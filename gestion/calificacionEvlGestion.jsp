<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>

<%-- 
     1. Recuperación de parámetros enviados.
     En este caso, el parámetro "id" corresponde al id del coordinador.
--%>
<c:set var="idEvaluador" value="${param.id}" />
<c:set var="rol" value="${param.rol}" />
<c:set var="nombreRol" value="${param.nombre_rol}" />
<c:set var="nombres" value="${param.nombres}" />

<%-- 
     2. Procesamiento del formulario de calificación enviado (método POST no multipart).
        Se espera que el formulario envíe:
         - accion=calificar
         - anteproyectoId: el id del registro de anteproyecto a calificar
         - id_estudiante: id del estudiante (para manejo extra si se requiere)
         - calificacion: valor seleccionado (Aprobado, No Aprobado o Con Cambios)
--%>
<c:if test="${pageContext.request.method eq 'POST' and not fn:contains(pageContext.request.contentType, 'multipart/form-data')}">
    <c:set var="accion" value="${param.accion}" />
    <c:if test="${accion eq 'calificar'}">
        <%-- Primero se consulta el registro para conocer el estado actual de las calificaciones --%>
        <sql:query dataSource="${trabajosdegradoBD}" var="anteRec">
            SELECT estado_calificacion_coordinador, estado_calificacion_director, estado_calificacion_evaluador
            FROM anteproyecto
            WHERE id = ?
            <sql:param value="${param.anteproyectoId}" />
        </sql:query>
        <c:choose>
            <%-- Si el estado de calificación del director está vacío, se actualiza ese campo --%>
            <c:when test="${empty anteRec.rows[0].estado_calificacion_evaluador}">
                <sql:update dataSource="${trabajosdegradoBD}">
                    UPDATE anteproyecto 
                    SET estado_calificacion_evaluador = ?
                    WHERE id = ?
                    <sql:param value="${param.calificacion}" />
                    <sql:param value="${param.anteproyectoId}" />
                </sql:update>
            </c:when>
            <%-- En cualquier otro caso (por ejemplo, no cumple la condición de todos Aprobados), se actualiza el estado del director --%>
            <c:otherwise>
                <sql:update dataSource="${trabajosdegradoBD}">
                    UPDATE anteproyecto 
                    SET estado_calificacion_evaluador = ?
                    WHERE id = ?
                    <sql:param value="${param.calificacion}" />
                    <sql:param value="${param.anteproyectoId}" />
                </sql:update>
            </c:otherwise>
        </c:choose>
        <c:set var="successMessage" scope="session" value="Calificación asignada correctamente." />
        <c:redirect url="calificacionEvlGestion.jsp?id=${idDirector}&rol=${rol}&nombre_rol=${nombreRol}&nombres=${nombres}" />
    </c:if>
</c:if>

<%-- 
     3. Consulta de los anteproyectos a mostrar:
         Se listan solamente la última versión de cada estudiante que cumpla:
         - Tener adjunto recibo de pago.
         - Y además, o bien aún no tienen “Aprobado” por coordinador,
           o tienen “Aprobado” en director, evaluador y coordinador pero sin valor en calificacion_total.
