<?php

/**
 * AstroIO - Minijuego Topo (Golpea al Topo)
 * Controlador del juego
 *
 * Rutas:
 *   game.php?page=minijuegotopo               → Vista principal
 *   game.php?page=minijuegotopo&mode=start    → AJAX: iniciar partida
 *   game.php?page=minijuegotopo&mode=finish   → AJAX: terminar partida
 *
 * @package AstroIO
 * @author  AstroIO Team
 * @version 1.2
 */

require_once ROOT_PATH.'includes/classes/MinijuegoTopoHelper.class.php';

class ShowMinijuegotopoPage extends AbstractGamePage
{
    public static $requireModule = MODULE_MINIJUEGOTOPO;

    public $defaultController = 'show';


    /* ============================================================
     * CONSTRUCTOR
     * ============================================================ */

    public function __construct()
    {
        parent::__construct();
    }


    /* ============================================================
     * VISTA PRINCIPAL
     * ============================================================ */

    public function show()
    {
        global $USER, $LNG;

        $userId   = (int) $USER['id'];
        $username = $USER['username'];

        // Si el juego está deshabilitado por el admin
        if (!MinijuegoTopoHelper::isEnabled()) {
            $this->printMessage(
                'El Minijuego Topo está deshabilitado.',
                array(array(
                    'label' => 'Volver',
                    'url'   => 'game.php?page=overview'
                ))
            );
            return;
        }

        // Limpiar tokens viejos (1 vez por carga, barato)
        MinijuegoTopoHelper::cleanupOldTokens();

        // Stats del jugador (cooldown + record + partidas)
        $stats = MinijuegoTopoHelper::getPlayerStats($userId);

        // Ranking top 10
        $ranking = MinijuegoTopoHelper::getRanking(10);

        // Config del juego (para el JS)
        $config = array(
            'duration'       => (int) MinijuegoTopoHelper::getConfig('topo_game_duration', 30),
            'moleInterval'   => (int) MinijuegoTopoHelper::getConfig('topo_mole_interval_ms', 1000),
            'moleVisible'    => (int) MinijuegoTopoHelper::getConfig('topo_mole_visible_ms', 500),
            'pointsPerHit'   => (int) MinijuegoTopoHelper::getConfig('topo_points_per_hit', 100),
            'scoreMax'       => (int) MinijuegoTopoHelper::getConfig('topo_score_max', 3000),
            'scoreMin'       => (int) MinijuegoTopoHelper::getConfig('topo_score_min_reward', 350),
            'cooldownHours'  => (int) MinijuegoTopoHelper::getConfig('topo_cooldown_hours', 2)
        );

        // Info de tiers para mostrar en pantalla
        $tiers = array();
        for ($i = 1; $i <= 5; $i++) {
            $tiers[] = array(
                'tier'        => $i,
                'score'       => (int) MinijuegoTopoHelper::getConfig('topo_reward_'.$i.'_score', 0),
                'mo'          => (int) MinijuegoTopoHelper::getConfig('topo_reward_'.$i.'_mo', 0),
                'chest'       => (int) MinijuegoTopoHelper::getConfig('topo_reward_'.$i.'_chest_chance', 0),
                'chest_fixed' => (int) MinijuegoTopoHelper::getConfig('topo_reward_'.$i.'_chest_fixed', 0) // 🔥 NUEVO
            );
        }

        $this->tplObj->assign_vars(array(
            'topo_stats'         => $stats,
            'topo_ranking'       => $ranking,
            'topo_config'        => $config,
            'topo_tiers'         => $tiers,
            'topo_config_json'   => json_encode($config),
            'topo_username'      => $username,
            'topo_user_id'       => $userId,
            'topo_image_url'     => 'styles/theme/gow/minijuego/topo.png'
        ));

        $this->display('page.minijuegotopo.default.tpl');
    }


    /* ============================================================
     * AJAX: INICIAR PARTIDA
     * Ruta: game.php?page=minijuegotopo&mode=start
     * ============================================================ */

    public function start()
    {
        global $USER;

        header('Content-Type: application/json; charset=UTF-8');

        $userId   = (int) $USER['id'];
        $username = $USER['username'];

        // Intenta iniciar
        $result = MinijuegoTopoHelper::startGame($userId, $username);

        if (!$result['success']) {
            // Error (ej: cooldown)
            $cooldownLeft = MinijuegoTopoHelper::getCooldownLeft($userId);

            echo json_encode(array(
                'success'       => false,
                'error'         => $result['error'],
                'cooldown_left' => $cooldownLeft,
                'cooldown_text' => MinijuegoTopoHelper::formatTimeLeft($cooldownLeft)
            ));
            exit;
        }

        // OK → devolvemos el token
        echo json_encode(array(
            'success' => true,
            'token'   => $result['token']
        ));
        exit;
    }


    /* ============================================================
     * AJAX: TERMINAR PARTIDA
     * Ruta: game.php?page=minijuegotopo&mode=finish
     * ============================================================ */

    public function finish()
    {
        global $USER;

        header('Content-Type: application/json; charset=UTF-8');

        $userId = (int) $USER['id'];

        // Leer POST
        $token = isset($_POST['token']) ? trim((string) $_POST['token']) : '';
        $score = isset($_POST['score']) ? (int) $_POST['score']          : 0;

        // Validaciones básicas
        if (empty($token)) {
            echo json_encode(array(
                'success' => false,
                'error'   => 'missing_token'
            ));
            exit;
        }

        // Intenta terminar
        $result = MinijuegoTopoHelper::finishGame($userId, $token, $score);

        if (!$result['success']) {
            echo json_encode(array(
                'success' => false,
                'error'   => $result['error']
            ));
            exit;
        }

        // OK → devolvemos score + reward
        echo json_encode(array(
            'success' => true,
            'score'   => $result['score'],
            'reward'  => $result['reward']
        ));
        exit;
    }
}