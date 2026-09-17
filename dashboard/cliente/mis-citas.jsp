<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.List, java.text.SimpleDateFormat, modelos.Cita" %>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/navbar.jspf" %>

<%
    List<Cita> citas = (List<Cita>) request.getAttribute("citas");
    SimpleDateFormat formatoFecha = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>

<main class="container my-5 flex-grow-1">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="fw-bold h3 mb-0">Mis citas</h1>
            <p class="text-muted mb-0">Seguimiento de las visitas que ha agendado a los inmuebles.</p>
        </div>
        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/dashboard/cliente/panel.jsp">
            <i class="fa-solid fa-arrow-left me-2"></i>Volver
        </a>
    </div>

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
                            <th>Inmobiliaria</th>
                            <th>Fecha y hora</th>
                            <th>Estado</th>
                            <th>Observaciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (citas != null && !citas.isEmpty()) {
                                for (Cita c : citas) {
                                    String estado = c.getEstado();
                                    String clase = "PENDIENTE".equals(estado) ? "warning"
                                            : ("CONFIRMADA".equals(estado) || "APROBADA".equals(estado) ? "success"
                                            : ("RECHAZADA".equals(estado) ? "danger"
                                            : ("REALIZADA".equals(estado) ? "info" : "secondary")));
                        %>
                        <tr>
                            <td class="fw-semibold"><%= c.getTituloPropiedad() %></td>
                            <td><%= c.getInmobiliaria() %></td>
                            <td><%= c.getFechaHora() != null ? formatoFecha.format(c.getFechaHora()) : "-" %></td>
                            <td><span class="badge text-bg-<%= clase %>"><%= estado %></span></td>
                            <td class="text-truncate" style="max-width: 250px;">
                                <%= c.getObservaciones() != null ? c.getObservaciones() : "-" %>
                            </td>
                        </tr>
                        <%      }
                            } else { %>
                        <tr>
                            <td colspan="5" class="text-center py-4 text-muted">
                                <i class="fa-solid fa-calendar-xmark me-2"></i>
                                Aún no tiene citas agendadas.
                            </td>
                        </tr>
                        <%  } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <div class="text-center mt-4">
        <a class="btn btn-primary" href="${pageContext.request.contextPath}/propiedades">
            <i class="fa-solid fa-plus me-2"></i>Agendar nueva cita
        </a>
    </div>
</main>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>