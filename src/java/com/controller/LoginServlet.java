/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.controller;

import com.DAO.UserDAO;
import com.model.User;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;        // KUKUHKAN: Pastikan 'javax' (Tomcat 9 ke bawah) atau 'jakarta' (Tomcat 10+)
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

//@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet LoginServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet LoginServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
         String username = request.getParameter("username");
        String password = request.getParameter("password");
    
        System.out.println("--> Cuba login - Username: [" + username + "] | Password: [" + password + "]");
    
        UserDAO userDAO = new UserDAO();
        User user = userDAO.validateUser(username, password);
    
        if (user != null) {
            System.out.println("--> LOGIN BERJAYA! ID: [" + user.getId() + "] | Role dari DB: [" + user.getRole() + "]");
        
            HttpSession session = request.getSession();
            
            // PEMBETULAN UTMA: Agihan data sesi yang jelas dan lengkap
            session.setAttribute("loggedInUserId", user.getId());          // Simpan ID (cth: 101) untuk Foreign Key DB
            session.setAttribute("loggedInUser", user.getName());          // Simpan Nama (cth: Ahmad) untuk paparan UI
            session.setAttribute("userRole", user.getRole());              // Simpan Role (cth: customer / staff)
        
            if ("staff".equalsIgnoreCase(user.getRole())) {
                System.out.println("--> Mengarah ke staff_dashboard.jsp");
                response.sendRedirect("staff_dashboard.jsp");
                return; 
            } else {
                System.out.println("--> Mengarah ke cust_dashboard.jsp");
                response.sendRedirect("cust_dashboard.jsp");
                return; 
            }
        } else {
            System.out.println("--> LOGIN GAGAL! Objek user adalah NULL dari UserDAO.");
        
            request.setAttribute("errorMsg", "Invalid username or password. Please try again.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
        
        
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
