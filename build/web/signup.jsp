<%-- 
    Document   : signup
    Created on : 6 Jun 2026, 7:56:33 pm
    Author     : BLADEKAZUMA
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Sign Up - Smart RSVP</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .login-redirect {
            margin-top: 20px;
            text-align: center;
            font-size: 14px;
            color: #666;
        }
        .login-redirect a {
            color: #d4c0a8;
            text-decoration: none;
            font-weight: bold;
        }
        .login-redirect a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>

<div class="login-container">
    <div class="login-card">
        <div class="logo-area">
            <img src="assets/logo_small.png" alt="Logo" class="logo">
        </div>
        
        <h1 class="system-title">Create Customer Account</h1>
        
        <form action="SignupServlet" method="post" class="login-form">
            <div class="input-group">
                <input type="text" name="fullName" placeholder="Full Name" required>
            </div>
            <div class="input-group">
                <input type="text" name="username" placeholder="Choose Username" required>
            </div>
            <div class="input-group">
                <input type="password" name="password" placeholder="Password" required>
            </div>
            <button type="submit" class="login-btn">Register Account</button>
        </form>
        
        <div class="login-redirect">
            <p>Already have an account? <a href="login.jsp">Login Instead</a></p>
        </div>
    </div>
</div>

<div id="errorModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <span class="close-btn">&times;</span>
            <div class="modal-icon" id="modalIcon">⚠️</div>
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
    String successMsg = (String) request.getAttribute("successMsg");
    if (errorMsg != null) { 
%>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            showErrorPopup('<%= errorMsg %>');
        });
    </script>
<% } else if (successMsg != null) { %>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('modalIcon').innerText = '✅';
            showErrorPopup('<%= successMsg %>');
            // Alihkan ke login selepas user tekan OK
            document.querySelector('.modal-close-btn').addEventListener('click', function() {
                window.location.href = 'login.jsp';
            });
            document.querySelector('.close-btn').addEventListener('click', function() {
                window.location.href = 'login.jsp';
            });
        });
    </script>
<% } %>

</body>
</html>