package com.astroio.game;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.KeyEvent;
import android.view.View;
import android.webkit.CookieManager;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import org.json.JSONObject;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Locale;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * AstroIO — App móvil (WebView optimizada):
 *  - Sirve las imágenes del juego desde dentro de la APK (assets locales)
 *    para ahorrar datos móviles.
 *  - Al abrirse comprueba la versión con el servidor; si hay una versión
 *    más nueva lo AVISA con dos opciones (Continuar / Actualizar) sin
 *    bloquear la entrada al juego. Si se actualiza, la descarga muestra
 *    porcentaje, velocidad y tiempo restante, y se instala sola.
 *  - v2.4.4: servicio en segundo plano con notificaciones flotantes de
 *    mensaje nuevo y alarma sonora de ataque (EstadoService), icono y
 *    pantalla de carga con el logo oficial del sitio.
 *  - v2.4.5: CONEXIÓN ROBUSTA — la comprobación de versión hace 3
 *    intentos (con espera entre ellos), timeouts más largos, pila IPv4
 *    y una última comprobación del juego antes de marcar "Sin conexión".
 *    Con el servidor ONLINE ya no aparece el error por gusto; y si el
 *    servidor está caído, el error solo ofrece Reintentar (el botón
 *    de continuar queda reservado a cuando hay una versión nueva).
 *  - v2.4.6 AUTO-RECONECTA: esas pantallas de error se reintentan
 *    SOLAS cada 7 s (hasta 12 veces, con el intento N visible) y la
 *    app entra sola en cuanto el servidor contesta. Además el WebView
 *    recarga el juego 2 veces en silencio antes de mostrar error.
 *  - Si falla la conexión muestra un aviso genérico (sin dominios ni datos
 *    técnicos del servidor).
 */
public class MainActivity extends Activity {

    // ════════════════════════════════════════════════════════════════
    //  Configuración del servidor: vive en Servidor.java (v2.4.4) para
    //  compartirla con EstadoService (notificaciones en segundo plano).
    // ════════════════════════════════════════════════════════════════
    private static String serverHost()     { return Servidor.host(); }
    private static String serverBasePath() { return Servidor.basePath(); }
    private static String homeUrl()        { return Servidor.juegoUrl(); }
    private static String versionUrl()     { return Servidor.versionUrl(); }

    private static final int FILE_CHOOSER_REQ = 4242;
    // v2.4.5: la descarga de la APK también conecta con 15 s (antes 10 s
    // se quedaban cortos en redes 4G lentas); la LECTURA de la descarga
    // sigue con su timeout largo propio (60 s).
    private static final int CONNECT_TIMEOUT  = 15000;
    // v2.4.3: la APK es muy grande; 15 s de silencio cortaban la descarga.
    private static final int DL_READ_TIMEOUT  = 60000;

    private WebView webView;
    private LinearLayout statusScreen;
    private TextView statusTitle;
    private TextView statusMsg;
    private ProgressBar statusProgress;
    private Button btnRetry;
    private Button btnContinue;
    private Button btnInstallPerm;

    private final ExecutorService io = Executors.newSingleThreadExecutor();
    private final Handler ui = new Handler(Looper.getMainLooper());

    private boolean gameLoaded = false;
    private boolean waitingInstall = false;
    private ValueCallback<Uri[]> uploadCallback;

    // v2.4.6 — AUTO-RECONECTA: las pantallas de error de conexión se
    // reintentan SOLAS cada 7 s (hasta 12 veces) mostrando el intento
    // N; en cuanto el servidor responde, la app entra sola. Antes había
    // que dar a Reintentar 5-10 veces (en 4G casi nunca entraba).
    // El botón Reintentar sigue para forzar un intento inmediato.
    private static final int MAX_AUTO_INTENTOS = 12;
    private static final long AUTO_REINTENTO_MS = 7000;
    private int autoIntentos = 0;
    private Runnable autoReintentoPendiente;
    // v2.4.6 — reintentos SILENCIOSOS de carga del juego (WebView):
    // antes cualquier error de red al cargar game.php sacaba la
    // pantalla de error al primer golpe; ahora recarga sola 2 veces
    // (esperando 2,5 s) antes de rendirse.
    private int webReintentos = 0;

