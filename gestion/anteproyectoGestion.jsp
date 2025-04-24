<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%--
  1. Recuperación de parámetros y asignación a variables (sin scriptlets)
--%>
<c:set var="idEstudiante" value="${param.id}" />
<c:set var="rol" value="${param.rol}" />
<c:set var="nombreRol" value="${param.nombre_rol}" />
<c:set var="nombres" value="${param.nombres}" />

<%-- Variables para mensajes se establecerán en sesión cuando se procese la acción --%>

<%--
  2. Consulta de la última versión del anteproyecto para el estudiante.
--%>
<sql:query dataSource="${trabajosdegradoBD}" var="anteProy">
    SELECT * FROM anteproyecto 
    WHERE id_estudiante = ? 
    ORDER BY version DESC LIMIT 1
    <sql:param value="${idEstudiante}" />
</sql:query>

<c:if test="${pageContext.request.method eq 'POST'}">
    <c:set var="accion" value="${param.accion}" />
    <c:if test="${accion eq 'estudiante2'}">
        <sql:update dataSource="${trabajosdegradoBD}">
            UPDATE anteproyecto 
            SET id_estudiante2 = ?
            WHERE id = ?
            <sql:param value="${param.estudiante2ID}" />
            <sql:param value="${param.anteproyectoId}" />
        </sql:update>
        <c:set var="successMessage" scope="session" value="Director y evaluador asignados correctamente." />
        <c:redirect url="anteproyectoGestion.jsp?id=${idEstudiante}&rol=${rol}&nombre_rol=${nombreRol}&nombres=${nombres}" />
    </c:if>
</c:if>

<%-- Si se obtuvo resultado, se asignan las variables correspondientes --%>
<c:if test="${not empty anteProy.rows}">
    <c:set var="tieneAnteproyecto" value="true" />
    <c:set var="versionActual" value="${anteProy.rows[0].version}" />
    <c:set var="idIdea" value="${anteProy.rows[0].id_idea}" />
    <c:set var="reciboPago" value="${anteProy.rows[0].recibo_pago}" />
    <c:set var="reciboNombre" value="${anteProy.rows[0].recibo_nombre}" />
    <c:set var="reciboTipo" value="${anteProy.rows[0].recibo_tipo}" />
    <c:set var="estadoCalificacionDirector" value="${anteProy.rows[0].estado_calificacion_director}" />
    <c:set var="estadoCalificacionEvaluador" value="${anteProy.rows[0].estado_calificacion_evaluador}" />
    <c:set var="estadoCalificacionCoordinador" value="${anteProy.rows[0].estado_calificacion_coordinador}" />
    <c:set var="calificacionTotal" value="${anteProy.rows[0].calificacion_total}" />
    <c:set var="fechaActualizacion" value="${anteProy.rows[0].fecha_actu}" />
    <c:set var="Evaluador" value="${anteProy.rows[0].id_director}" />
    <c:set var="Director" value="${anteProy.rows[0].id_evaluador}" />
</c:if>
<c:if test="${empty anteProy.rows}">
    <c:set var="tieneAnteproyecto" value="false" />
    <c:set var="versionActual" value="0" />
    <c:set var="estadoCalificacionDirector" value="" />
    <c:set var="estadoCalificacionEvaluador" value="" />
    <c:set var="estadoCalificacionCoordinador" value="" />
    <c:set var="calificacionTotal" value="" />
</c:if>

<%--
  Revisar si se adjunto el recibo de pago O no 
--%>
<c:if test="${empty anteProy.rows[0].recibo_pago}">
    <c:set var="adjuntorecibopago" value="false" />
</c:if>
<c:if test="${not empty anteProy.rows[0].recibo_pago}">
    <c:set var="adjuntorecibopago" value="true" />
</c:if>

<%--
  Revisar si se adjunto el anteproyecto o no
--%>
<c:if test="${empty anteProy.rows[0].archivo}">
    <c:set var="adjuntoanteproyecto" value="false" />
</c:if>
<c:if test="${not empty anteProy.rows[0].archivo}">
    <c:set var="adjuntoanteproyecto" value="true" />
</c:if>

<%--
  Revisar si existe director y evaluador
