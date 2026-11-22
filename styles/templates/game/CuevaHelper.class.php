<?php
/**
 * La Cueva Pirata - Hundir la Flota
 * Helper central: toda la lógica de negocio en un solo lugar.
 */

if (!defined('MODE')) { die('Hacking attempt'); }

class CuevaHelper
{
    const PREFIJO_DEFAULT    = 'uni1_';
    const TIEMPO_EXPIRA_MIN  = 30;
    const TIEMPO_BUSQUEDA_SEG = 300;
    const TIEMPO_COLOCACION_SEG = 120; // 2 minutos para colocar flota
    const TIEMPO_TURNO_SEG   = 60;     // 1 minuto por disparo
    const MAX_TURNOS_PERDIDOS = 3;

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
                $db->update(
                    "UPDATE `{$p}users` SET `{$col}` = `{$col}` + :c WHERE id = :uid",
                    [':c' => $cantidad, ':uid' => $userId]
                );
                return true;

            case 'DUST':
                $db->update(
                    "UPDATE `{$p}users` SET darkmatter = darkmatter + :c WHERE id = :uid",
                    [':c' => $cantidad, ':uid' => $userId]
                );
                return true;

            case 'DEUT':
                if (!$idPlaneta) return false;
                $db->update(
                    "UPDATE `{$p}planets` SET deuterium = deuterium + :c WHERE id = :pid AND id_owner = :uid",
                    [':c' => $cantidad, ':pid' => $idPlaneta, ':uid' => $userId]
                );
                return true;
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

    public static function crearSala($userId, $tipoApuesta, $apuestaBase, $idPlaneta = null, $modo = 'lobby')
    {
        $db = self::db(); $p = self::pref();

        if (!in_array($tipoApuesta, ['NTX','UNTX','DEUT','DUST'])) {
            return ['error' => 'Tipo de apuesta inválido'];
        }

        if (!in_array($modo, ['lobby','busqueda_rapida'])) {
            $modo = 'lobby';
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

            // CORRECCIÓN: Usamos la fecha de PHP para evitar desfases horarios
            $ahora = date('Y-m-d H:i:s');
            $expira = date('Y-m-d H:i:s', time() + (self::TIEMPO_EXPIRA_MIN * 60));

            $db->insert(
                "INSERT INTO `{$p}cueva_salas`
                 (id_jugador1, id_planeta_j1, modo, tipo_apuesta,
                  apuesta_base, apuesta_final, pozo, estado,
                  fecha_creacion, fecha_expiracion)
                 VALUES (:j1, :pid, :modo, :tipo,
                         :ab, :af, :pozo, 'esperando',
                         :ahora, :expira)",
                [
                    ':j1'     => $userId,
                    ':pid'    => $idPlaneta,
                    ':modo'   => $modo,
                    ':tipo'   => $tipoApuesta,
                    ':ab'     => $apuestaBase,
                    ':af'     => $apuestaFinal,
                    ':pozo'   => $apuestaFinal * 2,
                    ':ahora'  => $ahora,
                    ':expira' => $expira,
                ]
            );
            $salaId = $db->lastInsertId();

            $db->insert(
                "INSERT INTO `{$p}cueva_partidas`
                 (id_sala, turno, fase, fecha_turno_inicio, ultima_accion)
                 VALUES (:sid, 1, 'colocacion', :ahora, :ahora)",
                [':sid' => $salaId, ':ahora' => $ahora]
            );

            self::registrarMovimiento($userId, $salaId, 'apuesta', $tipoApuesta, -$apuestaFinal, $idPlaneta, 'Creación de sala');

            $db->query("COMMIT");
            return ['ok' => true, 'sala_id' => $salaId];
        } catch (Exception $e) {
            $db->query("ROLLBACK");
            return ['error' => 'No se pudo crear la sala: ' . $e->getMessage()];
        }
    }