    // ════════════════════════════════════════════════════════════════
    //  Ciclo de vida
    // ════════════════════════════════════════════════════════════════

    @Override
    @SuppressLint("SetJavaScriptEnabled")
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        bindViews();

        String err = SecurityGuard.performChecks(this);
        if (err != null) {
            showFatal(err);
            return;
        }
        // v2.4.4: permiso de notificaciones (Android 13+) y servicio de
        // estado en segundo plano. Ninguno bloquea la entrada al juego.
        pedirPermisoNotificaciones();
        arrancarServicioEstado();
        runVersionCheck(true);
    }

    @Override
    protected void onResume() {
        super.onResume();
        // Cuando el jugador vuelve (p. ej. tras instalar la actualización o
        // dar el permiso de instalación) se comprueba de nuevo la versión.
        if (waitingInstall && !gameLoaded) {
            waitingInstall = false;
            runVersionCheck(true);
        }
    }

    @Override
    protected void onDestroy() {
        if (webView != null) {
            webView.destroy();
        }
        io.shutdown();
        super.onDestroy();
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK && webView != null
                && webView.getVisibility() == View.VISIBLE && webView.canGoBack()) {
            webView.goBack();
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == FILE_CHOOSER_REQ && uploadCallback != null) {
            Uri[] result = null;
            if (data != null && data.getData() != null) {
                result = new Uri[] { data.getData() };
            }
            uploadCallback.onReceiveValue(result);
            uploadCallback = null;
            return;
        }
        super.onActivityResult(requestCode, resultCode, data);
    }

    // ════════════════════════════════════════════════════════════════
    //  Verificación de versión / actualización automática
    // ════════════════════════════════════════════════════════════════

    /**
     * Comprueba la versión con el servidor (3 intentos + prueba del
     * juego, v2.4.5). v2.4.6: manual=true la llama el jugador (botón
     * Reintentar o arranque) y REINICIA el contador del auto-reintento;
     * manual=false la llama el propio auto-reintento (7 s) sin tocar
     * el contador. Tras cada pantalla de error de conexión se
     * reprograma sola (AUTO-RECONECTA).
     */
    private void runVersionCheck(boolean manual) {
        cancelarAutoReintento();
        if (manual) {
            autoIntentos = 0;
        }
        if (!isOnline()) {
            // v2.4.5: sin Internet real solo Reintentar — el botón
            // "Entrar de todas formas" queda reservado a cuando HAY
            // una versión nueva pendiente de decidir (igual que el
            // launcher de PC).
            showStatus(getString(R.string.s_no_net), null, false, 0, true, false, false);
            programarAutoReintento(); // v2.4.6: reintenta sola (p. ej. al volver la señal)
            return;
        }
        showStatus(getString(R.string.s_checking),
                autoIntentos > 0
                        ? getString(R.string.s_auto, autoIntentos, MAX_AUTO_INTENTOS)
                        : null,
                false, 0, false, false, false);
        io.execute(new Runnable() {
            @Override public void run() {
                // v2.4.5 — CONEXIÓN ROBUSTA: 3 intentos de version.json
                // (esperando 1,5 s y 3 s entre intentos) en vez de UNO.
                // Antes bastaba un mal intento aislado (DNS lento, TLS
                // lento en 4G, el servidor ocupado un instante) para
                // sacar la pantalla de error y obligar a dar Reintentar
                // 5-10 veces hasta entrar.
                String body = null;
                Exception fallo = null;
                for (int intento = 1; intento <= 3; intento++) {
                    try {
                        body = Servidor.get(versionUrl(), null, Servidor.LECTURA_TIMEOUT);
                        fallo = null;
                        break;
                    } catch (Exception e) {
                        fallo = e;
                        if (intento < 3) {
                            try { Thread.sleep(1500L * intento); }
                            catch (InterruptedException ie) { }
                        }
                    }
                }

                if (fallo == null && body != null && !body.trim().isEmpty()) {
                    try {
                        JSONObject json = new JSONObject(body);
                        // IMPORTANTE: se compara SOLO el versionCode de la APK.
                        // El bloque "launcher" del JSON es para los launchers de
                        // PC: las versiones de la APK y de los launchers son
                        // INDEPENDIENTES, así que una versión nueva del launcher
                        // de Windows NO hace que la app diga "hay actualización".
                        int serverCode = json.optInt("versionCode", 0);
                        String serverName = json.optString("versionName", "");
                        String apkUrl  = json.optString("url", "");
                        String sha256  = json.optString("sha256", "");

                        if (serverCode > BuildConfig.VERSION_CODE && !apkUrl.isEmpty()) {
                            // v2.4.4: ACTUALIZACIÓN NO BLOQUEANTE. Antes se
                            // descargaba a la fuerza y no dejaba entrar al juego;
                            // ahora el jugador decide qué hacer.
                            final String nombre = serverName;
                            ui.post(new Runnable() { @Override public void run() {
                                preguntarActualizar(nombre, apkUrl, sha256);
                            }});
                            return;
                        }
                        // Al día: entrar al juego normal.
                        ui.post(new Runnable() { @Override public void run() { loadGame(); } });
                        return;
                    } catch (Exception je) {
                        // El JSON llegó ilegible PERO el servidor respondió:
                        // entrar igual. No se marca "Sin conexión" por gusto.
                        ui.post(new Runnable() { @Override public void run() { loadGame(); } });
                        return;
                    }
                }

                // version.json no respondió en 3 intentos (o llegó vacío).
                // ÚLTIMA COMPROBACIÓN: si el JUEGO en sí responde, el
                // servidor está ONLINE y se entra igual — solo se pierde
                // el aviso de actualización de esta sesión, nunca el
                // acceso. Si tampoco responde el juego, es un apagón real:
                // pantalla de error SOLO con Reintentar (entrar a un
                // servidor caído no lleva a ningún sitio).
                if (Servidor.juegoResponde()) {
                    ui.post(new Runnable() { @Override public void run() { loadGame(); } });
                    return;
                }
                ui.post(new Runnable() { @Override public void run() {
                    showStatus(getString(R.string.s_check_err), null, false, 0, true, false, false);
                    programarAutoReintento(); // v2.4.6: AUTO-RECONECTA
                }});
            }
        });
    }

    /**
     * v2.4.4 — Aviso de actualización con DOS OPCIONES:
     *   · Continuar  → entra al juego normal, sin actualizar.
     *   · Actualizar → descarga la versión nueva con barra de progreso
     *                  (% , velocidad y tiempo restante) e instala sola.
     */
    private void preguntarActualizar(String nombreNuevo, final String apkUrl, final String sha256) {
        gameLoaded = false;
        webView.setVisibility(View.GONE);
        statusScreen.setVisibility(View.GONE); // fondo limpio detrás del diálogo
        AlertDialog dlg = new AlertDialog.Builder(this)
                .setTitle(getString(R.string.s_update_title))
                .setMessage(getString(R.string.s_update_msg, nombreNuevo))
                .setPositiveButton(R.string.btn_download, new DialogInterface.OnClickListener() {
                    @Override public void onClick(DialogInterface d, int which) {
                        downloadUpdate(apkUrl, sha256);
                    }
                })
                .setNegativeButton(R.string.btn_cont, new DialogInterface.OnClickListener() {
                    @Override public void onClick(DialogInterface d, int which) {
                        loadGame(); // continúa normal, sin actualizar
                    }
                })
                .setCancelable(false)
                .show();
        // Colores del tema (cian = actualizar, verde = continuar).
        dlg.getButton(AlertDialog.BUTTON_POSITIVE).setTextColor(0xFF00E0FF);
        dlg.getButton(AlertDialog.BUTTON_NEGATIVE).setTextColor(0xFF10B981);
    }

    private void downloadUpdate(final String apkUrl, final String sha256) {
        showStatus(getString(R.string.s_downloading, 0), null, true, 0, false, false, false);
        io.execute(new Runnable() {
            @Override public void run() {
                File dst  = new File(getFilesDir(), UpdateFileProvider.APK_FILE_NAME);
                File part = new File(getFilesDir(), UpdateFileProvider.APK_FILE_NAME + ".part");
                try {
                    // v2.4.3: descarga con reanudación (Range). Antes, cualquier
                    // corte de la conexión obligaba a empezar de cero y la app
                    // quedaba bloqueada en "No se pudo comprobar…".
                    long offset = part.exists() ? part.length() : 0L;
                    HttpURLConnection conn = (HttpURLConnection) new URL(apkUrl).openConnection();
                    conn.setConnectTimeout(CONNECT_TIMEOUT);
                    conn.setReadTimeout(DL_READ_TIMEOUT);
                    conn.setInstanceFollowRedirects(true);
                    if (offset > 0) {
                        conn.setRequestProperty("Range", "bytes=" + offset + "-");
                    }
                    int code = conn.getResponseCode();
                    if (code == 416 && offset > 0) {
                        // El .part ya está completo: pasar directo a verificar.
                        conn.disconnect();
                        finishDownload(part, dst, sha256);
                        return;
                    }
                    if (code != 200 && code != 206) {
                        conn.disconnect();
                        throw new IOException("HTTP " + code);
                    }
                    boolean resume = (code == 206 && offset > 0);
                    long total = resume ? offset + conn.getContentLength() : conn.getContentLength();
                    InputStream in = conn.getInputStream();
                    FileOutputStream out = new FileOutputStream(part, resume);
                    // v2.4.4: la barra muestra PORCENTAJE, MB descargados,
                    // VELOCIDAD por momento (media exponencial suavizada) y
                    // TIEMPO RESTANTE estimado con esa velocidad.
                    byte[] buf = new byte[16384];
                    long read = offset;
                    int n;
                    int lastPct = -1;
                    long tMuestra    = System.currentTimeMillis(); // último tramo medido
                    long readMuestra = offset;                     // bytes al medirlo
                    double velocidad = 0;                          // bytes/s suavizados
                    long ultimaUi    = 0;                          // último refresco de pantalla
                    while ((n = in.read(buf)) > 0) {
                        out.write(buf, 0, n);
                        read += n;
                        if (total > 0) {
                            final int pct = (int) (read * 100 / total);
                            long ahora = System.currentTimeMillis();
                            // Velocidad instantánea del tramo + suavizado
                            // (evita que la cifra "baile" de MB/s en MB/s).
                            double dt = (ahora - tMuestra) / 1000.0;
                            if (dt >= 0.3) {
                                double vInst = (read - readMuestra) / dt;
                                velocidad = (velocidad <= 0)
                                        ? vInst : 0.4 * vInst + 0.6 * velocidad;
                                tMuestra    = ahora;
                                readMuestra = read;
                            }
                            // Refresco de pantalla: al cambiar el % o cada segundo.
                            if (pct != lastPct || ahora - ultimaUi >= 1000) {
                                lastPct = pct;
                                ultimaUi = ahora;
                                final long doneMB = read / 1048576;
                                final long totMB  = total / 1048576;
                                final String fVel = (velocidad > 0)
                                        ? String.format(Locale.US, "%.1f MB/s", velocidad / 1048576.0)
                                        : "…";
                                final String fEta = (velocidad > 0)
                                        ? etaTexto(Math.round((total - read) / velocidad))
                                        : "…";
                                ui.post(new Runnable() { @Override public void run() {
                                    showStatus(getString(R.string.s_dl_info,
                                            pct, doneMB, totMB, fVel, fEta),
                                            null, true, pct, false, false, false);
                                }});
                            }
                        }
                    }
                    out.flush();
                    out.close();
                    in.close();
                    conn.disconnect();
                    finishDownload(part, dst, sha256);
                } catch (final Exception e) {
                    // El .part se conserva: al reintentar, la descarga se
                    // reanuda donde se cortó (solo se borra si el SHA falla).
                    ui.post(new Runnable() { @Override public void run() {
                        showStatus(getString(R.string.s_dl_err), null, false, 0, true, false, true);
                    }});
                }
            }
        });
    }

    /** Verificación SHA-256 y paso a instalación (hilo de trabajo). */
    private void finishDownload(File part, File dst, String sha256) throws Exception {
        if (sha256 != null && sha256.length() == 64) {
            ui.post(new Runnable() { @Override public void run() {
                showStatus(getString(R.string.s_verifying), null, true, 100, false, false, false);
            }});
            String real = sha256OfFile(part);
            if (!real.equalsIgnoreCase(sha256)) {
                part.delete(); // corrupto: el próximo reintento empieza de cero
                ui.post(new Runnable() { @Override public void run() {
                    showStatus(getString(R.string.s_bad_pkg), null, false, 0, true, false, true);
                }});
                return;
            }
        }
        if (dst.exists()) {
            dst.delete();
        }
        if (!part.renameTo(dst)) {
            throw new IOException("No se pudo finalizar el archivo descargado");
        }
        ui.post(new Runnable() { @Override public void run() { promptInstall(); } });
    }

    private void promptInstall() {
        showStatus(getString(R.string.s_installing), null, false, 0, false, false, false);
        if (Build.VERSION.SDK_INT >= 26) {
            boolean canInstall = getPackageManager().canRequestPackageInstalls();
            if (!canInstall) {
                showStatus(getString(R.string.s_install_perm), null, false, 0, true, true, false);
                return;
            }
        }
        doInstall();
    }

    private void doInstall() {
        try {
            Uri apkUri = Uri.parse("content://" + UpdateFileProvider.AUTHORITY + "/" + UpdateFileProvider.APK_FILE_NAME);
            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.setDataAndType(apkUri, "application/vnd.android.package-archive");
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
            waitingInstall = true;
        } catch (Exception e) {
            showStatus(getString(R.string.s_check_err), null, false, 0, true, false, true);
        }
    }

    // ════════════════════════════════════════════════════════════════
    //  Juego (WebView)
    // ════════════════════════════════════════════════════════════════

    @SuppressLint("SetJavaScriptEnabled")
    private void loadGame() {
        cancelarAutoReintento(); // v2.4.6: se entra, ya no hay que reintentar
        webReintentos = 0;
        if (!isOnline()) {
            // v2.4.5: solo Reintentar (igual que el launcher de PC).
            showStatus(getString(R.string.s_no_net), null, false, 0, true, false, false);
            programarAutoReintento(); // v2.4.6: AUTO-RECONECTA
            return;
        }
        gameLoaded = true;
        statusScreen.setVisibility(View.GONE);

        WebSettings st = webView.getSettings();
        st.setJavaScriptEnabled(true);
        st.setDomStorageEnabled(true);
        st.setDatabaseEnabled(true);
        st.setLoadWithOverviewMode(true);
        st.setUseWideViewPort(true);
        st.setSupportZoom(false);
        st.setBuiltInZoomControls(false);
        st.setCacheMode(WebSettings.LOAD_DEFAULT);
        st.setAllowFileAccess(false);
        st.setAllowContentAccess(false);
        st.setMediaPlaybackRequiresUserGesture(false);
        if (Build.VERSION.SDK_INT >= 21) {
            st.setMixedContentMode(WebSettings.MIXED_CONTENT_NEVER_ALLOW);
        }
        try {
            // Marca la app en el User-Agent (el servidor puede detectarla si lo necesita)
            st.setUserAgentString(st.getUserAgentString() + " AstroIOMobile/" + BuildConfig.VERSION_NAME);
        } catch (Exception ignored) { }
        CookieManager.getInstance().setAcceptCookie(true);

        webView.setWebViewClient(new WebViewClient() {
            @Override
            public WebResourceResponse shouldInterceptRequest(WebView view, WebResourceRequest request) {
                return MainActivity.this.interceptAsset(request.getUrl().toString());
            }

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                Uri u = request.getUrl();
                String h = serverHost();
                if (u.getHost() != null && u.getHost().toLowerCase(Locale.US).endsWith(h)) {
                    return false; // dominio del juego: se abre dentro
                }
                try {
                    startActivity(new Intent(Intent.ACTION_VIEW, u));
                } catch (Exception ignored) { }
                return true;
            }

            @Override
            public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
                if (request.isForMainFrame()) {
                    gameLoaded = false;
                    // v2.4.6: reintentos SILENCIOSOS — antes el primer
                    // error de red al cargar el juego sacaba la pantalla
                    // de error al primer golpe; ahora recarga sola 2
                    // veces (esperando 2,5 s) por si fue un mal intento
                    // puntual de la red (muy común en 4G).
                    if (webReintentos < 2 && isOnline()) {
                        webReintentos++;
                        webView.postDelayed(new Runnable() {
                            @Override public void run() {
                                if (!gameLoaded) {
                                    webView.reload();
                                }
                            }
                        }, 2500);
                        return;
                    }
                    webReintentos = 0;
                    // v2.4.5: el juego no cargó → solo Reintentar (dar a
                    // "Entrar de todas formas" a un juego que no carga no
                    // lleva a ningún sitio).
                    showStatus(getString(R.string.s_game_err), null, false, 0, true, false, false);
                    programarAutoReintento(); // v2.4.6: AUTO-RECONECTA
                }
            }
        });

        webView.setWebChromeClient(new WebChromeClient() {
            @Override
            public boolean onShowFileChooser(WebView wv, ValueCallback<Uri[]> callback,
                                             FileChooserParams params) {
                uploadCallback = callback;
                try {
                    startActivityForResult(params.createIntent(), FILE_CHOOSER_REQ);
                } catch (Exception e) {
                    uploadCallback = null;
                    return false;
                }
                return true;
            }
        });

        webView.setVisibility(View.VISIBLE);
        webView.loadUrl(homeUrl());
    }

    /**
     * Sirve las imágenes guardadas dentro de la APK (assets/game/…)
     * en lugar de descargarlas de Internet → ahorro de datos.
     */
    private WebResourceResponse interceptAsset(String urlStr) {
        try {
            if (urlStr == null || !urlStr.startsWith("https://")) {
                return null;
            }
            Uri uri = Uri.parse(urlStr);
            String host = uri.getHost();
            if (host == null || !host.toLowerCase(Locale.US).endsWith(serverHost())) {
                return null;
            }
            String path = uri.getPath();
            if (path == null) {
                return null;
            }
            String candidate = null;
            int idx = path.indexOf("/styles/");
            if (idx >= 0) {
                candidate = "game/" + path.substring(idx + 1);
            }
            if (candidate == null) {
                candidate = "game" + path;
            }
            InputStream in = null;
            try {
                in = getAssets().open(candidate);
            } catch (IOException ignored) {
                return null; // sin copia local: se descarga de Internet
            }
            String ext = MimeTypeExt(candidate);
            String mime = android.webkit.MimeTypeMap.getSingleton()
                    .getMimeTypeFromExtension(ext);
            if (mime == null) {
                mime = "application/octet-stream";
            }
            String encoding = (mime.startsWith("text/") || mime.contains("javascript")
                    || mime.contains("json")) ? "utf-8" : null;
            return new WebResourceResponse(mime, encoding, in);
        } catch (Throwable t) {
            return null;
        }
    }

    private static String MimeTypeExt(String path) {
        int slash = path.lastIndexOf('/');
        int dot = path.lastIndexOf('.');
        if (dot > slash && dot < path.length() - 1) {
            return path.substring(dot + 1).toLowerCase(Locale.US);
        }
        return "";
    }

    // ════════════════════════════════════════════════════════════════
    //  Utilidades
    // ════════════════════════════════════════════════════════════════

    /** Convierte segundos a texto corto ("45s", "2m 05s", "1h 12m"). */
    private static String etaTexto(long segundos) {
        if (segundos < 0) segundos = 0;
        if (segundos < 60) return segundos + "s";
        long m = segundos / 60;
        long s = segundos % 60;
        if (m < 60) return m + "m " + (s < 10 ? "0" : "") + s + "s";
        long h = m / 60;
        m = m % 60;
        return h + "h " + (m < 10 ? "0" : "") + m + "m";
    }

    /**
     * v2.4.4 — Pide el permiso de notificaciones (Android 13+), necesario
     * para que el servicio en segundo plano pueda avisar de mensajes y
     * ataques. No bloquea nada: si se deniega, el juego funciona igual,
     * solo que sin avisos.
     */
    private void pedirPermisoNotificaciones() {
        if (Build.VERSION.SDK_INT >= 33
                && checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS)
                        != android.content.pm.PackageManager.PERMISSION_GRANTED) {
            try {
                requestPermissions(
                        new String[]{android.Manifest.permission.POST_NOTIFICATIONS}, 777);
            } catch (Exception ignored) { }
        }
    }

    /**
     * v2.4.4 — Arranca el servicio de estado (notificaciones flotantes +
     * sirena de ataque) que sigue trabajando con la APK minimizada o cerrada.
     */
    private void arrancarServicioEstado() {
        try {
            Intent s = new Intent(this, EstadoService.class);
            if (Build.VERSION.SDK_INT >= 26) {
                startForegroundService(s);
            } else {
                startService(s);
            }
        } catch (Exception ignored) { }
    }

    private boolean isOnline() {
        try {
            ConnectivityManager cm = (ConnectivityManager) getSystemService(CONNECTIVITY_SERVICE);
            if (cm == null) {
                return false;
            }
            NetworkInfo ni = cm.getActiveNetworkInfo();
            return ni != null && ni.isConnected();
        } catch (Exception e) {
            return false;
        }
    }

    // ══════════════════════════════════════════════════════════
    //  v2.4.6 — AUTO-RECONECTA
    // ══════════════════════════════════════════════════════════

    /** Quita el auto-reintento programado (si lo hay). */
    private void cancelarAutoReintento() {
        if (autoReintentoPendiente != null) {
            ui.removeCallbacks(autoReintentoPendiente);
            autoReintentoPendiente = null;
        }
    }

    /**
     * Programa el siguiente intento de conexión (7 s) mientras la
     * pantalla de error esté visible. Muestra el "intento N de 12" en
     * pantalla y, en cuanto el servidor contesta, runVersionCheck
     * acaba en loadGame() y la app ENTRA SOLA — sin que el jugador
     * tenga que dar a Reintentar una y otra vez. Tras 12 intentos se
     * queda en Reintentar manual para no gastar batería toda la noche.
     */
    private void programarAutoReintento() {
        cancelarAutoReintento();
        if (gameLoaded) {
            return;
        }
        if (autoIntentos >= MAX_AUTO_INTENTOS) {
            return; // se queda en Reintentar manual
        }
        autoReintentoPendiente = new Runnable() {
            @Override public void run() {
                autoReintentoPendiente = null;
                if (gameLoaded) {
                    return;
                }
                autoIntentos++;
                runVersionCheck(false);
            }
        };
        ui.postDelayed(autoReintentoPendiente, AUTO_REINTENTO_MS);
    }

    private static String readAll(InputStream in) throws IOException {
        if (in == null) {
            return null;
        }
        ByteArrayOutputStreamWrapper out = new ByteArrayOutputStreamWrapper();
        byte[] buf = new byte[8192];
        int n;
        while ((n = in.read(buf)) > 0) {
            out.write(buf, 0, n);
        }
        in.close();
        return new String(out.toByteArray(), StandardCharsets.UTF_8);
    }

    /** Envoltorio simple para evitar importar ByteArrayOutputStream dos veces. */
    private static final class ByteArrayOutputStreamWrapper {
        private final java.io.ByteArrayOutputStream bos = new java.io.ByteArrayOutputStream();
        void write(byte[] b, int off, int len) { bos.write(b, off, len); }
        byte[] toByteArray() { return bos.toByteArray(); }
    }

    private static String sha256OfFile(File f) throws Exception {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        FileInputStream fis = new FileInputStream(f);
        byte[] buf = new byte[16384];
        int n;
        while ((n = fis.read(buf)) > 0) {
            md.update(buf, 0, n);
        }
        fis.close();
        StringBuilder sb = new StringBuilder();
        for (byte b : md.digest()) {
            sb.append(String.format(Locale.US, "%02x", b));
        }
        return sb.toString();
    }

    // ════════════════════════════════════════════════════════════════
    //  Pantalla de estado
    // ════════════════════════════════════════════════════════════════

    private void bindViews() {
        webView = (WebView) findViewById(R.id.web_view);
        statusScreen = (LinearLayout) findViewById(R.id.status_screen);
        statusTitle = (TextView) findViewById(R.id.status_title);
        statusMsg = (TextView) findViewById(R.id.status_msg);
        statusProgress = (ProgressBar) findViewById(R.id.status_progress);
        btnRetry = (Button) findViewById(R.id.btn_retry);
        btnInstallPerm = (Button) findViewById(R.id.btn_install_perm);

        btnContinue = (Button) findViewById(R.id.btn_continue);
        btnContinue.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) {
                loadGame();
            }
        });
        btnRetry.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) {
                if (!gameLoaded) {
                    runVersionCheck(true); // v2.4.6: manual reinicia el contador
                }
            }
        });
        btnInstallPerm.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) {
                if (Build.VERSION.SDK_INT >= 26) {
                    try {
                        Intent intent = new Intent(android.provider.Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                                Uri.parse("package:" + getPackageName()));
                        startActivity(intent);
                        waitingInstall = true;
                    } catch (Exception e) {
                        doInstall();
                    }
                } else {
                    doInstall();
                }
            }
        });
    }

    private void showStatus(String title, String msg, boolean showProgress, int percent,
                            boolean showRetry, boolean showInstallPerm, boolean showContinue) {
        gameLoaded = false;
        webView.setVisibility(View.GONE);
        statusScreen.setVisibility(View.VISIBLE);
        statusTitle.setTextColor(getResources().getColor(R.color.astro_title));
        statusTitle.setText(title);
        if (msg != null && !msg.isEmpty()) {
            statusMsg.setVisibility(View.VISIBLE);
            statusMsg.setText(msg);
        } else {
            statusMsg.setVisibility(View.GONE);
        }
        statusProgress.setVisibility(showProgress ? View.VISIBLE : View.GONE);
        statusProgress.setProgress(percent);
        btnRetry.setVisibility(showRetry ? View.VISIBLE : View.GONE);
        btnRetry.setText(R.string.btn_retry);
        btnContinue.setVisibility(showContinue ? View.VISIBLE : View.GONE);
        btnInstallPerm.setVisibility(showInstallPerm ? View.VISIBLE : View.GONE);
    }

    private void showFatal(String message) {
        gameLoaded = false;
        webView.setVisibility(View.GONE);
        statusScreen.setVisibility(View.VISIBLE);
        statusTitle.setTextColor(getResources().getColor(R.color.astro_bad));
        statusTitle.setText(message);
        statusMsg.setVisibility(View.GONE);
        statusProgress.setVisibility(View.GONE);
        btnInstallPerm.setVisibility(View.GONE);
        btnRetry.setVisibility(View.VISIBLE);
        btnRetry.setText(R.string.btn_close);
        btnRetry.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) {
                finishAffinity();
            }
        });
    }
}
