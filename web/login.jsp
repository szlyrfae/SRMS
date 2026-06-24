<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Smart RSVP Management System</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        /* Gaya tambahan untuk pautan pendaftaran */
        .signup-redirect {
            margin-top: 20px;
            text-align: center;
            font-size: 14px;
            color: #666;
        }
        .signup-redirect a {
            color: #d4c0a8;
            text-decoration: none;
            font-weight: bold;
            transition: color 0.2s;
        }
        .signup-redirect a:hover {
            color: #bfa88f;
            text-decoration: underline;
        }
    </style>
</head>
<body>

<div class="login-container">
    <div class="login-card">
        
        <div class="logo-area">
            <img src="assets/logo_small.png" alt="Logo" class="logo" id="logoImage">
        </div>
        
        <h1 class="system-title">Smart RSVP Management System </h1>
        
        <form action="LoginServlet" method="post" class="login-form" id="loginForm">
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
        
        <div class="signup-redirect">
            <p>Don't have an account? <a href="signup.jsp">Sign Up Here</a></p>
        </div>
    </div>
</div>

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
    String errorMsg = (String) request.getAttribute("errorMsg");
    if (errorMsg != null) { 
%>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            showErrorPopup('<%= errorMsg %>');
        });
    </script>
<% } %>

</body>
</html>