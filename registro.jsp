<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/navbar.jspf" %>

<%
    String nombres = (String) request.getAttribute("nombres");
    String apellidos = (String) request.getAttribute("apellidos");
    String correo = (String) request.getAttribute("correo");
    String documento = (String) request.getAttribute("documento");
    String telefono = (String) request.getAttribute("telefono");
    String direccion = (String) request.getAttribute("direccion");
%>

<main class="container my-5 flex-grow-1">
    <div class="row justify-content-center">
        <div class="col-md-8 col-lg-6 col-xl-5">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-primary text-white text-center py-3">
                    <i class="fa-solid fa-user-plus fa-2x mb-2"></i>
                    <h1 class="h4 mb-0">Crear una cuenta</h1>
                    <p class="small opacity-75 mb-0">Únase a Inmobiliaria UTS para gestionar sus trámites</p>
                </div>
                <div class="card-body p-4">
                    <% if (request.getAttribute("error") != null && !String.valueOf(request.getAttribute("error")).isBlank()) { %>
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fa-solid fa-circle-exclamation me-2"></i>
                            <%= request.getAttribute("error") %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Cerrar"></button>
                        </div>
                    <% } %>

                    <form action="${pageContext.request.contextPath}/RegistroServlet" method="POST" id="formRegistro" novalidate>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label" for="nombres">Nombres</label>
                                <input type="text" name="nombres" id="nombres" class="form-control" required
                                       maxlength="80" value="<%= nombres != null ? nombres : "" %>"
                                       placeholder="Sus nombres">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label" for="apellidos">Apellidos</label>
                                <input type="text" name="apellidos" id="apellidos" class="form-control" required
                                       maxlength="80" value="<%= apellidos != null ? apellidos : "" %>"
                                       placeholder="Sus apellidos">
                            </div>
                            <div class="col-12">
                                <label class="form-label" for="correo">Correo electrónico</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fa-solid fa-envelope"></i></span>
                                    <input type="email" name="correo" id="correo" class="form-control" required
                                           maxlength="120" value="<%= correo != null ? correo : "" %>"
                                           placeholder="usuario@correo.com">
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label" for="documento">Documento</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fa-solid fa-id-card"></i></span>
                                    <input type="text" name="documento" id="documento" class="form-control"
                                           maxlength="20" value="<%= documento != null ? documento : "" %>"
                                           placeholder="1098765432">
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label" for="telefono">Teléfono</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fa-solid fa-phone"></i></span>
                                    <input type="tel" name="telefono" id="telefono" class="form-control"
                                           maxlength="20" value="<%= telefono != null ? telefono : "" %>"
                                           placeholder="3101234567">
                                </div>
                            </div>
                            <div class="col-12">
                                <label class="form-label" for="direccion">Dirección</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fa-solid fa-location-dot"></i></span>
                                    <input type="text" name="direccion" id="direccion" class="form-control"
                                           maxlength="150" value="<%= direccion != null ? direccion : "" %>"
                                           placeholder="Calle 12 #34-56, Bucaramanga">
                                </div>
                            </div>
                            <div class="col-12">
                                <label class="form-label" for="clave">Contraseña</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fa-solid fa-lock"></i></span>
                                    <input type="password" name="contrasena" id="clave" class="form-control" required
                                           minlength="6" placeholder="Mínimo 6 caracteres">
                                </div>
                            </div>
                            <div class="col-12">
                                <div class="alert alert-light border d-flex align-items-center mb-0">
                                    <i class="fa-solid fa-user-tag me-3 text-primary"></i>
                                    <div>
                                        <strong>Rol asignado: Cliente</strong>
                                        <p class="text-muted small mb-0">
                                            Su cuenta se creará con el rol Cliente. Puede consultar el catálogo,
                                            agendar citas y radicar solicitudes.
                                        </p>
                                    </div>
                                </div>
                            </div>
                            <div class="col-12 mt-4">
                                <div class="d-grid">
                                    <button type="submit" class="btn btn-primary btn-lg">
                                        <i class="fa-solid fa-user-check me-2"></i>Registrarse
                                    </button>
                                </div>
                            </div>
                        </div>
                    </form>

                    <hr class="my-4">

                    <p class="text-center text-muted mb-0">
                        ¿Ya tiene una cuenta?
                        <a class="fw-semibold text-primary text-decoration-none"
                           href="${pageContext.request.contextPath}/login.jsp">Iniciar sesión</a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</main>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>