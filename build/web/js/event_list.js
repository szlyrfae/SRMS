/**
 * Event List Page JavaScript
 * Handle navigation for both Staff and Customer
 */

/**
 * Event List Page JavaScript (MVC Version)
 * Handle navigation and secure deletion for both Staff and Customer
 */

document.addEventListener('DOMContentLoaded', function() {
    initNavigation();
    initDeleteConfirmation();
});

// Menguruskan navigasi berpusat berasaskan Router Servlet
function initNavigation() {
    // Elemen Navigasi Kakitangan (Staff)
    const navStaffDashboard = document.getElementById('navStaffDashboard');
    const navHall = document.getElementById('navHall');
    const navStaff = document.getElementById('navStaff');
    const navReport = document.getElementById('navReport');
    
    // Elemen Navigasi Pelanggan (Customer)
    const navCustDashboard = document.getElementById('navCustDashboard');
    const navAddEvent = document.getElementById('navAddEvent');
    
    // Elemen Navigasi Bersama
    const navEventList = document.getElementById('navEventList');
    
    // Pautan Menu Staff
    if (navStaffDashboard) {
        navStaffDashboard.addEventListener('click', function() {
            window.location.href = 'staff_dashboard.jsp';
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
    
    // Pautan Menu Customer (PEMBETULAN: Mesti melalui EventServlet)
    if (navCustDashboard) {
        navCustDashboard.addEventListener('click', function() {
            window.location.href = 'cust_dashboard.jsp';
        });
    }
    
    if (navAddEvent) {
        navAddEvent.addEventListener('click', function() {
            window.location.href = 'EventServlet'; // <-- Diubah dari add_event.jsp
        });
    }
    
    // Pautan Menu Bersama (PEMBETULAN: Mesti melalui EventListServlet)
    if (navEventList) {
        navEventList.addEventListener('click', function() {
            window.location.href = 'EventListServlet'; // <-- Diubah dari event_list.jsp
        });
    }
}

// Menguruskan pengesahan butang padam secara selamat (POST Form Submission)
function initDeleteConfirmation() {
    const deleteButtons = document.querySelectorAll('.btn-delete');
    
    deleteButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            // Hentikan aksi klik pautan lalai (href)
            e.preventDefault(); 
            
            // Ambil ID acara daripada atribut data atau parameter khas
            const eventId = this.getAttribute('data-event-id');
            
            if (!eventId) {
                console.error("--> Ralat: Atribut data-event-id tidak ditemui pada butang!");
                return;
            }
            
            if (confirm('Are you sure you want to delete this event? This action cannot be undone.')) {
                // Bina borang POST secara dinamik untuk dihantar ke EventListServlet
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'EventListServlet';
                
                const hiddenField = document.createElement('input');
                hiddenField.type = 'hidden';
                hiddenField.name = 'deleteId';
                hiddenField.value = eventId;
                
                form.appendChild(hiddenField);
                document.body.appendChild(form);
                
                // Hantar borang
                form.submit();
            }
        });
    });
}
document.addEventListener('DOMContentLoaded', function() {
    initNavigation();
    initDetailsNavigation(); // <-- 1. Tambah panggilan fungsi baharu ini di sini
    initDeleteConfirmation();
});

// 2. BINA FUNGSI BAHARU INI DI BAWAH initNavigation()
function initDetailsNavigation() {
    const detailButtons = document.querySelectorAll('.btn-details');
    
    detailButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            // Kita biarkan JS handle sepenuhnya alamat URL untuk elakkan isu tersasar path
            // Alamat akan ditarik terus dari atribut href HTML yang kita set di Langkah 1
            const targetUrl = this.getAttribute('href');
            if (targetUrl) {
                window.location.href = "event_detail.jsp";
            }
        });
    });
}