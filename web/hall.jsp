<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    String loggedInUser = (String) session.getAttribute("loggedInUser");
    String userRole = (String) session.getAttribute("userRole");
    
    // 1. PEMBETULAN: Semak userRole menggunakan equalsIgnoreCase untuk mengelakkan ralat tendang ke login.jsp
    if (loggedInUser == null || !"staff".equalsIgnoreCase(userRole)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get halls from session
    List<Map<String, String>> halls = (List<Map<String, String>>) session.getAttribute("hallList");
    if (halls == null) {
        halls = new ArrayList<>();
        
        // Sample demo data
        Map<String, String> hall1 = new HashMap<>();
        hall1.put("id", "1");
        hall1.put("name", "Grand Hall");
        hall1.put("capacity", "500");
        hall1.put("location", "Level 2");
        hall1.put("status", "Available");
        halls.add(hall1);
        
        Map<String, String> hall2 = new HashMap<>();
        hall2.put("id", "2");
        hall2.put("name", "Meeting Room A");
        hall2.put("capacity", "50");
        hall2.put("location", "Level 1");
        hall2.put("status", "Occupied");
        halls.add(hall2);
        
        Map<String, String> hall3 = new HashMap<>();
        hall3.put("id", "3");
        hall3.put("name", "Ballroom");
        hall3.put("capacity", "300");
        hall3.put("location", "Level 3");
        hall3.put("status", "Available");
        halls.add(hall3);
        
        session.setAttribute("hallList", halls);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hall Management - SRMS</title>
    <link rel="stylesheet" href="css/hall.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
</head>
<body>

<div class="dashboard">
    <div class="top-header">
        <div class="header-left"></div>
        <div class="header-right">
            <div class="vertical-divider"></div>
            <div class="staff-info">
                <span class="staff-name"><i class="fas fa-user-tie"></i> [<%= loggedInUser %>]</span>
                <a href="logout.jsp" class="logout-link"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </div>
    </div>

    <div class="main-layout">
        <div class="sidebar">
            <div class="logo-section">
                <h2>SRMS</h2>
                <div class="logo-sub">STAFF PORTAL</div>
            </div>
            <nav class="sidebar-nav">
                <ul>
                    <li class="nav-item" id="navDashboard">
                        <i class="fas fa-tachometer-alt nav-icon"></i>
                        <span class="nav-text">Dashboard</span>
                    </li>
                    <li class="nav-item active" id="navHall">
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
                    <li class="nav-item" id="navReservation">
                        <i class="fas fa-calendar-check nav-icon"></i>
                        <span class="nav-text">Reservation</span>
                    </li>
                </ul>
            </nav>
        </div>

        <div class="vertical-divider-line"></div>

        <div class="content-area">
            <div class="page-header">
                <h1><i class="fas fa-building"></i> HALL LIST</h1>
                <button id="addHallBtn" class="add-hall-btn">
                    <i class="fas fa-plus-circle"></i> Add Hall
                </button>
            </div>

            <div class="table-container">
                <table class="hall-table" id="hallTable">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Hall Name</th>
                            <th>Capacity</th>
                            <th>Location</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="hallTableBody">
                        <% for (Map<String, String> hall : halls) { %>
                            <tr data-id="<%= hall.get("id") %>">
                                <td><%= hall.get("id") %></td>
                                <td class="editable-name"><%= hall.get("name") %></td>
                                <td class="editable-capacity"><%= hall.get("capacity") %></td>
                                <td class="editable-location"><%= hall.get("location") %></td>
                                <td class="editable-status">
                                    <span class="status-badge <%= hall.get("status").toLowerCase() %>">
                                        <%= hall.get("status") %>
                                    </span>
                                </td>
                                <td class="actions">
                                    <button class="edit-btn" onclick="editHall(this)"><i class="fas fa-edit"></i> Edit</button>
                                    <button class="delete-btn" onclick="deleteHall('<%= hall.get("id") %>')"><i class="fas fa-trash-alt"></i> Delete</button>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<div id="hallModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3 id="modalTitle"><i class="fas fa-plus-circle"></i> Add New Hall</h3>
            <span class="close-modal">&times;</span>
        </div>
        <div class="modal-body">
            <form id="hallForm">
                <input type="hidden" id="hallId">
                <div class="form-group">
                    <label>Hall Name</label>
                    <input type="text" id="hallName" required>
                </div>
                <div class="form-group">
                    <label>Capacity</label>
                    <input type="number" id="hallCapacity" required>
                </div>
                <div class="form-group">
                    <label>Location</label>
                    <input type="text" id="hallLocation" required>
                </div>
                <div class="form-group">
                    <label>Status</label>
                    <select id="hallStatus">
                        <option value="Available">Available</option>
                        <option value="Occupied">Occupied</option>
                        <option value="Maintenance">Maintenance</option>
                    </select>
                </div>
                <button type="submit" class="submit-btn">Save Hall</button>
            </form>
        </div>
    </div>
</div>

<script src="js/hall.js"></script>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const navDashboard = document.getElementById('navDashboard');
        const navHall = document.getElementById('navHall');
        const navStaff = document.getElementById('navStaff');
        const navReport = document.getElementById('navReport');
        const navReservation = document.getElementById('navReservation');

        if (navDashboard) navDashboard.addEventListener('click', function() { window.location.href = 'staff_dashboard.jsp'; });
        if (navHall) navHall.addEventListener('click', function() { window.location.href = 'hall.jsp'; });
        if (navStaff) navStaff.addEventListener('click', function() { window.location.href = 'staff.jsp'; });
        if (navReport) navReport.addEventListener('click', function() { window.location.href = 'ReportServlet'; });
        if (navReservation) navReservation.addEventListener('click', function() { window.location.href = 'EventListServlet'; });
    });
</script>
</body>
</html>