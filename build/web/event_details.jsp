<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %> 

<%
    String loggedInUser = (String) session.getAttribute("loggedInUser");
    String userRole = (String) session.getAttribute("userRole");
    
    // 1. Sekatan Keselamatan: Pastikan pengguna telah log masuk
    if (loggedInUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // 2. Tangkap ID dari Request Parameter
    String eventId = request.getParameter("id");
    
    // PENGESAHAN 1: Jika parameter id tiada dalam URL
    if (eventId == null || eventId.trim().isEmpty()) {
%>
        <div style="padding:20px; margin:50px; background-color:#f8d7da; color:#721c24; border:1px solid #f5c6cb; border-radius:5px; font-family:sans-serif;">
            <h2>🚨 Ralat: Parameter ID Tidak Ditemui!</h2>
            <p>Sistem tidak menerima sebarang ID acara. Pastikan pautan dari senarai acara menghantar parameter <code>?id=...</code> dengan betul.</p>
            <p>User: <b><%= loggedInUser %></b> | Role: <b><%= userRole %></b></p>
            <a href="${pageContext.request.contextPath}/EventListServlet" style="display:inline-block; padding:10px 15px; background-color:#721c24; color:white; text-decoration:none; border-radius:3px; margin-top:10px;">Kembali ke Event List</a>
        </div>
<%
        return;
    }
    
    // 3. Ambil data event dari Session berdasarkan peranan (Role)
    Map<String, String> event = null;
    
    if ("staff".equalsIgnoreCase(userRole)) {
        List<Map<String, String>> allEvents = (List<Map<String, String>>) session.getAttribute("allEvents");
        if (allEvents != null) {
            for (Map<String, String> e : allEvents) {
                if (e.get("id") != null && e.get("id").equals(eventId)) {
                    event = e;
                    break;
                }
            }
        }
    } else {
        List<Map<String, String>> customerEvents = (List<Map<String, String>>) session.getAttribute("customerEvents_" + loggedInUser);
        if (customerEvents != null) {
            for (Map<String, String> e : customerEvents) {
                if (e.get("id") != null && e.get("id").equals(eventId)) {
                    event = e;
                    break;
                }
            }
        }
    }
    
    // 🎯 PENYELESAIAN UTAMA: Jika diklik dari Dashboard (Data tiada dalam session), tarik terus dari DATABASE
    if (event == null) {
        String mainDbUrl = "jdbc:mysql://localhost:3306/s74699_srms_db";
        String mainDbUser = "s74699";
        String mainDbPass = "SLz4qTEpB8Re";
        
        // SINKRONISASI JADUAL: Menggunakan event_description, reservation_date, dan user_id dari table anda
        String sqlFallback = "SELECT r.id, r.event_name, r.event_description, h.name AS hall_name, r.reservation_date, r.start_time, r.end_time, r.user_id " +
                             "FROM reservations r " +
                             "LEFT JOIN halls h ON r.hall_id = h.id " +
                             "WHERE r.id = ?";
                             
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(mainDbUrl, mainDbUser, mainDbPass);
                 PreparedStatement ps = conn.prepareStatement(sqlFallback)) {
                
                ps.setInt(1, Integer.parseInt(eventId.trim()));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        event = new HashMap<>();
                        event.put("id", String.valueOf(rs.getInt("id")));
                        event.put("name", rs.getString("event_name"));
                        event.put("description", rs.getString("event_description")); // Sesuai lajur event_description
                        event.put("venue", rs.getString("hall_name") != null ? rs.getString("hall_name") : "Unknown Hall");
                        event.put("date", rs.getString("reservation_date")); // Sesuai lajur reservation_date
                        event.put("start_time", rs.getString("start_time"));
                        event.put("end_time", rs.getString("end_time"));
                        event.put("createdBy", rs.getString("user_id") != null ? rs.getString("user_id") : "-"); // Guna user_id FK
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    // PENGESAHAN 2: Jika ID ada, tetapi data objek event langsung tiada di DB mahupun Session
    if (event == null) {
%>
        <div style="padding:20px; margin:50px; background-color:#fff3cd; color:#856404; border:1px solid #ffeeba; border-radius:5px; font-family:sans-serif;">
            <h2>⚠️ Data Acara Tidak Ditemui</h2>
            <p>ID Acara: <b><%= eventId %></b> dikesan, tetapi maklumatnya tiada di dalam rekod pangkalan data.</p>
            <a href="${pageContext.request.contextPath}/EventListServlet" style="display:inline-block; padding:10px 15px; background-color:#856404; color:white; text-decoration:none; border-radius:3px; margin-top:10px;">Kembali ke Event List</a>
        </div>
<%
        return;
    }
    
    // 4. Ekstrak data butiran setelah dipastikan selamat dan wujud
    String eventName = event.get("name") != null ? event.get("name") : "No Name";
    String eventDescription = event.get("description") != null ? event.get("description") : "";
    String eventDate = event.get("date") != null ? event.get("date") : "-";
    
    // Sinkronisasi data masa (time) / start_time & end_time
    String eventTime = event.get("time");
    if ((eventTime == null || eventTime.isEmpty() || eventTime.equals("-")) && event.get("start_time") != null) {
        eventTime = event.get("start_time") + " - " + event.get("end_time");
    }
    if (eventTime == null) eventTime = "-";
    
    String venue = event.get("venue") != null ? event.get("venue") : "-";
    
    // Semak pautan borang dinamik dari session
    String registrationLink = (String) session.getAttribute("regLink_" + eventId);
    String attendanceLink = (String) session.getAttribute("attLink_" + eventId);
    
    boolean isRegLinkGenerated = (registrationLink != null && !registrationLink.isEmpty());
    boolean isAttLinkGenerated = (attendanceLink != null && !attendanceLink.isEmpty());
    
    if (registrationLink == null) registrationLink = "";
    if (attendanceLink == null) attendanceLink = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Event Details - <%= eventName %></title>
    <link rel="stylesheet" href="css/event_details.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
</head>
<body>

<div class="dashboard">
    <div class="top-header">
        <div class="header-left"></div>
        <div class="header-right">
            <div class="vertical-divider"></div>
            <div class="customer-info">
                <span class="customer-name"><i class="fas fa-user"></i> [<%= loggedInUser %>]</span>
                <a href="${pageContext.request.contextPath}/logout.jsp" class="logout-link"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </div>
    </div>

    <div class="main-layout">
        <div class="sidebar">
            <div class="logo-section">
                <h2>SRMS</h2>
                <div class="logo-sub"><%= "staff".equalsIgnoreCase(userRole) ? "STAFF PORTAL" : "CUSTOMER PORTAL" %></div>
            </div>
            
            <nav class="sidebar-nav">
                <ul>
                    <% if ("staff".equalsIgnoreCase(userRole)) { %>
                        <li class="nav-item" id="navStaffDashboard">
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
                        <li class="nav-item active" id="navEventList">
                            <i class="fas fa-calendar-alt nav-icon"></i>
                            <span class="nav-text">Event List</span>
                        </li>
                    <% } else { %>
                        <li class="nav-item" id="navCustDashboard">
                            <i class="fas fa-tachometer-alt nav-icon"></i>
                            <span class="nav-text">Dashboard</span>
                        </li>
                        <li class="nav-item" id="navAddEvent">
                            <i class="fas fa-plus-circle nav-icon"></i>
                            <span class="nav-text">Add Event</span>
                        </li>
                        <li class="nav-item active" id="navEventList">
                            <i class="fas fa-calendar-alt nav-icon"></i>
                            <span class="nav-text">Event List</span>
                        </li>
                    <% } %>
                </ul>
            </nav>
        </div>

        <div class="vertical-divider-line"></div>

        <div class="content-area">
            <div class="event-card">
                <div class="event-header">
                    <h1><i class="fas fa-calendar-alt"></i> EVENT DETAILS</h1>
                </div>
                
                <div class="event-info">
                    <div class="info-row">
                        <div class="info-label"><i class="fas fa-tag"></i> Event Name:</div>
                        <div class="info-value"><%= eventName %></div>
                    </div>
                    <div class="info-row">
                        <div class="info-label"><i class="fas fa-align-left"></i> Event Description:</div>
                        <div class="info-value"><%= eventDescription.isEmpty() ? "-" : eventDescription %></div>
                    </div>
                    <div class="info-row">
                        <div class="info-label"><i class="fas fa-map-marker-alt"></i> Venue:</div>
                        <div class="info-value"><%= venue %></div>
                    </div>
                    <div class="info-row half">
                        <div class="info-label"><i class="fas fa-calendar-day"></i> Date:</div>
                        <div class="info-value"><%= eventDate %></div>
                    </div>
                    <div class="info-row half">
                        <div class="info-label"><i class="fas fa-clock"></i> Time:</div>
                        <div class="info-value"><%= eventTime %></div>
                    </div>
                    <% if ("staff".equalsIgnoreCase(userRole)) { %>
                        <div class="info-row">
                            <div class="info-label"><i class="fas fa-user"></i> Creator:</div>
                            <div class="info-value"><%= event.get("createdBy") %></div>
                        </div>
                    <% } %>
                </div>
                
                <div class="links-section">
                    <div class="link-card">
                        <div class="link-header">
                            <i class="fas fa-user-plus"></i>
                            <h3>Registration Link</h3>
                        </div>
                        <div class="link-body">
                            <% if (isRegLinkGenerated) { %>
                                <div class="generated-link">
                                    <input type="text" id="regLink" value="<%= registrationLink %>" readonly>
                                    <button class="copy-btn" onclick="copyToClipboard('regLink')">
                                        <i class="fas fa-copy"></i> Copy
                                    </button>
                                    <button class="regenerate-btn" onclick="regenerateLink('registration', '<%= eventId %>')">
                                        <i class="fas fa-sync-alt"></i> Regenerate
                                    </button>
                                </div>
                            <% } else { %>
                                <div class="no-link">
                                    <p>No registration link generated yet.</p>
                                    <button class="generate-btn" onclick="generateLink('registration', '<%= eventId %>')">
                                        <i class="fas fa-link"></i> Generate Registration Link
                                    </button>
                                </div>
                            <% } %>
                        </div>
                    </div>
                    
                    <div class="link-card">
                        <div class="link-header">
                            <i class="fas fa-check-circle"></i>
                            <h3>Attendance Link</h3>
                        </div>
                        <div class="link-body">
                            <% if (isAttLinkGenerated) { %>
                                <div class="generated-link">
                                    <input type="text" id="attLink" value="<%= attendanceLink %>" readonly>
                                    <button class="copy-btn" onclick="copyToClipboard('attLink')">
                                        <i class="fas fa-copy"></i> Copy
                                    </button>
                                    <button class="regenerate-btn" onclick="regenerateLink('attendance', '<%= eventId %>')">
                                        <i class="fas fa-sync-alt"></i> Regenerate
                                    </button>
                                </div>
                            <% } else { %>
                                <div class="no-link">
                                    <p>No attendance link generated yet.</p>
                                    <button class="generate-btn" onclick="generateLink('attendance', '<%= eventId %>')">
                                        <i class="fas fa-link"></i> Generate Attendance Link
                                    </button>
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="attendee-section">
                <div class="attendee-header">
                    <h2><i class="fas fa-users"></i> ATTENDEE DETAILS</h2>
                    <button class="refresh-btn" onclick="refreshAttendeeList('<%= eventId %>')">
                        <i class="fas fa-sync-alt"></i> Refresh
                    </button>
                </div>
                
                <div class="table-container">
                    <table class="attendee-table" id="attendeeTable">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>No. Phone</th>
                                <th>Email</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody id="attendeeTableBody">
                            <%
                                String attendDbUrl = "jdbc:mysql://localhost:3306/srms_db";
                                String attendDbUser = "root";
                                String attendDbPass = "";
                                
                                String attendQuery = "SELECT p.name, p.phone_num, p.email_address, ep.rsvp_status " +
                                                     "FROM event_participants ep " +
                                                     "JOIN participants p ON ep.participant_id = p.id " +
                                                     "WHERE ep.reservation_id = ?";
                                
                                boolean dataFound = false;
                                
                                if (eventId != null && !eventId.trim().isEmpty()) {
                                    try {
                                        Class.forName("com.mysql.cj.jdbc.Driver");
                                        try (Connection attendConn = DriverManager.getConnection(attendDbUrl, attendDbUser, attendDbPass);
                                             PreparedStatement attendPstmt = attendConn.prepareStatement(attendQuery)) {
                                            
                                            attendPstmt.setInt(1, Integer.parseInt(eventId.trim()));
                                            
                                            try (ResultSet attendRs = attendPstmt.executeQuery()) {
                                                while (attendRs.next()) {
                                                    dataFound = true;
                                                    String pName = attendRs.getString("name");
                                                    String pPhone = attendRs.getString("phone_num");
                                                    String pEmail = attendRs.getString("email_address");
                                                    if (pEmail == null || pEmail.trim().isEmpty()) {
                                                        pEmail = "-";
                                                    }
                                                    
                                                    String pStatus = attendRs.getString("rsvp_status") != null ? attendRs.getString("rsvp_status") : "tak hadir";
                                                    
                                                    String badgeClass = "badge-absent";
                                                    String statusText = "Tak Hadir";
                                                    if (pStatus.equalsIgnoreCase("hadir") || pStatus.equalsIgnoreCase("present")) {
                                                        badgeClass = "badge-success";
                                                        statusText = "Hadir";
                                                    }
                            %>
                                                    <tr>
                                                        <td><strong><%= pName %></strong></td>
                                                        <td><%= pPhone %></td>
                                                        <td><%= pEmail %></td>
                                                        <td><span class="badge <%= badgeClass %>"><%= statusText %></span></td>
                                                    </tr>
                            <%
                                                }
                                            }
                                        }
                                    } catch (Exception e) {
                            %>
                                        <tr>
                                            <td colspan="4" style="color:red; text-align:center; padding:15px;">
                                                Ralat Database: <%= e.getMessage() %>
                                            </td>
                                        </tr>
                            <%
                                    }
                                }
                                
                                if (!dataFound) {
                            %>
                                    <tr>
                                        <td colspan="4" style="text-align:center; color:#888; padding:20px;">
                                            <i class="fas fa-folder-open"></i> No participants registered yet for this event.
                                        </td>
                                    </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="js/event_details.js"></script>
<script>
    window.eventId = '<%= eventId %>';
    window.userRole = '<%= userRole %>';

    document.addEventListener('DOMContentLoaded', function() {
        const context = '${pageContext.request.contextPath}';
        
        const navStaffDashboard = document.getElementById('navStaffDashboard');
        const navHall = document.getElementById('navHall');
        const navStaff = document.getElementById('navStaff');
        const navReport = document.getElementById('navReport');
        const navCustDashboard = document.getElementById('navCustDashboard');
        const navAddEvent = document.getElementById('navAddEvent');
        const navEventList = document.getElementById('navEventList');

        if (navStaffDashboard) navStaffDashboard.addEventListener('click', function() { window.location.href = context + '/staff_dashboard.jsp'; });
        if (navHall) navHall.addEventListener('click', function() { window.location.href = context + '/hall.jsp'; });
        if (navStaff) navStaff.addEventListener('click', function() { window.location.href = context + '/staff.jsp'; });
        if (navReport) navReport.addEventListener('click', function() { window.location.href = context + '/ReportServlet'; });
        if (navCustDashboard) navCustDashboard.addEventListener('click', function() { window.location.href = context + '/cust_dashboard.jsp'; });
        if (navAddEvent) navAddEvent.addEventListener('click', function() { window.location.href = context + '/EventServlet'; });
        if (navEventList) navEventList.addEventListener('click', function() { window.location.href = context + '/EventListServlet'; });
    });
</script>
</body>
</html>