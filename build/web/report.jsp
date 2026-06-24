<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.model.ReportData" %>
<%
    String loggedInUser = (String) session.getAttribute("loggedInUser");
    String userRole = (String) session.getAttribute("userRole");
    
    // Sekatan Keselamatan
    if (loggedInUser == null || !"staff".equalsIgnoreCase(userRole)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Dapatkan data metrik dari Request Attribute yang dihantar oleh ReportServlet
    ReportData reportData = (ReportData) request.getAttribute("reportData");
    
    // Pencegahan jika pengguna cuba akses report.jsp secara terus tanpa melalui Servlet
    if (reportData == null) {
        response.sendRedirect(request.getContextPath() + "/ReportServlet");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports - SRMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/report.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>

<div class="dashboard">
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

    <div class="main-layout">
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

            <div class="stats-container">
                <div class="stat-card">
                    <i class="fas fa-calendar-alt"></i>
                    <div class="stat-info">
                        <h3>Total Events</h3>
                        <p class="stat-number"><%= reportData.getTotalEvents() %></p>
                        <span class="trend up"><i class="fas fa-arrow-up"></i> Live</span>
                    </div>
                </div>
                <div class="stat-card">
                    <i class="fas fa-users"></i>
                    <div class="stat-info">
                        <h3>Total Attendees</h3>
                        <p class="stat-number"><%= reportData.getTotalAttendees() %></p>
                        <span class="trend up"><i class="fas fa-arrow-up"></i> Live</span>
                    </div>
                </div>
                <div class="stat-card">
                    <i class="fas fa-building"></i>
                    <div class="stat-info">
                        <h3>Total Halls</h3>
                        <p class="stat-number"><%= reportData.getTotalHalls() %></p>
                        <span class="trend"><i class="fas fa-minus"></i> Live</span>
                    </div>
                </div>
                <div class="stat-card">
                    <i class="fas fa-bookmark"></i>
                    <div class="stat-info">
                        <h3>Reservations</h3>
                        <p class="stat-number"><%= reportData.getTotalReservations() %></p>
                        <span class="trend up"><i class="fas fa-arrow-up"></i> Live</span>
                    </div>
                </div>
            </div>

            <div class="charts-grid">
                <div class="chart-card">
                    <div class="chart-header">
                        <h3><i class="fas fa-chart-bar"></i> Event Attendance Report</h3>
                    </div>
                    <div class="chart-container">
                        <canvas id="attendanceChart"></canvas>
                    </div>
                </div>

                <div class="chart-card">
                    <div class="chart-header">
                        <h3><i class="fas fa-chart-line"></i> Reservation & Hall Usage</h3>
                    </div>
                    <div class="chart-container">
                        <canvas id="reservationChart"></canvas>
                    </div>
                </div>

                <div class="chart-card">
                    <div class="chart-header">
                        <h3><i class="fas fa-chart-area"></i> Event Trends</h3>
                    </div>
                    <div class="chart-container">
                        <canvas id="trendChart"></canvas>
                    </div>
                </div>

                <div class="chart-card">
                    <div class="chart-header">
                        <h3><i class="fas fa-chart-pie"></i> Event Distribution</h3>
                    </div>
                    <div class="chart-container pie-container">
                        <canvas id="pieChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="js/report.js"></script>
<script>
    window.months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    window.monthlyAttendance = <%= Arrays.toString(reportData.getMonthlyAttendance()) %>;
    
    window.hallNames = [<% 
        String[] hNames = reportData.getHallNames();
        if(hNames != null) {
            for(int i=0; i<hNames.length; i++) { out.print("'" + hNames[i] + "'" + (i < hNames.length-1 ? "," : "")); }
        }
    %>];
    window.hallReservations = <%= Arrays.toString(reportData.getHallReservations()) %>;
    window.hallUsagePercent = <%= Arrays.toString(reportData.getHallUsagePercent()) %>;
    
    window.trendMonths = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"];
    window.eventTrends = <%= Arrays.toString(reportData.getEventTrends()) %>;
    window.pieData = <%= Arrays.toString(reportData.getPieData()) %>;
</script>
</body>
</html>