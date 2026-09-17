<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.List" %>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/navbar.jspf" %>

<%
    Integer totalUsuarios = (Integer) request.getAttribute("totalUsuarios");
    Integer totalInmuebles = (Integer) request.getAttribute("totalInmuebles");
    Integer totalCitas = (Integer) request.getAttribute("totalCitas");
    Integer totalSolicitudes = (Integer) request.getAttribute("totalSolicitudes");
    String usuarioSesion = String.valueOf(session.getAttribute("usuario"));
%>

<main class="container my-5 flex-grow-1">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="fw-bold h3 mb-0">Panel del Administrador</h1>
            <p class="text-muted mb-0">Bienvenido, <%= usuarioSesion %></p>
        </div>
        <a href="${pageContext.request.contextPath}/reportes" class="btn btn-outline-primary">
            <i class="fa-solid fa-chart-column me-2"></i>Ver reportes
        </a>
    </div>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger" role="alert">
            <i class="fa-solid fa-triangle-exclamation me-2"></i><%= request.getAttribute("error") %>
        </div>
    <% } %>
    <% if (request.getAttribute("exito") != null) { %>
        <div class="alert alert-success" role="alert">
            <i class="fa-solid fa-circle-check me-2"></i><%= request.getAttribute("exito") %>
        </div>
    <% } %>

    <div class="row g-4">
        <div class="col-sm-6 col-lg-3">
            <div class="card border-0 shadow-sm text-bg-primary">
                <div class="card-body d-flex align-items-center justify-content-between">
                    <div>
                        <h6 class="card-title text-uppercase opacity-75 mb-1">Usuarios</h6>
                        <span class="display-6 fw-bold"><%= totalUsuarios != null ? totalUsuarios : 0 %></span>
                    </div>
                    <i class="fa-solid fa-users fa-3x opacity-50"></i>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-lg-3">
            <div class="card border-0 shadow-sm text-bg-success">
                <div class="card-body d-flex align-items-center justify-content-between">
                    <div>
                        <h6 class="card-title text-uppercase opacity-75 mb-1">Inmuebles</h6>
                        <span class="display-6 fw-bold"><%= totalInmuebles != null ? totalInmuebles : 0 %></span>
                    </div>
                    <i class="fa-solid fa-building fa-3x opacity-50"></i>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-lg-3">
            <div class="card border-0 shadow-sm text-bg-warning">
                <div class="card-body d-flex align-items-center justify-content-between">
                    <div>
                        <h6 class="card-title text-uppercase opacity-75 mb-1">Citas</h6>
                        <span class="display-6 fw-bold"><%= totalCitas != null ? totalCitas : 0 %></span>
                    </div>
                    <i class="fa-solid fa-calendar-check fa-3x opacity-50"></i>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-lg-3">
            <div class="card border-0 shadow-sm text-bg-info">
                <div class="card-body d-flex align-items-center justify-content-between">
                    <div>
                        <h6 class="card-title text-uppercase opacity-75 mb-1">Solicitudes</h6>
                        <span class="display-6 fw-bold"><%= totalSolicitudes != null ? totalSolicitudes : 0 %></span>
                    </div>
                    <i class="fa-solid fa-file-circle-check fa-3x opacity-50"></i>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4 mt-4">
        <div class="col-lg-6">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-header bg-white fw-bold">Accesos rápidos</div>
                <div class="list-group list-group-flush">
                    <a class="list-group-item list-group-item-action d-flex align-items-center"
                       href="${pageContext.request.contextPath}/dashboard/admin/usuarios.jsp">
                        <i class="fa-solid fa-user-gear me-3 text-primary"></i>
                        Gestión de usuarios y roles
                    </a>
                    <a class="list-group-item list-group-item-action d-flex align-items-center"
                       href="${pageContext.request.contextPath}/reportes">
                        <i class="fa-solid fa-chart-pie me-3 text-success"></i>
                        Reportes consolidados
                    </a>
                    <a class="list-group-item list-group-item-action d-flex align-items-center"
                       href="${pageContext.request.contextPath}/catalogos">
                        <i class="fa-solid fa-layer-group me-3 text-info"></i>
                        Catálogos de administración
                    </a>
                    <a class="list-group-item list-group-item-action d-flex align-items-center"
                       href="${pageContext.request.contextPath}/auditorias">
                        <i class="fa-solid fa-scroll me-3 text-danger"></i>
                        Bitácora de auditoría
                    </a>
                    <a class="list-group-item list-group-item-action d-flex align-items-center"
                       href="${pageContext.request.contextPath}/propiedades">
                        <i class="fa-solid fa-tags me-3 text-warning"></i>
                        Catálogo de inmuebles
                    </a>
                </div>
            </div>
        </div>
        <div class="col-lg-6">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-header bg-white fw-bold">Estados recientes</div>
                <div class="card-body">
                    <p class="text-muted mb-0">
                        El panel se actualiza con los totales expuestos como atributos
                        <code>totalUsuarios</code>, <code>totalInmuebles</code>, <code>totalCitas</code> y
                        <code>totalSolicitudes</code>.
                    </p>
                </div>
            </div>
        </div>
    </div>
</main>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>