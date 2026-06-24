/**
 * Customer Dashboard JavaScript
 * Synchronized for Dynamic MySQL Database & SRMS UI Elements
 */

// Muatkan data sebaik sahaja halaman selesai dimuatkan
document.addEventListener('DOMContentLoaded', function() {
    initNavigation();
    loadDashboardData();
});

// Menguruskan pautan navigasi menu tepi (Sidebar)
function initNavigation() {
    const navDashboard = document.getElementById('navDashboard');
    const navAddEvent = document.getElementById('navAddEvent');
    const navEventList = document.getElementById('navEventList');
    
    if (navDashboard) {
        navDashboard.addEventListener('click', function() {
            window.location.href = 'cust_dashboard.jsp';
        });
    }
    
    if (navAddEvent) {
        navAddEvent.addEventListener('click', function() {
            window.location.href = 'EventServlet';
        });
    }
    
    if (navEventList) {
        navEventList.addEventListener('click', function() {
            window.location.href = 'EventListServlet';
        });
    }
}

// Mengambil statistik dashboard menggunakan AJAX fetch
function loadDashboardData() {
    fetch('get_dashboard_data.jsp')
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.json();
        })
        .then(data => {
            if (data.success) {
                // 🎯 SINKRONISASI 1: Memastikan elemen dipetakan tepat mengikut ID di cust_dashboard.jsp
                if (document.getElementById('totalEvents')) {
                    document.getElementById('totalEvents').textContent = data.totalEvents ?? 0;
                }
                
                // 🎯 SINKRONISASI 2: Memetakan data upcomingEvents ke elemen id="Upcoming" anda
                if (document.getElementById('Upcoming')) {
                    document.getElementById('Upcoming').textContent = data.upcomingEvents ?? 0;
                }
                
                if (document.getElementById('completedEvents')) {
                    document.getElementById('completedEvents').textContent = data.completedEvents ?? 0;
                }
                
                // Muatkan kad senarai acara terbaharu
                renderRecentEvents(data.recentEvents);
            } else {
                console.error('Server returned failed status:', data.message);
                setDefaultStats();
            }
        })
        .catch(error => {
            console.error('Error loading dashboard data:', error);
            setDefaultStats();
        });
}

// Fungsi menetapkan nilai kosong jika sistem mengalami masalah database
function setDefaultStats() {
    if (document.getElementById('totalEvents')) document.getElementById('totalEvents').textContent = '0';
    if (document.getElementById('Upcoming')) document.getElementById('Upcoming').textContent = '0';
    if (document.getElementById('completedEvents')) document.getElementById('completedEvents').textContent = '0';
}

// Membina komponen kad acara secara dinamik ke dalam grid
function renderRecentEvents(events) {
    const container = document.getElementById('recentEventsGrid');
    if (!container) return;
    
    if (!events || events.length === 0) {
        container.innerHTML = '<div class="no-events" style="color: #888; padding: 20px;">No events found yet. <a href="EventServlet" style="color: #856404; font-weight: bold; text-decoration: underline;">Create your first event</a></div>';
        return;
    }
    
    container.innerHTML = '';
    
    // Ambil maksimum 3 acara sahaja untuk dipaparkan di grid hadapan
    events.slice(0, 3).forEach(event => {
        const eventCard = document.createElement('div');
        eventCard.className = 'event-card';
        eventCard.innerHTML = `
            <h3 class="event-name">${escapeHtml(event.name)}</h3>
            <div class="event-details">
                <p><i class="fas fa-map-marker-alt"></i> Venue: ${escapeHtml(event.venue)}</p>
                <p><i class="fas fa-calendar-day"></i> Date: ${escapeHtml(event.date)}</p>
                <p><i class="fas fa-clock"></i> Time: ${escapeHtml(event.time)}</p>
            </div>
            <a href="event_details.jsp?id=${event.id}" class="details-link" style="display: inline-block; margin-top: 15px; text-decoration: none; color: #856404; font-weight: 500;">
                View Details <i class="fas fa-arrow-right"></i>
            </a>
        `;
        container.appendChild(eventCard);
    });
}

// Fungsi keselamatan menghalang serangan XSS inject script pada form input teks
function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}