--%>
<sql:query dataSource="${trabajosdegradoBD}" var="listaAnteproyectos">
    SELECT a.id,
           a.id_estudiante,
           a.id_idea,
           a.archivo_nombre,
           a.recibo_nombre,
           a.version,
           a.estado_calificacion_director,
           a.estado_calificacion_evaluador,
           a.estado_calificacion_coordinador,
           a.calificacion_total,
           a.fecha_actu,
           i.nombre_idea,
           CONCAT(d.nombres, ' ', d.apellido1, ' ', d.apellido2) AS nombre_director,
           CONCAT(e.nombres, ' ', e.apellido1, ' ', e.apellido2) AS nombre_evaluador,
           CONCAT(c.nombres, ' ', c.apellido1, ' ', c.apellido2) AS nombre_coordinador,
           CONCAT(est.nombres, ' ', est.apellido1, ' ', est.apellido2) AS nombre_estudiante,
            CONCAT(est2.nombres, ' ', est2.apellido1, ' ', est2.apellido2) AS nombre_estudiante2,
           CONCAT('Nombre: ', est2.nombres, ' ', est2.apellido1, ' ', est2.apellido2, ' Documento: ',est2.documento, ' Correo: ',est2.correo,' Telefono: ',est2.telefono) AS info_estudiante2,
           CONCAT('Nombre: ', d.nombres, ' ', d.apellido1, ' ', d.apellido2, ' Documento: ', d.documento, ' Correo: ', d.correo, ' Telefono: ', d.telefono) AS info_director,
           CONCAT('Nombre: ', e.nombres, ' ', e.apellido1, ' ', e.apellido2, ' Documento: ', e.documento, ' Correo: ', e.correo, ' Telefono: ', e.telefono) AS info_evaluador,
           CONCAT('Nombre: ', c.nombres, ' ', c.apellido1, ' ', c.apellido2, ' Documento: ', c.documento, ' Correo: ', c.correo, ' Telefono: ', c.telefono) AS info_coordinador,
            CONCAT('Nombre: ', est.nombres, ' ', est.apellido1, ' ', est.apellido2, ' Documento: ', est.documento, ' Correo: ', est.correo, ' Telefono: ', est.telefono) AS info_estudiante
    FROM anteproyecto a
    JOIN ideas i ON a.id_idea = i.id
    JOIN usuarios est ON a.id_estudiante = est.id
    LEFT JOIN usuarios est2 ON a.id_estudiante2 = est2.id
    LEFT JOIN usuarios d ON a.id_director = d.id
    LEFT JOIN usuarios e ON a.id_evaluador = e.id
    LEFT JOIN usuarios c ON a.id_coordinador = c.id
    WHERE a.recibo_pago IS NOT NULL
    AND a.archivo IS NOT NULL
      AND a.version = (SELECT MAX(b.version) FROM anteproyecto b WHERE b.id_estudiante = a.id_estudiante)
      AND a.estado_calificacion_coordinador = 'Aprobado'
      AND a.estado_calificacion_director = 'Aprobado'
      AND a.estado_calificacion_evaluador <> 'Con Cambios'
      AND a.estado_calificacion_evaluador <> 'Aprobado'
      AND a.estado_calificacion_evaluador <> 'No Aprobado'
      AND a.id_evaluador = ?
    ORDER BY a.id_estudiante
    <sql:param value="${idEvaluador}" />
</sql:query>

