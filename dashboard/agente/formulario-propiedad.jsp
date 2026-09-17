<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.List, java.util.Map, java.util.Set, modelos.Propiedad, modelos.ImagenPropiedad" %>
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
    Propiedad propiedad =
            (Propiedad) request.getAttribute("propiedad");
    boolean esEdicion = propiedad != null;

    String idPropiedad = request.getParameter("id_propiedad");
    String idInmobiliaria = request.getParameter("id_inmobiliaria");
    String idCiudad = request.getParameter("id_ciudad");
    String idTipo = request.getParameter("id_tipo");
    String titulo = request.getParameter("titulo");
    String descripcion = request.getParameter("descripcion");
    String direccion = request.getParameter("direccion");
    String matricula = request.getParameter("matricula_inmobiliaria");
    String precio = request.getParameter("precio");
    String areaM2 = request.getParameter("area_m2");
    String habitaciones = request.getParameter("habitaciones");
    String banos = request.getParameter("banos");
    String estrato = request.getParameter("estrato");
    String estado = request.getParameter("estado");

    if (propiedad != null) {
        idPropiedad = idPropiedad != null ? idPropiedad : String.valueOf(propiedad.getIdPropiedad());
        idInmobiliaria = idInmobiliaria != null ? idInmobiliaria : String.valueOf(propiedad.getIdInmobiliaria());
        idCiudad = idCiudad != null ? idCiudad : String.valueOf(propiedad.getIdCiudad());
        idTipo = idTipo != null ? idTipo : String.valueOf(propiedad.getIdTipo());
        titulo = titulo != null ? titulo : propiedad.getTitulo();
        descripcion = descripcion != null ? descripcion : propiedad.getDescripcion();
        direccion = direccion != null ? direccion : propiedad.getDireccion();
        matricula = matricula != null ? matricula : propiedad.getMatriculaInmobiliaria();
        precio = precio != null ? precio : (propiedad.getPrecio() != null ? String.valueOf(propiedad.getPrecio()) : null);
        areaM2 = areaM2 != null ? areaM2 : (propiedad.getAreaM2() != null ? String.valueOf(propiedad.getAreaM2()) : null);
        habitaciones = habitaciones != null ? habitaciones : String.valueOf(propiedad.getHabitaciones());
        banos = banos != null ? banos : String.valueOf(propiedad.getBanos());
        estrato = estrato != null ? estrato : String.valueOf(propiedad.getEstrato());
        estado = estado != null ? estado : propiedad.getEstado();
    }

    if (idInmobiliaria == null) {
        Object idInmobiliariaSesion = request.getAttribute("idInmobiliariaSesion");
        if (idInmobiliariaSesion != null) {
            idInmobiliaria = String.valueOf(idInmobiliariaSesion);
        } else {
            idInmobiliaria = "1";
        }
    }

    List<Map<String, Object>> listaCaracteristicas =
            (List<Map<String, Object>>) request.getAttribute("listaCaracteristicas");
    Set<Integer> caracteristicasSeleccionadas =
            (Set<Integer>) request.getAttribute("caracteristicasSeleccionadas");
    String[] caracteristicasPost = request.getParameterValues("caracteristicas");
    if (caracteristicasPost != null && caracteristicasSeleccionadas == null) {
        caracteristicasSeleccionadas = new java.util.HashSet<>();
        for (String c : caracteristicasPost) {
            try {
                caracteristicasSeleccionadas.add(Integer.valueOf(c.trim()));
            } catch (NumberFormatException e) {
            }
        }
    }
    if (caracteristicasSeleccionadas == null) {
        caracteristicasSeleccionadas = new java.util.HashSet<>();
    }

    List<Map<String, Object>> imagenesActuales =
            (List<Map<String, Object>>) request.getAttribute("imagenesActuales");
%>

