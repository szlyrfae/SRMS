/**
 * Customer Dashboard JavaScript
 * Load events and attendees data
 */

// Load data when page loads
document.addEventListener('DOMContentLoaded', function() {
    initNavigation();
    loadDashboardData();
});

// Navigation to different pages
function initNavigation() {
    const navDashboard = document.getElementById('navDashboard');
    const navAddEvent = document.getElementById('navAddEvent');
    const navEventList = document.getElementById('navEventList');
    
    // Dashboard - stay on same page
    if (navDashboard) {
        navDashboard.addEventListener('click', function() {
            window.location.href = 'cust_dashboard.jsp';
        });
    }
    
    // Add Event - redirect to add_event.jsp
    if (navAddEvent) {
        navAddEvent.addEventListener('click', function() {
            window.location.href = 'add_event.jsp';
        });
    }
    
    // Event List - redirect to event_list.jsp
    if (navEventList) {
        navEventList.addEventListener('click', function() {
            window.location.href = 'event_list.jsp';
        });
    }
}

// Load dashboard statistics
function loadDashboardData() {
    // In real application, fetch from server
    // For demo, we'll use sample data or fetch from session
    
    // You can make an AJAX call to get actual data
    fetch('get_dashboard_data.jsp')
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                document.getElementById('totalEvents').textContent = data.totalEvents || 0;
                document.getElementById('totalAttendees').textContent = data.totalAttendees || 0;
                document.getElementById('completedEvents').textContent = data.completedEvents || 0;
                renderRecentEvents(data.recentEvents);
            }
        })
        .catch(error => {
            console.error('Error loading dashboard data:', error);
            // Set default values
            document.getElementById('totalEvents').textContent = '0';
            document.getElementById('totalAttendees').textContent = '0';
            document.getElementById('completedEvents').textContent = '0';
        });
}

// Render recent events
function renderRecentEvents(events) {
    const container = document.getElementById('recentEventsGrid');
    if (!container) return;
    
    if (!events || events.length === 0) {
        container.innerHTML = '<div class="no-events">No events yet. <a href="add_event.jsp">Create your first event</a></div>';
        return;
    }
    
    container.innerHTML = '';
    events.slice(0, 3).forEach(event => {
        const eventCard = document.createElement('div');
        eventCard.className = 'event-card';
        eventCard.innerHTML = `
            <h3 class="event-name">${escapeHtml(event.name)}</h3>
            <div class="event-details">
                <p><i class="fas fa-map-marker-alt"></i> ${escapeHtml(event.venue)}</p>
                <p><i class="fas fa-calendar-day"></i> ${escapeHtml(event.date)}</p>
                <p><i class="fas fa-clock"></i> ${escapeHtml(event.time)}</p>
            </div>
            <a href="event_details.jsp?id=${event.id}" class="details-link">View Details <i class="fas fa-arrow-right"></i></a>
        `;
        container.appendChild(eventCard);
    });
}

// Helper function to escape HTML
function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}