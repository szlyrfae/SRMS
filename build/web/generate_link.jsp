<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.util.UUID" %>
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
    
    // Base URL for your application
    String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();
    
    if ("generate".equals(action)) {
        String uniqueId = UUID.randomUUID().toString().substring(0, 8);
        String generatedLink = "";
        
        if ("registration".equals(type)) {
            generatedLink = baseUrl + "/register_attendee.jsp?eventId=" + eventId + "&code=" + uniqueId;
            session.setAttribute("regLink_" + eventId, generatedLink);
        } else if ("attendance".equals(type)) {
            generatedLink = baseUrl + "/mark_attendance.jsp?eventId=" + eventId + "&code=" + uniqueId;
            session.setAttribute("attLink_" + eventId, generatedLink);
        }
        
        out.print("{\"success\": true, \"link\": \"" + generatedLink + "\"}");
        
    } else if ("regenerate".equals(action)) {
        String uniqueId = UUID.randomUUID().toString().substring(0, 8);
        String generatedLink = "";
        
        if ("registration".equals(type)) {
            generatedLink = baseUrl + "/register_attendee.jsp?eventId=" + eventId + "&code=" + uniqueId;
            session.setAttribute("regLink_" + eventId, generatedLink);
        } else if ("attendance".equals(type)) {
            generatedLink = baseUrl + "/mark_attendance.jsp?eventId=" + eventId + "&code=" + uniqueId;
            session.setAttribute("attLink_" + eventId, generatedLink);
        }
        
        out.print("{\"success\": true, \"link\": \"" + generatedLink + "\"}");
        
    } else if ("getAttendees".equals(action)) {
        // Get attendees from session
        List<Map<String, String>> attendees = (List<Map<String, String>>) session.getAttribute("attendees_" + eventId);
        
        if (attendees == null) {
            attendees = new ArrayList<>();
        }
        
        StringBuilder json = new StringBuilder();
        json.append("{\"success\": true, \"attendees\": [");
        
        for (int i = 0; i < attendees.size(); i++) {
            Map<String, String> attendee = attendees.get(i);
            json.append("{");
            json.append("\"name\":\"").append(escapeJson(attendee.get("name"))).append("\",");
            json.append("\"phone\":\"").append(escapeJson(attendee.get("phone"))).append("\",");
            json.append("\"email\":\"").append(escapeJson(attendee.get("email"))).append("\",");
            json.append("\"status\":\"").append(escapeJson(attendee.get("status"))).append("\"");
            json.append("}");
            if (i < attendees.size() - 1) json.append(",");
        }
        
        json.append("]}");
        out.print(json.toString());
    }
%>
<%!
    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
%>