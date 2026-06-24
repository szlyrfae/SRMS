<%-- Bahagian Atas Sekali Fail cust_dashboard.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String loggedInUser = (String) session.getAttribute("loggedInUser");
    String userRole = (String) session.getAttribute("userRole");

    // Semak jika user belum login ATAU peranan bukan customer
    if (loggedInUser == null || !"customer".equalsIgnoreCase(userRole)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Dashboard - SRMS</title>
    <link rel="stylesheet" href="css/cust_dashboard.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
</head>
<body>

<div class="dashboard">
    <!-- Top Header -->
    <div class="top-header">
        <div class="header-left">
            <!--<img src="assets/logo_big.png" alt="Logo" class="logo" id="logoImage">-->
        </div>
        <div class="header-right">
            <div class="vertical-divider"></div>
            <div class="customer-info">
                <span class="customer-name"><i class="fas fa-user"></i> <%= loggedInUser %></span>
                <a href="logout.jsp" class="logout-link"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </div>
    </div>

    <!-- Main Content with Sidebar -->
    <div class="main-layout">
        <!-- Sidebar Kiri -->
        <div class="sidebar">
            <div class="logo-section">
                <h2>SRMS</h2>
                <div class="logo-sub">CUSTOMER  PORTAL</div>
            </div>
            
            <nav class="sidebar-nav">
                <ul>
                    <li class="nav-item active" id="navDashboard">
                        <i class="fas fa-tachometer-alt nav-icon"></i>
                        <span class="nav-text">Dashboard</span>
                    </li>
                    <li class="nav-item" id="navAddEvent">
                        <i class="fas fa-plus-circle nav-icon"></i>
                        <span class="nav-text">Add Event</span>
                    </li>
                    <li class="nav-item" id="navEventList">
                        <i class="fas fa-calendar-alt nav-icon"></i>
                        <span class="nav-text">Event List</span>
                    </li>
                </ul>
            </nav>
        </div>

        <!-- Vertical Divider Line -->
        <div class="vertical-divider-line"></div>

        <!-- Content Area Kanan -->
        <div class="content-area">
            <!-- Welcome Section -->
            <div class="welcome-section">
                <h1>WELCOME,<%= loggedInUser.toUpperCase() %></h1>
            </div>

            <!-- Stats Cards -->
            <div class="stats-container">
                <div class="stat-card">
                    <i class="fas fa-calendar-alt"></i>
                    <h3>Total Events</h3>
                    <p class="stat-number" id="totalEvents">0</p>
                </div>
                <div class="stat-card">
                    <i class="fas fa-clock"></i>
                    <h3>Upcoming</h3>
                    <p class="stat-number" id="Upcoming">0</p>
                </div>
                <div class="stat-card">
                    <i class="fas fa-check-circle"></i>
                    <h3>Completed</h3>
                    <p class="stat-number" id="completedEvents">0</p>
                </div>
            </div>

            <!-- Recent Events Section -->
            <div class="recent-events">
                <h2>Recent Events</h2>
                <div class="events-grid" id="recentEventsGrid">
                    <!-- Events will be loaded here -->
                </div>
            </div>
        </div>
    </div>
</div>

<script src="js/cust_dashboard.js?v=2.0"></script>
</body>
</body>
</html>