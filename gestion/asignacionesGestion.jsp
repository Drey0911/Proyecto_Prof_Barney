<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>

<%-- 
     1. Recuperación de parámetros enviados.
     En este caso, el parámetro "id" corresponde al id del coordinador.
--%>
<c:set var="idCoordinador" value="${param.id}" />
<c:set var="rol" value="${param.rol}" />
<c:set var="nombreRol" value="${param.nombre_rol}" />
<c:set var="nombres" value="${param.nombres}" />

<%-- 
     2. Procesamiento del formulario para asignar director y evaluador (método POST).
        Se espera que el formulario envíe:
         - accion=asignar
         - anteproyectoId: el id del registro de anteproyecto a asignar
         - directorId: id del director seleccionado
         - evaluadorId: id del evaluador seleccionado
--%>
<c:if test="${pageContext.request.method eq 'POST'}">
    <c:set var="accion" value="${param.accion}" />
    <c:if test="${accion eq 'asignar'}">
        <sql:update dataSource="${trabajosdegradoBD}">
            UPDATE anteproyecto 
            SET id_director = ?, id_evaluador = ?, id_coordinador = ?
            WHERE id = ?
            <sql:param value="${param.directorId}" />
            <sql:param value="${param.evaluadorId}" />
            <sql:param value="${idCoordinador}" />
            <sql:param value="${param.anteproyectoId}" />
        </sql:update>
        <c:set var="successMessage" scope="session" value="Director y evaluador asignados correctamente." />
        <c:redirect url="asignacionesGestion.jsp?id=${idCoordinador}&rol=${rol}&nombre_rol=${nombreRol}&nombres=${nombres}" />
    </c:if>
</c:if>

<%-- 
     3. Consulta de los anteproyectos en versión 1 sin director, evaluador ni coordinador asignados
        pero que tienen recibo de pago.
--%>
<sql:query dataSource="${trabajosdegradoBD}" var="listaAnteproyectos">
    SELECT a.id,
           a.id_estudiante,
           a.id_idea,
           a.archivo_nombre,
           a.recibo_nombre,
           a.version,
           a.fecha_actu,
           i.nombre_idea,
           CONCAT(est.nombres, ' ', est.apellido1, ' ', est.apellido2) AS nombre_estudiante,
           CONCAT('Nombre: ', est.nombres, ' ', est.apellido1, ' ', est.apellido2, ' Documento: ', est.documento, ' Correo: ', est.correo, ' Telefono: ', est.telefono) AS info_estudiante,
            CONCAT(est2.nombres, ' ', est2.apellido1, ' ', est2.apellido2) AS nombre_estudiante2,
           CONCAT('Nombre: ', est2.nombres, ' ', est2.apellido1, ' ', est2.apellido2, ' Documento: ',est2.documento, ' Correo: ',est2.correo,' Telefono: ',est2.telefono) AS info_estudiante2
    FROM anteproyecto a
    JOIN ideas i ON a.id_idea = i.id
    JOIN usuarios est ON a.id_estudiante = est.id
    LEFT JOIN usuarios est2 ON a.id_estudiante2 = est2.id
    WHERE a.recibo_pago IS NOT NULL
    AND estado_calificacion_coordinador = 'Aprobado'
      AND a.version = 1
      AND a.id_director IS NULL
      AND a.id_evaluador IS NULL
      AND a.id_coordinador IS NOT NULL
    ORDER BY a.id_estudiante;
</sql:query>

<%-- 4. Consulta de los directores (rol = 4) --%>
<sql:query dataSource="${trabajosdegradoBD}" var="listaDirectores">
    SELECT id, CONCAT(nombres, ' ', apellido1, ' ', apellido2) AS nombre_completo
    FROM usuarios
    WHERE rol = 4
    ORDER BY nombres;
</sql:query>

<%-- 5. Consulta de los evaluadores (rol = 5) --%>
<sql:query dataSource="${trabajosdegradoBD}" var="listaEvaluadores">
    SELECT id, CONCAT(nombres, ' ', apellido1, ' ', apellido2) AS nombre_completo
    FROM usuarios
    WHERE rol = 5
    ORDER BY nombres;
</sql:query>

<%-- Limpiar las alertas del JS --%>
<c:if test="${not empty sessionScope.successMessage}">
    <c:set var="mostrarSuccess" value="${sessionScope.successMessage}" scope="page" />
    <c:remove var="successMessage" scope="session" />
</c:if>

<c:if test="${not empty sessionScope.errorMessage}">
    <c:set var="mostrarError" value="${sessionScope.errorMessage}" scope="page" />
    <c:remove var="errorMessage" scope="session" />
