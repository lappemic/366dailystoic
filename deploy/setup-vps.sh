#!/bin/bash

# VPS Setup Script for Daily Stoic Website
# For Ubuntu/Debian systems with existing devuser
# Run as: curl -sSL https://raw.githubusercontent.com/yourusername/daily-stoic-website/main/deploy/setup-vps.sh | bash

set -e

echo "🛠️  Setting up VPS for Daily Stoic Website..."

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Node.js (using NodeSource repository)
echo "📱 Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install nginx
echo "🌐 Installing nginx..."
sudo apt install -y nginx

# Install certbot for SSL
echo "🔐 Installing certbot for SSL certificates..."
sudo apt install -y certbot python3-certbot-nginx

# Install PM2 globally (alternative to systemd)
echo "⚡ Installing PM2..."
sudo npm install -g pm2

# Setup firewall
echo "🔥 Setting up firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

# Create projects directory for devuser
echo "📁 Creating projects directory..."
sudo -u devuser mkdir -p /home/devuser/projects
sudo mkdir -p /var/log/daily-stoic

# Set up log rotation
echo "📋 Setting up log rotation..."
sudo tee /etc/logrotate.d/daily-stoic > /dev/null <<EOF
/var/log/daily-stoic/*.log {
    daily
    missingok
    rotate 14
    compress
    notifempty
    create 0640 devuser devuser
}
EOF

# Enable and start nginx
echo "🚀 Starting nginx..."
sudo systemctl enable nginx
sudo systemctl start nginx

# Setup basic nginx default page
sudo tee /var/www/html/index.html > /dev/null <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>VPS Setup Complete</title>
</head>
<body>
    <h1>VPS Setup Complete!</h1>
    <p>Your server is ready for Daily Stoic Website deployment.</p>
    <p>Run the deployment script to install the application.</p>
    <p>User: devuser | Projects: /home/devuser/projects</p>
</body>
</html>
EOF

echo "✅ VPS setup completed successfully!"
echo ""
echo "📋 What was installed:"
echo "   ✓ Node.js $(node --version)"
echo "   ✓ npm $(npm --version)"
echo "   ✓ nginx $(nginx -v 2>&1 | cut -d/ -f2)"
echo "   ✓ PM2 $(pm2 --version)"
echo "   ✓ certbot $(certbot --version | head -n1)"
echo ""
echo "🔧 Configuration:"
echo "   ✓ Projects directory: /home/devuser/projects"
echo "   ✓ User: devuser"
echo "   ✓ Firewall configured (ports 22, 80, 443)"
echo ""
echo "🔧 Next steps:"
echo "   1. Configure your domain's DNS to point to this server"
echo "   2. Run the deployment script from your local machine:"
echo "      ./deploy/deploy.sh devuser@your-server your-domain.com"
echo "   3. Setup SSL certificate:"
echo "      sudo certbot --nginx -d your-domain.com"
echo ""
echo "🌐 Test your server: http://$(curl -s ifconfig.me)" 