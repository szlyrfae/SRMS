<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    String loggedInUser = (String) session.getAttribute("loggedInUser");
    if (loggedInUser == null || !"staff".equals(loggedInUser)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Sample events data for staff
    List<Map<String, String>> events = new ArrayList<>();

    Map<String, String> event1 = new HashMap<>();
    event1.put("id", "1");
    event1.put("name", "Annual Tech Conference 2025");
    event1.put("venue", "KL Convention Center");
    event1.put("date", "2025-06-15");
    event1.put("time", "09:00 AM");
    events.add(event1);

    Map<String, String> event2 = new HashMap<>();
    event2.put("id", "2");
    event2.put("name", "Wedding Reception - Adam & Hawa");
    event2.put("venue", "Grand Ballroom, Hotel Istana");
    event2.put("date", "2025-07-20");
    event2.put("time", "07:30 PM");
    events.add(event2);

    Map<String, String> event3 = new HashMap<>();
    event3.put("id", "3");
    event3.put("name", "Corporate Networking Night");
    event3.put("venue", "The Vertical, Bangsar South");
    event3.put("date", "2025-05-10");
    event3.put("time", "08:00 PM");
    events.add(event3);

    // Calculate stats
    int totalEvents = events.size();
    int totalHalls = 5;
    int totalReservations = 23;
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Staff Dashboard - SRMS</title>
        <link rel="stylesheet" href="css/staff_dashboard.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
    </head>
    <body>

        <div class="dashboard">
            <!-- Top Header -->
            <div class="top-header">
                <div class="header-left"></div>
                <div class="header-right">
                    <div class="vertical-divider"></div>
                    <div class="staff-info">
                        <span class="staff-name"><i class="fas fa-user-tie"></i> [<%= loggedInUser%>]</span>
                        <a href="logout.jsp" class="logout-link"><i class="fas fa-sign-out-alt"></i> Logout</a>
                    </div>
                </div>
            </div>

            <!-- Main Layout with Sidebar -->
            <div class="main-layout">
                <!-- Sidebar -->
                <div class="sidebar">
                    <div class="logo-section">
                        <h2>SRMS</h2>
                        <div class="logo-sub">STAFF PORTAL</div>
                    </div>

                    <nav class="sidebar-nav">
                        <ul>
                            <li class="nav-item active" id="navDashboard">
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
                            <li class="nav-item" id="navReport">
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

                <!-- Vertical Divider Line -->
                <div class="vertical-divider-line"></div>

                <!-- Content Area -->
                <div class="content-area">
                    <div class="welcome-section">
                        <h1>WELCOME, <%= loggedInUser.toUpperCase()%>!</h1>
                        <p>Manage halls, reservations, and generate reports here.</p>
                    </div>

                    <!-- Stats Cards -->
                    <div class="stats-container">
                        <div class="stat-card">
                            <i class="fas fa-calendar-alt"></i>
                            <h3>Total Events</h3>
                            <p class="stat-number"><%= totalEvents%></p>
                        </div>
                        <div class="stat-card">
                            <i class="fas fa-building"></i>
                            <h3>Total Halls</h3>
                            <p class="stat-number"><%= totalHalls%></p>
                        </div>
                        <div class="stat-card">
                            <i class="fas fa-bookmark"></i>
                            <h3>Reservations</h3>
                            <p class="stat-number"><%= totalReservations%></p>
                        </div>
                    </div>

                    <!-- Action Buttons -->
                    <div class="action-buttons">
                        <a href="hall.jsp" class="action-btn">
                            <i class="fas fa-plus-circle"></i> Hall
                        </a>
                        <a href="staff.jsp" class="action-btn">
                            <i class="fas fa-user-plus"></i> Staff
                        </a>
                        <a href="report.jsp" class="action-btn">
                            <i class="fas fa-file-alt"></i> Report
                        </a>
                        <a href="event_list.jsp" class="action-btn">
                            <i class="fas fa-calendar-plus"></i> Reservation
                        </a>
                    </div>

                    <!-- Recent Events Section -->
                    <div class="recent-events">
                        <div class="section-header">
                            <h2><i class="fas fa-clock"></i> Recent Events</h2>
                            <a href="event_list.jsp" class="view-all" id="viewAllEvents">View All <i class="fas fa-arrow-right"></i></a>
                        </div>

                        <div class="events-grid">
                            <% for (Map<String, String> event : events) {%>
                            <div class="event-card">
                                <h3 class="event-name"><%= event.get("name")%></h3>
                                <div class="event-details">
                                    <p><i class="fas fa-map-marker-alt"></i> Venue: <%= event.get("venue")%></p>
                                    <p><i class="fas fa-calendar-day"></i> Date: <%= event.get("date")%></p>
                                    <p><i class="fas fa-clock"></i> Time: <%= event.get("time")%></p>
                                </div>
                                <button class="details-btn" data-id="<%= event.get("id")%>">
                                    Details <i class="fas fa-arrow-right"></i>
                                </button>
                            </div>
                            <% }%>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script src="js/staff_dashboard.js"></script>
    </body>
</html>