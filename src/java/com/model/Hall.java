/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.model;

/**
 *
 * @author BLADEKAZUMA
 */


public class Hall {
    private int id;
    private String name;
    private int capacity;
    private String location;
    private String status;

    // Constructor Kosong
    public Hall() {}

    // Constructor Penuh
    public Hall(int id, String name, int capacity, String location, String status) {
        this.id = id;
        this.name = name;
        this.capacity = capacity;
        this.location = location;
        this.status = status;
    }

    // Getter dan Setter
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public int getCapacity() { return capacity; }
    public void setCapacity(int capacity) { this.capacity = capacity; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
