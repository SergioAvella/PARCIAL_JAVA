package controladores;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import config.ConexionBD;
import modelos.Solicitud;
import util.AuditoriaUtil;
import util.AuthUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/SolicitudServlet")
public class SolicitudServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String JSP_MIS_SOLICITUDES = "/dashboard/cliente/mis-solicitudes.jsp";
    private static final String JSP_REVISAR_SOLICITUDES = "/dashboard/agente/revisar-solicitudes.jsp";

    private static final String SQL_INSERTAR_SOLICITUD =
            "INSERT INTO solicitud (id_usuario, id_propiedad, tipo_solicitud, estado) "
          + "VALUES (?, ?, ?, 'PENDIENTE')";

    private static final String SQL_INSERTAR_DOCUMENTO =
            "INSERT INTO documento_solicitud (id_solicitud, nombre_documento, archivo_url) "
          + "VALUES (?, ?, ?)";

    private static final String SQL_ACTUALIZAR_SOLICITUD =
            "UPDATE solicitud "
          + "SET estado = CASE WHEN ? = 'APROBADO' THEN 'APROBADO' ELSE 'RECHAZADO' END "
          + "WHERE id_solicitud = ?";

    private static final String SQL_SOLICITUDES_CLIENTE =
            "SELECT s.id_solicitud, s.id_propiedad, s.tipo_solicitud AS tipo, "
          + "s.estado, NULL AS observaciones, s.fecha_creacion AS fecha_solicitud, "
          + "p.titulo, p.direccion, p.precio, "
          + "(SELECT COUNT(*) FROM documento_solicitud d WHERE d.id_solicitud = s.id_solicitud) AS documentos "
          + "FROM solicitud s "
          + "INNER JOIN propiedad p ON p.id_propiedad = s.id_propiedad "
          + "WHERE s.id_usuario = ? "
          + "ORDER BY s.fecha_creacion DESC";

    private static final String SQL_SOLICITUDES_INMOBILIARIA =
            "SELECT s.id_solicitud, s.id_propiedad, s.tipo_solicitud AS tipo, "
          + "s.estado, NULL AS observaciones, s.fecha_creacion AS fecha_solicitud, "
          + "p.titulo, p.direccion, p.precio, "
          + "(SELECT COUNT(*) FROM documento_solicitud d WHERE d.id_solicitud = s.id_solicitud) AS documentos, "
          + "pf.nombres AS cliente, pf.apellidos AS cliente_apellido "
          + "FROM solicitud s "
          + "INNER JOIN propiedad p ON p.id_propiedad = s.id_propiedad "
          + "INNER JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria "
          + "LEFT JOIN perfil pf ON pf.id_usuario = s.id_usuario "
          + "WHERE i.id_inmobiliaria = ? "
          + "ORDER BY s.fecha_creacion DESC";

    private static final String SQL_INMOBILIARIA_POR_SOLICITUD =
            "SELECT p.id_inmobiliaria AS id_inmobiliaria "
          + "FROM solicitud s "
          + "INNER JOIN propiedad p ON p.id_propiedad = s.id_propiedad "
          + "WHERE s.id_solicitud = ?";

    private static final String SQL_INMOBILIARIA_POR_AGENTE =
            "SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ? LIMIT 1";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Inicialización defensiva: la vista siempre recibe la lista (nunca null).
        List<Solicitud> solicitudes = new ArrayList<>();

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

        // Las consultas filtran por el idUsuario de la sesión; se valida que sea
        // un Integer válido antes de preparar el PreparedStatement.
        Object idUsuarioObjeto = session.getAttribute("idUsuario");
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

            if (esCliente) {
                sentencia = conexion.prepareStatement(SQL_SOLICITUDES_CLIENTE);
                sentencia.setInt(1, idUsuario);
                resultado = sentencia.executeQuery();
                while (resultado.next()) {
                    solicitudes.add(mapearSolicitud(resultado, false));
                }
            } else {
                int idInmobiliaria = obtenerIdInmobiliaria(conexion, idUsuario);
                sentencia = conexion.prepareStatement(SQL_SOLICITUDES_INMOBILIARIA);
                sentencia.setInt(1, idInmobiliaria);
                resultado = sentencia.executeQuery();
                while (resultado.next()) {
                    solicitudes.add(mapearSolicitud(resultado, true));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(resultado, sentencia, conexion);
        }

        // Lista garantizada (nunca null) y JSP acorde al rol antes del forward.
        request.setAttribute("solicitudes", solicitudes);
        if (esCliente) {
            request.getRequestDispatcher(JSP_MIS_SOLICITUDES).forward(request, response);
        } else {
            request.getRequestDispatcher(JSP_REVISAR_SOLICITUDES).forward(request, response);
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

        Object idUsuarioObjeto = session.getAttribute("idUsuario");
        if (!(idUsuarioObjeto instanceof Integer)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        int idUsuario = (Integer) idUsuarioObjeto;

        boolean esCliente = AuthUtil.tieneRol(session, AuthUtil.ROL_CLIENTE);

        Connection conexion = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;

        try {
            conexion = ConexionBD.getConexion();

            if ("radicar".equals(accion)) {
                // Solo un cliente (o administrador) puede radicar solicitudes.
                if (!AuthUtil.tieneAlgunRol(session, AuthUtil.ROL_CLIENTE,
                        AuthUtil.ROL_ADMINISTRADOR)) {
                    response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                    return;
                }

                String idPropiedad = request.getParameter("id_propiedad");
                String tipo = request.getParameter("tipo");
                String documentoUrl = request.getParameter("documento_url");
                String nombreDocumento = request.getParameter("nombre_documento");

                if (idPropiedad == null || idPropiedad.isBlank() || tipo == null || tipo.isBlank()) {
                    request.setAttribute("solicitudes", new ArrayList<>());
                    request.getRequestDispatcher(JSP_MIS_SOLICITUDES).forward(request, response);
                    return;
                }

                sentencia = conexion.prepareStatement(SQL_INSERTAR_SOLICITUD,
                        PreparedStatement.RETURN_GENERATED_KEYS);
                sentencia.setInt(1, idUsuario);
                sentencia.setInt(2, Integer.parseInt(idPropiedad.trim()));
                sentencia.setString(3, tipo);
                sentencia.executeUpdate();

                int idSolicitud = -1;
                resultado = sentencia.getGeneratedKeys();
                if (resultado.next()) {
                    idSolicitud = resultado.getInt(1);
                }

                if (documentoUrl != null && !documentoUrl.isBlank()) {
                    sentencia.close();
                    sentencia = conexion.prepareStatement(SQL_INSERTAR_DOCUMENTO);
                    sentencia.setInt(1, idSolicitud);
                    sentencia.setString(2, nombreDocumento != null ? nombreDocumento : "Documento soporte");
                    sentencia.setString(3, documentoUrl);
                    sentencia.executeUpdate();
                }

                AuditoriaUtil.registrarEnTransaccion(conexion, idUsuario, "solicitud", "INSERT",
                        "Solicitud de tipo " + tipo + " radicada para el inmueble " + idPropiedad.trim());

                session.setAttribute("exito",
                        "Su solicitud fue radicada. Envíe los documentos para continuar.");
                response.sendRedirect(request.getContextPath() + "/SolicitudServlet");

            } else if ("cambiar_estado".equals(accion)) {
                // Aprobar/rechazar solicitudes es EXCLUSIVO de la inmobiliaria (o administrador).
                // Un cliente jamás puede cambiar el estado de sus propios trámites por POST.
                if (!AuthUtil.tieneAlgunRol(session, AuthUtil.ROL_INMOBILIARIA,
                        AuthUtil.ROL_ADMINISTRADOR)) {
                    response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                    return;
                }

                String idSolicitud = request.getParameter("id_solicitud");
                String estado = request.getParameter("estado");

                if (idSolicitud == null || idSolicitud.isBlank()
                        || (!"APROBADO".equals(estado) && !"RECHAZADO".equals(estado))) {
                    response.sendRedirect(request.getContextPath() + "/SolicitudServlet");
                    return;
                }

                int idSolicitudVal = Integer.parseInt(idSolicitud.trim());

                int idInmobiliariaSolicitud = obtenerInmobiliariaDeSolicitud(conexion, idSolicitudVal);
                if (idInmobiliariaSolicitud <= 0) {
                    response.sendRedirect(request.getContextPath() + "/SolicitudServlet");
                    return;
                }

                // Solo la inmobiliaria dueña de la propiedad puede responder la solicitud.
                if (!AuthUtil.tieneRol(session, AuthUtil.ROL_ADMINISTRADOR)) {
                    int idInmobiliariaUsuario = obtenerIdInmobiliaria(conexion, idUsuario);
                    if (idInmobiliariaUsuario != idInmobiliariaSolicitud) {
                        response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                        return;
                    }
                }

                sentencia = conexion.prepareStatement(SQL_ACTUALIZAR_SOLICITUD);
                sentencia.setString(1, estado);
                sentencia.setInt(2, idSolicitudVal);
                sentencia.executeUpdate();

                AuditoriaUtil.registrarEnTransaccion(conexion, idUsuario, "solicitud", "UPDATE",
                        "La solicitud " + idSolicitudVal + " fue marcada como " + estado);

                session.setAttribute("exito", "El estado de la solicitud fue actualizado.");
                response.sendRedirect(request.getContextPath() + "/SolicitudServlet");

            } else {
                response.sendRedirect(request.getContextPath() + "/SolicitudServlet");
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/SolicitudServlet");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("solicitudes", new ArrayList<>());
            if (esCliente) {
                request.getRequestDispatcher(JSP_MIS_SOLICITUDES).forward(request, response);
            } else {
                request.getRequestDispatcher(JSP_REVISAR_SOLICITUDES).forward(request, response);
            }
        } finally {
            cerrarRecursos(resultado, sentencia, conexion);
        }
    }

    private Solicitud mapearSolicitud(ResultSet resultado, boolean conCliente) throws SQLException {
        Solicitud solicitud = new Solicitud();
        solicitud.setIdSolicitud(resultado.getInt("id_solicitud"));
        solicitud.setIdPropiedad(resultado.getInt("id_propiedad"));
        solicitud.setTipo(resultado.getString("tipo"));
        solicitud.setEstado(resultado.getString("estado"));
        solicitud.setObservaciones(resultado.getString("observaciones"));
        solicitud.setFechaSolicitud(resultado.getTimestamp("fecha_solicitud"));
        solicitud.setCantidadDocumentos(resultado.getInt("documentos"));
        solicitud.setTituloPropiedad(resultado.getString("titulo"));
        solicitud.setDireccionPropiedad(resultado.getString("direccion"));
        solicitud.setPrecioPropiedad(resultado.getBigDecimal("precio"));
        if (conCliente) {
            solicitud.setNombreCliente(resultado.getString("cliente"));
            solicitud.setApellidoCliente(resultado.getString("cliente_apellido"));
        }
        return solicitud;
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

    private int obtenerInmobiliariaDeSolicitud(Connection conexion, int idSolicitud) throws SQLException {
        int idInmobiliaria = -1;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;

        try {
            sentencia = conexion.prepareStatement(SQL_INMOBILIARIA_POR_SOLICITUD);
            sentencia.setInt(1, idSolicitud);
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