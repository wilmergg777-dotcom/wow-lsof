<?php
/**
 * WalletFundHelper — Gestion del fondo global del banco
 * AstroIO v9.0 — Doble escritura (wallet_fund + uni1_reserves)
 */

if (!defined('MODE')) die('Hacking attempt');

class WalletFundHelper
{
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
     * 🆕 v9.0: SINCRONIZAR CON uni1_reserves
     * ------------------------------------------------------------
     * Se llama desde addToBanco, removeFromBanco, addToProyecto,
     * removeFromProyecto. Escribe en la tabla nueva de reservas.
     * En try/catch: si falla, no rompe el sistema viejo.
     * ============================================================ */
    private static function syncReserves($currency, $campo, $delta)
    {
        $delta = (int)$delta;
        if ($delta === 0) return;

        if (!in_array($campo, ['balance', 'project_fund'], true)) return;

        $db = self::db();
        try {
            $db->update(
                "UPDATE ".self::prefix()."reserves 
                 SET `".$campo."` = GREATEST(0, `".$campo."` + :d)
                 WHERE currency_code = :cur",
                [':d' => $delta, ':cur' => $currency]
            );
        } catch (Exception $e) {
            if (defined('DEBUG') && DEBUG) {
                error_log('WalletFundHelper::syncReserves ERROR: '.$e->getMessage());
            }
        }
    }

    /* ============================================================
     * OBTENER FONDO GLOBAL
     * ============================================================ */
    public static function getFund()
    {
        $db = self::db();

        $fund = $db->selectSingle(
            "SELECT * FROM ".self::prefix()."wallet_fund 
             WHERE id = 1 
             LIMIT 1"
        );

        if (!$fund) {
            // Crear la fila si no existe
            $db->insert(
                "INSERT INTO ".self::prefix()."wallet_fund (id) 
                 VALUES (:id)",
                [':id' => 1]
            );

            $fund = $db->selectSingle(
                "SELECT * FROM ".self::prefix()."wallet_fund 
                 WHERE id = 1 
                 LIMIT 1"
            );
        }

        if (!$fund) {
            // Fallback por si falla todo (v7.4)
            $fund = [
                'id'                        => 1,
                'kyber_banco'               => 0,
                'kyber_banco_cup'           => 0,
                'kyber_banco_qvapay'        => 0,
                'fondo_proyecto'            => 0,
                'total_invertido_historico' => 0,
                'total_retirado_historico'  => 0,
                'min_retiro_nxt20'          => 300,
                'retiros_habilitados'       => 0,
                'retiros_duracion'          => 0,
                'fecha_apertura'            => null,
                'fecha_cierre'              => null,
                'ultima_actualizacion'      => 0
            ];
        }

        return $fund;
    }

    /* ============================================================
     * GUARDAR FONDO (update dinamico)
     * ============================================================ */
    public static function saveFund($data)
    {
        $db = self::db();

        $sets = [];
        $params = [];

        foreach ($data as $key => $val) {
            if ($key === 'id') continue;

            $sets[] = "`".$key."` = :".$key;
            $params[":".$key] = $val;
        }

        // Siempre actualizamos la fecha
        $sets[] = "`ultima_actualizacion` = :ultima_actualizacion";
        $params[':ultima_actualizacion'] = self::now();

        if (empty($sets)) return false;

        $sql = "UPDATE ".self::prefix()."wallet_fund 
                SET ".implode(', ', $sets)." 
                WHERE id = :fid";
        $params[':fid'] = 1;

        $db->update($sql, $params);
        return true;
    }

    /* ============================================================
     * LIQUIDEZ DEL BANCO (v9.0 CON DOBLE ESCRITURA)
     * ------------------------------------------------------------
     * addToBanco()    — suma Kyber al banco específico, global,
     *                   y a uni1_reserves (NTX20_NAC o UNTX20_INT).
     * removeFromBanco() — resta Kyber del banco específico, global,
     *                   y de uni1_reserves.
     * ============================================================ */
    public static function addToBanco($cantidad, $metodo = 'CUP')
    {
        $db = self::db();
        $cantidad = (int)$cantidad;
        if ($cantidad <= 0) return true;

        $metodo = strtoupper($metodo);

        if ($metodo === 'QVAPAY') {
            $db->update(
                "UPDATE ".self::prefix()."wallet_fund 
                 SET kyber_banco = kyber_banco + :c1,
                     kyber_banco_qvapay = kyber_banco_qvapay + :c2
                 WHERE id = :fid",
                [':c1' => $cantidad, ':c2' => $cantidad, ':fid' => 1]
            );
            // 🆕 v9.0: sincronizar con reserva internacional
            self::syncReserves('UNTX20_INT', 'balance', $cantidad);
        } else {
            $db->update(
                "UPDATE ".self::prefix()."wallet_fund 
                 SET kyber_banco = kyber_banco + :c1,
                     kyber_banco_cup = kyber_banco_cup + :c2
                 WHERE id = :fid",
                [':c1' => $cantidad, ':c2' => $cantidad, ':fid' => 1]
            );
            // 🆕 v9.0: sincronizar con reserva nacional
            self::syncReserves('NTX20_NAC', 'balance', $cantidad);
        }

        return true;
    }

