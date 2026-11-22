<?php
/**
 * BugReportHelper — Sistema de Reporte de Bugs
 * AstroIO v1.0
 *
 * Estados SIMPLIFICADOS:
 *   pendiente    → Recién creado, jugador NO lo ve
 *   aceptado     → Admin aceptó, jugador ve "En Proceso"
 *   solucionado  → Admin lo arregló en código, jugador ve "Pendiente Update"
 *   cancelado    → No es bug válido (eliminado para el jugador)
 *   borrado      → Update aplicado, se elimina del sistema
 *
 * Flujo del jugador:
 *   Crea reporte → No lo ve hasta que admin acepte
 *   Admin acepta → Aparece como "En Proceso"
 *   Admin soluciona → Aparece como "Pendiente Update"
 *   Admin aplica update → Se borra
 *
 * Flujo del admin:
 *   Pendientes → ACEPTAR / CANCELAR
 *   Aceptados  → MARCAR SOLUCIONADO / CANCELAR
 *   Solucionados → BORRAR (al aplicar el update)
 */

if (!defined('MODE')) die('Hacking attempt');

class BugReportHelper
{
    /* ============================================================
     * CONSTANTES — LÍMITES ANTI-SPAM
     * ============================================================ */
    const MAX_REPORTES_ACTIVOS = 3;
    const MAX_REPORTES_POR_DIA = 5;
    const COOLDOWN_SEGUNDOS    = 600; // 10 minutos
    const TITULO_MIN           = 5;
    const TITULO_MAX           = 200;
    const DESCRIPCION_MIN      = 30;

    /* ============================================================
     * TIPO DE MENSAJE — Sistema (4)
     * 0 = Espionaje, 1 = Jugadores, 2 = Alianza, 3 = Batallas,
     * 4 = Sistema, 15 = Expediciones, 50 = Noticias, 999 = Enviados
     * ============================================================ */
    const MSG_TYPE_SYSTEM = 4;

    /* ============================================================
     * PREFIJO DE TABLAS
     * ============================================================ */
    private static function prefix()
    {
        if (defined('DB_PREFIX')) return DB_PREFIX;
        if (defined('PREFIX'))    return PREFIX;
        return 'uni1_';
    }

    /* ============================================================
     * INSTANCIA DE LA BD
     * ============================================================ */
    private static function db()
    {
        return Database::get();
    }

    /* ============================================================
     * TIMESTAMP ACTUAL
     * ============================================================ */
    private static function now()
    {
        return defined('TIMESTAMP') ? TIMESTAMP : time();
    }

    /* ============================================================
     * MAPA DE EMOJIS — Código => Emoji
     * ============================================================ */
    public static function getEmoji($code)
    {
        $mapa = [
            'building' => '🏗️',
            'flask'    => '🔬',
            'rocket'   => '🚀',
            'shield'   => '🛡️',
            'user'     => '👤',
            'money'    => '💰',
            'anchor'   => '⚓',
            'box'      => '📦',
            'globe'    => '🌌',
            'castle'   => '🏰',
            'gear'     => '⚙️',
            'note'     => '📝'
        ];
        return isset($mapa[$code]) ? $mapa[$code] : '📝';
    }

    /* ============================================================
     * MAPA DE ESTADOS — Estado => Info visual
     * ============================================================ */
    public static function getEstadoInfo($estado)
    {
        $mapa = [
            'pendiente'    => ['color' => '#ffdd88', 'icono' => '🟡', 'texto' => 'Pendiente'],
            'aceptado'     => ['color' => '#00ccff', 'icono' => '🔵', 'texto' => 'En Proceso'],
            'solucionado'  => ['color' => '#ffaa33', 'icono' => '🟠', 'texto' => 'Pendiente Update'],
            'cancelado'    => ['color' => '#ff4488', 'icono' => '🔴', 'texto' => 'Cancelado'],
            'borrado'      => ['color' => '#666666', 'icono' => '⚫', 'texto' => 'Borrado']
        ];
        return isset($mapa[$estado]) ? $mapa[$estado] : ['color' => '#888', 'icono' => '❓', 'texto' => 'Desconocido'];
    }

