#!/bin/bash

# Daily Stoic Website Deployment Script
# Usage: ./deploy.sh [user@host] [app_path]

set -e

# Configuration
USER_HOST=${1:-"user@your-vps"}
APP_PATH=${2:-"/var/www/daily-stoic"}
DOMAIN=${3:-"your-domain.com"}

echo "🚀 Deploying Daily Stoic Website to $USER_HOST:$APP_PATH"

# Check if ssh key exists
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "❌ SSH key not found. Please set up SSH key authentication first."
    exit 1
fi

# Create app directory on VPS
echo "📁 Creating application directory..."
ssh $USER_HOST "sudo mkdir -p $APP_PATH && sudo chown -R \$USER:www-data $APP_PATH"

# Sync files to VPS (excluding node_modules and database)
echo "📦 Syncing files to VPS..."
rsync -av --progress \
    --exclude 'node_modules/' \
    --exclude 'daily-stoic.db' \
    --exclude '.git/' \
    --exclude 'logs/' \
    --exclude '.DS_Store' \
    ./ $USER_HOST:$APP_PATH/

# Install dependencies and setup on VPS
echo "⚙️  Installing dependencies on VPS..."
ssh $USER_HOST "cd $APP_PATH && npm install --production"

# Parse the book and create database
echo "📚 Parsing book and creating database..."
ssh $USER_HOST "cd $APP_PATH && npm run parse"

# Set proper permissions
echo "🔒 Setting permissions..."
ssh $USER_HOST "sudo chown -R \$USER:www-data $APP_PATH && sudo chmod -R 755 $APP_PATH"

# Setup systemd service
echo "🔧 Setting up systemd service..."
ssh $USER_HOST "sudo cp $APP_PATH/deploy/daily-stoic.service /etc/systemd/system/ && \
    sudo sed -i 's|/var/www/daily-stoic|$APP_PATH|g' /etc/systemd/system/daily-stoic.service && \
    sudo systemctl daemon-reload && \
    sudo systemctl enable daily-stoic && \
    sudo systemctl restart daily-stoic"

# Setup nginx configuration
echo "🌐 Setting up nginx configuration..."
ssh $USER_HOST "sudo cp $APP_PATH/deploy/nginx.conf /etc/nginx/sites-available/daily-stoic && \
    sudo sed -i 's/your-domain.com/$DOMAIN/g' /etc/nginx/sites-available/daily-stoic && \
    sudo ln -sf /etc/nginx/sites-available/daily-stoic /etc/nginx/sites-enabled/ && \
    sudo nginx -t && \
    sudo systemctl reload nginx"

# Check service status
echo "🔍 Checking service status..."
ssh $USER_HOST "sudo systemctl status daily-stoic --no-pager"

echo "✅ Deployment completed successfully!"
echo "📱 Your website should be available at: http://$DOMAIN"
echo ""
echo "📋 Next steps:"
echo "   1. Setup SSL certificate with Let's Encrypt:"
echo "      sudo certbot --nginx -d $DOMAIN"
echo "   2. Check logs with:"
echo "      sudo journalctl -u daily-stoic -f"
echo "   3. Restart service with:"
echo "      sudo systemctl restart daily-stoic" 