    public static function removeFromBanco($cantidad, $metodo = 'CUP')
    {
        $db = self::db();
        $cantidad = (int)$cantidad;
        if ($cantidad <= 0) return true;

        $metodo = strtoupper($metodo);

        if ($metodo === 'QVAPAY') {
            $db->update(
                "UPDATE ".self::prefix()."wallet_fund 
                 SET kyber_banco = GREATEST(0, kyber_banco - :c1),
                     kyber_banco_qvapay = GREATEST(0, kyber_banco_qvapay - :c2)
                 WHERE id = :fid",
                [':c1' => $cantidad, ':c2' => $cantidad, ':fid' => 1]
            );
            // 🆕 v9.0: sincronizar con reserva internacional
            self::syncReserves('UNTX20_INT', 'balance', -$cantidad);
        } else {
            $db->update(
                "UPDATE ".self::prefix()."wallet_fund 
                 SET kyber_banco = GREATEST(0, kyber_banco - :c1),
                     kyber_banco_cup = GREATEST(0, kyber_banco_cup - :c2)
                 WHERE id = :fid",
                [':c1' => $cantidad, ':c2' => $cantidad, ':fid' => 1]
            );
            // 🆕 v9.0: sincronizar con reserva nacional
            self::syncReserves('NTX20_NAC', 'balance', -$cantidad);
        }

        return true;
    }

    public static function getKyberBanco()
    {
        $fund = self::getFund();
        return (int)($fund['kyber_banco'] ?? 0);
    }

    // 🆕 Obtiene el Kyber del sistema CUP
    public static function getKyberBancoCup()
    {
        $fund = self::getFund();
        return (int)($fund['kyber_banco_cup'] ?? 0);
    }

    // 🆕 Obtiene el Kyber del sistema QvaPay
    public static function getKyberBancoQvapay()
    {
        $fund = self::getFund();
        return (int)($fund['kyber_banco_qvapay'] ?? 0);
    }

    /* ============================================================
     * HISTORICOS (v6.0)
     * ------------------------------------------------------------
     * Agregado removeFromInvertidoHistorico() para liquidaciones.
     * ============================================================ */
    public static function addToInvertidoHistorico($cantidad)
    {
        $db = self::db();
        $cantidad = (int)$cantidad;
        if ($cantidad <= 0) return true;

        $db->update(
            "UPDATE ".self::prefix()."wallet_fund 
             SET total_invertido_historico = total_invertido_historico + :c 
             WHERE id = :fid",
            [':c' => $cantidad, ':fid' => 1]
        );

        return true;
    }

    public static function removeFromInvertidoHistorico($cantidad)
    {
        $db = self::db();
        $cantidad = (int)$cantidad;
        if ($cantidad <= 0) return true;

        $db->update(
            "UPDATE ".self::prefix()."wallet_fund 
             SET total_invertido_historico = GREATEST(0, total_invertido_historico - :c) 
             WHERE id = :fid",
            [':c' => $cantidad, ':fid' => 1]
        );

        return true;
    }

    public static function addToRetiradoHistorico($cantidad)
    {
        $db = self::db();
        $cantidad = (int)$cantidad;
        if ($cantidad <= 0) return true;

        $db->update(
            "UPDATE ".self::prefix()."wallet_fund 
             SET total_retirado_historico = total_retirado_historico + :c 
             WHERE id = :fid",
            [':c' => $cantidad, ':fid' => 1]
        );

        return true;
    }

    public static function getTotalInvertidoHistorico()
    {
        $fund = self::getFund();
        return (int)($fund['total_invertido_historico'] ?? 0);
    }

    public static function getTotalRetiradoHistorico()
    {
        $fund = self::getFund();
        return (int)($fund['total_retirado_historico'] ?? 0);
    }

