/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.model;

/**
 *
 * @author BLADEKAZUMA
 */


import java.io.Serializable; // Wajib untuk standard POJO / Java Bean

public class Event implements Serializable {
    
    // ID Versi unik untuk fasa penyaliran bait (serialization stream)
    private static final long serialVersionUID = 3L; 

    private int id;
    private String name;
    private String description;
    private String date;
    private String time;
    private String status;
    private int userId; // Sebagai Foreign Key ke jadual 'users'
    private int hallId; // Sebagai Foreign Key ke jadual 'halls'

    // 1. Syarat Wajib Java Bean: No-Argument Constructor (Constructor Kosong)
    public Event() {}

    // 2. Constructor Penuh (Opsional untuk kemudahan instansiasi objek)
    public Event(int id, String name, String description, String date, String time, String status, int userId, int hallId) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.date = date;
        this.time = time;
        this.status = status;
        this.userId = userId;
        this.hallId = hallId;
    }

    // 3. Syarat Wajib Java Bean: Kumpulan Fungsi Getter & Setter
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }

    public String getTime() { return time; }
    public void setTime(String time) { this.time = time; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getHallId() { return hallId; }
    public void setHallId(int hallId) { this.hallId = hallId; }
}