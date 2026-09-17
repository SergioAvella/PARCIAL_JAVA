<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.List, java.text.SimpleDateFormat, modelos.Solicitud" %>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/navbar.jspf" %>

<%
    List<Solicitud> solicitudes = (List<Solicitud>) request.getAttribute("solicitudes");
    SimpleDateFormat formatoFecha = new SimpleDateFormat("dd/MM/yyyy");
%>

<main class="container my-5 flex-grow-1">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="fw-bold h3 mb-0">Mis solicitudes</h1>
            <p class="text-muted mb-0">Radicación de trámites y consulta del estado de sus documentos.</p>
        </div>
        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/dashboard/cliente/panel.jsp">
            <i class="fa-solid fa-arrow-left me-2"></i>Volver
        </a>
    </div>

    <%-- Bloque de error de sistema DESHABILITADO: la vista nunca muestra alertas rojas.
         Si la lista está vacía se muestra el mensaje amigable de "Aún no ha radicado solicitudes".
    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger" role="alert">
            <i class="fa-solid fa-triangle-exclamation me-2"></i><%= request.getAttribute("error") %>
        </div>
    <% } %>
    --%>
    <% if (session.getAttribute("exito") != null) { %>
        <div class="alert alert-success" role="alert">
            <i class="fa-solid fa-circle-check me-2"></i><%= session.getAttribute("exito") %>
        </div>
        <% session.removeAttribute("exito"); %>
    <% } %>

    <div class="card border-0 shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Inmueble</th>
                            <th>Tipo</th>
                            <th>Fecha</th>
                            <th>Estado</th>
                            <th>Observaciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (solicitudes != null && !solicitudes.isEmpty()) {
                                for (Solicitud s : solicitudes) {
                                    String estado = s.getEstado();
                                    String tipo = s.getTipo();
                                    String clase = "APROBADO".equals(estado) || "APROBADA".equals(estado) ? "success"
                                            : ("RECHAZADO".equals(estado) || "RECHAZADA".equals(estado) ? "danger"
                                            : ("CERRADA".equals(estado) ? "info"
                                            : ("PENDIENTE".equals(estado) || "EN_REVISION".equals(estado) ? "warning" : "secondary")));
                        %>
                        <tr>
                            <td class="fw-semibold"><%= s.getTituloPropiedad() %></td>
                            <td><span class="badge text-bg-light border"><%= tipo %></span></td>
                            <td><%= s.getFechaSolicitud() != null ? formatoFecha.format(s.getFechaSolicitud()) : "-" %></td>
                            <td><span class="badge text-bg-<%= clase %>"><%= estado %></span></td>
                            <td class="text-truncate" style="max-width: 250px;">
                                <%= s.getObservaciones() != null ? s.getObservaciones() : "-" %>
                            </td>
                        </tr>
                        <%      }
                            } else { %>
                        <tr>
                            <td colspan="5" class="text-center py-4 text-muted">
                                <i class="fa-solid fa-inbox me-2"></i>
                                Aún no ha radicado solicitudes.
                            </td>
                        </tr>
                        <%  } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <div class="alert alert-light border mt-4 d-flex align-items-center">
        <i class="fa-solid fa-cloud-arrow-up fa-2x me-3 text-primary"></i>
        <div>
            <h6 class="mb-1">Suba sus documentos desde la ficha de cada inmueble</h6>
            <p class="text-muted small mb-0">
                Al radicar una solicitud desde <code>detalle-propiedad.jsp</code> se genera un documento soporte
                con estado <code>PENDIENTE</code> que la inmobiliaria podrá aprobar o rechazar.
            </p>
        </div>
    </div>
</main>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>