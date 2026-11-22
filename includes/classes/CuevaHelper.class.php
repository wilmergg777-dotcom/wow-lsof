<?php
/**
 * La Cueva Pirata - Hundir la Flota + Ajedrez
 * Helper central: toda la lógica de negocio en un solo lugar.
 */

if (!defined('MODE')) { die('Hacking attempt'); }

class CuevaHelper
{
    const PREFIJO_DEFAULT    = 'uni1_';
    const TIEMPO_EXPIRA_MIN  = 30;
    const TIEMPO_BUSQUEDA_SEG = 300;
    const TIEMPO_COLOCACION_SEG = 120; // 2 minutos para colocar flota
    const TIEMPO_TURNO_SEG   = 60;     // 1 minuto por disparo / movimiento de ajedrez
    const MAX_TURNOS_PERDIDOS = 3;

    const FEN_INICIAL = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

    private static function db()     { return Database::get(); }
    private static function pref()   { return defined('DB_PREFIX') ? DB_PREFIX : self::PREFIJO_DEFAULT; }

    private static function isUpdateSuccessful($stmt) {
        if ($stmt === false) return false;
        if (is_object($stmt) && method_exists($stmt, 'rowCount')) return $stmt->rowCount() >= 1;
        if (is_int($stmt)) return $stmt >= 1;
        return true;
    }

    public static function detectarRiel($user)
    {
        $qvapay = ($user && $user['metodo_retiro'] === 'QVAPAY');
        return [
            'metodo'        => $qvapay ? 'QVAPAY' : 'CUP',
            'columna'       => $qvapay ? 'untx20' : 'ntx20',
            'etiqueta'      => $qvapay ? 'UNTX-20' : 'NTX-20',
            'factor'        => $qvapay ? 2 : 1,
            'tipo_apuesta'  => $qvapay ? 'UNTX' : 'NTX',
        ];
    }

    public static function getSaldo($userId, $tipoApuesta, $idPlaneta = null)
    {
        $db = self::db(); $p = self::pref();

        switch ($tipoApuesta) {
            case 'NTX':
            case 'UNTX':
                $col = ($tipoApuesta === 'NTX') ? 'ntx20' : 'untx20';
                $r = $db->selectSingle(
                    "SELECT `{$col}` AS s FROM `{$p}users` WHERE id = :uid LIMIT 1",
                    [':uid' => $userId]
                );
                return $r ? (int)$r['s'] : 0;

            case 'DUST':
                $r = $db->selectSingle(
                    "SELECT darkmatter AS s FROM `{$p}users` WHERE id = :uid LIMIT 1",
                    [':uid' => $userId]
                );
                return $r ? (int)$r['s'] : 0;

            case 'DEUT':
                if (!$idPlaneta) return 0;
                $r = $db->selectSingle(
                    "SELECT deuterium AS s FROM `{$p}planets`
                     WHERE id = :pid AND id_owner = :uid LIMIT 1",
                    [':pid' => $idPlaneta, ':uid' => $userId]
                );
                return $r ? (int)$r['s'] : 0;
        }
        return 0;
    }

    private static function descontarSaldo($userId, $tipoApuesta, $cantidad, $idPlaneta = null)
    {
        $db = self::db(); $p = self::pref();

        if (self::getSaldo($userId, $tipoApuesta, $idPlaneta) < $cantidad) {
            return false;
        }

        switch ($tipoApuesta) {
            case 'NTX':
            case 'UNTX':
                $col = ($tipoApuesta === 'NTX') ? 'ntx20' : 'untx20';
                $stmt = $db->update(
                    "UPDATE `{$p}users`
                     SET `{$col}` = `{$col}` - :c
                     WHERE id = :uid AND `{$col}` >= :c",
                    [':c' => $cantidad, ':uid' => $userId]
                );
                return self::isUpdateSuccessful($stmt);

            case 'DUST':
                $stmt = $db->update(
                    "UPDATE `{$p}users`
                     SET darkmatter = darkmatter - :c
                     WHERE id = :uid AND darkmatter >= :c",
                    [':c' => $cantidad, ':uid' => $userId]
                );
                return self::isUpdateSuccessful($stmt);

            case 'DEUT':
                if (!$idPlaneta) return false;
                $stmt = $db->update(
                    "UPDATE `{$p}planets`
                     SET deuterium = deuterium - :c
                     WHERE id = :pid AND id_owner = :uid AND deuterium >= :c",
                    [':c' => $cantidad, ':pid' => $idPlaneta, ':uid' => $userId]
                );
                return self::isUpdateSuccessful($stmt);
        }
        return false;
    }

    private static function acreditarSaldo($userId, $tipoApuesta, $cantidad, $idPlaneta = null)
    {
        $db = self::db(); $p = self::pref();

        switch ($tipoApuesta) {
            case 'NTX':
            case 'UNTX':
                $col = ($tipoApuesta === 'NTX') ? 'ntx20' : 'untx20';
                $stmt = $db->update(
                    "UPDATE `{$p}users` SET `{$col}` = `{$col}` + :c WHERE id = :uid",
                    [':c' => $cantidad, ':uid' => $userId]
                );
                return self::isUpdateSuccessful($stmt);

            case 'DUST':
                $stmt = $db->update(
                    "UPDATE `{$p}users` SET darkmatter = darkmatter + :c WHERE id = :uid",
                    [':c' => $cantidad, ':uid' => $userId]
                );
                return self::isUpdateSuccessful($stmt);

            case 'DEUT':
                if (!$idPlaneta) return false;
                $stmt = $db->update(
                    "UPDATE `{$p}planets` SET deuterium = deuterium + :c WHERE id = :pid AND id_owner = :uid",
                    [':c' => $cantidad, ':pid' => $idPlaneta, ':uid' => $userId]
                );
                return self::isUpdateSuccessful($stmt);
        }
        return false;
    }

