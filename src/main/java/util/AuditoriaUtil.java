package util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import db.ConexionBD;
import jakarta.servlet.http.HttpServletRequest;

/**
 * Helper para registrar eventos en la tabla de auditoria.
 *
 * Los servlets pueden invocar {@link #registrar} (abre su propia conexion)
 * o {@link #registrarEnTransaccion} para participar en la transaccion que ya
 * tiene abierta el Servlet (recomendado en operaciones multi-SQL).
 */
public final class AuditoriaUtil {

    private static final String SQL_INSERTAR =
            "INSERT INTO auditoria (id_usuario, accion, ip) VALUES (?, ?, ?)";

    private AuditoriaUtil() {
    }

    public static void registrar(HttpServletRequest request,
            Integer idUsuario, String tablaAfectada, String accion, String descripcion) {
        String ip = request != null ? request.getRemoteAddr() : null;
        registrar(idUsuario, tablaAfectada, accion, descripcion, ip);
    }

    public static void registrar(Integer idUsuario, String tablaAfectada,
            String accion, String descripcion, String ipOrigen) {

        Connection conexion = null;
        PreparedStatement sentencia = null;

        try {
            conexion = ConexionBD.getConexion();
            sentencia = conexion.prepareStatement(SQL_INSERTAR);
            asignarParametros(sentencia, idUsuario, tablaAfectada, accion, descripcion, ipOrigen);
            sentencia.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(sentencia, conexion);
        }
    }

    public static void registrarEnTransaccion(Connection conexion,
            Integer idUsuario, String tablaAfectada, String accion, String descripcion)
            throws SQLException {

        PreparedStatement sentencia = null;
        try {
            sentencia = conexion.prepareStatement(SQL_INSERTAR);
            asignarParametros(sentencia, idUsuario, tablaAfectada, accion, descripcion, null);
            sentencia.executeUpdate();
        } finally {
            if (sentencia != null) {
                sentencia.close();
            }
        }
    }

    private static void asignarParametros(PreparedStatement sentencia,
            Integer idUsuario, String tablaAfectada, String accion,
            String descripcion, String ipOrigen) throws SQLException {

        String detalle = tablaAfectada + " " + accion
                + (descripcion != null ? ": " + descripcion : "");
        if (detalle.length() > 255) {
            detalle = detalle.substring(0, 252) + "...";
        }
        sentencia.setObject(1, idUsuario);
        sentencia.setString(2, detalle);
        sentencia.setString(3, ipOrigen);
    }

    private static void cerrarRecursos(PreparedStatement sentencia, Connection conexion) {
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