    /* ============================================================
     * FONDO PROYECTO (acumulativo)
     * ------------------------------------------------------------
     * v9.0: doble escritura con uni1_reserves.project_fund
     * ============================================================ */
    public static function addToProyecto($cantidad)
    {
        $db = self::db();
        $cantidad = (int)$cantidad;
        if ($cantidad <= 0) return true;

        $db->update(
            "UPDATE ".self::prefix()."wallet_fund 
             SET fondo_proyecto = fondo_proyecto + :c 
             WHERE id = :fid",
            [':c' => $cantidad, ':fid' => 1]
        );

        // 🆕 v9.0: sincronizar con reserva nacional (project_fund)
        self::syncReserves('NTX20_NAC', 'project_fund', $cantidad);

        return true;
    }

    public static function removeFromProyecto($cantidad)
    {
        $db = self::db();
        $cantidad = (int)$cantidad;
        if ($cantidad <= 0) return true;

        $db->update(
            "UPDATE ".self::prefix()."wallet_fund 
             SET fondo_proyecto = GREATEST(0, fondo_proyecto - :c) 
             WHERE id = :fid",
            [':c' => $cantidad, ':fid' => 1]
        );

        // 🆕 v9.0: sincronizar con reserva nacional (project_fund)
        self::syncReserves('NTX20_NAC', 'project_fund', -$cantidad);

        return true;
    }

    public static function getFondoProyecto()
    {
        $fund = self::getFund();
        return (int)($fund['fondo_proyecto'] ?? 0);
    }

    /* ============================================================
     * MINIMOS DE RETIRO (config admin)
     * ------------------------------------------------------------
     * Minimo UNICO (NXT-20), default 300, sobre monto bruto.
     * ============================================================ */
    public static function getMinRetiroNxt20()
    {
        $fund = self::getFund();
        $min  = (int)($fund['min_retiro_nxt20'] ?? 0);
        return $min > 0 ? $min : 300;
    }

    public static function setMinRetiros($minNxt20)
    {
        return self::saveFund([
            'min_retiro_nxt20' => (int)$minNxt20
        ]);
    }

    /* ============================================================
     * RETIROS — ABRIR / CERRAR / ESTADO
     * ------------------------------------------------------------
     * El admin controla el flag retiros_habilitados desde el panel.
     * retirosAbiertos() respeta ese flag y el timeout de duracion.
     * ============================================================ */
    public static function abrirRetiros($duracionHoras = 0)
    {
        self::saveFund([
            'retiros_habilitados' => 1,
            'retiros_duracion'    => (int)$duracionHoras,
            'fecha_apertura'      => self::now(),
            'fecha_cierre'        => null
        ]);

        return ['success' => true];
    }

    public static function cerrarRetiros()
    {
        self::saveFund([
            'retiros_habilitados' => 0,
            'fecha_cierre'        => self::now()
        ]);

        return ['success' => true];
    }

    public static function retirosAbiertos()
    {
        $fund = self::getFund();

        // 1. Si el admin los cerro, estan cerrados
        if ((int)($fund['retiros_habilitados'] ?? 0) !== 1) {
            return false;
        }

        // 2. Si hay duracion configurada, verificar timeout
        if ((int)($fund['retiros_duracion'] ?? 0) > 0 && !empty($fund['fecha_apertura'])) {
            $cierreProgramado = (int)$fund['fecha_apertura'] 
                              + ((int)$fund['retiros_duracion'] * 3600);

            if (self::now() >= $cierreProgramado) {
                // Se vencio el tiempo: cerrar automaticamente
                self::cerrarRetiros();
                return false;
            }
        }

        return true;
    }

    /* ============================================================
     * ESTADISTICAS DEL FONDO (v9.0)
     * ============================================================ */
    public static function getStats()
    {
        $fund = self::getFund();

        return [
            'kyber_banco'               => (int)($fund['kyber_banco'] ?? 0),
            'kyber_banco_cup'           => (int)($fund['kyber_banco_cup'] ?? 0),
            'kyber_banco_qvapay'        => (int)($fund['kyber_banco_qvapay'] ?? 0),
            'fondo_proyecto'            => (int)($fund['fondo_proyecto'] ?? 0),
            'total_invertido_historico' => (int)($fund['total_invertido_historico'] ?? 0),
            'total_retirado_historico'  => (int)($fund['total_retirado_historico'] ?? 0),
            'min_retiro_nxt20'          => self::getMinRetiroNxt20(),
            'retiros_abiertos'          => self::retirosAbiertos(),
            'fecha_apertura'            => $fund['fecha_apertura'] ?? null,
            'fecha_cierre'              => $fund['fecha_cierre'] ?? null
        ];
    }
}