--%>
<c:if test="${empty anteProy.rows[0].id_evaluador and empty anteProy.rows[0].id_director}">
    <c:set var="tieneDocentes" value="false" />
</c:if>
<c:if test="${not empty anteProy.rows[0].id_evaluador and not empty anteProy.rows[0].id_director}">
    <c:set var="tieneDocentes" value="true" />
</c:if>


<%--
  3. Lógica para determinar si se puede agregar una nueva versión.
--%>
<c:set var="puedeAgregarVersion" value="false" />
<c:if test="${tieneAnteproyecto}">
    <c:choose>
        <c:when test="${versionActual == 1}">
            <c:if test="${not empty reciboPago and estadoCalificacionCoordinador eq 'Aprobado' and tieneDocentes eq true}">
                <c:set var="puedeAgregarVersion" value="true" />
            </c:if>
        </c:when>
        <c:otherwise>
            <c:if test="${estadoCalificacionDirector eq 'Con Cambios' or estadoCalificacionEvaluador eq 'Con Cambios'}">
                <c:set var="puedeAgregarVersion" value="true" />
            </c:if>
        </c:otherwise>
    </c:choose>
    <c:if test="${estadoCalificacionDirector eq 'No Aprobado' or estadoCalificacionEvaluador eq 'No Aprobado' or calificacionTotal eq 'No Aprobado'}">
        <c:set var="puedeAgregarVersion" value="false" />
    </c:if>
    <c:if test="${estadoCalificacionDirector eq 'Aprobado' and estadoCalificacionEvaluador eq 'Aprobado'}">
        <c:set var="puedeAgregarVersion" value="false" />
    </c:if>
    <c:if test="${calificacionTotal eq 'Con Cambios'}">
        <c:set var="puedeAgregarVersion" value="true" />
    </c:if>
</c:if>

<%--
  4. Procesamiento del formulario POST.
  Se separa el caso normal (no multipart) del de archivo.
  NOTA: La carga de archivos multipart no es soportada por JSTL, así que se redirige con un mensaje.