    /* ============================================================
     * OBTENER CATEGORÍAS
     * ============================================================ */
    public static function getCategorias()
    {
        $db = self::db();
        $prefix = self::prefix();

        $rows = $db->select(
            "SELECT * FROM ".$prefix."bug_categories 
             WHERE activo = 1 
             ORDER BY orden ASC"
        );

        if (!$rows) return [];

        foreach ($rows as &$row) {
            $row['emoji'] = self::getEmoji($row['icono']);
        }

        return $rows;
    }

    /* ============================================================
     * OBTENER CATEGORÍA POR CLAVE
     * ============================================================ */
    public static function getCategoria($clave)
    {
        $db = self::db();
        $prefix = self::prefix();

        $row = $db->selectSingle(
            "SELECT * FROM ".$prefix."bug_categories 
             WHERE clave = :clave AND activo = 1 
             LIMIT 1",
            [':clave' => $clave]
        );

        if ($row) {
            $row['emoji'] = self::getEmoji($row['icono']);
        }

        return $row;
    }

    /* ============================================================
     * VALIDAR REPORTE (ANTI-SPAM)
     * ============================================================ */
    public static function validarReporte($userId, $titulo, $descripcion)
    {
        $db = self::db();
        $prefix = self::prefix();
        $userId = (int)$userId;

        // Título
        $titulo = trim($titulo);
        if (strlen($titulo) < self::TITULO_MIN) {
            return ['success' => false, 'message' => '❌ El título es demasiado corto (mínimo '.self::TITULO_MIN.' caracteres).'];
        }
        if (strlen($titulo) > self::TITULO_MAX) {
            return ['success' => false, 'message' => '❌ El título es demasiado largo (máximo '.self::TITULO_MAX.' caracteres).'];
        }

        // Descripción
        $descripcion = trim($descripcion);
        if (strlen($descripcion) < self::DESCRIPCION_MIN) {
            return ['success' => false, 'message' => '❌ La descripción es demasiado corta (mínimo '.self::DESCRIPCION_MIN.' caracteres).'];
        }

        // ¿Cuántos reportes activos tiene? (pendiente, aceptado, solucionado)
        $row = $db->selectSingle(
            "SELECT COUNT(*) AS total 
             FROM ".$prefix."bug_reports 
             WHERE user_id = :uid 
               AND estado IN ('pendiente', 'aceptado', 'solucionado')
               AND eliminada = 0",
            [':uid' => $userId]
        );
        $activos = (int)($row['total'] ?? 0);
        if ($activos >= self::MAX_REPORTES_ACTIVOS) {
            return ['success' => false, 'message' => '❌ Tenés '.$activos.' reportes activos. Máximo: '.self::MAX_REPORTES_ACTIVOS.'. Esperá a que se resuelvan.'];
        }

        // ¿Cuántos reportes hizo hoy?
        $hace24h = self::now() - 86400;
        $row = $db->selectSingle(
            "SELECT COUNT(*) AS total 
             FROM ".$prefix."bug_reports 
             WHERE user_id = :uid 
               AND fecha_creacion > :hace24h",
            [':uid' => $userId, ':hace24h' => $hace24h]
        );
        $hoy = (int)($row['total'] ?? 0);
        if ($hoy >= self::MAX_REPORTES_POR_DIA) {
            return ['success' => false, 'message' => '❌ Ya enviaste '.self::MAX_REPORTES_POR_DIA.' reportes hoy. Esperá a mañana.'];
        }

        // Cooldown entre reportes
        $row = $db->selectSingle(
            "SELECT fecha_creacion 
             FROM ".$prefix."bug_reports 
             WHERE user_id = :uid 
             ORDER BY fecha_creacion DESC 
             LIMIT 1",
            [':uid' => $userId]
        );
        if ($row) {
            $diff = self::now() - (int)$row['fecha_creacion'];
            if ($diff < self::COOLDOWN_SEGUNDOS) {
                $espera = self::COOLDOWN_SEGUNDOS - $diff;
                $mins = ceil($espera / 60);
                return ['success' => false, 'message' => '⏳ Esperá '.$mins.' minuto(s) antes de crear otro reporte.'];
            }
        }

        return ['success' => true];
    }

