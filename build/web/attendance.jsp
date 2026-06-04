<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    String eventId = request.getParameter("eventId");
    String code = request.getParameter("code");
    
    if (eventId == null || code == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get event details from session
    Map<String, String> event = null;
    List<Map<String, String>> allEvents = (List<Map<String, String>>) session.getAttribute("allEvents");
    
    if (allEvents != null) {
        for (Map<String, String> e : allEvents) {
            if (e.get("id").equals(eventId)) {
                event = e;
                break;
            }
        }
    }
    
    // If event not found, use sample data
    if (event == null) {
        event = new HashMap<>();
        event.put("name", "Annual Tech Conference 2025");
        event.put("venue", "KL Convention Center");
        event.put("date", "2025-06-15");
        event.put("time", "09:00 AM");
    }
    
    String message = "";
    String messageType = "";
    String attendeeId = "";
    boolean attendanceMarked = false;
    
    // Check if already marked attendance via session
    String alreadyMarked = (String) session.getAttribute("attendance_marked_" + eventId + "_" + (request.getParameter("attendeeId") != null ? request.getParameter("attendeeId") : ""));
    
    // Handle form submission
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String attendeeIdParam = request.getParameter("attendeeId");
        String attend = request.getParameter("attend");
        
        if (attendeeIdParam != null && !attendeeIdParam.trim().isEmpty()) {
            // Get attendees list from session
            List<Map<String, String>> attendees = (List<Map<String, String>>) session.getAttribute("attendees_" + eventId);
            
            if (attendees != null) {
                boolean found = false;
                for (Map<String, String> attendee : attendees) {
                    if (attendee.get("id") != null && attendee.get("id").equals(attendeeIdParam)) {
                        found = true;
                        // Check if already attended
                        if ("Attended".equals(attendee.get("status"))) {
                            message = "You have already marked your attendance for this event!";
                            messageType = "warning";
                            attendanceMarked = true;
                        } else {
                            // Update status to Attended
                            attendee.put("status", "Attended");
                            session.setAttribute("attendees_" + eventId, attendees);
                            message = "Attendance marked successfully! Thank you for attending.";
                            messageType = "success";
                            attendanceMarked = true;
                            session.setAttribute("attendance_marked_" + eventId + "_" + attendeeIdParam, "true");
                        }
                        break;
                    }
                }
                
                if (!found) {
                    message = "Invalid Attendee ID. Please check your ID and try again.";
                    messageType = "error";
                }
            } else {
                message = "No attendees found for this event.";
                messageType = "error";
            }
        } else {
            message = "Please enter your Attendee ID.";
            messageType = "error";
        }
    }
    
    // Get attendee name if ID provided via GET
    String prefillId = request.getParameter("attendeeId");
    if (prefillId != null && !prefillId.isEmpty()) {
        List<Map<String, String>> attendees = (List<Map<String, String>>) session.getAttribute("attendees_" + eventId);
        if (attendees != null) {
            for (Map<String, String> attendee : attendees) {
                if (attendee.get("id") != null && attendee.get("id").equals(prefillId)) {
                    attendeeId = prefillId;
                    break;
                }
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mark Attendance - <%= event.get("name") %></title>
    <link rel="stylesheet" href="css/attendance.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
</head>
<body>

<div class="attendance-container">
    <div class="attendance-card">
        <!-- Header -->
        <div class="attendance-header">
            <div class="logo">
                <i class="fas fa-calendar-check"></i>
                <h2>Smart RSVP</h2>
            </div>
            <p class="tagline">Attendance Management System</p>
        </div>

        <!-- Event Details -->
        <div class="event-details-section">
            <h1><i class="fas fa-calendar-alt"></i> <%= event.get("name") %></h1>
            <div class="event-info">
                <div class="info-item">
                    <i class="fas fa-map-marker-alt"></i>
                    <span><strong>Venue:</strong> <%= event.get("venue") %></span>
                </div>
                <div class="info-item">
                    <i class="fas fa-calendar-day"></i>
                    <span><strong>Date:</strong> <%= event.get("date") %></span>
                </div>
                <div class="info-item">
                    <i class="fas fa-clock"></i>
                    <span><strong>Time:</strong> <%= event.get("time") %></span>
                </div>
            </div>
        </div>

        <!-- Message -->
        <% if (!message.isEmpty()) { %>
            <div class="message <%= messageType %>">
                <i class="<%= messageType.equals("success") ? "fas fa-check-circle" : (messageType.equals("warning") ? "fas fa-exclamation-triangle" : "fas fa-exclamation-circle") %>"></i>
                <%= message %>
            </div>
        <% } %>

        <!-- Attendance Form (only show if not already marked) -->
        <% if (!attendanceMarked && !messageType.equals("success")) { %>
            <div class="form-section">
                <h3><i class="fas fa-qrcode"></i> Mark Your Attendance</h3>
                <p class="instruction">Please enter your Attendee ID to confirm your presence at this event.</p>
                
                <form method="post" class="attendance-form" id="attendanceForm">
                    <div class="form-group">
                        <label><i class="fas fa-id-card"></i> Attendee ID *</label>
                        <input type="text" name="attendeeId" id="attendeeId" placeholder="Enter your Attendee ID" value="<%= attendeeId %>" required>
                        <small class="hint">Your Attendee ID was sent to you after registration.</small>
                    </div>
                    
                    <div class="action-buttons">
                        <button type="submit" name="attend" value="yes" class="submit-btn">
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
                <a href="<%= request.getContextPath() %>/login.jsp" class="btn-primary">
                    <i class="fas fa-home"></i> Back to Home
                </a>
            </div>
        <% } %>
    </div>
</div>

<script src="js/attendance.js"></script>
</body>
</html>