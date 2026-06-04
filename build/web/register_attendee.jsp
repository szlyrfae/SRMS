<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.util.UUID" %>
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
        event.put("description", "Join us for the biggest tech conference of the year");
    }
    
    String message = "";
    String messageType = "";
    String generatedAttendeeId = "";
    boolean isComing = true;
    
    // Handle form submission
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String name = request.getParameter("name");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String attend = request.getParameter("attend");
        
        if (name != null && !name.trim().isEmpty() && phone != null && !phone.trim().isEmpty()) {
            // Save attendee to session
            List<Map<String, String>> attendees = (List<Map<String, String>>) session.getAttribute("attendees_" + eventId);
            if (attendees == null) {
                attendees = new ArrayList<>();
            }
            
            // Check if already registered (by email or phone)
            boolean alreadyRegistered = false;
            for (Map<String, String> a : attendees) {
                if ((email != null && email.equals(a.get("email"))) || (phone != null && phone.equals(a.get("phone")))) {
                    alreadyRegistered = true;
                    break;
                }
            }
            
            if (!alreadyRegistered) {
                // Check if attendee is coming
                isComing = "Registered".equals(attend);
                
                Map<String, String> attendee = new HashMap<>();
                attendee.put("name", name);
                attendee.put("phone", phone);
                attendee.put("email", email != null ? email : "");
                attendee.put("status", isComing ? "Registered" : "Not Coming");
                
                // ONLY generate ID if they are coming
                if (isComing) {
                    String uniqueId = UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
                    generatedAttendeeId = uniqueId;
                    attendee.put("id", uniqueId);
                    message = "Registration successful! Your Attendee ID has been generated.";
                } else {
                    attendee.put("id", "");
                    message = "Thank you for your response. We're sorry you can't make it this time.";
                }
                
                attendees.add(attendee);
                session.setAttribute("attendees_" + eventId, attendees);
                
                // Also store in global attendees list for staff
                List<Map<String, String>> allAttendees = (List<Map<String, String>>) session.getAttribute("allAttendees_" + eventId);
                if (allAttendees == null) {
                    allAttendees = new ArrayList<>();
                }
                allAttendees.add(attendee);
                session.setAttribute("allAttendees_" + eventId, allAttendees);
                
                messageType = "success";
            } else {
                message = "You have already registered for this event with this email or phone number.";
                messageType = "error";
            }
        } else {
            message = "Please fill in all required fields.";
            messageType = "error";
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Event Registration - <%= event.get("name") %></title>
    <link rel="stylesheet" href="css/register_attendee.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
</head>
<body>

<div class="registration-container">
    <div class="registration-card">
        <!-- Header with Logo -->
        <div class="registration-header">
            <div class="logo">
                <i class="fas fa-calendar-check"></i>
                <h2>Smart RSVP</h2>
            </div>
            <p class="tagline">Management System</p>
        </div>

        <!-- Event Details Section -->
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
            <% if (event.get("description") != null && !event.get("description").isEmpty()) { %>
                <p class="event-description"><%= event.get("description") %></p>
            <% } %>
        </div>

        <!-- Success/Error Message -->
        <% if (!message.isEmpty()) { %>
            <div class="message <%= messageType %>">
                <i class="<%= messageType.equals("success") ? "fas fa-check-circle" : "fas fa-exclamation-triangle" %>"></i>
                <%= message %>
            </div>
        <% } %>

        <!-- Registration Form (only show if not success) -->
        <% if (!messageType.equals("success")) { %>
            <div class="form-section">
                <h3><i class="fas fa-user-plus"></i> Register for Event</h3>
                <form method="post" class="registration-form" id="registrationForm">
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
            <!-- Success Page - Different view based on attendance choice -->
            <div class="success-actions">
                <% if (isComing && generatedAttendeeId != null && !generatedAttendeeId.isEmpty()) { %>
                    <!-- Case 1: Coming - Show Attendee ID -->
                    <i class="fas fa-id-card success-icon"></i>
                    <h3>Registration Successful!</h3>
                    <p>You have successfully registered for this event.</p>
                    
                    <div class="attendee-id-box">
                        <p><i class="fas fa-qrcode"></i> Your Attendee ID:</p>
                        <div class="attendee-id"><%= generatedAttendeeId %></div>
                        <small>Please save this ID. You will need it to mark your attendance.</small>
                    </div>
                    
                    <div class="action-buttons-success">
                        <a href="<%= request.getContextPath() %>/login.jsp" class="btn-primary">
                            <i class="fas fa-home"></i> Back to Home
                        </a>
                        <button class="btn-secondary" onclick="copyAttendeeId()">
                            <i class="fas fa-copy"></i> Copy ID
                        </button>
                    </div>
                <% } else { %>
                    <!-- Case 2: Not Coming - Just thank you message -->
                    <i class="fas fa-heart success-icon" style="color: #d4c0a8;"></i>
                    <h3>Thank You!</h3>
                    <p>We appreciate your response. We're sorry you can't make it this time.</p>
                    <p>We look forward to seeing you at future events!</p>
                    
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

<script src="js/register_attendee.js"></script>
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