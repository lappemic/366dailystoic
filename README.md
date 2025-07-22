# The Daily Stoic Website

A minimalistic website that provides one stoic meditation per day from "The Daily Stoic: 366 Meditations on Wisdom, Perseverance, and the Art of Living" by Ryan Holiday and Stephen Hanselman.

## Features

- Daily meditation based on today's date
- Clean, readable design with elegant typography
- Responsive layout for mobile and desktop
- Minimal tech stack for easy deployment
- SQLite database with pre-populated meditations

## Tech Stack

- **Backend**: Node.js + Express
- **Database**: SQLite (file-based)
- **Frontend**: Vanilla HTML/CSS/JavaScript
- **Styling**: Google Fonts (Crimson Text)

## Setup

1. **Install dependencies**:
   ```bash
   npm install
   ```

2. **Start the server**:
   ```bash
   npm start
   ```

3. **Visit the website**:
   Open your browser to `http://localhost:3000`

## API Endpoints

- `GET /api/today` - Get today's meditation
- `GET /api/meditation/:month/:day` - Get meditation for specific date
- `GET /api/all` - Get all meditations (titles only)
- `GET /api/health` - Health check

## Project Structure

```
daily-stoic-website/
├── deploy/                        # VPS deployment configuration
│   ├── nginx.conf                 # Nginx reverse proxy config
│   ├── daily-stoic.service        # Systemd service file
│   ├── deploy.sh                  # Automated deployment script
│   └── setup-vps.sh               # VPS setup script
├── public/
│   ├── index.html                 # Main HTML page
│   ├── style.css                  # Styling
│   └── script.js                  # Client-side JavaScript
├── daily-stoic.db                 # SQLite database with meditations
├── ecosystem.config.js            # PM2 configuration
├── server.js                      # Express server
├── package.json                   # Dependencies and scripts
└── README.md                      # This file
```

## Deployment to VPS

### Automated Deployment (Recommended)

1. **Setup your VPS** (run on your VPS as root):
   ```bash
   curl -sSL https://raw.githubusercontent.com/yourusername/daily-stoic-website/main/deploy/setup-vps.sh | bash
   ```

2. **Deploy from your local machine**:
   ```bash
   ./deploy/deploy.sh devuser@your-vps your-domain.com
   ```

3. **Setup SSL certificate** (run on your VPS):
   ```bash
   sudo certbot --nginx -d your-domain.com
   ```

### Manual Deployment

1. **Copy files to your VPS**:
   ```bash
   rsync -av --exclude node_modules . devuser@your-vps:/home/devuser/projects/daily-stoic/
   ```

2. **On your VPS, install dependencies**:
   ```bash
   cd /home/devuser/projects/daily-stoic
   npm install --production
   ```

3. **Option A: Run with systemd service**:
   ```bash
   sudo cp deploy/daily-stoic.service /etc/systemd/system/
   sudo systemctl enable daily-stoic
   sudo systemctl start daily-stoic
   ```

4. **Option B: Run with PM2**:
   ```bash
   npm install -g pm2
   pm2 start ecosystem.config.js --env production
   pm2 startup
   pm2 save
   ```

5. **Setup nginx reverse proxy**:
   ```bash
   sudo cp deploy/nginx.conf /etc/nginx/sites-available/daily-stoic
   sudo ln -s /etc/nginx/sites-available/daily-stoic /etc/nginx/sites-enabled/
   sudo nginx -t && sudo systemctl reload nginx
   ```

## Environment Variables

- `PORT` - Server port (default: 3000)

## License

This project is for educational purposes. The original text belongs to Ryan Holiday and Stephen Hanselman. 