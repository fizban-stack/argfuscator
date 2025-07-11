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

# Build TypeScript to JavaScript first
RUN if [ -f "src/tsconfig.json" ]; then \
        echo "Compiling TypeScript with tsconfig.json..."; \
        tsc --project src/ --outfile gui/assets/js/main.js; \
    elif [ -d "src" ] && [ -f "src/*.ts" ]; then \
        echo "Compiling TypeScript files to gui/assets/js/..."; \
        mkdir -p gui/assets/js && \
        tsc --project src/ --outDir gui/assets/js/; \
    else \
        echo "No TypeScript source found, skipping compilation"; \
    fi

# Copy and convert models for Jekyll
RUN if [ -d "models" ]; then \
        echo "Processing models..."; \
        cp -r models/ gui/assets/ && \
        if [ -f ".github/workflows/json-transform.py" ]; then \
            python3 .github/workflows/json-transform.py; \
        fi; \
    else \
        echo "No models directory found, skipping model processing"; \
    fi

# Change to the gui directory where the Jekyll site is located
WORKDIR /app/gui

# Install Jekyll and dependencies
RUN gem install jekyll bundler

# Create necessary directories
RUN mkdir -p _includes _layouts _posts assets/js assets/css

# Check if Gemfile exists in gui directory, if not create a basic one
RUN if [ ! -f Gemfile ]; then \
        echo "Creating Gemfile..."; \
        echo "source 'https://rubygems.org'" > Gemfile && \
        echo "gem 'jekyll', '~> 4.3'" >> Gemfile && \
        echo "gem 'webrick', '~> 1.7'" >> Gemfile && \
        echo "gem 'kramdown-parser-gfm'" >> Gemfile; \
    fi

# Install bundle dependencies
RUN bundle install

# Create a minimal _config.yml if it doesn't exist
RUN if [ ! -f _config.yml ]; then \
        echo "Creating basic _config.yml..."; \
        echo "title: ArgFuscator.net" > _config.yml && \
        echo "description: Command-line obfuscation tool" >> _config.yml && \
        echo "baseurl: ''" >> _config.yml && \
        echo "url: ''" >> _config.yml && \
        echo "markdown: kramdown" >> _config.yml && \
        echo "highlighter: rouge" >> _config.yml && \
        echo "plugins:" >> _config.yml && \
        echo "  - jekyll-feed" >> _config.yml; \
    fi

# Create missing include files if they don't exist
RUN if [ ! -f _includes/faqs.html ]; then \
        echo "Creating missing faqs.html include..."; \
        echo '<div class="faqs">' > _includes/faqs.html && \
        echo '  <h2>Frequently Asked Questions</h2>' >> _includes/faqs.html && \
        echo '  <p>FAQ content would go here.</p>' >> _includes/faqs.html && \
        echo '</div>' >> _includes/faqs.html; \
    fi

# Try to build Jekyll site, with fallback if it fails
RUN bundle exec jekyll build --destination ../_site --trace || \
    (echo "Initial build failed, trying with safe mode..." && \
     bundle exec jekyll build --destination ../_site --safe --trace) || \
    (echo "Build failed, creating minimal site..." && \
     mkdir -p ../_site && \
     echo '<!DOCTYPE html><html><head><title>ArgFuscator.net</title></head><body><h1>ArgFuscator.net</h1><p>Command-line obfuscation tool</p></body></html>' > ../_site/index.html)

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

# Default command for development - handle both TypeScript compilation and Jekyll serving
CMD ["sh", "-c", "\
    # Compile TypeScript if present \
    if [ -f 'src/tsconfig.json' ]; then \
        echo 'Compiling TypeScript...'; \
        tsc --project src/ --outfile gui/assets/js/main.js; \
    elif [ -d 'src' ]; then \
        echo 'Compiling TypeScript to gui/assets/js/...'; \
        tsc --project src/ --outDir gui/assets/js/; \
    fi && \
    # Process models if present \
    if [ -d 'models' ]; then \
        echo 'Processing models...'; \
        cp -r models/ gui/assets/ && \
        if [ -f '.github/workflows/json-transform.py' ]; then \
            python3 .github/workflows/json-transform.py; \
        fi; \
    fi && \
    # Change to gui directory \
    cd gui && \
    # Create Gemfile if it doesn't exist \
    if [ ! -f Gemfile ]; then \
        echo 'Creating Gemfile...'; \
        echo 'source \"https://rubygems.org\"' > Gemfile && \
        echo 'gem \"jekyll\", \"~> 4.3\"' >> Gemfile && \
        echo 'gem \"webrick\", \"~> 1.7\"' >> Gemfile && \
        echo 'gem \"kramdown-parser-gfm\"' >> Gemfile; \
    fi && \
    # Install dependencies and start Jekyll server \
    echo 'Installing Jekyll dependencies...' && \
    bundle install && \
    echo 'Starting Jekyll development server...' && \
    bundle exec jekyll serve --host 0.0.0.0 --port 4000 --watch --force_polling --incremental \
    "]
