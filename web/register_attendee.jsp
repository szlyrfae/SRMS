<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    // 1. Cuba ambil data yang dihantar oleh request.setAttribute() dari Servlet
    String eventName = (String) request.getAttribute("eventName");
    String venue = (String) request.getAttribute("venue");
    String date = (String) request.getAttribute("date");
    String time = (String) request.getAttribute("time");
    String description = (String) request.getAttribute("description");

    // =========================================================================
    // 🚀 PELAN KECEMASAN (FALLBACK): Jika Servlet hantar null, kita paksa tarik dari Session!
    // =========================================================================
    if (eventName == null || eventName.isEmpty()) {
        String eventId = request.getParameter("eventId");
        if (eventId != null) {
            // Cuba semak dalam allEvents (Staff)
            List<Map<String, String>> allEvents = (List<Map<String, String>>) session.getAttribute("allEvents");
            Map<String, String> foundEvent = null;
            
            if (allEvents != null) {
                for (Map<String, String> e : allEvents) {
                    if (eventId.equals(e.get("id"))) {
                        foundEvent = e;
                        break;
                    }
                }
            }
            
            // Jika tiada dalam allEvents, cuba semak dalam customerEvents
            if (foundEvent == null) {
                String loggedInUser = (String) session.getAttribute("loggedInUser");
                List<Map<String, String>> customerEvents = (List<Map<String, String>>) session.getAttribute("customerEvents_" + loggedInUser);
                if (customerEvents != null) {
                    for (Map<String, String> e : customerEvents) {
                        if (eventId.equals(e.get("id"))) {
                            foundEvent = e;
                            break;
                        }
                    }
                }
            }
            
            // Jika jumpa dalam Session, masukkan nilai tersebut!
            if (foundEvent != null) {
                eventName = foundEvent.get("name");
                venue = foundEvent.get("venue");
                date = foundEvent.get("date");
                time = foundEvent.get("start_time") + " - " + foundEvent.get("end_time");
                description = foundEvent.get("description");
            }
        }
    }
    // =========================================================================

    // Set nilai default jika masih tidak ditemui setelah pelan kecemasan dijalankan
    if (eventName == null || eventName.isEmpty()) eventName = "Event Form";
    if (venue == null || venue.isEmpty()) venue = "-";
    if (date == null || date.isEmpty()) date = "-";
    if (time == null || time.isEmpty()) time = "-";
    if (description == null) description = "";

    String message = request.getAttribute("message") != null ? (String) request.getAttribute("message") : "";
    String messageType = request.getAttribute("messageType") != null ? (String) request.getAttribute("messageType") : "";
    String generatedAttendeeId = request.getAttribute("generatedAttendeeId") != null ? (String) request.getAttribute("generatedAttendeeId") : "";
    boolean isComing = request.getAttribute("isComing") != null ? (Boolean) request.getAttribute("isComing") : true;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Event Registration - <%= eventName %></title>
    <link rel="stylesheet" href="css/register_attendee.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
</head>
<body>

<div class="registration-container">
    <div class="registration-card">
        <div class="registration-header">
            <div class="logo">
                <i class="fas fa-calendar-check"></i>
                <h2>Smart RSVP</h2>
            </div>
            <p class="tagline">Management System</p>
        </div>

        <div class="event-details-section">
            <h1><i class="fas fa-calendar-alt"></i> <%= eventName %></h1>
            <div class="event-info">
                <div class="info-item"><i class="fas fa-map-marker-alt"></i> <span><strong>Venue:</strong> <%= venue %></span></div>
                <div class="info-item"><i class="fas fa-calendar-day"></i> <span><strong>Date:</strong> <%= date %></span></div>
                <div class="info-item"><i class="fas fa-clock"></i> <span><strong>Time:</strong> <%= time %></span></div>
             </div>
             <% if (!description.isEmpty()) { %>
                <p class="event-description"><%= description %></p>
            <% } %>
        </div>

        <% if (!message.isEmpty()) { %>
            <div class="message <%= messageType %>">
                <i class="<%= messageType.equals("success") ? "fas fa-check-circle" : "fas fa-exclamation-triangle" %>"></i>
                <%= message %>
            </div>
        <% } %>

        <% if (!messageType.equals("success")) { %>
            <div class="form-section">
                <h3><i class="fas fa-user-plus"></i> Register for Event</h3>
                
                <form action="<%= request.getContextPath() %>/RegistrationServlet" method="post" class="registration-form" id="registrationForm">
                    
                    <input type="hidden" name="eventId" value="<%= request.getParameter("eventId") %>">
                    
                    <div class="form-group">
                        <label><i class="fas fa-user"></i> Full Name *</label>
                        <input type="text" name="name" id="name" placeholder="Enter your full name" required>
                    </div>
                    
                    <div class="form-group">
                        <label><i class="fas fa-phone"></i> Phone Number *</label>
                        <input type="tel" name="phone" id="phone" placeholder="Enter your phone number" required>
                    </div>
                    
                    <div class="form-group">
                        <label><i class="fas fa-envelope"></i> Email Address</label>
                        <input type="email" name="email" id="email" placeholder="Enter your email address">
                    </div>
                    
                    <div class="form-group">
                        <label><i class="fas fa-check-circle"></i> Will you attend?</label>
                        <div class="radio-group">
                            <label class="radio-option">
                                <input type="radio" name="attend" value="Registered" checked>
                                <span class="radio-custom"></span>
                                <i class="fas fa-check-circle"></i> Yes, I will attend
                            </label>
                            <label class="radio-option">
                                <input type="radio" name="attend" value="Not Coming">
                                <span class="radio-custom"></span>
                                <i class="fas fa-times-circle"></i> No, I cannot attend
                            </label>
                        </div>
                    </div>
                    
                    <button type="submit" class="submit-btn">
                        <i class="fas fa-paper-plane"></i> SUBMIT REGISTRATION
                    </button>
                </form>
            </div>
        <% } else { %>
            <div class="success-actions">
                <% if (isComing) { %>
                    <i class="fas fa-id-card success-icon"></i>
                    <h3>Registration Successful!</h3>
                    <p>You have successfully registered for this event.</p>
                    
                    <div class="attendee-id-box">
                        <p><i class="fas fa-qrcode"></i> Your Attendee ID:</p>
                        <div class="attendee-id"><%= generatedAttendeeId %></div>
                        <small>Please save this ID. You will need it to mark your attendance.</small>
                    </div>
                    
                    <div class="action-buttons-success">
                        
                        <button class="btn-secondary" onclick="copyAttendeeId()">
                            <i class="fas fa-copy"></i> Copy ID
                        </button>
                    </div>
                <% } else { %>
                    <i class="fas fa-heart success-icon" style="color: #d4c0a8;"></i>
                    <h3>Thank You!</h3>
                    <p>We appreciate your response. We look forward to seeing you at future events!</p>
                    <div class="action-buttons-success">
                        <a href="<%= request.getContextPath() %>/login.jsp" class="btn-primary">
                            <i class="fas fa-home"></i> Back to Home
                        </a>
                    </div>
                <% } %>
            </div>
        <% } %>
    </div>
</div>

<script src="js/register_attendance.js"></script>
<script>
    function copyAttendeeId() {
        const attendeeId = '<%= generatedAttendeeId %>';
        navigator.clipboard.writeText(attendeeId).then(() => {
            alert('Attendee ID copied to clipboard!');
        });
    }
</script>
</body>
</html>