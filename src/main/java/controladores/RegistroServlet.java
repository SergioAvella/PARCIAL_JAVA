package controladores;

import config.ConexionBD;
import util.PasswordUtil;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/RegistroServlet")
public class RegistroServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final int ROL_CLIENTE = 3;

    private static final String SQL_INSERTAR_USUARIO =
            "INSERT INTO usuario (correo, contrasena, estado) VALUES (?, ?, 'ACTIVO')";

    private static final String SQL_INSERTAR_USUARIO_ROL =
            "INSERT INTO usuario_rol (id_usuario, id_rol) VALUES (?, ?)";

    private static final String SQL_INSERTAR_PERFIL =
            "INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion) "
          + "VALUES (?, ?, ?, ?, ?, ?)";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String correo = request.getParameter("correo");
        String contrasena = request.getParameter("contrasena");
        String nombres = request.getParameter("nombres");
        String apellidos = request.getParameter("apellidos");
        String documento = request.getParameter("documento");
        String telefono = request.getParameter("telefono");
        String direccion = request.getParameter("direccion");

        if (esVacio(correo) || esVacio(contrasena) || esVacio(nombres) || esVacio(apellidos)) {
            request.setAttribute("error",
                    "Los campos correo, contraseña, nombres y apellidos son obligatorios.");
            request.getRequestDispatcher("registro.jsp").forward(request, response);
            return;
        }

        // Los registros públicos siempre se crean con el rol CLIENTE.
        // El valor enviado por el cliente (id_rol) se ignora para impedir la escalada
        // de privilegios desde la vista.
        int idRol = ROL_CLIENTE;

        String contrasenaHash = PasswordUtil.hashPassword(contrasena);

        Connection conn = null;
        PreparedStatement psUsuario = null;
        PreparedStatement psRol = null;
        PreparedStatement psPerfil = null;
        ResultSet rsGenerado = null;

        try {
            conn = ConexionBD.getConexion();
            conn.setAutoCommit(false);

            psUsuario = conn.prepareStatement(SQL_INSERTAR_USUARIO, Statement.RETURN_GENERATED_KEYS);
            psUsuario.setString(1, correo.trim());
            psUsuario.setString(2, contrasenaHash);
            psUsuario.executeUpdate();

            int idUsuario = -1;
            rsGenerado = psUsuario.getGeneratedKeys();
            if (rsGenerado.next()) {
                idUsuario = rsGenerado.getInt(1);
            }
            if (idUsuario <= 0) {
                throw new SQLException("No se pudo recuperar el id_usuario generado.");
            }

            psRol = conn.prepareStatement(SQL_INSERTAR_USUARIO_ROL);
            psRol.setInt(1, idUsuario);
            psRol.setInt(2, idRol);
            psRol.executeUpdate();

            psPerfil = conn.prepareStatement(SQL_INSERTAR_PERFIL);
            psPerfil.setInt(1, idUsuario);
            psPerfil.setString(2, nombres.trim());
            psPerfil.setString(3, apellidos.trim());
            psPerfil.setString(4, esVacio(documento) ? null : documento.trim());
            psPerfil.setString(5, esVacio(telefono) ? null : telefono.trim());
            psPerfil.setString(6, esVacio(direccion) ? null : direccion.trim());
            psPerfil.executeUpdate();

            conn.commit();

            request.getSession().setAttribute("mensaje", "Registro exitoso. Ya puede iniciar sesión.");
            response.sendRedirect(request.getContextPath() + "/login.jsp");

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }

            if (e.getErrorCode() == 1062) {
                request.setAttribute("error", "El correo '" + correo + "' ya se encuentra registrado.");
            } else {
                e.printStackTrace();
                request.setAttribute("error", "Error al procesar el registro: " + e.getMessage());
            }
            request.getRequestDispatcher("registro.jsp").forward(request, response);

        } finally {
            cerrar(rsGenerado);
            cerrar(psUsuario);
            cerrar(psRol);
            cerrar(psPerfil);
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private boolean esVacio(String valor) {
        return valor == null || valor.trim().isEmpty();
    }

    private void cerrar(AutoCloseable recurso) {
        if (recurso != null) {
            try {
                recurso.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}