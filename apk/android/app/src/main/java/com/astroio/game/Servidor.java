package com.astroio.game;

import android.annotation.SuppressLint;
import android.webkit.CookieManager;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

/**
 * AstroIO — Configuración del servidor compartida por toda la app.
 *
 * Antes las URLs ofuscadas vivían dentro de MainActivity; desde la
 * v2.4.4 también las necesita EstadoService (notificaciones en segundo
 * plano), así que viven aquí y ambas clases las comparten.
 *
 * El dominio NO aparece en texto plano: va en hexadecimal XOR 0x5A,
 * de modo que ni la descompilación de la APK ni las pantallas de error
 * revelan el servidor.
 */
public final class Servidor {

    private static final int XK = 0x5A;

    // Dominio del juego en XOR 0x5A (astroio.duckdns.org)
    private static final String HOST_ENC = "3b292e28353335743e2f39313e34297435283d";
    // v2.4.1: el juego está en la RAÍZ del dominio (antes /AstroIO3.4/).
    private static final String BASE_PATH_ENC = "";

    private Servidor() { } // solo métodos estáticos: no se instancia

    /** Desofusca una cadena hexadecimal XOR 0x5A. */
    public static String deobf(String hex) {
        byte[] raw = new byte[hex.length() / 2];
        for (int i = 0; i < raw.length; i++) {
            raw[i] = (byte) (Integer.parseInt(hex.substring(i * 2, i * 2 + 2), 16) ^ XK);
        }
        return new String(raw, StandardCharsets.UTF_8);
    }

    /** Dominio del servidor, p. ej. "astroio.duckdns.org". */
    public static String host()     { return deobf(HOST_ENC); }

    /** Subcarpeta (vacía: el juego está en la raíz). */
    public static String basePath() { return deobf(BASE_PATH_ENC); }

    /** URL de entrada al juego. */
    public static String juegoUrl() { return "https://" + host() + basePath() + "game.php"; }

    /** URL del archivo de versiones (APK + launchers). */
    public static String versionUrl() { return "https://" + host() + basePath() + "apk/version.json"; }

    /** URL del estado (mensajes sin leer + ataques) para el servicio en segundo plano. */
    public static String estadoUrl() { return "https://" + host() + basePath() + "api_estado.php"; }

    /**
     * Devuelve la cookie de sesión del juego (PHPSESSID) que el WebView
     * ya tiene guardada, para que las peticiones del servicio en segundo
     * plano se autentiquen como el MISMO jugador. Puede devolver null si
     * el jugador todavía no ha iniciado sesión.
     */
    @SuppressLint("NewApi")
    public static String cookieSesion() {
        try {
            return CookieManager.getInstance().getCookie(
                    "https://" + host() + basePath());
        } catch (Exception e) {
            return null;
        }
    }

    /** Timeout de conexión para peticiones cortas (estado/versiones). */
    public static final int CONEX_TIMEOUT = 10000;
    /** Timeout de lectura para peticiones cortas. */
    public static final int LECTURA_TIMEOUT = 15000;

    /**
     * GET sencillo que devuelve el cuerpo como texto (o null si la
     * respuesta no es 200). Se le puede pasar una cookie de sesión.
     * El llamador cierra la conexión; lanza IOException si hay problemas.
     */
    public static String get(String urlStr, String cookie, int timeoutLectura)
            throws IOException {
        HttpURLConnection conn = (HttpURLConnection) new URL(urlStr).openConnection();
        try {
            conn.setConnectTimeout(CONEX_TIMEOUT);
            conn.setReadTimeout(timeoutLectura);
            conn.setInstanceFollowRedirects(true);
            if (cookie != null && !cookie.isEmpty()) {
                conn.setRequestProperty("Cookie", cookie);
            }
            int code = conn.getResponseCode();
            if (code != 200) {
                return null;
            }
            InputStream in = conn.getInputStream();
            java.io.ByteArrayOutputStream out = new java.io.ByteArrayOutputStream();
            byte[] buf = new byte[8192];
            int n;
            while ((n = in.read(buf)) > 0) {
                out.write(buf, 0, n);
            }
            in.close();
            return new String(out.toByteArray(), StandardCharsets.UTF_8);
        } finally {
            conn.disconnect();
        }
    }
}