    private static function registrarMovimiento($userId, $idSala, $tipo, $moneda, $cantidad, $idPlaneta = null, $motivo = null)
    {
        $db = self::db(); $p = self::pref();
        $ahora = date('Y-m-d H:i:s');
        
        $db->insert(
            "INSERT INTO `{$p}cueva_movimientos`
             (id_jugador, id_sala, tipo, moneda, cantidad, id_planeta, motivo, fecha)
             VALUES (:uid, :sid, :tipo, :mon, :cant, :pid, :mot, :fecha)",
            [
                ':uid'   => $userId,
                ':sid'   => $idSala,
                ':tipo'  => $tipo,
                ':mon'   => $moneda,
                ':cant'  => $cantidad,
                ':pid'   => $idPlaneta,
                ':mot'   => $motivo,
                ':fecha' => $ahora,
            ]
        );
    }

    public static function crearSala($userId, $tipoApuesta, $apuestaBase, $idPlaneta = null, $modo = 'lobby', $juego = 'flota')
    {
        $db = self::db(); $p = self::pref();

        if (!in_array($tipoApuesta, ['NTX','UNTX','DEUT','DUST'])) {
            return ['error' => 'Tipo de apuesta inválido'];
        }

        if (!in_array($modo, ['lobby','busqueda_rapida'])) {
            $modo = 'lobby';
        }

        if (!in_array($juego, ['flota','ajedrez'])) {
            $juego = 'flota';
        }

        $user = $db->selectSingle(
            "SELECT id, metodo_retiro, ntx20, untx20, darkmatter
             FROM `{$p}users` WHERE id = :uid LIMIT 1",
            [':uid' => $userId]
        );
        if (!$user) return ['error' => 'Usuario inválido'];

        $riel = self::detectarRiel($user);
        if ($tipoApuesta === 'NTX' && $riel['metodo'] !== 'CUP') {
            return ['error' => 'Solo jugadores CUP pueden apostar NTX-20'];
        }
        if ($tipoApuesta === 'UNTX' && $riel['metodo'] !== 'QVAPAY') {
            return ['error' => 'Solo jugadores QVAPAY pueden apostar UNTX-20'];
        }
        if ($tipoApuesta === 'DEUT' && !$idPlaneta) {
            return ['error' => 'Debés elegir un planeta para apostar deuterio'];
        }

        $apuestaBase = (int)$apuestaBase;
        if ($apuestaBase <= 0) return ['error' => 'La apuesta debe ser mayor a 0'];

        $factor = ($tipoApuesta === 'UNTX') ? 2 : 1;
        $apuestaFinal = $apuestaBase * $factor;

        if (self::getSaldo($userId, $tipoApuesta, $idPlaneta) < $apuestaFinal) {
            $etiqueta = ['NTX'=>'NTX-20','UNTX'=>'UNTX-20','DEUT'=>'Deuterio','DUST'=>'Materia Oscura'][$tipoApuesta];
            return ['error' => 'No tenés suficiente ' . $etiqueta];
        }

        $activa = $db->selectSingle(
            "SELECT id FROM `{$p}cueva_salas`
             WHERE (id_jugador1 = :uid OR id_jugador2 = :uid)
               AND estado IN ('esperando','jugando') LIMIT 1",
            [':uid' => $userId]
        );
        if ($activa) return ['error' => 'Ya tenés una sala activa. Terminá o cancelá esa primero.'];

        try {
            $db->query("START TRANSACTION");

            if (!self::descontarSaldo($userId, $tipoApuesta, $apuestaFinal, $idPlaneta)) {
                throw new Exception('No se pudo descontar el saldo');
            }

            $ahora = date('Y-m-d H:i:s');
            $expira = date('Y-m-d H:i:s', time() + (self::TIEMPO_EXPIRA_MIN * 60));

            // Insertar Sala (con el campo juego)
            $db->insert(
                "INSERT INTO `{$p}cueva_salas`
                 (id_jugador1, id_planeta_j1, modo, juego, tipo_apuesta,
                  apuesta_base, apuesta_final, pozo, estado,
                  fecha_creacion, fecha_expiracion)
                 VALUES (:j1, :pid, :modo, :juego, :tipo,
                         :ab, :af, :pozo, 'esperando',
                         :ahora, :expira)",
                [
                    ':j1'     => $userId,
                    ':pid'    => $idPlaneta,
                    ':modo'   => $modo,
                    ':juego'  => $juego,
                    ':tipo'   => $tipoApuesta,
                    ':ab'     => $apuestaBase,
                    ':af'     => $apuestaFinal,
                    ':pozo'   => $apuestaFinal * 2,
                    ':ahora'  => $ahora,
                    ':expira' => $expira,
                ]
            );
            $salaId = $db->lastInsertId();

            // Fase inicial corregida para el ENUM
            $faseInicial = 'colocacion';

            $db->insert(
                "INSERT INTO `{$p}cueva_partidas`
                 (id_sala, turno, fase, fecha_turno_inicio, ultima_accion)
                 VALUES (:sid, 1, :fase, :ahora, :ahora)",
                [':sid' => $salaId, ':fase' => $faseInicial, ':ahora' => $ahora]
            );

            self::registrarMovimiento($userId, $salaId, 'apuesta', $tipoApuesta, -$apuestaFinal, $idPlaneta, 'Creación de sala');

            $db->query("COMMIT");
            return ['ok' => true, 'sala_id' => $salaId];
        } catch (Exception $e) {
            $db->query("ROLLBACK");
            return ['error' => 'No se pudo crear la sala: ' . $e->getMessage()];
        }
    }

