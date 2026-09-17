package util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

public class PasswordUtil {

    private static final String PREFIJO_PBKDF2 = "PBKDF2";
    private static final String ALGORITMO_PBKDF2 = "PBKDF2WithHmacSHA256";
    private static final int ITERACIONES = 100000;
    private static final int LONGITUD_SAL = 16;
    private static final int LONGITUD_CLAVE_BITS = 256;
    private static final char SEPARADOR = '$';

    private PasswordUtil() {
    }

    public static String hashPassword(String password) {
        if (password == null || password.isBlank()) {
            throw new IllegalArgumentException("La contraseña no puede estar vacía.");
        }

        byte[] sal = new byte[LONGITUD_SAL];
        new SecureRandom().nextBytes(sal);
        byte[] derivada = derivarPBKDF2(password, sal, ITERACIONES);

        StringBuilder resultado = new StringBuilder();
        resultado.append(PREFIJO_PBKDF2).append(SEPARADOR)
                .append(ITERACIONES).append(SEPARADOR)
                .append(Base64.getEncoder().encodeToString(sal)).append(SEPARADOR)
                .append(Base64.getEncoder().encodeToString(derivada));
        return resultado.toString();
    }

    public static boolean verificarContrasena(String password, String almacenado) {
        if (password == null || almacenado == null || almacenado.isBlank()) {
            return false;
        }

        String[] partes = almacenado.split("\\" + SEPARADOR);
        if (partes.length == 4 && PREFIJO_PBKDF2.equalsIgnoreCase(partes[0])) {
            try {
                int iteraciones = Integer.parseInt(partes[1]);
                byte[] sal = Base64.getDecoder().decode(partes[2]);
                byte[] esperado = Base64.getDecoder().decode(partes[3]);
                byte[] calculado = derivarPBKDF2(password, sal, iteraciones);
                return MessageDigest.isEqual(esperado, calculado);
            } catch (IllegalArgumentException e) {
                return false;
            }
        }

        return sha256Hex(password).equalsIgnoreCase(almacenado.trim());
    }

    public static String sha256Hex(String texto) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] bytes = digest.digest(texto.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexadecimal = new StringBuilder(bytes.length * 2);
            for (byte b : bytes) {
                String h = Integer.toHexString(0xff & b);
                if (h.length() == 1) {
                    hexadecimal.append('0');
                }
                hexadecimal.append(h);
            }
            return hexadecimal.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("No fue posible procesar la contraseña.", e);
        }
    }

    private static byte[] derivarPBKDF2(String password, byte[] sal, int iteraciones) {
        PBEKeySpec especificacion = new PBEKeySpec(password.toCharArray(), sal,
                iteraciones, LONGITUD_CLAVE_BITS);
        try {
            SecretKeyFactory fabrica = SecretKeyFactory.getInstance(ALGORITMO_PBKDF2);
            return fabrica.generateSecret(especificacion).getEncoded();
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            throw new RuntimeException("No fue posible derivar la clave PBKDF2.", e);
        } finally {
            especificacion.clearPassword();
        }
    }
}