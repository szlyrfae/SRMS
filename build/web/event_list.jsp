<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Event List - SRMS</title>
    <link class="nav-text" rel="stylesheet" href="css/event_list.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
</head>
<body>

<div class="dashboard">
    <div class="top-header">
        <div class="header-left"></div>
        <div class="header-right">
            <div class="vertical-divider"></div>
            <div class="customer-info">
                <span class="customer-name"><i class="fas fa-user"></i> [${sessionScope.loggedInUser}]</span>
                <a href="logout.jsp" class="logout-link"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </div>
    </div>

    <div class="main-layout">
        <div class="sidebar">
            <div class="logo-section">
                <h2>SRMS</h2>
                <div class="logo-sub">${sessionScope.userRole == 'staff' ? 'STAFF PORTAL' : 'CUSTOMER PORTAL'}</div>
            </div>
            <nav class="sidebar-nav">
                <ul>
                    <c:choose>
                        <c:when test="${sessionScope.userRole == 'staff'}">
                            <li class="nav-item" id="navStaffDashboard">
                                <i class="fas fa-tachometer-alt nav-icon"></i><span class="nav-text">Dashboard</span>
                            </li>
                            <li class="nav-item" id="navHall">
                                <i class="fas fa-building nav-icon"></i><span class="nav-text">Hall</span>
                            </li>
                            <li class="nav-item" id="navStaff">
                                <i class="fas fa-users-gear nav-icon"></i><span class="nav-text">Staff</span>
                            </li>
                            <li class="nav-item" id="navReport">
                                <i class="fas fa-chart-bar nav-icon"></i><span class="nav-text">Report</span>
                            </li>
                            <li class="nav-item active" id="navEventList">
                                <i class="fas fa-calendar-alt nav-icon"></i><span class="nav-text">Reservation</span>
                            </li>
                        </c:when>
                        <c:otherwise>
                            <li class="nav-item" id="navCustDashboard">
                                <i class="fas fa-tachometer-alt nav-icon"></i><span class="nav-text">Dashboard</span>
                            </li>
                            <li class="nav-item" id="navAddEvent">
                                <i class="fas fa-plus-circle nav-icon"></i><span class="nav-text">Add Event</span>
                            </li>
                            <li class="nav-item active" id="navEventList">
                                <i class="fas fa-calendar-alt nav-icon"></i><span class="nav-text">Event List</span>
                            </li>
                        </c:otherwise>
                    </c:choose>
                </ul>
            </nav>
        </div>

        <div class="vertical-divider-line"></div>

        <div class="content-area">
            <div class="page-header">
                <h1><i class="fas fa-calendar-alt"></i> Event List</h1>
                <p>Manage all database reservations seamlessly</p>
            </div>

            <c:if test="${not empty requestScope.sqlErrorMsg}">
                <div style="background-color: #f8d7da; color: #721c24; padding: 15px; border-radius: 6px; margin-bottom: 20px;">
                    <i class="fas fa-exclamation-triangle"></i> ${requestScope.sqlErrorMsg}
                </div>
            </c:if>

            <div class="stats-container">
                <div class="stat-card">
                    <i class="fas fa-calendar-alt"></i>
                    <h3>Total Events</h3>
                    <p class="stat-number">${not empty requestScope.totalEvents ? requestScope.totalEvents : 0}</p>
                </div>
                <div class="stat-card">
                    <i class="fas fa-clock"></i>
                    <h3>Upcoming</h3>
                    <p class="stat-number">${not empty requestScope.upcomingEvents ? requestScope.upcomingEvents : 0}</p>
                </div>
                <div class="stat-card">
                    <i class="fas fa-check-circle"></i>
                    <h3>Completed</h3>
                    <p class="stat-number">${not empty requestScope.completedEvents ? requestScope.completedEvents : 0}</p>
                </div>
            </div>

            <c:choose>
                <c:when test="${empty requestScope.events}">
                    <div class="empty-state">
                        <i class="fas fa-calendar-times"></i>
                        <h3>No Active Reservations Found</h3>
                        <p>There are no recorded events inside the database system currently.</p>
                        <c:if test="${sessionScope.userRole != 'staff'}">
                            <a href="EventServlet" class="btn-primary"><i class="fas fa-plus"></i> Create First Event</a>
                        </c:if>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="events-grid">
                        <c:forEach var="event" items="${requestScope.events}">
                            <div class="event-card">
                                <div class="event-status ${fn:toLowerCase(event.status)}">
                                    ${event.status}
                                </div>
                                <h3 class="event-name">${event.name}</h3>
                                <div class="event-details">
                                    <p><i class="fas fa-map-marker-alt"></i> Venue: ${event.venue}</p>
                                    <p><i class="fas fa-calendar-day"></i> Date: ${event.date}</p>
                                    <p><i class="fas fa-clock"></i> Time: ${event.start_time} - ${event.end_time}</p>
                                    <c:if test="${not empty event.description}">
                                        <p class="event-description"><i class="fas fa-align-left"></i> ${event.description}</p>
                                    </c:if>
                                    <c:if test="${sessionScope.userRole == 'staff'}">
                                        <p style="color: #e67e22; font-weight: bold;"><i class="fas fa-user"></i> Booked By: ${event.createdBy}</p>
                                    </c:if>
                                </div>
                                <div class="event-actions">
                                    <a href="event_details.jsp?id=${event.id}" class="btn-details">
                                        <i class="fas fa-info-circle"></i> Details
                                    </a>
                                    <button type="button" class="btn-delete" data-event-id="${event.id}" style="border:none; cursor:pointer;">
                                        <i class="fas fa-trash-alt"></i> Delete
                                    </button>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<script src="js/event_list.js?v=1.5"></script>
</body>
</html>