    public static function aceptarSala($userId, $salaId, $idPlaneta = null, $juego = 'flota')
    {
        $db = self::db(); $p = self::pref();

        if (!in_array($juego, ['flota','ajedrez'])) {
            $juego = 'flota';
        }

        $user = $db->selectSingle(
            "SELECT id, metodo_retiro, ntx20, untx20, darkmatter
             FROM `{$p}users` WHERE id = :uid LIMIT 1",
            [':uid' => $userId]
        );
        if (!$user) return ['error' => 'Usuario inválido'];

        $sala = $db->selectSingle(
            "SELECT * FROM `{$p}cueva_salas`
             WHERE id = :sid AND estado = 'esperando' LIMIT 1",
            [':sid' => $salaId]
        );
        if (!$sala) return ['error' => 'Sala no disponible'];
        if ((int)$sala['id_jugador1'] === (int)$userId) {
            return ['error' => 'No podés aceptar tu propia sala'];
        }

        if (!empty($sala['juego']) && in_array($sala['juego'], ['flota','ajedrez'], true)) {
            $juego = $sala['juego'];
        }

        $riel = self::detectarRiel($user);
        if ($sala['tipo_apuesta'] === 'NTX' && $riel['metodo'] !== 'CUP') {
            return ['error' => 'Esta sala es solo para jugadores CUP'];
        }
        if ($sala['tipo_apuesta'] === 'UNTX' && $riel['metodo'] !== 'QVAPAY') {
            return ['error' => 'Esta sala es solo para jugadores QVAPAY'];
        }
        if ($sala['tipo_apuesta'] === 'DEUT' && !$idPlaneta) {
            return ['error' => 'Debés elegir un planeta para apostar deuterio'];
        }

        if (self::getSaldo($userId, $sala['tipo_apuesta'], $idPlaneta) < (int)$sala['apuesta_final']) {
            $etiqueta = ['NTX'=>'NTX-20','UNTX'=>'UNTX-20','DEUT'=>'Deuterio','DUST'=>'Materia Oscura'][$sala['tipo_apuesta']];
            return ['error' => 'No tenés suficiente ' . $etiqueta];
        }

        try {
            $db->query("START TRANSACTION");
            $ahora = date('Y-m-d H:i:s');

            $stmt = $db->update(
                "UPDATE `{$p}cueva_salas`
                 SET id_jugador2 = :j2, id_planeta_j2 = :pid,
                     estado = 'jugando', fecha_inicio = :ahora
                 WHERE id = :sid AND estado = 'esperando'",
                [':j2' => $userId, ':pid' => $idPlaneta, ':sid' => $salaId, ':ahora' => $ahora]
            );
            if (!self::isUpdateSuccessful($stmt)) throw new Exception('Sala ya tomada por otro jugador');

            if (!self::descontarSaldo($userId, $sala['tipo_apuesta'], (int)$sala['apuesta_final'], $idPlaneta)) {
                throw new Exception('No se pudo descontar el saldo');
            }

            $db->update(
                "UPDATE `{$p}cueva_partidas` 
                 SET fecha_turno_inicio = :ahora, ultima_accion = :ahora 
                 WHERE id_sala = :sid",
                [':sid' => $salaId, ':ahora' => $ahora]
            );

            if ($juego === 'ajedrez') {
                $resAj = self::crearAjedrez($salaId, (int)$sala['id_jugador1'], (int)$userId);
                if (isset($resAj['error'])) {
                    throw new Exception('Error al crear tablero de ajedrez: ' . $resAj['error']);
                }
            }

            self::registrarMovimiento($userId, $salaId, 'apuesta', $sala['tipo_apuesta'], -(int)$sala['apuesta_final'], $idPlaneta, 'Aceptación de sala');

            $db->query("COMMIT");
            return ['ok' => true];
        } catch (Exception $e) {
            $db->query("ROLLBACK");
            return ['error' => $e->getMessage()];
        }
    }

    public static function cancelarSala($userId, $salaId)
    {
        $db = self::db(); $p = self::pref();

        $sala = $db->selectSingle(
            "SELECT * FROM `{$p}cueva_salas`
             WHERE id = :sid AND estado = 'esperando' LIMIT 1",
            [':sid' => $salaId]
        );
        if (!$sala) return ['error' => 'Sala no disponible'];
        if ((int)$sala['id_jugador1'] !== (int)$userId) {
            return ['error' => 'Solo el creador puede cancelar'];
        }

        try {
            $db->query("START TRANSACTION");
            $ahora = date('Y-m-d H:i:s');

            $stmt = $db->update(
                "UPDATE `{$p}cueva_salas`
                 SET estado = 'cancelada', fecha_fin = :ahora
                 WHERE id = :sid AND estado = 'esperando'",
                [':sid' => $salaId, ':ahora' => $ahora]
            );
            if (!self::isUpdateSuccessful($stmt)) throw new Exception('Sala ya no se puede cancelar');

            // BLINDAJE: Si no se puede devolver el saldo, lanzamos excepción para que no se pierda el dinero
            $okRefund = self::acreditarSaldo($userId, $sala['tipo_apuesta'], (int)$sala['apuesta_final'], $sala['id_planeta_j1']);
            if (!$okRefund) {
                throw new Exception('No se pudo devolver el saldo. Intente de nuevo.');
            }

            self::registrarMovimiento($userId, $salaId, 'cancelacion', $sala['tipo_apuesta'], (int)$sala['apuesta_final'], $sala['id_planeta_j1'], 'Cancelación por el creador');

            $db->query("COMMIT");
            return ['ok' => true];
        } catch (Exception $e) {
            $db->query("ROLLBACK");
            return ['error' => $e->getMessage()];
        }
    }

