<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="../styles/estilos.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.3.0/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
     <!-- CSS de DataTables -->
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css">
<link rel="stylesheet" href="https://cdn.datatables.net/buttons/2.4.1/css/buttons.dataTables.min.css">
  <title>UTS - Trabajos de grado</title>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark fixed-top">
    <div class="container">
      <a class="navbar-brand" href="#">
        <img src="../images/logoUTS.png" alt="UTS Logo" width="40" height="40" class="d-inline-block align-top">
       Gestion Trabajos de grado
      </a>
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav ms-auto">
          <li class="nav-item">
            <a class="nav-link" href="../vistas/principal.jsp?rol=${param.rol}&nombre_rol=${param.nombre_rol}&nombres=${param.nombres}"><i class="fas fa-home me-1"></i> Inicio</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="#crud"><i class="fa-solid fa-briefcase"></i> Gestion</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="../vistas/principal.jsp?rol=${param.rol}&nombre_rol=${param.nombre_rol}&nombres=${param.nombres}#about"><i class="fas fa-info-circle me-1"></i> Importante</a>
          </li>
            <li class="nav-item">
            <a class="nav-link" href="../logout.jsp"><i class="fa-solid fa-sign-out-alt"></i> Cerrar Sesion</a>
            </li>
        </ul>
      </div>
    </div>
  </nav>

  <section class="hero text-center">
    <div class="container hero-content">
      <div class="logo-container floating">
        <img src="../images/logoUTScompleto.png" alt="UTS Logo">
      </div>
      <h1>Gestion de Roles</h1>
      <p>Usuario: <c:out value="${param.nombres}" /></p>
<a href="#crud" class="btn-exercise">
  <i class="fas fa-arrow-down me-2"></i>Gestionar Usuarios
</a>
    </div>
  </section>

  <%-- Procesar operaciones CRUD directamente--%>
  <c:if test="${not empty param.form_action}">
    <c:choose>
      <%-- Insertar usuario --%>
      <c:when test="${param.form_action eq 'add'}">
        <sql:update dataSource="${trabajosdegradoBD}">
          INSERT INTO usuarios (nombres, apellido1, apellido2, documento, pass, correo, telefono,  rol, estadoLogin)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0)
          <sql:param value="${param.form_nombres}" />
          <sql:param value="${param.form_apellido1}" />
          <sql:param value="${param.form_apellido2}" />
          <sql:param value="${param.form_documento}" />
          <sql:param value="${param.form_pass}" />
          <sql:param value="${param.form_correo}" />
          <sql:param value="${param.form_telefono}" />
          <sql:param value="${param.form_rol}" />
        </sql:update>
        <c:set var="mensaje" value="Usuario agregado correctamente" scope="session" />
        <c:set var="tipo" value="success" scope="session" />
      </c:when>

      <%-- Actualizar usuario --%>
      <c:when test="${param.form_action eq 'edit'}">
        <sql:update dataSource="${trabajosdegradoBD}">
          UPDATE usuarios 
          SET nombres = ?, apellido1 = ?, apellido2 = ?, documento = ?, pass = ?, correo = ?, telefono = ?, rol = ?
          WHERE id = ?
          <sql:param value="${param.form_nombres}" />
          <sql:param value="${param.form_apellido1}" />
          <sql:param value="${param.form_apellido2}" />
          <sql:param value="${param.form_documento}" />
          <sql:param value="${param.form_pass}" />
          <sql:param value="${param.form_correo}" />
          <sql:param value="${param.form_telefono}" />
          <sql:param value="${param.form_rol}" />
          <sql:param value="${param.form_id}" />
        </sql:update>
        <c:set var="mensaje" value="Usuario actualizado correctamente" scope="session" />
        <c:set var="tipo" value="success" scope="session" />
      </c:when>

      <%-- Eliminar usuario --%>
      <c:when test="${param.form_action eq 'delete'}">
        <sql:update dataSource="${trabajosdegradoBD}">
          DELETE FROM usuarios WHERE id = ?
          <sql:param value="${param.form_id}" />
        </sql:update>
        <c:set var="mensaje" value="Usuario eliminado correctamente" scope="session" />
        <c:set var="tipo" value="success" scope="session" />
      </c:when>
      
    </c:choose>
