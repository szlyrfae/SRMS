<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
                <div class="logo-sub">CUSTOMER PORTAL</div>
            </div>
            
            <nav class="sidebar-nav">
                <ul>
                    <li class="nav-item" id="navDashboard" onclick="window.location.href='cust_dashboard.jsp';">
                        <i class="fas fa-tachometer-alt nav-icon"></i><span class="nav-text">Dashboard</span>
                    </li>
                    <li class="nav-item active" id="navAddEvent" onclick="window.location.href='EventServlet';">
                        <i class="fas fa-plus-circle nav-icon"></i><span class="nav-text">Add Event</span>
                    </li>
                    <li class="nav-item" id="navEventList" onclick="window.location.href='EventListServlet';">
                        <i class="fas fa-calendar-alt nav-icon"></i><span class="nav-text">Event List</span>
                    </li>
                </ul>
            </nav>
        </div>

        <div class="vertical-divider-line"></div>

        <div class="content-area">
            <div class="form-card">
                <div class="form-header">
                    <i class="fas fa-plus-circle"></i>
                    <h1>Add New Event</h1>
                    <p>Fill in the details to create a new event allocation</p>
                </div>

                <c:if test="${not empty requestScope.message}">
                    <div class="message ${requestScope.messageType}">
                        <i class="${requestScope.messageType == 'success' ? 'fas fa-check-circle' : 'fas fa-exclamation-triangle'}"></i>
                        ${requestScope.message}
                    </div>
                </c:if>

                <c:choose>
                    <c:when test="${requestScope.messageType == 'success'}">
                        <div class="success-actions">
                            <a href="EventServlet" class="btn-secondary"><i class="fas fa-plus"></i> Add Another Event</a>
                            <a href="EventListServlet" class="btn-primary"><i class="fas fa-list"></i> View Event List</a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <form action="EventServlet" method="post" class="add-event-form">
                            <div class="form-group">
                                <label><i class="fas fa-tag"></i> Event Name *</label>
                                <input type="text" name="eventName" placeholder="Enter event name" value="${param.eventName}" required>
                            </div>
                            
                            <div class="form-group">
                                <label><i class="fas fa-align-left"></i> Event Description</label>
                                <textarea name="eventDescription" rows="4" placeholder="Enter event description">${param.eventDescription}</textarea>
                            </div>
                            
                            <div class="form-group">
                                <label><i class="fas fa-building"></i> Select Venue / Hall *</label>
                                <select name="hallId" style="width: 100%; padding: 10px; border-radius: 6px; border: 1px solid #ccc;" required>
                                    <option value="" disabled selected>-- Choose Available Hall --</option>
                                    <c:forEach var="hall" items="${requestScope.hallOptions}">
                                        <option value="${hall.id}" ${param.hallId == hall.id ? 'selected' : ''}>${hall.name}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            
                            <div class="form-row" style="display: flex; gap: 15px;">
                                <div class="form-group" style="flex: 1;">
                                    <label><i class="fas fa-calendar-day"></i> Event Date *</label>
                                    <input type="date" name="eventDate" value="${param.eventDate}" style="width: 100%; padding: 8px;" required>
                                </div>
                            </div>

                            <div class="form-row" style="display: flex; gap: 15px; margin-top: 10px;">
                                <div class="form-group" style="flex: 1;">
                                    <label><i class="fas fa-clock"></i> Start Time *</label>
                                    <input type="time" name="startTime" value="${param.startTime}" style="width: 100%; padding: 8px;" required>
                                </div>
                                <div class="form-group" style="flex: 1;">
                                    <label><i class="fas fa-history"></i> End Time *</label>
                                    <input type="time" name="endTime" value="${param.endTime}" style="width: 100%; padding: 8px;" required>
                                </div>
                            </div>
                            
                            <button type="submit" class="submit-btn" style="margin-top: 20px;">
                                <i class="fas fa-save"></i> Create Event
                            </button>
                        </form>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

</body>
</html>