    /* ============================================================
     * CREAR REPORTE
     * ============================================================ */
    public static function crearReporte($userId, $categoria, $titulo, $descripcion, $prioridad = 'media')
    {
        $db = self::db();
        $prefix = self::prefix();
        $userId = (int)$userId;

        // Validar
        $validacion = self::validarReporte($userId, $titulo, $descripcion);
        if (!$validacion['success']) {
            return $validacion;
        }

        // Validar categoría
        $cat = self::getCategoria($categoria);
        if (!$cat) {
            return ['success' => false, 'message' => '❌ Categoría no válida.'];
        }

        // Validar prioridad
        if (!in_array($prioridad, ['baja', 'media', 'alta', 'critica'])) {
            $prioridad = 'media';
        }

        $now = self::now();

        $db->insert(
            "INSERT INTO ".$prefix."bug_reports 
             (user_id, titulo, categoria, descripcion, prioridad, estado, fecha_creacion, eliminada)
             VALUES (:uid, :tit, :cat, :desc, :pri, 'pendiente', :now, 0)",
            [
                ':uid'  => $userId,
                ':tit'  => trim($titulo),
                ':cat'  => $categoria,
                ':desc' => trim($descripcion),
                ':pri'  => $prioridad,
                ':now'  => $now
            ]
        );

        $reportId = (int)$db->lastInsertId();

        // Log
        self::log($reportId, $userId, null, 'creado', 'Reporte creado por el jugador');

        // Notificar a los admins
        self::notificarAdmins($reportId, $userId, $titulo, $categoria);

        return [
            'success'   => true,
            'message'   => '✅ Reporte enviado. Será revisado por un admin.',
            'report_id' => $reportId
        ];
    }

    /* ============================================================
     * NOTIFICAR A TODOS LOS ADMINS
     * (SIN emojis porque la tabla messages no soporta utf8mb4)
     * AHORA: message_type = 4 (Mensajes del Sistema)
     * ============================================================ */
    public static function notificarAdmins($reportId, $userId, $titulo, $categoria)
    {
        $db = self::db();
        $prefix = self::prefix();

        // Obtener nombre del jugador
        $userRow = $db->selectSingle(
            "SELECT username FROM ".$prefix."users WHERE id = :uid LIMIT 1",
            [':uid' => (int)$userId]
        );
        $username = $userRow ? $userRow['username'] : 'Desconocido';

        // Obtener info de la categoría
        $cat = self::getCategoria($categoria);
        $catNombre = $cat ? $cat['nombre'] : 'Otros';

        // Obtener todos los admins (authlevel >= 1)
        $admins = $db->select(
            "SELECT id FROM ".$prefix."users WHERE authlevel >= 1"
        );

        if (!$admins || !is_array($admins)) return;

        // Universo actual
        $universe = defined('UNIVERSE') ? UNIVERSE : 1;

        // SIN EMOJIS — la tabla messages no soporta utf8mb4
        $subject = "Nuevo reporte de bug #".$reportId;
        $text = "El jugador ".$username." ha creado un nuevo reporte.\n\n".
                "Categoria: ".$catNombre."\n".
                "Titulo: ".$titulo."\n\n".
                "Ver reporte: game.php?page=bugreportadmin&mode=ver&id=".$reportId;

        $now = self::now();

        foreach ($admins as $admin) {
            $db->insert(
                "INSERT INTO ".$prefix."messages 
                 (message_owner, message_sender, message_time, message_type, 
                  message_from, message_subject, message_text, 
                  message_unread, message_universe)
                 VALUES (:owner, 0, :time, :mtype, :from, :subj, :txt, 1, :uni)",
                [
                    ':owner' => (int)$admin['id'],
                    ':time'  => $now,
                    ':mtype' => self::MSG_TYPE_SYSTEM,
                    ':from'  => 'Sistema de Bugs',
                    ':subj'  => $subject,
                    ':txt'   => $text,
                    ':uni'   => (int)$universe
                ]
            );
        }
    }

