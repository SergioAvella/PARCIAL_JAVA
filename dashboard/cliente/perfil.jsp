<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/navbar.jspf" %>

<%
    String nombre = (String) request.getAttribute("nombre");
    String apellido = (String) request.getAttribute("apellido");
    String telefono = (String) request.getAttribute("telefono");
    String direccion = (String) request.getAttribute("direccion");
%>

<main class="container my-5 flex-grow-1">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="fw-bold h3 mb-0">Mi perfil</h1>
            <p class="text-muted mb-0">Datos personales asociados a su cuenta (relación 1:1 con su usuario).</p>
        </div>
        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/dashboard/cliente/panel.jsp">
            <i class="fa-solid fa-arrow-left me-2"></i>Volver
        </a>
    </div>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger" role="alert">
            <i class="fa-solid fa-triangle-exclamation me-2"></i><%= request.getAttribute("error") %>
        </div>
    <% } %>
    <% if (request.getAttribute("mensaje") != null) { %>
        <div class="alert alert-success" role="alert">
            <i class="fa-solid fa-circle-check me-2"></i><%= request.getAttribute("mensaje") %>
        </div>
    <% } %>

    <div class="row justify-content-center">
        <div class="col-lg-8">
            <form class="card border-0 shadow-sm" method="post"
                  action="${pageContext.request.contextPath}/PerfilServlet">
                <div class="card-header bg-white fw-bold">
                    <i class="fa-solid fa-id-card me-2"></i>Información personal
                </div>
                <div class="card-body p-4">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label" for="nombre">Nombres *</label>
                            <input class="form-control" id="nombre" name="nombre" required maxlength="80"
                                   value="<%= nombre != null ? nombre : "" %>" placeholder="Sus nombres">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="apellido">Apellidos *</label>
                            <input class="form-control" id="apellido" name="apellido" required maxlength="80"
                                   value="<%= apellido != null ? apellido : "" %>" placeholder="Sus apellidos">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="telefono">Teléfono</label>
                            <input class="form-control" id="telefono" name="telefono" maxlength="20"
                                   value="<%= telefono != null ? telefono : "" %>" placeholder="3101234567">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="direccion">Dirección</label>
                            <input class="form-control" id="direccion" name="direccion" maxlength="150"
                                   value="<%= direccion != null ? direccion : "" %>" placeholder="Calle 8 # 4-20">
                        </div>
                        <div class="col-12">
                            <div class="alert alert-light border small mb-0">
                                <i class="fa-solid fa-circle-info me-2 text-primary"></i>
                                El correo de la cuenta no se puede modificar desde este formulario.
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-footer bg-white d-flex justify-content-end gap-2">
                    <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/dashboard/cliente/panel.jsp">Cancelar</a>
                    <button type="submit" class="btn btn-primary">
                        <i class="fa-solid fa-floppy-disk me-2"></i>Guardar cambios
                    </button>
                </div>
            </form>
        </div>
    </div>
</main>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>