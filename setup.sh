#!/bin/bash

# ArgFuscator.net Docker Setup Script
# This script helps you quickly set up and run ArgFuscator.net with Docker

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        echo "Visit: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        echo "Visit: https://docs.docker.com/compose/install/"
        exit 1
    fi
    
    print_success "Docker and Docker Compose are installed"
}

# Check if we're in the right directory
check_directory() {
    if [ ! -f "Dockerfile" ]; then
        print_error "Dockerfile not found. Please ensure you're in the ArgFuscator.net directory with Docker files."
        exit 1
    fi
    print_success "Docker files found"
}

# Show menu
show_menu() {
    echo ""
    echo "=== ArgFuscator.net Docker Setup ==="
    echo ""
    echo "Choose an option:"
    echo "1) Development environment (with live reloading)"
    echo "2) Production environment (nginx)"
    echo "3) Build only (generate static files)"
    echo "4) Stop all services"
    echo "5) Clean up (remove containers and volumes)"
    echo "6) View logs"
    echo "7) Exit"
    echo ""
}

# Start development environment
start_dev() {
    print_status "Starting development environment..."
    print_status "This will be available at http://localhost:4000"
    print_status "Press Ctrl+C to stop"
    docker-compose up argfuscator-dev
}

# Start production environment
start_prod() {
    print_status "Starting production environment..."
    print_status "This will be available at http://localhost:8080"
    print_status "Running in detached mode"
    docker-compose up -d argfuscator-prod
    print_success "Production environment started!"
    print_status "Visit: http://localhost:8080"
    print_status "To stop: docker-compose down"
}

# Build only
build_only() {
    print_status "Building static site..."
    docker-compose up argfuscator-build
    print_success "Build completed! Check the _site directory"
}

# Stop services
stop_services() {
    print_status "Stopping all services..."
    docker-compose down
    print_success "All services stopped"
}

# Clean up
cleanup() {
    print_warning "This will remove all containers, volumes, and images for ArgFuscator"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Cleaning up..."
        docker-compose down -v --rmi all
        print_success "Cleanup completed"
    else
        print_status "Cleanup cancelled"
    fi
}

# View logs
view_logs() {
    echo ""
    echo "Choose service to view logs:"
    echo "1) Development"
    echo "2) Production"
    echo "3) Back to main menu"
    echo ""
    read -p "Enter choice [1-3]: " choice
    
    case $choice in
        1)
            print_status "Showing development logs (Press Ctrl+C to exit)..."
            docker-compose logs -f argfuscator-dev
            ;;
        2)
            print_status "Showing production logs (Press Ctrl+C to exit)..."
            docker-compose logs -f argfuscator-prod
            ;;
        3)
            return
            ;;
        *)
            print_error "Invalid option"
            view_logs
            ;;
    esac
}

# Main script
main() {
    print_status "ArgFuscator.net Docker Setup"
    
    # Check prerequisites
    check_docker
    check_directory
    
    while true; do
        show_menu
        read -p "Enter choice [1-7]: " choice
        
        case $choice in
            1)
                start_dev
                ;;
            2)
                start_prod
                ;;
            3)
                build_only
                ;;
            4)
                stop_services
                ;;
            5)
                cleanup
                ;;
            6)
                view_logs
                ;;
            7)
                print_status "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please choose 1-7."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main function
main "$@"