--%>
<%-- Caso de solicitud POST NO multipart --%>
<c:if test="${pageContext.request.method eq 'POST' and not fn:contains(pageContext.request.contentType, 'multipart/form-data')}">
    <c:set var="accion" value="${param.accion}" />
    <c:set var="ideaSeleccionada" value="${param.id_idea}" />

    <%-- Caso 1: Crear nuevo anteproyecto (versión 1) --%>
    <c:if test="${accion eq 'nuevaIdea' and tieneAnteproyecto eq false and not empty ideaSeleccionada}">
        <%-- Inserta el nuevo registro en anteproyecto --%>
        <sql:update dataSource="${trabajosdegradoBD}">
            INSERT INTO anteproyecto (id_idea, id_estudiante, id_estudiante2, version, estado_calificacion_coordinador, fecha_actu)
            VALUES (?, ?, ?, 1, '',NOW())
            <sql:param value="${ideaSeleccionada}" />
            <sql:param value="${idEstudiante}" />
            <sql:param value="${null}"/>
        </sql:update>
        <%-- Actualiza la idea para marcarla como no disponible --%>
        <sql:update dataSource="${trabajosdegradoBD}">
            UPDATE ideas SET disponibilidad = 0 WHERE id = ?
            <sql:param value="${ideaSeleccionada}" />
        </sql:update>
        <c:set var="successMessage" scope="session" value="Idea seleccionada correctamente para el anteproyecto." />
        <c:redirect url="anteproyectoGestion.jsp?id=${idEstudiante}&rol=${rol}&nombre_rol=${nombreRol}&nombres=${nombres}#crud" />
    </c:if>

    <%-- Caso 2: Agregar nueva versión del anteproyecto --%>
    <c:if test="${accion eq 'agregarVersion'}">
        <c:choose>
            <c:when test="${tieneAnteproyecto and puedeAgregarVersion}">
                <%-- Explícitamente establecer adjuntoanteproyecto como false para la nueva versión --%>
                <c:set var="adjuntoanteproyecto" value="false" scope="session" />
                
                <%-- Se consulta la última versión --%>
                <sql:query dataSource="${trabajosdegradoBD}" var="rsVersion">
                    SELECT * FROM anteproyecto 
                    WHERE id_estudiante = ? 
                    ORDER BY version DESC LIMIT 1
                    <sql:param value="${idEstudiante}" />
                </sql:query>
                <c:if test="${not empty rsVersion.rows}">
                    <%-- Se copian los campos necesarios --%>
                    <c:set var="idEstudiante2" value="${rsVersion.rows[0].id_estudiante2}" />
                    <c:set var="idIdeaCopy" value="${rsVersion.rows[0].id_idea}" />
                    <c:set var="idDirectorCopy" value="${rsVersion.rows[0].id_director}" />
                    <c:set var="idEvaluadorCopy" value="${rsVersion.rows[0].id_evaluador}" />
                    <c:set var="idCoordinadorCopy" value="${rsVersion.rows[0].id_coordinador}" />
                    <c:set var="reciboPagoCopy" value="${rsVersion.rows[0].recibo_pago}" />
                    <c:set var="reciboTipoCopy" value="${rsVersion.rows[0].recibo_tipo}" />
                    <c:set var="reciboNombreCopy" value="${rsVersion.rows[0].recibo_nombre}" />
                    <c:set var="newVersion" value="${rsVersion.rows[0].version + 1}" />
                    
                    <%-- Asegurar que adjuntoanteproyecto es false antes de insertar --%>
                    <c:set var="adjuntoanteproyecto" value="false" scope="session" />
                    
                    <%-- Se inserta la nueva versión (se reinician los estados de director y evaluador y la calificación final) --%>
                    <sql:update dataSource="${trabajosdegradoBD}">
                        INSERT INTO anteproyecto (id_idea, id_estudiante, id_estudiante2, id_director, id_evaluador, id_coordinador,
                            recibo_pago, recibo_tipo, recibo_nombre, archivo, archivo_nombre, archivo_tipo, version,
                            estado_calificacion_director, estado_calificacion_evaluador, estado_calificacion_coordinador, calificacion_total, fecha_actu)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,NOW())
                        <sql:param value="${idIdeaCopy}" />
                        <sql:param value="${idEstudiante}" />
                        <sql:param value="${idEstudiante2}" />
                        <sql:param value="${idDirectorCopy}" />
                        <sql:param value="${idEvaluadorCopy}" />
                        <sql:param value="${idCoordinadorCopy}" />
                        <sql:param value="${reciboPagoCopy}" />
                        <sql:param value="${reciboTipoCopy}" />
                        <sql:param value="${reciboNombreCopy}" />
                        <sql:param value="${null}"/>
                        <sql:param value="${null}" />
                        <sql:param value="${null}" />
                        <sql:param value="${newVersion}" />
                        <sql:param value=""/>  <%-- Se reinicia el estado de director --%>
                        <sql:param value=""/>  <%-- Se reinicia el estado de evaluador --%>
                        <sql:param value="${estadoCalificacionCoordinador}" />  <%-- Se conserva el estado del coordinador --%>
                        <sql:param value=""/>  <%-- Se reinicia la calificación final --%>
                    </sql:update>
                
                    <c:set var="successMessage" scope="session" value="Nueva versión ${newVersion} del anteproyecto creada correctamente. Adjunto anteproyecto pendiente." />
                    <c:redirect url="anteproyectoGestion.jsp?id=${idEstudiante}&rol=${rol}&nombre_rol=${nombreRol}&nombres=${nombres}#crud" />
                </c:if>
                <c:if test="${empty rsVersion.rows}">
                    <c:set var="errorMessage" scope="session" value="No se pudo obtener la versión anterior del anteproyecto." />
                    <c:redirect url="anteproyectoGestion.jsp?id=${idEstudiante}&rol=${rol}&nombre_rol=${nombreRol}&nombres=${nombres}#crud" />
                </c:if>
            </c:when>
            <c:otherwise>
                <c:set var="errorMessage" scope="session" value="No se puede agregar una nueva versión en este momento. Verifica el estado de evaluación." />
                <c:redirect url="anteproyectoGestion.jsp?id=${idEstudiante}&rol=${rol}&nombre_rol=${nombreRol}&nombres=${nombres}#crud" />
            </c:otherwise>
        </c:choose>
    </c:if>
