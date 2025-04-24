<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="x" uri="http://java.sun.com/jsp/jstl/xml" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="../styles/estilos.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.3.0/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
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
            <a class="nav-link" href="#home"><i class="fas fa-home me-1"></i> Inicio</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="#management"><i class="fa-solid fa-briefcase"></i> Gestion</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="#about"><i class="fas fa-info-circle me-1"></i> Importante</a>
          </li>
            <li class="nav-item">
            <a class="nav-link" href="../logout.jsp"><i class="fa-solid fa-sign-out-alt"></i> Cerrar Sesion</a>
            </li>
        </ul>
      </div>
    </div>
  </nav>

  <section id="home" class="hero text-center">
    <div class="container hero-content">
      <div class="logo-container floating">
        <img src="../images/logoUTScompleto.png" alt="UTS Logo">
      </div>
      <h1>Bienvenido, <c:out value="${param.nombres}" /></h1>
      <p>Rol: <c:out value="${param.nombre_rol}" /></p>
<a href="#management" class="btn-exercise">
  <i class="fas fa-arrow-down me-2"></i>Gestion
</a>
    </div>
  </section>

<section id="about" class="py-5">
    <div class="container">
        <h2 class="section-title">Importante</h2>
        <div class="about-jstl">
            <div class="row align-items-center">
                <div class="col-lg-5 mb-4 mb-lg-0 text-center">
                    <img src="../images/UTS.png" alt="UTS Imagen" class="img-fluid">
                </div>
                <div class="col-lg-7">
                    <p>Aquí encontrarás toda la base documental de las <strong>Unidades Tecnológicas de Santander</strong>, con los formatos para trabajos de grado y el calendario estudiantil actualizado, podras acceder a las fechas especificas por semestre y año y la base documental oficial de la universidad con los formatos.</p>
                    <div class="row mt-4">
                        <div class="col-md-6 mb-3">
                            <a href="https://www.uts.edu.co/sitio/calendario-academico/" class="btn btn-success w-100">
                                <i class="fas fa-calendar me-2"></i>Calendario Académico
                            </a>
                        </div>
                        <div class="col-md-6 mb-3">
                            <a href="https://www.dropbox.com/scl/fo/pudgcaq639agy7t06ahjs/AN084HnuyHffgYL5i--v_Ks/DOCUMENTOS%20DE%20GRADO?dl=0&rlkey=6s0b9ajweteyx2ang7ywvk6xm&subfolder_nav_tracking=1" class="btn btn-success w-100">
                                <i class="fas fa-file-alt me-2"></i>Base Documental
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
</section>

<section id="management" >
    <div class="container">
      <h2 class="section-title">Gestión</h2>
      <br>

      <%-- FUNCIONES DE ADMINISTRADOR --%>
      <c:choose>
        <c:when test="${param.rol eq '1'}">
          <div class="row">
            <div class="col-md-4">
              <div class="user-management-card shadow-lg rounded-lg border border-success">
          <div class="card-header bg-success text-white py-3 text-center">
            <i class="fas fa-users fa-2x mb-2"></i>
            <h4 class="card-title mb-0">Usuarios</h4>
          </div>
          <div class="card-body text-center">
            <p class="card-text text-muted mb-4">
                <br>
              Gestión de los usuarios del sistema y su rol especifico
            </p>
            <a href="../gestion/usuariosGestion.jsp?id=${param.id}&rol=${param.rol}&nombre_rol=${param.nombre_rol}&nombres=${param.nombres}" class="btn btn-outline-success btn-lg px-4 rounded-pill">
              Administrar Usuarios
            </a>
          </div>
          <br>
              </div>
            </div>
            <div class="col-md-4">
              <div class="user-management-card shadow-lg rounded-lg border border-success">
          <div class="card-header bg-success text-white py-3 text-center">
            <i class="fas fa-bookmark fa-2x mb-2"></i>
            <h4 class="card-title mb-0">Roles</h4>
          </div>
          <div class="card-body text-center">
            <p class="card-text text-muted mb-4">
                <br>
              Gestión de los roles y sus funciones dentro del sistema de proyectos.
            </p>
            <a href="../gestion/rolesGestion.jsp?id=${param.id}&rol=${param.rol}&nombre_rol=${param.nombre_rol}&nombres=${param.nombres}" class="btn btn-outline-success btn-lg px-4 rounded-pill">
              Administrar Roles
            </a>
          </div>
          <br>
              </div>
            </div>
          </div>
        </c:when>
        
 <%-- FUNCIONES DE COORDINADOR --%>