    public static function aceptarSala($userId, $salaId, $idPlaneta = null)
    {
        $db = self::db(); $p = self::pref();

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
            
            // CORRECCIÓN: Usamos la fecha de PHP para evitar desfases
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

            // Iniciar el reloj de colocación de 2 minutos
            $db->update(
                "UPDATE `{$p}cueva_partidas` 
                 SET fecha_turno_inicio = :ahora, ultima_accion = :ahora 
                 WHERE id_sala = :sid",
                [':sid' => $salaId, ':ahora' => $ahora]
            );

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

            self::acreditarSaldo($userId, $sala['tipo_apuesta'], (int)$sala['apuesta_final'], $sala['id_planeta_j1']);
            self::registrarMovimiento($userId, $salaId, 'cancelacion', $sala['tipo_apuesta'], (int)$sala['apuesta_final'], $sala['id_planeta_j1'], 'Cancelación por el creador');

            $db->query("COMMIT");
            return ['ok' => true];
        } catch (Exception $e) {
            $db->query("ROLLBACK");
            return ['error' => $e->getMessage()];
        }
    }

    // FUNCIÓN: Cancelar por inactividad en fase de colocación
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
            
            // Devolver dinero al J1
            if ($sala['id_jugador1']) {
                self::acreditarSaldo($sala['id_jugador1'], $sala['tipo_apuesta'], (int)$sala['apuesta_final'], $sala['id_planeta_j1']);
                self::registrarMovimiento($sala['id_jugador1'], $salaId, 'devolucion', $sala['tipo_apuesta'], (int)$sala['apuesta_final'], $sala['id_planeta_j1'], 'Timeout en colocación');
            }
            
            // Devolver dinero al J2
            if ($sala['id_jugador2']) {
                self::acreditarSaldo($sala['id_jugador2'], $sala['tipo_apuesta'], (int)$sala['apuesta_final'], $sala['id_planeta_j2']);
                self::registrarMovimiento($sala['id_jugador2'], $salaId, 'devolucion', $sala['tipo_apuesta'], (int)$sala['apuesta_final'], $sala['id_planeta_j2'], 'Timeout en colocación');
            }
            
            $db->query("COMMIT");
            return ['ok' => true];
        } catch (Exception $e) {
            $db->query("ROLLBACK");
            return ['error' => $e->getMessage()];
        }
    }

    // FUNCIÓN: Verificar si el tiempo de colocación o de turno expiró
    public static function verificarTimeouts($salaId)
    {
        $db = self::db(); $p = self::pref();
        
        $partida = $db->selectSingle(
            "SELECT p.*, s.estado, s.id_jugador1, s.id_jugador2, s.fecha_inicio 
             FROM `{$p}cueva_partidas` p
             INNER JOIN `{$p}cueva_salas` s ON s.id = p.id_sala
             WHERE p.id_sala = :sid LIMIT 1",
            [':sid' => $salaId]
        );
        
        if (!$partida || $partida['estado'] !== 'jugando') return false;
        
        // 1. Verificar Fase de Colocación (2 minutos)
        if ($partida['fase'] === 'colocacion') {
            // Si la fecha de inicio está vacía, la reiniciamos
            if (empty($partida['fecha_inicio']) || strtotime($partida['fecha_inicio']) === false) {
                $ahora = date('Y-m-d H:i:s');
                $db->update(
                    "UPDATE `{$p}cueva_salas` SET fecha_inicio = :ahora WHERE id = :sid",
                    [':sid' => $salaId, ':ahora' => $ahora]
                );
                return false;
            }

            $tiempoTranscurrido = time() - strtotime($partida['fecha_inicio']);
            // BLINDAJE EXTRA: Si por algún motivo el tiempo es negativo, lo forzamos a 0
            if ($tiempoTranscurrido < 0) $tiempoTranscurrido = 0;

            if ($tiempoTranscurrido > self::TIEMPO_COLOCACION_SEG) {
                self::cancelarPartidaPorTimeout($salaId);
                return true;
            }
        }
        
        // 2. Verificar Fase de Disparos (1 minuto por turno)
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
                // El jugador en turno pierde por inactividad
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
                    self::acreditarSaldo($sala['id_jugador1'], $sala['tipo_apuesta'], (int)$sala['apuesta_final'], $sala['id_planeta_j1']);
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

            self::acreditarSaldo($ganadorId, $sala['tipo_apuesta'], $pozo, $idPlanetaGanador);

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

            self::registrarMovimiento($ganadorId, $salaId, 'pozo_ganado', $sala['tipo_apuesta'], $pozo, $idPlanetaGanador, 'Victoria Hundir la Flota');

            $db->query("COMMIT");
            return ['ok' => true, 'pozo' => $pozo];
        } catch (Exception $e) {
            $db->query("ROLLBACK");
            return ['error' => $e->getMessage()];
        }
    }

    public static function listarSalas($userId, $metodoRetiro)
    {
        $db = self::db(); $p = self::pref();

        $riel = self::detectarRiel(['metodo_retiro' => $metodoRetiro]);

        $salas = $db->select(
            "SELECT s.*, u.username AS creador
             FROM `{$p}cueva_salas` s
             INNER JOIN `{$p}users` u ON u.id = s.id_jugador1
             WHERE s.estado = 'esperando'
               AND s.id_jugador1 <> :uid
               AND u.onlinetime >= (UNIX_TIMESTAMP() - 300)
               AND (s.modo = 'lobby'
                    OR (s.modo = 'busqueda_rapida'
                        AND s.fecha_creacion <= DATE_SUB(NOW(), INTERVAL 5 MINUTE)))
             ORDER BY s.fecha_creacion DESC LIMIT 30",
            [':uid' => $userId]
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
}