</c:if>

<%-- Caso: Solicitud POST con multipart (carga de archivos) --%>
<c:if test="${pageContext.request.method eq 'POST' and fn:contains(pageContext.request.contentType, 'multipart/form-data')}">
    <%-- JSTL no permite procesar archivos, por lo que se notifica y se redirige.
         Se recomienda manejar la carga de archivos desde un servlet o controlador especializado. --%>
    <c:set var="errorMessage" scope="session" value="La carga de archivos debe procesarse a través de un servlet dedicado." />
    <c:redirect url="anteproyectoGestion.jsp?id=${idEstudiante}&rol=${rol}&nombre_rol=${nombreRol}&nombres=${nombres}#crud" />
</c:if>

<%-- limpiar las alertas del JS --%>
<c:if test="${not empty sessionScope.successMessage}">
    <c:set var="mostrarSuccess" value="${sessionScope.successMessage}" scope="page" />
    <c:remove var="successMessage" scope="session" />
</c:if>

<c:if test="${not empty sessionScope.errorMessage}">
    <c:set var="mostrarError" value="${sessionScope.errorMessage}" scope="page" />
    <c:remove var="errorMessage" scope="session" />
</c:if>

<%-- Consulta de estudiante 2 --%>
<sql:query dataSource="${trabajosdegradoBD}" var="listaEstudiante2">
    SELECT id, CONCAT(nombres, ' ', apellido1, ' ', apellido2) AS nombre_estudiante2
    FROM usuarios
    WHERE rol = 2 AND id != ${idEstudiante}
    ORDER BY nombres;
</sql:query>

<%--
  5. Continuación de la parte de presentación de la página (HTML y uso de JSTL en vistas)
