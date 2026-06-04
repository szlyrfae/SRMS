<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    String loggedInUser = (String) session.getAttribute("loggedInUser");
    String userRole = (String) session.getAttribute("userRole");
    
    if (loggedInUser == null || !"staff".equals(loggedInUser)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Sample data for reports
    int totalEvents = 12;
    int totalAttendees = 578;
    int totalHalls = 5;
    int totalReservations = 73;
    
    // Monthly attendance data
    int[] monthlyAttendance = {45, 52, 38, 65, 78, 82, 95, 88, 76, 68, 55, 48};
    String[] months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
    
    // Hall usage data
    int[] hallUsage = {85, 60, 45, 30, 20};
    String[] hallNames = {"Grand Hall", "Ballroom", "Meeting A", "Meeting B", "Conference"};
    
    // Event trends (last 6 months)
    int[] eventTrends = {3, 4, 5, 7, 9, 12};
    String[] trendMonths = {"Jan", "Feb", "Mar", "Apr", "May", "Jun"};
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports - SRMS</title>
    <link rel="stylesheet" href="css/report.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>

<div class="dashboard">
    <!-- Top Header -->
    <div class="top-header">
        <div class="header-left"></div>
        <div class="header-right">
            <div class="vertical-divider"></div>
            <div class="staff-info">
                <span class="staff-name"><i class="fas fa-user-tie"></i> [<%= loggedInUser %>]</span>
                <a href="logout.jsp" class="logout-link"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </div>
    </div>

    <!-- Main Layout -->
    <div class="main-layout">
        <!-- Sidebar -->
        <div class="sidebar">
            <div class="logo-section">
                <h2>SRMS</h2>
                <div class="logo-sub">STAFF PORTAL</div>
            </div>
            <nav class="sidebar-nav">
                <ul>
                    <li class="nav-item" id="navDashboard">
                        <i class="fas fa-tachometer-alt nav-icon"></i>
                        <span class="nav-text">Dashboard</span>
                    </li>
                    <li class="nav-item" id="navHall">
                        <i class="fas fa-building nav-icon"></i>
                        <span class="nav-text">Hall</span>
                    </li>
                    <li class="nav-item" id="navStaff">
                        <i class="fas fa-users-gear nav-icon"></i>
                        <span class="nav-text">Staff</span>
                    </li>
                    <li class="nav-item active" id="navReport">
                        <i class="fas fa-chart-bar nav-icon"></i>
                        <span class="nav-text">Report</span>
                    </li>
                    <li class="nav-item" id="navReservation">
                        <i class="fas fa-calendar-check nav-icon"></i>
                        <span class="nav-text">Reservation</span>
                    </li>
                </ul>
            </nav>
        </div>

        <div class="vertical-divider-line"></div>

        <!-- Content Area -->
        <div class="content-area">
            <div class="page-header">
                <h1><i class="fas fa-chart-line"></i> REPORTS & ANALYTICS</h1>
                <div class="date-range">
                    <input type="month" id="startMonth" class="date-input">
                    <span>to</span>
                    <input type="month" id="endMonth" class="date-input">
                    <button class="filter-btn" onclick="updateReports()"><i class="fas fa-filter"></i> Apply Filter</button>
                    <button class="export-btn" onclick="exportReport()"><i class="fas fa-download"></i> Export</button>
                </div>
            </div>

            <!-- Stats Cards -->
            <div class="stats-container">
                <div class="stat-card">
                    <i class="fas fa-calendar-alt"></i>
                    <div class="stat-info">
                        <h3>Total Events</h3>
                        <p class="stat-number"><%= totalEvents %></p>
                        <span class="trend up"><i class="fas fa-arrow-up"></i> +25%</span>
                    </div>
                </div>
                <div class="stat-card">
                    <i class="fas fa-users"></i>
                    <div class="stat-info">
                        <h3>Total Attendees</h3>
                        <p class="stat-number"><%= totalAttendees %></p>
                        <span class="trend up"><i class="fas fa-arrow-up"></i> +18%</span>
                    </div>
                </div>
                <div class="stat-card">
                    <i class="fas fa-building"></i>
                    <div class="stat-info">
                        <h3>Total Halls</h3>
                        <p class="stat-number"><%= totalHalls %></p>
                        <span class="trend"><i class="fas fa-minus"></i> No change</span>
                    </div>
                </div>
                <div class="stat-card">
                    <i class="fas fa-bookmark"></i>
                    <div class="stat-info">
                        <h3>Reservations</h3>
                        <p class="stat-number"><%= totalReservations %></p>
                        <span class="trend up"><i class="fas fa-arrow-up"></i> +32%</span>
                    </div>
                </div>
            </div>

            <!-- Charts Grid -->
            <div class="charts-grid">
                <!-- Chart 1: Event Attendance (Bar Chart) -->
                <div class="chart-card">
                    <div class="chart-header">
                        <h3><i class="fas fa-chart-bar"></i> Event Attendance Report</h3>
                        <div class="chart-legend">
                            <span><i class="fas fa-circle" style="color: #d4c0a8;"></i> Attendees</span>
                        </div>
                    </div>
                    <div class="chart-container">
                        <canvas id="attendanceChart"></canvas>
                    </div>
                </div>

                <!-- Chart 2: Reservation & Hall Usage (Line Chart) -->
                <div class="chart-card">
                    <div class="chart-header">
                        <h3><i class="fas fa-chart-line"></i> Reservation & Hall Usage</h3>
                        <div class="chart-legend">
                            <span><i class="fas fa-circle" style="color: #d4c0a8;"></i> Reservations</span>
                            <span><i class="fas fa-circle" style="color: #b87c5a;"></i> Hall Usage %</span>
                        </div>
                    </div>
                    <div class="chart-container">
                        <canvas id="reservationChart"></canvas>
                    </div>
                </div>

                <!-- Chart 3: Event Trends (Area Chart) -->
                <div class="chart-card">
                    <div class="chart-header">
                        <h3><i class="fas fa-chart-area"></i> Event Trends</h3>
                        <div class="chart-legend">
                            <span><i class="fas fa-circle" style="color: #d4c0a8;"></i> Events Created</span>
                        </div>
                    </div>
                    <div class="chart-container">
                        <canvas id="trendChart"></canvas>
                    </div>
                </div>

                <!-- Chart 4: Distribution (Pie Chart) -->
                <div class="chart-card">
                    <div class="chart-header">
                        <h3><i class="fas fa-chart-pie"></i> Event Distribution</h3>
                        <div class="chart-legend">
                            <span><i class="fas fa-circle" style="color: #d4c0a8;"></i> Completed</span>
                            <span><i class="fas fa-circle" style="color: #b87c5a;"></i> Upcoming</span>
                            <span><i class="fas fa-circle" style="color: #bcab99;"></i> Ongoing</span>
                        </div>
                    </div>
                    <div class="chart-container pie-container">
                        <canvas id="pieChart"></canvas>
                    </div>
                </div>
            </div>

            <!-- Detailed Reports Table -->
            <div class="details-section">
                <div class="section-header">
                    <h3><i class="fas fa-table"></i> Monthly Breakdown</h3>
                    <button class="view-all" onclick="toggleDetails()">View Details <i class="fas fa-chevron-down"></i></button>
                </div>
                <div class="table-container" id="detailsTable" style="display: none;">
                    <table class="report-table">
                        <thead>
                            <tr>
                                <th>Month</th>
                                <th>Events</th>
                                <th>Attendees</th>
                                <th>Hall Usage</th>
                                <th>Revenue (RM)</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (int i = 0; i < months.length; i++) { %>
                            <tr>
                                <td><%= months[i] %></td>
                                <td><%= (int)(Math.random() * 10) + 1 %></td>
                                <td><%= monthlyAttendance[i] %></td>
                                <td><%= (int)(Math.random() * 100) %>%</td>
                                <td>RM <%= (int)(monthlyAttendance[i] * 150) %></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="js/report.js"></script>
<script>
    window.monthlyAttendance = [45, 52, 38, 65, 78, 82, 95, 88, 76, 68, 55, 48];
    window.months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    window.hallUsage = [85, 60, 45, 30, 20];
    window.hallNames = ["Grand Hall", "Ballroom", "Meeting A", "Meeting B", "Conference"];
    window.eventTrends = [3, 4, 5, 7, 9, 12];
    window.trendMonths = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"];
</script>
</body>
</html>