package controladores;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import config.ConexionBD;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/PerfilServlet")
public class PerfilServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String JSP_PERFIL = "/dashboard/cliente/perfil.jsp";

    private static final String SQL_CARGAR_PERFIL =
            "SELECT u.id_usuario, u.correo, p.nombres, p.apellidos, p.telefono, p.direccion "
          + "FROM usuario u "
          + "LEFT JOIN perfil p ON p.id_usuario = u.id_usuario "
          + "WHERE u.id_usuario = ?";

    private static final String SQL_ACTUALIZAR_PERFIL =
            "UPDATE perfil SET nombres = ?, apellidos = ?, telefono = ?, direccion = ? WHERE id_usuario = ?";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer idUsuario = (Integer) request.getSession().getAttribute("idUsuario");
        if (idUsuario == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Connection conexion = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;

        try {
            conexion = ConexionBD.getConexion();
            sentencia = conexion.prepareStatement(SQL_CARGAR_PERFIL);
            sentencia.setInt(1, idUsuario);
            resultado = sentencia.executeQuery();

            if (resultado.next()) {
                request.setAttribute("nombre", resultado.getString("nombres"));
                request.setAttribute("apellido", resultado.getString("apellidos"));
                request.setAttribute("telefono", resultado.getString("telefono"));
                request.setAttribute("direccion", resultado.getString("direccion"));
                request.setAttribute("usuarioActual", resultado.getString("correo"));
            } else {
                request.setAttribute("error", "No se encontró información para el usuario en sesión.");
            }

            request.getRequestDispatcher(JSP_PERFIL).forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar el perfil del usuario.");
            request.getRequestDispatcher(JSP_PERFIL).forward(request, response);
        } finally {
            cerrarRecursos(resultado, sentencia, conexion);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        Integer idUsuario = (Integer) request.getSession().getAttribute("idUsuario");
        if (idUsuario == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String nombre = request.getParameter("nombre");
        String apellido = request.getParameter("apellido");
        String telefono = request.getParameter("telefono");
        String direccion = request.getParameter("direccion");

        if (nombre == null || nombre.trim().isEmpty()
                || apellido == null || apellido.trim().isEmpty()) {
            request.setAttribute("error", "Los campos nombre y apellido son obligatorios.");
            request.getRequestDispatcher(JSP_PERFIL).forward(request, response);
            return;
        }

        Connection conexion = null;
        PreparedStatement sentencia = null;

        try {
            conexion = ConexionBD.getConexion();
            sentencia = conexion.prepareStatement(SQL_ACTUALIZAR_PERFIL);
            sentencia.setString(1, nombre.trim());
            sentencia.setString(2, apellido.trim());
            sentencia.setString(3, telefono != null && !telefono.trim().isEmpty() ? telefono.trim() : null);
            sentencia.setString(4, direccion != null && !direccion.trim().isEmpty() ? direccion.trim() : null);
            sentencia.setInt(5, idUsuario);
            sentencia.executeUpdate();

            HttpSession session = request.getSession();
            session.setAttribute("nombreCompleto", nombre.trim() + " " + apellido.trim());

            request.setAttribute("nombre", nombre.trim());
            request.setAttribute("apellido", apellido.trim());
            request.setAttribute("telefono", telefono != null ? telefono.trim() : "");
            request.setAttribute("direccion", direccion != null ? direccion.trim() : "");
            request.setAttribute("mensaje", "Perfil actualizado correctamente");
            request.getRequestDispatcher(JSP_PERFIL).forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al actualizar el perfil del usuario.");
            request.getRequestDispatcher(JSP_PERFIL).forward(request, response);
        } finally {
            cerrarRecursos(null, sentencia, conexion);
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