    /* ============================================================
     * NOTIFICAR AL JUGADOR — Cuando cambia el estado de su reporte
     * AHORA: message_type = 4 (Mensajes del Sistema)
     * ============================================================ */
    public static function notificarJugador($reportId, $userId, $tipo)
    {
        $db = self::db();
        $prefix = self::prefix();
        $userId = (int)$userId;

        if ($userId <= 0) return;

        $subject = '';
        $text = '';

        switch ($tipo) {
            case 'aceptado':
                $subject = 'Reporte #'.$reportId.' aceptado';
                $text = "Tu reporte #".$reportId." ha sido aceptado por un administrador.\n\n".
                        "Ahora está en proceso de revisión. Podés verlo en:\n".
                        "game.php?page=bugreport";
                break;
            case 'solucionado':
                $subject = 'Reporte #'.$reportId.' solucionado';
                $text = "Tu reporte #".$reportId." ha sido solucionado.\n\n".
                        "El fix está aplicado. Podés verlo en:\n".
                        "game.php?page=bugreport";
                break;
            case 'resuelto':
                $subject = 'Reporte #'.$reportId.' resuelto';
                $text = "Tu reporte #".$reportId." ha sido completamente resuelto.\n\n".
                        "Gracias por colaborar con AstroIO.";
                break;
            case 'cancelado':
                $subject = 'Reporte #'.$reportId.' cancelado';
                $text = "Tu reporte #".$reportId." fue cancelado.\n\n".
                        "Si tenés dudas, contactá a un administrador.";
                break;
            default:
                return;
        }

        $universe = defined('UNIVERSE') ? UNIVERSE : 1;
        $now = self::now();

        $db->insert(
            "INSERT INTO ".$prefix."messages 
             (message_owner, message_sender, message_time, message_type, 
              message_from, message_subject, message_text, 
              message_unread, message_universe)
             VALUES (:owner, 0, :time, :mtype, :from, :subj, :txt, 1, :uni)",
            [
                ':owner' => $userId,
                ':time'  => $now,
                ':mtype' => self::MSG_TYPE_SYSTEM,
                ':from'  => 'Sistema de Bugs',
                ':subj'  => $subject,
                ':txt'   => $text,
                ':uni'   => (int)$universe
            ]
        );
    }

    /* ============================================================
     * MIS REPORTES (vista del jugador)
     * Solo muestra: aceptado, solucionado
     * NO muestra: pendiente, cancelado, borrado
     * ============================================================ */
    public static function getMisReportes($userId)
    {
        $db = self::db();
        $prefix = self::prefix();
        $userId = (int)$userId;

        $rows = $db->select(
            "SELECT * FROM ".$prefix."bug_reports 
             WHERE user_id = :uid 
               AND estado IN ('aceptado', 'solucionado')
               AND eliminada = 0
             ORDER BY fecha_creacion DESC",
            [':uid' => $userId]
        );

        if (!$rows) return [];

        foreach ($rows as &$row) {
            $cat = self::getCategoria($row['categoria']);
            $row['categoria_nombre'] = $cat ? $cat['nombre'] : 'Otros';
            $row['categoria_emoji']  = $cat ? $cat['emoji'] : '📝';
            $row['estado_info']      = self::getEstadoInfo($row['estado']);
        }

        return $rows;
    }

    /* ============================================================
     * OBTENER REPORTE POR ID
     * ============================================================ */
    public static function getReporteById($reportId)
    {
        $db = self::db();
        $prefix = self::prefix();

        $row = $db->selectSingle(
            "SELECT r.*, u.username AS jugador, a.username AS admin_nombre
             FROM ".$prefix."bug_reports r
             LEFT JOIN ".$prefix."users u ON u.id = r.user_id
             LEFT JOIN ".$prefix."users a ON a.id = r.admin_id
             WHERE r.id = :id 
             LIMIT 1",
            [':id' => (int)$reportId]
        );

        if (!$row) return null;

        $cat = self::getCategoria($row['categoria']);
        $row['categoria_nombre'] = $cat ? $cat['nombre'] : 'Otros';
        $row['categoria_emoji']  = $cat ? $cat['emoji'] : '📝';
        $row['estado_info']      = self::getEstadoInfo($row['estado']);

        return $row;
    }

    /* ============================================================
     * PUEDE VER EL REPORTE EL JUGADOR
     * ============================================================ */
    public static function puedeVerReporte($reportId, $userId)
    {
        $reporte = self::getReporteById($reportId);
        if (!$reporte) return false;

        if ((int)$reporte['user_id'] === (int)$userId) {
            return in_array($reporte['estado'], ['aceptado', 'solucionado']);
        }

        return false;
    }

