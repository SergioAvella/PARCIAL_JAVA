package util;

import java.util.Collections;
import java.util.HashSet;
import java.util.Locale;
import java.util.Set;

import jakarta.servlet.http.HttpSession;

public final class AuthUtil {

    public static final String ATTR_ROLES = "roles";

    public static final String ROL_ADMINISTRADOR = "ADMINISTRADOR";
    public static final String ROL_INMOBILIARIA = "INMOBILIARIA";
    public static final String ROL_CLIENTE = "CLIENTE";

    private AuthUtil() {
    }

    public static boolean estaAutenticado(HttpSession session) {
        return session != null && session.getAttribute("idUsuario") != null;
    }

    public static Set<String> obtenerRoles(HttpSession session) {
        if (session == null) {
            return Collections.emptySet();
        }
        Object atributo = session.getAttribute(ATTR_ROLES);
        Set<String> roles = new HashSet<>();
        if (atributo instanceof Set<?>) {
            for (Object elemento : (Set<?>) atributo) {
                if (elemento != null) {
                    roles.add(normalizar(String.valueOf(elemento)));
                }
            }
        }
        return roles;
    }

    public static boolean tieneRol(HttpSession session, String rol) {
        return tieneAlgunRol(session, rol);
    }

    public static boolean tieneAlgunRol(HttpSession session, String... rolesRequeridos) {
        Set<String> roles = obtenerRoles(session);
        if (roles.isEmpty()) {
            return false;
        }
        for (String rol : rolesRequeridos) {
            if (roles.contains(normalizar(rol))) {
                return true;
            }
        }
        return false;
    }

    public static String normalizar(String rol) {
        return rol == null ? "" : rol.trim().toUpperCase(Locale.ROOT);
    }
}