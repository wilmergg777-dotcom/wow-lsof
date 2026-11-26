package com.astroio.game;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.media.AudioAttributes;
import android.media.MediaPlayer;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;

import org.json.JSONObject;

/**
 * AstroIO — Servicio de ESTADO en segundo plano (v2.4.4).
 *
 * Qué hace:
 *  - Se queda vivo (servicio en primer plano, notificación fija
 *    "AstroIO activo") aunque la APK esté minimizada o cerrada.
 *  - Cada 60 segundos pregunta al servidor (api_estado.php) con la MISMA
 *    sesión del juego cuántos mensajes sin leer tiene el jugador y si hay
 *    un ataque real en curso.
 *  - Mensaje nuevo  → notificación flotante (heads-up) "💬 Mensaje nuevo".
 *  - Ataque         → notificación de emergencia + SIRENA de la alarma
 *                     (res/raw/alarma_ataque.wav, a volumen de ALARMA,
 *                     en bucle mientras el ataque siga en vuelo; se para
 *                     cuando el servidor dice que ya no hay ataques).
 *
 * La lógica de ataque es LA MISMA que la web (check_attacks.php v3.9):
 * solo misión PvP real (1/2/9) en ida de otro jugador hace sonar la
 * sirena; PVE y espionajes no la disparan.
 */
public class EstadoService extends Service {

    // ── Identificadores fijos de canales y notificaciones ──
    public static final String CANAL_SERVICIO = "astroio_servicio";
    public static final String CANAL_MENSAJES = "astroio_mensajes";
    public static final String CANAL_ATAQUES  = "astroio_ataques";
    private static final int NOTI_SERVICIO  = 1;
    private static final int NOTI_MENSAJE   = 2;
    private static final int NOTI_ATAQUE    = 3;

    // ── Intervalo de consulta al servidor (60 s, como la web) ──
    private static final long INTERVALO_MS = 60000;

    private final Handler manejador = new Handler(Looper.getMainLooper());
    private MediaPlayer sirena;          // alarma de ataque
    private int mensajesAntes = -1;      // -1 = primera comprobación
    private boolean enAtaque = false;    // estado anterior del ataque
    private boolean ocupado = false;     // evita consultas solapadas

    // Tarea que se ejecuta en bucle: consulta el estado y reprograma.
    private final Runnable ciclo = new Runnable() {
        @Override public void run() {
            comprobarEstado();
            manejador.postDelayed(this, INTERVALO_MS);
        }
    };

    @Override
    public void onCreate() {
        super.onCreate();
        crearCanales();
        // Notificación fija y silenciosa exigida por Android a todo
        // servicio en primer plano: "AstroIO activo".
        startForeground(NOTI_SERVICIO, notiServicio());
        manejador.post(ciclo); // primera comprobación inmediata
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // START_STICKY: si el sistema mata el servicio, se reinicia solo.
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        manejador.removeCallbacks(ciclo);
        pararSirena();
        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null; // servicio sin enlace: solo trabajo en segundo plano
    }

    // ════════════════════════════════════════════════════════════════
    //  Consulta de estado (red en hilo propio, UI por el Handler)
    // ════════════════════════════════════════════════════════════════

    private void comprobarEstado() {
        if (ocupado) return;
        ocupado = true;
        // La red NO puede ir en el hilo principal de un servicio.
        final Thread t = new Thread(new Runnable() {
            @Override public void run() {
                int mensajes = -1;
                boolean ataque = false;
                boolean respuestaValida = false;
                try {
                    // La sesión del juego la guarda el WebView (CookieManager):
                    // el servicio consulta como el MISMO jugador.
                    String cookie = Servidor.cookieSesion();
                    if (cookie != null) {
                        String cuerpo = Servidor.get(Servidor.estadoUrl(), cookie,
                                Servidor.CONEX_TIMEOUT);
                        if (cuerpo != null) {
                            JSONObject json = new JSONObject(cuerpo);
                            if (!json.has("error") && !json.has("reason")) {
                                mensajes = json.optInt("mensajes", 0);
                                ataque   = json.optBoolean("hasAttack", false);
                                respuestaValida = true;
                            }
                        }
                    }
                } catch (Exception ignored) {
                    // Sin red o sin sesión: no notificar nada este ciclo.
                }
                final int fMensajes = mensajes;
                final boolean fAtaque = ataque;
                final boolean fValida = respuestaValida;
                manejador.post(new Runnable() {
                    @Override public void run() {
                        ocupado = false;
                        if (fValida) {
                            procesar(fMensajes, fAtaque);
                        }
                    }
                });
            }
        });
        t.setDaemon(true);
        t.start();
    }

