package controladores;

import java.io.IOException;

import util.AuditoriaUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/CerrarSesionServlet")
public class CerrarSesionServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null) {
            Integer idUsuario = (Integer) session.getAttribute("idUsuario");
            Object usuarioCorreo = session.getAttribute("usuario");
            AuditoriaUtil.registrar(request, idUsuario, "usuario", "LOGOUT",
                    "Cierre de sesión"
                            + (usuarioCorreo != null ? " del usuario " + usuarioCorreo : ""));
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }
}