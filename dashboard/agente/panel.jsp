<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.List, java.text.NumberFormat, java.util.Locale, modelos.Propiedad" %>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/navbar.jspf" %>

<%
    NumberFormat formatoPrecio = NumberFormat.getCurrencyInstance(new Locale("es", "CO"));
    List<Propiedad> propiedades =
            (List<Propiedad>) request.getAttribute("propiedades");
    String usuarioSesion = String.valueOf(session.getAttribute("usuario"));
%>

<main class="container my-5 flex-grow-1">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="fw-bold h3 mb-0">Panel de la Inmobiliaria</h1>
            <p class="text-muted mb-0">Bienvenido, <%= usuarioSesion %></p>
        </div>
        <a class="btn btn-primary" href="${pageContext.request.contextPath}/mantenimiento-propiedad">
            <i class="fa-solid fa-plus me-2"></i>Publicar inmueble
        </a>
    </div>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger" role="alert">
            <i class="fa-solid fa-triangle-exclamation me-2"></i><%= request.getAttribute("error") %>
        </div>
    <% } %>

    <div class="card border-0 shadow-sm">
        <div class="card-header bg-white fw-bold">
            <i class="fa-solid fa-building me-2"></i>Inmuebles gestionados por la agencia
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>ID</th>
                            <th>Título</th>
                            <th>Ciudad</th>
                            <th>Precio</th>
                            <th>Área m²</th>
                            <th>Estado</th>
                            <th class="text-end">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (propiedades != null && !propiedades.isEmpty()) {
                                for (Propiedad p : propiedades) {
                        %>
                        <tr>
                            <td><%= p.getIdPropiedad() %></td>
                            <td class="fw-semibold"><%= p.getTitulo() %></td>
                            <td><%= p.getCiudad() %></td>
                            <td class="text-success fw-semibold"><%= formatoPrecio.format(p.getPrecio()) %></td>
                            <td><%= p.getAreaM2() %></td>
                            <td>
                                <span class="badge text-bg-<%= "DISPONIBLE".equals(p.getEstado()) ? "success" : ("RESERVADA".equals(p.getEstado()) ? "warning" : "secondary") %>">
                                    <%= p.getEstado() %>
                                </span>
                            </td>
                            <td class="text-end">
                                <a class="btn btn-sm btn-outline-secondary"
                                   href="${pageContext.request.contextPath}/detalle-propiedad.jsp?id=<%= p.getIdPropiedad() %>">
                                    <i class="fa-solid fa-eye"></i>
                                </a>
                                <a class="btn btn-sm btn-outline-primary"
                                   href="${pageContext.request.contextPath}/mantenimiento-propiedad?id=<%= p.getIdPropiedad() %>">
                                    <i class="fa-solid fa-pen"></i>
                                </a>
                            </td>
                        </tr>
                        <%      }
                            } else { %>
                        <tr>
                            <td colspan="7" class="text-center py-4 text-muted">
                                <i class="fa-solid fa-circle-info me-2"></i>
                                Aún no hay inmuebles públicos. Consulte la lista a través de
                                <code>PropiedadServlet</code> (atributo <code>propiedades</code>).
                            </td>
                        </tr>
                        <%  } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="row g-4 mt-1">
        <div class="col-md-6">
            <a class="card border-0 shadow-sm text-decoration-none card-hover" href="${pageContext.request.contextPath}/CitaServlet">
                <div class="card-body d-flex align-items-center">
                    <i class="fa-solid fa-calendar-check fa-2x text-primary me-3"></i>
                    <div>
                        <h6 class="fw-bold mb-0">Gestor de citas</h6>
                        <small class="text-muted">Aprobar o rechazar visitas agendadas.</small>
                    </div>
                </div>
            </a>
        </div>
        <div class="col-md-6">
            <a class="card border-0 shadow-sm text-decoration-none card-hover" href="${pageContext.request.contextPath}/SolicitudServlet">
                <div class="card-body d-flex align-items-center">
                    <i class="fa-solid fa-folder-open fa-2x text-success me-3"></i>
                    <div>
                        <h6 class="fw-bold mb-0">Revisar solicitudes</h6>
                        <small class="text-muted">Evaluar documentos y trámites de clientes.</small>
                    </div>
                </div>
            </a>
        </div>
    </div>
</main>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>