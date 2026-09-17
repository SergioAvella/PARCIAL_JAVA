<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
    import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet, java.sql.SQLException,
            java.util.ArrayList, java.util.LinkedHashMap, java.util.List, java.util.Map,
            java.text.NumberFormat, java.util.Locale, java.net.URLEncoder,
            config.ConexionBD, modelos.Propiedad" %>
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
    NumberFormat formatoPrecio = NumberFormat.getCurrencyInstance(new Locale("es", "CO"));
    List<Propiedad> propiedades =
            (List<Propiedad>) request.getAttribute("propiedades");
    String filtroCiudad = (String) request.getAttribute("filtroCiudad");
    String filtroTipo = (String) request.getAttribute("filtroTipo");
    String filtroPrecioMaximo = (String) request.getAttribute("filtroPrecioMaximo");
    List<Map<String, Object>> listaCiudades =
            (List<Map<String, Object>>) request.getAttribute("listaCiudades");
    List<Map<String, Object>> listaTipos =
            (List<Map<String, Object>>) request.getAttribute("listaTipos");

    // Al acceder a la raiz (/) la pagina se sirve como welcome-file sin pasar por
    // /propiedades; aqui se cargan los datos para que el catalogo no quede vacio.
    if (propiedades == null) {
        try (Connection conexion = ConexionBD.getConexion()) {

            try (PreparedStatement sentencia = conexion.prepareStatement(
                    "SELECT id_ciudad, nombre FROM ciudad ORDER BY nombre");
                    ResultSet resultado = sentencia.executeQuery()) {
                listaCiudades = new ArrayList<>();
                while (resultado.next()) {
                    Map<String, Object> ciudad = new LinkedHashMap<>();
                    ciudad.put("id", resultado.getInt("id_ciudad"));
                    ciudad.put("nombre", resultado.getString("nombre"));
                    listaCiudades.add(ciudad);
                }
            }

            try (PreparedStatement sentencia = conexion.prepareStatement(
                    "SELECT id_tipo, nombre FROM tipo_propiedad ORDER BY nombre");
                    ResultSet resultado = sentencia.executeQuery()) {
                listaTipos = new ArrayList<>();
                while (resultado.next()) {
                    Map<String, Object> tipo = new LinkedHashMap<>();
                    tipo.put("id", resultado.getInt("id_tipo"));
                    tipo.put("nombre", resultado.getString("nombre"));
                    listaTipos.add(tipo);
                }
            }

            try (PreparedStatement sentencia = conexion.prepareStatement(
                    "SELECT p.id_propiedad, p.titulo, p.direccion, p.matricula_inmobiliaria, "
                  + "p.precio, p.estado, "
                  + "c.nombre AS ciudad, tp.nombre AS tipo_propiedad, "
                  + "COALESCE(ip.url, '/uploads/propiedades/sin-imagen.png') AS imagen_url "
                  + "FROM propiedad p "
                  + "LEFT JOIN ciudad c ON c.id_ciudad = p.id_ciudad "
                  + "LEFT JOIN tipo_propiedad tp ON tp.id_tipo = p.id_tipo "
                  + "LEFT JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria "
                  + "LEFT JOIN imagen_propiedad ip ON ip.id_propiedad = p.id_propiedad AND ip.es_principal = 1 "
                  + "WHERE p.estado = 'DISPONIBLE' "
                  + "ORDER BY p.id_propiedad DESC");
                    ResultSet resultado = sentencia.executeQuery()) {
                propiedades = new ArrayList<>();
                while (resultado.next()) {
                    Propiedad propiedad = new Propiedad();
                    propiedad.setIdPropiedad(resultado.getInt("id_propiedad"));
                    propiedad.setTitulo(resultado.getString("titulo"));
                    propiedad.setDireccion(resultado.getString("direccion"));
                    propiedad.setMatriculaInmobiliaria(resultado.getString("matricula_inmobiliaria"));
                    propiedad.setPrecio(resultado.getBigDecimal("precio"));
                    propiedad.setEstado(resultado.getString("estado"));
                    propiedad.setCiudad(resultado.getString("ciudad"));
                    propiedad.setTipoPropiedad(resultado.getString("tipo_propiedad"));
                    propiedad.setImagen(resultado.getString("imagen_url"));
                    propiedades.add(propiedad);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            // Sin mensaje de error de sistema: se garantizan listas vacías para la vista.
            if (propiedades == null) {
                propiedades = new ArrayList<>();
            }
            if (listaCiudades == null) {
                listaCiudades = new ArrayList<>();
            }
            if (listaTipos == null) {
                listaTipos = new ArrayList<>();
            }
        }
    }
%>

<section class="bg-primary bg-gradient text-white py-5">
    <div class="container">
        <div class="row justify-content-center text-center">
            <div class="col-lg-8">
                <h1 class="display-5 fw-bold">Encuentra la propiedad de tus sueños</h1>
                <p class="lead mb-4">Apartamentos, casas, locales y más, publicados por inmobiliarias confiables.</p>
            </div>
        </div>
        <div class="row justify-content-center">
            <div class="col-lg-10">
                <form class="row g-2 shadow p-3 bg-white rounded-3" method="get"
                      action="${pageContext.request.contextPath}/propiedades">
                    <div class="col-md-4">
                        <label class="form-label fw-semibold text-dark" for="id_ciudad">Ciudad</label>
                        <select class="form-select" id="id_ciudad" name="id_ciudad">
                            <option value="">Todas las ciudades</option>
                            <%
                                if (listaCiudades != null) {
                                    for (Map<String, Object> ciudad : listaCiudades) {
                                        String id = String.valueOf(ciudad.get("id"));
                                        String nombre = String.valueOf(ciudad.get("nombre"));
                                        String seleccionada = id.equals(filtroCiudad) ? " selected" : "";
                            %>
                            <option value="<%= escapado(id) %>"<%= seleccionada %>><%= escapado(nombre) %></option>
                            <%      }
                                }
                            %>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold text-dark" for="id_tipo_propiedad">Tipo de propiedad</label>
                        <select class="form-select" id="id_tipo_propiedad" name="id_tipo_propiedad">
                            <option value="">Todos los tipos</option>
                            <%
                                if (listaTipos != null) {
                                    for (Map<String, Object> tipo : listaTipos) {
                                        String id = String.valueOf(tipo.get("id"));
                                        String nombre = String.valueOf(tipo.get("nombre"));
                                        String seleccionada = id.equals(filtroTipo) ? " selected" : "";
                            %>
                            <option value="<%= escapado(id) %>"<%= seleccionada %>><%= escapado(nombre) %></option>
                            <%      }
                                }
                            %>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold text-dark" for="precio_maximo">Precio máximo</label>
                        <div class="input-group">
                            <span class="input-group-text">$</span>
                            <input type="number" step="1000000" min="0" class="form-control" id="precio_maximo"
                                   name="precio_maximo" placeholder="Ej: 500000000"
                                   value="<%= escapado(filtroPrecioMaximo) %>">
                            <button class="btn btn-outline-primary" type="submit">
                                <i class="fa-solid fa-magnifying-glass me-1"></i>Buscar
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</section>

<main class="container my-5 flex-grow-1">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold mb-0">Catálogo de inmuebles</h2>
        <span class="text-secondary small">
            <%= (propiedades != null ? propiedades.size() : 0) %> propiedades encontradas
        </span>
    </div>

    <%-- Bloque de error de sistema DESHABILITADO: la vista nunca muestra alertas rojas.
         Si no hay propiedades o la base falla, se muestra el estado vacío amigable.
    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger" role="alert">
            <i class="fa-solid fa-triangle-exclamation me-2"></i><%= escapado(request.getAttribute("error")) %>
        </div>
    <% } %>
    --%>

    <div class="row g-4">
        <%
            if (propiedades != null && !propiedades.isEmpty()) {
                for (Propiedad p : propiedades) {
        %>
        <div class="col-sm-6 col-lg-4 col-xl-3">
            <div class="card h-100 shadow-sm producto-card">
                <div class="card-img-top bg-secondary d-flex align-items-center justify-content-center text-white"
                     style="height: 200px; position: relative;">
                    <i class="fa-solid fa-house-circle-check fa-3x"></i>
                    <%
                        String urlImagen = p.getImagen();
                        if (urlImagen != null && urlImagen.startsWith("/")) {
                            urlImagen = pageContext.getServletContext().getContextPath() + urlImagen;
                        }
                        if (urlImagen == null || urlImagen.isBlank()) {
                            urlImagen = pageContext.getServletContext().getContextPath()
                                    + "/uploads/propiedades/sin-imagen.png";
                        }
                    %>
                    <img class="w-100 h-100 object-fit-cover position-absolute top-0 start-0"
                         src="<%= escapado(urlImagen) %>"
                         alt="<%= escapado(p.getTitulo()) %>"
                         onerror="this.style.display='none';">
                </div>
                <div class="card-body">
                    <span class="badge text-bg-primary mb-2"><%= escapado(p.getTipoPropiedad()) %></span>
                    <h5 class="card-title text-truncate"><%= escapado(p.getTitulo()) %></h5>
                    <p class="text-muted small mb-1">
                        <i class="fa-solid fa-location-dot me-1"></i><%= escapado(p.getCiudad()) %><%= p.getDireccion() != null ? " - " + escapado(p.getDireccion()) : "" %>
                    </p>
                    <p class="card-text fw-semibold text-success fs-5 mb-2"><%= formatoPrecio.format(p.getPrecio()) %></p>
                    <p class="text-muted small mb-2">
                        <i class="fa-solid fa-barcode me-1"></i>Matrícula: <%= escapado(p.getMatriculaInmobiliaria()) %>
                    </p>
                </div>
                <div class="card-footer bg-white border-0 pb-3">
                    <a class="btn btn-outline-primary w-100"
                       href="${pageContext.request.contextPath}/detalle-propiedad.jsp?id=<%= p.getIdPropiedad() %>">
                        Ver Detalle
                    </a>
                </div>
            </div>
        </div>
        <%      }
            } else { %>
        <div class="col-12">
            <div class="alert alert-info text-center py-5" role="alert">
                <i class="fa-solid fa-house-circle-exclamation fa-2x mb-3"></i>
                <h4>No se encontraron propiedades</h4>
                <p class="mb-0">Ajuste los filtros de búsqueda o vuelva más tarde.</p>
            </div>
        </div>
        <%  } %>
    </div>
</main>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>