package com.astroio.game;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.Signature;
import android.os.Build;
import android.os.Debug;

import java.security.MessageDigest;
import java.util.Locale;

/**
 * AstroIO — Protección anti manipulación (v1.0):
 *  - Comprueba que la APK esté firmada con el certificado oficial
 *    (si alguien la edita con APK Editor tendrá que re-firmarla y el
 *    hash del certificado cambiará → la app se bloquea).
 *  - Bloquea la versión de depuración y el uso de debugger.
 *  - Detecta apps conocidas de edición/patching de APK si están instaladas.
 */
public final class SecurityGuard {

    /** SHA-256 del certificado de firma oficial de AstroIO (keystore/astroio-release.p12). */
    private static final String EXPECTED_CERT_SHA256 =
            "5B0D52A32A09176049A9C1BFCE3B44A1DD5E207CA613C607F2AB1882C95D1E03";

    /** Paquetes conocidos de editores de APK / parcheo. */
    private static final String[] FORBIDDEN_PACKAGES = {
            "com.gmail.hejosadac.apkeditor",
            "com.apk.editor",
            "apk.editor",
            "com.pyrosa.apkeditor",
            "com.crazy.apkeditor",
            "com.hebosoft.apkmeter",
            "com.android.vending.bonus",
            "com.chelpus.lackypatch",
            "com.dimonvideo.luckypatcher"
    };

    private SecurityGuard() { }

    /**
     * @return null si todo está correcto; en caso contrario el mensaje
     *         (del archivo strings.xml) que se muestra al jugador.
     */
    public static String performChecks(Context ctx) {
        try {
            if ((ctx.getApplicationInfo().flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0) {
                return ctx.getString(R.string.s_debug);
            }
            if (Debug.isDebuggerConnected() || Debug.waitingForDebugger()) {
                return ctx.getString(R.string.s_debug);
            }
            if (!certificateOk(ctx)) {
                return ctx.getString(R.string.s_tampered);
            }
            if (editorInstalled(ctx)) {
                return ctx.getString(R.string.s_editor);
            }
        } catch (Throwable t) {
            return ctx.getString(R.string.s_tampered);
        }
        return null;
    }

    private static boolean certificateOk(Context ctx) {
        byte[] cert = null;
        PackageManager pm = ctx.getPackageManager();
        String pkg = ctx.getPackageName();
        try {
            if (Build.VERSION.SDK_INT >= 28) {
                PackageInfo pi = pm.getPackageInfo(pkg, PackageManager.GET_SIGNING_CERTIFICATES);
                if (pi.signingInfo != null) {
                    Signature[] sigs = pi.signingInfo.getApkContentsSigners();
                    if (sigs != null && sigs.length > 0) {
                        cert = sigs[0].toByteArray();
                    }
                }
            } else {
                @SuppressWarnings("deprecation")
                PackageInfo pi = pm.getPackageInfo(pkg, PackageManager.GET_SIGNATURES);
                if (pi.signatures != null && pi.signatures.length > 0) {
                    cert = pi.signatures[0].toByteArray();
                }
            }
        } catch (Exception e) {
            return false;
        }
        if (cert == null) {
            return false;
        }
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] digest = md.digest(cert);
            StringBuilder sb = new StringBuilder(digest.length * 2);
            for (byte b : digest) {
                sb.append(String.format(Locale.US, "%02X", b));
            }
            return EXPECTED_CERT_SHA256.equals(sb.toString());
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean editorInstalled(Context ctx) {
        PackageManager pm = ctx.getPackageManager();
        for (String pkg : FORBIDDEN_PACKAGES) {
            try {
                pm.getPackageInfo(pkg, 0);
                return true;
            } catch (PackageManager.NameNotFoundException ignored) {
                // no instalado: continuar
            } catch (RuntimeException ignored) {
                // el sistema puede denegar la consulta: continuar
            }
        }
        return false;
    }
}