    /* ============================================================
     * LISTADO PÚBLICO — Solo aceptados y solucionados
     * ============================================================ */
    public static function getReportesPublicos($limit = 50)
    {
        $db = self::db();
        $prefix = self::prefix();
        $limit = (int)$limit;

        $rows = $db->select(
            "SELECT * FROM ".$prefix."bug_reports 
             WHERE estado IN ('aceptado', 'solucionado')
               AND eliminada = 0
             ORDER BY 
                FIELD(estado, 'solucionado', 'aceptado'),
                fecha_creacion DESC
             LIMIT ".$limit
        );

        if (!$rows) return [];

        foreach ($rows as &$row) {
            $cat = self::getCategoria($row['categoria']);
            $row['categoria_nombre'] = $cat ? $cat['nombre'] : 'Otros';
            $row['categoria_emoji']  = $cat ? $cat['emoji'] : '📝';
            $row['estado_info']      = self::getEstadoInfo($row['estado']);
        }

        return $rows;
    }

    /* ============================================================
     * LISTADOS DEL ADMIN
     * ============================================================ */
    public static function getPendientes()
    {
        $db = self::db();
        $prefix = self::prefix();

        $rows = $db->select(
            "SELECT r.*, u.username AS jugador
             FROM ".$prefix."bug_reports r
             LEFT JOIN ".$prefix."users u ON u.id = r.user_id
             WHERE r.estado = 'pendiente' 
               AND r.eliminada = 0
             ORDER BY 
                FIELD(r.prioridad, 'critica', 'alta', 'media', 'baja'),
                r.fecha_creacion ASC"
        );

        return self::addInfoToRows($rows);
    }

    public static function getAceptados()
    {
        $db = self::db();
        $prefix = self::prefix();

        $rows = $db->select(
            "SELECT r.*, u.username AS jugador, a.username AS admin_nombre
             FROM ".$prefix."bug_reports r
             LEFT JOIN ".$prefix."users u ON u.id = r.user_id
             LEFT JOIN ".$prefix."users a ON a.id = r.admin_id
             WHERE r.estado = 'aceptado' 
               AND r.eliminada = 0
             ORDER BY r.fecha_asignacion ASC"
        );

        return self::addInfoToRows($rows);
    }

    public static function getSolucionados()
    {
        $db = self::db();
        $prefix = self::prefix();

        $rows = $db->select(
            "SELECT r.*, u.username AS jugador, a.username AS admin_nombre
             FROM ".$prefix."bug_reports r
             LEFT JOIN ".$prefix."users u ON u.id = r.user_id
             LEFT JOIN ".$prefix."users a ON a.id = r.admin_id
             WHERE r.estado = 'solucionado' 
               AND r.eliminada = 0
             ORDER BY r.fecha_solucion ASC"
        );

        return self::addInfoToRows($rows);
    }

    public static function getHistorial($limit = 100)
    {
        $db = self::db();
        $prefix = self::prefix();
        $limit = (int)$limit;

        $rows = $db->select(
            "SELECT r.*, u.username AS jugador, a.username AS admin_nombre
             FROM ".$prefix."bug_reports r
             LEFT JOIN ".$prefix."users u ON u.id = r.user_id
             LEFT JOIN ".$prefix."users a ON a.id = r.admin_id
             WHERE r.estado IN ('cancelado', 'borrado')
             ORDER BY r.fecha_cancelacion DESC
             LIMIT ".$limit
        );

        return self::addInfoToRows($rows);
    }

    private static function addInfoToRows($rows)
    {
        if (!$rows || !is_array($rows)) return [];

        foreach ($rows as &$row) {
            $cat = self::getCategoria($row['categoria']);
            $row['categoria_nombre'] = $cat ? $cat['nombre'] : 'Otros';
            $row['categoria_emoji']  = $cat ? $cat['emoji'] : '📝';
            $row['estado_info']      = self::getEstadoInfo($row['estado']);
        }

        return $rows;
    }

