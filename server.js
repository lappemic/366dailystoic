const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Create database connection
const db = new sqlite3.Database('daily-stoic.db');

// Serve static files
app.use(express.static('public'));

// API endpoint to get today's meditation
app.get('/api/today', (req, res) => {
  const today = new Date();
  const month = today.toLocaleDateString('en-US', { month: 'long' }).toLowerCase();
  const day = today.getDate();
  const dateKey = `${month}-${day.toString().padStart(2, '0')}`;
  
  db.get(
    'SELECT * FROM meditations WHERE date_key = ?',
    [dateKey],
    (err, row) => {
      if (err) {
        console.error('Database error:', err);
        res.status(500).json({ error: 'Database error' });
        return;
      }
      
      if (!row) {
        res.status(404).json({ error: 'Meditation not found for today' });
        return;
      }
      
      res.json(row);
    }
  );
});

// API endpoint to get a specific meditation by date
app.get('/api/meditation/:month/:day', (req, res) => {
  const { month, day } = req.params;
  const dateKey = `${month.toLowerCase()}-${day.padStart(2, '0')}`;
  
  db.get(
    'SELECT * FROM meditations WHERE date_key = ?',
    [dateKey],
    (err, row) => {
      if (err) {
        console.error('Database error:', err);
        res.status(500).json({ error: 'Database error' });
        return;
      }
      
      if (!row) {
        res.status(404).json({ error: 'Meditation not found' });
        return;
      }
      
      res.json(row);
    }
  );
});

// API endpoint to get all meditations (for navigation)
app.get('/api/all', (req, res) => {
  db.all(
    'SELECT id, month, day, title, date_key FROM meditations ORDER BY id',
    (err, rows) => {
      if (err) {
        console.error('Database error:', err);
        res.status(500).json({ error: 'Database error' });
        return;
      }
      
      res.json(rows);
    }
  );
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Serve the main page
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Start server
app.listen(PORT, () => {
  console.log(`Daily Stoic server running on port ${PORT}`);
  console.log(`Visit http://localhost:${PORT} to view today's meditation`);
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\nShutting down gracefully...');
  db.close((err) => {
    if (err) {
      console.error('Error closing database:', err);
    } else {
      console.log('Database connection closed.');
    }
    process.exit(0);
  });
}); 