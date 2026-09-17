package controladores;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import config.ConexionBD;
import modelos.Caracteristica;
import modelos.Ciudad;
import modelos.TipoPropiedad;
import util.AuditoriaUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/catalogos")
public class CatalogoServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String JSP_CATALOGOS = "/dashboard/admin/catalogos.jsp";
    private static final String JSP_LOGIN = "/login.jsp";

    private static final String SQL_CIUDADES =
            "SELECT id_ciudad, nombre, departamento, codigo_dane FROM ciudad ORDER BY departamento, nombre";

    private static final String SQL_CIUDAD_POR_ID =
            "SELECT id_ciudad, nombre, departamento, codigo_dane FROM ciudad WHERE id_ciudad = ?";

    private static final String SQL_CIUDAD_INSERTAR =
            "INSERT INTO ciudad (nombre, departamento, codigo_dane) VALUES (?, ?, ?)";

    private static final String SQL_CIUDAD_ACTUALIZAR =
            "UPDATE ciudad SET nombre = ?, departamento = ?, codigo_dane = ? WHERE id_ciudad = ?";

    private static final String SQL_CIUDAD_ELIMINAR =
            "DELETE FROM ciudad WHERE id_ciudad = ?";

    private static final String SQL_TIPOS =
            "SELECT id_tipo, nombre, descripcion FROM tipo_propiedad ORDER BY nombre";

    private static final String SQL_TIPO_POR_ID =
            "SELECT id_tipo, nombre, descripcion FROM tipo_propiedad WHERE id_tipo = ?";

    private static final String SQL_TIPO_INSERTAR =
            "INSERT INTO tipo_propiedad (nombre, descripcion) VALUES (?, ?)";

    private static final String SQL_TIPO_ACTUALIZAR =
            "UPDATE tipo_propiedad SET nombre = ?, descripcion = ? WHERE id_tipo = ?";

    private static final String SQL_TIPO_ELIMINAR =
            "DELETE FROM tipo_propiedad WHERE id_tipo = ?";

    private static final String SQL_CARACTERISTICAS =
            "SELECT id_caracteristica, nombre, icono FROM caracteristica ORDER BY nombre";

    private static final String SQL_CARACTERISTICA_POR_ID =
            "SELECT id_caracteristica, nombre, icono FROM caracteristica WHERE id_caracteristica = ?";

    private static final String SQL_CARACTERISTICA_INSERTAR =
            "INSERT INTO caracteristica (nombre, icono) VALUES (?, ?)";

    private static final String SQL_CARACTERISTICA_ACTUALIZAR =
            "UPDATE caracteristica SET nombre = ?, icono = ? WHERE id_caracteristica = ?";

    private static final String SQL_CARACTERISTICA_ELIMINAR =
            "DELETE FROM caracteristica WHERE id_caracteristica = ?";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!esAdministrador(request, response)) {
            return;
        }

        // Inicialización defensiva: la vista siempre recibe listas vacías (nunca null).
        List<Ciudad> ciudades = new ArrayList<>();
        List<TipoPropiedad> tipos = new ArrayList<>();
        List<Caracteristica> caracteristicas = new ArrayList<>();
        request.setAttribute("ciudades", ciudades);
        request.setAttribute("tipos", tipos);
        request.setAttribute("caracteristicas", caracteristicas);

        try {
            String seccionEdicion = request.getParameter("editar_seccion");
            Integer idEdicion = parseId(request.getParameter("editar_id"));

            cargarVista(request, seccionEdicion, idEdicion);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("ciudades", new ArrayList<>());
            request.setAttribute("tipos", new ArrayList<>());
            request.setAttribute("caracteristicas", new ArrayList<>());
        }

        // Forward garantizado: la vista se renderiza aunque la base de datos falle.
        request.getRequestDispatcher(JSP_CATALOGOS).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        if (!esAdministrador(request, response)) {
            return;
        }

        // Inicialización defensiva: la vista siempre recibe listas vacías (nunca null).
        request.setAttribute("ciudades", new ArrayList<>());
        request.setAttribute("tipos", new ArrayList<>());
        request.setAttribute("caracteristicas", new ArrayList<>());

        String seccion = request.getParameter("seccion");
        String accion = request.getParameter("accion");
        String idParam = request.getParameter("id");

        if (seccion != null && accion != null) {
            Integer id = parseId(idParam);
            Connection conexion = null;

            try {
                conexion = ConexionBD.getConexion();
                ejecutarAccion(request, conexion, seccion, accion, id);
            } catch (NumberFormatException e) {
                e.printStackTrace();
            } catch (SQLException e) {
                e.printStackTrace();
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                cerrarRecursos(null, null, conexion);
            }
        }

        try {
            cargarVista(request, null, null);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("ciudades", new ArrayList<>());
            request.setAttribute("tipos", new ArrayList<>());
            request.setAttribute("caracteristicas", new ArrayList<>());
        }

        // Forward garantizado: la vista se renderiza aunque la base de datos falle.
        request.getRequestDispatcher(JSP_CATALOGOS).forward(request, response);
    }

    private void ejecutarAccion(HttpServletRequest request, Connection conexion,
            String seccion, String accion, Integer id)
            throws SQLException, NumberFormatException {

        String nombre = request.getParameter("nombre");
        String departamento = request.getParameter("departamento");
        String codigoDane = request.getParameter("codigo_dane");
        String descripcion = request.getParameter("descripcion");
        String icono = request.getParameter("icono");

        Integer idUsuario = (Integer) request.getSession().getAttribute("idUsuario");

        String tabla;
        switch (seccion) {
            case "ciudad":
                tabla = "ciudad";
                ejecutarCiudad(request, conexion, accion, id, nombre, departamento, codigoDane);
                break;
            case "tipo":
                tabla = "tipo_propiedad";
                ejecutarTipo(request, conexion, accion, id, nombre, descripcion);
                break;
            case "caracteristica":
                tabla = "caracteristica";
                ejecutarCaracteristica(request, conexion, accion, id, nombre, icono);
                break;
            default:
                return;
        }

        AuditoriaUtil.registrarEnTransaccion(conexion, idUsuario, tabla, accion,
                accion + " en tabla " + tabla + (nombre != null ? ": " + nombre.trim() : ""));
    }

    private void ejecutarCiudad(HttpServletRequest request, Connection conexion,
            String accion, Integer id, String nombre, String departamento, String codigoDane)
            throws SQLException {

        if ("eliminar".equals(accion)) {
            if (id == null) {
                return;
            }
            PreparedStatement sentencia = conexion.prepareStatement(SQL_CIUDAD_ELIMINAR);
            sentencia.setInt(1, id);
            sentencia.executeUpdate();
            cerrarRecursos(null, sentencia, null);
            request.setAttribute("exito", "La ciudad fue eliminada correctamente.");
            return;
        }

        if (!validarObligatorios(nombre, departamento, codigoDane)) {
            return;
        }

        if ("actualizar".equals(accion)) {
            if (id == null) {
                return;
            }
            PreparedStatement sentencia = conexion.prepareStatement(SQL_CIUDAD_ACTUALIZAR);
            sentencia.setString(1, nombre.trim());
            sentencia.setString(2, departamento.trim());
            sentencia.setString(3, codigoDane.trim());
            sentencia.setInt(4, id);
            sentencia.executeUpdate();
            cerrarRecursos(null, sentencia, null);
            request.setAttribute("exito", "La ciudad fue actualizada correctamente.");
        } else if ("crear".equals(accion)) {
            PreparedStatement sentencia = conexion.prepareStatement(SQL_CIUDAD_INSERTAR);
            sentencia.setString(1, nombre.trim());
            sentencia.setString(2, departamento.trim());
            sentencia.setString(3, codigoDane.trim());
            sentencia.executeUpdate();
            cerrarRecursos(null, sentencia, null);
            request.setAttribute("exito", "La ciudad fue creada correctamente.");
        }
    }

    private void ejecutarTipo(HttpServletRequest request, Connection conexion,
            String accion, Integer id, String nombre, String descripcion)
            throws SQLException {

        if ("eliminar".equals(accion)) {
            if (id == null) {
                return;
            }
            PreparedStatement sentencia = conexion.prepareStatement(SQL_TIPO_ELIMINAR);
            sentencia.setInt(1, id);
            sentencia.executeUpdate();
            cerrarRecursos(null, sentencia, null);
            request.setAttribute("exito", "El tipo de propiedad fue eliminado correctamente.");
            return;
        }

        if (nombre == null || nombre.isBlank()) {
            return;
        }

        if ("actualizar".equals(accion)) {
            if (id == null) {
                return;
            }
            PreparedStatement sentencia = conexion.prepareStatement(SQL_TIPO_ACTUALIZAR);
            sentencia.setString(1, nombre.trim());
            sentencia.setString(2, descripcion != null ? descripcion.trim() : null);
            sentencia.setInt(3, id);
            sentencia.executeUpdate();
            cerrarRecursos(null, sentencia, null);
            request.setAttribute("exito", "El tipo de propiedad fue actualizado correctamente.");
        } else if ("crear".equals(accion)) {
            PreparedStatement sentencia = conexion.prepareStatement(SQL_TIPO_INSERTAR);
            sentencia.setString(1, nombre.trim());
            sentencia.setString(2, descripcion != null ? descripcion.trim() : null);
            sentencia.executeUpdate();
            cerrarRecursos(null, sentencia, null);
            request.setAttribute("exito", "El tipo de propiedad fue creado correctamente.");
        }
    }

    private void ejecutarCaracteristica(HttpServletRequest request, Connection conexion,
            String accion, Integer id, String nombre, String icono)
            throws SQLException {

        if ("eliminar".equals(accion)) {
            if (id == null) {
                return;
            }
            PreparedStatement sentencia = conexion.prepareStatement(SQL_CARACTERISTICA_ELIMINAR);
            sentencia.setInt(1, id);
            sentencia.executeUpdate();
            cerrarRecursos(null, sentencia, null);
            request.setAttribute("exito", "La característica fue eliminada correctamente.");
            return;
        }

        if (nombre == null || nombre.isBlank()) {
            return;
        }

        if ("actualizar".equals(accion)) {
            if (id == null) {
                return;
            }
            PreparedStatement sentencia = conexion.prepareStatement(SQL_CARACTERISTICA_ACTUALIZAR);
            sentencia.setString(1, nombre.trim());
            sentencia.setString(2, icono != null ? icono.trim() : null);
            sentencia.setInt(3, id);
            sentencia.executeUpdate();
            cerrarRecursos(null, sentencia, null);
            request.setAttribute("exito", "La característica fue actualizada correctamente.");
        } else if ("crear".equals(accion)) {
            PreparedStatement sentencia = conexion.prepareStatement(SQL_CARACTERISTICA_INSERTAR);
            sentencia.setString(1, nombre.trim());
            sentencia.setString(2, icono != null ? icono.trim() : null);
            sentencia.executeUpdate();
            cerrarRecursos(null, sentencia, null);
            request.setAttribute("exito", "La característica fue creada correctamente.");
        }
    }

    private boolean validarObligatorios(String... campos) {
        for (String campo : campos) {
            if (campo == null || campo.isBlank()) {
                return false;
            }
        }
        return true;
    }

    private void cargarVista(HttpServletRequest request, String seccionEdicion,
            Integer idEdicion) {

        Connection conexion = null;

        // Listas garantizadas (nunca null) antes del forward: aunque una tabla esté
        // vacía o alguna consulta falle, la vista recibe new ArrayList<>().
        request.setAttribute("ciudades", new ArrayList<>());
        request.setAttribute("tipos", new ArrayList<>());
        request.setAttribute("caracteristicas", new ArrayList<>());

        try {
            conexion = ConexionBD.getConexion();
            request.setAttribute("ciudades", cargarCiudades(conexion));
            request.setAttribute("tipos", cargarTipos(conexion));
            request.setAttribute("caracteristicas", cargarCaracteristicas(conexion));

            if (idEdicion != null && seccionEdicion != null) {
                cargarEdicion(request, conexion, seccionEdicion, idEdicion);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(null, null, conexion);
        }
    }

    // Cada tabla se carga en su propio try-catch: si una está vacía o falla su
    // consulta, se devuelve new ArrayList<>() sin impedir la carga de las demás.
    private List<Ciudad> cargarCiudades(Connection conexion) {
        try {
            return listarCiudades(conexion);
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    private List<TipoPropiedad> cargarTipos(Connection conexion) {
        try {
            return listarTipos(conexion);
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    private List<Caracteristica> cargarCaracteristicas(Connection conexion) {
        try {
            return listarCaracteristicas(conexion);
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    private void cargarEdicion(HttpServletRequest request, Connection conexion,
            String seccionEdicion, Integer idEdicion) {
        try {
            switch (seccionEdicion) {
                case "ciudad":
                    request.setAttribute("editandoCiudad", obtenerCiudad(conexion, idEdicion));
                    request.setAttribute("seccionEdicion", "ciudad");
                    break;
                case "tipo":
                    request.setAttribute("editandoTipo", obtenerTipo(conexion, idEdicion));
                    request.setAttribute("seccionEdicion", "tipo");
                    break;
                case "caracteristica":
                    request.setAttribute("editandoCaracteristica", obtenerCaracteristica(conexion, idEdicion));
                    request.setAttribute("seccionEdicion", "caracteristica");
                    break;
                default:
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private List<Ciudad> listarCiudades(Connection conexion) throws SQLException {
        List<Ciudad> ciudades = new ArrayList<>();
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        try {
            sentencia = conexion.prepareStatement(SQL_CIUDADES);
            resultado = sentencia.executeQuery();
            while (resultado.next()) {
                ciudades.add(new Ciudad(
                        resultado.getInt("id_ciudad"),
                        resultado.getString("nombre"),
                        resultado.getString("departamento"),
                        resultado.getString("codigo_dane")));
            }
            return ciudades;
        } finally {
            cerrarRecursos(resultado, sentencia, null);
        }
    }

    private Ciudad obtenerCiudad(Connection conexion, int id) throws SQLException {
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        try {
            sentencia = conexion.prepareStatement(SQL_CIUDAD_POR_ID);
            sentencia.setInt(1, id);
            resultado = sentencia.executeQuery();
            if (resultado.next()) {
                return new Ciudad(
                        resultado.getInt("id_ciudad"),
                        resultado.getString("nombre"),
                        resultado.getString("departamento"),
                        resultado.getString("codigo_dane"));
            }
            return null;
        } finally {
            cerrarRecursos(resultado, sentencia, null);
        }
    }

    private List<TipoPropiedad> listarTipos(Connection conexion) throws SQLException {
        List<TipoPropiedad> tipos = new ArrayList<>();
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        try {
            sentencia = conexion.prepareStatement(SQL_TIPOS);
            resultado = sentencia.executeQuery();
            while (resultado.next()) {
                tipos.add(new TipoPropiedad(
                        resultado.getInt("id_tipo"),
                        resultado.getString("nombre"),
                        resultado.getString("descripcion")));
            }
            return tipos;
        } finally {
            cerrarRecursos(resultado, sentencia, null);
        }
    }

    private TipoPropiedad obtenerTipo(Connection conexion, int id) throws SQLException {
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        try {
            sentencia = conexion.prepareStatement(SQL_TIPO_POR_ID);
            sentencia.setInt(1, id);
            resultado = sentencia.executeQuery();
            if (resultado.next()) {
                return new TipoPropiedad(
                        resultado.getInt("id_tipo"),
                        resultado.getString("nombre"),
                        resultado.getString("descripcion"));
            }
            return null;
        } finally {
            cerrarRecursos(resultado, sentencia, null);
        }
    }

    private List<Caracteristica> listarCaracteristicas(Connection conexion) throws SQLException {
        List<Caracteristica> caracteristicas = new ArrayList<>();
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        try {
            sentencia = conexion.prepareStatement(SQL_CARACTERISTICAS);
            resultado = sentencia.executeQuery();
            while (resultado.next()) {
                caracteristicas.add(new Caracteristica(
                        resultado.getInt("id_caracteristica"),
                        resultado.getString("nombre"),
                        resultado.getString("icono")));
            }
            return caracteristicas;
        } finally {
            cerrarRecursos(resultado, sentencia, null);
        }
    }

    private Caracteristica obtenerCaracteristica(Connection conexion, int id) throws SQLException {
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        try {
            sentencia = conexion.prepareStatement(SQL_CARACTERISTICA_POR_ID);
            sentencia.setInt(1, id);
            resultado = sentencia.executeQuery();
            if (resultado.next()) {
                return new Caracteristica(
                        resultado.getInt("id_caracteristica"),
                        resultado.getString("nombre"),
                        resultado.getString("icono"));
            }
            return null;
        } finally {
            cerrarRecursos(resultado, sentencia, null);
        }
    }

    private boolean esAdministrador(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String rol = (String) request.getSession().getAttribute("rol");

        if (rol == null || request.getSession().getAttribute("idUsuario") == null) {
            request.getRequestDispatcher(JSP_LOGIN).forward(request, response);
            return false;
        }

        if (!"ADMINISTRADOR".equalsIgnoreCase(rol)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return false;
        }

        return true;
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
}