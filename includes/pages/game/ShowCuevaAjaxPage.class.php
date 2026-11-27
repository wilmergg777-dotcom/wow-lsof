<?php
/**
 * La Cueva Pirata - Controlador AJAX del Lobby
 * URL: game.php?page=cuevaAjax
 * AstroIO 2026 - Soporta Flota + Ajedrez
 */

if (!defined('MODE')) { die('Hacking attempt'); }

// Incluimos el Helper para que no falle
require_once 'includes/classes/CuevaHelper.class.php';

class ShowCuevaAjaxPage extends AbstractGamePage
{
    public function __construct()
    {
        parent::__construct();
    }

    public function show()
    {
        global $USER;

        // Forzar respuesta JSON
        header('Content-Type: application/json; charset=utf-8');

        // =================================================================
        // INTERCEPTOR DE DATOS (Captura POST, GET o JSON crudo)
        // =================================================================
        $requestData = $_POST;
        
        if (empty($requestData)) {
            $requestData = $_GET; // Por si el JS envía los datos por la URL
        }
        
        if (empty($requestData)) {
            $json = file_get_contents('php://input');
            $decoded = json_decode($json, true);
            if (is_array($decoded)) {
                $requestData = $decoded; // Por si el JS envía JSON crudo (fetch)
            }
        }

        if (!is_array($requestData)) {
            $requestData = [];
        }

        // Buscar el nombre de la acción (soporta 'accion' y 'action')
        $accion = $requestData['accion'] ?? $requestData['action'] ?? '';
        
        // Mapear nombres cortos
        if ($accion === 'crear' || $accion === 'crear_mesa') {
            $accion = 'crear_sala';
        }
        if ($accion === 'buscar' || $accion === 'buscar_partida') {
            $accion = 'buscar_rapida';
        }

        $userId = (int)$USER['id'];

        try {
            switch ($accion) {
                
                // ----------------------------------------------------
                // CREAR SALA
                // ----------------------------------------------------
                case 'crear_sala':
                    $juego = $requestData['juego'] ?? 'flota';
                    if (!in_array($juego, ['flota', 'ajedrez'], true)) {
                        $juego = 'flota';
                    }

                    $r = CuevaHelper::crearSala(
                        $userId,
                        $requestData['tipo'] ?? '',
                        (int)($requestData['apuesta'] ?? 0),
                        isset($requestData['planeta']) && $requestData['planeta'] !== '' ? (int)$requestData['planeta'] : null,
                        'lobby',
                        $juego
                    );
                    break;

                // ----------------------------------------------------
                // ACEPTAR SALA
                // ----------------------------------------------------
                case 'aceptar_sala':
                    $salaIdAceptar = (int)($requestData['sala'] ?? 0);
                    $juegoAceptar   = 'flota';

                    // Determinar el tipo de juego leyendo la sala en la BD
                    if ($salaIdAceptar > 0) {
                        $dbTmp   = Database::get();
                        $pTemp   = DB_PREFIX;
                        $salaTmp = $dbTmp->selectSingle(
                            "SELECT juego FROM `{$pTemp}cueva_salas` WHERE id = :sid LIMIT 1",
                            [':sid' => $salaIdAceptar]
                        );
                        if ($salaTmp && isset($salaTmp['juego']) && $salaTmp['juego'] === 'ajedrez') {
                            $juegoAceptar = 'ajedrez';
                        }
                    }

                    $r = CuevaHelper::aceptarSala(
                        $userId,
                        $salaIdAceptar,
                        isset($requestData['planeta']) && $requestData['planeta'] !== '' ? (int)$requestData['planeta'] : null,
                        $juegoAceptar
                    );
                    break;

                // ----------------------------------------------------
                // CANCELAR SALA
                // ----------------------------------------------------
                case 'cancelar_sala':
                    $r = CuevaHelper::cancelarSala(
                        $userId,
                        (int)($requestData['sala'] ?? 0)
                    );
                    break;

                // ----------------------------------------------------
                // BUSCAR PARTIDA RÁPIDA
                // ----------------------------------------------------
                case 'buscar_rapida':
                    $juego = $requestData['juego'] ?? 'flota';
                    if (!in_array($juego, ['flota', 'ajedrez'], true)) {
                        $juego = 'flota';
                    }

                    $r = self::buscarRapida(
                        $userId,
                        $requestData['tipo'] ?? '',
                        (int)($requestData['apuesta'] ?? 0),
                        isset($requestData['planeta']) && $requestData['planeta'] !== '' ? (int)$requestData['planeta'] : null,
                        $juego
                    );
                    break;

                // ----------------------------------------------------
                // CHECK BÚSQUEDA (Polling del buscador)
                // ----------------------------------------------------
                case 'check_busqueda':
                    $r = self::checkBusqueda($userId);
                    break;

                // ----------------------------------------------------
                // COLOCAR FLOTA (Para la fase de colocación)
                // ----------------------------------------------------
                case 'colocar_flota':
                    $flotaJson = $requestData['flota'] ?? '[]';
                    $flota = json_decode($flotaJson, true);
                    if (!is_array($flota)) { 
                        $r = ['error' => 'Formato de flota inválido']; 
                        break; 
                    }
                    $r = CuevaHelper::colocarFlota(
                        (int)($requestData['sala'] ?? 0),
                        $userId,
                        $flota
                    );
                    break;

                // ----------------------------------------------------
                // DISPARAR (Para la fase de disparos)
                // ----------------------------------------------------
                case 'disparar':
                    $r = CuevaHelper::disparar(
                        (int)($requestData['sala'] ?? 0),
                        $userId,
                        strtoupper($requestData['coord'] ?? '')
                    );
                    break;

                // ----------------------------------------------------
                // CHECK ESTADO (Polling del tablero de FLOTA)
                // ----------------------------------------------------
                case 'check_estado':
                    $r = self::checkEstado(
                        $userId,
                        (int)($requestData['sala'] ?? 0)
                    );
                    break;

                // ----------------------------------------------------
                // MOVER AJEDREZ (Movimiento validado por chess.js en cliente)
                // ----------------------------------------------------
                case 'mover_ajedrez':
                    $ganador = null;
                    if (isset($requestData['ganador'])
                        && $requestData['ganador'] !== ''
                        && $requestData['ganador'] !== 'null'
                        && $requestData['ganador'] !== null
                    ) {
                        $ganador = (int)$requestData['ganador'];
                    }

                    $r = CuevaHelper::guardarMovimientoAjedrez(
                        (int)($requestData['sala'] ?? 0),
                        $userId,
                        $requestData['fen'] ?? '',
                        $requestData['historial'] ?? null,
                        $requestData['estado'] ?? 'jugando',
                        $ganador,
                        $requestData['motivo'] ?? null
                    );
                    break;

                // ----------------------------------------------------
                // CHECK AJEDREZ (Polling del tablero de AJEDREZ)
                // ----------------------------------------------------
                case 'check_ajedrez':
                    $r = self::checkAjedrez(
                        $userId,
                        (int)($requestData['sala'] ?? 0)
                    );
                    break;

                // ----------------------------------------------------
                // CHECK ESTADO GLOBAL (Radar para todas las páginas)
                // ----------------------------------------------------
                case 'check_estado_global':
                    $r = self::checkEstadoGlobal($userId);
                    break;

                // ----------------------------------------------------
                // RENDIRSE
                // ----------------------------------------------------
                case 'rendirse':
                    $r = self::rendirse(
                        $userId,
                        (int)($requestData['sala'] ?? 0)
                    );
                    break;

                default:
                    // Si sigue entrando aquí, te mostrará exactamente qué datos llegaron
                    $r = ['error' => 'Acción desconocida', 'datos_recibidos' => $requestData, 'raw_input' => file_get_contents('php://input')];
            }

        } catch (Throwable $e) {
            $r = ['error' => 'Excepción del sistema: ' . $e->getMessage()];
        }

        echo json_encode($r);
        exit;
    }

