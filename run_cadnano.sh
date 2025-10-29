#!/bin/bash

# Cadnano2 Docker GUI Runner
# This script helps run Cadnano2 with GUI support in Docker

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

# Setup X11 forwarding for macOS
setup_macos_x11() {
    print_status "Setting up X11 forwarding for macOS..."
    
    # Check if XQuartz is installed
    if ! command -v xquartz &> /dev/null; then
        print_error "XQuartz is not installed. Please install it first:"
        echo "  brew install --cask xquartz"
        echo "Then restart your terminal and run this script again."
        exit 1
    fi
    
    # Check if XQuartz is running
    if ! pgrep -x "Xquartz" > /dev/null; then
        print_status "Starting XQuartz..."
        open -a XQuartz
        sleep 3
    fi
    
    # Allow X11 connections from localhost and Docker
    print_status "Configuring X11 permissions..."
    xhost +localhost
    xhost +127.0.0.1
    
    # Set DISPLAY variable
    export DISPLAY=:0
    
    # Create Xauthority file if it doesn't exist
    if [ ! -f ~/.Xauthority ]; then
        touch ~/.Xauthority
    fi
    
    # Set XAUTHORITY environment variable
    export XAUTHORITY=~/.Xauthority
    
    print_status "macOS X11 forwarding configured successfully"
}

# Setup X11 forwarding for Linux
setup_linux_x11() {
    print_status "Setting up X11 forwarding for Linux..."
    
    # Allow X11 connections from local host
    xhost +local:docker
    
    # Set DISPLAY variable if not already set
    if [ -z "$DISPLAY" ]; then
        export DISPLAY=:0
    fi
    
    # Create Xauthority file if it doesn't exist
    if [ ! -f ~/.Xauthority ]; then
        touch ~/.Xauthority
    fi
    
    # Set XAUTHORITY environment variable
    export XAUTHORITY=~/.Xauthority
    
    print_status "Linux X11 forwarding configured successfully"
}

# Pull Docker image
pull_image() {
    print_status "Pulling Cadnano2 Docker image from Docker Hub..."
    docker-compose pull
    print_status "Docker image pulled successfully"
}

# Run Cadnano2 container
run_container() {
    print_status "Starting Cadnano2 container..."
    
    # Create data directories if they don't exist
    mkdir -p ./cadnano_data ./cadnano_projects
    
    # Run the container
    docker-compose up
}

# Stop container
stop_container() {
    print_status "Stopping Cadnano2 container..."
    docker-compose down
    print_status "Container stopped"
}

# Show help
show_help() {
    echo "Cadnano2 Docker GUI Runner"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  pull      Pull the Docker image from Docker Hub"
    echo "  run       Run Cadnano2 with GUI support"
    echo "  stop      Stop the running container"
    echo "  setup     Setup X11 forwarding for your platform"
    echo "  help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 setup    # Setup X11 forwarding"
    echo "  $0 pull     # Pull the Docker image from Docker Hub"
    echo "  $0 run      # Run Cadnano2"
    echo ""
    echo "Platform-specific notes:"
    echo "  macOS: Requires XQuartz to be installed and running"
    echo "  Linux: Requires X11 server to be running"
}

# Main script logic
main() {
    case "${1:-help}" in
        "setup")
            OS=$(detect_os)
            case $OS in
                "macos")
                    setup_macos_x11
                    ;;
                "linux")
                    setup_linux_x11
                    ;;
                *)
                    print_error "Unsupported operating system: $OSTYPE"
                    exit 1
                    ;;
            esac
            ;;
        "pull")
            pull_image
            ;;
        "run")
            OS=$(detect_os)
            case $OS in
                "macos")
                    setup_macos_x11
                    ;;
                "linux")
                    setup_linux_x11
                    ;;
                *)
                    print_error "Unsupported operating system: $OSTYPE"
                    exit 1
                    ;;
            esac
            run_container
            ;;
        "stop")
            stop_container
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Run main function with all arguments
main "$@"