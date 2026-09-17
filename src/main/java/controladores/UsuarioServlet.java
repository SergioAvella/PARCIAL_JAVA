package controladores;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import db.ConexionBD;
import util.AuditoriaUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/UsuarioServlet")
public class UsuarioServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String JSP_USUARIOS = "/dashboard/admin/usuarios.jsp";
    private static final String JSP_LOGIN = "/login.jsp";

    private static final String SQL_USUARIOS =
            "SELECT u.id_usuario, u.correo, u.estado, ur.id_rol, "
          + "p.nombres, p.apellidos, p.telefono "
          + "FROM usuario u "
          + "LEFT JOIN perfil p ON p.id_usuario = u.id_usuario "
          + "LEFT JOIN usuario_rol ur ON ur.id_usuario = u.id_usuario "
          + "ORDER BY u.id_usuario";

    private static final String SQL_ROLES =
            "SELECT id_rol, nombre_rol AS nombre, descripcion "
          + "FROM rol WHERE activo = 1 ORDER BY id_rol";

    private static final String SQL_ACTUALIZAR_ROL =
            "UPDATE usuario_rol SET id_rol = ? WHERE id_usuario = ?";

    private static final String SQL_INSERTAR_ROL =
            "INSERT INTO usuario_rol (id_usuario, id_rol, asignado_en) VALUES (?, ?, NOW())";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!esAdministrador(request, response)) {
            return;
        }

        cargarVista(request);
        request.getRequestDispatcher(JSP_USUARIOS).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        if (!esAdministrador(request, response)) {
            return;
        }

        String accion = request.getParameter("accion");

        if ("asignar_rol".equals(accion)) {
            String idUsuario = request.getParameter("id_usuario");
            String idRol = request.getParameter("id_rol");

            if (idUsuario == null || idUsuario.isBlank() || idRol == null || idRol.isBlank()) {
                request.setAttribute("error", "Debe seleccionar un usuario y un rol.");
                cargarVista(request);
                request.getRequestDispatcher(JSP_USUARIOS).forward(request, response);
                return;
            }

            Connection conexion = null;
            PreparedStatement sentencia = null;
            ResultSet resultado = null;

            try {
                conexion = ConexionBD.getConexion();
                int idUsuarioInt = Integer.parseInt(idUsuario.trim());
                int idRolInt = Integer.parseInt(idRol.trim());

                sentencia = conexion.prepareStatement(SQL_ACTUALIZAR_ROL);
                sentencia.setInt(1, idRolInt);
                sentencia.setInt(2, idUsuarioInt);
                int filas = sentencia.executeUpdate();

                if (filas == 0) {
                    sentencia.close();
                    sentencia = conexion.prepareStatement(SQL_INSERTAR_ROL);
                    sentencia.setInt(1, idUsuarioInt);
                    sentencia.setInt(2, idRolInt);
                    sentencia.executeUpdate();
                }

                Integer idUsuarioSesion = (Integer) request.getSession().getAttribute("idUsuario");
                AuditoriaUtil.registrarEnTransaccion(conexion, idUsuarioSesion,
                        "usuario", "UPDATE", "Asignación del rol " + idRolInt
                                + " al usuario " + idUsuarioInt);

                request.setAttribute("exito", "El rol del usuario fue actualizado correctamente.");

            } catch (NumberFormatException e) {
                request.setAttribute("error", "Los identificadores seleccionados no son válidos.");
            } catch (SQLException e) {
                e.printStackTrace();
                request.setAttribute("error", "No fue posible actualizar el rol del usuario.");
            } finally {
                cerrarRecursos(resultado, sentencia, conexion);
            }
        } else {
            request.setAttribute("error", "Acción no válida para el módulo de usuarios.");
        }

        cargarVista(request);
        request.getRequestDispatcher(JSP_USUARIOS).forward(request, response);
    }

    private boolean esAdministrador(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String rol = (String) request.getSession().getAttribute("rol");

        if (rol == null || request.getSession().getAttribute("idUsuario") == null) {
            request.setAttribute("error", "Debes iniciar sesión para acceder a este recurso.");
            request.getRequestDispatcher(JSP_LOGIN).forward(request, response);
            return false;
        }

        if (!"ADMINISTRADOR".equalsIgnoreCase(rol)) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return false;
        }

        return true;
    }

    private void cargarVista(HttpServletRequest request) {
        Connection conexion = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;

        List<Map<String, Object>> usuarios = new ArrayList<>();
        List<Map<String, Object>> roles = new ArrayList<>();

        try {
            conexion = ConexionBD.getConexion();

            sentencia = conexion.prepareStatement(SQL_USUARIOS);
            resultado = sentencia.executeQuery();
            while (resultado.next()) {
                Map<String, Object> usuario = new LinkedHashMap<>();
                usuario.put("id_usuario", resultado.getInt("id_usuario"));
                usuario.put("correo", resultado.getString("correo"));
                usuario.put("nombres", resultado.getString("nombres"));
                usuario.put("apellidos", resultado.getString("apellidos"));
                usuario.put("telefono", resultado.getString("telefono"));
                usuario.put("estado", resultado.getString("estado"));
                usuario.put("id_rol", resultado.getObject("id_rol"));
                usuarios.add(usuario);
            }
            cerrarRecursos(resultado, sentencia, null);

            sentencia = conexion.prepareStatement(SQL_ROLES);
            resultado = sentencia.executeQuery();
            while (resultado.next()) {
                Map<String, Object> rol = new LinkedHashMap<>();
                rol.put("id_rol", resultado.getInt("id_rol"));
                rol.put("nombre", resultado.getString("nombre"));
                rol.put("descripcion", resultado.getString("descripcion"));
                roles.add(rol);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "No fue posible cargar la información de usuarios.");
        } finally {
            cerrarRecursos(resultado, sentencia, conexion);
        }

        request.setAttribute("usuarios", usuarios);
        request.setAttribute("roles", roles);
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