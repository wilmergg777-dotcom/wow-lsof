<?php
/**
 * La Cueva Pirata - Controlador del Tablero
 * URL: game.php?page=cuevaPartida&sala=X
 * AstroIO 2026
 */

if (!defined('MODE')) { die('Hacking attempt'); }

// --- CORRECCIÓN: Cargar el Helper manualmente ---
require_once 'includes/classes/CuevaHelper.class.php';

class ShowCuevaPartidaPage extends AbstractGamePage
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
            $this->printMessage('Sala invalida', 'Error', 'game.php?page=cueva');
            return;
        }

        // 1) Cargar Sala y Partida
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

        $esJ1 = ((int)$sala['id_jugador1'] === (int)$USER['id']);
        $esJ2 = ((int)$sala['id_jugador2'] === (int)$USER['id']);
        if (!$esJ1 && !$esJ2) {
            $this->printMessage('No participas en esta partida', 'Error', 'game.php?page=cueva');
            return;
        }

        // Si la sala sigue esperando, lo mandamos al lobby (o a la vista de espera)
        if ($sala['estado'] === 'esperando') {
            header('Location: game.php?page=cueva');
            exit;
        }

        $partida = $db->selectSingle(
            "SELECT * FROM `{$p}cueva_partidas` WHERE id_sala = :sid LIMIT 1",
            [':sid' => $salaId]
        );
        if (!$partida) {
            $this->printMessage('Partida no encontrada', 'Error', 'game.php?page=cueva');
            return;
        }

        $partidaId = (int)$partida['id'];
        $rivalId   = $esJ1 ? (int)$sala['id_jugador2'] : (int)$sala['id_jugador1'];
        $miId      = (int)$USER['id'];
        $miTurno   = ($partida['fase'] === 'disparos') &&
                     (($esJ1 && (int)$partida['turno'] === 1) ||
                      (!$esJ1 && (int)$partida['turno'] === 2));

        // Calcular el tiempo restante inicial exacto para evitar el "reloj loco"
        $timeLeft = 0;
        if ($sala['estado'] === 'jugando') {
            if ($partida['fase'] === 'colocacion' && !empty($sala['fecha_inicio'])) {
                $timeLeft = CuevaHelper::TIEMPO_COLOCACION_SEG - (time() - strtotime($sala['fecha_inicio']));
            } elseif ($partida['fase'] === 'disparos' && !empty($partida['fecha_turno_inicio'])) {
                $timeLeft = CuevaHelper::TIEMPO_TURNO_SEG - (time() - strtotime($partida['fecha_turno_inicio']));
            }
        }
        if ($timeLeft < 0) $timeLeft = 0;

        // 2) Construir Mi Tablero
        $misNaves = $db->select(
            "SELECT coordenada, tipo_nave, impactada FROM `{$p}cueva_flota`
             WHERE id_partida = :pid AND id_jugador = :uid",
            [':pid' => $partidaId, ':uid' => $miId]
        );
        $miFlotaMap = [];
        $miFlotaCoords = []; // Guardamos las coordenadas para enviarlas al JS
        foreach ($misNaves ?: [] as $n) {
            $miFlotaMap[$n['coordenada']] = ['tipo' => $n['tipo_nave'], 'impactada' => (int)$n['impactada']];
            $miFlotaCoords[] = $n['coordenada'];
        }

        $disparosRival = $db->select(
            "SELECT coordenada, resultado FROM `{$p}cueva_disparos`
             WHERE id_partida = :pid AND id_jugador = :rival",
            [':pid' => $partidaId, ':rival' => $rivalId]
        );
        $disparosRivalMap = [];
        foreach ($disparosRival ?: [] as $d) {
            $disparosRivalMap[$d['coordenada']] = $d['resultado'];
        }

        $miTablero = [];
        for ($fila = 1; $fila <= 10; $fila++) {
            for ($col = 0; $col < 10; $col++) {
                $letra = chr(65 + $col);
                $coord = $letra . $fila;
                $estado = 'vacio';
                $tipoNave = null;

                if (isset($miFlotaMap[$coord])) {
                    $tipoNave = $miFlotaMap[$coord]['tipo'];
                    $estado = $miFlotaMap[$coord]['impactada'] ? 'tocado' : 'nave';
                }
                if (isset($disparosRivalMap[$coord])) {
                    $r = $disparosRivalMap[$coord];
                    if ($r === 'agua')   $estado = 'agua';
                    if ($r === 'tocado') $estado = 'tocado';
                    if ($r === 'hundido') $estado = 'hundido';
                }
                $miTablero[] = ['coord' => $coord, 'estado' => $estado, 'tipo' => $tipoNave];
            }
        }

        // 3) Construir Tablero Rival
        $misDisparos = $db->select(
            "SELECT coordenada, resultado FROM `{$p}cueva_disparos`
             WHERE id_partida = :pid AND id_jugador = :uid",
            [':pid' => $partidaId, ':uid' => $miId]
        );
        $misDisparosMap = [];
        foreach ($misDisparos ?: [] as $d) {
            $misDisparosMap[$d['coordenada']] = $d['resultado'];
        }

        $flotaRival = $db->select(
            "SELECT coordenada, tipo_nave, impactada FROM `{$p}cueva_flota`
             WHERE id_partida = :pid AND id_jugador = :rival",
            [':pid' => $partidaId, ':rival' => $rivalId]
        );
        
        $navesPorTipo = [];
        foreach ($flotaRival ?: [] as $f) {
            $navesPorTipo[$f['tipo_nave']][] = $f;
        }
        $coordsReveladas = [];
        foreach ($navesPorTipo as $tipo => $casillas) {
            $todasImpactadas = true;
            foreach ($casillas as $c) {
                if ((int)$c['impactada'] === 0) { $todasImpactadas = false; break; }
            }
            if ($todasImpactadas) {
                foreach ($casillas as $c) { $coordsReveladas[$c['coordenada']] = $tipo; }
            }
        }

        $tableroRival = [];
        for ($fila = 1; $fila <= 10; $fila++) {
            for ($col = 0; $col < 10; $col++) {
                $letra = chr(65 + $col);
                $coord = $letra . $fila;
                $estado = 'vacio';
                $tipoNave = null;

                if (isset($misDisparosMap[$coord])) {
                    $r = $misDisparosMap[$coord];
                    if ($r === 'agua')    $estado = 'agua';
                    if ($r === 'tocado')  $estado = 'tocado';
                    if ($r === 'hundido') $estado = 'hundido';
                }
                if (isset($coordsReveladas[$coord])) {
                    $estado = 'hundido';
                    $tipoNave = $coordsReveladas[$coord];
                }
                $tableroRival[] = ['coord' => $coord, 'estado' => $estado, 'tipo' => $tipoNave];
            }
        }

        // 4) Fase de Colocación
        $enColocacion = ($partida['fase'] === 'colocacion');
        $yaColoque = $esJ1 ? (int)$partida['colocacion_j1_ok'] : (int)$partida['colocacion_j2_ok'];
        $rivalColoco = $esJ1 ? (int)$partida['colocacion_j2_ok'] : (int)$partida['colocacion_j1_ok'];

        // 5) Enviar al Template
        $this->tplObj->assign_vars([
            'sala_id'         => $salaId,
            'partida_id'      => $partidaId,
            'jugador1'        => $sala['jugador1'],
            'jugador2'        => $sala['jugador2'],
            'soy_j1'          => $esJ1,
            'mi_nombre'       => $esJ1 ? $sala['jugador1'] : $sala['jugador2'],
            'rival_nombre'    => $esJ1 ? $sala['jugador2'] : $sala['jugador1'],
            'fase'            => $partida['fase'],
            'mi_turno'        => $miTurno,
            'mis_impactos'    => $esJ1 ? (int)$partida['impactos_j1'] : (int)$partida['impactos_j2'],
            'rival_impactos'  => $esJ1 ? (int)$partida['impactos_j2'] : (int)$partida['impactos_j1'],
            'tipo_apuesta'    => $sala['tipo_apuesta'],
            'moneda_label'    => ['NTX'=>'NTX-20','UNTX'=>'UNTX-20','DEUT'=>'Deuterio','DUST'=>'Materia Oscura'][$sala['tipo_apuesta']],
            'pozo'            => (int)$sala['pozo'],
            'mi_tablero'      => $miTablero,
            'tablero_rival'   => $tableroRival,
            'en_colocacion'   => $enColocacion,
            'ya_coloque'      => $yaColoque,
            'rival_coloco'    => $rivalColoco,
            'url_ajax'        => 'game.php?page=cuevaAjax',
            'url_lobby'       => 'game.php?page=cueva',
            'letras'          => ['A','B','C','D','E','F','G','H','I','J'],
            'time_left'       => $timeLeft,          // <--- NUEVO: Tiempo exacto al cargar
            'mi_flota_coords' => $miFlotaCoords      // <--- NUEVO: Naves para redibujar
        ]);

        $this->display('page.cueva.partida.tpl');
    }
}
?>