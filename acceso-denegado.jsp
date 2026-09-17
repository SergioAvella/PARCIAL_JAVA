<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/navbar.jspf" %>

<main class="container my-5 flex-grow-1">
    <div class="row justify-content-center">
        <div class="col-md-8 col-lg-6">
            <div class="alert alert-danger shadow-sm p-5 text-center" role="alert">
                <i class="fa-solid fa-lock fa-3x mb-3 text-danger"></i>
                <h1 class="display-4 fw-bold text-danger">403</h1>
                <h2 class="h4 fw-semibold">Acceso denegado</h2>
                <p class="text-muted mb-4">
                    No tiene permisos suficientes para acceder a este recurso.
                    Si considera que esto es un error, contacte al administrador del sistema.
                </p>
                <div class="d-flex justify-content-center gap-2">
                    <a class="btn btn-primary" href="${pageContext.request.contextPath}/">
                        <i class="fa-solid fa-house me-2"></i>Volver al inicio
                    </a>
                    <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/login.jsp">
                        Iniciar sesión
                    </a>
                </div>
            </div>
        </div>
    </div>
</main>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>