    /* ============================================================
     * LÓGICA PRIVADA
     * ============================================================ */

    private static function buscarRapida($userId, $tipo, $apuesta, $planeta, $juego = 'flota')
    {
        $db = Database::get();
        $p  = DB_PREFIX;

        if (!in_array($juego, ['flota', 'ajedrez'], true)) {
            $juego = 'flota';
        }

        $user = $db->selectSingle(
            "SELECT id, metodo_retiro FROM `{$p}users` WHERE id = :uid LIMIT 1",
            [':uid' => $userId]
        );
        if (!$user) return ['error' => 'Usuario inválido'];

        if (!in_array($tipo, ['NTX','UNTX','DEUT','DUST'])) return ['error' => 'Tipo inválido'];
        if ($apuesta <= 0) return ['error' => 'Apuesta inválida'];

        $riel = CuevaHelper::detectarRiel($user);
        if ($tipo === 'NTX'  && $riel['metodo'] !== 'CUP')    return ['error' => 'Esta apuesta es solo para CUP'];
        if ($tipo === 'UNTX' && $riel['metodo'] !== 'QVAPAY') return ['error' => 'Esta apuesta es solo para QVAPAY'];
        if ($tipo === 'DEUT' && !$planeta)                    return ['error' => 'Elegí un planeta para deuterio'];

        // Una sola sala activa por jugador
        $activa = $db->selectSingle(
            "SELECT id FROM `{$p}cueva_salas`
             WHERE (id_jugador1 = :uid OR id_jugador2 = :uid)
               AND estado IN ('esperando','jugando') LIMIT 1",
            [':uid' => $userId]
        );
        if ($activa) return ['error' => 'Ya tenés una sala activa'];

        // Buscar match (mismo juego + mismo tipo + misma apuesta base)
        $match = $db->selectSingle(
            "SELECT * FROM `{$p}cueva_salas`
             WHERE estado = 'esperando'
               AND juego = :juego
               AND tipo_apuesta = :tipo
               AND apuesta_base = :ap
               AND id_jugador1 <> :uid
             ORDER BY fecha_creacion ASC LIMIT 1",
            [':juego' => $juego, ':tipo' => $tipo, ':ap' => $apuesta, ':uid' => $userId]
        );

        if ($match) {
            $r = CuevaHelper::aceptarSala($userId, (int)$match['id'], $planeta, $juego);
            if (isset($r['error'])) return $r;
            return ['ok' => true, 'matcheada' => true, 'sala_id' => (int)$match['id']];
        }

        // Sin match → crear sala con modo='busqueda_rapida'
        $r = CuevaHelper::crearSala($userId, $tipo, $apuesta, $planeta, 'busqueda_rapida', $juego);
        if (isset($r['error'])) return $r;
        return ['ok' => true, 'matcheada' => false, 'sala_id' => (int)$r['sala_id']];
    }

