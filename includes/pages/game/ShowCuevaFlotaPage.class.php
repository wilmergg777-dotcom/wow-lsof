<?php
/**
 * La Cueva Pirata - Controlador del Lobby (Flota + Ajedrez)
 * URL: game.php?page=cuevaFlota          → Flota
 * URL: game.php?page=cuevaFlota&juego=ajedrez → Ajedrez
 * AstroIO 2026
 */

if (!defined('MODE')) { die('Hacking attempt'); }

require_once 'includes/classes/CuevaHelper.class.php';

class ShowCuevaFlotaPage extends AbstractGamePage
{
    public function __construct()
    {
        parent::__construct();
    }

    public function show()
    {
        global $USER, $LNG;

        $db = Database::get();
        $p  = DB_PREFIX;

        // ============================================================
        // 0) DETECTAR JUEGO (flota | ajedrez)
        // ============================================================
        $juego = isset($_GET['juego']) ? strtolower(trim($_GET['juego'])) : 'flota';
        if (!in_array($juego, ['flota', 'ajedrez'], true)) {
            $juego = 'flota';
        }
        $urlTablero = ($juego === 'ajedrez')
            ? 'game.php?page=cuevaAjedrez'
            : 'game.php?page=cuevaPartida';

        // ============================================================
        // 1) DETECTAR RIEL DEL JUGADOR
        // ============================================================
        $user = $db->selectSingle(
            "SELECT id, username, ntx20, untx20, darkmatter, metodo_retiro, id_planet
             FROM `{$p}users` WHERE id = :uid LIMIT 1",
            [':uid' => $USER['id']]
        );

        if (!$user) {
            $this->printMessage('Usuario invalido', 'Error', 'game.php?page=overview');
            return;
        }

        $riel = CuevaHelper::detectarRiel($user);

        // Saldo del riel del jugador (NTX o UNTX)
        $saldoRiel = ($riel['metodo'] === 'QVAPAY')
            ? (int)$user['untx20']
            : (int)$user['ntx20'];

        // Saldo de recursos
        $saldoDarkmatter = (int)$user['darkmatter'];

        // Planetas del jugador (para apuesta de deuterio)
        $planetas = $db->select(
            "SELECT id, name, deuterium
             FROM `{$p}planets`
             WHERE id_owner = :uid AND destruyed = 0
             ORDER BY planet_type ASC, id ASC",
            [':uid' => $USER['id']]
        );
        foreach ($planetas ?: [] as &$pl) {
            $pl['deuterium'] = (int)$pl['deuterium'];
        }
        unset($pl);

        // ============================================================
        // 2) SALAS ABIERTAS (filtradas por juego)
        // ============================================================
        $salas = CuevaHelper::listarSalas($USER['id'], $user['metodo_retiro'], $juego);

        // ============================================================
        // 3) PARTIDAS ACTIVAS DEL JUGADOR (filtradas por juego)
        // ============================================================
        $misPartidas = [];

        if ($juego === 'ajedrez') {
            // -------- AJEDREZ: turno real desde cueva_ajedrez --------
            $partidasActivas = $db->select(
                "SELECT s.id AS sala_id, s.tipo_apuesta, s.apuesta_final, s.pozo,
                        s.id_jugador1, s.id_jugador2, s.estado AS sala_estado,
                        a.turno AS aj_turno, a.estado AS aj_estado,
                        a.jugador_blancas, a.jugador_negras,
                        u1.username AS jugador1, u2.username AS jugador2
                 FROM `{$p}cueva_salas` s
                 LEFT JOIN `{$p}cueva_ajedrez` a ON a.id_sala = s.id
                 LEFT JOIN `{$p}users` u1 ON u1.id = s.id_jugador1
                 LEFT JOIN `{$p}users` u2 ON u2.id = s.id_jugador2
                 WHERE s.estado IN ('esperando','jugando')
                   AND s.juego = 'ajedrez'
                   AND (s.id_jugador1 = :uid OR s.id_jugador2 = :uid)
                 ORDER BY s.fecha_creacion DESC",
                [':uid' => $USER['id']]
            );

            foreach ($partidasActivas ?: [] as $pa) {
                $esJ1    = ((int)$pa['id_jugador1'] === (int)$USER['id']);
                $esJ2    = ((int)$pa['id_jugador2'] === (int)$USER['id']);

                $ajEstado = $pa['aj_estado'] ? $pa['aj_estado'] : 'jugando';
                $ajTurno  = $pa['aj_turno']  ? $pa['aj_turno']  : null;

                $esBlancas = ((int)$pa['jugador_blancas'] === (int)$USER['id']);
                $esNegras  = ((int)$pa['jugador_negras']  === (int)$USER['id']);

                $miTurno = ($ajEstado === 'jugando') && (
                    ($esBlancas && $ajTurno === 'w') ||
                    ($esNegras  && $ajTurno === 'b')
                );

                // Fase que verá el template: 'jugando' | 'jugando_espera' | etc.
                $fase = ($pa['sala_estado'] === 'esperando')
                    ? 'esperando'
                    : $ajEstado;

                $pa['es_creador']   = $esJ1;
                $pa['mi_turno']     = $miTurno;
                $pa['rival']        = $esJ1 ? $pa['jugador2'] : $pa['jugador1'];
                $pa['fase']         = $fase;
                $pa['moneda_label'] = [
                    'NTX'  => 'NTX-20',
                    'UNTX' => 'UNTX-20',
                    'DEUT' => 'Deuterio',
                    'DUST' => 'Materia Oscura',
                ][$pa['tipo_apuesta']];

                $misPartidas[] = $pa;
            }
        } else {
            // -------- FLOTA: turno desde cueva_partidas --------
            $partidasActivas = $db->select(
                "SELECT s.id AS sala_id, s.tipo_apuesta, s.apuesta_final, s.pozo,
                        s.id_jugador1, s.id_jugador2,
                        p.fase, p.turno,
                        u1.username AS jugador1, u2.username AS jugador2
                 FROM `{$p}cueva_salas` s
                 INNER JOIN `{$p}cueva_partidas` p ON p.id_sala = s.id
                 LEFT JOIN `{$p}users` u1 ON u1.id = s.id_jugador1
                 LEFT JOIN `{$p}users` u2 ON u2.id = s.id_jugador2
                 WHERE s.estado IN ('esperando','jugando')
                   AND s.juego = 'flota'
                   AND (s.id_jugador1 = :uid OR s.id_jugador2 = :uid)
                 ORDER BY s.fecha_creacion DESC",
                [':uid' => $USER['id']]
            );

            foreach ($partidasActivas ?: [] as $pa) {
                $esJ1 = ((int)$pa['id_jugador1'] === (int)$USER['id']);
                $miTurno = ($pa['fase'] === 'disparos') &&
                           (($esJ1 && (int)$pa['turno'] === 1) ||
                            (!$esJ1 && (int)$pa['turno'] === 2));

                $pa['es_creador']   = $esJ1;
                $pa['mi_turno']     = $miTurno;
                $pa['rival']        = $esJ1 ? $pa['jugador2'] : $pa['jugador1'];
                $pa['moneda_label'] = [
                    'NTX'  => 'NTX-20',
                    'UNTX' => 'UNTX-20',
                    'DEUT' => 'Deuterio',
                    'DUST' => 'Materia Oscura',
                ][$pa['tipo_apuesta']];

                $misPartidas[] = $pa;
            }
        }

        // ============================================================
        // 4) ASIGNAR VARIABLES AL TEMPLATE
        // ============================================================
        $this->tplObj->assign_vars([
            // Juego actual
            'juego'            => $juego,
            'url_tablero'      => $urlTablero,

            // Identidad / riel
            'player_id'        => (int)$USER['id'],
            'player_name'      => $user['username'],
            'metodo_retiro'    => $riel['metodo'],
            'moneda_riel'      => $riel['etiqueta'],
            'factor_riel'      => $riel['factor'],
            'tipo_riel'        => $riel['tipo_apuesta'],

            // Saldos
            'saldo_riel'       => $saldoRiel,
            'saldo_darkmatter' => $saldoDarkmatter,

            // Planetas para apostar deuterio
            'planetas'         => $planetas ?: [],

            // Salas
            'salas'            => $salas,

            // Partidas activas
            'mis_partidas'     => $misPartidas,

            // URL base para AJAX
            'url_ajax'         => 'game.php?page=cuevaAjax',
            'letras'           => ['A','B','C','D','E','F','G','H','I','J'],
        ]);

        $this->display('page.cueva.flota.tpl');
    }
}
?>