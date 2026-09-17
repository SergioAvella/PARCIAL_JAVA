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
            <h1 class="fw-bold h3 mb-0">Revisar solicitudes</h1>
            <p class="text-muted mb-0">Evalúe los trámites y documentos descargados de los clientes.</p>
        </div>
        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/dashboard/agente/panel.jsp">
            <i class="fa-solid fa-arrow-left me-2"></i>Volver
        </a>
    </div>

    <%-- Bloque de error de sistema DESHABILITADO: la vista nunca muestra alertas rojas.
         Si la lista está vacía se muestra el mensaje amigable de "No hay solicitudes pendientes de revisión".
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
                            <th>ID</th>
                            <th>Inmueble</th>
                            <th>Cliente</th>
                            <th>Tipo</th>
                            <th>Fecha</th>
                            <th>Estado</th>
                            <th>Observaciones</th>
                            <th class="text-end">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (solicitudes != null && !solicitudes.isEmpty()) {
                                for (Solicitud s : solicitudes) {
                                    String estado = s.getEstado();
                                    String tipo = s.getTipo();
                                    String clase = "APROBADA".equals(estado) ? "success"
                                            : ("RECHAZADA".equals(estado) ? "danger"
                                            : ("RADICADA".equals(estado) ? "secondary"
                                            : ("EN_REVISION".equals(estado) ? "warning" : "info")));
                        %>
                        <tr>
                            <td><%= s.getIdSolicitud() %></td>
                            <td class="fw-semibold"><%= s.getTituloPropiedad() %></td>
                            <td><%= s.getNombreCliente() %> <%= s.getApellidoCliente() %></td>
                            <td><span class="badge text-bg-light border"><%= tipo %></span></td>
                            <td><%= s.getFechaSolicitud() != null ? formatoFecha.format(s.getFechaSolicitud()) : "-" %></td>
                            <td><span class="badge text-bg-<%= clase %>"><%= estado %></span></td>
                            <td class="text-truncate" style="max-width: 200px;"><%= s.getObservaciones() != null ? s.getObservaciones() : "-" %></td>
                            <td class="text-end">
                                <div class="d-inline-flex gap-1">
                                    <form method="post" action="${pageContext.request.contextPath}/SolicitudServlet">
                                        <input type="hidden" name="accion" value="cambiar_estado">
                                        <input type="hidden" name="id_solicitud" value="<%= s.getIdSolicitud() %>">
                                        <input type="hidden" name="estado" value="APROBADO">
                                        <button class="btn btn-sm btn-outline-success confirmar-accion" type="submit"
                                                data-mensaje="¿Aprobar esta solicitud?"
                                                <%= "APROBADA".equals(estado) || "RECHAZADA".equals(estado) ? "disabled" : "" %>>
                                            <i class="fa-solid fa-check"></i> Aprobar
                                        </button>
                                    </form>
                                    <form method="post" action="${pageContext.request.contextPath}/SolicitudServlet">
                                        <input type="hidden" name="accion" value="cambiar_estado">
                                        <input type="hidden" name="id_solicitud" value="<%= s.getIdSolicitud() %>">
                                        <input type="hidden" name="estado" value="RECHAZADO">
                                        <button class="btn btn-sm btn-outline-danger confirmar-accion" type="submit"
                                                data-mensaje="¿Rechazar esta solicitud?"
                                                <%= "APROBADA".equals(estado) || "RECHAZADA".equals(estado) ? "disabled" : "" %>>
                                            <i class="fa-solid fa-xmark"></i> Rechazar
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                        <%      }
                            } else { %>
                        <tr>
                            <td colspan="8" class="text-center py-4 text-muted">
                                <i class="fa-solid fa-inbox me-2"></i>
                                No hay solicitudes pendientes de revisión.
                            </td>
                        </tr>
                        <%  } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>