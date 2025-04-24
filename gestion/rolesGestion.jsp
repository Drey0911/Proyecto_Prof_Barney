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
  <title>UTS - Gestión de Roles</title>
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
            <a class="nav-link" href="../vistas/principal.jsp?id=${param.id}&rol=${param.rol}&nombre_rol=${param.nombre_rol}&nombres=${param.nombres}"><i class="fas fa-home me-1"></i> Inicio</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="#crud"><i class="fa-solid fa-briefcase"></i> Gestion</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="../vistas/principal.jsp?id=${param.id}&rol=${param.rol}&nombre_rol=${param.nombre_rol}&nombres=${param.nombres}#about"><i class="fas fa-info-circle me-1"></i> Importante</a>
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
  <i class="fas fa-arrow-down me-2"></i>Gestionar Roles
</a>
    </div>
  </section>

<%-- Procesar operaciones CRUD --%>
<c:if test="${not empty param.form_action}">
    <c:choose>
        <%-- Insertar rol --%>
        <c:when test="${param.form_action eq 'add'}">
            <sql:update dataSource="${trabajosdegradoBD}">
                INSERT INTO roles (nombre_rol, funciones)
                VALUES (?, ?)
                <sql:param value="${param.form_nombre_rol}" />
                <sql:param value="${param.form_funciones}" />
            </sql:update>
            <c:set var="mensaje" value="Rol agregado correctamente" scope="session"  />
            <c:set var="tipo" value="success" scope="session"  />
        </c:when>
        
        <%-- Actualizar rol --%>
        <c:when test="${param.form_action eq 'edit'}">
            <sql:update dataSource="${trabajosdegradoBD}">
                UPDATE roles 
                SET nombre_rol = ?, funciones = ?
                WHERE id_rol = ?
                <sql:param value="${param.form_nombre_rol}" />
                <sql:param value="${param.form_funciones}" />
                <sql:param value="${param.form_id_rol}" />
            </sql:update>
            <c:set var="mensaje" value="Rol actualizado correctamente" scope="session" />
            <c:set var="tipo" value="success" scope="session" />
        </c:when>
        
        <%-- Eliminar rol --%>
        <c:when test="${param.form_action eq 'delete'}">
            <%-- Verificar si el rol está en uso --%>
            <sql:query dataSource="${trabajosdegradoBD}" var="usuariosConRol">
                SELECT COUNT(*) as total FROM usuarios WHERE rol = ?
                <sql:param value="${param.form_id_rol}" />
            </sql:query>
            
            <c:choose>
                <c:when test="${usuariosConRol.rows[0].total > 0}">
                    <c:set var="mensaje" value="No se puede eliminar el rol porque está asignado a uno o más usuarios. Elimine o reasigne esos usuarios primero." scope="session" />
                    <c:set var="tipo" value="error" scope="session" />
                </c:when>
                <c:otherwise>
                    <sql:update dataSource="${trabajosdegradoBD}">
                        DELETE FROM roles WHERE id_rol = ?
                        <sql:param value="${param.form_id_rol}" />
                    </sql:update>
                    <c:set var="mensaje" value="Rol eliminado correctamente" scope="session" />
                    <c:set var="tipo" value="success" scope="session" />
                </c:otherwise>
            </c:choose>
        </c:when>

    </c:choose>
<c:url var="redirectUrl" value="rolesGestion.jsp">
 <c:if test="${not empty param.id}">
        <c:param name="id" value="${param.id}"/>
    </c:if>
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

        <c:remove var="mensaje" scope="session" />
        <c:remove var="tipo" scope="session" />
    </script>
  </c:if>

