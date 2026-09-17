package filtros;

import java.io.IOException;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import util.AuthUtil;

// Protege los paneles privados (/dashboard/*), los reportes administrativos
// y los servlets de trámites. El catálogo público /propiedades NO se filtra.
@WebFilter(urlPatterns = {
    "/dashboard/admin/*",
    "/dashboard/agente/*",
    "/dashboard/cliente/*",
    "/reportes",
    "/PerfilServlet",
    "/CitaServlet",
    "/SolicitudServlet",
    "/FavoritoServlet",
    "/UsuarioServlet",
    "/mantenimiento-propiedad",
    "/catalogos",
    "/auditorias"
})
public class FiltroAutenticacion implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        // Evitar almacenamiento en caché para proteger las páginas tras cerrar sesión
        httpResponse.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        httpResponse.setHeader("Pragma", "no-cache");
        httpResponse.setDateHeader("Expires", 0);

        HttpSession session = httpRequest.getSession(false);

        // 1. Validar si existe sesión activa y si el usuario está autenticado
        if (!AuthUtil.estaAutenticado(session)) {
            httpRequest.setAttribute("error", "Debes iniciar sesión para acceder a este recurso.");
            httpRequest.getRequestDispatcher("/login.jsp").forward(httpRequest, httpResponse);
            return;
        }

        String contexto = httpRequest.getContextPath();
        String uri = httpRequest.getRequestURI();
        String ruta = uri.substring(contexto.length());

        // 2. Control de Acceso basado en Roles (RBAC) consultando el Set<String> de la sesión.
        //    Sin permisos se redirige con sendRedirect a /acceso-denegado.jsp.
        boolean permitido = true;

        if (ruta.startsWith("/dashboard/admin/")) {
            permitido = AuthUtil.tieneRol(session, AuthUtil.ROL_ADMINISTRADOR);
        } else if (ruta.startsWith("/dashboard/agente/")) {
            permitido = AuthUtil.tieneAlgunRol(session, AuthUtil.ROL_INMOBILIARIA,
                    AuthUtil.ROL_ADMINISTRADOR);
        } else if (ruta.startsWith("/dashboard/cliente/")) {
            permitido = AuthUtil.tieneAlgunRol(session, AuthUtil.ROL_CLIENTE,
                    AuthUtil.ROL_ADMINISTRADOR);
        } else if (ruta.equals("/mantenimiento-propiedad")) {
            permitido = AuthUtil.tieneAlgunRol(session, AuthUtil.ROL_INMOBILIARIA,
                    AuthUtil.ROL_ADMINISTRADOR);
        } else if (ruta.equals("/reportes")) {
            permitido = AuthUtil.tieneRol(session, AuthUtil.ROL_ADMINISTRADOR);
        } else if (ruta.equals("/catalogos") || ruta.equals("/auditorias")) {
            permitido = AuthUtil.tieneRol(session, AuthUtil.ROL_ADMINISTRADOR);
        }

        if (!permitido) {
            httpResponse.sendRedirect(contexto + "/acceso-denegado.jsp");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}