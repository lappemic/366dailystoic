# Deploying a Node.js Daily Stoic Website: From Development to Production with Nginx and Systemd

Building and deploying a web application can seem daunting, but with the right approach and tools, it becomes a straightforward process. In this post, I'll walk you through the complete setup of **The Daily Stoic** website - a minimalistic web app that serves daily philosophical meditations from Ryan Holiday's book "The Daily Stoic: 366 Meditations on Wisdom, Perseverance, and the Art of Living."

## Project Overview

The Daily Stoic website is designed with simplicity in mind:
- **Purpose**: Deliver one stoic meditation per day based on the current date
- **Design Philosophy**: Clean, readable interface with elegant typography
- **Tech Stack**: Minimal but robust - Node.js backend, SQLite database, vanilla frontend
- **Deployment**: Production-ready setup on a VPS with proper SSL and caching

## Tech Stack and Architecture

### Backend
- **Node.js + Express**: Lightweight server framework
- **SQLite**: File-based database with 366 pre-populated meditations
- **RESTful API**: Clean endpoints for fetching meditations

### Frontend
- **Vanilla HTML/CSS/JavaScript**: No frameworks, maximum performance
- **Google Fonts (Crimson Text)**: Elegant typography for readability
- **Responsive Design**: Works seamlessly on mobile and desktop

### Infrastructure
- **Ubuntu VPS**: Cost-effective hosting solution
- **Nginx**: Reverse proxy with SSL termination and static file caching
- **Systemd**: Process management and automatic restart capabilities
- **Let's Encrypt**: Free SSL certificates with automatic renewal

## Local Development Setup

### 1. Project Structure
```
366dailystoic/
├── server.js              # Express server with API routes
├── package.json           # Dependencies and scripts
├── daily-stoic.db         # SQLite database (586KB)
├── public/                # Static frontend files
│   ├── index.html         # Main page
│   ├── style.css          # Styling (4KB)
│   └── script.js          # Frontend logic (3KB)
└── README.md             # Documentation
```

### 2. Dependencies
The project uses minimal dependencies for maximum reliability:

```json
{
  "dependencies": {
    "express": "^4.18.2",
    "sqlite3": "^5.1.6"
  }
}
```

### 3. Server Configuration
The Express server (`server.js`) handles:
- Static file serving from the `public/` directory
- API endpoints for meditation data
- Database connections and queries
- Graceful shutdown handling

Key features:
```javascript
// Serve static files
app.use(express.static('public'));

// API endpoints
app.get('/api/today', (req, res) => { /* Today's meditation */ });
app.get('/api/meditation/:month/:day', (req, res) => { /* Specific date */ });
app.get('/api/all', (req, res) => { /* All meditations for navigation */ });
app.get('/api/health', (req, res) => { /* Health check */ });
```

### 4. Running Locally
```bash
# Install dependencies
npm install

# Start development server
npm start

# Visit the application
open http://localhost:3000
```

## Production Deployment on VPS

### 1. Server Preparation
First, set up your Ubuntu VPS with necessary packages:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js, Nginx, and other essentials
sudo apt install nodejs npm nginx git sqlite3 -y

# Clone your repository
git clone <your-repo-url>
cd 366dailystoic

# Install dependencies
npm install
```

### 2. Systemd Service Configuration

Create a systemd service for process management and automatic restarts:

**File: `/etc/systemd/system/daily-stoic.service`**
```ini
[Unit]
Description=Daily Stoic Website
Documentation=https://github.com/lappemic/366dailystoic
After=network.target

[Service]
Type=simple
User=devuser
WorkingDirectory=/home/devuser/projects/366dailystoic
ExecStart=/usr/bin/node server.js
Restart=on-failure
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=daily-stoic
Environment=NODE_ENV=production
Environment=PORT=3000

# Security settings
NoNewPrivileges=yes
PrivateTmp=yes

[Install]
WantedBy=multi-user.target
```

**Key Configuration Points:**
- **User**: Runs as non-root user (`devuser`) for security
- **WorkingDirectory**: Absolute path to your project
- **Restart Policy**: Automatically restarts on failure with 10-second delay
- **Logging**: Outputs to syslog with identifier for easy monitoring
- **Security**: Additional hardening with `NoNewPrivileges` and `PrivateTmp`

**Service Management:**
```bash
# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable daily-stoic
sudo systemctl start daily-stoic

# Check status
sudo systemctl status daily-stoic

# View logs
sudo journalctl -u daily-stoic -f
```

### 3. Nginx Reverse Proxy Configuration

Nginx serves as a reverse proxy, handling SSL termination, static file caching, and security headers.

**File: `/etc/nginx/sites-available/daily-stoic`**
```nginx
server {
    server_name 366dailystoic.com www.366dailystoic.com;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; connect-src 'self'" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;

    # Cache static assets and proxy to Node.js
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Proxy to Node.js app
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/366dailystoic.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/366dailystoic.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
}

