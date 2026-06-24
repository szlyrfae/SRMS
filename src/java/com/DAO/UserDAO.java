/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.DAO;

/**
 *
 * @author BLADEKAZUMA
 */


import com.model.User;
import java.sql.*;

public class UserDAO {
    private String dbURL = "jdbc:mysql://localhost:3306/s74699_srms_db";
    private String dbUser = "s74699";
    private String dbPass = "SLz4qTEpB8Re";

    private Connection getConnection() throws ClassNotFoundException, SQLException {
         Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(dbURL, dbUser, dbPass);
    }

    // 1. Fungsi Semak Login
    public User validateUser(String username, String password) {
        String sql = "SELECT id, name, role FROM users WHERE id = ? AND password = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, username);
            ps.setString(2, password);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setId(rs.getString("id"));
                    user.setName(rs.getString("name"));
                    user.setRole(rs.getString("role"));
                    return user;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // 2. Fungsi Daftar Akaun Customer Baru
    public boolean registerCustomer(User user) {
        String checkSql = "SELECT id FROM users WHERE id = ?";
        String insertSql = "INSERT INTO users (id, password, name, role) VALUES (?, ?, ?, 'customer')";
        
        try (Connection conn = getConnection()) {
            // Semak jika username sudah wujud
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setString(1, user.getId());
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next()) return false; // Username bertindih
                }
            }
            
            // Jalankan simpanan akaun baharu
            try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                insertPs.setString(1, user.getId());
                insertPs.setString(2, user.getPassword());
                insertPs.setString(3, user.getName());
                int rows = insertPs.executeUpdate();
                return rows > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}