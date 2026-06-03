<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Smart RSVP Management System</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

<div class="login-container">
    <div class="login-card">
        
        <!-- Logo from assets/image/ -->
        <div class="logo-area">
            <img src="assets/logo_small.png" alt="Logo" class="logo" id="logoImage">
        </div>
        
        <!-- Title -->
        <h1 class="system-title">Smart RSVP Management System</h1>
        
        <!-- Login Form -->
        <form action="login.jsp" method="post" class="login-form" id="loginForm">
            <div class="input-group">
                <input type="text" name="username" id="username" placeholder="Username" value="${param.username != null ? param.username : ''}" required autofocus>
            </div>
            
            <div class="input-group">
                <div class="password-wrapper">
                    <input type="password" name="password" id="passwordField" placeholder="Password" required>
                    <button type="button" class="toggle-eye" id="togglePasswordBtn">👁️</button>
                </div>
            </div>
            
            <button type="submit" class="login-btn">Login</button>
        </form>
        
        <!-- Demo Credentials Hint -->
        <div class="demo-hint">
            <p>Demo: admin / rsvp@2025</p>
        </div>
    </div>
</div>

<!-- POPUP MODAL FOR ERROR MESSAGE -->
<div id="errorModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <span class="close-btn">&times;</span>
            <div class="modal-icon">⚠️</div>
        </div>
        <div class="modal-body">
            <p id="errorMessageText"></p>
        </div>
        <div class="modal-footer">
            <button class="modal-close-btn">OK</button>
        </div>
    </div>
</div>

<script src="js/script.js"></script>

<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String errorMsg = null;

    if (username != null && password != null) {
        // Demo credentials
        if (("staff".equals(username) && "staff".equals(password)) ||
            ("customer".equals(username) && "customer".equals(password))) {
            
            session.setAttribute("loggedInUser", username);
            
            // Redirect based on role - Paling ringkas
            if ("staff".equals(username)) {
                session.setAttribute("userRole", "Staff");
                response.sendRedirect("staff_dashboard.jsp");
            } else {
                session.setAttribute("userRole", "Customer");
                response.sendRedirect("cust_dashboard.jsp");
            }
            return;
        } else {
            errorMsg = "Invalid username or password. Please try again.";
        }
    }
%>

<!-- Pass error message to JavaScript if exists -->
<% if (errorMsg != null) { %>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            showErrorPopup('<%= errorMsg %>');
        });
    </script>
<% } %>

</body>
</html>