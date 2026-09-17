<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.List, java.util.Map" %>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/navbar.jspf" %>

<%!
    private String escapado(Object valor) {
        if (valor == null) {
            return "";
        }
        return valor.toString().replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;");
    }

    private void renderTabla(jakarta.servlet.jsp.JspWriter out, List<Map<String, Object>> datos,
            String titulo, String descripcion) throws Exception {

        out.print("<div class=\"card border-0 shadow-sm mb-4\">");
        out.print("<div class=\"card-header bg-white fw-bold\">");
        out.print("<i class=\"fa-solid fa-table me-2\"></i>" + escapado(titulo));
        if (descripcion != null && !descripcion.isEmpty()) {
            out.print("<span class=\"text-muted small fw-normal ms-2\">" + escapado(descripcion) + "</span>");
        }
        out.print("</div>");
        out.print("<div class=\"card-body p-0\">");

        if (datos == null || datos.isEmpty()) {
            out.print("<div class=\"alert alert-info text-center m-3\" role=\"alert\">");
            out.print("<i class=\"fa-solid fa-circle-info me-2\"></i>Sin datos para mostrar.</div>");
            out.print("</div></div>");
            return;
        }

        out.print("<div class=\"table-responsive\">");
        out.print("<table class=\"table table-striped table-hover align-middle mb-0\">");
        out.print("<thead class=\"table-light\"><tr>");
        for (String columna : datos.get(0).keySet()) {
            out.print("<th>" + escapado(columna) + "</th>");
        }
        out.print("</tr></thead><tbody>");
        for (Map<String, Object> fila : datos) {
            out.print("<tr>");
            for (Object valor : fila.values()) {
                out.print("<td>" + escapado(valor) + "</td>");
            }
            out.print("</tr>");
        }
        out.print("</tbody></table></div></div></div>");
    }
%>

<%
    List<Map<String, Object>> reporte1 = (List<Map<String, Object>>) request.getAttribute("reporte1");
    List<Map<String, Object>> reporte2 = (List<Map<String, Object>>) request.getAttribute("reporte2");
    List<Map<String, Object>> reporte3 = (List<Map<String, Object>>) request.getAttribute("reporte3");
    List<Map<String, Object>> reporte4 = (List<Map<String, Object>>) request.getAttribute("reporte4");
    List<Map<String, Object>> reporte5 = (List<Map<String, Object>>) request.getAttribute("reporte5");
%>

<main class="container my-5 flex-grow-1">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="fw-bold h3 mb-0">Reportes del sistema</h1>
            <p class="text-muted mb-0">Consultas con JOINs, agregaciones y métricas de trámites.</p>
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

    <div class="row mb-2">
        <div class="col-md-4">
            <div class="card border-0 shadow-sm text-bg-primary mb-4">
                <div class="card-body d-flex align-items-center justify-content-between">
                    <div>
                        <h6 class="text-uppercase opacity-75 mb-0">Inmuebles registrados</h6>
                        <span class="display-6 fw-bold"><%= reporte1 != null ? reporte1.size() : 0 %></span>
                    </div>
                    <i class="fa-solid fa-building fa-2x opacity-50"></i>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card border-0 shadow-sm text-bg-success mb-4">
                <div class="card-body d-flex align-items-center justify-content-between">
                    <div>
                        <h6 class="text-uppercase opacity-75 mb-0">Sin citas</h6>
                        <span class="display-6 fw-bold"><%= reporte3 != null ? reporte3.size() : 0 %></span>
                    </div>
                    <i class="fa-solid fa-calendar-xmark fa-2x opacity-50"></i>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card border-0 shadow-sm text-bg-warning mb-4">
                <div class="card-body d-flex align-items-center justify-content-between">
                    <div>
                        <h6 class="text-uppercase opacity-75 mb-0">Ciudades (DISPONIBLE>2)</h6>
                        <span class="display-6 fw-bold"><%= reporte4 != null ? reporte4.size() : 0 %></span>
                    </div>
                    <i class="fa-solid fa-city fa-2x opacity-50"></i>
                </div>
            </div>
        </div>
    </div>

    <%
        renderTabla(out, reporte1, "Reporte 1: Inmuebles con inmobiliaria",
                "INNER JOIN de 4 tablas (propiedad, ciudad, tipo_propiedad, inmobiliaria)");
        renderTabla(out, reporte2, "Reporte 2: Características por propiedad",
                "Relación N:M vía propiedad_caracteristica (parámetro id_propiedad).");
        renderTabla(out, reporte3, "Reporte 3: Propiedades sin citas",
                "LEFT JOIN / Anti-Join (cita.id_cita IS NULL)");
        renderTabla(out, reporte4, "Reporte 4: Propiedades DISPONIBLE por ciudad",
                "GROUP BY c.nombre con HAVING COUNT(*) > 2");
        renderTabla(out, reporte5, "Reporte 5: Trámites por estado",
                "Metrizas agrupadas por campo estado (GROUP BY)");
    %>
</main>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>