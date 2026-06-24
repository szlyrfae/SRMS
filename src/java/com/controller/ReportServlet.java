package com.controller;

import com.DAO.ReportDAO;
import com.model.ReportData;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

//@WebServlet("/ReportServlet")
public class ReportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String loggedInUser = (String) session.getAttribute("loggedInUser");
        String userRole = (String) session.getAttribute("userRole");

        // Sekatan keselamatan peranan portal staf
        if (loggedInUser == null || !"staff".equalsIgnoreCase(userRole)) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Jalankan tarikan database
        ReportDAO reportDAO = new ReportDAO();
        ReportData reportData = reportDAO.generateLiveReport();

        // Letakkan objek di dalam Request Scope
        request.setAttribute("reportData", reportData);

        // Majukan pergerakan ke paparan report.jsp
        request.getRequestDispatcher("report.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}