    /* ============================================================
     * ESTADÍSTICAS DEL DASHBOARD
     * ============================================================ */
    public static function getStats()
    {
        $db = self::db();
        $prefix = self::prefix();

        $stats = [
            'pendientes'   => 0,
            'aceptados'    => 0,
            'solucionados' => 0,
            'cancelados'   => 0,
            'borrados'     => 0,
            'total'        => 0
        ];

        $row = $db->selectSingle(
            "SELECT 
                SUM(CASE WHEN estado = 'pendiente' THEN 1 ELSE 0 END) AS pendientes,
                SUM(CASE WHEN estado = 'aceptado' THEN 1 ELSE 0 END) AS aceptados,
                SUM(CASE WHEN estado = 'solucionado' THEN 1 ELSE 0 END) AS solucionados,
                SUM(CASE WHEN estado = 'cancelado' THEN 1 ELSE 0 END) AS cancelados,
                SUM(CASE WHEN estado = 'borrado' THEN 1 ELSE 0 END) AS borrados,
                COUNT(*) AS total
             FROM ".$prefix."bug_reports"
        );

        if ($row) {
            $stats['pendientes']   = (int)($row['pendientes'] ?? 0);
            $stats['aceptados']    = (int)($row['aceptados'] ?? 0);
            $stats['solucionados'] = (int)($row['solucionados'] ?? 0);
            $stats['cancelados']   = (int)($row['cancelados'] ?? 0);
            $stats['borrados']     = (int)($row['borrados'] ?? 0);
            $stats['total']        = (int)($row['total'] ?? 0);
        }

        return $stats;
    }

    /* ============================================================
     * ACCIONES DEL ADMIN
     * ============================================================ */

    /**
     * ACEPTAR — El admin confirma que es un bug real
     */
    public static function aceptar($reportId, $adminId)
    {
        $db = self::db();
        $prefix = self::prefix();
        $reportId = (int)$reportId;
        $adminId = (int)$adminId;

        $reporte = self::getReporteById($reportId);
        if (!$reporte) {
            return ['success' => false, 'message' => '❌ Reporte no encontrado.'];
        }
        if ($reporte['estado'] !== 'pendiente') {
            return ['success' => false, 'message' => '❌ El reporte no está pendiente.'];
        }

        $now = self::now();

        $db->update(
            "UPDATE ".$prefix."bug_reports 
             SET estado = 'aceptado',
                 admin_id = :aid,
                 fecha_asignacion = :now
             WHERE id = :id",
            [':aid' => $adminId, ':now' => $now, ':id' => $reportId]
        );

        self::log($reportId, null, $adminId, 'aceptado', 'Reporte aceptado por el admin');

        // Notificar al jugador
        self::notificarJugador($reportId, (int)$reporte['user_id'], 'aceptado');

        return ['success' => true, 'message' => '✅ Reporte aceptado.'];
    }

    /**
     * CANCELAR — El admin rechaza el reporte (NO es bug válido)
     * Se elimina para el jugador
     */
    public static function cancelar($reportId, $adminId, $motivo)
    {
        $db = self::db();
        $prefix = self::prefix();
        $reportId = (int)$reportId;
        $adminId = (int)$adminId;

        $motivo = trim($motivo);
        if (strlen($motivo) < 5) {
            return ['success' => false, 'message' => '❌ El motivo es obligatorio (mínimo 5 caracteres).'];
        }

        $reporte = self::getReporteById($reportId);
        if (!$reporte) {
            return ['success' => false, 'message' => '❌ Reporte no encontrado.'];
        }
        if (!in_array($reporte['estado'], ['pendiente', 'aceptado'])) {
            return ['success' => false, 'message' => '❌ El reporte no se puede cancelar en este estado.'];
        }

        $now = self::now();

        $db->update(
            "UPDATE ".$prefix."bug_reports 
             SET estado = 'cancelado',
                 admin_id = :aid,
                 motivo_cancelacion = :motivo,
                 fecha_cancelacion = :now,
                 eliminada = 1
             WHERE id = :id",
            [':aid' => $adminId, ':motivo' => $motivo, ':now' => $now, ':id' => $reportId]
        );

        self::log($reportId, null, $adminId, 'cancelado', 'Motivo: '.$motivo);

        // Notificar al jugador
        self::notificarJugador($reportId, (int)$reporte['user_id'], 'cancelado');

        return ['success' => true, 'message' => '✅ Reporte cancelado y eliminado.'];
    }