    private static function checkBusqueda($userId)
    {
        $db = Database::get();
        $p  = DB_PREFIX;

        $sala = $db->selectSingle(
            "SELECT * FROM `{$p}cueva_salas`
             WHERE id_jugador1 = :uid
               AND modo = 'busqueda_rapida'
               AND estado IN ('esperando','jugando')
             ORDER BY id DESC LIMIT 1",
            [':uid' => $userId]
        );

        if (!$sala) return ['status' => 'not_found'];

        $juegoSala = $sala['juego'] ?? 'flota';

        if ($sala['estado'] === 'jugando') {
            return ['status' => 'matched', 'sala_id' => (int)$sala['id']];
        }

        $timePassed = time() - strtotime($sala['fecha_creacion']);
        if ($timePassed >= 300) {
            $db->update(
                "UPDATE `{$p}cueva_salas` SET modo = 'lobby' WHERE id = :sid",
                [':sid' => $sala['id']]
            );
            return ['status' => 'now_public', 'sala_id' => (int)$sala['id']];
        }

        // Match por mismo juego + tipo + apuesta
        $match = $db->selectSingle(
            "SELECT * FROM `{$p}cueva_salas`
             WHERE estado = 'esperando'
               AND juego = :juego
               AND tipo_apuesta = :tipo
               AND apuesta_base = :ap
               AND id_jugador1 <> :uid
             ORDER BY fecha_creacion ASC LIMIT 1",
            [':juego' => $juegoSala, ':tipo' => $sala['tipo_apuesta'], ':ap' => $sala['apuesta_base'], ':uid' => $userId]
        );

        if ($match) {
            CuevaHelper::cancelarSala($userId, (int)$sala['id']);
            $r = CuevaHelper::aceptarSala($userId, (int)$match['id'], $sala['id_planeta_j1'], $juegoSala);
            if (isset($r['error'])) return ['status' => 'error', 'error' => $r['error']];
            return ['status' => 'matched', 'sala_id' => (int)$match['id']];
        }

        return ['status' => 'waiting', 'time_left' => 300 - $timePassed];
    }

