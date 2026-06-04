<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    String loggedInUser = (String) session.getAttribute("loggedInUser");
    String userRole = (String) session.getAttribute("userRole");
    
    if (loggedInUser == null || !"staff".equals(loggedInUser)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get staff from session
    List<Map<String, String>> staffList = (List<Map<String, String>>) session.getAttribute("staffList");
    if (staffList == null) {
        staffList = new ArrayList<>();
        
        // Sample demo data
        Map<String, String> staff1 = new HashMap<>();
        staff1.put("id", "1");
        staff1.put("name", "Ahmad bin Abdullah");
        staff1.put("position", "Event Manager");
        staff1.put("email", "ahmad@srms.com");
        staff1.put("phone", "012-3456789");
        staff1.put("status", "Active");
        staffList.add(staff1);
        
        Map<String, String> staff2 = new HashMap<>();
        staff2.put("id", "2");
        staff2.put("name", "Siti Nurhaliza");
        staff2.put("position", "Hall Supervisor");
        staff2.put("email", "siti@srms.com");
        staff2.put("phone", "013-4567890");
        staff2.put("status", "Active");
        staffList.add(staff2);
        
        Map<String, String> staff3 = new HashMap<>();
        staff3.put("id", "3");
        staff3.put("name", "Raj Kumar");
        staff3.put("position", "Reservation Officer");
        staff3.put("email", "raj@srms.com");
        staff3.put("phone", "014-5678901");
        staff3.put("status", "Inactive");
        staffList.add(staff3);
        
        session.setAttribute("staffList", staffList);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff Management - SRMS</title>
    <link rel="stylesheet" href="css/staff_management.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
</head>
<body>

<div class="dashboard">
    <!-- Top Header -->
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

    <!-- Main Layout -->
    <div class="main-layout">
        <!-- Sidebar -->
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
                    <li class="nav-item" id="navHall">
                        <i class="fas fa-building nav-icon"></i>
                        <span class="nav-text">Hall</span>
                    </li>
                    <li class="nav-item active" id="navStaff">
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

        <!-- Content Area -->
        <div class="content-area">
            <div class="page-header">
                <h1><i class="fas fa-users-gear"></i> STAFF LIST</h1>
                <button id="addStaffBtn" class="add-staff-btn">
                    <i class="fas fa-plus-circle"></i> Add Staff
                </button>
            </div>

            <!-- Staff Table -->
            <div class="table-container">
                <table class="staff-table" id="staffTable">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Position</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="staffTableBody">
                        <% for (Map<String, String> staff : staffList) { %>
                            <tr data-id="<%= staff.get("id") %>">
                                <td><%= staff.get("id") %></td>
                                <td><%= staff.get("name") %></td>
                                <td><%= staff.get("position") %></td>
                                <td><%= staff.get("email") %></td>
                                <td><%= staff.get("phone") %></td>
                                <td>
                                    <span class="status-badge <%= staff.get("status").toLowerCase() %>">
                                        <%= staff.get("status") %>
                                    </span>
                                </td>
                                <td class="actions">
                                    <button class="edit-btn" onclick="editStaff(this)"><i class="fas fa-edit"></i> Edit</button>
                                    <button class="delete-btn" onclick="deleteStaff('<%= staff.get("id") %>')"><i class="fas fa-trash-alt"></i> Delete</button>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Add/Edit Staff Modal -->
<div id="staffModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3 id="modalTitle"><i class="fas fa-plus-circle"></i> Add New Staff</h3>
            <span class="close-modal">&times;</span>
        </div>
        <div class="modal-body">
            <form id="staffForm">
                <input type="hidden" id="staffId" value="">
                <div class="form-group">
                    <label><i class="fas fa-user"></i> Full Name</label>
                    <input type="text" id="staffName" placeholder="Enter full name" required>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-briefcase"></i> Position</label>
                    <input type="text" id="staffPosition" placeholder="Enter position" required>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-envelope"></i> Email</label>
                    <input type="email" id="staffEmail" placeholder="Enter email address" required>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-phone"></i> Phone Number</label>
                    <input type="tel" id="staffPhone" placeholder="Enter phone number" required>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-info-circle"></i> Status</label>
                    <select id="staffStatus">
                        <option value="Active">Active</option>
                        <option value="Inactive">Inactive</option>
                    </select>
                </div>
                <button type="submit" class="submit-btn">Save Staff</button>
            </form>
        </div>
    </div>
</div>

<script src="js/staff_management.js"></script>
</body>
</html>