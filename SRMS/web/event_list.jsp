<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    String loggedInUser = (String) session.getAttribute("loggedInUser");
    if (loggedInUser == null || !"customer".equals(loggedInUser)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get events from session
    List<Map<String, String>> events = (List<Map<String, String>>) session.getAttribute("customerEvents_" + loggedInUser);
    if (events == null) {
        events = new ArrayList<>();
    }
    
    // Handle delete action
    String deleteId = request.getParameter("delete");
    if (deleteId != null) {
        events.removeIf(event -> event.get("id").equals(deleteId));
        session.setAttribute("customerEvents_" + loggedInUser, events);
        response.sendRedirect("event_list.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Event List - SRMS</title>
    <link rel="stylesheet" href="css/event_list.css">
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
                    <li class="nav-item" id="navAddEvent">
                        <i class="fas fa-plus-circle nav-icon"></i>
                        <span class="nav-text">Add Event</span>
                    </li>
                    <li class="nav-item active" id="navEventList">
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
            <div class="page-header">
                <h1><i class="fas fa-calendar-alt"></i> Event List</h1>
                <p>Manage all your events here</p>
            </div>

            <% if (events.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-calendar-times"></i>
                    <h3>No Events Yet</h3>
                    <p>Click the "Add Event" button to create your first event.</p>
                    <a href="add_event.jsp" class="btn-primary">
                        <i class="fas fa-plus"></i> Create Your First Event
                    </a>
                </div>
            <% } else { %>
                <div class="events-grid">
                    <% for (Map<String, String> event : events) { %>
                        <div class="event-card">
                            <div class="event-status <%= event.get("status").toLowerCase() %>">
                                <%= event.get("status") %>
                            </div>
                            <h3 class="event-name"><%= event.get("name") %></h3>
                            <div class="event-details">
                                <p><i class="fas fa-map-marker-alt"></i> <%= event.get("venue") %></p>
                                <p><i class="fas fa-calendar-day"></i> <%= event.get("date") %></p>
                                <p><i class="fas fa-clock"></i> <%= event.get("time") %></p>
                                <% if (event.get("description") != null && !event.get("description").isEmpty()) { %>
                                    <p class="event-description"><i class="fas fa-align-left"></i> <%= event.get("description").length() > 100 ? event.get("description").substring(0, 100) + "..." : event.get("description") %></p>
                                <% } %>
                            </div>
                            <div class="event-actions">
                                <a href="event_details.jsp?id=<%= event.get("id") %>" class="btn-details">
                                    <i class="fas fa-info-circle"></i> Details
                                </a>
                                <a href="event_list.jsp?delete=<%= event.get("id") %>" class="btn-delete" onclick="return confirm('Are you sure you want to delete this event?')">
                                    <i class="fas fa-trash-alt"></i> Delete
                                </a>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } %>
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