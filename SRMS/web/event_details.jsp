<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%
    String loggedInUser = (String) session.getAttribute("loggedInUser");
    if (loggedInUser == null || !"customer".equals(loggedInUser)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get event ID from request
    String eventId = request.getParameter("id");
    if (eventId == null) {
        response.sendRedirect("cust_dashboard.jsp");
        return;
    }
    
    // Sample event data (in real app, get from database)
    // For demo purposes, we'll use sample data
    String eventName = "Annual Tech Conference 2025";
    String eventDescription = "Join us for the biggest tech conference of the year featuring industry experts, workshops, and networking opportunities.";
    String eventDate = "2025-06-15";
    String eventTime = "09:00 AM";
    String venue = "KL Convention Center";
    
    // Check if links are generated from session or request
    String registrationLink = (String) session.getAttribute("regLink_" + eventId);
    String attendanceLink = (String) session.getAttribute("attLink_" + eventId);
    
    boolean isRegLinkGenerated = (registrationLink != null && !registrationLink.isEmpty());
    boolean isAttLinkGenerated = (attendanceLink != null && !attendanceLink.isEmpty());
    
    // If not set, use default or null
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
                        <div class="info-value"><%= eventDescription %></div>
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

<!-- Hidden form for generating links -->
<form id="linkForm" method="post" style="display: none;">
    <input type="hidden" name="action" id="linkAction">
    <input type="hidden" name="type" id="linkType">
    <input type="hidden" name="eventId" id="linkEventId">
</form>

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
    
    // Generate link function
    function generateLink(type, eventId) {
        fetch('generate_link.jsp', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'action=generate&type=' + type + '&eventId=' + eventId
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                location.reload();
            } else {
                alert('Failed to generate link. Please try again.');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('An error occurred. Please try again.');
        });
    }
    
    // Regenerate link function
    function regenerateLink(type, eventId) {
        if (confirm('Are you sure you want to regenerate this link? The old link will no longer work.')) {
            fetch('generate_link.jsp', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'action=regenerate&type=' + type + '&eventId=' + eventId
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    location.reload();
                } else {
                    alert('Failed to regenerate link. Please try again.');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('An error occurred. Please try again.');
            });
        }
    }
    
    // Copy to clipboard function
    function copyToClipboard(elementId) {
        const inputElement = document.getElementById(elementId);
        inputElement.select();
        inputElement.setSelectionRange(0, 99999);
        
        try {
            document.execCommand('copy');
            showToast('Link copied to clipboard!');
        } catch (err) {
            navigator.clipboard.writeText(inputElement.value).then(() => {
                showToast('Link copied to clipboard!');
            }).catch(() => {
                alert('Failed to copy link. Please copy manually.');
            });
        }
    }
    
    // Refresh attendee list
    function refreshAttendeeList(eventId) {
        const tableBody = document.getElementById('attendeeTableBody');
        tableBody.innerHTML = '<tr><td colspan="4" class="loading-text">Loading attendees......</td></tr>';
        
        fetch('generate_link.jsp?action=getAttendees&eventId=' + eventId)
            .then(response => response.json())
            .then(data => {
                if (data.success && data.attendees) {
                    if (data.attendees.length === 0) {
                        tableBody.innerHTML = '<tr><td colspan="4" class="loading-text">No attendees registered yet.</td></tr>';
                    } else {
                        tableBody.innerHTML = '';
                        data.attendees.forEach(attendee => {
                            const row = tableBody.insertRow();
                            row.insertCell(0).textContent = attendee.name || '-';
                            row.insertCell(1).textContent = attendee.phone || '-';
                            row.insertCell(2).textContent = attendee.email || '-';
                            
                            const statusCell = row.insertCell(3);
                            const statusClass = attendee.status === 'Registered' ? 'status-registered' : 
                                               (attendee.status === 'Attended' ? 'status-attended' : 'status-cancelled');
                            statusCell.innerHTML = `<span class="status-badge ${statusClass}">${attendee.status || 'Pending'}</span>`;
                        });
                    }
                } else {
                    tableBody.innerHTML = '<tr><td colspan="4" class="loading-text">Failed to load attendees.</td></tr>';
                }
            })
            .catch(error => {
                console.error('Error:', error);
                tableBody.innerHTML = '<tr><td colspan="4" class="loading-text">Error loading attendees.</td></tr>';
            });
    }
    
    // Show toast notification
    function showToast(message) {
        let toast = document.querySelector('.toast-notification');
        if (!toast) {
            toast = document.createElement('div');
            toast.className = 'toast-notification';
            toast.style.cssText = `
                position: fixed;
                bottom: 20px;
                right: 20px;
                background: #4a3b2f;
                color: white;
                padding: 12px 20px;
                border-radius: 8px;
                font-size: 14px;
                z-index: 1000;
                opacity: 0;
                transition: opacity 0.3s ease;
                pointer-events: none;
            `;
            document.body.appendChild(toast);
        }
        
        toast.textContent = message;
        toast.style.opacity = '1';
        
        setTimeout(() => {
            toast.style.opacity = '0';
        }, 2000);
    }
    
    // Load attendees on page load
    refreshAttendeeList('<%= eventId %>');
    
    // Auto refresh every 30 seconds
    let refreshInterval = setInterval(() => {
        refreshAttendeeList('<%= eventId %>');
    }, 30000);
    
    // Clear interval when page is unloaded
    window.addEventListener('beforeunload', function() {
        if (refreshInterval) {
            clearInterval(refreshInterval);
        }
    });
</script>

</body>
</html>