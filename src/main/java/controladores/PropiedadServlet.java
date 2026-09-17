package controladores;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import config.ConexionBD;
import modelos.ImagenPropiedad;
import modelos.Propiedad;
import util.AuditoriaUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet(urlPatterns = { "/propiedades", "/mantenimiento-propiedad" })
@MultipartConfig(
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 20 * 1024 * 1024,
        fileSizeThreshold = 1024 * 1024)
public class PropiedadServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final int ERROR_DUPLICADO_UNIQUE_MYSQL = 1062;

    private static final String SQL_LISTAR =
            "SELECT p.id_propiedad, p.titulo, p.direccion, p.matricula_inmobiliaria, "
          + "p.precio, p.estado, c.nombre AS ciudad, "
          + "tp.nombre AS tipo_propiedad, i.nombre AS inmobiliaria, "
          + "COALESCE(ip.url, '/uploads/propiedades/sin-imagen.png') AS imagen_url "
          + "FROM propiedad p "
          + "LEFT JOIN ciudad c ON c.id_ciudad = p.id_ciudad "
          + "LEFT JOIN tipo_propiedad tp ON tp.id_tipo = p.id_tipo "
          + "LEFT JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria "
          + "LEFT JOIN imagen_propiedad ip ON ip.id_propiedad = p.id_propiedad AND ip.es_principal = 1 "
          + "WHERE p.estado = 'DISPONIBLE'";

    private static final String SQL_CIUDADES =
            "SELECT id_ciudad, nombre FROM ciudad ORDER BY nombre";

    private static final String SQL_TIPOS =
            "SELECT id_tipo, nombre FROM tipo_propiedad ORDER BY nombre";

    private static final String SQL_CARACTERISTICAS =
            "SELECT id_caracteristica, nombre, icono FROM caracteristica ORDER BY nombre";

    private static final String SQL_CARACTERISTICAS_PROPIEDAD =
            "SELECT id_caracteristica FROM propiedad_caracteristica WHERE id_propiedad = ?";

    private static final String SQL_IMAGENES_PROPIEDAD =
            "SELECT id_imagen, url, descripcion, es_principal FROM imagen_propiedad "
          + "WHERE id_propiedad = ? ORDER BY es_principal DESC, orden ASC, id_imagen ASC";

    private static final String SQL_INSERTAR =
            "INSERT INTO propiedad "
          + "(id_inmobiliaria, id_ciudad, id_tipo, titulo, descripcion, direccion, "
          + "matricula_inmobiliaria, precio, area_m2, habitaciones, banos, estrato, estado) "
          + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    private static final String SQL_ACTUALIZAR =
            "UPDATE propiedad "
          + "SET id_inmobiliaria = ?, id_ciudad = ?, id_tipo = ?, titulo = ?, "
          + "descripcion = ?, direccion = ?, matricula_inmobiliaria = ?, precio = ?, "
          + "area_m2 = ?, habitaciones = ?, banos = ?, estrato = ?, estado = ? "
          + "WHERE id_propiedad = ?";

    private static final String SQL_OBTENER =
            "SELECT id_propiedad, id_inmobiliaria, id_ciudad, id_tipo, titulo, descripcion, "
          + "direccion, matricula_inmobiliaria, precio, area_m2, habitaciones, banos, "
          + "estrato, estado, fecha_publicacion "
          + "FROM propiedad WHERE id_propiedad = ?";

    private static final String SQL_BORRAR_CARACTERISTICAS =
            "DELETE FROM propiedad_caracteristica WHERE id_propiedad = ?";

    private static final String SQL_ASOCIAR_CARACTERISTICA =
            "INSERT INTO propiedad_caracteristica (id_propiedad, id_caracteristica) VALUES (?, ?)";

    private static final String SQL_INSERTAR_IMAGEN =
            "INSERT INTO imagen_propiedad (id_propiedad, url, descripcion, es_principal, orden) "
          + "VALUES (?, ?, ?, ?, ?)";

    private static final String SQL_CONTAR_IMAGENES =
            "SELECT COUNT(*) FROM imagen_propiedad WHERE id_propiedad = ?";

    private static final String SQL_MAX_ORDEN_IMAGEN =
            "SELECT COALESCE(MAX(orden), 0) FROM imagen_propiedad WHERE id_propiedad = ?";

    private static final String SQL_IMAGENES_URLS =
            "SELECT url FROM imagen_propiedad WHERE id_propiedad = ?";

    private static final String SQL_ELIMINAR =
            "DELETE FROM propiedad WHERE id_propiedad = ?";

    private static final String SQL_INMOBILIARIA_USUARIO =
            "SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ? AND estado = 'ACTIVA'";

    private static final String SQL_PROPIEDAD_INMOBILIARIA =
            "SELECT id_inmobiliaria FROM propiedad WHERE id_propiedad = ?";

    private static final String JSP_LISTADO = "index.jsp";
    private static final String JSP_FORMULARIO = "dashboard/agente/formulario-propiedad.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if ("/mantenimiento-propiedad".equals(request.getServletPath())) {
            mostrarFormulario(request, response);
            return;
        }

        String idCiudad = request.getParameter("id_ciudad");
        String idTipoPropiedad = request.getParameter("id_tipo_propiedad");
        String precioMaximo = request.getParameter("precio_maximo");

        Integer idCiudadVal = parseId(idCiudad);
        Integer idTipoVal = parseId(idTipoPropiedad);
        BigDecimal precioMaximoVal = null;
        if (esNoVacio(precioMaximo)) {
            try {
                precioMaximoVal = new BigDecimal(precioMaximo.trim());
            } catch (NumberFormatException e) {
                request.setAttribute("error", "El precio máximo no es un valor válido.");
            }
        }

        StringBuilder sql = new StringBuilder(SQL_LISTAR);
        if (idCiudadVal != null) {
            sql.append(" AND p.id_ciudad = ?");
        }
        if (idTipoVal != null) {
            sql.append(" AND p.id_tipo = ?");
        }
        if (precioMaximoVal != null) {
            sql.append(" AND p.precio <= ?");
        }
        sql.append(" ORDER BY p.id_propiedad DESC");

        Connection conexion = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        List<Propiedad> propiedades = new ArrayList<>();

        try {
            conexion = ConexionBD.getConexion();
            sentencia = conexion.prepareStatement(sql.toString());

            int indice = 1;
            if (idCiudadVal != null) {
                sentencia.setInt(indice++, idCiudadVal);
            }
            if (idTipoVal != null) {
                sentencia.setInt(indice++, idTipoVal);
            }
            if (precioMaximoVal != null) {
                sentencia.setBigDecimal(indice++, precioMaximoVal);
            }

            resultado = sentencia.executeQuery();

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
                propiedad.setInmobiliaria(resultado.getString("inmobiliaria"));
                String imagenUrl = resultado.getString("imagen_url");
                propiedad.setImagen(imagenUrl == null || imagenUrl.isBlank()
                        ? "/uploads/propiedades/sin-imagen.png" : imagenUrl);
                propiedades.add(propiedad);
            }

        } catch (SQLException e) {
            log("Error SQL al listar propiedades: " + e.getMessage(), e);
            request.setAttribute("error", "Error al consultar las propiedades: " + e.getMessage());
        } catch (RuntimeException e) {
            log("Error inesperado al listar propiedades: " + e.getMessage(), e);
            request.setAttribute("error", "Error al consultar las propiedades: " + e.getMessage());
        } finally {
            cerrarRecursos(resultado, sentencia, conexion);
        }

        // Lista garantizada (nunca null) antes del forward.
        request.setAttribute("propiedades", propiedades);

        request.setAttribute("filtroCiudad", idCiudad);
        request.setAttribute("filtroTipo", idTipoPropiedad);
        request.setAttribute("filtroPrecioMaximo", precioMaximo);
        cargarCatalogos(request);
        request.getRequestDispatcher(JSP_LISTADO).forward(request, response);
    }

    private void mostrarFormulario(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        Integer idPropiedad = parseId(idParam);

        Connection conexion = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;

        try {
            conexion = ConexionBD.getConexion();
            request.setAttribute("idInmobiliariaSesion", obtenerIdInmobiliariaSesion(request, conexion));

            if (idPropiedad != null) {
                sentencia = conexion.prepareStatement(SQL_OBTENER);
                sentencia.setInt(1, idPropiedad);
                resultado = sentencia.executeQuery();

                if (resultado.next()) {
                    Propiedad propiedad = new Propiedad();
                    propiedad.setIdPropiedad(resultado.getInt("id_propiedad"));
                    propiedad.setIdInmobiliaria(resultado.getInt("id_inmobiliaria"));
                    propiedad.setIdCiudad(resultado.getInt("id_ciudad"));
                    propiedad.setIdTipo(resultado.getInt("id_tipo"));
                    propiedad.setTitulo(resultado.getString("titulo"));
                    propiedad.setDescripcion(resultado.getString("descripcion"));
                    propiedad.setDireccion(resultado.getString("direccion"));
                    propiedad.setMatriculaInmobiliaria(resultado.getString("matricula_inmobiliaria"));
                    propiedad.setPrecio(resultado.getBigDecimal("precio"));
                    propiedad.setAreaM2(resultado.getBigDecimal("area_m2"));
                    propiedad.setHabitaciones(resultado.getInt("habitaciones"));
                    propiedad.setBanos(resultado.getInt("banos"));
                    propiedad.setEstrato(resultado.getInt("estrato"));
                    propiedad.setEstado(resultado.getString("estado"));
                    request.setAttribute("propiedad", propiedad);
                } else {
                    request.setAttribute("error", "La propiedad solicitada no existe.");
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "No fue posible cargar la propiedad para edición.");
        } finally {
            cerrarRecursos(resultado, sentencia, conexion);
        }

        cargarCatalogos(request);
        cargarCaracteristicasSeleccionadas(request, idPropiedad);
        cargarImagenesActuales(request, idPropiedad);
        request.getRequestDispatcher(JSP_FORMULARIO).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String accion = request.getParameter("accion");
        if ("eliminar".equals(accion)) {
            eliminarPropiedad(request, response);
            return;
        }

        String idPropiedad = request.getParameter("id_propiedad");
        String idInmobiliaria = request.getParameter("id_inmobiliaria");
        String idCiudad = request.getParameter("id_ciudad");
        String idTipoPropiedad = request.getParameter("id_tipo");
        String titulo = request.getParameter("titulo");
        String descripcion = request.getParameter("descripcion");
        String direccion = request.getParameter("direccion");
        String matriculaInmobiliaria = request.getParameter("matricula_inmobiliaria");
        String precio = request.getParameter("precio");
        String areaM2 = request.getParameter("area_m2");
        String habitaciones = request.getParameter("habitaciones");
        String banos = request.getParameter("banos");
        String estrato = request.getParameter("estrato");
        String estado = request.getParameter("estado");

        boolean esRegistro = esNoVacio(idInmobiliaria) && esNoVacio(idCiudad)
                && esNoVacio(idTipoPropiedad) && esNoVacio(titulo)
                && esNoVacio(direccion) && esNoVacio(matriculaInmobiliaria)
                && esNoVacio(precio) && esNoVacio(areaM2);

        Integer idInmobiliariaVal = parseId(idInmobiliaria);
        Integer idCiudadVal = parseId(idCiudad);
        Integer idTipoVal = parseId(idTipoPropiedad);
        Integer idPropiedadVal = esNoVacio(idPropiedad) ? parseId(idPropiedad) : null;

        if (!esRegistro || idInmobiliariaVal == null || idCiudadVal == null || idTipoVal == null
                || (esNoVacio(idPropiedad) && idPropiedadVal == null)) {
            request.setAttribute("error", !esRegistro
                    ? "Complete todos los campos obligatorios del formulario."
                    : "Los valores seleccionados de la propiedad no son válidos.");
            reenviarFormulario(request, response, idPropiedadVal);
            return;
        }

        boolean esActualizacion = idPropiedadVal != null;

        Connection conexion = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        List<String> archivosGuardados = new ArrayList<>();

        try {
            conexion = ConexionBD.getConexion();
            conexion.setAutoCommit(false);

            // Control de propiedad: para rol INMOBILIARIA se fuerza la agencia de la
            // sesión y se valida que el inmueble (al editar) pertenezca a ella.
            Integer idInmobiliariaSesion = obtenerIdInmobiliariaSesion(request, conexion);
            if (idInmobiliariaSesion != null) {
                idInmobiliariaVal = idInmobiliariaSesion;
                if (esActualizacion
                        && !propiedadPerteneceALaInmobiliaria(conexion, idPropiedadVal, idInmobiliariaSesion)) {
                    hacerRollback(conexion);
                    response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                    return;
                }
            }

            int idPropiedadFinal;
            if (esActualizacion) {
                sentencia = conexion.prepareStatement(SQL_ACTUALIZAR);
                asignarParametros(sentencia, idInmobiliariaVal, idCiudadVal, idTipoVal,
                        titulo, descripcion, direccion, matriculaInmobiliaria, precio,
                        areaM2, habitaciones, banos, estrato, estado);
                sentencia.setInt(14, idPropiedadVal);
                sentencia.executeUpdate();
                idPropiedadFinal = idPropiedadVal;
            } else {
                sentencia = conexion.prepareStatement(SQL_INSERTAR, Statement.RETURN_GENERATED_KEYS);
                asignarParametros(sentencia, idInmobiliariaVal, idCiudadVal, idTipoVal,
                        titulo, descripcion, direccion, matriculaInmobiliaria, precio,
                        areaM2, habitaciones, banos, estrato, estado);
                sentencia.executeUpdate();

                idPropiedadFinal = -1;
                resultado = sentencia.getGeneratedKeys();
                if (resultado.next()) {
                    idPropiedadFinal = resultado.getInt(1);
                }
                if (idPropiedadFinal <= 0) {
                    throw new SQLException("No se pudo recuperar el identificador de la propiedad creada.");
                }
            }
            cerrarRecursos(resultado, sentencia, null);

            // Relación N:M: se reemplazan las características seleccionadas.
            String[] caracteristicas = request.getParameterValues("caracteristicas");
            sentencia = conexion.prepareStatement(SQL_BORRAR_CARACTERISTICAS);
            sentencia.setInt(1, idPropiedadFinal);
            sentencia.executeUpdate();
            cerrarRecursos(null, sentencia, null);

            if (caracteristicas != null) {
                for (String idCaracteristica : caracteristicas) {
                    Integer idCaracteristicaVal = parseId(idCaracteristica);
                    if (idCaracteristicaVal == null) {
                        continue;
                    }
                    sentencia = conexion.prepareStatement(SQL_ASOCIAR_CARACTERISTICA);
                    sentencia.setInt(1, idPropiedadFinal);
                    sentencia.setInt(2, idCaracteristicaVal);
                    sentencia.executeUpdate();
                    cerrarRecursos(null, sentencia, null);
                }
            }

            // Relación 1:N: subida de imágenes (se guardan rutas en imagen_propiedad).
            int cantidadImagenes = contarImagenes(conexion, idPropiedadFinal);
            int ordenActual = obtenerMaxOrdenImagen(conexion, idPropiedadFinal);
            String directorio = getServletContext().getRealPath("/uploads/propiedades");

            Collection<Part> partes = request.getParts();
            int contador = 0;
            for (Part parte : partes) {
                if (parte == null || !"imagenes".equals(parte.getName()) || parte.getSize() <= 0) {
                    continue;
                }
                contador++;
                String nombreArchivo = guardarImagen(parte, directorio, contador, archivosGuardados);
                boolean esPrincipal = (cantidadImagenes + contador) == 1;
                sentencia = conexion.prepareStatement(SQL_INSERTAR_IMAGEN);
                sentencia.setInt(1, idPropiedadFinal);
                sentencia.setString(2, "/uploads/propiedades/" + nombreArchivo);
                sentencia.setString(3, null);
                sentencia.setInt(4, esPrincipal ? 1 : 0);
                sentencia.setInt(5, ordenActual + contador);
                sentencia.executeUpdate();
                cerrarRecursos(null, sentencia, null);
            }

            Integer idUsuarioSesion = (Integer) request.getSession().getAttribute("idUsuario");
            AuditoriaUtil.registrarEnTransaccion(conexion, idUsuarioSesion, "propiedad",
                    esActualizacion ? "UPDATE" : "INSERT",
                    (esActualizacion ? "Actualización del inmueble " : "Publicación del inmueble ")
                            + matriculaInmobiliaria.trim());

            conexion.commit();
            response.sendRedirect(request.getContextPath() + "/dashboard/agente/panel.jsp");

        } catch (SQLException e) {
            hacerRollback(conexion);
            eliminarArchivosGuardados(archivosGuardados);
            manejarErrorSQL(e, request, response, idPropiedadVal);
        } catch (NumberFormatException e) {
            hacerRollback(conexion);
            eliminarArchivosGuardados(archivosGuardados);
            request.setAttribute("error", "Los campos numéricos deben contener valores válidos.");
            reenviarFormulario(request, response, idPropiedadVal);
        } catch (IllegalStateException e) {
            hacerRollback(conexion);
            eliminarArchivosGuardados(archivosGuardados);
            request.setAttribute("error",
                    "Las imágenes superan el tamaño máximo permitido (5 MB por archivo).");
            reenviarFormulario(request, response, idPropiedadVal);
        } catch (IOException e) {
            hacerRollback(conexion);
            eliminarArchivosGuardados(archivosGuardados);
            e.printStackTrace();
            request.setAttribute("error", "No fue posible almacenar las imágenes en el servidor.");
            reenviarFormulario(request, response, idPropiedadVal);
        } finally {
            if (conexion != null) {
                try {
                    conexion.setAutoCommit(true);
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            cerrarRecursos(null, null, conexion);
        }
    }

    private void reenviarFormulario(HttpServletRequest request, HttpServletResponse response,
            Integer idPropiedad) throws ServletException, IOException {

        cargarCatalogos(request);
        cargarInmobiliariaSesion(request);
        cargarSeleccionDesdeParametros(request);
        cargarImagenesActuales(request, idPropiedad);
        request.getRequestDispatcher(JSP_FORMULARIO).forward(request, response);
    }

    private void cargarInmobiliariaSesion(HttpServletRequest request) {
        Connection conexion = null;
        try {
            conexion = ConexionBD.getConexion();
            request.setAttribute("idInmobiliariaSesion", obtenerIdInmobiliariaSesion(request, conexion));
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(null, null, conexion);
        }
    }

    private Integer obtenerIdInmobiliariaSesion(HttpServletRequest request, Connection conexion) {
        Integer idUsuario = (Integer) request.getSession().getAttribute("idUsuario");
        if (idUsuario == null) {
            return null;
        }
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        try {
            sentencia = conexion.prepareStatement(SQL_INMOBILIARIA_USUARIO);
            sentencia.setInt(1, idUsuario);
            resultado = sentencia.executeQuery();
            return resultado.next() ? resultado.getInt("id_inmobiliaria") : null;
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        } finally {
            cerrarRecursos(resultado, sentencia, null);
        }
    }

    private boolean propiedadPerteneceALaInmobiliaria(Connection conexion,
            int idPropiedad, int idInmobiliaria) throws SQLException {

        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        try {
            sentencia = conexion.prepareStatement(SQL_PROPIEDAD_INMOBILIARIA);
            sentencia.setInt(1, idPropiedad);
            resultado = sentencia.executeQuery();
            return resultado.next() && resultado.getInt("id_inmobiliaria") == idInmobiliaria;
        } finally {
            cerrarRecursos(resultado, sentencia, null);
        }
    }

    private void eliminarPropiedad(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer idPropiedad = parseId(request.getParameter("id"));
        if (idPropiedad == null) {
            request.setAttribute("error", "Debe indicar la propiedad que desea eliminar.");
            request.getRequestDispatcher("/dashboard/agente/panel.jsp").forward(request, response);
            return;
        }

        Connection conexion = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        List<String> rutasImagenes = new ArrayList<>();

        try {
            conexion = ConexionBD.getConexion();
            conexion.setAutoCommit(false);

            Integer idInmobiliariaSesion = obtenerIdInmobiliariaSesion(request, conexion);
            if (idInmobiliariaSesion != null
                    && !propiedadPerteneceALaInmobiliaria(conexion, idPropiedad, idInmobiliariaSesion)) {
                hacerRollback(conexion);
                response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                return;
            }

            // Se recuperan las rutas de las imágenes para borrar los archivos físicos
            // después de confirmar la eliminación en la base de datos (ON DELETE CASCADE).
            sentencia = conexion.prepareStatement(SQL_IMAGENES_URLS);
            sentencia.setInt(1, idPropiedad);
            resultado = sentencia.executeQuery();
            while (resultado.next()) {
                rutasImagenes.add(resultado.getString("url"));
            }
            cerrarRecursos(resultado, sentencia, null);

            sentencia = conexion.prepareStatement(SQL_ELIMINAR);
            sentencia.setInt(1, idPropiedad);
            sentencia.executeUpdate();
            cerrarRecursos(null, sentencia, null);

            Integer idUsuarioSesion = (Integer) request.getSession().getAttribute("idUsuario");
            AuditoriaUtil.registrarEnTransaccion(conexion, idUsuarioSesion, "propiedad", "DELETE",
                    "Eliminación del inmueble #" + idPropiedad);

            conexion.commit();
            eliminarArchivosDeRutas(rutasImagenes);
            response.sendRedirect(request.getContextPath() + "/dashboard/agente/panel.jsp");

        } catch (SQLException e) {
            hacerRollback(conexion);
            e.printStackTrace();
            request.setAttribute("error", "No fue posible eliminar el inmueble: " + e.getMessage());
            request.getRequestDispatcher("/dashboard/agente/panel.jsp").forward(request, response);
        } finally {
            if (conexion != null) {
                try {
                    conexion.setAutoCommit(true);
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            cerrarRecursos(resultado, sentencia, conexion);
        }
    }

    private void eliminarArchivosDeRutas(List<String> rutasImagenes) {
        String directorioBase = getServletContext().getRealPath("/uploads/propiedades");
        for (String ruta : rutasImagenes) {
            if (ruta == null || ruta.isBlank() || ruta.endsWith("/sin-imagen.png")) {
                continue;
            }
            String nombre = ruta.substring(ruta.lastIndexOf('/') + 1);
            File archivo = new File(directorioBase, nombre);
            if (archivo.exists()) {
                archivo.delete();
            }
        }
    }

    private void asignarParametros(PreparedStatement sentencia,
            int idInmobiliaria, int idCiudad, int idTipoPropiedad,
            String titulo, String descripcion, String direccion,
            String matriculaInmobiliaria, String precio, String areaM2,
            String habitaciones, String banos, String estrato, String estado)
            throws SQLException {

        int indice = 1;
        sentencia.setInt(indice++, idInmobiliaria);
        sentencia.setInt(indice++, idCiudad);
        sentencia.setInt(indice++, idTipoPropiedad);
        sentencia.setString(indice++, titulo.trim());
        sentencia.setString(indice++, descripcion != null ? descripcion.trim() : null);
        sentencia.setString(indice++, direccion.trim());
        sentencia.setString(indice++, matriculaInmobiliaria.trim());
        sentencia.setBigDecimal(indice++, new BigDecimal(precio.trim()));
        sentencia.setBigDecimal(indice++, new BigDecimal(areaM2.trim()));
        sentencia.setInt(indice++, parseInt(habitaciones, 0));
        sentencia.setInt(indice++, parseInt(banos, 0));
        sentencia.setInt(indice++, parseInt(estrato, 1));
        sentencia.setString(indice, estado != null ? estado : "DISPONIBLE");
    }

    private void manejarErrorSQL(SQLException e, HttpServletRequest request,
            HttpServletResponse response, Integer idPropiedad)
            throws ServletException, IOException {

        if (e.getErrorCode() == ERROR_DUPLICADO_UNIQUE_MYSQL) {
            request.setAttribute("error", "La matrícula inmobiliaria ya está registrada.");
        } else {
            e.printStackTrace();
            request.setAttribute("error", "Error al guardar la propiedad.");
        }
        reenviarFormulario(request, response, idPropiedad);
    }

    private void cargarCatalogos(HttpServletRequest request) {
        Connection conexion = null;

        // Listas garantizadas (nunca null): si una tabla está vacía o su consulta
        // falla, la vista recibe new ArrayList<>() y no rompe con un error visual.
        request.setAttribute("listaCiudades", new ArrayList<Map<String, Object>>());
        request.setAttribute("listaTipos", new ArrayList<Map<String, Object>>());
        request.setAttribute("listaCaracteristicas", new ArrayList<Map<String, Object>>());

        try {
            conexion = ConexionBD.getConexion();
            request.setAttribute("listaCiudades", cargarCiudades(conexion));
            request.setAttribute("listaTipos", cargarTipos(conexion));
            request.setAttribute("listaCaracteristicas", cargarCaracteristicasCatalogos(conexion));
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "No fue posible cargar los catálogos del formulario.");
        } finally {
            cerrarRecursos(null, null, conexion);
        }
    }

    private List<Map<String, Object>> cargarCiudades(Connection conexion) {
        List<Map<String, Object>> ciudades = new ArrayList<>();
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        try {
            sentencia = conexion.prepareStatement(SQL_CIUDADES);
            resultado = sentencia.executeQuery();
            while (resultado.next()) {
                Map<String, Object> ciudad = new LinkedHashMap<>();
                ciudad.put("id", resultado.getInt("id_ciudad"));
                ciudad.put("nombre", resultado.getString("nombre"));
                ciudades.add(ciudad);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return new ArrayList<>();
        } finally {
            cerrarRecursos(resultado, sentencia, null);
        }
        return ciudades;
    }

    private List<Map<String, Object>> cargarTipos(Connection conexion) {
        List<Map<String, Object>> tipos = new ArrayList<>();
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        try {
            sentencia = conexion.prepareStatement(SQL_TIPOS);
            resultado = sentencia.executeQuery();
            while (resultado.next()) {
                Map<String, Object> tipo = new LinkedHashMap<>();
                tipo.put("id", resultado.getInt("id_tipo"));
                tipo.put("nombre", resultado.getString("nombre"));
                tipos.add(tipo);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return new ArrayList<>();
        } finally {
            cerrarRecursos(resultado, sentencia, null);
        }
        return tipos;
    }

    private List<Map<String, Object>> cargarCaracteristicasCatalogos(Connection conexion) {
        List<Map<String, Object>> caracteristicas = new ArrayList<>();
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        try {
            sentencia = conexion.prepareStatement(SQL_CARACTERISTICAS);
            resultado = sentencia.executeQuery();
            while (resultado.next()) {
                Map<String, Object> caracteristica = new LinkedHashMap<>();
                caracteristica.put("id", resultado.getInt("id_caracteristica"));
                caracteristica.put("nombre", resultado.getString("nombre"));
                caracteristica.put("icono", resultado.getString("icono"));
                caracteristicas.add(caracteristica);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return new ArrayList<>();
        } finally {
            cerrarRecursos(resultado, sentencia, null);
        }
        return caracteristicas;
    }

    private void cargarCaracteristicasSeleccionadas(HttpServletRequest request, Integer idPropiedad) {
        if (idPropiedad == null) {
            request.setAttribute("caracteristicasSeleccionadas", new HashSet<>());
            return;
        }

        Connection conexion = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        Set<Integer> seleccionadas = new HashSet<>();

        try {
            conexion = ConexionBD.getConexion();
            sentencia = conexion.prepareStatement(SQL_CARACTERISTICAS_PROPIEDAD);
            sentencia.setInt(1, idPropiedad);
            resultado = sentencia.executeQuery();
            while (resultado.next()) {
                seleccionadas.add(resultado.getInt("id_caracteristica"));
            }
            request.setAttribute("caracteristicasSeleccionadas", seleccionadas);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("caracteristicasSeleccionadas", seleccionadas);
        } finally {
            cerrarRecursos(resultado, sentencia, conexion);
        }
    }

    private void cargarSeleccionDesdeParametros(HttpServletRequest request) {
        String[] valores = request.getParameterValues("caracteristicas");
        if (valores == null) {
            return;
        }

        Set<Integer> seleccionadas = new HashSet<>();
        for (String valor : valores) {
            Integer id = parseId(valor);
            if (id != null) {
                seleccionadas.add(id);
            }
        }
        request.setAttribute("caracteristicasSeleccionadas", seleccionadas);
    }

    private void cargarImagenesActuales(HttpServletRequest request, Integer idPropiedad) {
        if (idPropiedad == null) {
            request.setAttribute("imagenesActuales", new ArrayList<ImagenPropiedad>());
            return;
        }

        Connection conexion = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        List<ImagenPropiedad> imagenes = new ArrayList<>();

        try {
            conexion = ConexionBD.getConexion();
            sentencia = conexion.prepareStatement(SQL_IMAGENES_PROPIEDAD);
            sentencia.setInt(1, idPropiedad);
            resultado = sentencia.executeQuery();
            while (resultado.next()) {
                ImagenPropiedad imagen = new ImagenPropiedad();
                imagen.setIdImagen(resultado.getInt("id_imagen"));
                imagen.setUrl(resultado.getString("url"));
                imagen.setDescripcion(resultado.getString("descripcion"));
                imagen.setEsPrincipal(resultado.getInt("es_principal") == 1);
                imagen.setOrden(resultado.getInt("orden"));
                imagenes.add(imagen);
            }
            request.setAttribute("imagenesActuales", imagenes);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("imagenesActuales", imagenes);
        } finally {
            cerrarRecursos(resultado, sentencia, conexion);
        }
    }

    private int contarImagenes(Connection conexion, int idPropiedad) throws SQLException {
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        try {
            sentencia = conexion.prepareStatement(SQL_CONTAR_IMAGENES);
            sentencia.setInt(1, idPropiedad);
            resultado = sentencia.executeQuery();
            return resultado.next() ? resultado.getInt(1) : 0;
        } finally {
            cerrarRecursos(resultado, sentencia, null);
        }
    }

    private int obtenerMaxOrdenImagen(Connection conexion, int idPropiedad) throws SQLException {
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        try {
            sentencia = conexion.prepareStatement(SQL_MAX_ORDEN_IMAGEN);
            sentencia.setInt(1, idPropiedad);
            resultado = sentencia.executeQuery();
            return resultado.next() ? resultado.getInt(1) : 0;
        } finally {
            cerrarRecursos(resultado, sentencia, null);
        }
    }

    private String guardarImagen(Part parte, String directorio, int contador,
            List<String> archivosGuardados) throws IOException {

        File directorioDir = new File(directorio);
        if (!directorioDir.exists()) {
            directorioDir.mkdirs();
        }

        String extension = obtenerExtension(parte.getSubmittedFileName(), parte.getContentType());
        String nombreArchivo = "prop-" + System.currentTimeMillis() + "-" + contador + extension;
        String rutaAbsoluta = directorio + File.separator + nombreArchivo;
        parte.write(rutaAbsoluta);
        archivosGuardados.add(rutaAbsoluta);
        return nombreArchivo;
    }

    private String obtenerExtension(String nombreOriginal, String contentType) {
        if (nombreOriginal != null) {
            int punto = nombreOriginal.lastIndexOf('.');
            if (punto >= 0 && punto < nombreOriginal.length() - 1) {
                String extension = nombreOriginal.substring(punto).toLowerCase();
                if (extension.matches("\\.(png|jpe?g|gif|webp|bmp)")) {
                    return extension;
                }
            }
        }
        if (contentType != null) {
            if (contentType.contains("png")) {
                return ".png";
            }
            if (contentType.contains("jpeg") || contentType.contains("jpg")) {
                return ".jpg";
            }
            if (contentType.contains("gif")) {
                return ".gif";
            }
            if (contentType.contains("webp")) {
                return ".webp";
            }
        }
        return ".img";
    }

    private void eliminarArchivosGuardados(List<String> archivosGuardados) {
        for (String ruta : archivosGuardados) {
            File archivo = new File(ruta);
            if (archivo.exists()) {
                archivo.delete();
            }
        }
    }

    private void hacerRollback(Connection conexion) {
        if (conexion != null) {
            try {
                conexion.rollback();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    private Integer parseId(String valor) {
        if (valor == null || valor.isBlank()) {
            return null;
        }
        try {
            return Integer.valueOf(valor.trim());
        } catch (NumberFormatException e) {
            return null;
        }
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

    private boolean esNoVacio(String valor) {
        return valor != null && !valor.isBlank();
    }

    private int parseInt(String valor, int porDefecto) {
        if (valor == null || valor.isBlank()) {
            return porDefecto;
        }
        try {
            return Integer.parseInt(valor.trim());
        } catch (NumberFormatException e) {
            return porDefecto;
        }
    }
}