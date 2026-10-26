# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a minimalistic website that displays daily stoic meditations from "The Daily Stoic: 366 Meditations on Wisdom, Perseverance, and the Art of Living" by Ryan Holiday and Stephen Hanselman. The application serves one meditation per day based on the current date.

## Architecture

**Tech Stack:**
- Backend: Node.js with Express server (server.js:1)
- Database: SQLite with file-based storage (daily-stoic.db)
- Frontend: Vanilla HTML/CSS/JavaScript (no frameworks)
- Styling: Google Fonts (Crimson Text) with custom CSS

**Key Components:**
- `server.js`: Express server with REST API endpoints for meditations
- `daily-stoic.db`: SQLite database containing 366 meditations with schema: id, month, day, title, quote, reference, context, date_key
- `public/index.html`: Single-page application structure
- `public/script.js`: Client-side JavaScript for API calls and DOM manipulation
- `public/style.css`: Responsive CSS with serif typography

**API Endpoints:**
- `GET /api/today` - Returns today's meditation based on current date
- `GET /api/meditation/:month/:day` - Returns specific meditation by date
- `GET /api/all` - Returns all meditations (titles only)
- `GET /api/health` - Health check endpoint

## Development Commands

**Start server:**
```bash
npm start
# or
npm run dev
```
Both commands run `node server.js` on port 3000 (configurable via PORT env var)

**Install dependencies:**
```bash
npm install
```

**Database operations:**
```bash
sqlite3 daily-stoic.db ".schema"  # View database schema
sqlite3 daily-stoic.db "SELECT * FROM meditations LIMIT 5;"  # Sample data
```

## Key Development Patterns

**Date Handling:**
- Date keys use format: `month-day` (e.g., "january-01", "december-31")
- Month names are lowercase, days are zero-padded
- Client and server both handle date parsing independently

**Error Handling:**
- Server returns consistent JSON error responses with status codes
- Client-side graceful degradation with loading/error states
- Database errors logged to console

**Database Schema:**
The `meditations` table stores daily content with these fields:
- `date_key`: Unique identifier for each day (e.g., "march-15")
- `month`/`day`: Separate fields for date components  
- `title`, `quote`, `reference`, `context`: Meditation content

**Deployment:**
- Production-ready with systemd service configuration
- Includes nginx reverse proxy setup
- SQLite database is included in git repository
- Analytics integration with Umami (script in index.html:11)