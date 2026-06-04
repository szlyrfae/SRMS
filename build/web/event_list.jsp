<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    String loggedInUser = (String) session.getAttribute("loggedInUser");
    String userRole = (String) session.getAttribute("userRole");
    
    if (loggedInUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // For Staff - get all events from global session
    // For Customer - get events from customer-specific session
    List<Map<String, String>> events = new ArrayList<>();
    
    if ("Staff".equals(userRole)) {
        // STAFF: Get all events from global session
        List<Map<String, String>> allEvents = (List<Map<String, String>>) session.getAttribute("allEvents");
        if (allEvents == null) {
            allEvents = new ArrayList<>();
            
            // Demo data for staff
            Map<String, String> event1 = new HashMap<>();
            event1.put("id", "1");
            event1.put("name", "Annual Tech Conference 2025");
            event1.put("description", "Join us for the biggest tech conference");
            event1.put("venue", "KL Convention Center");
            event1.put("date", "2025-06-15");
            event1.put("time", "09:00 AM");
            event1.put("createdBy", "customer");
            event1.put("status", "Upcoming");
            allEvents.add(event1);
            
            Map<String, String> event2 = new HashMap<>();
            event2.put("id", "2");
            event2.put("name", "Wedding Reception");
            event2.put("description", "Grand wedding reception");
            event2.put("venue", "Grand Ballroom");
            event2.put("date", "2025-07-20");
            event2.put("time", "07:30 PM");
            event2.put("createdBy", "customer");
            event2.put("status", "Upcoming");
            allEvents.add(event2);
            
            session.setAttribute("allEvents", allEvents);
        }
        events = allEvents;
    } else {
        // CUSTOMER: Get events from customer-specific session
        events = (List<Map<String, String>>) session.getAttribute("customerEvents_" + loggedInUser);
        if (events == null) {
            events = new ArrayList<>();
        }
    }
    
    // Calculate stats
    int totalEvents = events.size();
    int upcomingEvents = 0;
    int completedEvents = 0;
    
    for (Map<String, String> event : events) {
        if ("Upcoming".equals(event.get("status"))) upcomingEvents++;
        if ("Completed".equals(event.get("status"))) completedEvents++;
    }
    
    // Handle delete action
    String deleteId = request.getParameter("delete");
    if (deleteId != null) {
        events.removeIf(event -> event.get("id").equals(deleteId));
        if ("Staff".equals(userRole)) {
            session.setAttribute("allEvents", events);
        } else {
            session.setAttribute("customerEvents_" + loggedInUser, events);
        }
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
    <div class="top-header">
        <div class="header-left"></div>
        <div class="header-right">
            <div class="vertical-divider"></div>
            <div class="customer-info">
                <span class="customer-name"><i class="fas fa-user"></i> [<%= loggedInUser %>]</span>
                <a href="logout.jsp" class="logout-link"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </div>
    </div>

    <div class="main-layout">
        <div class="sidebar">
            <div class="logo-section">
                <h2>SRMS</h2>
                <div class="logo-sub"><%= "Staff".equals(userRole) ? "STAFF PORTAL" : "CUSTOMER PORTAL" %></div>
            </div>
            <nav class="sidebar-nav">
                <ul>
                    <% if ("Staff".equals(userRole)) { %>
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
            <div class="page-header">
                <h1><i class="fas fa-calendar-alt"></i> Event List</h1>
                <p>Manage all your events here</p>
            </div>

            <!-- Stats Cards -->
            <div class="stats-container">
                <div class="stat-card">
                    <i class="fas fa-calendar-alt"></i>
                    <h3>Total Events</h3>
                    <p class="stat-number"><%= totalEvents %></p>
                </div>
                <div class="stat-card">
                    <i class="fas fa-clock"></i>
                    <h3>Upcoming</h3>
                    <p class="stat-number"><%= upcomingEvents %></p>
                </div>
                <div class="stat-card">
                    <i class="fas fa-check-circle"></i>
                    <h3>Completed</h3>
                    <p class="stat-number"><%= completedEvents %></p>
                </div>
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
                    <% for (Map<String, String> event : events) { 
                        String status = event.get("status");
                        if (status == null) status = "Upcoming";
                    %>
                        <div class="event-card" data-event-id="<%= event.get("id") %>">
                            <div class="event-status <%= status.toLowerCase() %>">
                                <%= status %>
                            </div>
                            <h3 class="event-name"><%= event.get("name") %></h3>
                            <div class="event-details">
                                <p><i class="fas fa-map-marker-alt"></i> <%= event.get("venue") %></p>
                                <p><i class="fas fa-calendar-day"></i> <%= event.get("date") %></p>
                                <p><i class="fas fa-clock"></i> <%= event.get("time") %></p>
                                <% if (event.get("description") != null && !event.get("description").isEmpty()) { %>
                                    <p class="event-description"><i class="fas fa-align-left"></i> <%= event.get("description").length() > 100 ? event.get("description").substring(0, 100) + "..." : event.get("description") %></p>
                                <% } %>
                                <% if ("Staff".equals(userRole)) { %>
                                    <p><i class="fas fa-user"></i> Created by: <%= event.get("createdBy") %></p>
                                <% } %>
                            </div>
                            <div class="event-actions">
                                <a href="event_details.jsp?id=<%= event.get("id") %>" class="btn-details" data-event-id="<%= event.get("id") %>">
                                    <i class="fas fa-info-circle"></i> Details
                                </a>
                                <a href="event_list.jsp?delete=<%= event.get("id") %>" class="btn-delete" data-event-id="<%= event.get("id") %>" onclick="return confirmDelete(event)">
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

<script src="js/event_list.js"></script>
</body>
</html>