/**
 * Event Details JavaScript
 * Handle generate links, copy links, refresh attendees, and navigation
 */

document.addEventListener('DOMContentLoaded', function() {
    initNavigation();
    initEventDetails();
});

// Navigation based on role
function initNavigation() {
    const navDashboard = document.getElementById('navDashboard');
    const navHall = document.getElementById('navHall');
    const navStaff = document.getElementById('navStaff');
    const navReport = document.getElementById('navReport');
    const navEventList = document.getElementById('navEventList');
    const navAddEvent = document.getElementById('navAddEvent');
    
    // Staff navigation
    if (navDashboard && window.userRole === 'Staff') {
        navDashboard.addEventListener('click', function() {
            window.location.href = 'staff_dashboard.jsp';
        });
    } else if (navDashboard) {
        navDashboard.addEventListener('click', function() {
            window.location.href = 'cust_dashboard.jsp';
        });
    }
    
    if (navHall) {
        navHall.addEventListener('click', function() {
            window.location.href = 'hall.jsp';
        });
    }
    
    if (navStaff) {
        navStaff.addEventListener('click', function() {
            window.location.href = 'staff.jsp';
        });
    }
    
    if (navReport) {
        navReport.addEventListener('click', function() {
            window.location.href = 'report.jsp';
        });
    }
    
    if (navEventList) {
        navEventList.addEventListener('click', function() {
            window.location.href = 'event_list.jsp';
        });
    }
    
    if (navAddEvent) {
        navAddEvent.addEventListener('click', function() {
            window.location.href = 'add_event.jsp';
        });
    }
}

// Initialize event details functions
function initEventDetails() {
    // Load attendees on page load
    if (window.eventId) {
        refreshAttendeeList(window.eventId);
        
        // Auto refresh every 30 seconds
        let refreshInterval = setInterval(function() {
            refreshAttendeeList(window.eventId);
        }, 30000);
        
        // Clear interval when page is unloaded
        window.addEventListener('beforeunload', function() {
            if (refreshInterval) {
                clearInterval(refreshInterval);
            }
        });
    }
}

// Generate link function
function generateLink(type, eventId) {
    fetch('generate_link.jsp', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'action=generate&type=' + type + '&eventId=' + eventId
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            location.reload();
        } else {
            alert('Failed to generate link. Please try again.');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('An error occurred. Please try again.');
    });
}

// Regenerate link function
function regenerateLink(type, eventId) {
    if (confirm('Are you sure you want to regenerate this link? The old link will no longer work.')) {
        fetch('generate_link.jsp', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'action=regenerate&type=' + type + '&eventId=' + eventId
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                location.reload();
            } else {
                alert('Failed to regenerate link. Please try again.');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('An error occurred. Please try again.');
        });
    }
}

// Copy to clipboard function
function copyToClipboard(elementId) {
    const inputElement = document.getElementById(elementId);
    if (!inputElement) return;
    
    inputElement.select();
    inputElement.setSelectionRange(0, 99999);
    
    try {
        document.execCommand('copy');
        showToast('Link copied to clipboard!');
    } catch (err) {
        navigator.clipboard.writeText(inputElement.value).then(() => {
            showToast('Link copied to clipboard!');
        }).catch(() => {
            alert('Failed to copy link. Please copy manually.');
        });
    }
}

// Refresh attendee list
function refreshAttendeeList(eventId) {
    const tableBody = document.getElementById('attendeeTableBody');
    if (!tableBody) return;
    
    tableBody.innerHTML = '<tr><td colspan="4" class="loading-text">Loading attendees...</td></tr>';
    
    fetch('generate_link.jsp?action=getAttendees&eventId=' + eventId)
        .then(response => response.json())
        .then(data => {
            if (data.success && data.attendees) {
                if (data.attendees.length === 0) {
                    tableBody.innerHTML = '<tr><td colspan="4" class="loading-text">No attendees registered yet.</td></tr>';
                } else {
                    tableBody.innerHTML = '';
                    data.attendees.forEach(attendee => {
                        const row = tableBody.insertRow();
                        row.insertCell(0).textContent = attendee.name || '-';
                        row.insertCell(1).textContent = attendee.phone || '-';
                        row.insertCell(2).textContent = attendee.email || '-';
                        
                        const statusCell = row.insertCell(3);
                        const statusClass = attendee.status === 'Registered' ? 'status-registered' : 
                                           (attendee.status === 'Attended' ? 'status-attended' : 'status-cancelled');
                        statusCell.innerHTML = `<span class="status-badge ${statusClass}">${attendee.status || 'Pending'}</span>`;
                    });
                }
            } else {
                tableBody.innerHTML = '<tr><td colspan="4" class="loading-text">Failed to load attendees.</td></tr>';
            }
        })
        .catch(error => {
            console.error('Error:', error);
            tableBody.innerHTML = '<tr><td colspan="4" class="loading-text">Error loading attendees.</td></tr>';
        });
}

// Show toast notification
function showToast(message) {
    let toast = document.querySelector('.toast-notification');
    if (!toast) {
        toast = document.createElement('div');
        toast.className = 'toast-notification';
        toast.style.cssText = `
            position: fixed;
            bottom: 20px;
            right: 20px;
            background: #4a3b2f;
            color: white;
            padding: 12px 20px;
            border-radius: 8px;
            font-size: 14px;
            z-index: 1000;
            opacity: 0;
            transition: opacity 0.3s ease;
            pointer-events: none;
        `;
        document.body.appendChild(toast);
    }
    
    toast.textContent = message;
    toast.style.opacity = '1';
    
    setTimeout(() => {
        toast.style.opacity = '0';
    }, 2000);
}