<c:when test="${param.rol eq '3'}">
  <div class="container-fluid">
    <div class="row row-cols-1 row-cols-md-2 row-cols-lg-4 g-4">
      <div class="col">
        <div class="user-management-card shadow-lg rounded-lg border border-success h-100">
          <div class="card-header bg-success text-white py-3 text-center">
            <i class="fa-solid fa-lightbulb fa-2x mb-2"></i>
            <h4 class="card-title mb-0">Ideas de anteproyecto</h4>
          </div>
          <div class="card-body text-center d-flex flex-column justify-content-between">
            <p class="card-text text-muted mb-4">
              <br>
              Administración y gestión de las ideas de anteproyecto.
            </p>
            <div class="mt-auto">
              <a href="../gestion/ideasGestion.jsp?id=${param.id}&rol=${param.rol}&nombre_rol=${param.nombre_rol}&nombres=${param.nombres}" class="btn btn-outline-success px-3 rounded-pill">
                Administrar Ideas
              </a>
            </div>
          </div>
          <br>
        </div>
      </div>
      <div class="col">
        <div class="user-management-card shadow-lg rounded-lg border border-success h-100">
          <div class="card-header bg-success text-white py-3 text-center">
            <i class="fa-solid fa-list fa-2x mb-2"></i>
            <h4 class="card-title mb-0">Historial de Versiones</h4>
          </div>
          <div class="card-body text-center d-flex flex-column justify-content-between">
            <p class="card-text text-muted mb-4">
              <br>
              Ver todas las versiones de los anteproyectos.
            </p>
            <div class="mt-auto">
              <a href="verHistorialCompleto.jsp?id=${param.id}&rol=${param.rol}&nombre_rol=${param.nombre_rol}&nombres=${param.nombres}" class="btn btn-outline-success px-3 rounded-pill">
                Visualizar Historial
              </a>
            </div>
          </div>
          <br>
        </div>
      </div>
      <div class="col">
        <div class="user-management-card shadow-lg rounded-lg border border-success h-100">
          <div class="card-header bg-success text-white py-3 text-center">
            <i class="fa-solid fa-clipboard-check fa-2x mb-2"></i>
            <h4 class="card-title mb-0">Aprobar y Calificar</h4>
          </div>
          <div class="card-body text-center d-flex flex-column justify-content-between">
            <p class="card-text text-muted mb-4">
              <br>
              Aprobar la idea y recibo de pago del anteproyecto.
            </p>
            <div class="mt-auto">
              <a href="../gestion/calificacionCoorGestion.jsp?id=${param.id}&rol=${param.rol}&nombre_rol=${param.nombre_rol}&nombres=${param.nombres}" class="btn btn-outline-success px-3 rounded-pill">
                Calificar
              </a>
            </div>
          </div>
          <br>
        </div>
      </div>
      <div class="col">
        <div class="user-management-card shadow-lg rounded-lg border border-success h-100">
          <div class="card-header bg-success text-white py-3 text-center">
            <i class="fa-solid fa-users fa-2x mb-2"></i>
            <h4 class="card-title mb-0">Asignar Docentes</h4>
          </div>
          <div class="card-body text-center d-flex flex-column justify-content-between">
            <p class="card-text text-muted mb-4">
              <br>
              Asignar evaluador y director a un anteproyecto.
            </p>
            <div class="mt-auto">
              <a href="../gestion/asignacionesGestion.jsp?id=${param.id}&rol=${param.rol}&nombre_rol=${param.nombre_rol}&nombres=${param.nombres}" class="btn btn-outline-success px-3 rounded-pill">
                Asignar
              </a>
            </div>
          </div>
          <br>
        </div>
      </div>
    </div>
  </div>
