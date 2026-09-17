package controladores;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import db.ConexionBD;
import modelos.Cita;
import util.AuditoriaUtil;
import util.AuthUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/CitaServlet")
public class CitaServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final int ERROR_DUPLICADO_UNIQUE_MYSQL = 1062;

    private static final String JSP_DETALLE = "/detalle-propiedad.jsp";
    private static final String JSP_MIS_CITAS = "/dashboard/cliente/mis-citas.jsp";
    private static final String JSP_GESTOR_CITAS = "/dashboard/agente/gestionar-citas.jsp";

    private static final String SQL_INSERTAR_CITA =
            "INSERT INTO cita (id_propiedad, id_usuario, fecha_hora, estado) "
          + "VALUES (?, ?, ?, 'PENDIENTE')";

    private static final String SQL_CAMBIAR_ESTADO_CITA =
            "UPDATE cita SET estado = ? WHERE id_cita = ?";

    private static final String SQL_CITAS_CLIENTE =
            "SELECT c.id_cita, c.id_propiedad, c.fecha_hora, c.estado, "
          + "NULL AS observaciones, "
          + "p.titulo, p.direccion, p.precio, i.nombre AS inmobiliaria "
          + "FROM cita c "
          + "INNER JOIN propiedad p ON p.id_propiedad = c.id_propiedad "
          + "INNER JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria "
          + "WHERE c.id_usuario = ? "
          + "ORDER BY c.fecha_hora DESC";

    private static final String SQL_CITAS_INMOBILIARIA =
            "SELECT c.id_cita, c.fecha_hora, c.estado, "
          + "NULL AS observaciones, "
          + "p.titulo, p.direccion, p.precio, p.id_propiedad, "
          + "pf.nombres AS cliente, pf.apellidos AS cliente_apellido "
          + "FROM cita c "
          + "INNER JOIN propiedad p ON p.id_propiedad = c.id_propiedad "
          + "INNER JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria "
          + "LEFT JOIN perfil pf ON pf.id_usuario = c.id_usuario "
          + "WHERE i.id_inmobiliaria = ? "
          + "ORDER BY c.fecha_hora DESC";

    private static final String SQL_INMOBILIARIA_POR_CITA =
            "SELECT p.id_inmobiliaria AS id_inmobiliaria "
          + "FROM cita c "
          + "INNER JOIN propiedad p ON p.id_propiedad = c.id_propiedad "
          + "WHERE c.id_cita = ?";

    private static final String SQL_INMOBILIARIA_POR_AGENTE =
            "SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ? LIMIT 1";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!AuthUtil.estaAutenticado(session)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        boolean esCliente = AuthUtil.tieneRol(session, AuthUtil.ROL_CLIENTE);
        boolean esOperador = AuthUtil.tieneAlgunRol(session, AuthUtil.ROL_INMOBILIARIA,
                AuthUtil.ROL_ADMINISTRADOR);

        if (!esCliente && !esOperador) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        Connection conexion = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        List<Cita> citas = new ArrayList<>();

        try {
            conexion = ConexionBD.getConexion();
            int idUsuario = (Integer) session.getAttribute("idUsuario");

            if (esCliente) {
                sentencia = conexion.prepareStatement(SQL_CITAS_CLIENTE);
                sentencia.setInt(1, idUsuario);
                resultado = sentencia.executeQuery();
                while (resultado.next()) {
                    citas.add(mapearCita(resultado, false));
                }
            } else {
                int idInmobiliaria = obtenerIdInmobiliaria(conexion, idUsuario);
                sentencia = conexion.prepareStatement(SQL_CITAS_INMOBILIARIA);
                sentencia.setInt(1, idInmobiliaria);
                resultado = sentencia.executeQuery();
                while (resultado.next()) {
                    citas.add(mapearCita(resultado, true));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al consultar las citas.");
        } catch (RuntimeException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al consultar las citas.");
        } finally {
            cerrarRecursos(resultado, sentencia, conexion);
        }

        // Lista garantizada (nunca null) y JSP acorde al rol antes del forward.
        request.setAttribute("citas", citas);
        if (esCliente) {
            request.getRequestDispatcher(JSP_MIS_CITAS).forward(request, response);
        } else {
            request.getRequestDispatcher(JSP_GESTOR_CITAS).forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String accion = request.getParameter("accion");

        HttpSession session = request.getSession(false);
        if (!AuthUtil.estaAutenticado(session)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Connection conexion = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;

        try {
            conexion = ConexionBD.getConexion();
            int idUsuario = (Integer) session.getAttribute("idUsuario");

            if ("agendar".equals(accion)) {
                // Solo un cliente (o administrador) puede agendar citas.
                if (!AuthUtil.tieneAlgunRol(session, AuthUtil.ROL_CLIENTE,
                        AuthUtil.ROL_ADMINISTRADOR)) {
                    response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                    return;
                }

                String idPropiedad = request.getParameter("id_propiedad");
                String fechaHora = request.getParameter("fecha_hora");

                if (idPropiedad == null || idPropiedad.isBlank()
                        || fechaHora == null || fechaHora.isBlank()) {
                    request.setAttribute("error",
                            "Debe indicar la propiedad y la fecha y hora de la visita.");
                    request.setAttribute("id_propiedad", idPropiedad);
                    request.getRequestDispatcher(JSP_DETALLE).forward(request, response);
                    return;
                }

                int idPropiedadVal = Integer.parseInt(idPropiedad.trim());

                sentencia = conexion.prepareStatement(SQL_INSERTAR_CITA);
                sentencia.setInt(1, idPropiedadVal);
                sentencia.setInt(2, idUsuario);
                sentencia.setString(3, fechaHora);
                sentencia.executeUpdate();

                AuditoriaUtil.registrarEnTransaccion(conexion, idUsuario, "cita", "INSERT",
                        "Cita agendada para el inmueble " + idPropiedadVal
                                + " el " + fechaHora);

                session.setAttribute("exito",
                        "La cita fue agendada correctamente y queda pendiente de aprobación.");
                response.sendRedirect(request.getContextPath() + "/CitaServlet");

            } else if ("APROBADA".equals(accion) || "RECHAZADA".equals(accion)) {
                // Aprobar/rechazar citas es EXCLUSIVO de la inmobiliaria (o administrador).
                // Un cliente jamás puede cambiar el estado de sus propios trámites por POST.
                if (!AuthUtil.tieneAlgunRol(session, AuthUtil.ROL_INMOBILIARIA,
                        AuthUtil.ROL_ADMINISTRADOR)) {
                    response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                    return;
                }

                String idCita = request.getParameter("id_cita");
                if (idCita == null || idCita.isBlank()) {
                    request.setAttribute("error", "Debe indicar la cita a modificar.");
                    response.sendRedirect(request.getContextPath() + "/CitaServlet");
                    return;
                }

                int idCitaVal = Integer.parseInt(idCita.trim());
                String nuevoEstado = "APROBADA".equals(accion) ? "APROBADA" : "RECHAZADA";

                int idInmobiliariaCita = obtenerInmobiliariaDeCita(conexion, idCitaVal);
                if (idInmobiliariaCita <= 0) {
                    request.setAttribute("error", "La cita seleccionada no existe.");
                    response.sendRedirect(request.getContextPath() + "/CitaServlet");
                    return;
                }

                // Solo la inmobiliaria dueña de la propiedad puede responder la cita.
                if (!AuthUtil.tieneRol(session, AuthUtil.ROL_ADMINISTRADOR)) {
                    int idInmobiliariaUsuario = obtenerIdInmobiliaria(conexion, idUsuario);
                    if (idInmobiliariaUsuario != idInmobiliariaCita) {
                        response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                        return;
                    }
                }

                sentencia = conexion.prepareStatement(SQL_CAMBIAR_ESTADO_CITA);
                sentencia.setString(1, nuevoEstado);
                sentencia.setInt(2, idCitaVal);
                sentencia.executeUpdate();

                AuditoriaUtil.registrarEnTransaccion(conexion, idUsuario, "cita", "UPDATE",
                        "La cita " + idCitaVal + " fue marcada como " + nuevoEstado);

                session.setAttribute("exito", "El estado de la cita fue actualizado.");
                response.sendRedirect(request.getContextPath() + "/CitaServlet");

            } else {
                request.setAttribute("error", "Acción no válida para la cita.");
                response.sendRedirect(request.getContextPath() + "/CitaServlet");
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("error", "El identificador proporcionado no es válido.");
            request.getRequestDispatcher(JSP_DETALLE).forward(request, response);
        } catch (SQLException e) {
            if (e.getErrorCode() == ERROR_DUPLICADO_UNIQUE_MYSQL) {
                request.setAttribute("error",
                        "Ya existe una cita agendada en esta fecha u hora para este inmueble.");
                request.setAttribute("id_propiedad", request.getParameter("id_propiedad"));
            } else {
                e.printStackTrace();
                request.setAttribute("error", "Error al procesar la cita.");
            }
            request.getRequestDispatcher(JSP_DETALLE).forward(request, response);
        } finally {
            cerrarRecursos(resultado, sentencia, conexion);
        }
    }

    private Cita mapearCita(ResultSet resultado, boolean conCliente) throws SQLException {
        Cita cita = new Cita();
        cita.setIdCita(resultado.getInt("id_cita"));
        cita.setIdPropiedad(resultado.getInt("id_propiedad"));
        cita.setFechaHora(resultado.getTimestamp("fecha_hora"));
        cita.setEstado(resultado.getString("estado"));
        cita.setObservaciones(resultado.getString("observaciones"));
        cita.setTituloPropiedad(resultado.getString("titulo"));
        cita.setDireccionPropiedad(resultado.getString("direccion"));
        cita.setPrecioPropiedad(resultado.getBigDecimal("precio"));
        cita.setInmobiliaria(resultado.getString("inmobiliaria"));
        if (conCliente) {
            cita.setNombreCliente(resultado.getString("cliente"));
            cita.setApellidoCliente(resultado.getString("cliente_apellido"));
        }
        return cita;
    }

    private int obtenerIdInmobiliaria(Connection conexion, int idUsuario) throws SQLException {
        int idInmobiliaria = -1;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;

        try {
            sentencia = conexion.prepareStatement(SQL_INMOBILIARIA_POR_AGENTE);
            sentencia.setInt(1, idUsuario);
            resultado = sentencia.executeQuery();
            if (resultado.next()) {
                idInmobiliaria = resultado.getInt("id_inmobiliaria");
            }
            return idInmobiliaria;
        } finally {
            cerrarRecursos(resultado, sentencia, null);
        }
    }

    private int obtenerInmobiliariaDeCita(Connection conexion, int idCita) throws SQLException {
        int idInmobiliaria = -1;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;

        try {
            sentencia = conexion.prepareStatement(SQL_INMOBILIARIA_POR_CITA);
            sentencia.setInt(1, idCita);
            resultado = sentencia.executeQuery();
            if (resultado.next()) {
                idInmobiliaria = resultado.getInt("id_inmobiliaria");
            }
            return idInmobiliaria;
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