--%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>UTS - Gestión de Anteproyecto</title>
    <link rel="stylesheet" href="../styles/estilos.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.3.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
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
                        <a class="nav-link" href="../vistas/principal.jsp?id=${idEstudiante}&rol=${rol}&nombre_rol=${nombreRol}&nombres=${nombres}">
                            <i class="fas fa-home me-1"></i> Inicio
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#crud">
                            <i class="fa-solid fa-briefcase"></i> Gestion
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="../vistas/principal.jsp?id=${idEstudiante}&rol=${rol}&nombre_rol=${nombreRol}&nombres=${nombres}#about">
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
            <h1>Gestión de Anteproyecto</h1>
            <p>Usuario: <c:out value="${nombres}" /></p>
            <a href="#crud" class="btn-exercise">
                <i class="fas fa-arrow-down me-2"></i>Gestionar Anteproyectos
            </a>
        </div>
    </section>
    
    <section id="crud" >
        <h3 class="section-title">Anteproyecto Actual</h3>
        <c:choose>
            <%-- Caso por defecto: En evaluación o sin poder agregar versión --%>
            <c:when test="${tieneAnteproyecto eq false}">
                <div class="container mt-5 border shadow p-3 mb-5 bg-body-tertiary rounded">
                    <div class="card shadow p-4">
                        <sql:query dataSource="${trabajosdegradoBD}" var="ideasDisponibles">
                            SELECT id, nombre_idea FROM ideas WHERE disponibilidad = 1
                        </sql:query>
                        <form method="post">
                            <input type="hidden" name="accion" value="nuevaIdea" />
                            <div class="mb-3">
                                <label class="form-label">Selecciona una idea</label>
                                <select name="id_idea" class="form-select" required>
                                    <c:forEach var="idea" items="${ideasDisponibles.rows}">
                                        <option value="${idea.id}">${idea.nombre_idea}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <button type="submit" class="btn btn-success">Seleccionar Idea</button>
                        </form>
                    </div>
            </c:when>
            
            <%-- Verificación de recibo de pago --%>
            <c:when test="${tieneAnteproyecto eq true and adjuntorecibopago eq false}">
                <div class="container mt-5 border shadow p-3 mb-5 bg-body-tertiary rounded">
                    <div class="alert alert-warning">
                        <i class="fas fa-exclamation-triangle"></i> Por favor, adjunte su recibo de pago para enviar su solicitud a coordinación.
                    </div>
            </c:when>
            
            <%-- Verificación de anteproyecto adjunto --%>
            <c:when test="${tieneAnteproyecto eq true and adjuntorecibopago eq true and adjuntoanteproyecto eq false and puedeAgregarVersion eq false and versionActual != 1}">
                <div class="container mt-5 border shadow p-3 mb-5 bg-body-tertiary rounded">
                    <div class="alert alert-warning">
                        <i class="fas fa-exclamation-triangle"></i> Por favor, adjunte su anteproyecto para enviar su solicitud al director.
                    </div>
            </c:when>
            
            <%-- Anteproyecto No Aprobado --%>
            <c:when test="${tieneAnteproyecto eq true and (estadoCalificacionDirector eq 'No Aprobado' or estadoCalificacionEvaluador eq 'No Aprobado' or calificacionTotal eq 'No Aprobado' or estadoCalificacionCoordinador eq 'No Aprobado')}">
                <div class="container mt-5 border shadow p-3 mb-5 bg-body-tertiary rounded">
                    <div class="alert alert-danger">
                        <i class="fas fa-exclamation-triangle"></i> El anteproyecto ha sido No Aprobado. No se permiten más cambios.
                    </div>
            </c:when>
            
            <%-- Anteproyecto aprobado --%>
            <c:when test="${tieneAnteproyecto eq true and (estadoCalificacionDirector eq 'Aprobado' and estadoCalificacionEvaluador eq 'Aprobado' and estadoCalificacionCoordinador eq 'Aprobado' and calificacionTotal eq 'Aprobado')}">
                <div class="container mt-5 border shadow p-3 mb-5 bg-body-tertiary rounded">
                    <div class="alert alert-success">
                        <i class="fas fa-star"></i> Su anteproyecto fue aprobado, ¡Felicitaciones!
                    </div>
            </c:when>
            
            <%-- Si se permite agregar nueva versión del anteproyecto --%>
            <c:when test="${tieneAnteproyecto eq true and puedeAgregarVersion eq true and estadoCalificacionCoordinador eq 'Aprobado' and adjuntorecibopago eq true and tieneDocentes eq true}">
                <div class="container mt-5 border shadow p-3 mb-5 bg-body-tertiary rounded">
                    <form method="post">
                        <input type="hidden" name="accion" value="agregarVersion" />
                        <div class="alert alert-info">
                            <i class="fas fa-info-circle"></i> Estás agregando la versión ${versionActual + 1} del anteproyecto.
                            <br>
                            <small>Estado actual:
                                <c:choose>
                                    <c:when test="${estadoCalificacionCoordinador eq 'Aprobado'}">
                                        Aprobado por Coordinador
                                    </c:when>
                                    <c:when test="${estadoCalificacionDirector eq 'Con Cambios'}">
                                        Director solicitó cambios
                                    </c:when>
                                    <c:when test="${estadoCalificacionEvaluador eq 'Con Cambios'}">
                                        Evaluador solicitó cambios
                                    </c:when>
                                </c:choose>
                            </small>
                        </div>
                        <button type="submit" class="btn btn-success">Crear Nueva Versión</button>
                    </form>
            </c:when>
            
            <%-- Caso por defecto: En evaluación o sin poder agregar versión --%>
            <c:otherwise>
                <div class="container mt-5 border shadow p-3 mb-5 bg-body-tertiary rounded">
                    <div class="alert alert-warning">
                        <i class="fas fa-info-circle"></i> No puedes agregar una nueva versión del anteproyecto, estamos en proceso de evaluación.
                    </div>
            </c:otherwise>
        </c:choose>
                
        <br><br>
        <sql:query dataSource="${trabajosdegradoBD}" var="misAnteproyectos">
            SELECT a.id, i.nombre_idea, a.archivo_nombre, a.estado_calificacion_director, 
                   a.estado_calificacion_evaluador, a.calificacion_total, a.version,
                   a.estado_calificacion_coordinador, a.recibo_nombre, a.id_estudiante2, a.fecha_actu,
                   CONCAT(d.nombres, ' ', d.apellido1, ' ', d.apellido2) AS nombre_director,
                   CONCAT(e.nombres, ' ', e.apellido1, ' ', e.apellido2) AS nombre_evaluador,
                   CONCAT(c.nombres, ' ', c.apellido1, ' ', c.apellido2) AS nombre_coordinador,
                   CONCAT(est2.nombres, ' ', est2.apellido1, ' ', est2.apellido2) AS nombre_estudiante2,
                   CONCAT('Nombre: ', c.nombres, ' ', c.apellido1, ' ', c.apellido2, ' Documento: ',c.documento, ' Correo: ',c.correo,' Telefono: ',c.telefono) AS info_coordinador,
                   CONCAT('Nombre: ', e.nombres, ' ', e.apellido1, ' ', e.apellido2, ' Documento: ',e.documento, ' Correo: ',e.correo,' Telefono: ',e.telefono) AS info_evaluador,
                   CONCAT('Nombre: ', d.nombres, ' ', d.apellido1, ' ', d.apellido2, ' Documento: ',d.documento, ' Correo: ',d.correo,' Telefono: ',d.telefono) AS info_director,
                   CONCAT('Nombre: ', est2.nombres, ' ', est2.apellido1, ' ', est2.apellido2, ' Documento: ',est2.documento, ' Correo: ',est2.correo,' Telefono: ',est2.telefono) AS info_estudiante2,
                   CONCAT(est.documento, ' - ', est.nombres, ' ', est.apellido1, ' ', est.apellido2) AS datos_estudiante,
                   a.id_director, a.id_evaluador, a.id_coordinador
            FROM anteproyecto a
            JOIN ideas i ON a.id_idea = i.id
            JOIN usuarios est ON a.id_estudiante = est.id
            LEFT JOIN usuarios est2 ON a.id_estudiante2 = est2.id
            LEFT JOIN usuarios d ON a.id_director = d.id
            LEFT JOIN usuarios e ON a.id_evaluador = e.id
            LEFT JOIN usuarios c ON a.id_coordinador = c.id
            WHERE a.id_estudiante = ? 
              AND a.version = (SELECT MAX(version) FROM anteproyecto WHERE id_estudiante = ?)
            <sql:param value="${idEstudiante}" />
            <sql:param value="${idEstudiante}" />
        </sql:query>
        
        <div class="table-responsive">
            <table id="tablaAnteproyectos" class="table table-striped table-bordered">
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
                        <th class="ancho-columna" >Ultima Actualizacion</th>
                        <th>Calificación</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="ap" items="${misAnteproyectos.rows}">
                        <tr>
                            <td class="text-center">Versión #${ap.version}</td>
                            <td class="ancho-columna">${ap.datos_estudiante}</td>
                            
                          <td class="ancho-columna">
    <c:choose>

        <c:when test="${ap.version == 1}">
            <c:choose>

                <c:when test="${empty ap.id_estudiante2}">
                    <form id="formEstudiante2_${ap.id}" method="post">
                        <input type="hidden" name="accion" value="estudiante2" />
                        <input type="hidden" name="anteproyectoId" value="${ap.id}" />
                        <select name="estudiante2ID" class="form-select form-select-sm">
                            <option value="">Seleccionar</option>
                            <c:forEach var="est2" items="${listaEstudiante2.rows}">
                                <option value="${est2.id}">${est2.nombre_estudiante2}</option>
                            </c:forEach>
                        </select>
                        <button type="submit" class="btn btn-primary btn-sm mt-1 px-3">
                            <i class="fas fa-user-plus me-1"></i> Agregar otro estudiante
                        </button>
                    </form>
                </c:when>
 
                <c:otherwise>
                    <button type="button" class="btn btn-success" data-bs-toggle="modal" data-bs-target="#gestionModal" 
                            onclick="mostrarInformacion('Estudiante 2', '${ap.info_estudiante2}')">
                        ${ap.nombre_estudiante2}
                    </button>
                </c:otherwise>
            </c:choose>
        </c:when>

        <c:otherwise>
            <c:choose>
               
                <c:when test="${not empty ap.id_estudiante2}">
                    <button type="button" class="btn btn-success" data-bs-toggle="modal" data-bs-target="#gestionModal" 
                            onclick="mostrarInformacion('Estudiante 2', '${ap.info_estudiante2}')">
                        ${ap.nombre_estudiante2}
                    </button>
                </c:when>

                <c:otherwise>
                    <button type="button" class="btn btn-secondary" disabled>
                        No aplica
                    </button>
                </c:otherwise>
            </c:choose>
        </c:otherwise>
    </c:choose>
