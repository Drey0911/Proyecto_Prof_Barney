<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");

    // Clear any existing parameters
    request.setAttribute("id", "");
    request.setAttribute("documento", "");
    request.setAttribute("nombres", "");
    request.setAttribute("apellido1", "");
    request.setAttribute("apellido2", "");
    request.setAttribute("rol", "");
    request.setAttribute("nombre_rol", "");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar Sesión - UTS</title>
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
    <!-- Sweet Alert 2 CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
    <style>
        /* Fondo con imagen y opacidad */
        body {
            background: url('images/fondologin.png') no-repeat center center fixed;
            background-size: cover;
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0;
            font-family: Arial, sans-serif;
        }

        /* Aplicar desenfoque solo a la imagen de fondo */
        body::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: inherit;
            background-size: inherit;
            filter: blur(4px);
            z-index: -1;
        }

        /* Contenedor centrado */
        .login-container {
            background: rgba(255, 255, 255, 0.9); /* Fondo blanco con opacidad */
            border-radius: 20px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
            padding: 50px;
            width: 100%;
            max-width: 400px;
            text-align: center;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        /* Hover del contenedor */
        .login-container:hover {
            transform: scale(1.05);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
        }

        /* Botón de ingresar */
        .btn-custom {
            background-color: #c1d631;
            color: white;
            border: none;
            padding: 10px 20px;
            font-size: 16px;
            border-radius: 5px;
            cursor: pointer;
            transition: transform 0.3s ease, background-color 0.3s ease;
        }

        /* Hover del botón */
        .btn-custom:hover {
            transform: scale(1.05);
            background-color: #a0b52f;
        }

        /* Responsividad */
        @media (max-width: 768px) {
            .login-container {
                padding: 30px;
                max-width: 90%;
            }
        }
    </style>
</head>
<body>
    <%-- SQL Query to validate login --%>
    <c:if test="${not empty param.documento and not empty param.pass}">
        <sql:query dataSource="${trabajosdegradoBD}" var="userCheck">
            SELECT u.id, u.documento, u.nombres, u.apellido1, u.apellido2, u.rol, r.nombre_rol, u.estadoLogin, 
                   TIMESTAMPDIFF(MINUTE, u.ultimoIntento, NOW()) as minutosPasados
            FROM usuarios u
            JOIN roles r ON u.rol = r.id_rol
            WHERE u.documento = ?
            <sql:param value="${param.documento}" />
        </sql:query>

        <c:choose>
            <c:when test="${userCheck.rowCount == 0}">
                <script>
                    window.addEventListener('load', function() {
                        Swal.fire({
                            icon: 'error',
                            title: 'Usuario no encontrado',
                            text: 'El documento ingresado no existe.',
                            confirmButtonColor: '#0c7025',
                            confirmButtonText: 'Intentar de nuevo'
                        });
                    });
                </script>
            </c:when>
            <c:otherwise>
                <c:set var="user" value="${userCheck.rows[0]}" />
                <c:choose>
                    <c:when test="${user.estadoLogin >= 3 && user.minutosPasados < 3}">
                        <script>
                            window.addEventListener('load', function() {
                                Swal.fire({
                                    icon: 'warning',
                                    title: 'Demasiados intentos fallidos',
                                    text: 'Espere 3 minutos antes de intentar nuevamente.',
                                    confirmButtonColor: '#0c7025',
                                    confirmButtonText: 'Entendido'
                                });
                            });
                        </script>
                    </c:when>
                    <c:otherwise>
                        <sql:query dataSource="${trabajosdegradoBD}" var="loginAttempt">
                            SELECT id FROM usuarios WHERE documento = ? AND pass = ?
                            <sql:param value="${param.documento}" />
                            <sql:param value="${param.pass}" />
                        </sql:query>

                        <c:choose>
                            <c:when test="${loginAttempt.rowCount > 0}">
                                <sql:update dataSource="${trabajosdegradoBD}">
                                    UPDATE usuarios SET estadoLogin = 0 WHERE id = ?
                                    <sql:param value="${user.id}" />
                                </sql:update>
                                <c:redirect url="vistas/principal.jsp">
                                    <c:param name="id" value="${user.id}" />
                                    <c:param name="documento" value="${user.documento}" />
                                    <c:param name="nombres" value="${user.nombres}" />
                                    <c:param name="apellido1" value="${user.apellido1}" />
                                    <c:param name="apellido2" value="${user.apellido2}" />
                                    <c:param name="rol" value="${user.rol}" />
                                    <c:param name="nombre_rol" value="${user.nombre_rol}" />
                                </c:redirect>
                            </c:when>
                            <c:otherwise>
                                <sql:update dataSource="${trabajosdegradoBD}">
                                    UPDATE usuarios SET estadoLogin = estadoLogin + 1, ultimoIntento = NOW() WHERE id = ?
                                    <sql:param value="${user.id}" />
                                </sql:update>
                                <script>
                                    window.addEventListener('load', function() {
                                        Swal.fire({
                                            icon: 'error',
                                            title: 'Error de Inicio de Sesión',
                                            text: 'Usuario o contraseña incorrectos.',
                                            confirmButtonColor: '#0c7025',
                                            confirmButtonText: 'Intentar de nuevo'
                                        });
                                    });
                                </script>
                            </c:otherwise>
                        </c:choose>
                    </c:otherwise>
                </c:choose>
            </c:otherwise>
        </c:choose>
    </c:if>

    <div class="container d-flex justify-content-center align-items-center" style="height: 100vh;">
        <div class="login-container text-center">
            <img src="images/logoUTS.png" alt="UTS Logo" class="mb-4" style="max-width: 100px;">
            <h2 class="mb-4">Iniciar Sesión</h2>
            <form id="loginForm" method="post" action="">
                <div class="form-group">
                    <label for="documento" class="text-left d-block">Documento</label>
                    <input type="text" class="form-control" id="documento" name="documento" 
                           placeholder="Ingrese su documento" required>
                </div>
                <div class="form-group">
                    <label for="pass" class="text-left d-block">Contraseña</label>
                    <input type="password" class="form-control" id="pass" name="pass" 
                           placeholder="Ingrese su contraseña" required>
                </div>
                <button type="submit" class="btn btn-custom btn-block">Ingresar</button>
            </form>
        </div>
    </div>

    <!-- jQuery -->
    <script src="https://cdn.jsdelivr.net/npm/jquery@3.5.1/dist/jquery.min.js"></script>
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Sweet Alert 2 -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.js"></script>
</body>
</html>