</c:if>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>UTS - Gestión de Anteproyecto</title>
    <link rel="stylesheet" href="../styles/estilos.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.3.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/buttons/2.4.1/css/buttons.dataTables.min.css">
    <style>
        .ancho-columna { min-width: 180px; }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark fixed-top">
        <div class="container">
            <a class="navbar-brand" href="#">
                <img src="../images/logoUTS.png" alt="UTS Logo" width="40" height="40" class="d-inline-block align-top">
                Gestion Trabajos de grado
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" 
                aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="../vistas/principal.jsp?id=${idCoordinador}&rol=${rol}&nombre_rol=${nombreRol}&nombres=${nombres}">
                            <i class="fas fa-home me-1"></i> Inicio
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#crud">
                            <i class="fa-solid fa-briefcase"></i> Gestion
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="../vistas/principal.jsp?id=${idCoordinador}&rol=${rol}&nombre_rol=${nombreRol}&nombres=${nombres}#about">
                            <i class="fas fa-info-circle me-1"></i> Importante
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="../logout.jsp">
                            <i class="fa-solid fa-sign-out-alt"></i> Cerrar Sesion
                        </a>
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
            <h1>Asignación de Docentes</h1>
            <p>Usuario: <c:out value="${nombres}" /></p>
            <a href="#crud" class="btn-exercise">
                <i class="fas fa-arrow-down me-2"></i>Asignar Docentes
            </a>
        </div>
    </section>
    
    <section id="crud" class="container mt-5">
        <h3 class="section-title">Listado de Anteproyectos para Asignar</h3>
        <div class="container mt-5 border shadow p-3 mb-5 bg-body-tertiary rounded">
            <div class="table-responsive">
                <table id="tablaAsignacion" class="table table-striped table-bordered">
                    <thead class="table-dark">
                        <tr>
                            <th>Versión</th>
                            <th class="ancho-columna">Estudiante #1</th>
                            <th class="ancho-columna">Estudiante #2</th>
                            <th class="ancho-columna">Idea</th>
                            <th class="ancho-columna">Anteproyecto</th>
                            <th class="ancho-columna">Recibo</th>
                            <th class="ancho-columna">Director</th>
                            <th class="ancho-columna">Evaluador</th>
                            <th class="ancho-columna">Ultima Actualizacion</th>
                            <th class="ancho-columna">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="ap" items="${listaAnteproyectos.rows}">
                            <tr>
                                <td class="text-center">Versión #<c:out value="${ap.version}" /></td>
                                <td>
                                    <button type="button" class="btn btn-success" data-bs-toggle="modal" data-bs-target="#gestionModal" 
                                            onclick="mostrarInformacion('Estudiante', '${ap.info_estudiante}')">
                                        ${ap.nombre_estudiante}
                                    </button>
                                </td>
                                   <td>
                                <button type="button" class="btn btn-${empty ap.nombre_estudiante2 ? 'secondary' : 'success'}" data-bs-toggle="modal" data-bs-target="#gestionModal" 
                                    onclick="mostrarInformacion('Estudiante2', '${empty ap.nombre_estudiante2 ? 'No Aplica' : ap.info_estudiante2}')">
                                    ${empty ap.nombre_estudiante2 ? 'No Aplica' : ap.nombre_estudiante2}
                                </button>
                            </td>
                                <td class="ancho-columna"><c:out value="${ap.nombre_idea}" /></td>
                                <td class="ancho-columna">
                                    <c:choose>
                                        <c:when test="${not empty ap.archivo_nombre}">
                                            <a href="../archivos/verArchivoAnteproyecto.jsp?idAnteproyecto=${ap.id}" class="btn btn-sm btn-outline-primary w-100" target="_blank">
                                                <c:out value="${ap.archivo_nombre}" />
                                            </a>
                                        </c:when>
                                        <c:otherwise>Sin archivo</c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="ancho-columna">
                                    <c:choose>
                                        <c:when test="${not empty ap.recibo_nombre}">
                                            <a href="../archivos/verReciboPago.jsp?idAnteproyecto=${ap.id}" class="btn btn-sm btn-outline-primary w-100" target="_blank">
                                                <c:out value="${ap.recibo_nombre}" />
                                            </a>
                                        </c:when>
                                        <c:otherwise>Sin recibo</c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="ancho-columna">
                                    <form id="formAsignacion_${ap.id}" method="post">
                                        <input type="hidden" name="accion" value="asignar" />
                                        <input type="hidden" name="anteproyectoId" value="${ap.id}" />
                                        <select name="directorId" class="form-select form-select-sm" required>
                                            <option value="">Seleccione Director</option>
                                            <c:forEach var="dir" items="${listaDirectores.rows}">
                                                <option value="${dir.id}">${dir.nombre_completo}</option>
                                            </c:forEach>
                                        </select>
                                </td>
                                <td class="ancho-columna">
                                        <select name="evaluadorId" class="form-select form-select-sm" required>
                                            <option value="">Seleccione Evaluador</option>
                                            <c:forEach var="eval" items="${listaEvaluadores.rows}">
                                                <option value="${eval.id}">${eval.nombre_completo}</option>
                                            </c:forEach>
                                        </select>
                                </td>
                                <td class="text-center">${ap.fecha_actu}</td>
                               <td class="ancho-columna">
    <button type="submit" class="btn btn-primary btn-sm mt-1 px-3">
        <i class="fas fa-user-plus me-1"></i> Asignar
    </button>
