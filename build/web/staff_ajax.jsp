<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    String action = request.getParameter("action");
    
    // Get staff from session
    List<Map<String, String>> staffList = (List<Map<String, String>>) session.getAttribute("staffList");
    if (staffList == null) {
        staffList = new ArrayList<>();
    }
    
    if ("getAll".equals(action)) {
        // Build JSON manually
        StringBuilder json = new StringBuilder();
        json.append("{\"success\":true,\"staff\":[");
        
        for (int i = 0; i < staffList.size(); i++) {
            Map<String, String> staff = staffList.get(i);
            json.append("{");
            json.append("\"id\":\"").append(escapeJson(staff.get("id"))).append("\",");
            json.append("\"name\":\"").append(escapeJson(staff.get("name"))).append("\",");
            json.append("\"position\":\"").append(escapeJson(staff.get("position"))).append("\",");
            json.append("\"email\":\"").append(escapeJson(staff.get("email"))).append("\",");
            json.append("\"phone\":\"").append(escapeJson(staff.get("phone"))).append("\",");
            json.append("\"status\":\"").append(escapeJson(staff.get("status"))).append("\"");
            json.append("}");
            if (i < staffList.size() - 1) json.append(",");
        }
        
        json.append("]}");
        out.print(json.toString());
        
    } else if ("add".equals(action)) {
        String name = request.getParameter("name");
        String position = request.getParameter("position");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String status = request.getParameter("status");
        
        // Generate new ID
        int newId = staffList.size() + 1;
        
        Map<String, String> newStaff = new HashMap<>();
        newStaff.put("id", String.valueOf(newId));
        newStaff.put("name", name);
        newStaff.put("position", position);
        newStaff.put("email", email);
        newStaff.put("phone", phone);
        newStaff.put("status", status);
        
        staffList.add(newStaff);
        session.setAttribute("staffList", staffList);
        
        out.print("{\"success\":true}");
        
    } else if ("update".equals(action)) {
        String id = request.getParameter("id");
        String name = request.getParameter("name");
        String position = request.getParameter("position");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String status = request.getParameter("status");
        
        for (Map<String, String> staff : staffList) {
            if (staff.get("id").equals(id)) {
                staff.put("name", name);
                staff.put("position", position);
                staff.put("email", email);
                staff.put("phone", phone);
                staff.put("status", status);
                break;
            }
        }
        session.setAttribute("staffList", staffList);
        
        out.print("{\"success\":true}");
        
    } else if ("delete".equals(action)) {
        String id = request.getParameter("id");
        staffList.removeIf(staff -> staff.get("id").equals(id));
        session.setAttribute("staffList", staffList);
        
        out.print("{\"success\":true}");
        
    } else {
        out.print("{\"success\":false,\"message\":\"Invalid action\"}");
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