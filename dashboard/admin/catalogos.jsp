<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.List, modelos.Ciudad, modelos.TipoPropiedad, modelos.Caracteristica" %>
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
    List<Ciudad> ciudades = (List<Ciudad>) request.getAttribute("ciudades");
    List<TipoPropiedad> tipos = (List<TipoPropiedad>) request.getAttribute("tipos");
    List<Caracteristica> caracteristicas = (List<Caracteristica>) request.getAttribute("caracteristicas");

    Ciudad editandoCiudad = (Ciudad) request.getAttribute("editandoCiudad");
    TipoPropiedad editandoTipo = (TipoPropiedad) request.getAttribute("editandoTipo");
    Caracteristica editandoCaracteristica = (Caracteristica) request.getAttribute("editandoCaracteristica");
    String seccionEdicion = (String) request.getAttribute("seccionEdicion");

    String contexto = pageContext.getServletContext().getContextPath();
%>

<main class="container my-5 flex-grow-1">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="fw-bold h3 mb-0">Catálogos de administración</h1>
            <p class="text-muted mb-0">Gestión de ciudades, tipos de propiedad y características.</p>
        </div>
        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/dashboard/admin/panel.jsp">
            <i class="fa-solid fa-arrow-left me-2"></i>Volver
        </a>
    </div>

    <%-- Bloque de error de sistema DESHABILITADO: la vista nunca muestra alertas rojas.
         Si una lista está vacía, la tabla muestra su mensaje amigable de "No hay ...".
    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger" role="alert">
            <i class="fa-solid fa-triangle-exclamation me-2"></i><%= escapado(request.getAttribute("error")) %>
        </div>
    <% } %>
    --%>
    <% if (request.getAttribute("exito") != null) { %>
        <div class="alert alert-success" role="alert">
            <i class="fa-solid fa-circle-check me-2"></i><%= escapado(request.getAttribute("exito")) %>
        </div>
    <% } %>

    <ul class="nav nav-tabs mb-4" id="pestanasCatalogos" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-link <%= !"tipo".equals(seccionEdicion) && !"caracteristica".equals(seccionEdicion) ? "active" : "" %>"
                    data-bs-toggle="tab" data-bs-target="#pestanaCiudades" type="button" role="tab">
                <i class="fa-solid fa-city me-1"></i>Ciudades
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link <%= "tipo".equals(seccionEdicion) ? "active" : "" %>"
                    data-bs-toggle="tab" data-bs-target="#pestanaTipos" type="button" role="tab">
                <i class="fa-solid fa-building me-1"></i>Tipos de propiedad
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link <%= "caracteristica".equals(seccionEdicion) ? "active" : "" %>"
                    data-bs-toggle="tab" data-bs-target="#pestanaCaracteristicas" type="button" role="tab">
                <i class="fa-solid fa-star me-1"></i>Características
            </button>
        </li>
    </ul>

    <div class="tab-content">
        <div class="tab-pane fade <%= !"tipo".equals(seccionEdicion) && !"caracteristica".equals(seccionEdicion) ? "show active" : "" %>"
             id="pestanaCiudades" role="tabpanel">
            <div class="card border-0 shadow-sm mb-4">
                <div class="card-header bg-white fw-bold">Registrar / editar ciudad</div>
                <div class="card-body">
                    <form class="row g-3" method="post" action="<%= contexto %>/catalogos">
                        <input type="hidden" name="seccion" value="ciudad">
                        <input type="hidden" name="accion" value="<%= editandoCiudad != null ? "actualizar" : "crear" %>">
                        <% if (editandoCiudad != null) { %>
                        <input type="hidden" name="id" value="<%= editandoCiudad.getIdCiudad() %>">
                        <% } %>
                        <div class="col-md-5">
                            <label class="form-label" for="ciudad_nombre">Nombre *</label>
                            <input class="form-control" id="ciudad_nombre" name="nombre" required maxlength="80"
                                   value="<%= editandoCiudad != null ? escapado(editandoCiudad.getNombre()) : "" %>">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label" for="ciudad_departamento">Departamento *</label>
                            <input class="form-control" id="ciudad_departamento" name="departamento" required maxlength="80"
                                   value="<%= editandoCiudad != null ? escapado(editandoCiudad.getDepartamento()) : "" %>">
                        </div>
                        <div class="col-md-2">
                            <label class="form-label" for="ciudad_codigo">Código DANE *</label>
                            <input class="form-control" id="ciudad_codigo" name="codigo_dane" required maxlength="10"
                                   value="<%= editandoCiudad != null ? escapado(editandoCiudad.getCodigoDane()) : "" %>">
                        </div>
                        <div class="col-md-1 d-flex align-items-end justify-content-end">
                            <button class="btn btn-primary w-100" type="submit">
                                <i class="fa-solid fa-floppy-disk"></i>
                            </button>
                        </div>
                    </form>
                    <% if (editandoCiudad != null) { %>
                    <a class="small" href="<%= contexto %>/catalogos">Cancelar edición</a>
                    <% } %>
                </div>
            </div>

            <div class="card border-0 shadow-sm">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>ID</th>
                                    <th>Nombre</th>
                                    <th>Departamento</th>
                                    <th>Código DANE</th>
                                    <th class="text-end">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (ciudades != null && !ciudades.isEmpty()) {
                                        for (Ciudad c : ciudades) {
                                %>
                                <tr>
                                    <td><%= c.getIdCiudad() %></td>
                                    <td class="fw-semibold"><%= escapado(c.getNombre()) %></td>
                                    <td><%= escapado(c.getDepartamento()) %></td>
                                    <td><%= escapado(c.getCodigoDane()) %></td>
                                    <td class="text-end">
                                        <a class="btn btn-sm btn-outline-primary"
                                           href="<%= contexto %>/catalogos?editar_seccion=ciudad&editar_id=<%= c.getIdCiudad() %>">
                                            <i class="fa-solid fa-pen"></i>
                                        </a>
                                        <form class="d-inline" method="post" action="<%= contexto %>/catalogos"
                                              onsubmit="return confirm('¿Eliminar la ciudad <%= escapado(c.getNombre()) %>?');">
                                            <input type="hidden" name="seccion" value="ciudad">
                                            <input type="hidden" name="accion" value="eliminar">
                                            <input type="hidden" name="id" value="<%= c.getIdCiudad() %>">
                                            <button class="btn btn-sm btn-outline-danger" type="submit">
                                                <i class="fa-solid fa-trash"></i>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                                <%      }
                                    } else { %>
                                <tr>
                                    <td colspan="5" class="text-center py-4 text-muted">No hay ciudades registradas.</td>
                                </tr>
                                <%  } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <div class="tab-pane fade <%= "tipo".equals(seccionEdicion) ? "show active" : "" %>"
             id="pestanaTipos" role="tabpanel">
            <div class="card border-0 shadow-sm mb-4">
                <div class="card-header bg-white fw-bold">Registrar / editar tipo de propiedad</div>
                <div class="card-body">
                    <form class="row g-3" method="post" action="<%= contexto %>/catalogos">
                        <input type="hidden" name="seccion" value="tipo">
                        <input type="hidden" name="accion" value="<%= editandoTipo != null ? "actualizar" : "crear" %>">
                        <% if (editandoTipo != null) { %>
                        <input type="hidden" name="id" value="<%= editandoTipo.getIdTipo() %>">
                        <% } %>
                        <div class="col-md-4">
                            <label class="form-label" for="tipo_nombre">Nombre *</label>
                            <input class="form-control" id="tipo_nombre" name="nombre" required maxlength="60"
                                   value="<%= editandoTipo != null ? escapado(editandoTipo.getNombre()) : "" %>">
                        </div>
                        <div class="col-md-7">
                            <label class="form-label" for="tipo_descripcion">Descripción</label>
                            <input class="form-control" id="tipo_descripcion" name="descripcion" maxlength="150"
                                   value="<%= editandoTipo != null ? escapado(editandoTipo.getDescripcion()) : "" %>">
                        </div>
                        <div class="col-md-1 d-flex align-items-end justify-content-end">
                            <button class="btn btn-primary w-100" type="submit">
                                <i class="fa-solid fa-floppy-disk"></i>
                            </button>
                        </div>
                    </form>
                    <% if (editandoTipo != null) { %>
                    <a class="small" href="<%= contexto %>/catalogos">Cancelar edición</a>
                    <% } %>
                </div>
            </div>

            <div class="card border-0 shadow-sm">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>ID</th>
                                    <th>Nombre</th>
                                    <th>Descripción</th>
                                    <th class="text-end">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (tipos != null && !tipos.isEmpty()) {
                                        for (TipoPropiedad t : tipos) {
                                %>
                                <tr>
                                    <td><%= t.getIdTipo() %></td>
                                    <td class="fw-semibold"><%= escapado(t.getNombre()) %></td>
                                    <td><%= escapado(t.getDescripcion()) %></td>
                                    <td class="text-end">
                                        <a class="btn btn-sm btn-outline-primary"
                                           href="<%= contexto %>/catalogos?editar_seccion=tipo&editar_id=<%= t.getIdTipo() %>">
                                            <i class="fa-solid fa-pen"></i>
                                        </a>
                                        <form class="d-inline" method="post" action="<%= contexto %>/catalogos"
                                              onsubmit="return confirm('¿Eliminar el tipo <%= escapado(t.getNombre()) %>?');">
                                            <input type="hidden" name="seccion" value="tipo">
                                            <input type="hidden" name="accion" value="eliminar">
                                            <input type="hidden" name="id" value="<%= t.getIdTipo() %>">
                                            <button class="btn btn-sm btn-outline-danger" type="submit">
                                                <i class="fa-solid fa-trash"></i>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                                <%      }
                                    } else { %>
                                <tr>
                                    <td colspan="4" class="text-center py-4 text-muted">No hay tipos de propiedad registrados.</td>
                                </tr>
                                <%  } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <div class="tab-pane fade <%= "caracteristica".equals(seccionEdicion) ? "show active" : "" %>"
             id="pestanaCaracteristicas" role="tabpanel">
            <div class="card border-0 shadow-sm mb-4">
                <div class="card-header bg-white fw-bold">Registrar / editar característica</div>
                <div class="card-body">
                    <form class="row g-3" method="post" action="<%= contexto %>/catalogos">
                        <input type="hidden" name="seccion" value="caracteristica">
                        <input type="hidden" name="accion" value="<%= editandoCaracteristica != null ? "actualizar" : "crear" %>">
                        <% if (editandoCaracteristica != null) { %>
                        <input type="hidden" name="id" value="<%= editandoCaracteristica.getIdCaracteristica() %>">
                        <% } %>
                        <div class="col-md-5">
                            <label class="form-label" for="carac_nombre">Nombre *</label>
                            <input class="form-control" id="carac_nombre" name="nombre" required maxlength="60"
                                   value="<%= editandoCaracteristica != null ? escapado(editandoCaracteristica.getNombre()) : "" %>">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="carac_icono">Icono (Font Awesome)</label>
                            <input class="form-control" id="carac_icono" name="icono" maxlength="60"
                                   placeholder="fa-swimming-pool"
                                   value="<%= editandoCaracteristica != null ? escapado(editandoCaracteristica.getIcono()) : "" %>">
                        </div>
                        <div class="col-md-1 d-flex align-items-end justify-content-end">
                            <button class="btn btn-primary w-100" type="submit">
                                <i class="fa-solid fa-floppy-disk"></i>
                            </button>
                        </div>
                    </form>
                    <% if (editandoCaracteristica != null) { %>
                    <a class="small" href="<%= contexto %>/catalogos">Cancelar edición</a>
                    <% } %>
                </div>
            </div>

            <div class="card border-0 shadow-sm">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>ID</th>
                                    <th>Nombre</th>
                                    <th>Icono</th>
                                    <th class="text-end">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (caracteristicas != null && !caracteristicas.isEmpty()) {
                                        for (Caracteristica ca : caracteristicas) {
                                %>
                                <tr>
                                    <td><%= ca.getIdCaracteristica() %></td>
                                    <td class="fw-semibold"><%= escapado(ca.getNombre()) %></td>
                                    <td><code><%= escapado(ca.getIcono()) %></code></td>
                                    <td class="text-end">
                                        <a class="btn btn-sm btn-outline-primary"
                                           href="<%= contexto %>/catalogos?editar_seccion=caracteristica&editar_id=<%= ca.getIdCaracteristica() %>">
                                            <i class="fa-solid fa-pen"></i>
                                        </a>
                                        <form class="d-inline" method="post" action="<%= contexto %>/catalogos"
                                              onsubmit="return confirm('¿Eliminar la característica <%= escapado(ca.getNombre()) %>?');">
                                            <input type="hidden" name="seccion" value="caracteristica">
                                            <input type="hidden" name="accion" value="eliminar">
                                            <input type="hidden" name="id" value="<%= ca.getIdCaracteristica() %>">
                                            <button class="btn btn-sm btn-outline-danger" type="submit">
                                                <i class="fa-solid fa-trash"></i>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                                <%      }
                                    } else { %>
                                <tr>
                                    <td colspan="4" class="text-center py-4 text-muted">No hay características registradas.</td>
                                </tr>
                                <%  } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>