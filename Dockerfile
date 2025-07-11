# Multi-stage Dockerfile for ArgFuscator.net
# Stage 1: Build stage with all dependencies
FROM ruby:3.1-alpine AS builder

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    nodejs \
    npm \
    python3 \
    py3-pip \
    git \
    && npm install -g typescript

# Set working directory
WORKDIR /app

# Install Python dependencies
RUN pip3 install --break-system-packages pyyaml

# Copy source code
COPY . .

# Install Jekyll and dependencies
RUN gem install jekyll bundler

# Check if Gemfile exists, if not create a basic one
RUN if [ ! -f Gemfile ]; then \
        echo "source 'https://rubygems.org'" > Gemfile && \
        echo "gem 'jekyll', '~> 4.3'" >> Gemfile && \
        echo "gem 'webrick', '~> 1.7'" >> Gemfile; \
    fi

# Install bundle dependencies
RUN bundle install

# Build TypeScript to JavaScript
RUN if [ -f "src/tsconfig.json" ]; then \
        tsc --project src/ --outfile gui/assets/js/main.js; \
    elif [ -d "src" ]; then \
        tsc --project src/ --outDir gui/assets/js/; \
    else \
        echo "No TypeScript source found, skipping compilation"; \
    fi

# Copy and convert models for Jekyll
RUN if [ -d "models" ]; then \
        cp -r models/ gui/assets/ && \
        if [ -f ".github/workflows/json-transform.py" ]; then \
            python3 .github/workflows/json-transform.py; \
        fi; \
    fi

# Build Jekyll site
RUN bundle exec jekyll build --destination _site

# Stage 2: Production stage with nginx
FROM nginx:alpine AS production

# Copy built site from builder stage
COPY --from=builder /app/_site /usr/share/nginx/html

# Copy custom nginx configuration if needed
COPY <<EOF /etc/nginx/conf.d/default.conf
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html index.htm;

    # Enable gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    location / {
        try_files \$uri \$uri/ =404;
    }

    # Cache static assets
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

EXPOSE 80

# Stage 3: Development stage for live development
FROM ruby:3.1-alpine AS development

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    nodejs \
    npm \
    python3 \
    py3-pip \
    git \
    && npm install -g typescript

# Set working directory
WORKDIR /app

# Install Python dependencies
RUN pip3 install --break-system-packages pyyaml

# Install Jekyll and bundler
RUN gem install jekyll bundler

# Expose port for Jekyll development server
EXPOSE 4000

# Default command for development
CMD ["sh", "-c", "if [ ! -f Gemfile ]; then echo 'source \"https://rubygems.org\"' > Gemfile && echo 'gem \"jekyll\", \"~> 4.3\"' >> Gemfile && echo 'gem \"webrick\", \"~> 1.7\"' >> Gemfile; fi && bundle install && if [ -f 'src/tsconfig.json' ]; then tsc --project src/ --outfile gui/assets/js/main.js; elif [ -d 'src' ]; then tsc --project src/ --outDir gui/assets/js/; fi && if [ -d 'models' ]; then cp -r models/ gui/assets/ && if [ -f '.github/workflows/json-transform.py' ]; then python3 .github/workflows/json-transform.py; fi; fi && bundle exec jekyll serve --host 0.0.0.0 --port 4000 --watch --force_polling"]
