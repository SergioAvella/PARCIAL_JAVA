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

import config.ConexionBD;
import util.AuditoriaUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/FavoritoServlet")
public class FavoritoServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String JSP_MIS_FAVORITOS = "/dashboard/cliente/mis-favoritos.jsp";

    private static final String SQL_INSERTAR_FAVORITO =
            "INSERT INTO favorito (id_usuario, id_propiedad) VALUES (?, ?)";

    private static final String SQL_ELIMINAR_FAVORITO =
            "DELETE FROM favorito WHERE id_usuario = ? AND id_propiedad = ?";

    private static final String SQL_LISTAR_FAVORITOS =
            "SELECT f.id_usuario, f.id_propiedad, "
          + "p.titulo, p.direccion, p.precio, p.estado, "
          + "c.nombre AS ciudad, tp.nombre AS tipo_propiedad "
          + "FROM favorito f "
          + "INNER JOIN propiedad p ON p.id_propiedad = f.id_propiedad "
          + "INNER JOIN ciudad c ON c.id_ciudad = p.id_ciudad "
          + "INNER JOIN tipo_propiedad tp ON tp.id_tipo = p.id_tipo "
          + "WHERE f.id_usuario = ? "
          + "ORDER BY f.id_propiedad DESC";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Inicialización defensiva: la vista siempre recibe la lista (nunca null).
        List<Map<String, Object>> favoritos = new ArrayList<>();

        HttpSession session = request.getSession(false);
        Object idUsuarioObjeto = session == null ? null : session.getAttribute("idUsuario");

        // Se valida el idUsuario de sesión antes de construir el PreparedStatement.
        if (!(idUsuarioObjeto instanceof Integer)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        int idUsuario = (Integer) idUsuarioObjeto;

        Connection conexion = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;

        try {
            conexion = ConexionBD.getConexion();
            sentencia = conexion.prepareStatement(SQL_LISTAR_FAVORITOS);
            sentencia.setInt(1, idUsuario);
            resultado = sentencia.executeQuery();

            while (resultado.next()) {
                Map<String, Object> favorito = new LinkedHashMap<>();
                favorito.put("id_propiedad", resultado.getInt("id_propiedad"));
                favorito.put("titulo", resultado.getString("titulo"));
                favorito.put("direccion", resultado.getString("direccion"));
                favorito.put("precio", resultado.getBigDecimal("precio"));
                favorito.put("estado", resultado.getString("estado"));
                favorito.put("ciudad", resultado.getString("ciudad"));
                favorito.put("tipo_propiedad", resultado.getString("tipo_propiedad"));
                favoritos.add(favorito);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(resultado, sentencia, conexion);
        }

        // Lista garantizada (nunca null) antes del forward.
        request.setAttribute("favoritos", favoritos);
        request.getRequestDispatcher(JSP_MIS_FAVORITOS).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        Object idUsuarioObjeto = session == null ? null : session.getAttribute("idUsuario");

        if (!(idUsuarioObjeto instanceof Integer)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        int idUsuario = (Integer) idUsuarioObjeto;

        String accion = request.getParameter("accion");
        Integer idPropiedad = parseId(request.getParameter("id_propiedad"));
        if (idPropiedad == null) {
            response.sendRedirect(request.getContextPath() + "/FavoritoServlet");
            return;
        }

        Connection conexion = null;
        PreparedStatement sentencia = null;

        try {
            conexion = ConexionBD.getConexion();

            if ("agregar".equals(accion)) {
                sentencia = conexion.prepareStatement(SQL_INSERTAR_FAVORITO);
                sentencia.setInt(1, idUsuario);
                sentencia.setInt(2, idPropiedad);
                sentencia.executeUpdate();
                AuditoriaUtil.registrarEnTransaccion(conexion, idUsuario, "favorito", "INSERT",
                        "El inmueble " + idPropiedad + " fue agregado a favoritos");
                session.setAttribute("exito", "El inmueble fue agregado a sus favoritos.");
            } else if ("quitar".equals(accion)) {
                sentencia = conexion.prepareStatement(SQL_ELIMINAR_FAVORITO);
                sentencia.setInt(1, idUsuario);
                sentencia.setInt(2, idPropiedad);
                sentencia.executeUpdate();
                AuditoriaUtil.registrarEnTransaccion(conexion, idUsuario, "favorito", "DELETE",
                        "El inmueble " + idPropiedad + " fue eliminado de favoritos");
                session.setAttribute("exito", "El inmueble fue eliminado de sus favoritos.");
            } else {
                response.sendRedirect(request.getContextPath() + "/FavoritoServlet");
                return;
            }

            response.sendRedirect(request.getContextPath() + "/FavoritoServlet");

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/FavoritoServlet");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/FavoritoServlet");
        } finally {
            cerrarRecursos(null, sentencia, conexion);
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
}