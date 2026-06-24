<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%
    String loggedInUser = (String) session.getAttribute("loggedInUser");
    String userRole = (String) session.getAttribute("userRole");

    // Sekatan Keselamatan: Semak userRole
    if (loggedInUser == null || !"staff".equalsIgnoreCase(userRole)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Pembolehubah untuk menyimpan statistik kaunter dari DB
    int totalEvents = 0;
    int totalHalls = 0;
    int totalReservations = 0;

    // Senarai untuk menyimpan 3 acara terbaharu secara dinamik
    List<Map<String, String>> events = new ArrayList<>();

    // Tetapan Pangkalan Data
    String dbUrl = "jdbc:mysql://localhost:3306/s74699_srms_db";
    String dbUser = "s74699";
    String dbPass = "SLz4qTEpB8Re";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass)) {
            
            // 1. KIRA JUMLAH ACARA / TEMPAHAN dari table reservations
            String sqlEvents = "SELECT COUNT(*) FROM reservations"; 
            try (PreparedStatement ps = conn.prepareStatement(sqlEvents);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalEvents = rs.getInt(1);
                }
            }

            // 2. KIRA JUMLAH DEWAN dari table halls
            String sqlHalls = "SELECT COUNT(*) FROM halls"; 
            try (PreparedStatement ps = conn.prepareStatement(sqlHalls);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalHalls = rs.getInt(1);
                }
            }

            // 3. Set total reservations sama dengan jumlah rekod tempahan
            totalReservations = totalEvents; 

            // 4. AMBIL 3 ACARA TERBAHARU DENGAN JOIN TABLE DEWAN (VENUE)
            // PEMBETULAN: h.name digunakan untuk mengambil nama dewan dari table halls
            String sqlRecent = "SELECT r.id, r.event_name, h.name AS hall_name, r.reservation_date, r.start_time, r.end_time " +
                               "FROM reservations r " +
                               "LEFT JOIN halls h ON r.hall_id = h.id " +
                               "ORDER BY r.id DESC LIMIT 3";
                               
            try (PreparedStatement ps = conn.prepareStatement(sqlRecent);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> event = new HashMap<>();
                    event.put("id", String.valueOf(rs.getInt("id")));
                    event.put("name", rs.getString("event_name") != null ? rs.getString("event_name") : "No Name");
                    
                    // Membaca 'hall_name' yang telah di-alias daripada h.name dalam SQL
                    event.put("venue", rs.getString("hall_name") != null ? rs.getString("hall_name") : "Unknown Hall");
                    event.put("date", rs.getString("reservation_date") != null ? rs.getString("reservation_date") : "-");
                    
                    // Gabungkan waktu mula & tamat
                    String timeStr = "-";
                    if (rs.getString("start_time") != null) {
                        timeStr = rs.getString("start_time") + " - " + rs.getString("end_time");
                    }
                    event.put("time", timeStr);
                    
                    events.add(event);
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
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
            <div class="top-header">
                <div class="header-left"></div>
                <div class="header-right">
                    <div class="vertical-divider"></div>
                    <div class="staff-info">
                        <span class="staff-name"><i class="fas fa-user-tie"></i> <%= loggedInUser%></span>
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

                <div class="vertical-divider-line"></div>

                <div class="content-area">
                    <div class="welcome-section">
                        <h1>BARU WELCOME, <%= loggedInUser.toUpperCase()%>!</h1>
                        <p>Manage halls, reservations, and generate reports here.</p>
                    </div>

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

                    <div class="action-buttons">
                        <a href="hall.jsp" class="action-btn">
                            <i class="fas fa-plus-circle"></i> Hall
                        </a>
                        <a href="staff.jsp" class="action-btn">
                            <i class="fas fa-user-plus"></i> Staff
                        </a>
                        <a href="ReportServlet" class="action-btn">
                            <i class="fas fa-file-alt"></i> Report
                        </a>
                        <a href="EventListServlet" class="action-btn">
                            <i class="fas fa-calendar-plus"></i> Reservation
                        </a>
                    </div>

                    <div class="recent-events">
                        <div class="section-header">
                            <h2><i class="fas fa-clock"></i> Recent Events</h2>
                            <a href="EventListServlet" class="view-all" id="viewAllEvents">View All <i class="fas fa-arrow-right"></i></a>
                        </div>

                        <div class="events-grid">
                            <% 
                                if (events.isEmpty()) {
                            %>
                                <p style="color: #888; padding: 20px;">No events found in database.</p>
                            <%
                                } else {
                                    for (Map<String, String> event : events) {
                            %>
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
                            <% 
                                    }
                                }
                            %>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script src="js/staff_dashboard.js"></script>
    </body>
</html>