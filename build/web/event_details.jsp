<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%
    String loggedInUser = (String) session.getAttribute("loggedInUser");
    String userRole = (String) session.getAttribute("userRole");
    
    if (loggedInUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get event ID from request
    String eventId = request.getParameter("id");
    if (eventId == null) {
        if ("Staff".equals(userRole)) {
            response.sendRedirect("event_list.jsp");
        } else {
            response.sendRedirect("cust_dashboard.jsp");
        }
        return;
    }
    
    // Get event from session based on role
    Map<String, String> event = null;
    
    if ("Staff".equals(userRole)) {
        // Staff: Get from allEvents
        List<Map<String, String>> allEvents = (List<Map<String, String>>) session.getAttribute("allEvents");
        if (allEvents != null) {
            for (Map<String, String> e : allEvents) {
                if (e.get("id").equals(eventId)) {
                    event = e;
                    break;
                }
            }
        }
    } else {
        // Customer: Get from customerEvents
        List<Map<String, String>> customerEvents = (List<Map<String, String>>) session.getAttribute("customerEvents_" + loggedInUser);
        if (customerEvents != null) {
            for (Map<String, String> e : customerEvents) {
                if (e.get("id").equals(eventId)) {
                    event = e;
                    break;
                }
            }
        }
    }
    
    // If event not found, redirect
    if (event == null) {
        if ("Staff".equals(userRole)) {
            response.sendRedirect("event_list.jsp");
        } else {
            response.sendRedirect("cust_dashboard.jsp");
        }
        return;
    }
    
    // Get event details
    String eventName = event.get("name");
    String eventDescription = event.get("description") != null ? event.get("description") : "";
    String eventDate = event.get("date");
    String eventTime = event.get("time");
    String venue = event.get("venue");
    
    // Check if links are generated from session
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
    <!-- Top Header -->
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

    <!-- Main Layout with Sidebar -->
    <div class="main-layout">
        <!-- Sidebar based on role -->
        <div class="sidebar">
            <div class="logo-section">
                <h2>SRMS</h2>
                <div class="logo-sub"><%= "Staff".equals(userRole) ? "STAFF PORTAL" : "CUSTOMER PORTAL" %></div>
            </div>
            
            <nav class="sidebar-nav">
                <ul>
                    <% if ("Staff".equals(userRole)) { %>
                        <li class="nav-item" id="navDashboard">
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
                    <% } %>
                </ul>
            </nav>
        </div>

        <!-- Vertical Divider Line -->
        <div class="vertical-divider-line"></div>

        <!-- Content Area -->
        <div class="content-area">
            <!-- Event Details Card -->
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
                    <% if ("Staff".equals(userRole)) { %>
                        <div class="info-row">
                            <div class="info-label"><i class="fas fa-user"></i> Created By:</div>
                            <div class="info-value"><%= event.get("createdBy") %></div>
                        </div>
                    <% } %>
                </div>
                
                <!-- Links Section -->
                <div class="links-section">
                    <!-- Registration Link -->
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
                    
                    <!-- Attendance Link -->
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
            
            <!-- Attendee Details Table -->
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
                            <tr>
                                <td colspan="4" class="loading-text">Loading attendees...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="js/event_details.js"></script>
<script>
    // Pass eventId to JavaScript
    window.eventId = '<%= eventId %>';
    window.userRole = '<%= userRole %>';
</script>
</body>
</html>