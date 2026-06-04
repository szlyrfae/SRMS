<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    String loggedInUser = (String) session.getAttribute("loggedInUser");
    if (loggedInUser == null || !"customer".equals(loggedInUser)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String message = "";
    String messageType = "";
    
    // Handle form submission
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String eventName = request.getParameter("eventName");
        String eventDescription = request.getParameter("eventDescription");
        String venue = request.getParameter("venue");
        String eventDate = request.getParameter("eventDate");
        String eventTime = request.getParameter("eventTime");
        
        if (eventName != null && !eventName.trim().isEmpty()) {
            // Get existing events from session
            List<Map<String, String>> events = (List<Map<String, String>>) session.getAttribute("customerEvents_" + loggedInUser);
            if (events == null) {
                events = new ArrayList<>();
            }
            
            // Create new event
            Map<String, String> newEvent = new HashMap<>();
            newEvent.put("id", String.valueOf(events.size() + 1));
            newEvent.put("name", eventName);
            newEvent.put("description", eventDescription);
            newEvent.put("venue", venue);
            newEvent.put("date", eventDate);
            newEvent.put("time", eventTime);
            newEvent.put("status", "Upcoming");
            
            events.add(newEvent);
            session.setAttribute("customerEvents_" + loggedInUser, events);
            
            message = "Event added successfully!";
            messageType = "success";
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
    <title>Add Event - SRMS</title>
    <link rel="stylesheet" href="css/add_event.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
</head>
<body>

<div class="dashboard">
    <!-- Top Header -->
    <div class="top-header">
        <div class="header-left">
            <!-- Empty or logo kecil -->
        </div>
        <div class="header-right">
            <div class="vertical-divider"></div>
            <div class="customer-info">
                <span class="customer-name"><i class="fas fa-user"></i> [<%= loggedInUser %>]</span>
                <a href="logout.jsp" class="logout-link"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </div>
    </div>

    <!-- Main Layout with Sidebar -->
    <div class="main-layout">
        <!-- Sidebar Kiri Sama Macam Dashboard -->
        <div class="sidebar">
            <div class="logo-section">
                <h2>SMART RSVP</h2>
                <div class="logo-sub">MANAGEMENT SYSTEM</div>
            </div>
            
            <nav class="sidebar-nav">
                <ul>
                    <li class="nav-item" id="navDashboard">
                        <i class="fas fa-tachometer-alt nav-icon"></i>
                        <span class="nav-text">Dashboard</span>
                    </li>
                    <li class="nav-item active" id="navAddEvent">
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
            <div class="form-card">
                <div class="form-header">
                    <i class="fas fa-plus-circle"></i>
                    <h1>Add New Event</h1>
                    <p>Fill in the details to create a new event</p>
                </div>

                <% if (!message.isEmpty()) { %>
                    <div class="message <%= messageType %>">
                        <i class="<%= messageType.equals("success") ? "fas fa-check-circle" : "fas fa-exclamation-triangle" %>"></i>
                        <%= message %>
                    </div>
                <% } %>

                <% if (messageType.equals("success")) { %>
                    <div class="success-actions">
                        <a href="add_event.jsp" class="btn-secondary">
                            <i class="fas fa-plus"></i> Add Another Event
                        </a>
                        <a href="event_list.jsp" class="btn-primary">
                            <i class="fas fa-list"></i> View Event List
                        </a>
                    </div>
                <% } else { %>
                    <form method="post" class="add-event-form">
                        <div class="form-group">
                            <label><i class="fas fa-tag"></i> Event Name *</label>
                            <input type="text" name="eventName" placeholder="Enter event name" required>
                        </div>
                        
                        <div class="form-group">
                            <label><i class="fas fa-align-left"></i> Event Description</label>
                            <textarea name="eventDescription" rows="4" placeholder="Enter event description"></textarea>
                        </div>
                        
                        <div class="form-group">
                            <label><i class="fas fa-map-marker-alt"></i> Venue *</label>
                            <input type="text" name="venue" placeholder="Enter venue location" required>
                        </div>
                        
                        <div class="form-row">
                            <div class="form-group half">
                                <label><i class="fas fa-calendar-day"></i> Date *</label>
                                <input type="date" name="eventDate" required>
                            </div>
                            <div class="form-group half">
                                <label><i class="fas fa-clock"></i> Time *</label>
                                <input type="time" name="eventTime" required>
                            </div>
                        </div>
                        
                        <button type="submit" class="submit-btn">
                            <i class="fas fa-save"></i> Create Event
                        </button>
                    </form>
                <% } %>
            </div>
        </div>
    </div>
</div>

<script>
    // Navigation to different pages
    document.getElementById('navDashboard').addEventListener('click', function() {
        window.location.href = 'cust_dashboard.jsp';
    });
    document.getElementById('navAddEvent').addEventListener('click', function() {
        window.location.href = 'add_event.jsp';
    });
    document.getElementById('navEventList').addEventListener('click', function() {
        window.location.href = 'event_list.jsp';
    });
</script>

</body>
</html>