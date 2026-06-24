<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.util.UUID" %>
<%@ page import="java.sql.*" %>  ```
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    String action = request.getParameter("action");
    String type = request.getParameter("type");
    String eventId = request.getParameter("eventId");
    
    if (action == null || type == null || eventId == null) {
        out.print("{\"success\": false, \"message\": \"Missing parameters\"}");
        return;
    }
    
    // Base URL untuk aplikasi
    String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();
    
    if ("generate".equals(action)) {
        String uniqueId = UUID.randomUUID().toString().substring(0, 8);
        String generatedLink = "";
        
        if ("registration".equals(type)) {
            generatedLink = baseUrl + "/RegistrationServlet?eventId=" + eventId + "&code=" + uniqueId;
            session.setAttribute("regLink_" + eventId, generatedLink);
        } else if ("attendance".equals(type)) {
            generatedLink = baseUrl + "/AttendanceServlet?eventId=" + eventId + "&code=" + uniqueId;
            session.setAttribute("attLink_" + eventId, generatedLink);
        }
        
        out.print("{\"success\": true, \"link\": \"" + generatedLink + "\"}");
        return; // 🚀 WAJIB ADA: Menghalang Java daripada terus membaca kod di bawah!
        
    } else if ("regenerate".equals(action)) {
        String uniqueId = UUID.randomUUID().toString().substring(0, 8);
        String generatedLink = "";
        
        if ("registration".equals(type)) {
            generatedLink = baseUrl + "/RegistrationServlet?eventId=" + eventId + "&code=" + uniqueId;
            session.setAttribute("regLink_" + eventId, generatedLink);
        } else if ("attendance".equals(type)) {
            generatedLink = baseUrl + "/AttendanceServlet?eventId=" + eventId + "&code=" + uniqueId;
            session.setAttribute("attLink_" + eventId, generatedLink);
        }
        
        out.print("{\"success\": true, \"link\": \"" + generatedLink + "\"}");
        return; // 🚀 WAJIB ADA: Menghalang Java daripada terus membaca kod di bawah!
        
    } else if ("getAttendees".equals(action)) {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String dbUrl = "jdbc:mysql://localhost:3306/s74699_srms_db";
        String dbUser = "s74699";
        String dbPass = "SLz4qTEpB8Re"; 
        
        StringBuilder json = new StringBuilder();
        String query = "SELECT p.name, p.phone_num, p.email, ep.rsvp_status " +
                       "FROM event_participants ep " +
                       "JOIN participants p ON ep.participant_id = p.id " +
                       "WHERE ep.reservation_id = ?";
        
        boolean hasData = false;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
                 PreparedStatement pstmt = conn.prepareStatement(query)) {
                
                pstmt.setInt(1, Integer.parseInt(eventId));
                
                try (ResultSet rs = pstmt.executeQuery()) {
                    json.append("{\"success\":true,\"attendees\":[");
                    while (rs.next()) {
                        if (hasData) {
                            json.append(",");
                        }
                        String pName = rs.getString("name") != null ? rs.getString("name").replace("\"", "\\\"") : "";
                        String pPhone = rs.getString("phone_num") != null ? rs.getString("phone_num").replace("\"", "\\\"") : "";
                        String pEmail = rs.getString("email") != null ? rs.getString("email").replace("\"", "\\\"") : "";
                        String pStatus = rs.getString("rsvp_status") != null ? rs.getString("rsvp_status").replace("\"", "\\\"") : "tak hadir";
                        
                        json.append("{");
                        json.append("\"name\":\"").append(pName).append("\",");
                        json.append("\"phone\":\"").append(pPhone).append("\",");
                        json.append("\"email\":\"").append(pEmail).append("\",");
                        json.append("\"status\":\"").append(pStatus).append("\"");
                        json.append("}");
                        hasData = true;
                    }
                    json.append("]}");
                }
            }
            out.print(json.toString());
            return;
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
            return;
        }
    }
%>
<%!
    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
%>