    public static function cancelarPartidaPorTimeout($salaId)
    {
        $db = self::db(); $p = self::pref();
        
        try {
            $db->query("START TRANSACTION");
            
            $sala = $db->selectSingle(
                "SELECT * FROM `{$p}cueva_salas` 
                 WHERE id = :sid AND estado = 'jugando' FOR UPDATE",
                [':sid' => $salaId]
            );
            
            if (!$sala) throw new Exception('Sala no jugable');
            
            $ahora = date('Y-m-d H:i:s');

            $db->update(
                "UPDATE `{$p}cueva_salas`
                 SET estado = 'cancelada', fecha_fin = :ahora
                 WHERE id = :sid",
                [':sid' => $salaId, ':ahora' => $ahora]
            );

            $db->update(
                "UPDATE `{$p}cueva_partidas`
                 SET fase = 'fin', ultima_accion = :ahora
                 WHERE id_sala = :sid",
                [':sid' => $salaId, ':ahora' => $ahora]
            );
            
            if ($sala['id_jugador1']) {
                $ok1 = self::acreditarSaldo($sala['id_jugador1'], $sala['tipo_apuesta'], (int)$sala['apuesta_final'], $sala['id_planeta_j1']);
                if (!$ok1) throw new Exception('No se pudo devolver saldo al J1');
                self::registrarMovimiento($sala['id_jugador1'], $salaId, 'devolucion', $sala['tipo_apuesta'], (int)$sala['apuesta_final'], $sala['id_planeta_j1'], 'Timeout en colocación');
            }
            
            if ($sala['id_jugador2']) {
                $ok2 = self::acreditarSaldo($sala['id_jugador2'], $sala['tipo_apuesta'], (int)$sala['apuesta_final'], $sala['id_planeta_j2']);
                if (!$ok2) throw new Exception('No se pudo devolver saldo al J2');
                self::registrarMovimiento($sala['id_jugador2'], $salaId, 'devolucion', $sala['tipo_apuesta'], (int)$sala['apuesta_final'], $sala['id_planeta_j2'], 'Timeout en colocación');
            }
            
            $db->query("COMMIT");
            return ['ok' => true];
        } catch (Exception $e) {
            $db->query("ROLLBACK");
            return ['error' => $e->getMessage()];
        }
    }

    public static function verificarTimeouts($salaId)
    {
        $db = self::db(); $p = self::pref();
        
        $partida = $db->selectSingle(
            "SELECT p.*, s.estado, s.id_jugador1, s.id_jugador2, s.fecha_inicio, s.juego 
             FROM `{$p}cueva_partidas` p
             INNER JOIN `{$p}cueva_salas` s ON s.id = p.id_sala
             WHERE p.id_sala = :sid LIMIT 1",
            [':sid' => $salaId]
        );
        
        // Si es ajedrez, no procesar aquí (lo hace verificarTimeoutAjedrez)
        if (!$partida || $partida['estado'] !== 'jugando' || $partida['juego'] === 'ajedrez') return false;
        
        if ($partida['fase'] === 'colocacion') {
            if (empty($partida['fecha_inicio']) || strtotime($partida['fecha_inicio']) === false) {
                $ahora = date('Y-m-d H:i:s');
                $db->update(
                    "UPDATE `{$p}cueva_salas` SET fecha_inicio = :ahora WHERE id = :sid",
                    [':sid' => $salaId, ':ahora' => $ahora]
                );
                return false;
            }

            $tiempoTranscurrido = time() - strtotime($partida['fecha_inicio']);
            if ($tiempoTranscurrido < 0) $tiempoTranscurrido = 0;

            if ($tiempoTranscurrido > self::TIEMPO_COLOCACION_SEG) {
                self::cancelarPartidaPorTimeout($salaId);
                return true;
            }
        }
        
        if ($partida['fase'] === 'disparos') {
            if (empty($partida['fecha_turno_inicio']) || strtotime($partida['fecha_turno_inicio']) === false) {
                $ahora = date('Y-m-d H:i:s');
                $db->update(
                    "UPDATE `{$p}cueva_partidas` SET fecha_turno_inicio = :ahora WHERE id = :pid",
                    [':pid' => $partida['id'], ':ahora' => $ahora]
                );
                return false;
            }

            $tiempoTranscurrido = time() - strtotime($partida['fecha_turno_inicio']);
            if ($tiempoTranscurrido < 0) $tiempoTranscurrido = 0;

            if ($tiempoTranscurrido > self::TIEMPO_TURNO_SEG) {
                $ganadorId = ($partida['turno'] == 1) ? $partida['id_jugador2'] : $partida['id_jugador1'];
                self::finalizarPartida($salaId, $ganadorId);
                return true;
            }
        }
        
        return false;
    }

    public static function expirarSalas()
    {
        $db = self::db(); $p = self::pref();

        $salas = $db->select(
            "SELECT * FROM `{$p}cueva_salas`
             WHERE estado = 'esperando' AND fecha_expiracion <= NOW()"
        );
        if (!$salas) return 0;

        $count = 0;
        foreach ($salas as $sala) {
            try {
                $db->query("START TRANSACTION");
                $ahora = date('Y-m-d H:i:s');
                
                $stmt = $db->update(
                    "UPDATE `{$p}cueva_salas`
                     SET estado = 'expirada', fecha_fin = :ahora
                     WHERE id = :sid AND estado = 'esperando'",
                    [':sid' => $sala['id'], ':ahora' => $ahora]
                );
                if (self::isUpdateSuccessful($stmt)) {
                    $okRefund = self::acreditarSaldo($sala['id_jugador1'], $sala['tipo_apuesta'], (int)$sala['apuesta_final'], $sala['id_planeta_j1']);
                    if (!$okRefund) {
                        throw new Exception('No se pudo devolver el saldo en expiración');
                    }
                    self::registrarMovimiento($sala['id_jugador1'], $sala['id'], 'devolucion', $sala['tipo_apuesta'], (int)$sala['apuesta_final'], $sala['id_planeta_j1'], 'Expiración de sala');
                    $count++;
                }
                $db->query("COMMIT");
            } catch (Exception $e) {
                $db->query("ROLLBACK");
            }
        }
        return $count;
    }

