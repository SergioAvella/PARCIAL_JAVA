<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.List, java.util.Map" %>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/navbar.jspf" %>

<%
    List<Map<String, Object>> usuarios = (List<Map<String, Object>>) request.getAttribute("usuarios");
    List<Map<String, Object>> roles = (List<Map<String, Object>>) request.getAttribute("roles");
%>

<main class="container my-5 flex-grow-1">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="fw-bold h3 mb-0">Gestión de usuarios</h1>
            <p class="text-muted mb-0">Asigne roles y controle el estado de las cuentas.</p>
        </div>
        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/dashboard/admin/panel.jsp">
            <i class="fa-solid fa-arrow-left me-2"></i>Volver
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

    <div class="card border-0 shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>ID</th>
                            <th>Correo</th>
                            <th>Nombres</th>
                            <th>Apellidos</th>
                            <th>Teléfono</th>
                            <th>Estado</th>
                            <th>Roles</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (usuarios != null && !usuarios.isEmpty()) {
                                for (Map<String, Object> u : usuarios) {
                        %>
                        <tr>
                            <td><%= u.get("id_usuario") %></td>
                            <td><%= u.get("correo") %></td>
                            <td><%= u.get("nombres") %></td>
                            <td><%= u.get("apellidos") %></td>
                            <td><%= u.get("telefono") != null ? u.get("telefono") : "-" %></td>
                            <td>
                                <span class="badge text-bg-<%= "ACTIVO".equals(u.get("estado")) ? "success" : ("BLOQUEADO".equals(u.get("estado")) ? "danger" : "secondary") %>">
                                    <%= u.get("estado") %>
                                </span>
                            </td>
                            <td>
                                <div class="d-flex flex-wrap gap-1 align-items-center">
                                    <form class="d-inline" method="post"
                                          action="${pageContext.request.contextPath}/UsuarioServlet">
                                        <input type="hidden" name="accion" value="asignar_rol">
                                        <input type="hidden" name="id_usuario" value="<%= u.get("id_usuario") %>">
                                        <select class="form-select form-select-sm d-inline-block w-auto" name="id_rol">
                                            <%
                                                if (roles != null) {
                                                    for (Map<String, Object> r : roles) {
                                                        boolean actual = (u.get("id_rol") != null
                                                                && String.valueOf(u.get("id_rol")).equals(String.valueOf(r.get("id_rol"))));
                                            %>
                                            <option value="<%= r.get("id_rol") %>" <%= actual ? "selected" : "" %>><%= r.get("nombre") %></option>
                                            <%      }
                                                }
                                            %>
                                        </select>
                                        <button class="btn btn-sm btn-outline-primary" type="submit">
                                            <i class="fa-solid fa-user-shield"></i>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                        <%      }
                            } else { %>
                        <tr>
                            <td colspan="7" class="text-center py-4 text-muted">
                                <i class="fa-solid fa-users me-2"></i>No hay usuarios para mostrar. Exponga la lista en el atributo <code>usuarios</code>.
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