<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    String loggedInUser = (String) session.getAttribute("loggedInUser");
    
    if (loggedInUser == null) {
        out.print("{\"success\": false, \"message\": \"Not logged in\"}");
        return;
    }
    
    // Get events from session
    List<Map<String, String>> events = (List<Map<String, String>>) session.getAttribute("customerEvents_" + loggedInUser);
    if (events == null) {
        events = new ArrayList<>();
    }
    
    // Get attendees from all events
    int totalAttendees = 0;
    for (Map<String, String> event : events) {
        List<Map<String, String>> attendees = (List<Map<String, String>>) session.getAttribute("attendees_" + event.get("id"));
        if (attendees != null) {
            totalAttendees += attendees.size();
        }
    }
    
    // Count completed events (for demo, events with status "Completed")
    int completedEvents = 0;
    for (Map<String, String> event : events) {
        if ("Completed".equals(event.get("status"))) {
            completedEvents++;
        }
    }
    
    // Prepare recent events (last 5)
    List<Map<String, String>> recentEvents = new ArrayList<>();
    int start = Math.max(0, events.size() - 5);
    for (int i = events.size() - 1; i >= start; i--) {
        recentEvents.add(events.get(i));
    }
    
    // Build JSON response
    StringBuilder json = new StringBuilder();
    json.append("{");
    json.append("\"success\": true,");
    json.append("\"totalEvents\": ").append(events.size()).append(",");
    json.append("\"totalAttendees\": ").append(totalAttendees).append(",");
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
%>
<%!
    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
%>