<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.io.*, java.sql.*, java.util.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");
    String idAnteproyecto = request.getParameter("idAnteproyecto");
    boolean actualizado = false;
        String nombreArchivoSubido = "";
    
    // Fixed return URL with the correct path
    String backUrl = "../gestion/anteproyectoGestion.jsp";
    
    // Add parameters to the back URL
    if (request.getParameter("idAnteproyecto") != null) {
        backUrl += "?idAnteproyecto=" + request.getParameter("idAnteproyecto");
    }
    if (request.getParameter("id") != null) {
        backUrl += (backUrl.contains("?") ? "&" : "?") + "id=" + request.getParameter("id");
    }
    if (request.getParameter("rol") != null) {
        backUrl += (backUrl.contains("?") ? "&" : "?") + "rol=" + request.getParameter("rol");
    }
    if (request.getParameter("nombre_rol") != null) {
        backUrl += (backUrl.contains("?") ? "&" : "?") + "nombre_rol=" + request.getParameter("nombre_rol");
    }
    if (request.getParameter("nombres") != null) {
        backUrl += (backUrl.contains("?") ? "&" : "?") + "nombres=" + request.getParameter("nombres");
    }

    if ("POST".equals(request.getMethod()) && ServletFileUpload.isMultipartContent(request)) {
        try {
            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletFileUpload upload = new ServletFileUpload(factory);
            List<FileItem> items = upload.parseRequest(request);

            byte[] datosArchivo = null;
            String nombreArchivo = "";
            String tipoArchivo = "";

            for (FileItem item : items) {
                if (!item.isFormField()) {
                    if (!item.getName().isEmpty()) {
                        nombreArchivo = new File(item.getName()).getName();
                        datosArchivo = item.get();
                        tipoArchivo = item.getContentType();
                    }
                }
            }
            
            // Only update if a file was selected
            if (datosArchivo != null && datosArchivo.length > 0) {
                Connection conn = ((javax.sql.DataSource) pageContext.getAttribute("trabajosdegradoBD")).getConnection();
                String updateSql = "UPDATE anteproyecto SET archivo = ?, archivo_nombre = ?, archivo_tipo = ? WHERE id = ?";
                PreparedStatement ps = conn.prepareStatement(updateSql);
                ps.setBytes(1, datosArchivo);
                ps.setString(2, nombreArchivo);
                ps.setString(3, tipoArchivo);
                ps.setInt(4, Integer.parseInt(idAnteproyecto));
                ps.executeUpdate();
                ps.close();
                conn.close();
                actualizado = true;
                nombreArchivoSubido = nombreArchivo;
            }
            
            // We'll handle the redirect in JavaScript after showing the notification
            if (actualizado) {
                session.setAttribute("mensaje_exito", "El recibo de pago fue adjuntado correctamente");
                // Not redirecting here, will do it after showing the notification
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Adjuntar Anteproyecto</title>
    <link rel="stylesheet" href="../styles/estilos.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.3.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary: rgb(111, 183, 62);
            --secondary: #c1d631;
            --accent: #c1d631;
            --light: #f8f9fa;
            --dark: rgb(131, 214, 49);
        }
        
        body {
            background-color: var(--light);
        }
        
        .card {
            border-radius: 15px;
            border: none;
            box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
        }
        
        .card-header {
            background-color: var(--primary);
            color: white;
            border-radius: 15px 15px 0 0 !important;
            padding: 1.5rem;
        }
        
        .btn-primary {
            background-color: var(--primary);
            border-color: var(--primary);
        }
        
        .btn-primary:hover {
            background-color: var(--dark);
            border-color: var(--dark);
        }
        
        .btn-secondary {
            background-color: #6c757d;
            border-color: #6c757d;
        }
        
        .btn-warning {
            background-color: var(--secondary);
            border-color: var(--secondary);
            color: #212529;
        }
        
        .btn-warning:hover {
            background-color: var(--accent);
            border-color: var(--accent);
            color: #212529;
        }
        
        .badge.bg-info {
            background-color: var(--primary) !important;
        }
        
        .file-upload-wrapper {
            position: relative;
            margin-bottom: 15px;
        }
        
        .file-upload-input {
            position: relative;
            z-index: 2;
            width: 100%;
            height: calc(3.5rem + 2px);
            margin: 0;
            opacity: 0;
        }
        
        .file-upload-text {
            position: absolute;
            top: 0;
            right: 0;
            left: 0;
            z-index: 1;
            height: calc(3.5rem + 2px);
            padding: 1rem 1rem;
            overflow: hidden;
            font-weight: 400;
            line-height: 1.5;
            color: #495057;
            background-color: #fff;
            border: 1px solid #ced4da;
            border-radius: 0.25rem;
            display: flex;
            align-items: center;
        }
        
        .file-upload-text i {
            margin-right: 10px;
            font-size: 1.2rem;
            color: var(--primary);
        }
        
        .current-file {
            padding: 15px;
            background-color: rgba(111, 183, 62, 0.1);
            border-radius: 8px;
            margin-bottom: 20px;
        }
        
        .current-file a {
            color: var(--primary);
            text-decoration: none;
            font-weight: 500;
        }
        
        .current-file a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
<div class="container mt-5">
    <div class="card shadow">
        <div class="card-header">
            <h2 class="text-center m-0">Adjuntar Anteproyecto</h2>
        </div>
        <div class="card-body p-4">
            <sql:query dataSource="${trabajosdegradoBD}" var="detalle">
                SELECT a.id, a.archivo_nombre, a.id_director, a.id_evaluador,
                       CONCAT(u1.nombres, ' ', u1.apellido1, ' ', u1.apellido2) AS nombre_director,
                       CONCAT(u2.nombres, ' ', u2.apellido1, ' ', u2.apellido2) AS nombre_evaluador
                FROM anteproyecto a
                LEFT JOIN usuarios u1 ON a.id_director = u1.id
                LEFT JOIN usuarios u2 ON a.id_evaluador = u2.id
                WHERE a.id = ?
                <sql:param value="${param.idAnteproyecto}" />
            </sql:query>

            <c:forEach var="ap" items="${detalle.rows}">
                <form method="post" enctype="multipart/form-data">
                    <div class="current-file mb-4">
                        <h5><i class="fas fa-file-pdf me-2"></i>Archivo actual:</h5>
                        <c:choose>
                            <c:when test="${not empty ap.archivo_nombre}">
                                <a href="verArchivoAnteproyecto.jsp?idAnteproyecto=${ap.id}" target="_blank">
                                    <i class="fas fa-download me-1"></i>${ap.archivo_nombre}
                                </a>
                            </c:when>
                            <c:otherwise>
                                <span class="text-muted">No hay archivo subido</span>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="mb-4">
                        <label class="form-label fw-bold">Nuevo archivo (PDF):</label>
                        <div class="file-upload-wrapper">
                            <input type="file" name="archivo" class="file-upload-input" accept="application/pdf" id="archivo">
                            <div class="file-upload-text">
                                <i class="fas fa-paperclip"></i>
                                <span id="file-chosen">Ningún archivo seleccionado, Clic aqui para agregar</span>
                            </div>
                        </div>
                    </div>
                    <div class="text-center mt-4">
                        <button type="submit" class="btn btn-warning btn-lg">
                            <i class="fas fa-paperclip me-2"></i>Adjuntar Archivo
                        </button>
                        <a href="<%= backUrl %>" class="btn btn-secondary btn-lg ms-2">
                            <i class="fas fa-times me-2"></i>Cancelar
                        </a>
                    </div>
                </form>
            </c:forEach>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
    // Update file input label when file is selected
    const actualFileInput = document.getElementById('archivo');
    const fileChosen = document.getElementById('file-chosen');

    actualFileInput.addEventListener('change', function() {
        if(this.files.length > 0) {
            fileChosen.textContent = this.files[0].name;
        } else {
            fileChosen.textContent = 'Ningún archivo seleccionado';
        }
    });
    
    <% if (actualizado) { %>
        Swal.fire({
            icon: 'success',
            title: '¡Actualizado!',
            text: 'Se Adjuntó el Anteproyecto: <%= nombreArchivoSubido %>',
            confirmButtonText: 'Aceptar',
            confirmButtonColor: 'rgb(111, 183, 62)',
            timer: 4000,  // Automatically close after 4 seconds
            timerProgressBar: true
        }).then(() => {
            window.location.href = '<%= backUrl %>';
        });
    <% } %>
</script>
</body>
</html>