/**
 * Event List Page JavaScript
 * Handle navigation for both Staff and Customer
 */

document.addEventListener('DOMContentLoaded', function() {
    initNavigation();
    initDeleteConfirmation();
});

// Navigation based on role
function initNavigation() {
    // Staff Navigation
    const navStaffDashboard = document.getElementById('navStaffDashboard');
    const navHall = document.getElementById('navHall');
    const navStaff = document.getElementById('navStaff');
    const navReport = document.getElementById('navReport');
    const navEventList = document.getElementById('navEventList');
    
    // Customer Navigation
    const navCustDashboard = document.getElementById('navCustDashboard');
    const navAddEvent = document.getElementById('navAddEvent');
    const navCustomerEventList = document.getElementById('navEventList');
    
    // Staff menu clicks
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
            window.location.href = 'report.jsp';
        });
    }
    
    if (navEventList) {
        navEventList.addEventListener('click', function() {
            window.location.href = 'event_list.jsp';
        });
    }
    
    // Customer menu clicks
    if (navCustDashboard) {
        navCustDashboard.addEventListener('click', function() {
            window.location.href = 'cust_dashboard.jsp';
        });
    }
    
    if (navAddEvent) {
        navAddEvent.addEventListener('click', function() {
            window.location.href = 'add_event.jsp';
        });
    }
    
    if (navCustomerEventList) {
        navCustomerEventList.addEventListener('click', function() {
            window.location.href = 'event_list.jsp';
        });
    }
}

// Delete confirmation function
function confirmDelete(event) {
    event.preventDefault();
    const deleteUrl = event.currentTarget.getAttribute('href');
    
    if (confirm('Are you sure you want to delete this event? This action cannot be undone.')) {
        window.location.href = deleteUrl;
    }
    return false;
}

// Initialize delete confirmation on all delete buttons
function initDeleteConfirmation() {
    const deleteButtons = document.querySelectorAll('.btn-delete');
    
    deleteButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            const deleteUrl = this.getAttribute('href');
            
            if (confirm('Are you sure you want to delete this event? This action cannot be undone.')) {
                window.location.href = deleteUrl;
            }
        });
    });
}