<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%
    // Set header respons sebagai format JSON yang sah
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    // 🎯 PEMBETULAN UTAMA: Ambil ID Nombor pengguna (Object) dari session LoginServlet
    Object loggedInUserIdObj = session.getAttribute("loggedInUserId");
    
    if (loggedInUserIdObj == null) {
        out.print("{\"success\": false, \"message\": \"Not logged in\"}");
        return;
    }
    
    // Tukarkan objek ID tersebut kepada integer atau string mengikut kesesuaian data
    String loggedInUserId = String.valueOf(loggedInUserIdObj);
    
    // Pembolehubah untuk menyimpan statistik kaunter khusus untuk pelanggan
    int totalEvents = 0;
    int upcomingEvents = 0;
    int completedEvents = 0;
    
    List<Map<String, String>> recentEvents = new ArrayList<>();
    
    // Tetapan Pangkalan Data SRMS
    String dbUrl = "jdbc:mysql://localhost:3306/s74699_srms_db";
    String dbUser = "s74699";
    String dbPass = "SLz4qTEpB8Re";
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass)) {
            
            // 🌟 1. KIRA STATISTIK BERDASARKAN ID NOMBOR (user_id = ?)
            String sqlStats = "SELECT " +
                              "  COUNT(*) as total, " +
                              "  SUM(CASE WHEN r.reservation_date >= CURRENT_DATE() THEN 1 ELSE 0 END) as upcoming, " +
                              "  SUM(CASE WHEN r.reservation_date < CURRENT_DATE() THEN 1 ELSE 0 END) as completed " +
                              "FROM reservations r WHERE r.user_id = ?";
                              
            try (PreparedStatement ps = conn.prepareStatement(sqlStats)) {
                ps.setString(1, loggedInUserId); // Memasukkan ID Nombor (cth: 1) ke query
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalEvents = rs.getInt("total");
                        upcomingEvents = rs.getInt("upcoming");
                        completedEvents = rs.getInt("completed");
                    }
                }
            }
            
            // 🌟 2. AMBIL MAXIMUM 5 ACARA TERBAHARU MILIK CUSTOMER INI (user_id = ?)
            String sqlRecent = "SELECT r.id, r.event_name, h.name AS hall_name, r.reservation_date, r.start_time, r.end_time " +
                               "FROM reservations r " +
                               "LEFT JOIN halls h ON r.hall_id = h.id " +
                               "WHERE r.user_id = ? " +
                               "ORDER BY r.id DESC LIMIT 5";
                               
            try (PreparedStatement ps = conn.prepareStatement(sqlRecent)) {
                ps.setString(1, loggedInUserId); // Memasukkan ID Nombor (cth: 1) ke query
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> event = new HashMap<>();
                        event.put("id", String.valueOf(rs.getInt("id")));
                        event.put("name", rs.getString("event_name") != null ? rs.getString("event_name") : "No Name");
                        event.put("venue", rs.getString("hall_name") != null ? rs.getString("hall_name") : "Unknown Hall");
                        event.put("date", rs.getString("reservation_date") != null ? rs.getString("reservation_date") : "-");
                        
                        String timeStr = "-";
                        if (rs.getString("start_time") != null) {
                            timeStr = rs.getString("start_time") + " - " + rs.getString("end_time");
                        }
                        event.put("time", timeStr);
                        
                        recentEvents.add(event);
                    }
                }
            }
        }
        
        // 🌟 3. BINA RESPONS JSON YANG DIFAHAMI OLEH cust_dashboard.js
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"success\": true,");
        json.append("\"totalEvents\": ").append(totalEvents).append(",");
        json.append("\"upcomingEvents\": ").append(upcomingEvents).append(",");
        json.append("\"completedEvents\": ").append(completedEvents).append(",");
        json.append("\"recentEvents\": [");
        
        for (int i = 0; i < recentEvents.size(); i++) {
            Map<String, String> event = recentEvents.get(i);
            json.append("{");
            json.append("\"id\": \"").append(event.get("id")).append("\",");
            json.append("\"name\": \"").append(escapeJson(event.get("name"))).append("\",");
            json.append("\"venue\": \"").append(escapeJson(event.get("venue"))).append("\",");
            json.append("\"date\": \"").append(event.get("date")).append("\",");
            json.append("\"time\": \"").append(event.get("time")).append("\"");
            json.append("}");
            if (i < recentEvents.size() - 1) json.append(",");
        }
        json.append("]}");
        
        out.print(json.toString());
        return;
        
    } catch (Exception e) {
        e.printStackTrace();
        out.print("{\"success\": false, \"message\": \"Database error: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        return;
    }
%><%!
    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
%>