<c:url var="redirectUrl" value="usuariosGestion.jsp">
    <c:if test="${not empty param.nombre_rol}">
        <c:param name="nombre_rol" value="${param.nombre_rol}"/>
    </c:if>
    <c:if test="${not empty param.nombres}">
        <c:param name="nombres" value="${param.nombres}"/>
    </c:if>
    <c:if test="${not empty param.rol}">
        <c:param name="rol" value="${param.rol}"/>
    </c:if>
</c:url>

<c:redirect url="${redirectUrl}#crud"/>

  </c:if>

  <%-- Mostrar mensaje de operación si existe --%>
  <c:if test="${not empty sessionScope.mensaje}">
    <script>
      window.addEventListener('load', function() {
        Swal.fire({
          title: '${sessionScope.tipo == "success" ? "¡Éxito!" : "Error"}',
          text: "${sessionScope.mensaje}",
          icon: "${sessionScope.tipo}",
          confirmButtonColor: '#0c7025',
          confirmButtonText: 'Aceptar'
        });
      });
        // Clear session variables after showing the alert
        <c:remove var="mensaje" scope="session" />
        <c:remove var="tipo" scope="session" />
    </script>
  </c:if>

<section id="crud" >
    <div class="container mt-5">
        <h2 class="section-title">Gestión de Usuarios</h2>
                    <div class="container mt-5 border shadow p-3 mb-5 bg-body-tertiary rounded">
        <div class="table-responsive">
            <table id="usuariosTable" class="table table-striped table-bordered">
                <thead class="table-dark">
                    <tr>
                        <th>ID</th>
                        <th>Nombres</th>
                        <th>Apellido 1</th>
                        <th>Apellido 2</th>
                        <th>Documento</th>
                        <th>Correo</th>
                        <th>Telefono</th>
                        <th>Rol</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <%-- Consulta para obtener usuarios con sus roles, excluyendo administradores (rol=1) --%>
                    <sql:query dataSource="${trabajosdegradoBD}" var="usuarios">
                        SELECT u.id, u.nombres, u.apellido1, u.apellido2, u.documento,u.correo,u.telefono, r.nombre_rol, u.pass, u.rol 
                        FROM usuarios u
                        JOIN roles r ON u.rol = r.id_rol
                        WHERE u.rol != 1;
                    </sql:query>
                    <c:forEach var="usuario" items="${usuarios.rows}">
                        <tr>
                            <td>${usuario.id}</td>
                            <td>${usuario.nombres}</td>
                            <td>${usuario.apellido1}</td>
                            <td>${usuario.apellido2}</td>
                            <td>${usuario.documento}</td>
                            <td>${usuario.correo}</td>
                            <td>${usuario.telefono}</td>
                            <td>${usuario.nombre_rol}</td>
                            <td>
                    <button class="btn btn-warning btn-sm edit-btn" 
                        data-id="${usuario.id}" 
                        data-nombres="${usuario.nombres}" 
                        data-apellido1="${usuario.apellido1}" 
                        data-apellido2="${usuario.apellido2}" 
                        data-documento="${usuario.documento}"
                        data-correo="${usuario.correo}"
                        data-telefono="${usuario.telefono}"
                        data-pass="${usuario.pass}"
                        data-rol="${usuario.rol}">
                        <i class="fas fa-edit me-1"></i> 
                    </button>
                    <button class="btn btn-danger btn-sm delete-btn" data-id="${usuario.id}">
                        <i class="fas fa-trash-alt me-1"></i> 
                    </button>
                </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
        <br>
        <button class="btn btn-success mt-3" id="addUserBtn">Agregar Usuario</button>
    </div>
     </div>

    <!-- Modal para agregar/editar usuario -->
    <div class="modal fade" id="gestionModal" tabindex="-1" aria-labelledby="gestionModalLabel" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <form id="userForm" method="post">
            <div class="modal-header">
              <h5 class="modal-title" id="gestionModalLabel">Agregar Usuario</h5>
              <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
              <input type="hidden" name="form_id" id="userId">
              <input type="hidden" name="form_action" id="action" value="add">
              <div class="mb-3">
                <label for="form_nombres" class="form-label">Nombres</label>
                <input type="text" class="form-control" id="form_nombres" name="form_nombres" required>
              </div>
              <div class="mb-3">
                <label for="form_apellido1" class="form-label">Apellido 1</label>
                <input type="text" class="form-control" id="form_apellido1" name="form_apellido1" required>
              </div>
              <div class="mb-3">
                <label for="form_apellido2" class="form-label">Apellido 2</label>
                <input type="text" class="form-control" id="form_apellido2" name="form_apellido2" required>
              </div>
              <div class="mb-3">
                <label for="form_documento" class="form-label">Documento</label>
                <input type="text" class="form-control" id="form_documento" name="form_documento" required>
              </div>
                <div class="mb-3">
                <label for="form_correo" class="form-label">Correo</label>
                <input type="email" class="form-control" id="form_correo" name="form_correo" required>
              </div>
                <div class="mb-3">
                <label for="form_telefono" class="form-label">Telefono</label>
                <input type="text" class="form-control" id="form_telefono" name="form_telefono" required>
              </div>
              <div class="mb-3">
                <label for="form_pass" class="form-label">Contraseña</label>
                <input type="password" class="form-control" id="form_pass" name="form_pass" required>
              </div>
              <div class="mb-3">
                <label for="form_rol" class="form-label">Rol</label>
                <select class="form-select" id="form_rol" name="form_rol" required>
                  <option value="" disabled selected>Seleccione un rol</option>
                  <%-- Consulta para obtener roles, excluyendo administrador (id_rol=1) --%>
                  <sql:query dataSource="${trabajosdegradoBD}" var="roles">
                    SELECT id_rol, nombre_rol FROM roles WHERE id_rol != 1;
                  </sql:query>
                  <c:forEach var="rol" items="${roles.rows}">
                    <option value="${rol.id_rol}">${rol.nombre_rol}</option>
                  </c:forEach>
                </select>
              </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
              <button type="submit" class="btn btn-success">Guardar</button>
            </div>
          </form>
        </div>
      </div>
    </div>