    /** Decide notificaciones y sirena comparando con el estado anterior. */
    private void procesar(int mensajes, boolean ataque) {
        // ── Mensaje nuevo: solo cuando el contador SUBE ──
        if (mensajesAntes >= 0 && mensajes > mensajesAntes) {
            notificarMensaje(mensajes);
        }
        mensajesAntes = mensajes;

        // ── Ataque: sirena al empezar y silencio al terminar ──
        if (ataque && !enAtaque) {
            notificarAtaque();
            arrancarSirena();
        } else if (!ataque && enAtaque) {
            pararSirena();
            // El aviso de ataque se retira: ya no hay flotas enemigas en vuelo.
            NotificationManager nm =
                    (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
            nm.cancel(NOTI_ATAQUE);
        }
        enAtaque = ataque;
    }

    // ════════════════════════════════════════════════════════════════
    //  Notificaciones
    // ════════════════════════════════════════════════════════════════

    /** Notificación fija y silenciosa del servicio (canal de prioridad baja). */
    private Notification notiServicio() {
        Notification.Builder b = builder(CANAL_SERVICIO)
                .setSmallIcon(android.R.drawable.stat_notify_sync_noanim)
                .setContentTitle(getString(R.string.n_servicio_titulo))
                .setContentText(getString(R.string.n_servicio_texto))
                .setOngoing(true)
                .setOnlyAlertOnce(true);
        return b.build();
    }

    /** Notificación flotante (heads-up) de mensaje nuevo. */
    private void notificarMensaje(int total) {
        if (!notificacionesActivas()) return;
        Intent abrir = new Intent(this, MainActivity.class)
                .setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        PendingIntent pi = PendingIntent.getActivity(this, 11, abrir,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        Notification.Builder b = builder(CANAL_MENSAJES)
                .setSmallIcon(android.R.drawable.sym_action_email)
                .setLargeIcon(BitmapFactory.decodeResource(getResources(),
                        R.drawable.logo_astroio))
                .setContentTitle(getString(R.string.n_mensaje_titulo))
                .setContentText(getString(R.string.n_mensaje_texto, total))
                .setStyle(new Notification.BigTextStyle().bigText(
                        getString(R.string.n_mensaje_texto, total)))
                .setContentIntent(pi)
                .setAutoCancel(true)
                .setDefaults(Notification.DEFAULT_SOUND | Notification.DEFAULT_VIBRATE);
        NotificationManager nm =
                (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
        nm.notify(NOTI_MENSAJE, b.build());
    }

    /** Notificación de emergencia de ataque (la sirena la acompaña aparte). */
    private void notificarAtaque() {
        if (!notificacionesActivas()) return;
        Intent abrir = new Intent(this, MainActivity.class)
                .setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        PendingIntent pi = PendingIntent.getActivity(this, 12, abrir,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        Notification.Builder b = builder(CANAL_ATAQUES)
                .setSmallIcon(android.R.drawable.ic_dialog_alert)
                .setLargeIcon(BitmapFactory.decodeResource(getResources(),
                        R.drawable.logo_astroio))
                .setContentTitle(getString(R.string.n_ataque_titulo))
                .setContentText(getString(R.string.n_ataque_texto))
                .setStyle(new Notification.BigTextStyle().bigText(
                        getString(R.string.n_ataque_texto)))
                .setContentIntent(pi)
                .setAutoCancel(true)
                // Prioridad máxima: aparece flotando sobre lo que se esté
                // usando, como el chat flotante que pedía el requisito.
                .setPriority(Notification.PRIORITY_MAX)
                .setVibrate(new long[]{0, 400, 200, 400});
        NotificationManager nm =
                (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
        nm.notify(NOTI_ATAQUE, b.build());
    }

    /**
     * Builder compatible: en Android 8+ el canal manda (importancia →
     * heads-up); en versiones anteriores manda setPriority().
     */
    private Notification.Builder builder(String canal) {
        if (Build.VERSION.SDK_INT >= 26) {
            return new Notification.Builder(this, canal);
        }
        Notification.Builder b = new Notification.Builder(this);
        if (canal.equals(CANAL_ATAQUES)) {
            b.setPriority(Notification.PRIORITY_MAX);
        } else if (canal.equals(CANAL_MENSAJES)) {
            b.setPriority(Notification.PRIORITY_HIGH);
        } else {
            b.setPriority(Notification.PRIORITY_LOW);
        }
        return b;
    }

    /** ¿El jugador ha dado permiso de notificaciones (Android 13+)? */
    private boolean notificacionesActivas() {
        if (Build.VERSION.SDK_INT >= 33) {
            NotificationManager nm =
                    (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
            return nm != null && nm.areNotificationsEnabled();
        }
        return true;
    }

    /** Crea los 3 canales (Android 8+; en anteriores no existen). */
    private void crearCanales() {
        if (Build.VERSION.SDK_INT < 26) return;
        NotificationManager nm =
                (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
        if (nm == null) return;

        NotificationChannel servicio = new NotificationChannel(CANAL_SERVICIO,
                getString(R.string.c_servicio), NotificationManager.IMPORTANCE_LOW);
        servicio.setSound(null, null);      // silencioso
        servicio.setShowBadge(false);
        nm.createNotificationChannel(servicio);

        NotificationChannel mensajes = new NotificationChannel(CANAL_MENSAJES,
                getString(R.string.c_mensajes), NotificationManager.IMPORTANCE_HIGH);
        mensajes.setDescription(getString(R.string.c_mensajes_desc));
        mensajes.enableVibration(true);
        nm.createNotificationChannel(mensajes);

        NotificationChannel ataques = new NotificationChannel(CANAL_ATAQUES,
                getString(R.string.c_ataques), NotificationManager.IMPORTANCE_HIGH);
        ataques.setDescription(getString(R.string.c_ataques_desc));
        ataques.setSound(null, null);       // el sonido es la SIRENA (MediaPlayer)
        ataques.enableVibration(true);
        ataques.setVibrationPattern(new long[]{0, 400, 200, 400});
        ataques.setBypassDnd(true);         // la alarma suena aunque haya silencio
        nm.createNotificationChannel(ataques);
    }

    // ════════════════════════════════════════════════════════════════
    //  Sirena de la alarma de ataque
    // ════════════════════════════════════════════════════════════════

    private void arrancarSirena() {
        if (sirena != null) return; // ya sonando
        try {
            sirena = MediaPlayer.create(this, R.raw.alarma_ataque);
            if (sirena == null) return;
            // A volumen de ALARMA (no de multimedia): se oye aunque el
            // teléfono esté en música baja; el canal además salta el modo
            // No molestar. En bucle hasta que el ataque termine.
            AudioAttributes attrs = new AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build();
            sirena.setAudioAttributes(attrs);
            sirena.setLooping(true);
            sirena.start();
        } catch (Exception e) {
            sirena = null;
        }
    }

    private void pararSirena() {
        if (sirena != null) {
            try {
                sirena.stop();
                sirena.release();
            } catch (Exception ignored) { }
            sirena = null;
        }
    }
}
