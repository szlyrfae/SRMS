<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%><%@ page import="java.util.*" %><%@ page import="java.sql.*" %><%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    out.clear(); 
    
    String action = request.getParameter("action");
    String dbUrl = "jdbc:mysql://localhost:3306/s74699_srms_db";
    String dbUser = "s74699";
    String dbPass = "SLz4qTEpB8Re"; 
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
        
        if ("getAll".equals(action)) {
            String sql = "SELECT id, name, role FROM users WHERE LOWER(role) = 'staff' ORDER BY id ASC";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"staff\":[");
            boolean first = true;
            while (rs.next()) {
                if (!first) json.append(",");
                json.append("{");
                json.append("\"id\":\"").append(rs.getString("id")).append("\",");
                json.append("\"name\":\"").append(escapeJson(rs.getString("name"))).append("\",");
                json.append("\"role\":\"").append(escapeJson(rs.getString("role"))).append("\"");
                json.append("}");
                first = false;
            }
            json.append("]}");
            out.print(json.toString());
            
        } else if ("add".equals(action)) {
            // PEMBETULAN: Ambil ID manual dari request parameter
            String id = request.getParameter("id");
            String name = request.getParameter("name");
            String password = request.getParameter("password");
            String role = request.getParameter("role");
            
            // Masukkan 4 parameter sepadan dengan tabel database users anda
            String sql = "INSERT INTO users (id, name, password, role) VALUES (?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, id);
            pstmt.setString(2, name);
            pstmt.setString(3, password);
            pstmt.setString(4, role);
            
            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                out.print("{\"success\":true}");
            } else {
                out.print("{\"success\":false,\"message\":\"Failed to insert staff records\"}");
            }
            
        } else if ("update".equals(action)) {
            String id = request.getParameter("id");
            String name = request.getParameter("name");
            String password = request.getParameter("password");
            
            String sql = "UPDATE users SET name=?, password=? WHERE id=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, name);
            pstmt.setString(2, password);
            pstmt.setString(3, id);
            
            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                out.print("{\"success\":true}");
            } else {
                out.print("{\"success\":false,\"message\":\"No changes made\"}");
            }
            
        } else if ("delete".equals(action)) {
            String id = request.getParameter("id");
            
            String sql = "DELETE FROM users WHERE id=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, id);
            
            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                out.print("{\"success\":true}");
            } else {
                out.print("{\"success\":false,\"message\":\"Failed to delete records\"}");
            }
        }
    } catch (Exception e) {
        out.print("{\"success\":false,\"message\":\"Database Error: " + escapeJson(e.getMessage()) + "\"}");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%><%!
    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
%>