    public static function colocarFlota($salaId, $userId, array $naves)
    {
        $db = self::db(); $p = self::pref();

        $salaId = (int)$salaId;

        self::verificarTimeouts($salaId);

        $partida = $db->selectSingle(
            "SELECT p.id AS id_partida, p.fase, s.estado, s.id_jugador1, s.id_jugador2
             FROM `{$p}cueva_partidas` p
             INNER JOIN `{$p}cueva_salas` s ON s.id = p.id_sala
             WHERE p.id_sala = :sid LIMIT 1",
            [':sid' => $salaId]
        );
        if (!$partida) return ['error' => 'Partida no encontrada'];
        if ($partida['estado'] !== 'jugando') return ['error' => 'La partida ha finalizado o fue cancelada'];
        if ($partida['fase'] !== 'colocacion') return ['error' => 'Ya no estás en fase de colocación'];

        $idPartida = (int)$partida['id_partida'];
        $userId = (int)$userId;

        $esJ1 = ((int)$partida['id_jugador1'] === $userId);
        $esJ2 = ((int)$partida['id_jugador2'] === $userId);
        if (!$esJ1 && !$esJ2) return ['error' => 'No participás en esta partida'];

        $porTipo = ['grande'=>0, 'mediana'=>0, 'pequena'=>0];
        $coords = [];
        foreach ($naves as $n) {
            if (!in_array($n['tipo'], ['grande','mediana','pequena'])) return ['error' => 'Tipo de nave inválido'];
            $porTipo[$n['tipo']] += count($n['casillas']);
            foreach ($n['casillas'] as $c) {
                if (!preg_match('/^[A-J](10|[1-9])$/', $c)) return ['error' => 'Coordenada inválida: '.$c];
                $coords[] = $c;
            }
        }
        if ($porTipo['grande']  !== 6)  return ['error' => 'La nave grande debe ocupar 6 casillas'];
        if ($porTipo['mediana'] !== 8)  return ['error' => 'Las 2 naves medianas deben ocupar 8 casillas'];
        if ($porTipo['pequena'] !== 6)  return ['error' => 'Las 3 naves pequeñas deben ocupar 6 casillas'];
        if (count(array_unique($coords)) !== 20) return ['error' => 'Hay coordenadas duplicadas'];

        try {
            $db->query("START TRANSACTION");

            $db->query(
                "DELETE FROM `{$p}cueva_flota` WHERE id_partida = " . $idPartida . " AND id_jugador = " . $userId
            );

            foreach ($naves as $n) {
                foreach ($n['casillas'] as $c) {
                    $db->insert(
                        "INSERT INTO `{$p}cueva_flota`
                         (id_partida, id_jugador, tipo_nave, coordenada, impactada)
                         VALUES (:pid, :uid, :tipo, :coord, 0)",
                        [':pid' => $idPartida, ':uid' => $userId, ':tipo' => $n['tipo'], ':coord' => $c]
                    );
                }
            }

            $colOk = $esJ1 ? 'colocacion_j1_ok' : 'colocacion_j2_ok';
            $db->update(
                "UPDATE `{$p}cueva_partidas` SET `{$colOk}` = 1 WHERE id = :pid",
                [':pid' => $idPartida]
            );

            $p2 = $db->selectSingle(
                "SELECT colocacion_j1_ok, colocacion_j2_ok FROM `{$p}cueva_partidas` WHERE id = :pid",
                [':pid' => $idPartida]
            );
            if ($p2['colocacion_j1_ok'] && $p2['colocacion_j2_ok']) {
                $ahora = date('Y-m-d H:i:s');
                $db->update(
                    "UPDATE `{$p}cueva_partidas`
                     SET fase = 'disparos', turno = 1,
                         fecha_turno_inicio = :ahora, ultima_accion = :ahora
                     WHERE id = :pid",
                    [':pid' => $idPartida, ':ahora' => $ahora]
                );
            }

            $db->query("COMMIT");
            return ['ok' => true];
        } catch (Exception $e) {
            $db->query("ROLLBACK");
            return ['error' => 'Error al guardar flota: ' . $e->getMessage()];
        }
    }

