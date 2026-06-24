/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

//@WebServlet("/EventServlet")
public class EventServlet extends HttpServlet {
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
            out.println("<title>Servlet EventServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet EventServlet at " + request.getContextPath() + "</h1>");
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
        List<Map<String, String>> hallOptions = new ArrayList<>();
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass)) {
                String sql = "SELECT id, name FROM halls WHERE LOWER(status) != 'maintenance' ORDER BY name ASC";
                try (Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
                    while (rs.next()) {
                        Map<String, String> hall = new HashMap<>();
                        hall.put("id", rs.getString("id"));
                        hall.put("name", rs.getString("name"));
                        hallOptions.add(hall);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        request.setAttribute("hallOptions", hallOptions);
        request.getRequestDispatcher("add_event.jsp").forward(request, response);
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
        HttpSession session = request.getSession();
        String loggedInUser = (String) session.getAttribute("loggedInUser");
        String userRole = (String) session.getAttribute("userRole");
        Object loggedInUserIdObj = session.getAttribute("loggedInUserId");

        if (loggedInUser == null || !"customer".equalsIgnoreCase(userRole)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String eventName = request.getParameter("eventName");
        String eventDescription = request.getParameter("eventDescription");
        String hallIdStr = request.getParameter("hallId");
        String eventDate = request.getParameter("eventDate");
        String startTime = request.getParameter("startTime");
        String endTime = request.getParameter("endTime");

        String message = "";
        String messageType = "";

        if (eventName != null && !eventName.trim().isEmpty() && hallIdStr != null 
                && !eventDate.isEmpty() && !startTime.isEmpty() && !endTime.isEmpty()) {
            
            if (startTime.compareTo(endTime) >= 0) {
                message = "Booking failed! End time must be later than start time.";
                messageType = "error";
            } else {
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass)) {
                        
                        // 1. KAWALAN PERTINDIHAN SLOT MASA (Clash Checking)
                        String sqlCheck = "SELECT COUNT(*) FROM reservations WHERE hall_id = ? AND reservation_date = ? "
                                        + "AND ((start_time < ? AND end_time > ?) OR (start_time >= ? AND start_time < ?))";
                        
                        try (PreparedStatement pstmtCheck = conn.prepareStatement(sqlCheck)) {
                            pstmtCheck.setString(1, hallIdStr);
                            pstmtCheck.setString(2, eventDate);
                            pstmtCheck.setString(3, endTime);
                            pstmtCheck.setString(4, startTime);
                            pstmtCheck.setString(5, startTime);
                            pstmtCheck.setString(6, endTime);
                            
                            try (ResultSet rsCheck = pstmtCheck.executeQuery()) {
                                int count = 0;
                                if (rsCheck.next()) {
                                    count = rsCheck.getInt(1);
                                }
                                
                                if (count > 0) {
                                    message = "Booking failed! The selected hall is already occupied during this time frame.";
                                    messageType = "error";
                                } else {
                                    // 2. KEMASUKAN DATA MANUAL TANPA KOLUM STATUS
                                    String sqlInsert = "INSERT INTO reservations (event_name, event_description, reservation_date, start_time, end_time, user_id, hall_id) VALUES (?, ?, ?, ?, ?, ?, ?)";
                                    try (PreparedStatement pstmtInsert = conn.prepareStatement(sqlInsert)) {
                                        pstmtInsert.setString(1, eventName);
                                        pstmtInsert.setString(2, eventDescription);
                                        pstmtInsert.setString(3, eventDate);
                                        pstmtInsert.setString(4, startTime);
                                        pstmtInsert.setString(5, endTime);
                                        
                                        // PEMBETULAN UTMA: Tukar jenis data kepada String demi menyokong ID teks seperti 'cust01'
                                        String userId = "";
                                        if (loggedInUserIdObj != null) {
                                            userId = loggedInUserIdObj.toString().trim();
                                        }
                                        
                                        // Fallback pencarian sekiranya data sesi terputus/kosong
                                        if (userId.isEmpty()) {
                                            String sqlFallback = "SELECT id FROM users WHERE LOWER(role) = 'customer' LIMIT 1";
                                            try (Statement stmtF = conn.createStatement(); ResultSet rsF = stmtF.executeQuery(sqlFallback)) {
                                                if (rsF.next()) {
                                                    userId = rsF.getString("id"); // Ambil sebagai String
                                                }
                                            }
                                        }

                                        // Mesej amaran jika jadual users kosong langsung
                                        if (userId.isEmpty()) {
                                            message = "Booking failed! No valid customer account found in the system.";
                                            messageType = "error";
                                            request.setAttribute("message", message);
                                            request.setAttribute("messageType", messageType);
                                            doGet(request, response);
                                            return;
                                        }

                                        // PENTING: Guna setString() kerana user_id anda ialah VARCHAR
                                        pstmtInsert.setString(6, userId);
                                        
                                        // Kekal setInt jika id dewan adalah nombor bulat (auto-increment)
                                        pstmtInsert.setInt(7, Integer.parseInt(hallIdStr));
                                        
                                        pstmtInsert.executeUpdate();
                                        message = "Event registered and hall slot secured successfully!";
                                        messageType = "success";
                                    }
                                }
                            }
                        }
                    }
                } catch (Exception e) {
                    message = "Database process error: " + e.getMessage();
                    messageType = "error";
                }
            }
        } else {
            message = "Please fill in all required fields.";
            messageType = "error";
        }

        request.setAttribute("message", message);
        request.setAttribute("messageType", messageType);
        
        // Logik UX: Jika gagal, hantar data sedia ada terus ke JSP tanpa reset input teks
        if ("error".equals(messageType)) {
            List<Map<String, String>> hallOptions = new ArrayList<>();
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
                     Statement stmt = conn.createStatement(); 
                     ResultSet rs = stmt.executeQuery("SELECT id, name FROM halls WHERE LOWER(status) != 'maintenance' ORDER BY name ASC")) {
                    while (rs.next()) {
                        Map<String, String> hall = new HashMap<>();
                        hall.put("id", rs.getString("id"));
                        hall.put("name", rs.getString("name"));
                        hallOptions.add(hall);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            request.setAttribute("hallOptions", hallOptions);
            request.getRequestDispatcher("add_event.jsp").forward(request, response);
        } else {
            // Jika berjaya, panggil doGet untuk mengosongkan borang
            doGet(request, response);
        }
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
