<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.model.Hall" %>
<%
    
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    
    out.clear(); 
    
    String action = request.getParameter("action");
    
    // DB CONFIGURATION
    String dbUrl = "jdbc:mysql://localhost:3306/s74699_srms_db";
    String dbUser = "s74699";
    String dbPass = "SLz4qTEpB8Re"; 
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
        
        // -----------------------------------------------------------------
        // CASE 1: RETRIEVE ALL DATA (SELECT)
        // -----------------------------------------------------------------
        if ("getAll".equals(action)) {
            List<Hall> hallList = new ArrayList<>();
            String sql = "SELECT * FROM halls ORDER BY id ASC";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Hall hall = new Hall();
                hall.setId(rs.getInt("id"));
                hall.setName(rs.getString("name"));
                hall.setCapacity(rs.getInt("capacity"));
                hall.setLocation(rs.getString("location"));
                hall.setStatus(rs.getString("status"));
                hallList.add(hall);
            }
            
            // Bina struktur JSON berdasarkan koleksi rekod dari Model List
            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"halls\":[");
            for (int i = 0; i < hallList.size(); i++) {
                Hall h = hallList.get(i);
                json.append("{");
                json.append("\"id\":\"").append(h.getId()).append("\",");
                json.append("\"name\":\"").append(escapeJson(h.getName())).append("\",");
                json.append("\"capacity\":\"").append(h.getCapacity()).append("\",");
                json.append("\"location\":\"").append(escapeJson(h.getLocation())).append("\",");
                json.append("\"status\":\"").append(escapeJson(h.getStatus())).append("\"");
                json.append("}");
                if (i < hallList.size() - 1) json.append(",");
            }
            json.append("]}");
            out.print(json.toString());
            
        // -----------------------------------------------------------------
        // CASE 2: INSERT NEW DATA
        // -----------------------------------------------------------------
        } else if ("add".equals(action)) {
            String name = request.getParameter("name");
            int capacity = Integer.parseInt(request.getParameter("capacity"));
            String location = request.getParameter("location");
            String status = request.getParameter("status");
            
            String sql = "INSERT INTO halls (name, capacity, location, status) VALUES (?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, name);
            pstmt.setInt(2, capacity);
            pstmt.setString(3, location);
            pstmt.setString(4, status);
            
            int rowsInserted = pstmt.executeUpdate();
            if (rowsInserted > 0) {
                out.print("{\"success\":true}");
            } else {
                out.print("{\"success\":false,\"message\":\"Failed to insert records\"}");
            }
            
        // -----------------------------------------------------------------
        // CASE 3: UPDATE DATA
        // -----------------------------------------------------------------
        } else if ("update".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String name = request.getParameter("name");
            int capacity = Integer.parseInt(request.getParameter("capacity"));
            String location = request.getParameter("location");
            String status = request.getParameter("status");
            
            String sql = "UPDATE halls SET name=?, capacity=?, location=?, status=? WHERE id=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, name);
            pstmt.setInt(2, capacity);
            pstmt.setString(3, location);
            pstmt.setString(4, status);
            pstmt.setInt(5, id);
            
            int rowsUpdated = pstmt.executeUpdate();
            if (rowsUpdated > 0) {
                out.print("{\"success\":true}");
            } else {
                out.print("{\"success\":false,\"message\":\"Hall record ID not found or data identical\"}");
            }
            
        // -----------------------------------------------------------------
        // CASE 4: DELETE DATA
        // -----------------------------------------------------------------
        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            
            String sql = "DELETE FROM halls WHERE id=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            
            int rowsDeleted = pstmt.executeUpdate();
            if (rowsDeleted > 0) {
                out.print("{\"success\":true}");
            } else {
                out.print("{\"success\":false,\"message\":\"Record already deleted\"}");
            }
            
        } else {
            out.print("{\"success\":false,\"message\":\"Invalid controller action\"}");
        }
        
    } catch (Exception e) {
        out.print("{\"success\":false,\"message\":\"Database Error: " + escapeJson(e.getMessage()) + "\"}");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>
<%!
    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
%>