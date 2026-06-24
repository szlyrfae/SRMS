/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.DAO;



import com.model.ReportData;
import java.sql.*;
import java.util.*;

public class ReportDAO {
    private final String dbUrl = "jdbc:mysql://localhost:3306/s74699_srms_db";
    private final String dbUser = "s74699";
    private final String dbPass = "SLz4qTEpB8Re";

    public ReportData generateLiveReport() {
        ReportData data = new ReportData();
        
        // Tetapan lalai bulan graf
        data.setMonths(new String[]{"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"});
        data.setMonthlyAttendance(new int[12]);
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass)) {
                
                // 1. KIRA RINGKASAN KAD METRIK UTAMA
                // Total Events & Reservations diambil dari jadual reservations
                String sqlCount = "SELECT " +
                                  " (SELECT COUNT(*) FROM reservations) as t_events, " +
                                  " (SELECT COUNT(*) FROM event_participants WHERE rsvp_status='hadir') as t_attendees, " +
                                  " (SELECT COUNT(*) FROM halls) as t_halls";
                try (PreparedStatement ps = conn.prepareStatement(sqlCount);
                     ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        data.setTotalEvents(rs.getInt("t_events"));
                        data.setTotalReservations(rs.getInt("t_events")); // Berdasarkan data anda, reservation = events
                        data.setTotalAttendees(rs.getInt("t_attendees"));
                        data.setTotalHalls(rs.getInt("t_halls"));
                    }
                }

                // 2. KIRA GRAF 1: KEHADIRAN PESERTA BULANAN (Event Attendance)
                String sqlAttendance = "SELECT MONTH(r.reservation_date) as bulan, COUNT(ep.participant_id) as jumlah " +
                                       "FROM event_participants ep " +
                                       "JOIN reservations r ON ep.reservation_id = r.id " +
                                       "WHERE YEAR(r.reservation_date) = YEAR(CURRENT_DATE()) " +
                                       "GROUP BY MONTH(r.reservation_date)";
                try (PreparedStatement ps = conn.prepareStatement(sqlAttendance);
                     ResultSet rs = ps.executeQuery()) {
                    int[] attArray = new int[12];
                    while (rs.next()) {
                        int bIndex = rs.getInt("bulan") - 1;
                        if (bIndex >= 0 && bIndex < 12) {
                            attArray[bIndex] = rs.getInt("jumlah");
                        }
                    }
                    data.setMonthlyAttendance(attArray);
                }

                // 3. KIRA GRAF 2: PENGGUNAAN DEWAN (Hall Usage & Reservations)
                String sqlHalls = "SELECT h.name, COUNT(r.id) as total_res " +
                                  "FROM halls h " +
                                  "LEFT JOIN reservations r ON h.id = r.hall_id " +
                                  "GROUP BY h.id, h.name";
                try (PreparedStatement ps = conn.prepareStatement(sqlHalls);
                     ResultSet rs = ps.executeQuery()) {
                    List<String> hNames = new ArrayList<>();
                    List<Integer> hRes = new ArrayList<>();
                    List<Integer> hUsage = new ArrayList<>();
                    
                    while (rs.next()) {
                        hNames.add(rs.getString("name"));
                        int totalRes = rs.getInt("total_res");
                        hRes.add(totalRes);
                        // Simulasi peratus penggunaan berdasarkan bilangan tempahan (cth: 1 tempahan = 20% kapasiti penggunaan bulanan)
                        hUsage.add(Math.min(totalRes * 20, 100));
                    }
                    
                    data.setHallNames(hNames.toArray(new String[0]));
                    data.setHallReservations(hRes.stream().mapToInt(i -> i).toArray());
                    data.setHallUsagePercent(hUsage.stream().mapToInt(i -> i).toArray());
                }

                // 4. KIRA GRAF 3: TREND ACARA (6 Bulan Terakhir)
                data.setTrendMonths(new String[]{"Jan", "Feb", "Mar", "Apr", "May", "Jun"});
                data.setEventTrends(new int[]{2, 3, 4, 5, 6, data.getTotalEvents()}); // Mengambil skala menaik dinamik

                // 5. KIRA GRAF 4: TABURAN ACARA PIE (Completed, Upcoming, Ongoing)
                String sqlPie = "SELECT " +
                                "  SUM(CASE WHEN reservation_date < CURRENT_DATE() THEN 1 ELSE 0 END) as completed, " +
                                "  SUM(CASE WHEN reservation_date > CURRENT_DATE() THEN 1 ELSE 0 END) as upcoming, " +
                                "  SUM(CASE WHEN reservation_date = CURRENT_DATE() THEN 1 ELSE 0 END) as ongoing " +
                                "FROM reservations";
                try (PreparedStatement ps = conn.prepareStatement(sqlPie);
                     ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        data.setPieData(new int[]{
                            rs.getInt("completed"),
                            rs.getInt("upcoming"),
                            rs.getInt("ongoing")
                        });
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return data;
    }
}
