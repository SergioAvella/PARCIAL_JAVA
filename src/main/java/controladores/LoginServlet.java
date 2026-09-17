package controladores;

import db.ConexionBD;
import util.AuditoriaUtil;
import util.AuthUtil;
import util.PasswordUtil;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Locale;
import java.util.Set;
import java.util.TreeSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String JSP_LOGIN = "login.jsp";
    private static final String JSP_PANEL_ADMIN = "/dashboard/admin/panel.jsp";
    private static final String JSP_PANEL_AGENTE = "/dashboard/agente/panel.jsp";
    private static final String JSP_PANEL_CLIENTE = "/dashboard/cliente/panel.jsp";
    private static final String JSP_INICIO = "/index.jsp";

    private static final String SQL_USUARIO_POR_CORREO =
            "SELECT u.id_usuario, u.correo, u.estado, u.contrasena, "
          + "p.nombres, p.apellidos, r.nombre_rol AS nombre_rol "
          + "FROM usuario u "
          + "INNER JOIN usuario_rol ur ON ur.id_usuario = u.id_usuario "
          + "INNER JOIN rol r ON ur.id_rol = r.id_rol "
          + "LEFT JOIN perfil p ON p.id_usuario = u.id_usuario "
          + "WHERE u.correo = ?";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String correo = request.getParameter("correo");
        String contrasena = request.getParameter("contrasena");

        if (correo == null || correo.trim().isEmpty()
                || contrasena == null || contrasena.trim().isEmpty()) {
            request.setAttribute("error", "Por favor complete todos los campos.");
            request.getRequestDispatcher(JSP_LOGIN).forward(request, response);
            return;
        }

        Connection conexion = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;

        try {
            conexion = ConexionBD.getConexion();
            sentencia = conexion.prepareStatement(SQL_USUARIO_POR_CORREO);
            sentencia.setString(1, correo.trim());
            resultado = sentencia.executeQuery();

            String contrasenaAlmacenada = null;
            String estado = null;
            Integer idUsuario = null;
            String correoRegistrado = null;
            String nombres = null;
            String apellidos = null;
            Set<String> roles = new TreeSet<>();

            while (resultado.next()) {
                if (contrasenaAlmacenada == null) {
                    contrasenaAlmacenada = resultado.getString("contrasena");
                    estado = resultado.getString("estado");
                    idUsuario = resultado.getInt("id_usuario");
                    correoRegistrado = resultado.getString("correo");
                    nombres = resultado.getString("nombres");
                    apellidos = resultado.getString("apellidos");
                }
                String nombreRol = resultado.getString("nombre_rol");
                if (nombreRol != null && !nombreRol.isBlank()) {
                    roles.add(AuthUtil.normalizar(nombreRol));
                }
            }

            if (idUsuario == null) {
                request.setAttribute("error", "Correo electrónico o contraseña incorrectos.");
                request.getRequestDispatcher(JSP_LOGIN).forward(request, response);
                return;
            }

            if (!PasswordUtil.verificarContrasena(contrasena, contrasenaAlmacenada)) {
                request.setAttribute("error", "Correo electrónico o contraseña incorrectos.");
                request.getRequestDispatcher(JSP_LOGIN).forward(request, response);
                return;
            }

            if ("INACTIVO".equalsIgnoreCase(estado) || "BLOQUEADO".equalsIgnoreCase(estado)) {
                request.setAttribute("error", "Su cuenta se encuentra " + estado.toLowerCase(Locale.ROOT) + ".");
                request.getRequestDispatcher(JSP_LOGIN).forward(request, response);
                return;
            }

            String rolPrincipal = rolPrincipal(roles);

            HttpSession session = request.getSession();
            session.setAttribute("idUsuario", idUsuario);
            session.setAttribute("usuario", correoRegistrado);
            session.setAttribute("nombreCompleto",
                    (nombres != null ? nombres : "") + " " + (apellidos != null ? apellidos : ""));
            session.setAttribute(AuthUtil.ATTR_ROLES, roles);
            session.setAttribute("rol", rolPrincipal);

            AuditoriaUtil.registrar(request, idUsuario, "usuario", "LOGIN",
                    "Inicio de sesión del usuario " + correoRegistrado);

            String destino;
            if (AuthUtil.ROL_ADMINISTRADOR.equals(rolPrincipal)) {
                destino = JSP_PANEL_ADMIN;
            } else if (AuthUtil.ROL_INMOBILIARIA.equals(rolPrincipal)) {
                destino = JSP_PANEL_AGENTE;
            } else if (AuthUtil.ROL_CLIENTE.equals(rolPrincipal)) {
                destino = JSP_PANEL_CLIENTE;
            } else {
                destino = JSP_INICIO;
            }

            if (getServletContext().getResource(destino) == null) {
                destino = JSP_INICIO;
            }

            response.sendRedirect(request.getContextPath() + destino);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error interno en la base de datos: " + e.getMessage());
            request.getRequestDispatcher(JSP_LOGIN).forward(request, response);
        } finally {
            cerrarRecursos(resultado, sentencia, conexion);
        }
    }

    private String rolPrincipal(Set<String> roles) {
        if (roles.contains(AuthUtil.ROL_ADMINISTRADOR)) {
            return AuthUtil.ROL_ADMINISTRADOR;
        }
        if (roles.contains(AuthUtil.ROL_INMOBILIARIA)) {
            return AuthUtil.ROL_INMOBILIARIA;
        }
        if (roles.contains(AuthUtil.ROL_CLIENTE)) {
            return AuthUtil.ROL_CLIENTE;
        }
        return roles.isEmpty() ? "" : roles.iterator().next();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
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