    public static function disparar($salaId, $userId, $coordenada)
    {
        $db = self::db(); $p = self::pref();

        $salaId = (int)$salaId;

        if (!preg_match('/^[A-J](10|[1-9])$/', $coordenada)) {
            return ['error' => 'Coordenada inválida'];
        }

        self::verificarTimeouts($salaId);

        $partida = $db->selectSingle(
            "SELECT p.*, s.estado, s.id_jugador1, s.id_jugador2
             FROM `{$p}cueva_partidas` p
             INNER JOIN `{$p}cueva_salas` s ON s.id = p.id_sala
             WHERE p.id_sala = :sid LIMIT 1",
            [':sid' => $salaId]
        );
        if (!$partida) return ['error' => 'Partida no encontrada'];
        if ($partida['estado'] !== 'jugando') return ['error' => 'La partida ha finalizado o fue cancelada'];
        if ($partida['fase'] !== 'disparos') return ['error' => 'La partida no está en fase de disparos'];

        $idPartida = (int)$partida['id'];

        $esJ1 = ((int)$partida['id_jugador1'] === (int)$userId);
        $esJ2 = ((int)$partida['id_jugador2'] === (int)$userId);
        if (!$esJ1 && !$esJ2) return ['error' => 'No participás en esta partida'];

        $turnoActual = (int)$partida['turno'];
        $miTurno = ($esJ1 && $turnoActual === 1) || ($esJ2 && $turnoActual === 2);
        if (!$miTurno) return ['error' => 'No es tu turno'];

        $rivalId = $esJ1 ? (int)$partida['id_jugador2'] : (int)$partida['id_jugador1'];

        $yaDisparo = $db->selectSingle(
            "SELECT id FROM `{$p}cueva_disparos`
             WHERE id_partida = :pid AND id_jugador = :uid AND coordenada = :c LIMIT 1",
            [':pid' => $idPartida, ':uid' => $userId, ':c' => $coordenada]
        );
        if ($yaDisparo) return ['error' => 'Ya disparaste a esa casilla'];

        try {
            $db->query("START TRANSACTION");
            $ahora = date('Y-m-d H:i:s');

            $nave = $db->selectSingle(
                "SELECT id, tipo_nave FROM `{$p}cueva_flota`
                 WHERE id_partida = :pid AND id_jugador = :rival
                   AND coordenada = :c AND impactada = 0 LIMIT 1",
                [':pid' => $idPartida, ':rival' => $rivalId, ':c' => $coordenada]
            );

            if (!$nave) {
                $resultado = 'agua';
                $db->update(
                    "UPDATE `{$p}cueva_partidas`
                     SET turno = :rival, turnos_perdidos_j1 = 0, turnos_perdidos_j2 = 0,
                         fecha_turno_inicio = :ahora, ultima_accion = :ahora
                     WHERE id = :pid",
                    [':rival' => $esJ1 ? 2 : 1, ':pid' => $idPartida, ':ahora' => $ahora]
                );
            } else {
                $db->update(
                    "UPDATE `{$p}cueva_flota` SET impactada = 1 WHERE id = :fid",
                    [':fid' => $nave['id']]
                );

                $colImpacto = $esJ1 ? 'impactos_j2' : 'impactos_j1';
                $db->update(
                    "UPDATE `{$p}cueva_partidas`
                     SET `{$colImpacto}` = `{$colImpacto}` + 1,
                         turnos_perdidos_j1 = 0, turnos_perdidos_j2 = 0,
                         fecha_turno_inicio = :ahora, ultima_accion = :ahora
                     WHERE id = :pid",
                    [':pid' => $idPartida, ':ahora' => $ahora]
                );

                $intactas = $db->selectSingle(
                    "SELECT COUNT(*) AS n FROM `{$p}cueva_flota`
                     WHERE id_partida = :pid AND id_jugador = :rival
                       AND tipo_nave = :tipo AND impactada = 0",
                    [':pid' => $idPartida, ':rival' => $rivalId, ':tipo' => $nave['tipo_nave']]
                );
                $resultado = ((int)$intactas['n'] === 0) ? 'hundido' : 'tocado';
            }

            $db->insert(
                "INSERT INTO `{$p}cueva_disparos`
                 (id_partida, id_jugador, coordenada, resultado, fecha)
                 VALUES (:pid, :uid, :c, :r, :ahora)",
                [':pid' => $idPartida, ':uid' => $userId, ':c' => $coordenada, ':r' => $resultado, ':ahora' => $ahora]
            );

            $p2 = $db->selectSingle(
                "SELECT impactos_j1, impactos_j2 FROM `{$p}cueva_partidas` WHERE id = :pid",
                [':pid' => $idPartida]
            );
            $victoria = false;
            if ($esJ1 && (int)$p2['impactos_j2'] >= 20) $victoria = true;
            if ($esJ2 && (int)$p2['impactos_j1'] >= 20) $victoria = true;

            if ($victoria) {
                $db->update(
                    "UPDATE `{$p}cueva_partidas` SET fase = 'fin', ultima_accion = :ahora WHERE id = :pid",
                    [':pid' => $idPartida, ':ahora' => $ahora]
                );
            }

            $db->query("COMMIT");

            if ($victoria) {
                self::finalizarPartida($salaId, $userId);
            }

            return [
                'ok'          => true,
                'resultado'   => $resultado,
                'victoria'    => $victoria,
                'coordenada'  => $coordenada,
                'turno'       => $victoria ? null : ($resultado === 'agua' ? ($esJ1 ? 2 : 1) : $turnoActual),
            ];
        } catch (Exception $e) {
            $db->query("ROLLBACK");
            return ['error' => 'Error al disparar: ' . $e->getMessage()];
        }
    }

    public static function finalizarPartida($salaId, $ganadorId)
    {
        $db = self::db(); $p = self::pref();

        $salaId = (int)$salaId;

        try {
            $db->query("START TRANSACTION");
            $ahora = date('Y-m-d H:i:s');

            $sala = $db->selectSingle(
                "SELECT * FROM `{$p}cueva_salas`
                 WHERE id = :sid AND estado = 'jugando' FOR UPDATE",
                [':sid' => $salaId]
            );
            if (!$sala) throw new Exception('Sala no jugable');

            $pozo = (int)$sala['pozo'];
            $idPlanetaGanador = ((int)$sala['id_jugador1'] === (int)$ganadorId)
                ? $sala['id_planeta_j1'] : $sala['id_planeta_j2'];

            $okGanador = self::acreditarSaldo($ganadorId, $sala['tipo_apuesta'], $pozo, $idPlanetaGanador);
            if (!$okGanador) throw new Exception('No se pudo acreditar el pozo al ganador');

            $db->update(
                "UPDATE `{$p}cueva_salas`
                 SET estado = 'finalizada', id_ganador = :g, fecha_fin = :ahora
                 WHERE id = :sid",
                [':g' => $ganadorId, ':sid' => $salaId, ':ahora' => $ahora]
            );

            $db->update(
                "UPDATE `{$p}cueva_partidas`
                 SET fase = 'fin', ultima_accion = :ahora
                 WHERE id_sala = :sid",
                [':sid' => $salaId, ':ahora' => $ahora]
            );

            $esAjedrez = $db->selectSingle(
                "SELECT id FROM `{$p}cueva_ajedrez` WHERE id_sala = :sid LIMIT 1",
                [':sid' => $salaId]
            );
            $msgVictoria = $esAjedrez ? 'Victoria Ajedrez' : 'Victoria Hundir la Flota';

            self::registrarMovimiento($ganadorId, $salaId, 'pozo_ganado', $sala['tipo_apuesta'], $pozo, $idPlanetaGanador, $msgVictoria);

            $db->query("COMMIT");
            return ['ok' => true, 'pozo' => $pozo];
        } catch (Exception $e) {
            $db->query("ROLLBACK");
            return ['error' => $e->getMessage()];
        }
    }