<!-- jQuery y JS de DataTables -->
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/buttons/2.4.1/js/dataTables.buttons.min.js"></script>
<script src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.html5.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>


    <!-- Incluir SweetAlert2 -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    
    <!-- Incluir Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Inicializar DataTable
 $(document).ready(function() {
            $('#usuariosTable').DataTable({
                "language": {
                    "url": "https://cdn.datatables.net/plug-ins/1.11.5/i18n/Spanish.json"
                }
            });
        });

            // Botón para agregar usuario
            document.getElementById('addUserBtn').addEventListener('click', function() {
                document.getElementById('gestionModalLabel').textContent = 'Agregar Usuario';
                document.getElementById('userForm').reset();
                document.getElementById('action').value = 'add';
                document.getElementById('userId').value = '';
                const modal = new bootstrap.Modal(document.getElementById('gestionModal'));
                modal.show();
            });

            // Botones para editar usuario
            document.querySelectorAll('.edit-btn').forEach(button => {
                button.addEventListener('click', function() {
                    const id = this.getAttribute('data-id');
                    const nombres = this.getAttribute('data-nombres');
                    const apellido1 = this.getAttribute('data-apellido1');
                    const apellido2 = this.getAttribute('data-apellido2');
                    const documento = this.getAttribute('data-documento');
                    const correo = this.getAttribute('data-correo');
                    const telefono = this.getAttribute('data-telefono');
                    const pass = this.getAttribute('data-pass');
                    const rol = this.getAttribute('data-rol');

                    document.getElementById('gestionModalLabel').textContent = 'Editar Usuario';
                    document.getElementById('userId').value = id;
                    document.getElementById('form_nombres').value = nombres;
                    document.getElementById('form_apellido1').value = apellido1;
                    document.getElementById('form_apellido2').value = apellido2;
                    document.getElementById('form_documento').value = documento;
                    document.getElementById('form_correo').value = correo;
                    document.getElementById('form_telefono').value = telefono;
                    document.getElementById('form_pass').value = pass;
                    document.getElementById('action').value = 'edit';

                    // Seleccionar el rol correcto en el dropdown
                    const rolSelect = document.getElementById('form_rol');
                    for (let i = 0; i < rolSelect.options.length; i++) {
                        if (rolSelect.options[i].value === rol) {
                            rolSelect.selectedIndex = i;
                            break;
                        }
                    }

                    const modal = new bootstrap.Modal(document.getElementById('gestionModal'));
                    modal.show();
                });
            });

            // Confirmación para eliminar usuario con SweetAlert2
            document.querySelectorAll('.delete-btn').forEach(button => {
                button.addEventListener('click', function() {
                    const id = this.getAttribute('data-id');

                    Swal.fire({
                        title: '¿Está seguro?',
                        text: "Esta acción no se puede revertir",
                        icon: 'warning',
                        showCancelButton: true,
                        confirmButtonColor: '#3085d6',
                        cancelButtonColor: '#d33',
                        confirmButtonColor: '#0c7025',
                        confirmButtonText: 'Sí, eliminar',
                        cancelButtonText: 'Cancelar'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            // Crear un formulario oculto para enviar la acción de eliminación
                            const form = document.createElement('form');
                            form.method = 'POST';
                            form.style.display = 'none';

                            const actionInput = document.createElement('input');
                            actionInput.type = 'hidden';
                            actionInput.name = 'form_action';
                            actionInput.value = 'delete';

                            const idInput = document.createElement('input');
                            idInput.type = 'hidden';
                            idInput.name = 'form_id';
                            idInput.value = id;

                            form.appendChild(actionInput);
                            form.appendChild(idInput);
                            document.body.appendChild(form);

                            form.submit();
                        }
                    });
                });
            });
        });
    </script>
