<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%
    // 1. Dapatkan eventId secara selamat
    String eventId = request.getAttribute("eventId") != null ? String.valueOf(request.getAttribute("eventId")) : request.getParameter("eventId");

    // 2. Ambil data dari request attribute (jika dihantar oleh Servlet)
    String eventName = (String) request.getAttribute("eventName");
    String venue = (String) request.getAttribute("venue");
    String date = (String) request.getAttribute("date");
    String time = (String) request.getAttribute("time");

    // =========================================================================
    // 🚀 MULTI-TABLE JOIN FALLBACK: Menyedot data merentasi table reservations & halls
    // =========================================================================
    if ((eventName == null || eventName.trim().isEmpty() || venue == null || venue.equals("-")) 
        && eventId != null && !eventId.trim().isEmpty()) {
        
        String dbUrl = "jdbc:mysql://localhost:3306/s74699_srms_db";
        String dbUser = "s74699";
        String dbPass = "SLz4qTEpB8Re";
        
        // 🎯 SQL JOIN: Menggabungkan reservations (r) dan halls (h) berasaskan hall_id
        String myQuery = "SELECT r.*, h.name AS nama_dewan FROM reservations r " +
                         "LEFT JOIN halls h ON r.hall_id = h.id " +
                         "WHERE r.id = ?";
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection myConn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
                 PreparedStatement myPstmt = myConn.prepareStatement(myQuery)) {
                
                myPstmt.setInt(1, Integer.parseInt(eventId.trim()));
                
                try (ResultSet myRs = myPstmt.executeQuery()) {
                    if (myRs.next()) {
                        // 1. Ambil Nama Event (Cuba event_name dahulu, kemudian name)
                        try { eventName = myRs.getString("event_name"); } catch(Exception ex) { eventName = myRs.getString("name"); }
                        
                        // 2. 🌟 AMBIL NAMA VENUE DARI TABLE HALLS (Menggunakan Alias AS nama_dewan)
                        venue = myRs.getString("nama_dewan");
                        if (venue == null || venue.trim().isEmpty()) {
                            venue = "Main Hall"; // Jika hall_id kosong/null di DB, set default
                        }
                        
                        // 3. Ambil Tarikh (reservation_date)
                        try { date = myRs.getString("reservation_date"); } catch(Exception ex) { date = myRs.getString("date"); }
                        
                        // 4. Ambil Masa (start_time & end_time)
                        try {
                            String start = myRs.getString("start_time");
                            String end = myRs.getString("end_time");
                            if (start != null && end != null) {
                                time = start + " - " + end;
                            } else {
                                time = myRs.getString("time");
                            }
                        } catch(Exception ex) {
                            try { time = myRs.getString("time"); } catch(Exception eX) { time = "-"; }
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.out.println("Direct SQL Join in attendance.jsp failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
    // =========================================================================

    // Pembersihan akhir data sebelum dicetak ke HTML
    if (eventName == null || eventName.trim().isEmpty()) eventName = "Attendance Form";
    if (venue == null || venue.trim().isEmpty()) venue = "-";
    if (date == null || date.trim().isEmpty()) date = "-";
    if (time == null || time.trim().isEmpty()) time = "-";

    String message = request.getAttribute("message") != null ? (String) request.getAttribute("message") : "";
    String messageType = request.getAttribute("messageType") != null ? (String) request.getAttribute("messageType") : "";
    String attendeeId = request.getAttribute("attendeeId") != null ? (String) request.getAttribute("attendeeId") : "";
    boolean attendanceMarked = request.getAttribute("attendanceMarked") != null ? (Boolean) request.getAttribute("attendanceMarked") : false;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mark Attendance - <%= eventName %></title>
    <link rel="stylesheet" href="css/attendance.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
</head>
<body>

<div class="attendance-container">
    <div class="attendance-card">
        <div class="attendance-header">
            <div class="logo">
                <i class="fas fa-calendar-check"></i>
                <h2>Smart RSVP</h2>
            </div>
            <p class="tagline">Attendance Management System</p>
        </div>

        <div class="event-details-section">
            <h1><i class="fas fa-calendar-alt"></i> <%= eventName %></h1>
            <div class="event-info">
                <div class="info-item"><i class="fas fa-map-marker-alt"></i> <span><strong>Venue:</strong> <%= venue %></span></div>
                <div class="info-item"><i class="fas fa-calendar-day"></i> <span><strong>Date:</strong> <%= date %></span></div>
                <div class="info-item"><i class="fas fa-clock"></i> <span><strong>Time:</strong> <%= time %></span></div>
            </div>
        </div>

        <% if (!message.isEmpty()) { %>
            <div class="message <%= messageType %>">
                <i class="<%= messageType.equals("success") ? "fas fa-check-circle" : (messageType.equals("warning") ? "fas fa-exclamation-triangle" : "fas fa-exclamation-circle") %>"></i>
                <%= message %>
            </div>
        <% } %>

        <% if (!attendanceMarked && !messageType.equals("success")) { %>
            <div class="form-section">
                <h3><i class="fas fa-qrcode"></i> Mark Your Attendance</h3>
                <p class="instruction">Please enter your Attendee ID to confirm your presence at this event.</p>
                
                <form action="<%= request.getContextPath() %>/AttendanceServlet" method="post" class="attendance-form" id="attendanceForm">
                    
                    <input type="hidden" name="eventId" value="<%= request.getParameter("eventId") %>">
                    
                    <div class="form-group">
                        <label><i class="fas fa-id-card"></i> Attendee ID *</label>
                        <input type="text" name="attendeeId" id="attendeeId" placeholder="Enter your Attendee ID" value="<%= attendeeId %>" required>
                        <small class="hint">Your Attendee ID was sent to you after registration.</small>
                    </div>
                    
                    <div class="action-buttons">
                        <button type="submit" class="submit-btn">
                            <i class="fas fa-check-circle"></i> Mark Attendance
                        </button>
                    </div>
                </form>
            </div>
        <% } else if (messageType.equals("success")) { %>
            <div class="success-actions">
                <i class="fas fa-check-circle success-icon"></i>
                <h3>Attendance Recorded!</h3>
                <p>Thank you for attending the event.</p>
               
            </div>
        <% } %>
    </div>
</div>

<script src="js/attendance.js"></script>
</body>
</html>