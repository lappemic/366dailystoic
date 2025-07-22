// DOM elements
const loadingEl = document.getElementById('loading');
const meditationEl = document.getElementById('meditation');
const errorEl = document.getElementById('error');
const todayDateEl = document.getElementById('today-date');

// Meditation content elements
const dateEl = document.getElementById('meditation-date');
const titleEl = document.getElementById('meditation-title');
const quoteEl = document.getElementById('meditation-quote');
const referenceEl = document.getElementById('meditation-reference');
const contextEl = document.getElementById('meditation-context');

// Format today's date
function formatTodayDate() {
    const today = new Date();
    const options = { 
        weekday: 'long', 
        year: 'numeric', 
        month: 'long', 
        day: 'numeric' 
    };
    return today.toLocaleDateString('en-US', options);
}

// Format meditation date
function formatMeditationDate(month, day) {
    const dayWithSuffix = addOrdinalSuffix(day);
    return `${month} ${dayWithSuffix}`;
}

// Add ordinal suffix to day (1st, 2nd, 3rd, etc.)
function addOrdinalSuffix(day) {
    if (day >= 11 && day <= 13) {
        return day + 'th';
    }
    switch (day % 10) {
        case 1: return day + 'st';
        case 2: return day + 'nd';
        case 3: return day + 'rd';
        default: return day + 'th';
    }
}

// Format context text (convert newlines to paragraphs)
function formatContext(context) {
    return context
        .split('\n\n')
        .filter(p => p.trim())
        .map(p => `<p>${p.trim()}</p>`)
        .join('');
}

// Show loading state
function showLoading() {
    loadingEl.style.display = 'block';
    meditationEl.style.display = 'none';
    errorEl.style.display = 'none';
}

// Show meditation
function showMeditation(data) {
    // Populate content
    dateEl.textContent = formatMeditationDate(data.month, data.day);
    titleEl.textContent = data.title;
    quoteEl.textContent = data.quote;
    referenceEl.textContent = data.reference;
    contextEl.innerHTML = formatContext(data.context);
    
    // Show meditation, hide loading
    loadingEl.style.display = 'none';
    meditationEl.style.display = 'block';
    errorEl.style.display = 'none';
}

// Show error
function showError() {
    loadingEl.style.display = 'none';
    meditationEl.style.display = 'none';
    errorEl.style.display = 'block';
}

// Fetch today's meditation
async function fetchTodaysMeditation() {
    try {
        showLoading();
        
        const response = await fetch('/api/today');
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const data = await response.json();
        showMeditation(data);
        
    } catch (error) {
        console.error('Error fetching meditation:', error);
        showError();
    }
}

// Initialize the page
function init() {
    // Set today's date in footer
    todayDateEl.textContent = formatTodayDate();
    
    // Fetch today's meditation
    fetchTodaysMeditation();
}

// Start the app when DOM is loaded
document.addEventListener('DOMContentLoaded', init); 