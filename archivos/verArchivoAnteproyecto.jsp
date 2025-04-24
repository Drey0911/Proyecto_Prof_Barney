<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.io.*" %>
<%
    String id = request.getParameter("idAnteproyecto");
    if (id != null && !id.isEmpty()) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/trabajosdegradobd", "root", "");

            String sql = "SELECT archivo, archivo_nombre, archivo_tipo FROM anteproyecto WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(id));
            rs = pstmt.executeQuery();

            if (rs.next()) {
                String nombre = rs.getString("archivo_nombre");
                String tipo = rs.getString("archivo_tipo");
                Blob archivo = rs.getBlob("archivo");

                response.setContentType(tipo);
                response.setHeader("Content-Disposition", "inline; filename=\"" + nombre + "\"");
                response.setContentLength((int) archivo.length());

InputStream in = archivo.getBinaryStream();
OutputStream outputStream = response.getOutputStream(); 
byte[] buffer = new byte[4096];
int bytesRead;

while ((bytesRead = in.read(buffer)) != -1) {
    outputStream.write(buffer, 0, bytesRead);
}

in.close();
outputStream.flush();
outputStream.close();

            } else {
                out.println("<h3>Archivo no encontrado</h3>");
            }
        } catch (Exception e) {
            out.println("<h3>Error: " + e.getMessage() + "</h3>");
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    } else {
        out.println("<h3>ID no proporcionado</h3>");
    }
%>
