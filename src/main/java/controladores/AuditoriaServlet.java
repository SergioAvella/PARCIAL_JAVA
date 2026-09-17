package controladores;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import db.ConexionBD;
import modelos.Auditoria;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/auditorias")
public class AuditoriaServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String JSP_AUDITORIAS = "/dashboard/admin/auditorias.jsp";
    private static final String JSP_LOGIN = "/login.jsp";

    private static final String SQL_AUDITORIAS =
            "SELECT a.id_auditoria, a.id_usuario, a.tabla_afectada, a.accion, "
          + "a.descripcion, a.ip_origen, a.fecha_evento, u.correo AS correo_usuario "
          + "FROM auditoria a "
          + "LEFT JOIN usuario u ON u.id_usuario = a.id_usuario "
          + "WHERE (1 = 1) "
          + " AND (? IS NULL OR a.accion = ?) "
          + " AND (? IS NULL OR a.tabla_afectada = ?) "
          + "ORDER BY a.fecha_evento DESC "
          + "LIMIT 300";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!esAdministrador(request, response)) {
            return;
        }

        String filtroAccion = request.getParameter("accion");
        String filtroTabla = request.getParameter("tabla");

        Connection conexion = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;

        List<Auditoria> auditorias = new ArrayList<>();

        try {
            conexion = ConexionBD.getConexion();
            sentencia = conexion.prepareStatement(SQL_AUDITORIAS);
            sentencia.setString(1, filtroAccion != null && !filtroAccion.isBlank() ? filtroAccion : null);
            sentencia.setString(2, filtroAccion != null && !filtroAccion.isBlank() ? filtroAccion : null);
            sentencia.setString(3, filtroTabla != null && !filtroTabla.isBlank() ? filtroTabla : null);
            sentencia.setString(4, filtroTabla != null && !filtroTabla.isBlank() ? filtroTabla : null);
            resultado = sentencia.executeQuery();

            while (resultado.next()) {
                Auditoria auditoria = new Auditoria();
                auditoria.setIdAuditoria(resultado.getLong("id_auditoria"));
                auditoria.setIdUsuario(resultado.getObject("id_usuario") != null
                        ? resultado.getInt("id_usuario") : null);
                auditoria.setTablaAfectada(resultado.getString("tabla_afectada"));
                auditoria.setAccion(resultado.getString("accion"));
                auditoria.setDescripcion(resultado.getString("descripcion"));
                auditoria.setIpOrigen(resultado.getString("ip_origen"));
                auditoria.setFechaEvento(resultado.getTimestamp("fecha_evento"));
                auditoria.setCorreoUsuario(resultado.getString("correo_usuario"));
                auditorias.add(auditoria);
            }

            request.setAttribute("auditorias", auditorias);
            request.setAttribute("filtroAccion", filtroAccion);
            request.setAttribute("filtroTabla", filtroTabla);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "No fue posible consultar la bitácora de auditoría.");
        } finally {
            cerrarRecursos(resultado, sentencia, conexion);
        }

        request.getRequestDispatcher(JSP_AUDITORIAS).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
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
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return false;
        }

        return true;
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