<%-- limpiar las alertas del JS --%>
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
        <!-- CSS de DataTables -->
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
                        <a class="nav-link" href="../vistas/principal.jsp?id=${idEvaluador}&rol=${rol}&nombre_rol=${nombreRol}&nombres=${nombres}">
                            <i class="fas fa-home me-1"></i> Inicio
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#crud">
                            <i class="fa-solid fa-briefcase"></i> Gestion
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="../vistas/principal.jsp?id=${idEvaluador}&rol=${rol}&nombre_rol=${nombreRol}&nombres=${nombres}#about">
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
            <h1>Calificacion de Anteproyectos</h1>
            <p>Usuario: <c:out value="${nombres}" /></p>
            <a href="#crud" class="btn-exercise">
                <i class="fas fa-arrow-down me-2"></i>Calificar Anteproyectos
            </a>
        </div>
    </section>
            <h3 class="section-title">Listado de Anteproyectos a Calificar</h3>
    
    <section id="crud" class="container mt-5">
                                  <div class="container mt-5 border shadow p-3 mb-5 bg-body-tertiary rounded">

        
        <div class="table-responsive">
            <table id="tablaCalificacion" class="table table-striped table-bordered">
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
                        <th class="ancho-columna">Coordinador</th>
                        <th>Estado Director</th>
                        <th>Estado Evaluador</th>
                        <th>Estado Coordinador</th>
                        <th class="ancho-columna">Ultima Actualizacion</th>
                        <th>Calificación</th>
                        <th class="ancho-columna">Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="ap" items="${listaAnteproyectos.rows}">
                        <tr>
                            <td class="text-center">Versión #<c:out value="${ap.version}" /></td>
                                <td>
                                        <button type="button" class="btn btn-${empty ap.nombre_estudiante ? 'secondary' : 'success'}" data-bs-toggle="modal" data-bs-target="#gestionModal" 
                                                onclick="mostrarInformacion('Estudiante', '${empty ap.nombre_estudiante ? 'Pendiente' : ap.info_estudiante}')">
                                            ${empty ap.nombre_estudiante ? 'Pendiente' : ap.nombre_estudiante}
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
                                <td>
                                        <button type="button" class="btn btn-${empty ap.nombre_director ? 'secondary' : 'success'}" data-bs-toggle="modal" data-bs-target="#gestionModal" 
                                                onclick="mostrarInformacion('Director', '${empty ap.nombre_director ? 'Pendiente' : ap.info_director}')">
                                            ${empty ap.nombre_director ? 'Pendiente' : ap.nombre_director}
                                        </button>
                                </td>
                                <td>
                                        <button type="button" class="btn btn-${empty ap.nombre_evaluador ? 'secondary' : 'success'}" data-bs-toggle="modal" data-bs-target="#gestionModal" 
                                                onclick="mostrarInformacion('Evaluador', '${empty ap.nombre_evaluador ? 'Pendiente' : ap.info_evaluador}')">
                                            ${empty ap.nombre_evaluador ? 'Pendiente' : ap.nombre_evaluador}
                                        </button>
                                </td>
                                <td>
                                        <button type="button" class="btn btn-${empty ap.nombre_coordinador ? 'secondary' : 'success'}" data-bs-toggle="modal" data-bs-target="#gestionModal" 
                                                onclick="mostrarInformacion('Coordinador', '${empty ap.nombre_coordinador ? 'Pendiente' : ap.info_coordinador}')">
                                            ${empty ap.nombre_coordinador ? 'Pendiente' : ap.nombre_coordinador}
                                        </button>
                                </td>
                                             <td>
                                    <span class="badge bg-${ap.estado_calificacion_director eq 'Aprobado' ? 'success' : (ap.estado_calificacion_director eq 'No Aprobado' ? 'danger' : (ap.estado_calificacion_director eq 'Con Cambios' ? 'warning' : 'secondary'))}">
                                        ${empty ap.estado_calificacion_director ? 'Pendiente' : ap.estado_calificacion_director}
                                    </span>
                                </td>
                                <td>
                                    <span class="badge bg-${ap.estado_calificacion_evaluador eq 'Aprobado' ? 'success' : (ap.estado_calificacion_evaluador eq 'No Aprobado' ? 'danger' : (ap.estado_calificacion_evaluador eq 'Con Cambios' ? 'warning' : 'secondary'))}">
                                        ${empty ap.estado_calificacion_evaluador ? 'Pendiente' : ap.estado_calificacion_evaluador}
                                    </span>
                                </td>
                            <td>
                                    <span class="badge bg-${ap.estado_calificacion_coordinador eq 'Aprobado' ? 'success' : (ap.estado_calificacion_coordinador eq 'No Aprobado' ? 'danger' : (ap.estado_calificacion_coordinador eq 'Con Cambios' ? 'warning' : 'secondary'))}">
                                        ${empty ap.estado_calificacion_coordinador ? 'Pendiente' : ap.estado_calificacion_coordinador}
                                    </span>
                                </td>
                                <td class="text-center">${ap.fecha_actu}</td>
                                  <td>
                                    <span class="badge bg-${ap.calificacion_total eq 'Aprobado' ? 'success' : (ap.calificacion_total eq 'No Aprobado' ? 'danger' : (ap.calificacion_total eq 'Con Cambios' ? 'warning' : 'secondary'))}">
                                        ${empty ap.calificacion_total ? 'Pendiente' : ap.calificacion_total}
                                    </span>
                                </td>
                            <td>
                                <c:if test="${empty ap.calificacion_total}">
                                    <form method="post">
                                        <input type="hidden" name="accion" value="calificar" />
                                        <input type="hidden" name="anteproyectoId" value="${ap.id}" />
                                        <input type="hidden" name="id_estudiante" value="${ap.id_estudiante}" />
                                        <select name="calificacion" class="form-select form-select-sm" required>
                                            <option value="">Seleccione</option>
                                            <option value="Aprobado">Aprobado</option>
                                            <option value="No Aprobado">No Aprobado</option>
                                            <option value="Con Cambios">Con Cambios</option>
                                        </select>
                                       <button type="submit" class="btn btn-primary btn-sm mt-1" title="Calificar">
    <i class="fas fa-check-circle"></i> Calificar
</button>
                                    </form>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
              </div>
    </section>
    
    <!-- Modal -->
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
    
    <%-- Inclusión de jQuery, Bootstrap y SweetAlert --%>
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <!-- jQuery y JS de DataTables -->
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/buttons/2.4.1/js/dataTables.buttons.min.js"></script>
<script src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.html5.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>

    <script>
function mostrarInformacion(rol, informacion) {
    document.getElementById('rolTitulo').textContent = rol;
    const lista = document.getElementById('infoLista');
    lista.innerHTML = '';
    
    if (informacion === 'Pendiente') {
        lista.innerHTML = '<li class="list-group-item">No asignado</li>';
        return;
    }
    
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

                        $('#tablaCalificacion').DataTable({
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