    /**
     * MARCAR SOLUCIONADO — El admin ya lo arregló en código
     * El jugador ve "Pendiente Update"
     */
    public static function marcarSolucionado($reportId, $adminId)
    {
        $db = self::db();
        $prefix = self::prefix();
        $reportId = (int)$reportId;
        $adminId = (int)$adminId;

        $reporte = self::getReporteById($reportId);
        if (!$reporte) {
            return ['success' => false, 'message' => '❌ Reporte no encontrado.'];
        }
        if ($reporte['estado'] !== 'aceptado') {
            return ['success' => false, 'message' => '❌ El reporte debe estar aceptado primero.'];
        }

        $now = self::now();

        $db->update(
            "UPDATE ".$prefix."bug_reports 
             SET estado = 'solucionado',
                 fecha_solucion = :now
             WHERE id = :id",
            [':now' => $now, ':id' => $reportId]
        );

        self::log($reportId, null, $adminId, 'solucionado', 'Arreglado en código, esperando update');

        // Notificar al jugador
        self::notificarJugador($reportId, (int)$reporte['user_id'], 'solucionado');

        return ['success' => true, 'message' => '✅ Reporte solucionado. El jugador verá "Pendiente Update".'];
    }

    /**
     * BORRAR — El admin aplica el update real, el bug queda 100% arreglado
     * Se borra para todos
     */
    public static function borrar($reportId, $adminId)
    {
        $db = self::db();
        $prefix = self::prefix();
        $reportId = (int)$reportId;
        $adminId = (int)$adminId;

        $reporte = self::getReporteById($reportId);
        if (!$reporte) {
            return ['success' => false, 'message' => '❌ Reporte no encontrado.'];
        }
        if ($reporte['estado'] !== 'solucionado') {
            return ['success' => false, 'message' => '❌ Solo se pueden borrar reportes solucionados.'];
        }

        $db->update(
            "UPDATE ".$prefix."bug_reports 
             SET estado = 'borrado',
                 eliminada = 1
             WHERE id = :id",
            [':id' => $reportId]
        );

        self::log($reportId, null, $adminId, 'borrado', 'Update aplicado, reporte eliminado del sistema');

        // Notificar al jugador
        self::notificarJugador($reportId, (int)$reporte['user_id'], 'resuelto');

        return ['success' => true, 'message' => '✅ Reporte borrado. Nadie lo verá más.'];
    }

    /* ============================================================
     * LOG DE AUDITORÍA
     * ============================================================ */
    public static function log($reportId, $userId, $adminId, $accion, $detalle = '')
    {
        $db = self::db();
        $prefix = self::prefix();

        try {
            $db->insert(
                "INSERT INTO ".$prefix."bug_log 
                 (report_id, user_id, admin_id, accion, detalle, ip, fecha)
                 VALUES (:rid, :uid, :aid, :acc, :det, :ip, :now)",
                [
                    ':rid' => (int)$reportId,
                    ':uid' => $userId ? (int)$userId : null,
                    ':aid' => $adminId ? (int)$adminId : null,
                    ':acc' => $accion,
                    ':det' => $detalle,
                    ':ip'  => isset($_SERVER['REMOTE_ADDR']) ? $_SERVER['REMOTE_ADDR'] : null,
                    ':now' => self::now()
                ]
            );
        } catch (Exception $e) {
            // Silencioso
        }
    }

    /* ============================================================
     * OBTENER LOG DE UN REPORTE
     * ============================================================ */
    public static function getLogByReport($reportId)
    {
        $db = self::db();
        $prefix = self::prefix();

        $rows = $db->select(
            "SELECT l.*, u.username AS user_name, a.username AS admin_name
             FROM ".$prefix."bug_log l
             LEFT JOIN ".$prefix."users u ON u.id = l.user_id
             LEFT JOIN ".$prefix."users a ON a.id = l.admin_id
             WHERE l.report_id = :rid
             ORDER BY l.fecha ASC",
            [':rid' => (int)$reportId]
        );

        return $rows ? $rows : [];
    }
}