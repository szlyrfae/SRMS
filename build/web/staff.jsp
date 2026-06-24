<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%
    String loggedInUser = (String) session.getAttribute("loggedInUser");
    String userRole = (String) session.getAttribute("userRole");
    
    if (loggedInUser == null || !"staff".equalsIgnoreCase(userRole)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    List<Map<String, String>> staffList = new ArrayList<>();
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/s74699_srms_db", "s74699", "SLz4qTEpB8Re");
        
        String sql = "SELECT id, name, role FROM users WHERE LOWER(role) = 'staff' ORDER BY id ASC";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        
        while (rs.next()) {
            Map<String, String> staff = new HashMap<>();
            staff.put("id", rs.getString("id"));
            staff.put("name", rs.getString("name"));
            staff.put("role", rs.getString("role"));
            staffList.add(staff);
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
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
                    <li class="nav-item" id="navDashboard"><i class="fas fa-tachometer-alt nav-icon"></i><span class="nav-text">Dashboard</span></li>
                    <li class="nav-item" id="navHall"><i class="fas fa-building nav-icon"></i><span class="nav-text">Hall</span></li>
                    <li class="nav-item active" id="navStaff"><i class="fas fa-users-gear nav-icon"></i><span class="nav-text">Staff</span></li>
                    <li class="nav-item" id="navReport"><i class="fas fa-chart-bar nav-icon"></i><span class="nav-text">Report</span></li>
                    <li class="nav-item" id="navReservation"><i class="fas fa-calendar-check nav-icon"></i><span class="nav-text">Reservation</span></li>
                </ul>
            </nav>
        </div>

        <div class="vertical-divider-line"></div>

        <div class="content-area">
            <div class="page-header">
                <h1><i class="fas fa-users-gear"></i> STAFF LIST</h1>
                <button id="addStaffBtn" class="add-staff-btn"><i class="fas fa-plus-circle"></i> Add Staff</button>
            </div>

            <div class="table-container">
                <table class="staff-table" id="staffTable">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Role</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="staffTableBody">
                        <% if (staffList.isEmpty()) { %>
                            <tr><td colspan="4" style="text-align: center; color: #888;">No staff accounts found.</td></tr>
                        <% } else { %>
                            <% for (Map<String, String> staff : staffList) { %>
                                <tr data-id="<%= staff.get("id") %>">
                                    <td><%= staff.get("id") %></td>
                                    <td><%= staff.get("name") %></td>
                                    <td><span class="status-badge staff"><%= staff.get("role") %></span></td>
                                    <td class="actions">
                                        <button class="edit-btn" onclick="editStaff(this)"><i class="fas fa-edit"></i> Edit</button>
                                        <button class="delete-btn" onclick="deleteStaff('<%= staff.get("id") %>')"><i class="fas fa-trash-alt"></i> Delete</button>
                                    </td>
                                </tr>
                            <% } %>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<div id="staffModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3 id="modalTitle"><i class="fas fa-plus-circle"></i> Add New Staff</h3>
            <span class="close-modal" id="closeModalBtn">&times;</span>
        </div>
        <div class="modal-body">
            <form id="staffForm">
                <input type="hidden" id="staffRole" value="staff">
                
                <div class="form-group">
                    <label><i class="fas fa-id-badge"></i> Staff ID</label>
                    <input type="text" id="staffId" placeholder="Enter staff ID (e.g., 101)" required>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-user"></i> Full Name</label>
                    <input type="text" id="staffName" placeholder="Enter full name" required>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-lock"></i> Password</label>
                    <input type="password" id="staffPassword" placeholder="Enter password" required>
                </div>
                
                <button type="submit" class="submit-btn">Save Staff</button>
            </form>
        </div>
    </div>
</div>

<script src="js/staff_management.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        if (document.getElementById('navDashboard')) document.getElementById('navDashboard').onclick = () => window.location.href = 'staff_dashboard.jsp';
        if (document.getElementById('navHall')) document.getElementById('navHall').onclick = () => window.location.href = 'hall.jsp';
        if (document.getElementById('navStaff')) document.getElementById('navStaff').onclick = () => window.location.href = 'staff.jsp';
        if (document.getElementById('navReport')) document.getElementById('navReport').onclick = () => window.location.href = 'ReportServlet';
        if (document.getElementById('navReservation')) document.getElementById('navReservation').onclick = () => window.location.href = 'EventListServlet';
    });
</script>
</body>
</html>