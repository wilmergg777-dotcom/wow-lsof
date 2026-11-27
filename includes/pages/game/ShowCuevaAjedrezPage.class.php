<?php
/**
 * La Cueva Pirata - Controlador del Tablero de Ajedrez
 * URL: game.php?page=cuevaAjedrez&sala=X
 * AstroIO 2026
 */

if (!defined('MODE')) { die('Hacking attempt'); }

require_once 'includes/classes/CuevaHelper.class.php';

class ShowCuevaAjedrezPage extends AbstractGamePage
{
    public function __construct()
    {
        parent::__construct();
    }

    public function show()
    {
        global $USER;

        $db = Database::get();
        $p  = DB_PREFIX;

        $salaId = isset($_GET['sala']) ? (int)$_GET['sala'] : 0;
        if ($salaId <= 0) {
            $this->printMessage('Sala inválida', 'Error', 'game.php?page=cueva');
            return;
        }

        // 1) Cargar Sala + usuarios
        $sala = $db->selectSingle(
            "SELECT s.*, u1.username AS jugador1, u2.username AS jugador2
             FROM `{$p}cueva_salas` s
             LEFT JOIN `{$p}users` u1 ON u1.id = s.id_jugador1
             LEFT JOIN `{$p}users` u2 ON u2.id = s.id_jugador2
             WHERE s.id = :sid LIMIT 1",
            [':sid' => $salaId]
        );
        if (!$sala) {
            $this->printMessage('Sala no encontrada', 'Error', 'game.php?page=cueva');
            return;
        }

        // Validar que sea una sala de ajedrez
        if (!isset($sala['juego']) || $sala['juego'] !== 'ajedrez') {
            $this->printMessage('Esta sala no es de ajedrez', 'Error', 'game.php?page=cueva');
            return;
        }

        $esJ1 = ((int)$sala['id_jugador1'] === (int)$USER['id']);
        $esJ2 = ((int)$sala['id_jugador2'] === (int)$USER['id']);
        if (!$esJ1 && !$esJ2) {
            $this->printMessage('No participas en esta partida', 'Error', 'game.php?page=cueva');
            return;
        }

        // Si sigue esperando rival → al lobby
        if ($sala['estado'] === 'esperando') {
            header('Location: game.php?page=cueva');
            exit;
        }

        // 2) Cargar estado del tablero (puede no existir si aún no fue aceptada)
        $aj = $db->selectSingle(
            "SELECT * FROM `{$p}cueva_ajedrez` WHERE id_sala = :sid LIMIT 1",
            [':sid' => $salaId]
        );
        if (!$aj) {
            $this->printMessage('Partida de ajedrez no inicializada', 'Error', 'game.php?page=cueva');
            return;
        }

        // 3) Verificar timeout antes de renderizar (si expiró, se liquidará aquí)
        CuevaHelper::verificarTimeoutAjedrez($salaId);

        // 4) Recargar ambos registros tras la posible liquidación
        $sala = $db->selectSingle(
            "SELECT s.*, u1.username AS jugador1, u2.username AS jugador2
             FROM `{$p}cueva_salas` s
             LEFT JOIN `{$p}users` u1 ON u1.id = s.id_jugador1
             LEFT JOIN `{$p}users` u2 ON u2.id = s.id_jugador2
             WHERE s.id = :sid LIMIT 1",
            [':sid' => $salaId]
        );
        $aj = $db->selectSingle(
            "SELECT * FROM `{$p}cueva_ajedrez` WHERE id_sala = :sid LIMIT 1",
            [':sid' => $salaId]
        );

        $miId      = (int)$USER['id'];
        $rivalId   = $esJ1 ? (int)$sala['id_jugador2'] : (int)$sala['id_jugador1'];
        $miNombre  = $esJ1 ? $sala['jugador1'] : $sala['jugador2'];
        $rivalNombre = $esJ1 ? $sala['jugador2'] : $sala['jugador1'];

        $esBlancas = ((int)$aj['jugador_blancas'] === $miId);
        $esNegras  = ((int)$aj['jugador_negras']  === $miId);
        $miTurno   = ($aj['estado'] === 'jugando') &&
                     (($esBlancas && $aj['turno'] === 'w') || ($esNegras && $aj['turno'] === 'b'));

        // 5) Calcular tiempo restante exacto al cargar
        $timeLeft = 0;
        if ($aj['estado'] === 'jugando' && $sala['estado'] === 'jugando' && !empty($aj['fecha_actualizacion'])) {
            $timeLeft = CuevaHelper::TIEMPO_TURNO_SEG - (time() - strtotime($aj['fecha_actualizacion']));
        }
        if ($timeLeft < 0) $timeLeft = 0;

        $ganador = $aj['ganador'] !== null ? (int)$aj['ganador'] : null;

        // 6) Enviar al Template
        $this->tplObj->assign_vars([
            'sala_id'        => $salaId,
            'mi_id'          => $miId,
            'rival_id'       => $rivalId,
            'mi_nombre'      => $miNombre,
            'rival_nombre'   => $rivalNombre,
            'fen'            => $aj['fen'],
            'historial'      => $aj['historial'] ? $aj['historial'] : '',
            'turno'          => $aj['turno'],
            'estado'         => $aj['estado'],
            'sala_estado'    => $sala['estado'],
            'ganador'        => $ganador,
            'motivo_fin'     => $aj['motivo_fin'],
            'soy_blancas'    => $esBlancas,
            'mi_turno'       => $miTurno,
            'gane_yo'        => ($ganador !== null && $ganador === $miId),
            'time_left'      => $timeLeft,
            'pozo'           => (int)$sala['pozo'],
            'apuesta_final'  => (int)$sala['apuesta_final'],
            'tipo_apuesta'   => $sala['tipo_apuesta'],
            'moneda_label'   => ['NTX'=>'NTX-20','UNTX'=>'UNTX-20','DEUT'=>'Deuterio','DUST'=>'Materia Oscura'][$sala['tipo_apuesta']],
            'url_ajax'       => 'game.php?page=cuevaAjax',
            'url_lobby'      => 'game.php?page=cueva',
        ]);

        $this->display('page.cueva.ajedrez.tpl');
    }
}