<main class="container my-5 flex-grow-1">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="fw-bold h3 mb-0"><%= esEdicion ? "Editar inmueble" : "Registrar inmueble" %></h1>
            <p class="text-muted mb-0">Complete los datos de la propiedad para publicarla en el catálogo.</p>
        </div>
        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/dashboard/agente/panel.jsp">
            <i class="fa-solid fa-arrow-left me-2"></i>Volver
        </a>
    </div>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger" role="alert">
            <i class="fa-solid fa-triangle-exclamation me-2"></i><%= escapado(request.getAttribute("error")) %>
        </div>
    <% } %>

    <div class="row justify-content-center">
        <div class="col-lg-10">
            <form class="card border-0 shadow-sm" method="post" id="formPropiedad"
                  enctype="multipart/form-data"
                  action="${pageContext.request.contextPath}/mantenimiento-propiedad">
                <div class="card-body p-4">
                    <input type="hidden" name="id_propiedad" value="<%= escapado(idPropiedad) %>">
                    <input type="hidden" name="id_inmobiliaria" value="<%= escapado(idInmobiliaria != null ? idInmobiliaria : "1") %>">

                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label" for="titulo">Título *</label>
                            <input class="form-control" id="titulo" name="titulo" required maxlength="150"
                                   value="<%= escapado(titulo) %>" placeholder="Ej: Apartamento en El Poblado">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label" for="id_tipo">Tipo de propiedad *</label>
                            <select class="form-select" id="id_tipo" name="id_tipo" required>
                                <option value="">Seleccione...</option>
                                <%
                                    List<Map<String, Object>> listaTipos =
                                            (List<Map<String, Object>>) request.getAttribute("listaTipos");
                                    if (listaTipos != null) {
                                        for (Map<String, Object> tipo : listaTipos) {
                                            String id = String.valueOf(tipo.get("id"));
                                            String nombre = String.valueOf(tipo.get("nombre"));
                                            String sel = id.equals(idTipo) ? " selected" : "";
                                %>
                                <option value="<%= escapado(id) %>"<%= sel %>><%= escapado(nombre) %></option>
                                <%      }
                                    }
                                %>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label" for="id_ciudad">Ciudad *</label>
                            <select class="form-select" id="id_ciudad" name="id_ciudad" required>
                                <option value="">Seleccione...</option>
                                <%
                                    List<Map<String, Object>> listaCiudades =
                                            (List<Map<String, Object>>) request.getAttribute("listaCiudades");
                                    if (listaCiudades != null) {
                                        for (Map<String, Object> ciudad : listaCiudades) {
                                            String id = String.valueOf(ciudad.get("id"));
                                            String nombre = String.valueOf(ciudad.get("nombre"));
                                            String sel = id.equals(idCiudad) ? " selected" : "";
                                %>
                                <option value="<%= escapado(id) %>"<%= sel %>><%= escapado(nombre) %></option>
                                <%      }
                                    }
                                %>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label" for="descripcion">Descripción</label>
                            <textarea class="form-control" id="descripcion" name="descripcion" rows="3" maxlength="500"
                                      placeholder="Detalle relevante del inmueble"><%= escapado(descripcion) %></textarea>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="direccion">Dirección *</label>
                            <input class="form-control" id="direccion" name="direccion" required maxlength="180"
                                   value="<%= escapado(direccion) %>" placeholder="Calle 12 # 3-45">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="matricula_inmobiliaria">Matrícula inmobiliaria *</label>
                            <input class="form-control" id="matricula_inmobiliaria" name="matricula_inmobiliaria" required maxlength="40"
                                   value="<%= escapado(matricula) %>" placeholder="MAT-BOG-0001">
                            <div class="form-text">Valor único. Si ya existe, el sistema lo notificará.</div>
                        </div>

                        <div class="col-12"><hr class="my-2"></div>

                        <div class="col-md-3">
                            <label class="form-label" for="precio">Precio (COP) *</label>
                            <input type="number" step="0.01" min="0" class="form-control" id="precio" name="precio" required
                                   value="<%= escapado(precio) %>" placeholder="450000000">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label" for="area_m2">Área (m²) *</label>
                            <input type="number" step="0.01" min="0" class="form-control" id="area_m2" name="area_m2" required
                                   value="<%= escapado(areaM2) %>" placeholder="95.5">
                        </div>
                        <div class="col-md-2">
                            <label class="form-label" for="habitaciones">Habitaciones</label>
                            <input type="number" min="0" class="form-control" id="habitaciones" name="habitaciones"
                                   value="<%= escapado(habitaciones != null ? habitaciones : "0") %>">
                        </div>
                        <div class="col-md-2">
                            <label class="form-label" for="banos">Baños</label>
                            <input type="number" min="0" class="form-control" id="banos" name="banos"
                                   value="<%= escapado(banos != null ? banos : "0") %>">
                        </div>
                        <div class="col-md-2">
                            <label class="form-label" for="estrato">Estrato</label>
                            <input type="number" min="1" max="6" class="form-control" id="estrato" name="estrato"
                                   value="<%= escapado(estrato != null ? estrato : "1") %>">
                        </div>

                        <div class="col-md-4">
                            <label class="form-label" for="estado">Estado</label>
                            <select class="form-select" id="estado" name="estado">
                                <% String[] estados = {"DISPONIBLE", "RESERVADA", "VENDIDA", "ARRIENDADA", "INACTIVA"}; %>
                                <% for (String e : estados) { %>
                                <option value="<%= e %>" <%= e.equals(estado) ? "selected" : "" %>><%= e %></option>
                                <% } %>
                            </select>
                        </div>
                    </div>

                    <div class="col-12"><hr class="my-3"></div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold">
                            <i class="fa-solid fa-star me-1 text-warning"></i>Características del inmueble
                        </label>
                        <p class="text-muted small">Seleccione una o varias características (relación N:M).</p>
                        <div class="d-flex flex-wrap gap-2">
                            <%
                                if (listaCaracteristicas != null) {
                                    for (Map<String, Object> caracteristica : listaCaracteristicas) {
                                        int id = ((Number) caracteristica.get("id")).intValue();
                                        String nombre = String.valueOf(caracteristica.get("nombre"));
                                        boolean marcada = caracteristicasSeleccionadas.contains(id);
                            %>
                            <input type="checkbox" class="btn-check" id="carac<%= id %>"
                                   name="caracteristicas" value="<%= id %>" <%= marcada ? "checked" : "" %>>
                            <label class="btn btn-outline-secondary btn-sm" for="carac<%= id %>">
                                <%= escapado(nombre) %>
                            </label>
                            <%      }
                                } else { %>
                            <span class="text-muted small">No hay características disponibles.</span>
                            <%  } %>
                        </div>
                    </div>

                    <div class="col-12"><hr class="my-3"></div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold" for="imagenes">
                            <i class="fa-solid fa-image me-1 text-primary"></i>Fotografías del inmueble
                        </label>
                        <input class="form-control" type="file" id="imagenes" name="imagenes"
                               accept="image/*" multiple>
                        <div class="form-text">
                            Formatos JPG/PNG, máximo 5 MB por archivo. Si la propiedad no tiene
                            imágenes se mostrará una imagen por defecto (sin-imagen.png).
                        </div>
                    </div>

                    <%
                        if (imagenesActuales != null && !imagenesActuales.isEmpty()) {
                    %>
                    <div class="mb-3">
                        <label class="form-label">Imágenes registradas</label>
                        <div class="d-flex flex-wrap gap-2">
                            <%
                                for (Map<String, Object> imagen : imagenesActuales) {
                                    String url = String.valueOf(imagen.get("url"));
                                    if (url.startsWith("/")) {
                                        url = pageContext.getServletContext().getContextPath() + url;
                                    }
                                    boolean principal = Boolean.TRUE.equals(imagen.get("es_principal"))
                                            || Integer.valueOf(1).equals(imagen.get("es_principal"));
                            %>
                            <div class="border rounded p-1 text-center" style="width: 120px;">
                                <img src="<%= escapado(url) %>" alt="Imagen"
                                     class="img-thumbnail border-0 mb-1 mx-auto d-block"
                                     style="width: 100%; height: 80px; object-fit: cover;"
                                     onerror="this.alt='Imagen no disponible';">
                                <% if (principal) { %>
                                <span class="badge text-bg-primary">Principal</span>
                                <% } %>
                            </div>
                            <%  } %>
                        </div>
                    </div>
                    <%  } %>
                </div>
                <div class="card-footer bg-white d-flex justify-content-end gap-2">
                    <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/dashboard/agente/panel.jsp">Cancelar</a>
                    <button type="submit" class="btn btn-primary">
                        <i class="fa-solid fa-floppy-disk me-2"></i><%= esEdicion ? "Actualizar inmueble" : "Publicar inmueble" %>
                    </button>
                </div>
            </form>
        </div>
    </div>
</main>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>