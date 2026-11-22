<?php
/**
 *  AstroIO - Página de Eventos
 *  Archivo: includes/pages/game/ShowEventsPage.class.php
 *  URL:     game.php?page=events
 *  Compatible con 2Moons 2.0.git (PDO)
 *
 *  Reglas:
 *   - Los eventos se resetean automáticamente (diarios/semanales/élite)
 *   - Los eventos rotan automaticamente cada 24h / 5d / 17d
 *   - Al completar → botón "Reclamar" se activa
 *   - Recompensas: metal, crystal, deuterium o containers
 */

// ============================================
// ASTROIO - Cargar EventHelper explícitamente
// (PHP 8.2 + autoloader)
// ============================================
if (!class_exists('EventHelper')) {
    require_once ROOT_PATH.'includes/classes/EventHelper.class.php';
}
// ============================================

class ShowEventsPage extends AbstractGamePage
{
    function __construct()
    {
        parent::__construct();
    }

    /**
     * Mapa de iconos texto → emoji
     */
    private function getIconEmoji($icon)
    {
        $map = array(
            'ATK'  => '⚔️',
            'REC'  => '♻️',
            'EXP'  => '🧭',
            'RES'  => '💰',
            'SHIP' => '🚀',
            'TEC'  => '🔬',
            'ELT'  => '👑',
        );
        return isset($map[$icon]) ? $map[$icon] : '🎯';
    }

    /**
     * Texto formateado de la recompensa
     * Solo: metal, crystal, deuterium, containers
     */
    private function getRewardText($type, $value)
    {
        $value = (int)$value;
        switch ($type) {
            case 'metal':     return '🪙 '.number_format($value).' Metal';
            case 'crystal':   return '💎 '.number_format($value).' Cristal';
            case 'deuterium': return '🧪 '.number_format($value).' Deuterio';
            case 'containers':return '📦 '.number_format($value).' Contenedores';
            default:          return '🎁 '.number_format($value).' '.$type;
        }
    }

    public function show()
    {
        global $USER, $LNG, $db;

        // ============================================
        // AUTO-SEEDER: crea los 40 eventos si la tabla esta vacia
        // Se ejecuta 1 vez. Si ya existen, no hace nada.
        // ============================================
        EventHelper::ensureEventsExist();
        // ============================================

        // ============================================
        // ROTACION: comprueba si toca rotar los eventos
        // (24h / 5d / 17d segun la clase)
        // ============================================
        EventHelper::rotateEvents();
        // ============================================

        $action  = HTTP::_GP('action', '');
        $message = '';
        $msgType = 'info';
        $reward  = null;

        // ============================================
        // PROCESAR RECLAMACIÓN
        // ============================================
        if ($action === 'claim') {
            $eventId = (int) HTTP::_GP('event_id', 0);

            $result = EventHelper::claimReward($USER['id'], $eventId);

            if ($result['success']) {
                $message = $result['message'];
                $msgType = 'success';
                $reward  = $result['reward'];
            } else {
                $message = $result['message'];
                $msgType = 'error';
            }
        }

        // ============================================
        // CARGAR EVENTOS
        // ============================================
        $allEvents = EventHelper::getUserEvents($USER['id'], 'all');

        // Separar por clase
        $eventsByClass = array(
            'daily'  => array(),
            'weekly' => array(),
            'elite'  => array(),
            'admin'  => array(),
        );

        foreach ($allEvents as $event) {
            $class = $event['event_class'];
            if (!isset($eventsByClass[$class])) {
                $eventsByClass[$class] = array();
            }

            // Calcular % de progreso
            $target   = max(1, (int)$event['event_target_value']);
            $progress = (int)$event['progress'];
            $percent  = min(100, round(($progress / $target) * 100));

            $event['icon_emoji']       = $this->getIconEmoji($event['event_icon']);
            $event['progress_pct']     = $percent;
            $event['progress_fmt']     = number_format($progress);
            $event['target_fmt']       = number_format($target);
            $event['reward_value_fmt'] = number_format((int)$event['reward_value']);
            $event['is_complete']      = ($progress >= $target);
            $event['is_claimed']       = ($event['claimed'] == 1);
            $event['can_claim']        = ($event['is_complete'] && !$event['is_claimed']);
            $event['reward_text']      = $this->getRewardText($event['reward_type'], $event['reward_value']);

            $eventsByClass[$class][] = $event;
        }

        // ============================================
        // CARGAR HISTORIAL (últimos 10)
        // ============================================
        $prefix = 'uni1_';
        if (defined('DB_PREFIX')) $prefix = DB_PREFIX;
        elseif (defined('PREFIX')) $prefix = PREFIX;

        $history = $db->select(
            "SELECT * FROM `".$prefix."events_history` 
             WHERE user_id = :uid 
             ORDER BY claimed_at DESC 
             LIMIT 10;",
            array(':uid' => $USER['id'])
        );

        if (!is_array($history)) $history = array();

        foreach ($history as &$h) {
            $h['reward_text']    = $this->getRewardText($h['reward_type'], $h['reward_value']);
            $h['date_formatted'] = date('d/m H:i', (int)$h['claimed_at']);
        }
        unset($h);

        // ============================================
        // ASIGNAR AL TEMPLATE
        // ============================================
        $this->assign(array(
            'dailyEvents'   => $eventsByClass['daily'],
            'weeklyEvents'  => $eventsByClass['weekly'],
            'eliteEvents'   => $eventsByClass['elite'],
            'adminEvents'   => $eventsByClass['admin'],
            'history'       => $history,
            'message'       => $message,
            'msgType'       => $msgType,
            'reward'        => $reward,
            'totalDaily'    => count($eventsByClass['daily']),
            'totalWeekly'   => count($eventsByClass['weekly']),
            'totalElite'    => count($eventsByClass['elite']),
            'totalAdmin'    => count($eventsByClass['admin']),
        ));

        $this->display('page.events.default.tpl');
    }
}