# HTTP to HTTPS redirect
server {
    if ($host = www.366dailystoic.com) {
        return 301 https://$host$request_uri;
    }

    if ($host = 366dailystoic.com) {
        return 301 https://$host$request_uri;
    }

    listen 80;
    server_name 366dailystoic.com www.366dailystoic.com;
    return 404;
}
```

**Key Configuration Features:**
- **Security Headers**: Comprehensive security headers for XSS, clickjacking, and content type protection
- **Gzip Compression**: Reduces bandwidth usage for text-based files
- **Static File Caching**: 1-year cache for CSS/JS files with immutable cache-control
- **Proxy Configuration**: Proper headers for WebSocket support and real IP forwarding
- **SSL Configuration**: Managed by Certbot for automatic certificate management

**Enable the Configuration:**
```bash
# Create symlink to enable site
sudo ln -s /etc/nginx/sites-available/daily-stoic /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

### 4. SSL Certificate Setup with Let's Encrypt

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Obtain SSL certificate
sudo certbot --nginx -d 366dailystoic.com -d www.366dailystoic.com

# Test automatic renewal
sudo certbot renew --dry-run
```

## Common Issues and Troubleshooting

### Issue 1: Static Files Return 404 Errors

**Problem**: CSS and JavaScript files return `404 Not Found` errors when accessed via the domain.

**Symptoms:**
```
GET https://366dailystoic.com/style.css net::ERR_ABORTED 404 (Not Found)
GET https://366dailystoic.com/script.js net::ERR_ABORTED 404 (Not Found)
```

**Root Cause**: The Nginx location block for static files only sets cache headers but doesn't include `proxy_pass` directive.

**Solution**: Add the `proxy_pass` directive to the static files location block:
```nginx
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    proxy_pass http://localhost:3000;  # This was missing!
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    # ... other headers
    
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

**Verification:**
```bash
# Test locally
curl -I http://localhost:3000/style.css

# Test through Nginx
curl -I https://366dailystoic.com/style.css
```

### Issue 2: Service Won't Start

**Common causes and solutions:**
- **Port conflicts**: Ensure port 3000 isn't used by another service
- **Permission issues**: Verify the service user has read access to project files
- **Path errors**: Double-check `WorkingDirectory` and `ExecStart` paths in service file
- **Missing dependencies**: Run `npm install` in the project directory

### Issue 3: Database Connection Errors

**Solution**: Ensure the SQLite database file has proper permissions:
```bash
sudo chown devuser:devuser daily-stoic.db
chmod 644 daily-stoic.db
```

## Performance Optimizations

### 1. Database Query Optimization
- Indexed date_key column for fast daily lookups
- Connection pooling handled by sqlite3 driver
- Graceful database connection management

### 2. Caching Strategy
- **Static files**: 1-year browser cache with immutable flag
- **API responses**: Consider adding ETag headers for future optimization
- **Nginx**: Gzip compression for text-based content

### 3. Security Measures
- **Content Security Policy**: Restricts resource loading to trusted sources
- **Security headers**: Protection against common web vulnerabilities
- **HTTPS enforcement**: All traffic redirected to secure connections
- **Process isolation**: Service runs with minimal privileges

## Monitoring and Maintenance

### Service Monitoring
```bash
# Check service status
sudo systemctl status daily-stoic

# View real-time logs
sudo journalctl -u daily-stoic -f

# Check Nginx status
sudo systemctl status nginx

# Monitor resource usage
htop
```

### SSL Certificate Renewal
Let's Encrypt certificates auto-renew via systemd timer:
```bash
# Check renewal status
sudo certbot certificates

# Manual renewal (if needed)
sudo certbot renew
```

### Backup Strategy
```bash
# Backup database
cp daily-stoic.db backups/daily-stoic-$(date +%Y%m%d).db

# Backup Nginx configuration
sudo cp /etc/nginx/sites-available/daily-stoic backups/
```

## Conclusion

This setup provides a robust, production-ready deployment for a Node.js application with:
- **High availability** through systemd process management
- **Performance** via Nginx reverse proxy and caching
- **Security** through SSL, security headers, and proper permissions
- **Maintainability** through clear configuration and logging

The Daily Stoic website demonstrates that simple, well-architected solutions can be both powerful and maintainable. By leveraging proven technologies like Nginx, systemd, and Let's Encrypt, we've created a deployment that's secure, fast, and reliable.

The total setup takes about 30 minutes once you understand the components, and the result is a professional-grade web application that can handle significant traffic while remaining easy to maintain and monitor.

**Key Takeaways:**
1. **Keep it simple**: Minimal dependencies reduce complexity and potential failure points
2. **Security first**: Implement proper headers, SSL, and process isolation from the start
3. **Monitor everything**: Good logging and monitoring prevent small issues from becoming big problems
4. **Automate wisely**: Use systemd for process management and Let's Encrypt for SSL automation

Whether you're deploying a simple meditation website or a complex web application, these principles and configurations provide a solid foundation for production deployments. 