    public static function listarSalas($userId, $metodoRetiro, $juego = 'flota')
    {
        $db = self::db(); $p = self::pref();

        if (!in_array($juego, ['flota', 'ajedrez'], true)) {
            $juego = 'flota';
        }

        $riel = self::detectarRiel(['metodo_retiro' => $metodoRetiro]);

        $salas = $db->select(
            "SELECT s.*, u.username AS creador
             FROM `{$p}cueva_salas` s
             INNER JOIN `{$p}users` u ON u.id = s.id_jugador1
             WHERE s.estado = 'esperando'
               AND s.juego = :juego
               AND s.id_jugador1 <> :uid
               AND u.onlinetime >= (UNIX_TIMESTAMP() - 300)
               AND (s.modo = 'lobby'
                    OR (s.modo = 'busqueda_rapida'
                        AND s.fecha_creacion <= DATE_SUB(NOW(), INTERVAL 5 MINUTE)))
             ORDER BY s.fecha_creacion DESC LIMIT 30",
            [':uid' => $userId, ':juego' => $juego]
        );

        $resultado = [];
        foreach ($salas ?: [] as $s) {
            $compatible = false;
            if ($s['tipo_apuesta'] === 'DEUT' || $s['tipo_apuesta'] === 'DUST') $compatible = true;
            if ($s['tipo_apuesta'] === 'NTX'  && $riel['metodo'] === 'CUP')     $compatible = true;
            if ($s['tipo_apuesta'] === 'UNTX' && $riel['metodo'] === 'QVAPAY')  $compatible = true;

            $s['compatible'] = $compatible;
            $s['moneda_label'] = [
                'NTX'  => 'NTX-20',
                'UNTX' => 'UNTX-20',
                'DEUT' => 'Deuterio',
                'DUST' => 'Materia Oscura',
            ][$s['tipo_apuesta']];

            $resultado[] = $s;
        }
        return $resultado;
    }

    // ============================================================
    // ============== AJEDREZ - NUEVAS FUNCIONES ==================
    // ============================================================

    private static function getTurnoDesdeFen($fen)
    {
        if (empty($fen) || !is_string($fen)) return null;
        $parts = explode(' ', trim($fen));
        if (count($parts) < 2) return null;
        $turno = $parts[1];
        return ($turno === 'w' || $turno === 'b') ? $turno : null;
    }

    public static function crearAjedrez($salaId, $jugadorBlancas, $jugadorNegras)
    {
        $db = self::db(); $p = self::pref();

        $salaId         = (int)$salaId;
        $jugadorBlancas = (int)$jugadorBlancas;
        $jugadorNegras  = (int)$jugadorNegras;

        if ($salaId <= 0 || $jugadorBlancas <= 0 || $jugadorNegras <= 0) {
            return ['error' => 'Datos inválidos para crear partida de ajedrez'];
        }
        if ($jugadorBlancas === $jugadorNegras) {
            return ['error' => 'Los jugadores no pueden ser el mismo'];
        }

        $existe = $db->selectSingle(
            "SELECT id FROM `{$p}cueva_ajedrez` WHERE id_sala = :sid LIMIT 1",
            [':sid' => $salaId]
        );
        if ($existe) return ['error' => 'La partida de ajedrez ya existe'];

        $ahora = date('Y-m-d H:i:s');

        try {
            $db->insert(
                "INSERT INTO `{$p}cueva_ajedrez`
                 (id_sala, jugador_blancas, jugador_negras, fen, historial,
                  turno, estado, fecha_inicio, fecha_actualizacion)
                 VALUES (:sid, :jb, :jn, :fen, NULL,
                         'w', 'jugando', :ahora, :ahora)",
                [
                    ':sid'   => $salaId,
                    ':jb'    => $jugadorBlancas,
                    ':jn'    => $jugadorNegras,
                    ':fen'   => self::FEN_INICIAL,
                    ':ahora' => $ahora,
                ]
            );
            return ['ok' => true];
        } catch (Exception $e) {
            return ['error' => 'Error al crear ajedrez: ' . $e->getMessage()];
        }
    }

    public static function guardarMovimientoAjedrez($salaId, $jugadorId, $nuevoFen, $nuevoHistorial = null, $estado = 'jugando', $ganador = null, $motivo = null)
    {
        $db = self::db(); $p = self::pref();

        $salaId    = (int)$salaId;
        $jugadorId = (int)$jugadorId;

        if ($salaId <= 0 || $jugadorId <= 0) {
            return ['error' => 'Datos inválidos'];
        }

        $aj = $db->selectSingle(
            "SELECT * FROM `{$p}cueva_ajedrez` WHERE id_sala = :sid LIMIT 1",
            [':sid' => $salaId]
        );
        if (!$aj)                          return ['error' => 'Partida de ajedrez no encontrada'];
        if ($aj['estado'] !== 'jugando')   return ['error' => 'La partida ya terminó'];

        $sala = $db->selectSingle(
            "SELECT * FROM `{$p}cueva_salas` WHERE id = :sid LIMIT 1",
            [':sid' => $salaId]
        );
        if (!$sala || $sala['estado'] !== 'jugando') {
            return ['error' => 'Sala no jugable'];
        }

        $esBlancas = ((int)$aj['jugador_blancas'] === $jugadorId);
        $esNegras  = ((int)$aj['jugador_negras']  === $jugadorId);
        if (!$esBlancas && !$esNegras) {
            return ['error' => 'No participás en esta partida'];
        }
        if (($esBlancas && $aj['turno'] !== 'w') || ($esNegras && $aj['turno'] !== 'b')) {
            return ['error' => 'No es tu turno'];
        }

        $fen = trim((string)$nuevoFen);
        $fenParts = explode(' ', $fen);
        if (count($fenParts) < 6) {
            return ['error' => 'FEN inválido (formato)'];
        }
        $nuevoTurno = self::getTurnoDesdeFen($fen);
        if (!$nuevoTurno) {
            return ['error' => 'FEN inválido (turno)'];
        }

        $estadosValidos = ['jugando','jaque_mate','tablas','ahogado','rendicion','timeout','cancelada'];
        if (!in_array($estado, $estadosValidos, true)) {
            $estado = 'jugando';
        }

        if ($estado === 'jugando' && $nuevoTurno === $aj['turno']) {
            return ['error' => 'El turno no ha cambiado'];
        }

        if ($ganador !== null) {
            $ganador = (int)$ganador;
            if ($ganador !== (int)$aj['jugador_blancas'] && $ganador !== (int)$aj['jugador_negras']) {
                return ['error' => 'Ganador inválido'];
            }
        }

        try {
            $db->query("START TRANSACTION");
            $ahora = date('Y-m-d H:i:s');

            $stmt = $db->update(
                "UPDATE `{$p}cueva_ajedrez`
                 SET fen = :fen, historial = :hist, turno = :turno,
                     estado = :estado, ganador = :g, motivo_fin = :motivo,
                     fecha_actualizacion = :ahora
                 WHERE id_sala = :sid AND estado = 'jugando'",
                [
                    ':fen'    => $fen,
                    ':hist'   => $nuevoHistorial,
                    ':turno'  => $nuevoTurno,
                    ':estado' => $estado,
                    ':g'      => $ganador,
                    ':motivo' => $motivo,
                    ':ahora'  => $ahora,
                    ':sid'    => $salaId,
                ]
            );
            if (!self::isUpdateSuccessful($stmt)) {
                throw new Exception('No se pudo actualizar el tablero (posible race condition)');
            }

            $db->update(
                "UPDATE `{$p}cueva_partidas` SET ultima_accion = :ahora WHERE id_sala = :sid",
                [':sid' => $salaId, ':ahora' => $ahora]
            );

            $db->query("COMMIT");
        } catch (Exception $e) {
            $db->query("ROLLBACK");
            return ['error' => 'Error al guardar movimiento: ' . $e->getMessage()];
        }

        if ($estado !== 'jugando') {
            if ($ganador === null) {
                self::finalizarAjedrezEmpate($salaId, $motivo ?: $estado);
            } else {
                $resFin = self::finalizarPartida($salaId, $ganador);
                if (isset($resFin['error'])) {
                    error_log('[CuevaHelper] finalizarPartida (ajedrez) error: ' . $resFin['error']);
                }
            }
        }

        return [
            'ok'     => true,
            'estado' => $estado,
            'turno'  => $nuevoTurno,
            'fen'    => $fen,
        ];
    }