</td>

                            
                            <td class="ancho-columna">${ap.nombre_idea}</td>
                            <td class="ancho-columna">
                                <c:choose>
                                    <c:when test="${not empty ap.archivo_nombre}">
                                        <a href="../archivos/verArchivoAnteproyecto.jsp?idAnteproyecto=${ap.id}" class="btn btn-sm btn-outline-primary w-100" target="_blank">${ap.archivo_nombre}</a>
                                    </c:when>
                                    <c:otherwise>Sin archivo</c:otherwise>
                                </c:choose>
                            </td>
                            <td class="ancho-columna">
                                <c:choose>
                                    <c:when test="${not empty ap.recibo_nombre}">
                                        <a href="../archivos/verReciboPago.jsp?idAnteproyecto=${ap.id}" class="btn btn-sm btn-outline-primary w-100" target="_blank">${ap.recibo_nombre}</a>
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
                                <c:choose>
                                    <%-- Para versión 1 sin evaluación --%>
                                    <c:when test="${ap.version == 1 and (empty ap.estado_calificacion_director or ap.estado_calificacion_director eq 'Pendiente')}">
                                        <div class="btn-group-vertical w-100">
                                            <c:if test="${empty ap.recibo_nombre}">
                                                <a href="../archivos/adjuntarRecibo.jsp?idAnteproyecto=${ap.id}&id=${idEstudiante}&rol=${rol}&nombre_rol=${nombreRol}&nombres=${nombres}" class="btn btn-sm btn-primary mb-1">
                                                    <i class="fas fa-file-invoice-dollar me-1"></i> Adjuntar Recibo
                                                </a>
                                            </c:if>
                                            <c:if test="${not empty ap.recibo_nombre}">
                                                <a href="../archivos/adjuntarRecibo.jsp?idAnteproyecto=${ap.id}&id=${idEstudiante}&rol=${rol}&nombre_rol=${nombreRol}&nombres=${nombres}" class="btn btn-sm btn-warning mb-1">
                                                    <i class="fas fa-edit me-1"></i> Editar Recibo
                                                </a>
                                            </c:if>
                                        </div>
                                    </c:when>
                                    <%-- Para versiones mayores sin evaluación --%>
                                    <c:when test="${ap.version > 1 and (empty ap.estado_calificacion_director or ap.estado_calificacion_director eq 'Pendiente')}">
                                        <div class="btn-group-vertical w-100">
                                            <c:if test="${empty ap.archivo_nombre}">
                                                <a href="../archivos/adjuntarAnteproyecto.jsp?idAnteproyecto=${ap.id}&id=${idEstudiante}&rol=${rol}&nombre_rol=${nombreRol}&nombres=${nombres}" class="btn btn-sm btn-primary">
                                                    <i class="fas fa-file-pdf me-1"></i> Adjuntar Anteproyecto
                                                </a>
                                            </c:if>
                                            <c:if test="${not empty ap.archivo_nombre}">
                                                <a href="../archivos/adjuntarAnteproyecto.jsp?idAnteproyecto=${ap.id}&id=${idEstudiante}&rol=${rol}&nombre_rol=${nombreRol}&nombres=${nombres}" class="btn btn-sm btn-warning">
                                                    <i class="fas fa-edit me-1"></i> Editar Anteproyecto
                                                </a>
                                            </c:if>
                                        </div>
                                    </c:when>
                                    <c:when test="${not empty ap.estado_calificacion_director and ap.estado_calificacion_director ne 'Pendiente' or ap.estado_calificacion_coordinador eq 'Aprobado'}">
                                        <div class="alert alert-secondary p-1 text-center">
                                            <small>No se permiten más cambios</small>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="alert alert-secondary p-1 text-center">
                                            <small>En evaluación</small>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
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
        <div class="col-12">
          <p class="small text-white-50">&copy; 2025 Andrey Mantilla. Todos los derechos reservados.</p>
        </div>
            </div>
        </div>
    </footer>
    
    <%-- Incluye jQuery, Bootstrap y SweetAlert --%>
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
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
