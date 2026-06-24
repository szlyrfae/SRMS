/**
 * Report Page JavaScript
 * Handle charts, filters, and exports with Live MySQL Database Data
 */

let attendanceChart, reservationChart, trendChart, pieChart;

document.addEventListener('DOMContentLoaded', function() {
    initNavigation();
    initCharts();
    setDefaultDates();
});

// Menguruskan navigasi menu tepi (Sidebar)
function initNavigation() {
    const navDashboard = document.getElementById('navDashboard');
    const navHall = document.getElementById('navHall');
    const navStaff = document.getElementById('navStaff');
    const navReport = document.getElementById('navReport');
    const navReservation = document.getElementById('navReservation');
    
    if (navDashboard) navDashboard.onclick = () => window.location.href = 'staff_dashboard.jsp';
    if (navHall) navHall.onclick = () => window.location.href = 'hall.jsp';
    if (navStaff) navStaff.onclick = () => window.location.href = 'staff.jsp';
    
    // Menu Report wajib melalui Servlet Controller untuk memuatkan data dari DB
    if (navReport) navReport.onclick = () => window.location.href = 'ReportServlet';
    if (navReservation) navReservation.onclick = () => window.location.href = 'EventListServlet';
}

// Menetapkan julat tarikh lalai secara automatik (12 bulan lepas)
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

// Fungsi utama membina kesemua 4 carta grafik Chart.js
function initCharts() {
    // ----------------------------------------------------
    // CARTA 1: Event Attendance Report (Bar Chart)
    // ----------------------------------------------------
    const attendanceCtx = document.getElementById('attendanceChart').getContext('2d');
    attendanceChart = new Chart(attendanceCtx, {
        type: 'bar',
        data: {
            labels: window.months,
            datasets: [{
                label: 'Attendees',
                data: window.monthlyAttendance, // 🎯 Live data jumlah peserta dari DB
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

    // ----------------------------------------------------
    // CARTA 2: Reservation & Hall Usage (Line Chart)
    // ----------------------------------------------------
    const reservationCtx = document.getElementById('reservationChart').getContext('2d');
    reservationChart = new Chart(reservationCtx, {
        type: 'line',
        data: {
            labels: window.hallNames, // 🎯 Live nama-nama dewan dari jadual halls
            datasets: [
                {
                    label: 'Reservations',
                    data: window.hallReservations, // 🎯 Live bilangan tempahan dari DB
                    borderColor: '#d4c0a8',
                    backgroundColor: 'rgba(212, 192, 168, 0.1)',
                    tension: 0.4,
                    fill: true
                },
                {
                    label: 'Hall Usage %',
                    data: window.hallUsagePercent, // 🎯 Live anggaran peratus penggunaan dewan
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
            plugins: { 
                tooltip: { callbacks: { label: (ctx) => `${ctx.dataset.label}: ${ctx.raw}` } } 
            }
        }
    });

    // ----------------------------------------------------
    // CARTA 3: Event Trends (Area Chart)
    // ----------------------------------------------------
    const trendCtx = document.getElementById('trendChart').getContext('2d');
    trendChart = new Chart(trendCtx, {
        type: 'line',
        data: {
            labels: window.trendMonths,
            datasets: [{
                label: 'Events Created',
                data: window.eventTrends, // 🎯 Live trend penaikan tempahan acara
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

    // ----------------------------------------------------
    // CARTA 4: Pie Chart - Event Distribution
    // ----------------------------------------------------
    const pieCtx = document.getElementById('pieChart').getContext('2d');
    
    // Kira anggaran total untuk paparan peratusan pada label
    const totalPieEvents = window.pieData.reduce((a, b) => a + b, 0) || 1;

    pieChart = new Chart(pieCtx, {
        type: 'pie',
        data: {
            labels: [
                `Completed (${window.pieData[0]})`, 
                `Upcoming (${window.pieData[1]})`, 
                `Ongoing (${window.pieData[2]})`
            ],
            datasets: [{
                data: window.pieData, // 🎯 Live pembahagian status acara [Completed, Upcoming, Ongoing]
                backgroundColor: ['#d4c0a8', '#b87c5a', '#bcab99'],
                borderWidth: 0
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { position: 'bottom' },
                tooltip: { 
                    callbacks: { 
                        label: (ctx) => `${ctx.label}: ${ctx.raw} events (${Math.round(ctx.raw / totalPieEvents * 100)}%)` 
                    } 
                }
            }
        }
    });
}

// Fungsi tapis mengikut pilihan bulan (Sedia dipautkan dengan backend jika ada)
function updateReports() {
    const startMonth = document.getElementById('startMonth').value;
    const endMonth = document.getElementById('endMonth').value;
    
    if (!startMonth || !endMonth) {
        alert('Please select both start and end dates');
        return;
    }
    
    showToast('Updating reports from database...', 'info');
    
    // Muatkan semula halaman bersama parameter tarikh untuk ditangkap oleh ReportServlet
    setTimeout(() => {
        window.location.href = `ReportServlet?start=${startMonth}&end=${endMonth}`;
    }, 800);
}

// Fungsi mengeksport laporan dokumen
function exportReport() {
    const format = confirm('Export as CSV? Click OK for CSV, Cancel for Print');
    if (format) {
        exportToCSV();
    } else {
        window.print();
    }
}

// Logik menukar data metrik ke bentuk fail CSV untuk dimuat turun
function exportToCSV() {
    let csv = [];
    csv.push("Live SRMS Database Metrik Report");
    csv.push(`Generated Date,${new Date().toLocaleString()}`);
    csv.push("");
    
    // Ambil nilai dari kad statistik di halaman web secara dinamik
    const cards = document.querySelectorAll('.stat-card');
    csv.push("Metric Title,Current Live Total");
    cards.forEach(card => {
        const title = card.querySelector('h3').textContent.trim();
        const value = card.querySelector('.stat-number').textContent.trim();
        csv.push(`"${title}",${value}`);
    });
    
    const blob = new Blob([csv.join('\n')], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `srms_live_report_${new Date().toISOString().slice(0, 10)}.csv`;
    a.click();
    URL.revokeObjectURL(url);
    showToast('Report exported successfully!', 'success');
}

// Fungsi memaparkan kotak notifikasi kecil (Toast)
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