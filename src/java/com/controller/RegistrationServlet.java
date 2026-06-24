/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;


//@WebServlet("/RegistrationServlet")
public class RegistrationServlet extends HttpServlet {
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
            out.println("<title>Servlet RegistrationServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet RegistrationServlet at " + request.getContextPath() + "</h1>");
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
    
        // 🔍 PRINT 1: Semak adakah ID sampai ke Servlet
        System.out.println("====== SYSTEM DIAGNOSTIC (doGet) ======");
        System.out.println("--> Received eventId from URL: " + eventId);

        if (eventId == null || eventId.trim().isEmpty()) {
            System.out.println("--> [AMARAN]: eventId KOSONG! Menghala ke login.jsp");
            System.out.println("=======================================");
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
                        // 🔍 PRINT 2: Semak adakah data berjaya ditarik dari database
                        System.out.println("--> [SUKSES]: Data ditemui dalam database MySQL!");
                        System.out.println("--> Event Name: " + rs.getString("event_name"));
                        System.out.println("--> Venue: " + rs.getString("venue"));
                        System.out.println("--> Date: " + rs.getString("reservation_date"));
                    
                        // Set data ke request attribute
                        request.setAttribute("eventName", rs.getString("event_name"));
                        request.setAttribute("venue", rs.getString("venue") != null ? rs.getString("venue") : "Main Hall");
                        request.setAttribute("date", rs.getString("reservation_date"));
                        request.setAttribute("time", rs.getString("start_time") + " - " + rs.getString("end_time"));
                    
                        try {
                            request.setAttribute("description", rs.getString("event_description"));
                        } catch (SQLException e) {
                            request.setAttribute("description", "");
                        }
                    } else {
                        // 🔍 PRINT 3: Jika ID dihantar, tapi tiada rekod dalam database
                        System.out.println("--> [RALAT]: ID " + eventId + " dihantar, TAPI TIADA rekod sepadan dalam table reservations!");
                    }
                }
            }
        } catch (Exception e) {
            // 🔍 PRINT 4: Jika berlaku sebarang ralat crash SQL
            System.out.println("--> [CRASH ERROR]: " + e.getMessage());
            e.printStackTrace();
        }
        System.out.println("=======================================");

        request.getRequestDispatcher("/register_attendee.jsp").forward(request, response);
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
        String name = request.getParameter("name");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String attend = request.getParameter("attend");

        String message = "";
        String messageType = "";
        String generatedAttendeeId = "";
        boolean isComing = "Registered".equals(attend);

        if (name == null || name.trim().isEmpty() || phone == null || phone.trim().isEmpty()) {
            request.setAttribute("message", "Please fill in all required fields.");
            request.setAttribute("messageType", "error");
            doGet(request, response);
            return;
        }

        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            conn.setAutoCommit(false);

            // 🚀 KEMAS KINI: Menggunakan event_participants & participants (Plural)
            String checkQuery = "SELECT * FROM event_participants ep JOIN participants p ON ep.participant_id = p.id WHERE ep.reservation_id = ? AND p.phone_num = ?";
            try (PreparedStatement checkPstmt = conn.prepareStatement(checkQuery)) {
                checkPstmt.setInt(1, Integer.parseInt(eventId));
                checkPstmt.setString(2, phone);
                try (ResultSet rs = checkPstmt.executeQuery()) {
                    if (rs.next()) {
                        request.setAttribute("message", "You have already registered for this event with this phone number.");
                        request.setAttribute("messageType", "error");
                        conn.rollback();
                        doGet(request, response);
                        return;
                    }
                }
            }

            if (isComing) {
                generatedAttendeeId = UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();

                // 🚀 KEMAS KINI: Simpan ke jadual participants (Plural)
                String insertPartSql = "INSERT INTO participants (id, name, phone_num, email_address) VALUES (?, ?, ?, ?)";
                try (PreparedStatement partPstmt = conn.prepareStatement(insertPartSql)) {
                    partPstmt.setString(1, generatedAttendeeId);
                    partPstmt.setString(2, name);
                    partPstmt.setString(3, phone);
                    partPstmt.setString(4, email != null ? email : "");
                    partPstmt.executeUpdate();
                }

                // 🚀 KEMAS KINI: Simpan ke jadual event_participants (Plural)
                String insertEventPartSql = "INSERT INTO event_participants (reservation_id, participant_id, rsvp_status) VALUES (?, ?, 'tak hadir')";
                try (PreparedStatement epPstmt = conn.prepareStatement(insertEventPartSql)) {
                    epPstmt.setInt(1, Integer.parseInt(eventId));
                    epPstmt.setString(2, generatedAttendeeId);
                    epPstmt.executeUpdate();
                }

                message = "Registration successful! Your Attendee ID has been generated.";
                messageType = "success";
            } else {
                message = "Thank you for your response. We're sorry you can't make it this time.";
                messageType = "success";
            }

            conn.commit();

        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException se) { se.printStackTrace(); }
            }
            e.printStackTrace();
            message = "Database Error: " + e.getMessage();
            messageType = "error";
        } finally {
            if (conn != null) { try { conn.close(); } catch (SQLException e) { e.printStackTrace(); } }
        }

        request.setAttribute("message", message);
        request.setAttribute("messageType", messageType);
        request.setAttribute("generatedAttendeeId", generatedAttendeeId);
        request.setAttribute("isComing", isComing);
        
        request.getRequestDispatcher("/register_attendee.jsp").forward(request, response);
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
