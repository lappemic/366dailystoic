module.exports = {
  apps: [{
    name: 'daily-stoic',
    script: 'server.js',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'development',
      PORT: 3000
    },
    env_production: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: '/var/log/daily-stoic/err.log',
    out_file: '/var/log/daily-stoic/out.log',
    log_file: '/var/log/daily-stoic/combined.log',
    time: true
  }]
}; 