</c:when>
      
       <%-- FUNCIONES DEL DIRECTOR --%>
        <c:when test="${param.rol eq '4'}">
          <div class="row">
                   <div class="col-md-4">
              <div class="user-management-card shadow-lg rounded-lg border border-success">
                <div class="card-header bg-success text-white py-3 text-center">
        <i class="fa-solid fa-clipboard-check fa-2x mb-2"></i>
                  <h4 class="card-title mb-0">Aprobar y Calificar</h4>
                </div>
                <div class="card-body text-center">
                  <p class="card-text text-muted mb-4">
                      <br>
                             Calificar anteproyectos de estudiantes.
                  </p>
            <a href="../gestion/calificacionDirGestion.jsp?id=${param.id}&rol=${param.rol}&nombre_rol=${param.nombre_rol}&nombres=${param.nombres}" class="btn btn-outline-success btn-lg px-4 rounded-pill">
              Calificar
            </a>
                </div>
                <br>
              </div>
              </div>
              <div class="col-md-4">
              <div class="user-management-card shadow-lg rounded-lg border border-success">
                <div class="card-header bg-success text-white py-3 text-center">
        <i class="fa-solid fa-list fa-2x mb-2"></i>
                  <h4 class="card-title mb-0">Historial de Versiones</h4>
                </div>
                <div class="card-body text-center">
                  <p class="card-text text-muted mb-4">
                      <br>
                            Ver todas las versiones de los anteproyectos.
                  </p>
          <a href="verHistorialCompleto.jsp?id=${param.id}&rol=${param.rol}&nombre_rol=${param.nombre_rol}&nombres=${param.nombres}" class="btn btn-outline-success btn-lg px-4 rounded-pill">
                Visualizar Historial
              </a>
                </div>
                <br>
              </div>
              </div>

       <%-- FUNCIONES DEL EVALUADOR --%>
          </div>
        </c:when>
        <c:when test="${param.rol eq '5'}">
          <div class="row">
            <div class="col-md-4">
              <div class="user-management-card shadow-lg rounded-lg border border-success">
                <div class="card-header bg-success text-white py-3 text-center">
                  <i class="fas fa-clipboard-check fa-2x mb-2"></i>
                  <h4 class="card-title mb-0">Aprobar y Calificar</h4>
                </div>
                <div class="card-body text-center">
                  <p class="card-text text-muted mb-4">
                      <br>
                    Calificar anteproyectos de estudiantes aprobados por el director.
                  </p>
                  <a href="../gestion/calificacionEvlGestion.jsp?id=${param.id}&rol=${param.rol}&nombre_rol=${param.nombre_rol}&nombres=${param.nombres}" class="btn btn-outline-success btn-lg px-4 rounded-pill">
              Calificar
            </a>
                </div>
                    <br>
              </div>
            </div>
                  <div class="col-md-4">
              <div class="user-management-card shadow-lg rounded-lg border border-success">
                <div class="card-header bg-success text-white py-3 text-center">
        <i class="fa-solid fa-list fa-2x mb-2"></i>
                  <h4 class="card-title mb-0">Historial de Versiones</h4>
                </div>
                <div class="card-body text-center">
                  <p class="card-text text-muted mb-4">
                      <br>
                            Ver todas las versiones de los anteproyectos.
                  </p>
          <a href="verHistorialCompleto.jsp?id=${param.id}&rol=${param.rol}&nombre_rol=${param.nombre_rol}&nombres=${param.nombres}" class="btn btn-outline-success btn-lg px-4 rounded-pill">
                Visualizar Historial
              </a>
                </div>
                <br>
              </div>
              </div>
          </div>
        </c:when>
        
              <%-- FUNCIONES DEL ESTUDIANTE --%>
          <c:when test="${param.rol eq '2'}">
          <div class="row">
            <div class="col-md-4">
              <div class="user-management-card shadow-lg rounded-lg border border-success">
                <div class="card-header bg-success text-white py-3 text-center">
                  <i class="fas fa-book-open fa-2x mb-2"></i>
                  <h4 class="card-title mb-0">Gestión de Anteproyecto</h4>
                </div>
                <div class="card-body text-center">
                  <p class="card-text text-muted mb-4">
                      <br>
                             Gestion del anteproyecto del estudiante.
                  </p>
            <a href="../gestion/anteproyectoGestion.jsp?id=${param.id}&rol=${param.rol}&nombre_rol=${param.nombre_rol}&nombres=${param.nombres}" class="btn btn-outline-success btn-lg px-4 rounded-pill">
              Administrar Anteproyecto
            </a>
                </div>
                <br>
              </div>
            </div>
                   <div class="col-md-4">
              <div class="user-management-card shadow-lg rounded-lg border border-success">
                <div class="card-header bg-success text-white py-3 text-center">
        <i class="fa-solid fa-list fa-2x mb-2"></i>
                  <h4 class="card-title mb-0">Historial de versiones</h4>
                </div>
                <div class="card-body text-center">
                  <p class="card-text text-muted mb-4">
                      <br>
                             Ver las versiones antiguas del anteproyecto.
                  </p>
            <a href="verHistorialVersiones.jsp?id=${param.id}&rol=${param.rol}&nombre_rol=${param.nombre_rol}&nombres=${param.nombres}" class="btn btn-outline-success btn-lg px-4 rounded-pill">
              Visualizar Historial
            </a>
                </div>
                <br>
              </div>
            </div>
             <div class="col-md-4">
              <div class="user-management-card shadow-lg rounded-lg border border-success">
                <div class="card-header bg-success text-white py-3 text-center">
        <i class="fa-solid fa-lightbulb fa-2x mb-2"></i>
                  <h4 class="card-title mb-0">Ideas de Anteproyecto</h4>
                </div>
                <div class="card-body text-center">
                  <p class="card-text text-muted mb-4">
                      <br>
                             Ver las ideas disponibles para anteproyecto.
                  </p>
            <a href="verIdeas.jsp?id=${param.id}&rol=${param.rol}&nombre_rol=${param.nombre_rol}&nombres=${param.nombres}" class="btn btn-outline-success btn-lg px-4 rounded-pill">
              Visualizar Ideas
            </a>
                </div>
          </div>
        </c:when>
      </c:choose>
    </div>
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
        <div class="col-12">
          <p class="small text-white-50">&copy; 2025 Andrey Mantilla. Todos los derechos reservados.</p>
        </div>
      </div>

  <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/2.9.2/umd/popper.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.3.0/js/bootstrap.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  <script>
    function showEjercicio1() {
      Swal.fire({
        title: 'Ejercicio 1',
        html: '<div <p class="text-center">Cadena de caracteres: <strong><c:out value="1+2+3"/> <br> <p class="text-center">Suma de valores: <strong><c:out value="${1+2+3}"/></strong></p></div>',
        icon: 'info',
        confirmButtonText: 'Cerrar',
        confirmButtonColor: '#0d6efd'
      });
    }
    
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