</section>

 <footer class="footer text-center">
    <div class="container">
      <div class="row">
        <div class="col-md-4 mb-4 mb-md-0">
          <h5>Gestion UTS</h5>
          <p class="footer-text">Pagina para la gestion y administracion del proceso de propuestas de trabajo de grado.</p>
        </div>
        <div class="col-md-4 mb-4 mb-md-0">
          <h5>Enlaces Útiles</h5>
          <ul class="list-unstyled">
            <li><a href="https://www.uts.edu.co/sitio/" class="text-white-50">Pagina principal UTS</a></li>
            <li><a href="https://www.uts.edu.co/sitio/modalidad-trabajos-de-grado/" class="text-white-50">Modalidades</a></li>
            <li><a href="https://www.uts.edu.co/sitio/atencion-al-ciudadano/" class="text-white-50">Atencion al ciudadano</a></li>
          </ul>
        </div>
        <div class="col-md-4">
          <h5>Redes</h5>
          <div class="mt-3">
            <a href="https://github.com/Drey0911" class="text-white me-3"><i class="fab fa-github fa-lg"></i></a>
            <a href="https://www.facebook.com/UnidadesTecnologicasdeSantanderUTS/" class="text-white me-3"><i class="fab fa-facebook fa-lg"></i></a>
            <a href="https://www.instagram.com/unidades_uts/" class="text-white me-3"><i class="fab fa-instagram fa-lg"></i></a>
            <a href="https://www.youtube.com/channel/UC-rIi4OnN0R10Wp-cPiLcpQ" class="text-white"><i class="fab fa-youtube fa-lg"></i></a>
          </div>
        </div>
      </div>

  <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/2.9.2/umd/popper.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.3.0/js/bootstrap.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  <script>
    
    // Back to top button
    window.addEventListener('scroll', function() {
      var backToTopButton = document.getElementById('backToTop');
      if (window.pageYOffset > 300) {
        backToTopButton.classList.add('show');
      } else {
        backToTopButton.classList.remove('show');
      }
    });
    
    document.getElementById('backToTop').addEventListener('click', function(e) {
      e.preventDefault();
      window.scrollTo({top: 0, behavior: 'smooth'});
    });
    
    // Smooth scrolling for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', function (e) {
        e.preventDefault();
        
        document.querySelector(this.getAttribute('href')).scrollIntoView({
          behavior: 'smooth'
        });
      });
    });
  </script>
</body>
</html>