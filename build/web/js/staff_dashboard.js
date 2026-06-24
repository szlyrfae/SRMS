/**
 * Staff Dashboard JavaScript
 * Simple navigation for all staff pages
 */

document.addEventListener('DOMContentLoaded', function() {
    initNavigation();
    initEventDetails();
});

// Navigation to different pages
function initNavigation() {
    const navDashboard = document.getElementById('navDashboard');
    const navHall = document.getElementById('navHall');
    const navReport = document.getElementById('navReport');
    const navReservation = document.getElementById('navReservation');
    const navStaff = document.getElementById('navStaff');
    
    if (navDashboard) {
        navDashboard.addEventListener('click', function() {
            window.location.href = 'staff_dashboard.jsp';
        });
    }
    
    if (navHall) {
        navHall.addEventListener('click', function() {
            window.location.href = 'hall.jsp';
        });
    }
    
    if (navReport) {
        navReport.addEventListener('click', function() {
            window.location.href = 'ReportServlet';
        });
    }
    
    if (navReservation) {
        navReservation.addEventListener('click', function() {
            window.location.href = 'EventListServlet';
        });
    }
    
    if (navStaff) {
        navStaff.addEventListener('click', function() {
            window.location.href = 'staff.jsp';
        });
    }
}

function initEventDetails() {
    const detailsBtns = document.querySelectorAll('.details-btn');
    
    detailsBtns.forEach(btn => {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            const eventId = this.getAttribute('data-id');
            // Redirect to event_details.jsp with the event ID
            window.location.href = 'event_details.jsp?id=' + eventId;
        });
    });
}