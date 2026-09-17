<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.List, java.util.Map, java.text.NumberFormat, java.util.Locale" %>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/navbar.jspf" %>

<%
    List<Map<String, Object>> favoritos = (List<Map<String, Object>>) request.getAttribute("favoritos");
    NumberFormat formatoPrecio = NumberFormat.getCurrencyInstance(new Locale("es", "CO"));
%>

<main class="container my-5 flex-grow-1">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="fw-bold h3 mb-0">Mis favoritos</h1>
            <p class="text-muted mb-0">Inmuebles guardados para revisarlos más adelante.</p>
        </div>
        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/dashboard/cliente/panel.jsp">
            <i class="fa-solid fa-arrow-left me-2"></i>Volver
        </a>
    </div>

    <%-- Bloques de error de sistema DESHABILITADOS: la vista nunca muestra alertas rojas.
         Si la lista está vacía se muestra el mensaje amigable de "Todavía no tiene inmuebles favoritos".
    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger" role="alert">
            <i class="fa-solid fa-triangle-exclamation me-2"></i><%= request.getAttribute("error") %>
        </div>
    <% } %>
    <% if (session.getAttribute("error") != null) { %>
        <div class="alert alert-danger" role="alert">
            <i class="fa-solid fa-triangle-exclamation me-2"></i><%= session.getAttribute("error") %>
        </div>
        <% session.removeAttribute("error"); %>
    <% } %>
    --%>
    <% if (session.getAttribute("exito") != null) { %>
        <div class="alert alert-success" role="alert">
            <i class="fa-solid fa-circle-check me-2"></i><%= session.getAttribute("exito") %>
        </div>
        <% session.removeAttribute("exito"); %>
    <% } %>

    <div class="row g-4">
        <%
            if (favoritos != null && !favoritos.isEmpty()) {
                for (Map<String, Object> f : favoritos) {
        %>
        <div class="col-sm-6 col-lg-4">
            <div class="card h-100 border-0 shadow-sm">
                <div class="bg-secondary d-flex align-items-center justify-content-center text-white"
                     style="height: 160px;">
                    <i class="fa-solid fa-building fa-2x"></i>
                </div>
                <div class="card-body">
                    <span class="badge text-bg-primary mb-2"><%= f.get("tipo_propiedad") %></span>
                    <h5 class="card-title text-truncate"><%= f.get("titulo") %></h5>
                    <p class="text-muted small mb-1">
                        <i class="fa-solid fa-location-dot me-1"></i><%= f.get("ciudad") %>
                    </p>
                    <p class="text-success fw-semibold mb-2"><%= formatoPrecio.format(f.get("precio")) %></p>
                    <% if (f.get("habitaciones") != null && f.get("banos") != null) { %>
                    <p class="text-muted small mb-0">
                        <i class="fa-solid fa-bed me-1"></i><%= f.get("habitaciones") %> hab.
                        <i class="fa-solid fa-bath ms-2 me-1"></i><%= f.get("banos") %> baños
                    </p>
                    <% } %>
                </div>
                <div class="card-footer bg-white border-top-0 d-flex gap-2">
                    <a class="btn btn-outline-primary btn-sm flex-grow-1"
                       href="${pageContext.request.contextPath}/detalle-propiedad.jsp?id=<%= f.get("id_propiedad") %>&amp;titulo=<%= f.get("titulo") %>">
                        <i class="fa-solid fa-eye me-1"></i>Ver
                    </a>
                    <form method="post" action="${pageContext.request.contextPath}/FavoritoServlet">
                        <input type="hidden" name="accion" value="quitar">
                        <input type="hidden" name="id_propiedad" value="<%= f.get("id_propiedad") %>">
                        <button class="btn btn-outline-danger btn-sm" type="submit"
                                title="Quitar de favoritos">
                            <i class="fa-solid fa-heart-crack"></i>
                        </button>
                    </form>
                </div>
            </div>
        </div>
        <%      }
            } else { %>
        <div class="col-12">
            <div class="alert alert-info text-center py-5" role="alert">
                <i class="fa-solid fa-heart-circle-plus fa-2x mb-3"></i>
                <h4>Todavía no tiene inmuebles favoritos</h4>
                <p class="mb-0">Explore el catálogo y guarde las propiedades que le interesen.</p>
            </div>
        </div>
        <%  } %>
    </div>
</main>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>