</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </section>
    
    <!-- Modal para información del estudiante -->
    <div class="modal fade" id="gestionModal" tabindex="-1" aria-labelledby="gestionModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="gestionModalLabel">Información del <span id="rolTitulo"></span></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <ul id="infoLista" class="list-group">
                        <!-- La información se insertará aquí dinámicamente -->
                    </ul>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
                </div>
            </div>
        </div>
    </div>

    <footer class="footer text-center">
        <div class="container">
            <div class="row">
                <div class="col-md-4 mb-4 mb-md-0">
                    <h5>Gestion UTS</h5>
                    <p class="footer-text">Página para la gestión y administración del proceso de propuestas de trabajo de grado.</p>
                </div>
                <div class="col-md-4 mb-4 mb-md-0">
                    <h5>Enlaces Útiles</h5>
                    <ul class="list-unstyled">
                        <li><a href="https://www.uts.edu.co/sitio/" class="text-white-50">Página principal UTS</a></li>
                        <li><a href="https://www.uts.edu.co/sitio/modalidad-trabajos-de-grado/" class="text-white-50">Modalidades</a></li>
                        <li><a href="https://www.uts.edu.co/sitio/atencion-al-ciudadano/" class="text-white-50">Atención al ciudadano</a></li>
                    </ul>
                </div>
                <div class="col-md-4">
                    <h5>Redes</h5>
                    <div class="mt-3">
                        <a href="https://github.com/Drey0911" class="text-white me-3">
                            <i class="fab fa-github fa-lg"></i>
                        </a>
                        <a href="https://www.facebook.com/UnidadesTecnologicasdeSantanderUTS/" class="text-white me-3">
                            <i class="fab fa-facebook fa-lg"></i>
                        </a>
                        <a href="https://www.instagram.com/unidades_uts/" class="text-white me-3">
                            <i class="fab fa-instagram fa-lg"></i>
                        </a>
                        <a href="https://www.youtube.com/channel/UC-rIi4OnN0R10Wp-cPiLcpQ" class="text-white">
                            <i class="fab fa-youtube fa-lg"></i>
                        </a>
                    </div>
                </div>
                  <div class="row mt-4">
<hr class="my-4 bg-light opacity-25">
          <p class="footer-text mb-0">© 2025 Andrey Stteven Mantilla Leon Todos los derechos reservados.</p>
            </div>
        </div>
    </footer>
    
    <!-- Scripts -->
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.4.1/js/dataTables.buttons.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.html5.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>

    <script>
    function mostrarInformacion(rol, informacion) {
        document.getElementById('rolTitulo').textContent = rol;
        const lista = document.getElementById('infoLista');
        lista.innerHTML = '';
        
        // Procesar la cadena de información
        const partes = informacion.split(' ');
        let items = [];
        let currentItem = '';
        
        for (let i = 0; i < partes.length; i++) {
            if (partes[i].endsWith(':')) {
                if (currentItem !== '') {
                    items.push(currentItem.trim());
                }
                currentItem = partes[i] + ' ';
            } else {
                currentItem += partes[i] + ' ';
            }
        }
        if (currentItem !== '') {
            items.push(currentItem.trim());
        }
        
        // Crear elementos de lista
        items.forEach(item => {
            const li = document.createElement('li');
            li.className = 'list-group-item';
            li.textContent = item;
            lista.appendChild(li);
        });
    }
    
    $(document).ready(function () {
        $('#tablaAsignacion').DataTable({
            "language": {
                "url": "https://cdn.datatables.net/plug-ins/1.11.5/i18n/Spanish.json"
            }
        });

        <c:if test="${not empty mostrarSuccess}">
            Swal.fire({
                title: '¡Éxito!',
                text: '${mostrarSuccess}',
                icon: 'success',
                confirmButtonColor: '#0c7025',
                confirmButtonText: 'Aceptar'
            });
        </c:if>
        <c:if test="${not empty mostrarError}">
            Swal.fire({
                title: 'Error',
                text: '${mostrarError}',
                icon: 'error',
                confirmButtonColor: '#d33',
                confirmButtonText: 'Aceptar'
            });
        </c:if>
    });
    </script>
</body>
</html>