    private static function checkEstado($userId, $salaId)
    {
        $db = Database::get();
        $p  = DB_PREFIX;

        // VERIFICAR TIMEOUTS: Si el tiempo expiró, esto cancelará la partida o dará la victoria al rival.
        CuevaHelper::verificarTimeouts($salaId);

        // CORRECCIÓN: Añadimos s.fecha_inicio para calcular el tiempo restante
        $partida = $db->selectSingle(
            "SELECT p.*, s.estado, s.id_jugador1, s.id_jugador2, s.id_ganador, s.fecha_inicio
             FROM `{$p}cueva_partidas` p
             INNER JOIN `{$p}cueva_salas` s ON s.id = p.id_sala
             WHERE p.id_sala = :sid LIMIT 1",
            [':sid' => $salaId]
        );
        if (!$partida) return ['error' => 'No encontrada'];

        $esJ1 = ((int)$partida['id_jugador1'] === (int)$userId);
        $miTurno = ($partida['fase'] === 'disparos') &&
                   (($esJ1 && (int)$partida['turno'] === 1) ||
                    (!$esJ1 && (int)$partida['turno'] === 2));

        // CALCULAR TIEMPO RESTANTE EXACTO Y BLINDADO
        $time_left = 0;
        if ($partida['estado'] === 'jugando') {
            if ($partida['fase'] === 'colocacion') {
                $inicio = !empty($partida['fecha_inicio']) ? strtotime($partida['fecha_inicio']) : time();
                $time_left = CuevaHelper::TIEMPO_COLOCACION_SEG - (time() - $inicio);
            } elseif ($partida['fase'] === 'disparos') {
                $inicio = !empty($partida['fecha_turno_inicio']) ? strtotime($partida['fecha_turno_inicio']) : time();
                $time_left = CuevaHelper::TIEMPO_TURNO_SEG - (time() - $inicio);
            }
        }

        return [
            'ok'       => true,
            'fase'     => $partida['fase'],
            'estado'   => $partida['estado'],
            'mi_turno' => $miTurno,
            'gane_yo'  => ((int)$partida['id_ganador'] === (int)$userId),
            'time_left' => max(0, $time_left) // Devolvemos el tiempo exacto (nunca negativo)
        ];
    }