    public static function verificarTimeoutAjedrez($salaId)
    {
        $db = self::db(); $p = self::pref();

        $salaId = (int)$salaId;

        $aj = $db->selectSingle(
            "SELECT a.*, s.estado AS sala_estado
             FROM `{$p}cueva_ajedrez` a
             INNER JOIN `{$p}cueva_salas` s ON s.id = a.id_sala
             WHERE a.id_sala = :sid LIMIT 1",
            [':sid' => $salaId]
        );
        if (!$aj) return false;
        if ($aj['estado'] !== 'jugando' || $aj['sala_estado'] !== 'jugando') return false;
        if (empty($aj['fecha_actualizacion']) || strtotime($aj['fecha_actualizacion']) === false) return false;

        $tiempoTranscurrido = time() - strtotime($aj['fecha_actualizacion']);
        if ($tiempoTranscurrido < 0) $tiempoTranscurrido = 0;

        if ($tiempoTranscurrido <= self::TIEMPO_TURNO_SEG) return false;

        $ganadorId = ($aj['turno'] === 'w') ? (int)$aj['jugador_negras'] : (int)$aj['jugador_blancas'];
        if ($ganadorId <= 0) return false;

        $ahora = date('Y-m-d H:i:s');

        $db->update(
            "UPDATE `{$p}cueva_ajedrez`
             SET estado = 'timeout', ganador = :g, motivo_fin = 'Timeout de turno',
                 fecha_actualizacion = :ahora
             WHERE id_sala = :sid AND estado = 'jugando'",
            [':g' => $ganadorId, ':ahora' => $ahora, ':sid' => $salaId]
        );

        $resFin = self::finalizarPartida($salaId, $ganadorId);
        if (isset($resFin['error'])) {
            error_log('[CuevaHelper] verificarTimeoutAjedrez finalizarPartida error: ' . $resFin['error']);
        }

        return true;
    }

    public static function finalizarAjedrezEmpate($salaId, $motivo = 'Tablas')
    {
        $db = self::db(); $p = self::pref();

        $salaId = (int)$salaId;

        try {
            $db->query("START TRANSACTION");
            $ahora = date('Y-m-d H:i:s');

            $sala = $db->selectSingle(
                "SELECT * FROM `{$p}cueva_salas`
                 WHERE id = :sid AND estado = 'jugando' FOR UPDATE",
                [':sid' => $salaId]
            );
            if (!$sala) throw new Exception('Sala no jugable');

            if (!empty($sala['id_jugador1'])) {
                $ok1 = self::acreditarSaldo($sala['id_jugador1'], $sala['tipo_apuesta'], (int)$sala['apuesta_final'], $sala['id_planeta_j1']);
                if (!$ok1) throw new Exception('No se pudo devolver saldo al J1');
                self::registrarMovimiento($sala['id_jugador1'], $salaId, 'devolucion', $sala['tipo_apuesta'], (int)$sala['apuesta_final'], $sala['id_planeta_j1'], 'Empate Ajedrez: ' . $motivo);
            }
            if (!empty($sala['id_jugador2'])) {
                $ok2 = self::acreditarSaldo($sala['id_jugador2'], $sala['tipo_apuesta'], (int)$sala['apuesta_final'], $sala['id_planeta_j2']);
                if (!$ok2) throw new Exception('No se pudo devolver saldo al J2');
                self::registrarMovimiento($sala['id_jugador2'], $salaId, 'devolucion', $sala['tipo_apuesta'], (int)$sala['apuesta_final'], $sala['id_planeta_j2'], 'Empate Ajedrez: ' . $motivo);
            }

            $db->update(
                "UPDATE `{$p}cueva_salas`
                 SET estado = 'finalizada', id_ganador = NULL, fecha_fin = :ahora
                 WHERE id = :sid",
                [':sid' => $salaId, ':ahora' => $ahora]
            );

            $db->update(
                "UPDATE `{$p}cueva_partidas`
                 SET fase = 'fin', ultima_accion = :ahora
                 WHERE id_sala = :sid",
                [':sid' => $salaId, ':ahora' => $ahora]
            );

            $db->query("COMMIT");
            return ['ok' => true];
        } catch (Exception $e) {
            $db->query("ROLLBACK");
            return ['error' => $e->getMessage()];
        }
    }
}