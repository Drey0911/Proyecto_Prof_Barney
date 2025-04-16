<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Clear all session attributes
    session.removeAttribute("id");
    session.removeAttribute("documento");
    session.removeAttribute("nombres");
    session.removeAttribute("apellido1");
    session.removeAttribute("apellido2");
    session.removeAttribute("rol");
    session.removeAttribute("nombre_rol");

    // Redirect to index.jsp with LOGOUT parameter
    response.sendRedirect("index.jsp?LOGOUT");
%>
