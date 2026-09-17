<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.List" %>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/navbar.jspf" %>

<%
    String usuarioSesion = String.valueOf(session.getAttribute("usuario"));
    List<?> citas = (List<?>) request.getAttribute("citas");
    List<?> solicitudes = (List<?>) request.getAttribute("solicitudes");
    int totalCitas = citas != null ? citas.size() : 0;
    int totalSolicitudes = solicitudes != null ? solicitudes.size() : 0;
%>

<main class="container my-5 flex-grow-1">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="fw-bold h3 mb-0">Panel del Cliente</h1>
            <p class="text-muted mb-0">Bienvenido, <%= usuarioSesion %></p>
        </div>
        <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/PerfilServlet">
            <i class="fa-solid fa-user-pen me-2"></i>Completar mi perfil
        </a>
    </div>

    <div class="row g-4">
        <div class="col-sm-6">
            <div class="card border-0 shadow-sm text-bg-primary">
                <div class="card-body d-flex align-items-center justify-content-between">
                    <div>
                        <h6 class="text-uppercase opacity-75 mb-1">Citas agendadas</h6>
                        <span class="display-5 fw-bold"><%= totalCitas %></span>
                    </div>
                    <i class="fa-solid fa-calendar-check fa-3x opacity-50"></i>
                </div>
            </div>
        </div>
        <div class="col-sm-6">
            <div class="card border-0 shadow-sm text-bg-success">
                <div class="card-body d-flex align-items-center justify-content-between">
                    <div>
                        <h6 class="text-uppercase opacity-75 mb-1">Trámites activos</h6>
                        <span class="display-5 fw-bold"><%= totalSolicitudes %></span>
                    </div>
                    <i class="fa-solid fa-folder-open fa-3x opacity-50"></i>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4 mt-4">
        <div class="col-md-6">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-header bg-white fw-bold">Mis trámites</div>
                <div class="list-group list-group-flush">
                    <a class="list-group-item list-group-item-action d-flex align-items-center"
                       href="${pageContext.request.contextPath}/CitaServlet">
                        <i class="fa-solid fa-clock me-3 text-primary"></i>
                        Estado de mis visitas
                    </a>
                    <a class="list-group-item list-group-item-action d-flex align-items-center"
                       href="${pageContext.request.contextPath}/SolicitudServlet">
                        <i class="fa-solid fa-file-signature me-3 text-success"></i>
                        Mis solicitudes y documentos
                    </a>
                    <a class="list-group-item list-group-item-action d-flex align-items-center"
                       href="${pageContext.request.contextPath}/FavoritoServlet">
                        <i class="fa-solid fa-heart me-3 text-danger"></i>
                        Mis inmuebles favoritos
                    </a>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-header bg-white fw-bold">Explorar catálogo</div>
                <div class="card-body">
                    <p class="text-muted">
                        Encuentre su próxima propiedad usando el buscador con filtros por ciudad,
                        tipo e inmueble y precio máximo.
                    </p>
                    <a class="btn btn-primary" href="${pageContext.request.contextPath}/propiedades">
                        <i class="fa-solid fa-magnifying-glass me-2"></i>Ir al catálogo
                    </a>
                </div>
            </div>
        </div>
    </div>
</main>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>