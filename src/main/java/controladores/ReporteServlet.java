package controladores;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import config.ConexionBD;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/reportes")
public class ReporteServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String JSP_REPORTES = "/dashboard/admin/reportes.jsp";

    private static final String SQL_REPORTE_1 =
            "SELECT p.id_propiedad, p.titulo, p.precio, "
          + "c.nombre AS ciudad, tp.nombre AS tipo_propiedad, "
          + "i.nombre AS inmobiliaria "
          + "FROM propiedad p "
          + "INNER JOIN ciudad c ON c.id_ciudad = p.id_ciudad "
          + "INNER JOIN tipo_propiedad tp ON tp.id_tipo = p.id_tipo "
          + "INNER JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria "
          + "ORDER BY p.fecha_publicacion DESC";

    private static final String SQL_REPORTE_2 =
            "SELECT ca.nombre, ca.descripcion "
          + "FROM caracteristica ca "
          + "INNER JOIN propiedad_caracteristica pc "
          + "ON pc.id_caracteristica = ca.id_caracteristica "
          + "WHERE pc.id_propiedad = ? "
          + "ORDER BY ca.nombre";

    private static final String SQL_REPORTE_3 =
            "SELECT p.id_propiedad, p.titulo, p.direccion, "
          + "p.matricula_inmobiliaria, p.estado "
          + "FROM propiedad p "
          + "LEFT JOIN cita ci ON ci.id_propiedad = p.id_propiedad "
          + "WHERE ci.id_cita IS NULL "
          + "ORDER BY p.titulo";

    private static final String SQL_REPORTE_4 =
            "SELECT c.nombre AS ciudad, COUNT(*) AS total_disponibles "
          + "FROM propiedad p "
          + "INNER JOIN ciudad c ON c.id_ciudad = p.id_ciudad "
          + "WHERE p.estado = 'DISPONIBLE' "
          + "GROUP BY c.nombre "
          + "HAVING COUNT(*) > 2 "
          + "ORDER BY total_disponibles DESC";

    private static final String SQL_REPORTE_5 =
            "SELECT s.estado, COUNT(*) AS total_solicitudes "
          + "FROM solicitud s "
          + "GROUP BY s.estado "
          + "ORDER BY s.estado";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idPropiedad = request.getParameter("id_propiedad");

        Connection conexion = null;

        try {
            conexion = ConexionBD.getConexion();

            List<Map<String, Object>> reporte1 = ejecutarReporte1(conexion);
            List<Map<String, Object>> reporte2 = ejecutarReporte2(conexion, idPropiedad);
            List<Map<String, Object>> reporte3 = ejecutarReporte3(conexion);
            List<Map<String, Object>> reporte4 = ejecutarReporte4(conexion);
            List<Map<String, Object>> reporte5 = ejecutarReporte5(conexion);

            request.setAttribute("reporte1", reporte1);
            request.setAttribute("reporte2", reporte2);
            request.setAttribute("reporte3", reporte3);
            request.setAttribute("reporte4", reporte4);
            request.setAttribute("reporte5", reporte5);

            request.getRequestDispatcher(JSP_REPORTES).forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al generar los reportes del sistema.");
            request.getRequestDispatcher(JSP_REPORTES).forward(request, response);
        } finally {
            cerrarRecursos(null, null, conexion);
        }
    }

    private List<Map<String, Object>> ejecutarReporte1(Connection conexion)
            throws SQLException {
        return listarRegistros(conexion, SQL_REPORTE_1, null);
    }

    private List<Map<String, Object>> ejecutarReporte2(Connection conexion,
            String idPropiedad) throws SQLException {
        Object parametro = null;
        if (idPropiedad != null && !idPropiedad.isBlank()) {
            parametro = Integer.valueOf(idPropiedad.trim());
        }
        return listarRegistros(conexion, SQL_REPORTE_2, parametro);
    }

    private List<Map<String, Object>> ejecutarReporte3(Connection conexion)
            throws SQLException {
        return listarRegistros(conexion, SQL_REPORTE_3, null);
    }

    private List<Map<String, Object>> ejecutarReporte4(Connection conexion)
            throws SQLException {
        return listarRegistros(conexion, SQL_REPORTE_4, null);
    }

    private List<Map<String, Object>> ejecutarReporte5(Connection conexion)
            throws SQLException {
        return listarRegistros(conexion, SQL_REPORTE_5, null);
    }

    private List<Map<String, Object>> listarRegistros(Connection conexion,
            String sql, Object parametro) throws SQLException {

        List<Map<String, Object>> registros = new ArrayList<>();
        PreparedStatement sentencia = null;
        ResultSet resultado = null;

        try {
            sentencia = conexion.prepareStatement(sql);
            if (parametro != null) {
                sentencia.setObject(1, parametro);
            }
            resultado = sentencia.executeQuery();

            ResultSetMetaData metadatos = resultado.getMetaData();
            int cantidadColumnas = metadatos.getColumnCount();

            while (resultado.next()) {
                Map<String, Object> fila = new LinkedHashMap<>();
                for (int i = 1; i <= cantidadColumnas; i++) {
                    fila.put(metadatos.getColumnLabel(i), resultado.getObject(i));
                }
                registros.add(fila);
            }
            return registros;

        } finally {
            cerrarRecursos(resultado, sentencia, null);
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