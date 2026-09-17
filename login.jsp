<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/navbar.jspf" %>

<main class="container my-5 flex-grow-1">
    <div class="row justify-content-center align-items-center">
        <div class="col-md-6 col-lg-5 col-xl-4">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-primary text-white text-center py-3">
                    <i class="fa-solid fa-door-open fa-2x mb-2"></i>
                    <h1 class="h4 mb-0">Iniciar sesión</h1>
                    <p class="small opacity-75 mb-0">Acceda a su cuenta de Inmobiliaria UTS</p>
                </div>
                <div class="card-body p-4">
                    <% if (request.getAttribute("error") != null && !String.valueOf(request.getAttribute("error")).isBlank()) { %>
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fa-solid fa-circle-exclamation me-2"></i>
                            <%= request.getAttribute("error") %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Cerrar"></button>
                        </div>
                    <% } %>

                    <%
                        String mensajeExito = (String) request.getAttribute("mensaje");
                        if (mensajeExito == null || mensajeExito.isBlank()) {
                            mensajeExito = (String) session.getAttribute("mensaje");
                            if (mensajeExito != null) {
                                session.removeAttribute("mensaje");
                            }
                        }
                    %>
                    <% if (mensajeExito != null && !mensajeExito.isBlank()) { %>
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <i class="fa-solid fa-circle-check me-2"></i>
                            <%= mensajeExito %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Cerrar"></button>
                        </div>
                    <% } %>

                    <form action="${pageContext.request.contextPath}/LoginServlet" method="POST" id="formLogin" novalidate>
                        <div class="mb-3">
                            <label class="form-label" for="correo">Correo electrónico</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fa-solid fa-envelope"></i></span>
                                <input type="email" name="correo" id="correo" class="form-control" required
                                       placeholder="usuario@correo.com">
                            </div>
                        </div>
                        <div class="mb-4">
                            <label class="form-label" for="clave">Contraseña</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fa-solid fa-lock"></i></span>
                                <input type="password" name="contrasena" id="clave" class="form-control" required
                                       placeholder="••••••••">
                            </div>
                        </div>
                        <div class="d-grid">
                            <button type="submit" class="btn btn-primary btn-lg">
                                <i class="fa-solid fa-right-to-bracket me-2"></i>Entrar
                            </button>
                        </div>
                    </form>

                    <hr class="my-4">

                    <p class="text-center text-muted mb-0">
                        ¿No tiene una cuenta?
                        <a class="fw-semibold text-primary text-decoration-none"
                           href="${pageContext.request.contextPath}/registro.jsp">Regístrese aquí</a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</main>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>