    /**
     * Polling del tablero de AJEDREZ.
     * Devuelve FEN, turno, estado, ganador, time_left y flags del jugador.
     */
    private static function checkAjedrez($userId, $salaId)
    {
        $db = Database::get();
        $p  = DB_PREFIX;

        // Verificar timeout de ajedrez (mata la partida si pasó el minuto)
        CuevaHelper::verificarTimeoutAjedrez($salaId);

        $aj = $db->selectSingle(
            "SELECT a.*, s.estado AS sala_estado, s.id_jugador1, s.id_jugador2, s.id_ganador AS sala_ganador
             FROM `{$p}cueva_ajedrez` a
             INNER JOIN `{$p}cueva_salas` s ON s.id = a.id_sala
             WHERE a.id_sala = :sid LIMIT 1",
            [':sid' => $salaId]
        );
        if (!$aj) return ['error' => 'Partida de ajedrez no encontrada'];

        $esBlancas = ((int)$aj['jugador_blancas'] === (int)$userId);
        $esNegras  = ((int)$aj['jugador_negras']  === (int)$userId);
        if (!$esBlancas && !$esNegras) {
            return ['error' => 'No participás en esta partida'];
        }

        $miTurno = ($esBlancas && $aj['turno'] === 'w') || ($esNegras && $aj['turno'] === 'b');

        // Tiempo restante del turno (solo si la partida sigue viva)
        $time_left = 0;
        if ($aj['estado'] === 'jugando' && $aj['sala_estado'] === 'jugando') {
            $inicio = !empty($aj['fecha_actualizacion']) ? strtotime($aj['fecha_actualizacion']) : time();
            $time_left = CuevaHelper::TIEMPO_TURNO_SEG - (time() - $inicio);
        }

        $ganador = $aj['ganador'] !== null ? (int)$aj['ganador'] : null;

        return [
            'ok'            => true,
            'fen'           => $aj['fen'],
            'historial'     => $aj['historial'],
            'turno'         => $aj['turno'],
            'estado'        => $aj['estado'],
            'sala_estado'   => $aj['sala_estado'],
            'ganador'       => $ganador,
            'motivo_fin'    => $aj['motivo_fin'],
            'mi_turno'      => $miTurno,
            'soy_blancas'   => $esBlancas,
            'gane_yo'       => ($ganador !== null && $ganador === (int)$userId),
            'time_left'     => max(0, $time_left),
        ];
    }

    // NUEVA FUNCIÓN: Radar global para saber si el jugador está en una partida activa
    private static function checkEstadoGlobal($userId)
    {
        $db = Database::get();
        $p  = DB_PREFIX;

        $sala = $db->selectSingle(
            "SELECT id FROM `{$p}cueva_salas`
             WHERE (id_jugador1 = :uid OR id_jugador2 = :uid)
               AND estado = 'jugando' LIMIT 1",
            [':uid' => $userId]
        );

        if ($sala) {
            // Verificamos timeouts de flota (no-op si es ajedrez)
            CuevaHelper::verificarTimeouts((int)$sala['id']);
            // Verificamos timeouts de ajedrez (no-op si es flota)
            CuevaHelper::verificarTimeoutAjedrez((int)$sala['id']);
            
            // Volvemos a consultar por si el timeout la acaba de cancelar
            $check = $db->selectSingle(
                "SELECT id FROM `{$p}cueva_salas` WHERE id = :sid AND estado = 'jugando' LIMIT 1",
                [':sid' => $sala['id']]
            );

            if ($check) {
                return ['status' => 'jugando', 'sala_id' => (int)$sala['id']];
            }
        }
        
        return ['status' => 'idle'];
    }

    private static function rendirse($userId, $salaId)
    {
        $db = Database::get();
        $p  = DB_PREFIX;

        $sala = $db->selectSingle(
            "SELECT * FROM `{$p}cueva_salas`
             WHERE id = :sid AND estado = 'jugando' LIMIT 1",
            [':sid' => $salaId]
        );
        if (!$sala) return ['error' => 'Sala no jugable'];
        if ((int)$sala['id_jugador1'] !== (int)$userId && (int)$sala['id_jugador2'] !== (int)$userId) {
            return ['error' => 'No participás'];
        }

        $ganador = ((int)$sala['id_jugador1'] === (int)$userId)
            ? (int)$sala['id_jugador2'] : (int)$sala['id_jugador1'];

        // Si es ajedrez, marcar rendición en cueva_ajedrez (para que el cliente muestre el motivo)
        $ahora = date('Y-m-d H:i:s');
        $db->update(
            "UPDATE `{$p}cueva_ajedrez`
             SET estado = 'rendicion', ganador = :g, motivo_fin = 'Rendición',
                 fecha_actualizacion = :ahora
             WHERE id_sala = :sid AND estado = 'jugando'",
            [':g' => $ganador, ':ahora' => $ahora, ':sid' => $salaId]
        );

        return CuevaHelper::finalizarPartida($salaId, $ganador);
    }
}