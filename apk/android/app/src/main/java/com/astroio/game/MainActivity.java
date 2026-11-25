package com.astroio.game;

import android.annotation.SuppressLint;
import android.app.Activity;
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
 *    más nueva, descarga e instala la actualización y NO deja entrar al
 *    juego hasta que la app esté actualizada.
 *  - Si falla la conexión muestra un aviso genérico (sin dominios ni datos
 *    técnicos del servidor).
 */
public class MainActivity extends Activity {

    // ════════════════════════════════════════════════════════════════
    //  Configuración del servidor (XOR 0x5A: el dominio no aparece
    //  en texto plano dentro del APK ni en pantallas de error).
    // ════════════════════════════════════════════════════════════════
    private static final int XK = 0x5A;
    private static final String HOST_ENC = "3b292e28353335743e2f39313e34297435283d";
    // ASTROIO v2.4.1: el juego está en la RAÍZ del dominio (antes /AstroIO3.4/).
    // Cadena vacía => sin subcarpeta (https://astroio.duckdns.org/...).
    private static final String BASE_PATH_ENC = "";

    private static String deobf(String hex) {
        byte[] raw = new byte[hex.length() / 2];
        for (int i = 0; i < raw.length; i++) {
            raw[i] = (byte) (Integer.parseInt(hex.substring(i * 2, i * 2 + 2), 16) ^ XK);
        }
        return new String(raw, StandardCharsets.UTF_8);
    }

    private static String serverHost()     { return deobf(HOST_ENC); }
    private static String serverBasePath() { return deobf(BASE_PATH_ENC); }
    private static String homeUrl()        { return "https://" + serverHost() + serverBasePath() + "game.php"; }
    private static String versionUrl()     { return "https://" + serverHost() + serverBasePath() + "apk/version.json"; }

    private static final int FILE_CHOOSER_REQ = 4242;
    private static final int CONNECT_TIMEOUT  = 10000;
    private static final int READ_TIMEOUT     = 15000;
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
        runVersionCheck();
    }

    @Override
    protected void onResume() {
        super.onResume();
        // Cuando el jugador vuelve (p. ej. tras instalar la actualización o
        // dar el permiso de instalación) se comprueba de nuevo la versión.
        if (waitingInstall && !gameLoaded) {
            waitingInstall = false;
            runVersionCheck();
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

    private void runVersionCheck() {
        if (!isOnline()) {
            showStatus(getString(R.string.s_no_net), null, false, 0, true, false, true);
            return;
        }
        showStatus(getString(R.string.s_checking), null, false, 0, false, false, false);
        io.execute(new Runnable() {
            @Override public void run() {
                try {
                    HttpURLConnection conn = (HttpURLConnection) new URL(versionUrl()).openConnection();
                    conn.setConnectTimeout(CONNECT_TIMEOUT);
                    conn.setReadTimeout(READ_TIMEOUT);
                    conn.setInstanceFollowRedirects(true);
                    int code = conn.getResponseCode();
                    String body = readAll(code == 200 ? conn.getInputStream() : conn.getErrorStream());
                    conn.disconnect();

                    if (code != 200 || body == null || body.trim().isEmpty()) {
                        // Sin archivo de versiones configurado: no hay nada que
                        // comparar aún (primera puesta en marcha) → entrar al juego.
                        ui.post(new Runnable() { @Override public void run() { loadGame(); } });
                        return;
                    }

                    JSONObject json = new JSONObject(body);
                    int serverCode = json.optInt("versionCode", 0);
                    String apkUrl  = json.optString("url", "");
                    String sha256  = json.optString("sha256", "");

                    if (serverCode > BuildConfig.VERSION_CODE && !apkUrl.isEmpty()) {
                        // Todo lo que toca la UI va por ui.post (hilo principal)
                        ui.post(new Runnable() { @Override public void run() {
                            showStatus(getString(R.string.s_update_available), null, false, 0, false, false, false);
                            downloadUpdate(apkUrl, sha256);
                        }});
                    } else {
                        ui.post(new Runnable() { @Override public void run() { loadGame(); } });
                    }
                } catch (final Exception e) {
                    ui.post(new Runnable() { @Override public void run() {
                        showStatus(getString(R.string.s_check_err), null, false, 0, true, false, true);
                    }});
                }
            }
        });
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
                    byte[] buf = new byte[16384];
                    long read = offset;
                    int n;
                    int lastPct = -1;
                    while ((n = in.read(buf)) > 0) {
                        out.write(buf, 0, n);
                        read += n;
                        if (total > 0) {
                            final int pct = (int) (read * 100 / total);
                            if (pct != lastPct) {
                                lastPct = pct;
                                ui.post(new Runnable() { @Override public void run() {
                                    showStatus(getString(R.string.s_downloading, pct), null, true, pct, false, false, false);
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
        if (!isOnline()) {
            showStatus(getString(R.string.s_no_net), null, false, 0, true, false, true);
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
                    showStatus(getString(R.string.s_game_err), null, false, 0, true, false, true);
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
                    runVersionCheck();
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
