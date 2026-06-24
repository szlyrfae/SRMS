/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

//@WebServlet("/AttendanceServlet")
public class AttendanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final String dbUrl = "jdbc:mysql://localhost:3306/s74699_srms_db";
    private final String dbUser = "s74699";
    private final String dbPass = "SLz4qTEpB8Re";

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet AttendanceServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet AttendanceServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String eventId = request.getParameter("eventId");
        if (eventId == null || eventId.trim().isEmpty()) {
            response.sendRedirect("login.jsp");
            return;
        }

        String query = "SELECT * FROM reservations WHERE id = ?";
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
                PreparedStatement pstmt = conn.prepareStatement(query)) {
                pstmt.setInt(1, Integer.parseInt(eventId));
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        request.setAttribute("eventName", rs.getString("event_name"));
                        request.setAttribute("venue", rs.getString("venue") != null ? rs.getString("venue") : "Main Hall");
                        request.setAttribute("date", rs.getString("reservation_date"));
                        request.setAttribute("time", rs.getString("start_time") + " - " + rs.getString("end_time"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("attendeeId", request.getParameter("attendeeId") != null ? request.getParameter("attendeeId") : "");
        request.getRequestDispatcher("/attendance.jsp").forward(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String eventId = request.getParameter("eventId");
        String attendeeIdParam = request.getParameter("attendeeId");

        String message = "";
        String messageType = "";
        boolean attendanceMarked = false;

        if (attendeeIdParam == null || attendeeIdParam.trim().isEmpty()) {
            request.setAttribute("message", "Please enter your Attendee ID.");
            request.setAttribute("messageType", "error");
            doGet(request, response);
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass)) {
                
                // 🚀 KEMAS KINI: Menggunakan event_participants (Plural)
                String checkQuery = "SELECT rsvp_status FROM event_participants WHERE reservation_id = ? AND participant_id = ?";
                try (PreparedStatement checkPstmt = conn.prepareStatement(checkQuery)) {
                    checkPstmt.setInt(1, Integer.parseInt(eventId));
                    checkPstmt.setString(2, attendeeIdParam.trim());
                    
                    try (ResultSet rs = checkPstmt.executeQuery()) {
                        if (rs.next()) {
                            String currentStatus = rs.getString("rsvp_status");
                            
                            if ("hadir".equalsIgnoreCase(currentStatus)) {
                                message = "You have already marked your attendance for this event!";
                                messageType = "warning";
                                attendanceMarked = true;
                            } else {
                                // 🚀 KEMAS KINI: Kemas kini ke jadual event_participants (Plural)
                                String updateSql = "UPDATE event_participants SET rsvp_status = 'hadir' WHERE reservation_id = ? AND participant_id = ?";
                                try (PreparedStatement updatePstmt = conn.prepareStatement(updateSql)) {
                                    updatePstmt.setInt(1, Integer.parseInt(eventId));
                                    updatePstmt.setString(2, attendeeIdParam.trim());
                                    updatePstmt.executeUpdate();
                                }
                                message = "Attendance marked successfully! Thank you for attending.";
                                messageType = "success";
                                attendanceMarked = true;
                            }
                        } else {
                            message = "Invalid Attendee ID. Please check your ID and try again.";
                            messageType = "error";
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = "Database Error: " + e.getMessage();
            messageType = "error";
        }

        request.setAttribute("message", message);
        request.setAttribute("messageType", messageType);
        request.setAttribute("attendanceMarked", attendanceMarked);
        request.setAttribute("attendeeId", attendeeIdParam);
        
        request.getRequestDispatcher("/attendance.jsp").forward(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
