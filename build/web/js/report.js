/**
 * Report Page JavaScript
 * Handle charts, filters, and exports
 */

let attendanceChart, reservationChart, trendChart, pieChart;

document.addEventListener('DOMContentLoaded', function() {
    initNavigation();
    initCharts();
    setDefaultDates();
});

// Navigation
function initNavigation() {
    const navDashboard = document.getElementById('navDashboard');
    const navHall = document.getElementById('navHall');
    const navStaff = document.getElementById('navStaff');
    const navReport = document.getElementById('navReport');
    const navReservation = document.getElementById('navReservation');
    
    if (navDashboard) navDashboard.onclick = () => window.location.href = 'staff_dashboard.jsp';
    if (navHall) navHall.onclick = () => window.location.href = 'hall.jsp';
    if (navStaff) navStaff.onclick = () => window.location.href = 'staff.jsp';
    if (navReport) navReport.onclick = () => window.location.href = 'report.jsp';
    if (navReservation) navReservation.onclick = () => window.location.href = 'event_list.jsp';
}

// Set default date range (last 12 months)
function setDefaultDates() {
    const today = new Date();
    const lastYear = new Date(today.getFullYear() - 1, today.getMonth(), 1);
    
    const startInput = document.getElementById('startMonth');
    const endInput = document.getElementById('endMonth');
    
    if (startInput) {
        startInput.value = lastYear.toISOString().slice(0, 7);
    }
    if (endInput) {
        endInput.value = today.toISOString().slice(0, 7);
    }
}

// Initialize all charts
function initCharts() {
    // Chart 1: Event Attendance (Bar Chart)
    const attendanceCtx = document.getElementById('attendanceChart').getContext('2d');
    attendanceChart = new Chart(attendanceCtx, {
        type: 'bar',
        data: {
            labels: window.months,
            datasets: [{
                label: 'Attendees',
                data: window.monthlyAttendance,
                backgroundColor: 'rgba(212, 192, 168, 0.6)',
                borderColor: '#d4c0a8',
                borderWidth: 1,
                borderRadius: 8
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false },
                tooltip: { callbacks: { label: (ctx) => `${ctx.raw} attendees` } }
            },
            scales: {
                y: { beginAtZero: true, title: { display: true, text: 'Number of Attendees' } },
                x: { title: { display: true, text: 'Month' } }
            }
        }
    });

    // Chart 2: Reservation & Hall Usage (Line Chart)
    const reservationCtx = document.getElementById('reservationChart').getContext('2d');
    const hallUsagePercent = [45, 60, 35, 25, 20];
    reservationChart = new Chart(reservationCtx, {
        type: 'line',
        data: {
            labels: window.hallNames,
            datasets: [
                {
                    label: 'Reservations',
                    data: [28, 15, 12, 8, 10],
                    borderColor: '#d4c0a8',
                    backgroundColor: 'rgba(212, 192, 168, 0.1)',
                    tension: 0.4,
                    fill: true
                },
                {
                    label: 'Hall Usage %',
                    data: hallUsagePercent,
                    borderColor: '#b87c5a',
                    backgroundColor: 'rgba(184, 124, 90, 0.1)',
                    tension: 0.4,
                    fill: true
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { tooltip: { callbacks: { label: (ctx) => `${ctx.dataset.label}: ${ctx.raw}` } } }
        }
    });

    // Chart 3: Event Trends (Area Chart)
    const trendCtx = document.getElementById('trendChart').getContext('2d');
    trendChart = new Chart(trendCtx, {
        type: 'line',
        data: {
            labels: window.trendMonths,
            datasets: [{
                label: 'Events Created',
                data: window.eventTrends,
                borderColor: '#d4c0a8',
                backgroundColor: 'rgba(212, 192, 168, 0.3)',
                tension: 0.3,
                fill: true,
                pointBackgroundColor: '#d4c0a8',
                pointRadius: 4,
                pointHoverRadius: 6
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { tooltip: { callbacks: { label: (ctx) => `${ctx.raw} events` } } },
            scales: { y: { beginAtZero: true, title: { display: true, text: 'Number of Events' } } }
        }
    });

    // Chart 4: Pie Chart - Event Distribution
    const pieCtx = document.getElementById('pieChart').getContext('2d');
    pieChart = new Chart(pieCtx, {
        type: 'pie',
        data: {
            labels: ['Completed (73)', 'Upcoming (578)', 'Ongoing (45)'],
            datasets: [{
                data: [73, 578, 45],
                backgroundColor: ['#d4c0a8', '#b87c5a', '#bcab99'],
                borderWidth: 0
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { position: 'bottom' },
                tooltip: { callbacks: { label: (ctx) => `${ctx.label}: ${ctx.raw} events (${Math.round(ctx.raw / 696 * 100)}%)` } }
            }
        }
    });
}

// Update reports with new date range
function updateReports() {
    const startMonth = document.getElementById('startMonth').value;
    const endMonth = document.getElementById('endMonth').value;
    
    if (!startMonth || !endMonth) {
        alert('Please select both start and end dates');
        return;
    }
    
    // Simulate loading new data
    showToast('Updating reports...', 'info');
    
    // In real application, fetch new data from server
    setTimeout(() => {
        showToast('Reports updated successfully!', 'success');
    }, 1000);
}

// Export report as PDF/CSV
function exportReport() {
    const format = confirm('Export as CSV? Click OK for CSV, Cancel for Print');
    
    if (format) {
        exportToCSV();
    } else {
        window.print();
    }
}

// Export table data to CSV
function exportToCSV() {
    const rows = document.querySelectorAll('.report-table tr');
    let csv = [];
    
    rows.forEach(row => {
        const cells = row.querySelectorAll('th, td');
        const rowData = Array.from(cells).map(cell => cell.textContent.trim());
        csv.push(rowData.join(','));
    });
    
    const blob = new Blob([csv.join('\n')], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `report_${new Date().toISOString().slice(0, 10)}.csv`;
    a.click();
    URL.revokeObjectURL(url);
    showToast('Report exported successfully!', 'success');
}

// Toggle details table visibility
function toggleDetails() {
    const table = document.getElementById('detailsTable');
    const btn = document.querySelector('.view-all i');
    
    if (table.style.display === 'none') {
        table.style.display = 'block';
        btn.className = 'fas fa-chevron-up';
    } else {
        table.style.display = 'none';
        btn.className = 'fas fa-chevron-down';
    }
}

// Show toast notification
function showToast(message, type) {
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
            z-index: 2000;
            opacity: 0;
            transition: opacity 0.3s ease;
        `;
        document.body.appendChild(toast);
    }
    
    if (type === 'success') toast.style.background = '#2e7d32';
    else if (type === 'error') toast.style.background = '#c62828';
    else toast.style.background = '#4a3b2f';
    
    toast.textContent = message;
    toast.style.opacity = '1';
    
    setTimeout(() => {
        toast.style.opacity = '0';
    }, 3000);
}