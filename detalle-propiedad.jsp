<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
    import="java.text.NumberFormat, java.util.Locale,
            java.util.ArrayList, java.util.LinkedHashMap, java.util.List, java.util.Map,
            java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet, java.sql.SQLException,
            db.ConexionBD" %>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/navbar.jspf" %>

<%!
    private static final String SQL_DETALLE =
            "SELECT p.id_propiedad, p.titulo, p.direccion, "
          + "p.matricula_inmobiliaria, p.precio, p.estado, "
          + "c.nombre AS ciudad, tp.nombre AS tipo_propiedad, i.nombre AS inmobiliaria, "
          + "i.telefono AS telefono_contacto "
          + "FROM propiedad p "
          + "LEFT JOIN ciudad c ON c.id_ciudad = p.id_ciudad "
          + "LEFT JOIN tipo_propiedad tp ON tp.id_tipo = p.id_tipo "
          + "LEFT JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria "
          + "WHERE p.id_propiedad = ?";

    private static final String SQL_IMAGENES =
            "SELECT url, es_principal "
          + "FROM imagen_propiedad WHERE id_propiedad = ? "
          + "ORDER BY es_principal DESC, id_imagen ASC";

    private static final String SQL_CARACTERISTICAS =
            "SELECT ca.nombre "
          + "FROM caracteristica ca "
          + "INNER JOIN propiedad_caracteristica pc ON pc.id_caracteristica = ca.id_caracteristica "
          + "WHERE pc.id_propiedad = ? ORDER BY ca.nombre";

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

    private void cerrarRecursos(ResultSet resultado, PreparedStatement sentencia,
            Connection conexion) {
        if (resultado != null) {
            try {
                resultado.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        if (sentencia != null) {
            try {
                sentencia.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        if (conexion != null) {
            try {
                conexion.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
%>

<%
    request.setCharacterEncoding("UTF-8");

    Integer idPropiedad = null;
    String idParam = request.getParameter("id");
    if (idParam == null || idParam.isBlank()) {
        idParam = request.getParameter("id_propiedad");
    }
    if (idParam != null && !idParam.isBlank()) {
        try {
            idPropiedad = Integer.valueOf(idParam.trim());
        } catch (NumberFormatException e) {
            idPropiedad = null;
        }
    }

    Map<String, Object> propiedad = null;
    List<Map<String, Object>> imagenes = new ArrayList<>();
    List<String> caracteristicas = new ArrayList<>();
    String errorDetalle = null;

    if (idPropiedad != null) {
        Connection conexion = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;

        try {
            conexion = ConexionBD.getConexion();

            sentencia = conexion.prepareStatement(SQL_DETALLE);
            sentencia.setInt(1, idPropiedad);
            resultado = sentencia.executeQuery();
            if (resultado.next()) {
                propiedad = new LinkedHashMap<>();
                propiedad.put("id", resultado.getInt("id_propiedad"));
                propiedad.put("titulo", resultado.getString("titulo"));
                propiedad.put("direccion", resultado.getString("direccion"));
                propiedad.put("matricula", resultado.getString("matricula_inmobiliaria"));
                propiedad.put("precio", resultado.getBigDecimal("precio"));
                propiedad.put("estado", resultado.getString("estado"));
                propiedad.put("ciudad", resultado.getString("ciudad"));
                propiedad.put("tipo", resultado.getString("tipo_propiedad"));
                propiedad.put("inmobiliaria", resultado.getString("inmobiliaria"));
                propiedad.put("telefono_contacto", resultado.getString("telefono_contacto"));
            }
            cerrarRecursos(resultado, sentencia, null);

            sentencia = conexion.prepareStatement(SQL_IMAGENES);
            sentencia.setInt(1, idPropiedad);
            resultado = sentencia.executeQuery();
            while (resultado.next()) {
                Map<String, Object> imagen = new LinkedHashMap<>();
                imagen.put("url", resultado.getString("url"));
                imagenes.add(imagen);
            }
            cerrarRecursos(resultado, sentencia, null);

            sentencia = conexion.prepareStatement(SQL_CARACTERISTICAS);
            sentencia.setInt(1, idPropiedad);
            resultado = sentencia.executeQuery();
            while (resultado.next()) {
                caracteristicas.add(resultado.getString("nombre"));
            }

        } catch (SQLException e) {
            e.printStackTrace();
            errorDetalle = "No fue posible cargar la información de la propiedad.";
        } finally {
            cerrarRecursos(resultado, sentencia, conexion);
        }
    }

    if (idPropiedad == null || propiedad == null) {
        errorDetalle = "No se encontró la propiedad solicitada.";
    }

    NumberFormat formatoPrecio = NumberFormat.getCurrencyInstance(new Locale("es", "CO"));
%>

<main class="container my-5 flex-grow-1">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/">Inicio</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/propiedades">Catálogo</a></li>
            <li class="breadcrumb-item active" aria-current="page">Detalle de la propiedad</li>
        </ol>
    </nav>

    <% if (errorDetalle != null) { %>
        <div class="alert alert-warning text-center py-5" role="alert">
            <i class="fa-solid fa-house-circle-exclamation fa-2x mb-3"></i>
            <h4><%= escapado(errorDetalle) %></h4>
            <p class="mb-3">Es posible que el inmueble ya no esté disponible o que la dirección sea incorrecta.</p>
            <a class="btn btn-primary" href="${pageContext.request.contextPath}/propiedades">
                <i class="fa-solid fa-magnifying-glass me-2"></i>Volver al catálogo
            </a>
        </div>
    <% } else { %>
        <div class="row g-4">
            <div class="col-lg-7">
                <div class="card shadow-sm border-0 h-100">
                    <%
                        if (imagenes.isEmpty()) {
                            String sinImagen = pageContext.getServletContext().getContextPath()
                                    + "/uploads/propiedades/sin-imagen.png";
                    %>
                    <div class="bg-secondary d-flex align-items-center justify-content-center text-white"
                         style="height: 380px; position: relative;">
                        <i class="fa-solid fa-building fa-4x"></i>
                        <img class="w-100 h-100 object-fit-cover position-absolute top-0 start-0"
                             src="<%= escapado(sinImagen) %>" alt="Sin imagen"
                             onerror="this.style.display='none';">
                    </div>
                    <%  } else {
                            boolean multiples = imagenes.size() > 1;
                    %>
                    <div id="galeriaPropiedad" class="carousel slide" data-bs-ride="carousel">
                        <div class="carousel-inner">
                            <%
                                int posicion = 0;
                                for (Map<String, Object> imagen : imagenes) {
                                    String urlImagen = (String) imagen.get("url");
                                    if (urlImagen != null && urlImagen.startsWith("/")) {
                                        urlImagen = pageContext.getServletContext().getContextPath() + urlImagen;
                                    }
                                    boolean activa = (posicion == 0);
                            %>
                            <div class="carousel-item <%= activa ? "active" : "" %>">
                                <div class="bg-secondary d-flex align-items-center justify-content-center text-white"
                                     style="height: 380px; position: relative;">
                                    <i class="fa-solid fa-building fa-4x"></i>
                                    <img class="w-100 h-100 object-fit-cover position-absolute top-0 start-0"
                                         src="<%= escapado(urlImagen) %>"
                                         alt="<%= escapado(imagen.get("descripcion")) %>"
                                         onerror="this.style.border='0';this.style.display='none';">
                                </div>
                            </div>
                            <%      posicion++;
                                }
                            %>
                        </div>
                        <% if (multiples) { %>
                        <button class="carousel-control-prev" type="button"
                                data-bs-target="#galeriaPropiedad" data-bs-slide="prev">
                            <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                            <span class="visually-hidden">Anterior</span>
                        </button>
                        <button class="carousel-control-next" type="button"
                                data-bs-target="#galeriaPropiedad" data-bs-slide="next">
                            <span class="carousel-control-next-icon" aria-hidden="true"></span>
                            <span class="visually-hidden">Siguiente</span>
                        </button>
                        <div class="carousel-indicators">
                            <% for (int i = 0; i < imagenes.size(); i++) { %>
                            <button type="button" data-bs-target="#galeriaPropiedad"
                                    data-bs-slide-to="<%= i %>" <%= i == 0 ? "class=\"active\" aria-current=\"true\"" : "" %>>
                            </button>
                            <%  } %>
                        </div>
                        <%  } %>
                    </div>
                    <%  } %>
                    <div class="card-body">
                        <h1 class="fw-bold h3 mb-2"><%= escapado(propiedad.get("titulo")) %></h1>
                        <p class="text-muted mb-2">
                            <i class="fa-solid fa-location-dot me-1"></i>
                            <%= escapado(propiedad.get("ciudad")) %><%= propiedad.get("direccion") != null ? " - " + escapado(propiedad.get("direccion")) : "" %>
                        </p>
                        <p>
                            <span class="badge text-bg-primary"><%= escapado(propiedad.get("tipo")) %></span>
                            <span class="badge <%= "VENDIDA".equals(propiedad.get("estado")) ? "text-bg-danger" : "text-bg-success" %>">
                                <%= escapado(propiedad.get("estado")) %>
                            </span>
                        </p>
                        <h2 class="text-success fw-bold"><%= formatoPrecio.format((Number) propiedad.get("precio")) %></h2>
                    </div>
                </div>
            </div>

            <div class="col-lg-5">
                <div class="card shadow-sm border-0 mb-4">
                    <div class="card-header bg-primary text-white fw-bold">
                        <i class="fa-solid fa-clipboard-list me-2"></i>Ficha técnica
                    </div>
                    <div class="card-body">
                        <ul class="list-group list-group-flush">
                            <li class="list-group-item d-flex justify-content-between">
                                <span class="text-muted">Matrícula inmobiliaria</span>
                                <span class="fw-semibold"><%= escapado(propiedad.get("matricula")) %></span>
                            </li>
                            <li class="list-group-item d-flex justify-content-between">
                                <span class="text-muted">Tipo</span>
                                <span class="fw-semibold"><%= escapado(propiedad.get("tipo")) %></span>
                            </li>
                            <li class="list-group-item d-flex justify-content-between">
                                <span class="text-muted">Estado</span>
                                <span class="fw-semibold"><%= escapado(propiedad.get("estado")) %></span>
                            </li>
                        </ul>
                    </div>
                </div>

                <div class="card shadow-sm border-0 mb-4">
                    <div class="card-header bg-white fw-bold">
                        <i class="fa-solid fa-star me-2 text-warning"></i>Características
                    </div>
                    <div class="card-body">
                        <%
                            if (caracteristicas.isEmpty()) {
                        %>
                        <p class="text-muted mb-0">Este inmueble no tiene características registradas.</p>
                        <%  } else {
                                for (String caracteristica : caracteristicas) {
                        %>
                        <span class="badge text-bg-light border me-1 mb-1">
                            <i class="fa-solid fa-check text-success me-1"></i><%= escapado(caracteristica) %>
                        </span>
                        <%      }
                            }
                        %>
                    </div>
                </div>

                <div class="card shadow-sm border-0 mb-4">
                    <div class="card-header bg-white fw-bold">
                        <i class="fa-solid fa-building-user me-2 text-primary"></i>Inmobiliaria
                    </div>
                    <div class="card-body">
                        <p class="fw-semibold mb-1"><%= escapado(propiedad.get("inmobiliaria")) %></p>
                        <% if (autenticado) { %>
                            <% if (propiedad.get("telefono_contacto") != null) { %>
                            <p class="mb-1">
                                <i class="fa-solid fa-phone me-2 text-muted"></i><%= escapado(propiedad.get("telefono_contacto")) %>
                            </p>
                            <% } %>
                            <% if (propiedad.get("correo_contacto") != null) { %>
                            <p class="mb-0">
                                <i class="fa-solid fa-envelope me-2 text-muted"></i><%= escapado(propiedad.get("correo_contacto")) %>
                            </p>
                            <% } %>
                        <% } else { %>
                        <p class="text-muted small mb-0">
                            <i class="fa-solid fa-lock me-1"></i>Los datos de contacto completos están disponibles para usuarios registrados.
                        </p>
                        <% } %>
                    </div>
                </div>

                <div class="card shadow-sm border-0">
                    <div class="card-body">
                        <div class="d-grid gap-2">
                            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#modalAgendarCita">
                                <i class="fa-solid fa-calendar-check me-2"></i>Agendar Cita
                            </button>
                            <form method="post" action="${pageContext.request.contextPath}/FavoritoServlet">
                                <input type="hidden" name="accion" value="agregar">
                                <input type="hidden" name="id_propiedad" value="<%= idPropiedad %>">
                                <button type="submit" class="btn btn-outline-danger w-100">
                                    <i class="fa-solid fa-heart me-2"></i>Agregar a Favoritos
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    <% } %>
</main>

<div class="modal fade" id="modalAgendarCita" tabindex="-1" aria-labelledby="modalAgendarCitaLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form method="post" id="formCita" action="${pageContext.request.contextPath}/CitaServlet">
                <input type="hidden" name="accion" value="agendar">
                <input type="hidden" name="id_propiedad" value="<%= idPropiedad != null ? idPropiedad : "" %>">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title" id="modalAgendarCitaLabel">
                        <i class="fa-solid fa-calendar-plus me-2"></i>Agendar visita
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label" for="fecha_hora">Fecha y hora de la visita</label>
                        <input type="datetime-local" class="form-control" id="fecha_hora" name="fecha_hora" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label" for="observaciones">Observaciones</label>
                        <textarea class="form-control" id="observaciones" name="observaciones" rows="3"
                                  placeholder="Comentarios para el asesor"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-primary">Solicitar cita</button>
                </div>
            </form>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>