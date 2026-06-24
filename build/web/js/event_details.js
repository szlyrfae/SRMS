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
            window.location.href = 'ReportServlet';
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
    /*if (window.eventId) {
        refreshAttendeeList(window.eventId);
        
        // Auto refresh every 15 seconds
        let refreshInterval = setInterval(function() {
            refreshAttendeeList(window.eventId);
        }, 15000);
        
        // Clear interval when page is unloaded
        window.addEventListener('beforeunload', function() {
            if (refreshInterval) {
                clearInterval(refreshInterval);
            }
        });
    }*/
}

// Fungsi Generate Link (Versi Kebal - Terus Auto-Reload)
function generateLink(type, eventId) {
    fetch(`generate_link.jsp?action=generate&type=${type}&eventId=${eventId}`)
    .then(response => {
        // Kita tidak perlu pakai response.json() lagi untuk elakkan crash.
        // Sebaik sahaja server bagi respon (200 OK), kita terus paksa halaman REFRESH!
        window.location.reload();
    })
    .catch(error => {
        console.error('Error:', error);
        // Jika ada ralat format sekalipun, kita tetap force reload sebab data dah siap di server
        window.location.reload();
    });
}

// Fungsi Regenerate Link (Versi Kebal - Terus Auto-Reload)
function regenerateLink(type, eventId) {
    if (confirm('Are you sure you want to regenerate this link? The old link will no longer work.')) {
        fetch(`generate_link.jsp?action=regenerate&type=${type}&eventId=${eventId}`)
        .then(response => {
            window.location.reload(); // Terus paksa auto-refresh!
        })
        .catch(error => {
            console.error('Error:', error);
            window.location.reload(); // Force reload juga jika ada ralat pembacaan
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

// 🎯 REFRESH ATTENDEE LIST (VERSI STABIL & ANTI-CACHE)
function refreshAttendeeList(eventId) {
    const tableBody = document.getElementById('attendeeTableBody');
    if (!tableBody) return;

    // Tambah timestamp (_=Date.now()) untuk memaksa browser ambil data baru, bukan dari cache!
    fetch(`generate_link.jsp?action=getAttendees&eventId=${eventId}&_=${Date.now()}`)
        .then(response => {
            if (!response.ok) {
                throw new Error('Server returned HTTP ' + response.status);
            }
            return response.json();
        })
        .then(data => {
            if (data.success) {
                if (!data.attendees || data.attendees.length === 0) {
                    tableBody.innerHTML = `<tr><td colspan="4" style="text-align:center; color:#888; padding:20px;"><i class="fas fa-folder-open"></i> No participants registered yet for this event.</td></tr>`;
                    return;
                }

                let html = '';
                data.attendees.forEach(attendee => {
                    let statusClass = 'badge-absent';
                    let statusText = 'Tak Hadir';
                    
                    // Memastikan rsvp_status dibaca dengan betul walaupun dari huruf besar/kecil
                    if (attendee.status && (attendee.status.toLowerCase() === 'hadir' || attendee.status.toLowerCase() === 'present')) {
                        statusClass = 'badge-success';
                        statusText = 'Hadir';
                    }

                    html += `<tr>
                        <td><strong>${attendee.name}</strong></td>
                        <td>${attendee.phone}</td>
                        <td>${attendee.email ? attendee.email : '-'}</td>
                        <td><span class="badge ${statusClass}">${statusText}</span></td>
                    </tr>`;
                });
                
                tableBody.innerHTML = html;
            } else {
                tableBody.innerHTML = `<tr><td colspan="4" style="color:#c62828; text-align:center; padding:15px;"><i class="fas fa-exclamation-circle"></i> Error: ${data.message}</td></tr>`;
            }
        })
        .catch(err => {
            console.error('AJAX Error:', err);
            tableBody.innerHTML = `<tr><td colspan="4" style="color:#c62828; text-align:center; padding:15px;"><i class="fas fa-exclamation-circle"></i> Error loading attendees.</td></tr>`;
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