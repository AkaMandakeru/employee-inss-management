#!/bin/bash

# Docker Setup Script for CrediShop Test
# This script helps you get started with Docker

set -e

echo "🐳 CrediShop Test - Docker Setup"
echo "================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop and try again."
    exit 1
fi

echo "✅ Docker is running"

# Check if docker compose is available
if ! docker compose version > /dev/null 2>&1; then
    echo "❌ Docker Compose is not available. Please ensure Docker Desktop is installed."
    exit 1
fi

echo "✅ Docker Compose is available"

# Function to start development environment
start_dev() {
    echo "🚀 Starting development environment..."
    docker compose -f docker-compose.dev.yml up --build -d

    echo "⏳ Waiting for database to be ready..."
    sleep 10

    echo "🗄️  Setting up database..."
    docker compose -f docker-compose.dev.yml exec web rails db:create db:migrate db:seed

    echo "✅ Development environment is ready!"
    echo "🌐 Application: http://localhost:3000"
    echo "🔐 Admin login: admin@credishop.com / admin123"
}

# Function to start production environment
start_prod() {
    echo "🚀 Starting production environment..."

    # Check for Rails master key
    if [ ! -f "config/master.key" ]; then
        echo "❌ Rails master key not found. Please ensure config/master.key exists."
        exit 1
    fi

    export RAILS_MASTER_KEY=$(cat config/master.key)
    docker compose up --build -d

    echo "⏳ Waiting for database to be ready..."
    sleep 15

    echo "🗄️  Setting up database..."
    docker compose exec web rails db:create db:migrate db:seed

    echo "✅ Production environment is ready!"
    echo "🌐 Application: http://localhost:3000"
    echo "🔐 Admin login: admin@credishop.com / admin123"
}

# Function to stop services
stop_services() {
    echo "🛑 Stopping services..."
    docker compose down 2>/dev/null || true
    docker compose -f docker-compose.dev.yml down 2>/dev/null || true
    echo "✅ Services stopped"
}

# Function to clean up
cleanup() {
    echo "🧹 Cleaning up Docker resources..."
    docker compose down -v 2>/dev/null || true
    docker compose -f docker-compose.dev.yml down -v 2>/dev/null || true
    docker system prune -f
    echo "✅ Cleanup complete"
}

# Main menu
case "${1:-menu}" in
    "dev")
        start_dev
        ;;
    "prod")
        start_prod
        ;;
    "stop")
        stop_services
        ;;
    "cleanup")
        cleanup
        ;;
    "menu"|*)
        echo ""
        echo "Available commands:"
        echo "  ./docker-setup.sh dev     - Start development environment"
        echo "  ./docker-setup.sh prod    - Start production environment"
        echo "  ./docker-setup.sh stop    - Stop all services"
        echo "  ./docker-setup.sh cleanup - Clean up Docker resources"
        echo ""
        echo "Examples:"
        echo "  ./docker-setup.sh dev     # Recommended for development"
        echo "  ./docker-setup.sh prod    # For production testing"
        echo ""
        ;;
esac
