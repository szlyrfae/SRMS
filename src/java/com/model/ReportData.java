/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.model;



import java.util.List;
import java.util.Map;

public class ReportData {
    private int totalEvents;
    private int totalAttendees;
    private int totalHalls;
    private int totalReservations;
    
    // Tatasusunan untuk Graf Chart.js
    private int[] monthlyAttendance;
    private String[] months;
    
    private int[] hallReservations;
    private int[] hallUsagePercent;
    private String[] hallNames;
    
    private int[] eventTrends;
    private String[] trendMonths;
    
    private int[] pieData; // Index 0: Completed, 1: Upcoming, 2: Ongoing

    // Getters and Setters
    public int getTotalEvents() { return totalEvents; }
    public void setTotalEvents(int totalEvents) { this.totalEvents = totalEvents; }

    public int getTotalAttendees() { return totalAttendees; }
    public void setTotalAttendees(int totalAttendees) { this.totalAttendees = totalAttendees; }

    public int getTotalHalls() { return totalHalls; }
    public void setTotalHalls(int totalHalls) { this.totalHalls = totalHalls; }

    public int getTotalReservations() { return totalReservations; }
    public void setTotalReservations(int totalReservations) { this.totalReservations = totalReservations; }

    public int[] getMonthlyAttendance() { return monthlyAttendance; }
    public void setMonthlyAttendance(int[] monthlyAttendance) { this.monthlyAttendance = monthlyAttendance; }

    public String[] getMonths() { return months; }
    public void setMonths(String[] months) { this.months = months; }

    public int[] getHallReservations() { return hallReservations; }
    public void setHallReservations(int[] hallReservations) { this.hallReservations = hallReservations; }

    public int[] getHallUsagePercent() { return hallUsagePercent; }
    public void setHallUsagePercent(int[] hallUsagePercent) { this.hallUsagePercent = hallUsagePercent; }

    public String[] getHallNames() { return hallNames; }
    public void setHallNames(String[] hallNames) { this.hallNames = hallNames; }

    public int[] getEventTrends() { return eventTrends; }
    public void setEventTrends(int[] eventTrends) { this.eventTrends = eventTrends; }

    public String[] getTrendMonths() { return trendMonths; }
    public void setTrendMonths(String[] trendMonths) { this.trendMonths = trendMonths; }

    public int[] getPieData() { return pieData; }
    public void setPieData(int[] pieData) { this.pieData = pieData; }
}