<section id="crud" >
    <div class="container mt-5">
        <h2 class="section-title">Gestión de Roles</h2>
            <div class="container mt-5 border shadow p-3 mb-5 bg-body-tertiary rounded">
        <div class="table-responsive">
            <table id="rolesTable" class="table table-striped table-bordered">
                <thead class="table-dark">
                    <tr>
                        <th>ID</th>
                        <th>Nombre del Rol</th>
                        <th>Funciones</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <%-- Consulta para obtener roles y contar usuarios asociados --%>
                    <sql:query dataSource="${trabajosdegradoBD}" var="roles">
                        SELECT id_rol, nombre_rol, funciones FROM roles ORDER BY id_rol ASC;
                    </sql:query>
                    <c:forEach var="rol" items="${roles.rows}">
                        <tr>
                            <td>${rol.id_rol}</td>
                            <td>${rol.nombre_rol}</td>
                            <td>${rol.funciones}</td>
                            <td>
                                <div class="btn-group">
                                    <button class="btn btn-warning btn-sm edit-btn" 
                                        data-id="${rol.id_rol}" 
                                        data-nombre="${rol.nombre_rol}" 
                                        data-funciones="${rol.funciones}">
                                         <i class="fas fa-edit me-1"></i> 
                                    </button>
                                    <button class="btn btn-danger btn-sm delete-btn" 
                                        data-id="${rol.id_rol}">
                                         <i class="fas fa-trash-alt me-1"></i> 
                                    </button>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
        <br>
        <button class="btn btn-success mt-3" id="addRoleBtn">Agregar Rol</button>
    </div>
     </div>

    <!-- Modal para agregar/editar rol -->
    <div class="modal fade" id="gestionModal" tabindex="-1" aria-labelledby="gestionModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <form id="roleForm" method="post">
                    <div class="modal-header">
                        <h5 class="modal-title" id="gestionModalLabel">Agregar Rol</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="form_id_rol" id="roleId">
                        <input type="hidden" name="form_action" id="action" value="add">
                        <div class="mb-3">
                            <label for="form_nombre_rol" class="form-label">Nombre del Rol</label>
                            <input type="text" class="form-control" id="form_nombre_rol" name="form_nombre_rol" required>
                        </div>
                        <div class="mb-3">
                            <label for="form_funciones" class="form-label">Funciones</label>
                            <textarea class="form-control" id="form_funciones" name="form_funciones" rows="3" required></textarea>
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
            $('#rolesTable').DataTable({
                "language": {
                    "url": "https://cdn.datatables.net/plug-ins/1.11.5/i18n/Spanish.json"
                }
            });
        });
            
            // Mostrar SweetAlert si hay un mensaje después de operación CRUD
            <c:if test="${not empty mensaje}">
                Swal.fire({
                    title: '${tipo == "success" ? "¡Éxito!" : "Error"}',
                    text: "${mensaje}",
                    icon: "${tipo}",
                    confirmButtonColor: '#0c7025',
                    confirmButtonText: 'Aceptar'
                });
            </c:if>
            
            // Botón para agregar rol
            document.getElementById('addRoleBtn').addEventListener('click', function() {
                document.getElementById('gestionModalLabel').textContent = 'Agregar Rol';
                document.getElementById('roleForm').reset();
                document.getElementById('action').value = 'add';
                document.getElementById('roleId').value = '';
                
                const modal = new bootstrap.Modal(document.getElementById('gestionModal'));
                modal.show();
            });
            
            // Botones para editar rol
            document.querySelectorAll('.edit-btn').forEach(button => {
                button.addEventListener('click', function() {
                    const id = this.getAttribute('data-id');
                    const nombre = this.getAttribute('data-nombre');
                    const funciones = this.getAttribute('data-funciones');
                    
                    document.getElementById('gestionModalLabel').textContent = 'Editar Rol';
                    document.getElementById('roleId').value = id;
                    document.getElementById('form_nombre_rol').value = nombre;
                    document.getElementById('form_funciones').value = funciones;
                    document.getElementById('action').value = 'edit';
                    
                    const modal = new bootstrap.Modal(document.getElementById('gestionModal'));
                    modal.show();
                });
            });
            
            // Confirmación para eliminar rol con SweetAlert2
            document.querySelectorAll('.delete-btn').forEach(button => {
                button.addEventListener('click', function() {
                    const id = this.getAttribute('data-id');
                    const usuariosAsignados = parseInt(this.getAttribute('data-usuarios'));
                    
                    if (usuariosAsignados > 0) {
                        Swal.fire({
                            title: 'No se puede eliminar',
                            text: `Este rol tiene ${usuariosAsignados} usuario(s) asignado(s). Debe reasignar estos usuarios antes de eliminar el rol.`,
                            icon: 'warning',
                            confirmButtonColor: '#0c7025',
                            confirmButtonText: 'Entendido'
                        });
                        return;
                    }
                    
                    Swal.fire({
                        title: '¿Está seguro?',
                        text: "Esta acción no se puede revertir",
                        icon: 'warning',
                        showCancelButton: true,
                        confirmButtonColor: '#0c7025',
                        cancelButtonColor: '#d33',
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
                            idInput.name = 'form_id_rol';
                            idInput.value = id;
                            
                            form.appendChild(actionInput);
                            form.appendChild(idInput);
                            document.body.appendChild(form);
                            
                            form.submit();
                        }
                    });
                });
            });
            
            // Manejar envío del formulario
            document.getElementById('roleForm').addEventListener('submit', function(event) {
                event.preventDefault();
                
                // Validación básica del formulario
                const nombreRol = document.getElementById('form_nombre_rol').value.trim();
                const funciones = document.getElementById('form_funciones').value.trim();
                
                if (!nombreRol || !funciones) {
                    Swal.fire({
                        title: 'Error',
                        text: 'Por favor complete todos los campos requeridos',
                        icon: 'error',
                        confirmButtonColor: '#0c7025',
                        confirmButtonText: 'Aceptar'
                    });
                    return;
                }
                
                // Enviar el formulario
                this.submit();
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
          <div class="row mt-4">
<hr class="my-4 bg-light opacity-25">
          <p class="footer-text mb-0">© 2025 Andrey Stteven Mantilla Leon Todos los derechos reservados.</p>
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