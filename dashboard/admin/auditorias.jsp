<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.List, modelos.Auditoria" %>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/navbar.jspf" %>

<%!
    private String escapado(Object valor) {
        if (valor == null) {
            return "";
        }
        return String.valueOf(valor)
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    List<Auditoria> auditorias = (List<Auditoria>) request.getAttribute("auditorias");
    String filtroAccion = (String) request.getAttribute("filtroAccion");
    String filtroTabla = (String) request.getAttribute("filtroTabla");
%>

<main class="container my-5 flex-grow-1">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="fw-bold h3 mb-0">Bitácora de auditoría</h1>
            <p class="text-muted mb-0">Registro de actividades de acceso y cambios sobre los datos del sistema.</p>
        </div>
        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/dashboard/admin/panel.jsp">
            <i class="fa-solid fa-arrow-left me-2"></i>Volver
        </a>
    </div>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger" role="alert">
            <i class="fa-solid fa-triangle-exclamation me-2"></i><%= escapado(request.getAttribute("error")) %>
        </div>
    <% } %>

    <div class="card border-0 shadow-sm mb-3">
        <div class="card-body">
            <form class="row g-3 align-items-end" method="get" action="${pageContext.request.contextPath}/auditorias">
                <div class="col-md-4">
                    <label class="form-label" for="accion">Filtrar por acción</label>
                    <select class="form-select" id="accion" name="accion">
                        <option value="">Todas las acciones</option>
                        <%
                            String[] acciones = {"INSERT", "UPDATE", "DELETE", "LOGIN", "LOGOUT"};
                            for (String a : acciones) {
                                String sel = a.equals(filtroAccion) ? " selected" : "";
                        %>
                        <option value="<%= a %>"<%= sel %>><%= a %></option>
                        <%  } %>
                    </select>
                </div>
                <div class="col-md-5">
                    <label class="form-label" for="tabla">Filtrar por tabla</label>
                    <input class="form-control" id="tabla" name="tabla" maxlength="60"
                           placeholder="Ej: propiedad, usuario, cita"
                           value="<%= escapado(filtroTabla) %>">
                </div>
                <div class="col-md-3">
                    <button class="btn btn-outline-primary w-100" type="submit">
                        <i class="fa-solid fa-filter me-1"></i>Filtrar
                    </button>
                </div>
            </form>
        </div>
    </div>

    <div class="card border-0 shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>ID</th>
                            <th>Fecha</th>
                            <th>Usuario</th>
                            <th>Tabla</th>
                            <th>Acción</th>
                            <th>Descripción</th>
                            <th>IP origen</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (auditorias != null && !auditorias.isEmpty()) {
                                for (Auditoria a : auditorias) {
                                    String badgeColor;
                                    switch (a.getAccion()) {
                                        case "INSERT": badgeColor = "success"; break;
                                        case "UPDATE": badgeColor = "warning"; break;
                                        case "DELETE": badgeColor = "danger"; break;
                                        case "LOGIN": badgeColor = "primary"; break;
                                        default: badgeColor = "secondary";
                                    }
                        %>
                        <tr>
                            <td><%= a.getIdAuditoria() %></td>
                            <td class="small"><%= a.getFechaEvento() != null ? a.getFechaEvento() : "" %></td>
                            <td><%= a.getCorreoUsuario() != null ? escapado(a.getCorreoUsuario()) : "N/D" %></td>
                            <td><code><%= escapado(a.getTablaAfectada()) %></code></td>
                            <td><span class="badge text-bg-<%= badgeColor %>"><%= escapado(a.getAccion()) %></span></td>
                            <td class="small"><%= escapado(a.getDescripcion()) %></td>
                            <td class="small"><%= escapado(a.getIpOrigen()) %></td>
                        </tr>
                        <%      }
                            } else { %>
                        <tr>
                            <td colspan="7" class="text-center py-4 text-muted">
                                <i class="fa-solid fa-scroll me-2"></i>No hay eventos de auditoría con los filtros seleccionados.
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