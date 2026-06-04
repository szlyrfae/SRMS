<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    String action = request.getParameter("action");
    
    // Get halls from session
    List<Map<String, String>> halls = (List<Map<String, String>>) session.getAttribute("hallList");
    if (halls == null) {
        halls = new ArrayList<>();
    }
    
    if ("getAll".equals(action)) {
        // Build JSON manually
        StringBuilder json = new StringBuilder();
        json.append("{\"success\":true,\"halls\":[");
        
        for (int i = 0; i < halls.size(); i++) {
            Map<String, String> hall = halls.get(i);
            json.append("{");
            json.append("\"id\":\"").append(escapeJson(hall.get("id"))).append("\",");
            json.append("\"name\":\"").append(escapeJson(hall.get("name"))).append("\",");
            json.append("\"capacity\":\"").append(escapeJson(hall.get("capacity"))).append("\",");
            json.append("\"location\":\"").append(escapeJson(hall.get("location"))).append("\",");
            json.append("\"status\":\"").append(escapeJson(hall.get("status"))).append("\"");
            json.append("}");
            if (i < halls.size() - 1) json.append(",");
        }
        
        json.append("]}");
        out.print(json.toString());
        
    } else if ("add".equals(action)) {
        String name = request.getParameter("name");
        String capacity = request.getParameter("capacity");
        String location = request.getParameter("location");
        String status = request.getParameter("status");
        
        // Generate new ID
        int newId = halls.size() + 1;
        
        Map<String, String> newHall = new HashMap<>();
        newHall.put("id", String.valueOf(newId));
        newHall.put("name", name);
        newHall.put("capacity", capacity);
        newHall.put("location", location);
        newHall.put("status", status);
        
        halls.add(newHall);
        session.setAttribute("hallList", halls);
        
        out.print("{\"success\":true}");
        
    } else if ("update".equals(action)) {
        String id = request.getParameter("id");
        String name = request.getParameter("name");
        String capacity = request.getParameter("capacity");
        String location = request.getParameter("location");
        String status = request.getParameter("status");
        
        for (Map<String, String> hall : halls) {
            if (hall.get("id").equals(id)) {
                hall.put("name", name);
                hall.put("capacity", capacity);
                hall.put("location", location);
                hall.put("status", status);
                break;
            }
        }
        session.setAttribute("hallList", halls);
        
        out.print("{\"success\":true}");
        
    } else if ("delete".equals(action)) {
        String id = request.getParameter("id");
        halls.removeIf(hall -> hall.get("id").equals(id));
        session.setAttribute("hallList", halls);
        
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