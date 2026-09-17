package config;

import java.io.IOException;
import java.io.InputStream;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ConexionBD {

    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";
    private static final String ARCHIVO_CONFIG = "config.properties";

    private static final String HOST_LOCAL = "localhost";
    private static final String PUERTO_POR_DEFECTO = "3306";
    private static final String BD_LOCAL = "inmobiliaria_db";
    private static final String HOST_RAILWAY = "iriguchi.proxy.rlwy.net";
    private static final String PUERTO_RAILWAY = "46322";
    private static final String BD_RAILWAY = "railway";
    private static final String USUARIO_POR_DEFECTO = "root";

    private static final String PARAMETROS_JDBC =
            "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";

    private static final Pattern PATRON_MYSQL = Pattern.compile(
            "^(?:jdbc:)?mysql://(?:([^:@/]+)(?::([^@/]*))?@)?([^:/?#]+)(?::(\\d+))?/([^?]+).*$");

    private static final String URL;
    private static final String USER;
    private static final String PASSWORD;

    static {
        try {
            Class.forName(DRIVER);
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError("No se encontró el driver JDBC de MySQL: " + e.getMessage());
        }

        Properties propiedades = cargarConfiguracion();
        Credenciales credenciales = resolverCredenciales(propiedades);
        URL = credenciales.url;
        USER = credenciales.usuario;
        PASSWORD = credenciales.password;
    }

    private ConexionBD() {
    }

    private static Credenciales resolverCredenciales(Properties propiedades) {
        String host = System.getenv("MYSQLHOST");
        String puerto = System.getenv("MYSQLPORT");
        String baseDatos = System.getenv("MYSQLDATABASE");
        String usuario = System.getenv("MYSQLUSER");
        String password = System.getenv("MYSQLPASSWORD");
        boolean enRailway = host != null && !host.isBlank();

        String urlPlataforma = primerNoVacio(System.getenv("MYSQL_URL"), System.getenv("DATABASE_URL"));
        if (urlPlataforma != null) {
            Credenciales desdeUrl = parsearUrlMySQL(urlPlataforma);
            if (desdeUrl != null) {
                return desdeUrl;
            }
        }

        if (enRailway) {
            return new Credenciales(
                    construirUrl(valor(host, HOST_RAILWAY),
                            valor(puerto, PUERTO_POR_DEFECTO),
                            valor(baseDatos, BD_RAILWAY)),
                    valor(usuario, USUARIO_POR_DEFECTO),
                    password != null ? password : "");
        }

        String url = primerNoVacio(System.getenv("DB_URL"), propiedades.getProperty("db.url"));
        String usuarioLocal = primerNoVacio(System.getenv("DB_USER"),
                System.getenv("MYSQLUSER"), propiedades.getProperty("db.user"));
        String passwordLocal = primerNoVacio(System.getenv("DB_PASSWORD"),
                System.getenv("MYSQLPASSWORD"), propiedades.getProperty("db.password"));

        if (url != null) {
            return new Credenciales(url,
                    valor(usuarioLocal, USUARIO_POR_DEFECTO),
                    passwordLocal != null ? passwordLocal : "");
        }

        return new Credenciales(construirUrl(HOST_LOCAL, PUERTO_POR_DEFECTO, BD_LOCAL),
                USUARIO_POR_DEFECTO, "");
    }

    private static Credenciales parsearUrlMySQL(String url) {
        Matcher matcher = PATRON_MYSQL.matcher(url.trim());
        if (!matcher.matches()) {
            return null;
        }

        String usuario = decodificar(matcher.group(1));
        String password = decodificar(matcher.group(2));
        String host = matcher.group(3);
        String puerto = matcher.group(4);
        String baseDatos = matcher.group(5);

        return new Credenciales(
                construirUrl(host, valor(puerto, PUERTO_POR_DEFECTO), baseDatos),
                usuario != null ? usuario : valor(System.getenv("MYSQLUSER"), USUARIO_POR_DEFECTO),
                password != null ? password
                        : (System.getenv("MYSQLPASSWORD") != null ? System.getenv("MYSQLPASSWORD") : ""));
    }

    private static String construirUrl(String host, String puerto, String baseDatos) {
        return "jdbc:mysql://" + host + ":" + puerto + "/" + baseDatos + PARAMETROS_JDBC;
    }

    private static String decodificar(String valor) {
        if (valor == null) {
            return null;
        }
        return URLDecoder.decode(valor, StandardCharsets.UTF_8);
    }

    private static String primerNoVacio(String... valores) {
        for (String valor : valores) {
            if (valor != null && !valor.isBlank()) {
                return valor.trim();
            }
        }
        return null;
    }

    private static String valor(String valor, String porDefecto) {
        return valor != null && !valor.isBlank() ? valor.trim() : porDefecto;
    }

    private static Properties cargarConfiguracion() {
        Properties propiedades = new Properties();
        try (InputStream entrada = ConexionBD.class.getClassLoader()
                .getResourceAsStream(ARCHIVO_CONFIG)) {
            if (entrada != null) {
                propiedades.load(entrada);
            }
        } catch (IOException e) {
            throw new ExceptionInInitializerError(
                    "No fue posible cargar " + ARCHIVO_CONFIG + ": " + e.getMessage());
        }
        return propiedades;
    }

    public static Connection getConexion() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    private static final class Credenciales {
        private final String url;
        private final String usuario;
        private final String password;

        private Credenciales(String url, String usuario, String password) {
            this.url = url;
            this.usuario = usuario;
            this.password = password;
        }
    }
}
