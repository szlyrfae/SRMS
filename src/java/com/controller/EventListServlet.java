package com.controller;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

//@WebServlet("/EventListServlet")
public class EventListServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private final String dbUrl = "jdbc:mysql://localhost:3306/s74699_srms_db";
    private final String dbUser = "s74699";
    private final String dbPass = "SLz4qTEpB8Re"; // <-- WAJIB: Samakan dengan password MySQL di EventServlet anda!

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String loggedInUser = (String) session.getAttribute("loggedInUser");
        String userRole = (String) session.getAttribute("userRole");
        
        // Membaca variasi nama session ID secara dinamik
        Object loggedInUserIdObj = session.getAttribute("loggedInUserId");
        if (loggedInUserIdObj == null) {
            loggedInUserIdObj = session.getAttribute("userId");
        }
        if (loggedInUserIdObj == null) {
            loggedInUserIdObj = session.getAttribute("id");
        }

        // Cetakan Diagnostik di Konsol NetBeans
        System.out.println("====== DIAGNOSIS EVENT LIST ======");
        System.out.println("--> LoggedInUser: " + loggedInUser);
        System.out.println("--> UserRole: " + userRole);
        System.out.println("--> Derived UserID: " + (loggedInUserIdObj != null ? loggedInUserIdObj.toString() : "KOSONG/NULL"));
        System.out.println("==================================");

        if (loggedInUser == null || userRole == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        List<Map<String, String>> eventsList = new ArrayList<>();
        int totalEvents = 0;
        int upcomingEvents = 0;
        int completedEvents = 0;

        String querySql = "";
        
        if ("staff".equalsIgnoreCase(userRole)) {
            // STAFF: Membaca semua rekod menggunakan LEFT JOIN berserta susunan tarikh yang betul
            querySql = "SELECT r.*, h.name AS venue_name, IFNULL(u.name, r.user_id) AS creator " +
                       "FROM reservations r " +
                       "LEFT JOIN halls h ON r.hall_id = h.id " +
                       "LEFT JOIN users u ON r.user_id = u.id " +
                       "ORDER BY r.reservation_date DESC, r.start_time DESC"; // <-- DIKEMAS KINI
        } else {
            // CUSTOMER: Menapis mengikut ID pengguna secara spesifik
            querySql = "SELECT r.*, h.name AS venue_name " +
                       "FROM reservations r " +
                       "LEFT JOIN halls h ON r.hall_id = h.id " +
                       "WHERE r.user_id = ? " +
                       "ORDER BY r.reservation_date DESC, r.start_time DESC"; // <-- DIKEMAS KINI
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
                 PreparedStatement pstmt = conn.prepareStatement(querySql)) {
                
                if (!"staff".equalsIgnoreCase(userRole)) {
                    String currentUserId = (loggedInUserIdObj != null) ? loggedInUserIdObj.toString().trim() : "";
                    pstmt.setString(1, currentUserId);
                }

                try (ResultSet rs = pstmt.executeQuery()) {
                    // Menyediakan waktu perbandingan tarikh semasa (mencabut nilai jam/minit)
                    java.util.Calendar cal = java.util.Calendar.getInstance();
                    cal.set(java.util.Calendar.HOUR_OF_DAY, 0);
                    cal.set(java.util.Calendar.MINUTE, 0);
                    cal.set(java.util.Calendar.SECOND, 0);
                    cal.set(java.util.Calendar.MILLISECOND, 0);
                    java.sql.Date today = new java.sql.Date(cal.getTimeInMillis());

                    while (rs.next()) {
                        Map<String, String> event = new HashMap<>();
                        event.put("id", rs.getString("id"));
                        event.put("name", rs.getString("event_name"));
                        event.put("description", rs.getString("event_description"));
                        
                        String venueName = rs.getString("venue_name");
                        event.put("venue", (venueName != null) ? venueName : "Unknown Venue");
                        
                        // DIKEMAS KINI: Membaca nilai mengikut nama kolum sebenar database
                        event.put("date", rs.getString("reservation_date")); 
                        
                        event.put("start_time", rs.getString("start_time"));
                        event.put("end_time", rs.getString("end_time"));
                        
                        if ("staff".equalsIgnoreCase(userRole)) {
                            event.put("createdBy", rs.getString("creator"));
                        }

                        // DIKEMAS KINI: Mengambil objek Date menggunakan kolum 'reservation_date' untuk kaunter summary
                        java.sql.Date eventDate = rs.getDate("reservation_date");
                        String status = "Upcoming";
                        
                        if (eventDate != null && eventDate.before(today)) {
                            status = "Completed";
                            completedEvents++;
                        } else {
                            status = "Upcoming";
                            upcomingEvents++;
                        }
                        event.put("status", status);
                        
                        eventsList.add(event);
                        totalEvents++;
                    }
                }
            }
        } catch (Exception e) {
            System.out.println("--> Ralat SQL EventList: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("sqlErrorMsg", "Database Exception: " + e.getMessage());
        }

        // Memasukkan data ke dalam scope permintaan untuk pembacaan JSTL di event_list.jsp
        request.setAttribute("events", eventsList);
        request.setAttribute("totalEvents", totalEvents);
        request.setAttribute("upcomingEvents", upcomingEvents);
        request.setAttribute("completedEvents", completedEvents);
        
        if ("staff".equalsIgnoreCase(userRole)) {
            // Staff: Guna nama sesi 'allEvents'
            session.setAttribute("allEvents", eventsList);
        } else {
            // Customer: Guna nama sesi 'customerEvents_[username]' bersandarkan user yang login
            session.setAttribute("customerEvents_" + loggedInUser, eventsList);
        }

        request.getRequestDispatcher("event_list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String deleteId = request.getParameter("deleteId");
        if (deleteId != null && !deleteId.trim().isEmpty()) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                String deleteSql = "DELETE FROM reservations WHERE id = ?";
                try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
                     PreparedStatement pstmt = conn.prepareStatement(deleteSql)) {
                    pstmt.setInt(1, Integer.parseInt(deleteId));
                    pstmt.executeUpdate();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        response.sendRedirect("EventListServlet");
    }
}