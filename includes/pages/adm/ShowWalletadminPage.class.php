<?php
/**
 * ShowWalletadminPage — Panel de administracion del Wallet/Banco
 * AstroIO v9.2 — Fase 3: tasa automática QvaPay (P2P averages) + fallback manual + CSRF + POST-only + UUID + idempotencia
 */

if (!defined('MODE')) die('Hacking attempt');

class ShowWalletadminPage extends AbstractGamePage
{
    public $defaultController = 'show';

    private $userId;
    private $authlevel;

    public function __construct()
    {
        global $USER;

        parent::__construct();

        require_once ROOT_PATH.'includes/classes/WalletHelper.class.php';
        require_once ROOT_PATH.'includes/classes/WalletFundHelper.class.php';
        require_once ROOT_PATH.'includes/classes/AdminBankDataHelper.class.php';
        require_once ROOT_PATH.'includes/classes/AdminBankHelper.class.php';

        if (file_exists(ROOT_PATH.'includes/classes/UserBankDataHelper.class.php')) {
            require_once ROOT_PATH.'includes/classes/UserBankDataHelper.class.php';
        }

        $this->userId    = (int)$USER['id'];
        $this->authlevel = (int)$USER['authlevel'];

        if ($this->authlevel < 2) {
            $this->redirect('game.php?page=overview');
        }

        AdminBankHelper::ensureAccount($this->userId);

        $modeActual = isset($_GET['mode']) ? $_GET['mode'] : 'show';
        $excluidos  = ['setbankdata', 'doSetBankData', 'checkBankData', 'getGrafico', 'getAuditoriaAjax'];

        if (!in_array($modeActual, $excluidos)) {
            if (!AdminBankDataHelper::hasBankData($this->userId)) {
                $this->redirect('game.php?page=walletadmin&mode=setbankdata');
            }
        }
    }

    private function prefix()
    {
        if (defined('DB_PREFIX')) return DB_PREFIX;
        if (defined('PREFIX'))    return PREFIX;
        return 'uni1_';
    }

    private function redirect($url)
    {
        header('Location: '.$url);
        exit;
    }

    private function getRequestId()
    {
        if (isset($_POST['id'])) return (int)$_POST['id'];
        if (isset($_GET['id'])) return (int)$_GET['id'];
        return 0;
    }

    private function getRequestMotivo()
    {
        if (isset($_POST['motivo'])) return trim($_POST['motivo']);
        if (isset($_GET['motivo'])) return trim($_GET['motivo']);
        return '';
    }

    /* ════════════════════════════════════════════════════════════
     * 🆕 v9.1: CSRF HELPERS
     * ════════════════════════════════════════════════════════════ */

    private function getCsrfToken()
    {
        if (session_status() === PHP_SESSION_NONE) {
            @session_start();
        }
        if (empty($_SESSION['walletadmin_csrf'])) {
            $_SESSION['walletadmin_csrf'] = bin2hex(random_bytes(32));
        }
        return $_SESSION['walletadmin_csrf'];
    }

    private function validarCsrf()
    {
        if (session_status() === PHP_SESSION_NONE) {
            @session_start();
        }
        if (empty($_SESSION['walletadmin_csrf'])) {
            return false;
        }
        $recibido = isset($_POST['csrf_token']) ? (string)$_POST['csrf_token'] : '';
        if ($recibido === '') {
            return false;
        }
        return hash_equals($_SESSION['walletadmin_csrf'], $recibido);
    }

    private function varsComunes()
    {
        $bank = AdminBankDataHelper::getBankData($this->userId);

        $sinAsignar = $this->fetchTramites('sin_asignar');
        $misPend    = $this->fetchTramites('mis_pendientes', $this->userId);
        $misVerif   = $this->fetchTramites('verificar', $this->userId);
        
        $pendingWd  = WalletHelper::getWithdrawals('pendiente', 100);
        $transRec   = AdminBankHelper::getTransferenciasPendientes($this->userId);

        $countCambios = 0;
        if (class_exists('UserBankDataHelper')) {
            $solicitudesCambio = UserBankDataHelper::getSolicitudesPendientes();
            $countCambios = count($solicitudesCambio);
        }

        return [
            'tiene_datos_banco'  => ($bank !== null),
            'count_sin_asignar'  => count($sinAsignar),
            'count_mis_pend'     => count($misPend),
            'count_mis_verif'    => count($misVerif),
            'count_pending_wd'   => count($pendingWd),
            'count_trans_rec'    => count($transRec),
            'count_cambios'      => $countCambios,
            'user_id'            => $this->userId,
            'es_superadmin'      => ($this->authlevel >= 3),
            'csrf_token'         => $this->getCsrfToken()
        ];
    }

    private function fetchTramites($filtro, $adminId = null)
    {
        $db = Database::get();
        $tramites = [];

        $whereInv = ["i.eliminada = 0"];
        $whereRet = ["1=1"];

        if ($filtro == 'sin_asignar') {
            $whereInv[] = "i.estado = 'pendiente_sin_asignar' AND (i.admin_id = 0 OR i.admin_id IS NULL)";
            $whereRet[] = "w.estado = 'pendiente' AND (w.admin_id = 0 OR w.admin_id IS NULL)";
        } elseif ($filtro == 'mis_pendientes') {
            $whereInv[] = "i.estado IN ('pendiente_asignada', 'datos_enviados')";
            $whereInv[] = "i.admin_id = " . (int)$adminId;
            $whereRet[] = "1=0"; 
        } elseif ($filtro == 'verificar') {
            $whereInv[] = "i.estado = 'pendiente_verificacion'";
            $whereInv[] = "i.admin_id = " . (int)$adminId;
            $whereRet[] = "w.estado = 'aceptada'";
            $whereRet[] = "w.admin_id = " . (int)$adminId;
        } elseif ($filtro == 'historial') {
            $whereInv[] = "i.estado IN ('completada', 'rechazada', 'cancelada', 'expirada')";
            $whereRet[] = "w.estado IN ('completada', 'rechazada', 'cancelada_user', 'cancelada_admin', 'expirada')";
            if ($adminId !== null) {
                $whereInv[] = "i.admin_id = " . (int)$adminId;
                $whereRet[] = "w.admin_id = " . (int)$adminId;
            }
        }

        $sqlInv = "SELECT i.*, 'inversion' AS tipo, u.username AS user_name, a.username AS admin_name 
                   FROM ".$this->prefix()."wallet_investments i
                   LEFT JOIN ".$this->prefix()."users u ON u.id = i.user_id
                   LEFT JOIN ".$this->prefix()."users a ON a.id = i.admin_id
                   WHERE " . implode(' AND ', $whereInv);
        
        $sqlRet = "SELECT w.*, 'retiro' AS tipo, u.username AS user_name, a.username AS admin_name 
                   FROM ".$this->prefix()."wallet_withdrawals w
                   LEFT JOIN ".$this->prefix()."users u ON u.id = w.user_id
                   LEFT JOIN ".$this->prefix()."users a ON a.id = w.admin_id
                   WHERE " . implode(' AND ', $whereRet);

        $rowsInv = $db->select($sqlInv);
        if ($rowsInv) $tramites = array_merge($tramites, $rowsInv);

        $rowsRet = $db->select($sqlRet);
        if ($rowsRet) $tramites = array_merge($tramites, $rowsRet);

        usort($tramites, function($a, $b) {
            return $b['fecha'] - $a['fecha'];
        });

        $formatted = [];
        foreach ($tramites as $r) {
            $estado = $r['estado'];
            $etiquetas = [
                'pendiente_sin_asignar'  => ['Sin asignar',     'pendiente'],
                'pendiente_asignada'     => ['Asignada',        'info'],
                'datos_enviados'         => ['Datos enviados',  'info'],
                'pendiente_verificacion' => ['Verificando',     'info'],
                'pendiente'              => ['Pendiente',       'pendiente'],
                'aceptada'               => ['Aceptada',        'info'],
                'completada'             => ['Completada',      'ok'],
                'rechazada'              => ['Rechazada',       'error'],
                'cancelada'              => ['Cancelada',       'gray'],
                'cancelada_user'         => ['Cancelada User',  'gray'],
                'cancelada_admin'        => ['Cancelada Admin', 'gray'],
                'expirada'               => ['Expirada',        'gray']
            ];
            $et = isset($etiquetas[$estado]) ? $etiquetas[$estado] : [$estado, 'gray'];

            $monto = ($r['tipo'] == 'inversion') ? $r['cantidad_kyber'] : $r['nxt20_retirados'];

            $formatted[] = [
                'id'                => (int)$r['id'],
                'user_id'           => (int)$r['user_id'],
                'username'          => $r['user_name'] ?? ('ID '.$r['user_id']),
                'admin_id'          => (int)$r['admin_id'],
                'admin_username'    => $r['admin_name'] ?? '',
                'cantidad_kyber'    => number_format((float)$monto, 0, '', '.'),
                'cantidad_raw'      => (float)$monto,
                'tipo'              => $r['tipo'],
                'estado'            => $estado,
                'estado_label'      => $et[0],
                'estado_clase'      => $et[1],
                'referencia'        => $r['referencia'] ?? '',
                'motivo'            => $r['motivo'] ?? '',
                'metodo_pago'       => $r['metodo_pago'] ?? 'CUP',
                'referidor_id'      => isset($r['referidor_id']) ? (int)$r['referidor_id'] : 0,
                'nxt20_referidor'   => number_format((int)($r['nxt20_referidor_add'] ?? 0), 0, '', '.'),
                'fecha'             => date('d/m/Y H:i', (int)$r['fecha']),
                'fecha_asignada'    => !empty($r['fecha_asignada']) ? date('d/m/Y H:i', (int)$r['fecha_asignada']) : '',
                'fecha_comprobante' => !empty($r['fecha_comprobante']) ? date('d/m/Y H:i', (int)$r['fecha_comprobante']) : '',
                'fecha_resolucion'  => !empty($r['fecha_resolucion']) ? date('d/m/Y H:i', (int)$r['fecha_resolucion']) : '',
            ];
        }
        return $formatted;
    }

    private function getTramitesEnVivo()
    {
        $db = Database::get();
        $tramites = [];

        $sqlInv = "SELECT 
                    i.id, i.user_id, i.admin_id, i.cantidad_kyber AS monto, i.estado,
                    i.fecha, i.fecha_asignada, i.fecha_datos_enviados, i.fecha_comprobante, i.referencia,
                    'inversion' AS tipo, u.username AS user_name, a.username AS admin_name
                FROM ".$this->prefix()."wallet_investments i
                LEFT JOIN ".$this->prefix()."users u ON u.id = i.user_id
                LEFT JOIN ".$this->prefix()."users a ON a.id = i.admin_id
                WHERE i.eliminada = 0 AND i.estado IN ('pendiente_sin_asignar','pendiente_asignada','datos_enviados','pendiente_verificacion')";
        $rowsInv = $db->select($sqlInv);
        if ($rowsInv) $tramites = array_merge($tramites, $rowsInv);

        $sqlWd = "SELECT 
                    w.id, w.user_id, w.admin_id, w.nxt20_retirados AS monto, w.estado,
                    w.fecha, w.fecha_aceptacion AS fecha_asignada, NULL AS fecha_datos_enviados, NULL AS fecha_comprobante, NULL AS referencia,
                    'retiro' AS tipo, u.username AS user_name, a.username AS admin_name
                FROM ".$this->prefix()."wallet_withdrawals w
                LEFT JOIN ".$this->prefix()."users u ON u.id = w.user_id
                LEFT JOIN ".$this->prefix()."users a ON a.id = w.admin_id
                WHERE w.estado IN ('pendiente', 'aceptada')";
        $rowsWd = $db->select($sqlWd);
        if ($rowsWd) $tramites = array_merge($tramites, $rowsWd);

        usort($tramites, function($a, $b) {
            return $a['fecha'] - $b['fecha'];
        });

        $estadosConfig = [
            'pendiente_sin_asignar'  => ['Sin asignar',    'pendiente'],
            'pendiente_asignada'     => ['Asignada',       'info'],
            'datos_enviados'         => ['Datos enviados', 'info'],
            'pendiente_verificacion' => ['Verificando',    'info'],
            'pendiente'              => ['Pendiente',      'pendiente'],
            'aceptada'               => ['Aceptado',       'info'],
        ];

        $grupos = [];
        foreach ($tramites as $r) {
            $adminId = (int)$r['admin_id'];
            $key     = $adminId > 0 ? $adminId : 0;

            if (!isset($grupos[$key])) {
                $grupos[$key] = [
                    'admin_id'   => $adminId,
                    'admin_name' => $adminId > 0 ? ($r['admin_name'] ?? ('ID '.$adminId)) : 'Sin asignar',
                    'tramites'   => [], 'total' => 0,
                ];
            }

            $estado = $r['estado'];
            $est    = isset($estadosConfig[$estado]) ? $estadosConfig[$estado] : [$estado, 'gray'];

            $fechaRef = (int)$r['fecha'];
            if ($estado == 'pendiente_asignada' && !empty($r['fecha_asignada'])) $fechaRef = (int)$r['fecha_asignada'];
            elseif ($estado == 'datos_enviados' && !empty($r['fecha_datos_enviados'])) $fechaRef = (int)$r['fecha_datos_enviados'];
            elseif ($estado == 'pendiente_verificacion' && !empty($r['fecha_comprobante'])) $fechaRef = (int)$r['fecha_comprobante'];
            elseif ($estado == 'aceptada' && !empty($r['fecha_asignada'])) $fechaRef = (int)$r['fecha_asignada'];

            $grupos[$key]['tramites'][] = [
                'id'             => (int)$r['id'],
                'user_id'        => (int)$r['user_id'],
                'username'       => $r['user_name'] ?? ('ID '.$r['user_id']),
                'cantidad_kyber' => number_format((int)$r['monto'], 0, '', '.'),
                'tipo'           => $r['tipo'],
                'estado'         => $estado,
                'estado_label'   => $est[0],
                'estado_clase'   => $est[1],
                'referencia'     => $r['referencia'] ?? '',
                'fecha'          => date('d/m/Y H:i', $fechaRef),
            ];
            $grupos[$key]['total']++;
        }

        $myUserId = $this->userId;
        uasort($grupos, function($a, $b) use ($myUserId) {
            $aIsMe  = ($a['admin_id'] == $myUserId);
            $bIsMe  = ($b['admin_id'] == $myUserId);
            $aIsSin = ($a['admin_id'] == 0);
            $bIsSin = ($b['admin_id'] == 0);
            if ($aIsMe && !$bIsMe) return -1;
            if (!$aIsMe && $bIsMe) return 1;
            if ($aIsSin && !$bIsSin) return 1;
            if (!$aIsSin && $bIsSin) return -1;
            return strcmp($a['admin_name'], $b['admin_name']);
        });

        return array_values($grupos);
    }

    public function auditoria()
    {
        global $USER;
        $grupos = $this->getTramitesEnVivo();
        $totalTramites = 0;
        foreach ($grupos as $g) { $totalTramites += $g['total']; }

        $this->assign(array_merge($this->varsComunes(), [
            'grupos' => $grupos, 'total_tramites' => $totalTramites, 'tab' => 'auditoria',
            'username' => $USER['username'], 'action_url' => 'game.php?page=walletadmin',
            'feedback_ok' => isset($_GET['ok']) ? $_GET['ok'] : '',
            'feedback_error' => isset($_GET['error']) ? urldecode($_GET['error']) : ''
        ]));
        $this->display('page.wallet.admin.tpl');
    }

    public function getAuditoriaAjax()
    {
        header('Content-Type: application/json');
        if ($this->authlevel < 2) { echo json_encode(['ok' => false, 'error' => 'No autorizado']); exit; }
        $grupos = $this->getTramitesEnVivo();
        $totalTramites = 0;
        foreach ($grupos as $g) { $totalTramites += $g['total']; }
        echo json_encode(['ok' => true, 'grupos' => $grupos, 'total_tramites' => $totalTramites, 'timestamp' => date('d/m/Y H:i:s')]);
        exit;
    }

    public function setbankdata()
    {
        global $USER;
        $bank = AdminBankDataHelper::getBankData($this->userId);
        $esEdicion = ($bank !== null);

        $this->assign([
            'es_edicion' => $esEdicion, 'tarjeta' => $esEdicion ? $bank['tarjeta_magnetica'] : '',
            'telefono' => $esEdicion ? $bank['telefono'] : '', 'titular' => $esEdicion && $bank['titular'] ? $bank['titular'] : '',
            'banco' => $esEdicion && $bank['banco'] ? $bank['banco'] : '', 'feedback_ok' => isset($_GET['ok']) ? $_GET['ok'] : '',
            'feedback_error' => isset($_GET['error']) ? urldecode($_GET['error']) : '',
            'action_url' => 'game.php?page=walletadmin&mode=doSetBankData', 'username' => $USER['username']
        ]);
        $this->display('page.wallet.setbankdata.tpl');
    }

    public function doSetBankData()
    {
        $tarjeta  = isset($_POST['tarjeta'])  ? trim($_POST['tarjeta'])  : '';
        $telefono = isset($_POST['telefono']) ? trim($_POST['telefono']) : '';
        $titular  = isset($_POST['titular'])  ? trim($_POST['titular'])  : '';
        $banco    = isset($_POST['banco'])    ? trim($_POST['banco'])    : '';

        $result = AdminBankDataHelper::saveBankData($this->userId, $tarjeta, $telefono, $titular, $banco);
        if (isset($result['error'])) { $this->redirect('game.php?page=walletadmin&mode=setbankdata&error='.urlencode($result['error'])); }
        $this->redirect('game.php?page=walletadmin&ok=datos_guardados');
    }

    public function checkBankData()
    {
        header('Content-Type: application/json');
        if ($this->authlevel < 2) { echo json_encode(['has_data' => true]); exit; }
        echo json_encode(['has_data' => AdminBankDataHelper::hasBankData($this->userId)]);
        exit;
    }

    public function show()
    {
        global $USER;
        $fund  = WalletFundHelper::getFund();
        
        // Leemos los 3 cajones de wallet_fund (viejo)
        $kyberBanco       = WalletHelper::getKyberBanco();
        $kyberBancoCup    = WalletHelper::getKyberBancoCup();
        $kyberBancoQvapay = WalletHelper::getKyberBancoQvapay();
        
        $totalInvertido = WalletHelper::getTotalInvertidoHistorico();
        $totalRetirado  = WalletHelper::getTotalRetiradoHistorico();
        $minRetiroNxt20 = WalletFundHelper::getMinRetiroNxt20();

        // v9.0: Leemos también las reservas nuevas (uni1_reserves)
        $db = Database::get();
        $reserveNac = null;
        $reserveInt = null;
        try {
            $reserveNac = $db->selectSingle(
                "SELECT balance, project_fund FROM ".$this->prefix()."reserves 
                 WHERE currency_code = 'NTX20_NAC' LIMIT 1"
            );
            $reserveInt = $db->selectSingle(
                "SELECT balance, project_fund FROM ".$this->prefix()."reserves 
                 WHERE currency_code = 'UNTX20_INT' LIMIT 1"
            );
        } catch (Exception $e) {
            // Si la tabla no existe todavía, seguimos con null
        }
        $reserveNacBalance    = $reserveNac ? (int)$reserveNac['balance']      : 0;
        $reserveNacProject    = $reserveNac ? (int)$reserveNac['project_fund'] : 0;
        $reserveNacDisponible = $reserveNacBalance - $reserveNacProject;
        if ($reserveNacDisponible < 0) $reserveNacDisponible = 0;
        $reserveIntBalance    = $reserveInt ? (int)$reserveInt['balance']      : 0;
        $reserveIntProject    = $reserveInt ? (int)$reserveInt['project_fund'] : 0;

        $cuentasAdmin = AdminBankHelper::getAllAccounts();
        $fondoProyecto = 0;
        foreach ($cuentasAdmin as $c) { $fondoProyecto += (float)$c['marca_proyecto']; }

        $cuentaCup = AdminBankHelper::getAccount($this->userId);
        $saldoCup  = (float)($cuentaCup['saldo'] ?? 0);
        $marcaCup  = (float)($cuentaCup['marca_proyecto'] ?? 0);
        $dispCup   = $saldoCup - $marcaCup;
        $bank = AdminBankDataHelper::getBankData($this->userId);

        $totalNtx20Query = $db->selectSingle("SELECT SUM(ntx20 + ntx20_bloqueado) as total FROM " . $this->prefix() . "users");
        $totalNtx20Juego = $totalNtx20Query ? (int)$totalNtx20Query['total'] : 0;

        $this->assign(array_merge($this->varsComunes(), [
            'kyber_banco'         => number_format($kyberBanco, 0, '', '.'),
            'kyber_banco_raw'     => $kyberBanco,
            'kyber_banco_cup'     => number_format($kyberBancoCup, 0, '', '.'),
            'kyber_banco_cup_raw' => $kyberBancoCup,
            'kyber_banco_qvapay'  => number_format($kyberBancoQvapay, 0, '', '.'),
            'kyber_banco_qvapay_raw' => $kyberBancoQvapay,

            'reserve_nac_balance'      => number_format($reserveNacBalance, 0, '', '.'),
            'reserve_nac_balance_raw'  => $reserveNacBalance,
            'reserve_nac_project_fund' => number_format($reserveNacProject, 0, '', '.'),
            'reserve_nac_project_raw'  => $reserveNacProject,
            'reserve_nac_disponible'   => number_format($reserveNacDisponible, 0, '', '.'),
            'reserve_nac_disponible_raw' => $reserveNacDisponible,
            'reserve_int_balance'      => number_format($reserveIntBalance, 0, '', '.'),
            'reserve_int_balance_raw'  => $reserveIntBalance,
            'reserve_int_project_fund' => number_format($reserveIntProject, 0, '', '.'),
            'reserve_int_project_raw'  => $reserveIntProject,
            
            'total_invertido'     => number_format($totalInvertido, 0, '', '.'),
            'total_invertido_raw' => $totalInvertido,
            'total_retirado'      => number_format($totalRetirado, 0, '', '.'),
            'total_retirado_raw'  => $totalRetirado,
            'fondo_proyecto'      => number_format($fondoProyecto, 0, '', '.'),
            'total_ntx20_juego'   => number_format($totalNtx20Juego, 0, '', '.'),
            'total_ntx20_juego_raw' => $totalNtx20Juego,
            'retiros_abiertos'    => (int)($fund['retiros_habilitados'] ?? 0) === 1,
            'retiros_duracion'    => (int)($fund['retiros_duracion'] ?? 0),
            'min_retiro_nxt20'    => $minRetiroNxt20,
            'tarjeta_actual'      => $bank ? $bank['tarjeta_magnetica'] : '',
            'telefono_actual'     => $bank ? $bank['telefono'] : '',
            'cup_saldo'           => number_format($saldoCup, 0, '', '.'),
            'cup_saldo_raw'       => $saldoCup,
            'cup_marca'           => number_format($marcaCup, 0, '', '.'),
            'cup_marca_raw'       => $marcaCup,
            'cup_disponible'      => number_format($dispCup, 0, '', '.'),
            'cup_disponible_raw'  => $dispCup,
            'tab'                 => 'dashboard',
            'username'            => $USER['username'],
            'action_url'          => 'game.php?page=walletadmin',
            'feedback_ok'         => isset($_GET['ok']) ? $_GET['ok'] : '',
            'feedback_error'      => isset($_GET['error']) ? urldecode($_GET['error']) : ''
        ]));
        $this->display('page.wallet.admin.tpl');
    }

    public function investments()
    {
        global $USER;
        $this->assign(array_merge($this->varsComunes(), [
            'solicitudes'    => $this->fetchTramites('sin_asignar'),
            'tab'            => 'investments',
            'username'       => $USER['username'],
            'action_url'     => 'game.php?page=walletadmin',
            'feedback_ok'    => isset($_GET['ok']) ? $_GET['ok'] : '',
            'feedback_error' => isset($_GET['error']) ? urldecode($_GET['error']) : ''
        ]));
        $this->display('page.wallet.admin.tpl');
    }

    public function misPendientes()
    {
        global $USER;
        $this->assign(array_merge($this->varsComunes(), [
            'solicitudes'    => $this->fetchTramites('mis_pendientes', $this->userId),
            'tab'            => 'mis_pendientes',
            'username'       => $USER['username'],
            'action_url'     => 'game.php?page=walletadmin',
            'feedback_ok'    => isset($_GET['ok']) ? $_GET['ok'] : '',
            'feedback_error' => isset($_GET['error']) ? urldecode($_GET['error']) : ''
        ]));
        $this->display('page.wallet.admin.tpl');
    }

    public function verificar()
    {
        global $USER;
        $this->assign(array_merge($this->varsComunes(), [
            'solicitudes'    => $this->fetchTramites('verificar', $this->userId),
            'tab'            => 'verificar',
            'username'       => $USER['username'],
            'action_url'     => 'game.php?page=walletadmin',
            'feedback_ok'    => isset($_GET['ok']) ? $_GET['ok'] : '',
            'feedback_error' => isset($_GET['error']) ? urldecode($_GET['error']) : ''
        ]));
        $this->display('page.wallet.admin.tpl');
    }
	public function historial()
    {
        global $USER;
        $filtroAdmin = null; 
        $this->assign(array_merge($this->varsComunes(), [
            'solicitudes'    => $this->fetchTramites('historial', $filtroAdmin),
            'es_superadmin'  => ($this->authlevel >= 3),
            'tab'            => 'historial',
            'username'       => $USER['username'],
            'action_url'     => 'game.php?page=walletadmin',
            'feedback_ok'    => isset($_GET['ok']) ? $_GET['ok'] : '',
            'feedback_error' => isset($_GET['error']) ? urldecode($_GET['error']) : ''
        ]));
        $this->display('page.wallet.admin.tpl');
    }

    public function tomar()
    {
        $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
        if ($id <= 0) { $this->redirect('game.php?page=walletadmin&mode=investments&error='.urlencode('ID invalido.')); }
        $result = WalletHelper::tomarSolicitud($id, $this->userId);
        if (isset($result['error'])) { $this->redirect('game.php?page=walletadmin&mode=investments&error='.urlencode($result['error'])); }
        $this->redirect('game.php?page=walletadmin&mode=misPendientes&ok=solicitud_tomada');
    }

    public function enviarDatos()
    {
        $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
        if ($id <= 0) { $this->redirect('game.php?page=walletadmin&mode=misPendientes&error='.urlencode('ID invalido.')); }
        $result = WalletHelper::enviarDatos($id, $this->userId);
        if (isset($result['error'])) { $this->redirect('game.php?page=walletadmin&mode=misPendientes&error='.urlencode($result['error'])); }
        $this->redirect('game.php?page=walletadmin&mode=misPendientes&ok=datos_enviados');
    }

    public function confirmar()
    {
        $id = $this->getRequestId();
        if ($id <= 0) { $this->redirect('game.php?page=walletadmin&mode=verificar&error='.urlencode('ID invalido.')); }
        $result = WalletHelper::confirmInvestment($id, $this->userId);
        if (isset($result['error'])) { $this->redirect('game.php?page=walletadmin&mode=verificar&error='.urlencode($result['error'])); }
        $this->redirect('game.php?page=walletadmin&mode=verificar&ok=inversion_confirmada');
    }

    public function rechazar()
    {
        $id     = $this->getRequestId();
        $motivo = $this->getRequestMotivo();
        if ($id <= 0) { $this->redirect('game.php?page=walletadmin&mode=verificar&error='.urlencode('ID invalido.')); }
        $result = WalletHelper::rejectInvestment($id, $this->userId, $motivo);
        if (isset($result['error'])) { $this->redirect('game.php?page=walletadmin&mode=verificar&error='.urlencode($result['error'])); }
        $this->redirect('game.php?page=walletadmin&mode=verificar&ok=inversion_rechazada');
    }

    public function liberar()
    {
        $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
        if ($id <= 0) { $this->redirect('game.php?page=walletadmin&mode=misPendientes&error='.urlencode('ID invalido.')); }
        $result = WalletHelper::liberarLock($id, $this->userId);
        if (isset($result['error'])) { $this->redirect('game.php?page=walletadmin&mode=misPendientes&error='.urlencode($result['error'])); }
        $this->redirect('game.php?page=walletadmin&mode=investments&ok=lock_liberado');
    }

    public function cancelarAdmin()
    {
        $id     = $this->getRequestId();
        $motivo = $this->getRequestMotivo();
        if ($id <= 0) { $this->redirect('game.php?page=walletadmin&mode=misPendientes&error='.urlencode('ID invalido.')); }
        $result = WalletHelper::cancelarSolicitudAdmin($id, $this->userId, $motivo);
        if (isset($result['error'])) { $this->redirect('game.php?page=walletadmin&mode=misPendientes&error='.urlencode($result['error'])); }
        $this->redirect('game.php?page=walletadmin&mode=misPendientes&ok=solicitud_cancelada');
    }

    public function eliminar()
    {
        $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
        if ($id <= 0) { $this->redirect('game.php?page=walletadmin&mode=historial&error='.urlencode('ID invalido.')); }
        $inv = WalletHelper::getInvestmentById($id);
        if (!$inv) { $this->redirect('game.php?page=walletadmin&mode=historial&error='.urlencode('Solicitud no encontrada.')); }
        if (!WalletHelper::puedeEliminar($inv, $this->userId, $this->authlevel)) { $this->redirect('game.php?page=walletadmin&mode=historial&error='.urlencode('No tenes permiso para eliminar esta solicitud.')); }
        $result = WalletHelper::eliminarSolicitud($id, $this->userId);
        if (isset($result['error'])) { $this->redirect('game.php?page=walletadmin&mode=historial&error='.urlencode($result['error'])); }
        $this->redirect('game.php?page=walletadmin&mode=historial&ok=solicitud_eliminada');
    }

    public function withdrawals()
    {
        $this->redirect('game.php?page=walletadmin&mode=investments');
    }

    public function verRetiro()
    {
        global $USER;
        $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
        if ($id <= 0) { $this->redirect('game.php?page=walletadmin&mode=investments&error='.urlencode('ID invalido.')); }
        $w = WalletHelper::getWithdrawalById($id);
        if (!$w) { $this->redirect('game.php?page=walletadmin&mode=investments&error='.urlencode('Retiro no encontrado.')); }

        $userBank = null;
        if (class_exists('UserBankDataHelper')) { $userBank = UserBankDataHelper::getDatos((int)$w['user_id']); }

        $retiro = [
            'id'                 => (int)$w['id'],
            'user_id'            => (int)$w['user_id'],
            'username'           => isset($w['username']) ? $w['username'] : 'ID ' . $w['user_id'],
            'nxt20_retirados'    => number_format((int)$w['nxt20_retirados'], 0, '', '.'),
            'bruto'              => number_format((int)$w['bruto'], 0, '', '.'),
            'neto'               => number_format((int)$w['neto'], 0, '', '.'),
            'neto_raw'           => (int)$w['neto'],
            'comision_proyecto'  => number_format((int)$w['comision_proyecto'], 0, '', '.'),
            'comision_referidor' => number_format((int)$w['comision_referidor'], 0, '', '.'),
            'tipo_cambio'        => number_format((float)$w['tipo_cambio'], 4, '.', ','),
            'referidor_id'       => (int)($w['referidor_id'] ?? 0),
            'estado'             => $w['estado'],
            'motivo'             => isset($w['motivo']) ? $w['motivo'] : '',
            'admin_id'           => (int)($w['admin_id'] ?? 0),
            'metodo_pago'        => $w['metodo_pago'] ?? 'CUP',
            'fecha'              => date('d/m/Y H:i', (int)$w['fecha']),
            'fecha_aceptacion'   => !empty($w['fecha_aceptacion']) ? date('d/m/Y H:i', (int)$w['fecha_aceptacion']) : '',
            'fecha_procesado'    => !empty($w['fecha_procesado']) ? date('d/m/Y H:i', (int)$w['fecha_procesado']) : '',
            'user_tarjeta'       => $userBank ? ($userBank['tarjeta_magnetica'] ?? '') : '',
            'user_telefono'      => $userBank ? ($userBank['telefono'] ?? '')          : '',
            'user_titular'       => $userBank ? ($userBank['titular'] ?? '')           : '',
            'user_banco'         => $userBank ? ($userBank['banco'] ?? '')             : '',
            'user_tiene_datos'   => ($userBank !== null && !empty($userBank['tarjeta_magnetica'])) ? 1 : 0
        ];

        // 🆕 v9.2: Intentar tasa automática de QvaPay, fallback a manual
        $db = Database::get();
        $prefix = $this->prefix();
        $globalCfg = $db->selectSingle(
            "SELECT qvapay_app_id, qvapay_app_secret, qvapay_tasa_cup_por_kyber FROM ".$prefix."config LIMIT 1"
        );

        $tasaCupPorUsd = 0;
        $tasaFuente = 'manual';

        // Intentar tasa automática
        try {
            if ($globalCfg && !empty($globalCfg['qvapay_app_id']) && !empty($globalCfg['qvapay_app_secret'])) {
                require_once ROOT_PATH . 'includes/qvapay.class.php';
                $qpTemp = new QvaPay($globalCfg['qvapay_app_id'], $globalCfg['qvapay_app_secret']);
                $averages = $qpTemp->getP2PAverages();

                $cupKey = null;
                if (isset($averages['CUP'])) {
                    $cupKey = 'CUP';
                } elseif (isset($averages['BANK_CUP'])) {
                    $cupKey = 'BANK_CUP';
                } elseif (isset($averages['CUP_BANK'])) {
                    $cupKey = 'CUP_BANK';
                }

                if ($cupKey !== null && !empty($averages[$cupKey]['average'])) {
                    $tasaCupPorUsd = (float)$averages[$cupKey]['average'];
                    $tasaFuente = 'p2p_average';
                    
                    // 🆕 GUARDAR LA TASA REAL EN LA BASE DE DATOS (Auto-actualización)
                    try {
                        $db->update(
                            "UPDATE ".$prefix."config SET qvapay_tasa_cup_por_kyber = ? WHERE uni = 1",
                            [$tasaCupPorUsd]
                        );
                    } catch (Exception $e) {
                        if (defined('DEBUG') && DEBUG) {
                            error_log('Error guardando tasa automática en verRetiro: '.$e->getMessage());
                        }
                    }
                }
            }
        } catch (Exception $e) {
            if (defined('DEBUG') && DEBUG) {
                error_log('verRetiro getP2PAverages falló: '.$e->getMessage());
            }
        }

        // Fallback a tasa manual
        if ($tasaCupPorUsd <= 1 && $globalCfg) {
            $tasaCupPorUsd = (float)($globalCfg['qvapay_tasa_cup_por_kyber'] ?? 0);
            $tasaFuente = 'manual_fallback';
        }

        $this->assign(array_merge($this->varsComunes(), [
            'retiro'           => $retiro,
            'tasa_cup_por_usd' => $tasaCupPorUsd,
            'tasa_fuente'      => $tasaFuente,
            'csrf_token'       => $this->getCsrfToken(),
            'tab'              => 'investments',
            'username'         => $USER['username'],
            'action_url'       => 'game.php?page=walletadmin',
            'feedback_ok'      => isset($_GET['ok']) ? $_GET['ok'] : '',
            'feedback_error'   => isset($_GET['error']) ? urldecode($_GET['error']) : ''
        ]));
        $this->display('page.wallet.admin.verRetiro.tpl');
    }

    public function aceptarRetiro()
    {
        // 🆕 v9.1: validar CSRF
        if (!$this->validarCsrf()) {
            $this->redirect('game.php?page=walletadmin&mode=investments&error='.urlencode('Token de seguridad inválido. Recargá la página.'));
        }

        $id = $this->getRequestId();
        if ($id <= 0) { $this->redirect('game.php?page=walletadmin&mode=verificar&error='.urlencode('ID invalido.')); }
        $result = WalletHelper::aceptarRetiro($id, $this->userId);
        if (isset($result['error'])) { $this->redirect('game.php?page=walletadmin&mode=verificar&error='.urlencode($result['error'])); }
        $this->redirect('game.php?page=walletadmin&mode=verificar&ok=retiro_aceptado');
    }

    public function confirmarRetiro()
    {
        // 🆕 v9.1: validar CSRF
        if (!$this->validarCsrf()) {
            $this->redirect('game.php?page=walletadmin&mode=investments&error='.urlencode('Token de seguridad inválido. Recargá la página.'));
        }

        $id = $this->getRequestId();
        if ($id <= 0) { $this->redirect('game.php?page=walletadmin&mode=verificar&error='.urlencode('ID invalido.')); }
        $result = WalletHelper::confirmarRetiro($id, $this->userId);
        if (isset($result['error'])) { $this->redirect('game.php?page=walletadmin&mode=verificar&error='.urlencode($result['error'])); }
        $this->redirect('game.php?page=walletadmin&mode=verificar&ok=retiro_confirmado');
    }

    public function pagarRetiroQvaPay()
    {
        // 1. Solo POST
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->redirect('game.php?page=walletadmin&mode=investments&error='.urlencode('Método no permitido.'));
        }

        // 2. Validar CSRF
        if (!$this->validarCsrf()) {
            $this->redirect('game.php?page=walletadmin&mode=investments&error='.urlencode('Token de seguridad inválido. Recargá la página.'));
        }

        $id = isset($_POST['id']) ? (int)$_POST['id'] : 0;
        if ($id <= 0) { $this->redirect('game.php?page=walletadmin&mode=investments&error='.urlencode('ID invalido.')); }

        $db = Database::get();
        $prefix = $this->prefix();

        // 3. Leer retiro
        $w = WalletHelper::getWithdrawalById($id);
        if (!$w) { $this->redirect('game.php?page=walletadmin&mode=investments&error='.urlencode('Retiro no encontrado.')); }

        if ($w['estado'] !== 'aceptada') {
            $this->redirect('game.php?page=walletadmin&mode=verRetiro&id='.$id.'&error='.urlencode('El retiro no está en estado "aceptada".'));
        }

        if (($w['metodo_pago'] ?? 'CUP') !== 'QVAPAY') {
            $this->redirect('game.php?page=walletadmin&mode=verRetiro&id='.$id.'&error='.urlencode('Este retiro no es por QvaPay.'));
        }

        // 4. Idempotencia: verificar intentos previos
        $previo = $db->selectSingle(
            "SELECT * FROM ".$prefix."qvapay_withdrawals WHERE withdraw_id = ? LIMIT 1",
            [$id]
        );

        $qvapayWdId = 0;

        if ($previo) {
            if ($previo['status'] === 'completed') {
                $this->redirect('game.php?page=walletadmin&mode=verRetiro&id='.$id.'&error='.urlencode('Este retiro ya fue pagado por QvaPay.'));
            }
            if ($previo['status'] === 'sent') {
                $this->redirect('game.php?page=walletadmin&mode=verRetiro&id='.$id.'&error='.urlencode('El pago ya fue enviado a QvaPay (UUID: '.($previo['qvapay_transaction_id'] ?? 'N/A').') pero la DB no confirma. Resolver manualmente.'));
            }
            if ($previo['status'] === 'pending') {
                $this->redirect('game.php?page=walletadmin&mode=verRetiro&id='.$id.'&error='.urlencode('Ya hay un intento de pago pendiente. Esperar o contactar soporte.'));
            }
            if ($previo['status'] === 'failed') {
                $db->update(
                    "UPDATE ".$prefix."qvapay_withdrawals 
                     SET status = 'pending', error_message = NULL, qvapay_transaction_id = NULL 
                     WHERE id = ?",
                    [(int)$previo['id']]
                );
                $qvapayWdId = (int)$previo['id'];
            }
        }

        // 5. Cuenta QvaPay del jugador
        $userQvaPay = $db->selectSingle(
            "SELECT qvapay_username FROM ".$prefix."qvapay_accounts WHERE user_id = ? LIMIT 1",
            [(int)$w['user_id']]
        );
        if (!$userQvaPay || empty($userQvaPay['qvapay_username'])) {
            $this->redirect('game.php?page=walletadmin&mode=verRetiro&id='.$id.'&error='.urlencode('El usuario no tiene cuenta QvaPay vinculada.'));
        }

        // 6. Credenciales globales
        $globalCfg = $db->selectSingle(
            "SELECT qvapay_app_id, qvapay_app_secret, qvapay_tasa_cup_por_kyber FROM ".$prefix."config LIMIT 1"
        );
        if (!$globalCfg || empty($globalCfg['qvapay_app_id']) || empty($globalCfg['qvapay_app_secret'])) {
            $this->redirect('game.php?page=walletadmin&mode=verRetiro&id='.$id.'&error='.urlencode('La API global de QvaPay no está configurada.'));
        }

        require_once ROOT_PATH . 'includes/qvapay.class.php';

        // 7. Obtener tasa automática de QvaPay (con fallback a manual)
        $tasaCupPorUsd = 0;
        $tasaFuente = 'manual';

        try {
            $qpTemp = new QvaPay($globalCfg['qvapay_app_id'], $globalCfg['qvapay_app_secret']);
            $averages = $qpTemp->getP2PAverages();

            $cupKey = null;
            if (isset($averages['CUP'])) {
                $cupKey = 'CUP';
            } elseif (isset($averages['BANK_CUP'])) {
                $cupKey = 'BANK_CUP';
            } elseif (isset($averages['CUP_BANK'])) {
                $cupKey = 'CUP_BANK';
            }

            if ($cupKey !== null && !empty($averages[$cupKey]['average'])) {
                $tasaCupPorUsd = (float)$averages[$cupKey]['average'];
                $tasaFuente = 'p2p_average';

                try {
                    $db->update(
                        "UPDATE ".$prefix."config SET qvapay_tasa_cup_por_kyber = ? WHERE uni = 1",
                        [$tasaCupPorUsd]
                    );
                } catch (Exception $e) {
                    if (defined('DEBUG') && DEBUG) {
                        error_log('Error guardando tasa automática en pagarRetiro: '.$e->getMessage());
                    }
                }
            }
        } catch (Exception $e) {
            if (defined('DEBUG') && DEBUG) {
                error_log('getP2PAverages falló: '.$e->getMessage());
            }
        }

        // Fallback a tasa manual si la automática no está disponible
        if ($tasaCupPorUsd <= 1) {
            $tasaCupPorUsd = (float)($globalCfg['qvapay_tasa_cup_por_kyber'] ?? 0);
            $tasaFuente = 'manual_fallback';
        }

        if ($tasaCupPorUsd <= 1) {
            $this->redirect('game.php?page=walletadmin&mode=verRetiro&id='.$id.'&error='.urlencode('No se pudo obtener la tasa CUP/USD (ni automática ni manual). Configurá una tasa manual.'));
        }

        // 8. Conversión CUP → USD
        $montoCup = (float)$w['neto'];
        $montoUsd = round($montoCup / $tasaCupPorUsd, 2);

        if ($montoUsd < 0.01) {
            $this->redirect('game.php?page=walletadmin&mode=verRetiro&id='.$id.'&error='.urlencode('Monto USD demasiado bajo ($'.$montoUsd.'). Mínimo $0.01.'));
        }

        // 9. Crear registro de intento ANTES de transferir
        if ($qvapayWdId === 0) {
            try {
                $db->insert(
                    "INSERT INTO ".$prefix."qvapay_withdrawals 
                     (withdraw_id, method, amount_cup, status) 
                     VALUES (?, 'transfer', ?, 'pending')",
                    [$id, $montoCup]
                );
                $qvapayWdId = (int)$db->lastInsertId();
            } catch (Exception $e) {
                $this->redirect('game.php?page=walletadmin&mode=verRetiro&id='.$id.'&error='.urlencode('Error al crear registro de pago: '.$e->getMessage()));
            }
        }

        // 10. Transferir vía QvaPay
        try {
            $qp = new QvaPay($globalCfg['qvapay_app_id'], $globalCfg['qvapay_app_secret']);
            $res = $qp->transfer(
                $userQvaPay['qvapay_username'],
                $montoUsd,
                "Retiro AstroIO #".$id
            );

            $uuid = null;
            if (is_array($res)) {
                $uuid = $res['transaction_uuid']
                     ?? $res['uuid']
                     ?? $res['data']['uuid']
                     ?? $res['data']['transaction_uuid']
                     ?? null;
            }

            $db->update(
                "UPDATE ".$prefix."qvapay_withdrawals 
                 SET qvapay_transaction_id = ?, status = 'sent', error_message = NULL 
                 WHERE id = ?",
                [$uuid, $qvapayWdId]
            );

        } catch (Exception $e) {
            $db->update(
                "UPDATE ".$prefix."qvapay_withdrawals 
                 SET status = 'failed', error_message = ? 
                 WHERE id = ?",
                [substr($e->getMessage(), 0, 500), $qvapayWdId]
            );

            $this->redirect('game.php?page=walletadmin&mode=verRetiro&id='.$id.'&error='.urlencode('Error de QvaPay: '.$e->getMessage()));
        }

        // 11. Confirmar en DB
        $result = WalletHelper::confirmarRetiro($id, $this->userId);

        if (isset($result['error'])) {
            $db->update(
                "UPDATE ".$prefix."qvapay_withdrawals 
                 SET status = 'sent', 
                     error_message = CONCAT('PAGO OK PERO ERROR DB: ', ?) 
                 WHERE id = ?",
                [substr($result['error'], 0, 400), $qvapayWdId]
            );

            $this->redirect('game.php?page=walletadmin&mode=verRetiro&id='.$id.'&error='.urlencode('Pago enviado a QvaPay ($'.$montoUsd.' USD, tasa '.$tasaFuente.') pero error en DB: '.$result['error'].' | UUID: '.($uuid ?? 'N/A').' | Resolver manualmente.'));
        }

        // 12. Todo OK
        $db->update(
            "UPDATE ".$prefix."qvapay_withdrawals SET status = 'completed' WHERE id = ?",
            [$qvapayWdId]
        );

        $this->redirect('game.php?page=walletadmin&mode=verRetiro&id='.$id.'&ok=retiro_confirmado_qvapay&tasa='.$tasaFuente);
    }

    public function rechazarRetiro()
    {
        if (!$this->validarCsrf()) {
            $this->redirect('game.php?page=walletadmin&mode=investments&error='.urlencode('Token de seguridad inválido. Recargá la página.'));
        }

        $id     = $this->getRequestId();
        $motivo = $this->getRequestMotivo();
        if ($id <= 0) { $this->redirect('game.php?page=walletadmin&mode=verificar&error='.urlencode('ID invalido.')); }
        $result = WalletHelper::rechazarRetiro($id, $this->userId, $motivo);
        if (isset($result['error'])) { $this->redirect('game.php?page=walletadmin&mode=verificar&error='.urlencode($result['error'])); }
        $this->redirect('game.php?page=walletadmin&mode=verificar&ok=retiro_rechazado');
    }

    public function cancelarRetiroAdmin()
    {
        if (!$this->validarCsrf()) {
            $this->redirect('game.php?page=walletadmin&mode=investments&error='.urlencode('Token de seguridad inválido. Recargá la página.'));
        }

        $id     = $this->getRequestId();
        $motivo = $this->getRequestMotivo();
        if ($id <= 0) { $this->redirect('game.php?page=walletadmin&mode=verificar&error='.urlencode('ID invalido.')); }
        $result = WalletHelper::cancelarRetiroAdmin($id, $this->userId, $motivo);
        if (isset($result['error'])) { $this->redirect('game.php?page=walletadmin&mode=verificar&error='.urlencode($result['error'])); }
        $this->redirect('game.php?page=walletadmin&mode=verificar&ok=retiro_cancelado');
    }

    public function solicitudesCambio()
    {
        global $USER;
        if (!class_exists('UserBankDataHelper')) { $this->redirect('game.php?page=walletadmin&error='.urlencode('Helper de datos bancarios no disponible.')); }
        $rows = UserBankDataHelper::getSolicitudesPendientes();
        $solicitudes = [];
        foreach ($rows as $r) {
            $solicitudes[] = [
                'id' => (int)$r['id'], 'user_id' => (int)$r['user_id'], 'username' => isset($r['username']) ? $r['username'] : ('ID ' . $r['user_id']),
                'tarjeta_magnetica' => $r['tarjeta_magnetica'], 'telefono' => $r['telefono'], 'titular' => $r['titular'] ?? '', 'banco' => $r['banco'] ?? '',
                'fecha_creacion' => date('d/m/Y H:i', (int)$r['fecha_creacion'])
            ];
        }
        $this->assign(array_merge($this->varsComunes(), [
            'solicitudes_cambio' => $solicitudes, 'tab' => 'cambios_bancarios', 'username' => $USER['username'],
            'action_url' => 'game.php?page=walletadmin', 'feedback_ok' => isset($_GET['ok']) ? $_GET['ok'] : '',
            'feedback_error' => isset($_GET['error']) ? urldecode($_GET['error']) : ''
        ]));
        $this->display('page.wallet.admin.tpl');
    }

    public function aprobarCambioDatos()
    {
        $id = $this->getRequestId();
        if ($id <= 0) { $this->redirect('game.php?page=walletadmin&mode=solicitudesCambio&error='.urlencode('ID invalido.')); }
        if (!class_exists('UserBankDataHelper')) { $this->redirect('game.php?page=walletadmin&mode=solicitudesCambio&error='.urlencode('Helper no disponible.')); }
        $result = UserBankDataHelper::aprobarCambio($id, $this->userId);
        if (isset($result['error'])) { $this->redirect('game.php?page=walletadmin&mode=solicitudesCambio&error='.urlencode($result['error'])); }
        $this->redirect('game.php?page=walletadmin&mode=solicitudesCambio&ok=cambio_aprobado');
    }

    public function rechazarCambioDatos()
    {
        $id     = $this->getRequestId();
        $motivo = $this->getRequestMotivo();
        if ($id <= 0) { $this->redirect('game.php?page=walletadmin&mode=solicitudesCambio&error='.urlencode('ID invalido.')); }
        if (!class_exists('UserBankDataHelper')) { $this->redirect('game.php?page=walletadmin&mode=solicitudesCambio&error='.urlencode('Helper no disponible.')); }
        $result = UserBankDataHelper::rechazarCambio($id, $this->userId, $motivo);
        if (isset($result['error'])) { $this->redirect('game.php?page=walletadmin&mode=solicitudesCambio&error='.urlencode($result['error'])); }
        $this->redirect('game.php?page=walletadmin&mode=solicitudesCambio&ok=cambio_rechazado');
    }

    public function config()
    {
        global $USER;
        $fund = WalletFundHelper::getFund();
        $kyberBanco     = WalletHelper::getKyberBanco();
        $totalInvertido = WalletHelper::getTotalInvertidoHistorico();
        $totalRetirado  = WalletHelper::getTotalRetiradoHistorico();
        $minRetiroNxt20 = WalletFundHelper::getMinRetiroNxt20();

        $this->assign(array_merge($this->varsComunes(), [
            'kyber_banco'         => number_format($kyberBanco, 0, '', '.'),
            'kyber_banco_raw'     => $kyberBanco,
            'total_invertido'     => number_format($totalInvertido, 0, '', '.'),
            'total_retirado'      => number_format($totalRetirado, 0, '', '.'),
            'retiros_abiertos'    => (int)($fund['retiros_habilitados'] ?? 0) === 1,
            'retiros_duracion'    => (int)($fund['retiros_duracion'] ?? 0),
            'fecha_apertura'      => !empty($fund['fecha_apertura']) ? date('d/m/Y H:i', (int)$fund['fecha_apertura']) : '—',
            'fecha_cierre'        => !empty($fund['fecha_cierre']) ? date('d/m/Y H:i', (int)$fund['fecha_cierre']) : '—',
            'min_retiro_nxt20'    => $minRetiroNxt20,
            'tab'                 => 'config',
            'username'            => $USER['username'],
            'action_url'          => 'game.php?page=walletadmin',
            'feedback_ok'         => isset($_GET['ok']) ? $_GET['ok'] : '',
            'feedback_error'      => isset($_GET['error']) ? urldecode($_GET['error']) : ''
        ]));
        $this->display('page.wallet.admin.tpl');
    }

    public function qvapay()
    {
        global $USER;

        if ($this->authlevel < 3) {
            $this->redirect('game.php?page=walletadmin&error='.urlencode('Solo el Superadmin puede configurar la Pasarela de Pago.'));
        }

        $db = Database::get();
        $prefix = $this->prefix();
        $qp_msg = ''; $qp_err = '';

        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['qvapay_action'])) {
            if ($_POST['qvapay_action'] === 'save') {
                $enabled = isset($_POST['qvapay_enabled']) ? 1 : 0;
                $hab_inv = isset($_POST['qvapay_habilitado_inversion']) ? 1 : 0;
                $hab_ret = isset($_POST['qvapay_habilitado_retiro']) ? 1 : 0;
                $app_id = addslashes(trim($_POST['qvapay_app_id']));
                $app_secret = addslashes(trim($_POST['qvapay_app_secret']));
                $callback = addslashes(trim($_POST['qvapay_callback_url']));
                $tasa = (float)$_POST['qvapay_tasa_cup_por_kyber'];
                $fee = (float)$_POST['qvapay_fee_retiro_pct'];

                if (empty($_POST['qvapay_app_secret'])) {
                    $current = $db->selectSingle("SELECT qvapay_app_secret FROM ".$prefix."config LIMIT 1");
                    $app_secret = $current ? addslashes($current['qvapay_app_secret']) : '';
                }

                $db->query("UPDATE ".$prefix."config SET 
                    qvapay_enabled = '{$enabled}',
                    qvapay_app_id = '{$app_id}',
                    qvapay_app_secret = '{$app_secret}',
                    qvapay_callback_url = '{$callback}',
                    qvapay_tasa_cup_por_kyber = '{$tasa}',
                    qvapay_fee_retiro_pct = '{$fee}',
                    qvapay_habilitado_inversion = '{$hab_inv}',
                    qvapay_habilitado_retiro = '{$hab_ret}'
                ");

                $qp_msg = "✅ Configuración Global de QvaPay guardada correctamente.";
            }
            
            if ($_POST['qvapay_action'] === 'test') {
                try {
                    require_once ROOT_PATH . 'includes/qvapay.class.php';
                    $cfg = $db->selectSingle("SELECT qvapay_app_id, qvapay_app_secret FROM ".$prefix."config LIMIT 1");
                    
                    if (!$cfg || empty($cfg['qvapay_app_id']) || empty($cfg['qvapay_app_secret'])) {
                        throw new Exception("Primero tenés que guardar el App ID y el Secret.");
                    }
                    
                    $qp = new QvaPay($cfg['qvapay_app_id'], $cfg['qvapay_app_secret']);
                    $info = $qp->getInfo();
                    $bal = $qp->getBalance();
                    
                    $msgTasa = "";
                    try {
                        $averages = $qp->getP2PAverages();
                        $cupKey = null;
                        if (isset($averages['CUP'])) {
                            $cupKey = 'CUP';
                        } elseif (isset($averages['BANK_CUP'])) {
                            $cupKey = 'BANK_CUP';
                        } elseif (isset($averages['CUP_BANK'])) {
                            $cupKey = 'CUP_BANK';
                        }

                        if ($cupKey !== null && !empty($averages[$cupKey]['average'])) {
                            $tasaReal = (float)$averages[$cupKey]['average'];
                            
                            $db->update(
                                "UPDATE ".$prefix."config SET qvapay_tasa_cup_por_kyber = ? WHERE uni = 1",
                                [$tasaReal]
                            );
                            
                            $msgTasa = " | Tasa actualizada a: <b>" . number_format($tasaReal, 2) . " CUP/USD</b>";
                        } else {
                            $msgTasa = " | ⚠️ No se pudo obtener la tasa P2P (usando la manual)";
                        }
                    } catch (Exception $eTasa) {
                        $msgTasa = " | ⚠️ Error obteniendo tasa P2P: " . htmlspecialchars($eTasa->getMessage());
                    }

                    $qp_msg = "🔌 Conexión exitosa. App: <b>" . htmlspecialchars($info['data']['name'] ?? 'OK') . "</b> | Balance: <b>$" . htmlspecialchars($bal['data']['balance'] ?? '0.00') . "</b>" . $msgTasa;

                } catch (Exception $e) {
                    $qp_err = "❌ Error: " . htmlspecialchars($e->getMessage());
                }
            }
        }

        $row = $db->selectSingle("SELECT * FROM ".$prefix."config LIMIT 1");
        $qp_cfg = [
            'app_id' => $row['qvapay_app_id'] ?? '',
            'app_secret' => $row['qvapay_app_secret'] ?? '',
            'enabled' => $row['qvapay_enabled'] ?? 0,
            'tasa_cup_por_kyber' => $row['qvapay_tasa_cup_por_kyber'] ?? 1.0000,
            'fee_retiro_pct' => $row['qvapay_fee_retiro_pct'] ?? 2.00,
            'callback_url' => $row['qvapay_callback_url'] ?? ''
        ];
        
        $global_cfg = $row;
        
        $host = $_SERVER['HTTP_HOST'] ?? 'astroio.duckdns.org';
        $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
        $defaultCallback = "{$scheme}://{$host}/banco_qvapay_webhook.php";

        $this->assign(array_merge($this->varsComunes(), [
            'qp_msg'              => $qp_msg,
            'qp_err'              => $qp_err,
            'qp_cfg'              => $qp_cfg,
            'global_cfg'          => $global_cfg,
            'defaultCallback'     => $defaultCallback,
            'tab'                 => 'qvapay',
            'username'            => $USER['username'],
            'action_url'          => 'game.php?page=walletadmin',
            'feedback_ok'         => isset($_GET['ok']) ? $_GET['ok'] : '',
            'feedback_error'      => isset($_GET['error']) ? urldecode($_GET['error']) : ''
        ]));
        $this->display('page.wallet.admin.tpl');
    }

    public function doSaveMinimos()
    {
        $minNxt20 = isset($_POST['min_retiro_nxt20']) ? (int)$_POST['min_retiro_nxt20'] : 0;
        if ($minNxt20 < 0) $minNxt20 = 0;
        WalletFundHelper::setMinRetiros($minNxt20);
        $this->redirect('game.php?page=walletadmin&mode=config&ok=minimo_guardado');
    }

    public function ganancias()
    {
        global $USER;
        $cuentasAdmin = AdminBankHelper::getAllAccounts();
        $fondoProyecto = 0;
        $adminesConMarca = [];
        
        foreach ($cuentasAdmin as $c) {
            $marca = (float)$c['marca_proyecto'];
            $saldo = (float)$c['saldo'];
            $fondoProyecto += $marca;
            
            $adminesConMarca[] = [
                'admin_id'       => (int)$c['admin_id'],
                'username'       => isset($c['username']) ? $c['username'] : ('ID '.$c['admin_id']),
                'authlevel'      => (int)($c['authlevel'] ?? 0),
                'saldo'          => number_format($saldo, 0, '', '.'),
                'saldo_raw'      => $saldo,
                'marca_proyecto' => number_format($marca, 0, '', '.'),
                'marca_raw'      => $marca,
                'tiene_fondo'    => ($marca > 0) 
            ];
        }

        $this->assign(array_merge($this->varsComunes(), [
            'fondo_proyecto'       => number_format($fondoProyecto, 0, '', '.'),
            'fondo_proyecto_raw'   => $fondoProyecto,
            'admins_con_marca'     => $adminesConMarca,
            'es_superadmin'        => ($this->authlevel >= 3), 
            'pct_inv_proyecto'          => WalletHelper::PCT_PROYECTO,
            'pct_inv_proyecto_sin_ref'  => WalletHelper::PCT_PROYECTO_SIN_REF,
            'pct_ret_proyecto'          => WalletHelper::PCT_RET_PROYECTO,
            'pct_ret_referidor'         => WalletHelper::PCT_RET_REFERIDOR,
            'tab'                => 'ganancias',
            'username'           => $USER['username'],
            'action_url'         => 'game.php?page=walletadmin',
            'feedback_ok'        => isset($_GET['ok']) ? $_GET['ok'] : '',
            'feedback_error'     => isset($_GET['error']) ? urldecode($_GET['error']) : ''
        ]));
        $this->display('page.wallet.admin.tpl');
    }

    public function doRetirarProyecto()
    {
        if ($this->authlevel < 3) { $this->redirect('game.php?page=walletadmin&mode=ganancias&error='.urlencode('Solo el superadmin puede retirar el fondo.')); }
        $targetAdminId = isset($_POST['target_admin_id']) ? (int)$_POST['target_admin_id'] : 0;
        $cantidad      = isset($_POST['cantidad'])        ? (int)$_POST['cantidad']        : 0;
        if ($targetAdminId <= 0) { $this->redirect('game.php?page=walletadmin&mode=ganancias&error='.urlencode('Debes elegir un admin del cual retirar.')); }
        if ($cantidad <= 0) { $this->redirect('game.php?page=walletadmin&mode=ganancias&error='.urlencode('La cantidad debe ser mayor a 0.')); }
        
        $result = WalletHelper::retirarFondoProyecto($this->userId, $targetAdminId, $cantidad);
        
        if (isset($result['error'])) { $this->redirect('game.php?page=walletadmin&mode=ganancias&error='.urlencode($result['error'])); }
        $this->redirect('game.php?page=walletadmin&mode=ganancias&ok=fondo_retirado');
    }

    public function openWithdrawals()
    {
        $duracion = isset($_POST['duracion']) ? (int)$_POST['duracion'] : 0;
        $result = WalletFundHelper::abrirRetiros($duracion);
        if (isset($result['error'])) { $this->redirect('game.php?page=walletadmin&mode=config&error='.urlencode($result['error'])); }
        $this->redirect('game.php?page=walletadmin&mode=config&ok=retiros_abiertos');
    }

    public function closeWithdrawals()
    {
        WalletFundHelper::cerrarRetiros();
        $this->redirect('game.php?page=walletadmin&mode=config&ok=retiros_cerrados');
    }

    public function saldoCup()
    {
        global $USER;
        $cuentas = AdminBankHelper::getAllAccounts();
        $totalSaldo = 0; $totalMarca = 0; $totalDisponible = 0;
        $cuentasFormateadas = [];
        
        foreach ($cuentas as $c) {
            if ((int)($c['authlevel'] ?? 0) < 2) continue;

            $s = (float)$c['saldo']; $m = (float)$c['marca_proyecto']; $d = $s - $m; if ($d < 0) $d = 0;
            $totalSaldo += $s; $totalMarca += $m; $totalDisponible += $d;
            $cuentasFormateadas[] = [
                'admin_id'       => (int)$c['admin_id'],
                'username'       => isset($c['username']) ? $c['username'] : ('ID '.$c['admin_id']),
                'authlevel'      => (int)($c['authlevel'] ?? 0),
                'es_yo'          => ((int)$c['admin_id'] === $this->userId),
                'saldo'          => number_format($s, 0, '', '.'),
                'marca'          => number_format($m, 0, '', '.'),
                'disponible'     => number_format($d, 0, '', '.'),
                'saldo_raw'      => $s, 'disponible_raw' => $d
            ];
        }

        $transRecibidas = AdminBankHelper::getTransferenciasPendientes($this->userId);
        $transRecibidasFmt = [];
        foreach ($transRecibidas as $t) {
            $transRecibidasFmt[] = [
                'id' => (int)$t['id'], 'from_admin_id' => (int)$t['from_admin_id'],
                'from_username' => isset($t['from_username']) ? $t['from_username'] : ('ID '.$t['from_admin_id']),
                'monto' => number_format((float)$t['monto'], 0, '', '.'),
                'fecha' => date('d/m/Y H:i', (int)$t['fecha_creacion']), 'expira' => date('d/m/Y H:i', (int)$t['fecha_expiracion'])
            ];
        }

        $transEnviadas = AdminBankHelper::getTransferenciasEnviadas($this->userId);
        $transEnviadasFmt = [];
        foreach ($transEnviadas as $t) {
            $transEnviadasFmt[] = [
                'id' => (int)$t['id'], 'to_admin_id' => (int)$t['to_admin_id'],
                'to_username' => isset($t['to_username']) ? $t['to_username'] : ('ID '.$t['to_admin_id']),
                'monto' => number_format((float)$t['monto'], 0, '', '.'),
                'fecha' => date('d/m/Y H:i', (int)$t['fecha_creacion']), 'expira' => date('d/m/Y H:i', (int)$t['fecha_expiracion'])
            ];
        }

        $filtroAdmin = null;
        $movs = AdminBankHelper::getMovimientos($filtroAdmin, [], 20);
        $movsFmt = [];
        foreach ($movs as $m) {
            $movsFmt[] = [
                'id' => (int)$m['id'], 'tipo' => $m['tipo'], 'monto' => number_format((float)$m['monto'], 0, '', '.'),
                'monto_raw' => (float)$m['monto'], 'saldo' => number_format((float)$m['saldo_resultante'], 0, '', '.'),
                'admin_dueno' => isset($m['admin_name']) ? $m['admin_name'] : (isset($m['username']) ? $m['username'] : ('ID '.$m['admin_id'])),
                'admin_rel' => isset($m['admin_rel_name']) ? $m['admin_rel_name'] : '',
                'referencia_id' => (int)($m['referencia_id'] ?? 0), 'detalle' => $m['detalle'], 'fecha' => date('d/m/Y H:i', (int)$m['fecha'])
            ];
        }

        $this->assign(array_merge($this->varsComunes(), [
            'cup_saldo'          => number_format($totalSaldo, 0, '', '.'),
            'cup_marca'          => number_format($totalMarca, 0, '', '.'),
            'cup_disponible'     => number_format($totalDisponible, 0, '', '.'),
            'cup_saldo_raw'      => $totalSaldo, 'cup_marca_raw' => $totalMarca, 'cup_disponible_raw' => $totalDisponible,
            'cuentas_admin'      => $cuentasFormateadas, 'trans_recibidas' => $transRecibidasFmt,
            'trans_enviadas'     => $transEnviadasFmt, 'count_trans_env' => count($transEnviadasFmt), 'movimientos' => $movsFmt,
            'es_superadmin'      => ($this->authlevel >= 3),
            'tab' => 'cup', 'username' => $USER['username'],
            'action_url'         => 'game.php?page=walletadmin', 'feedback_ok' => isset($_GET['ok']) ? $_GET['ok'] : '',
            'feedback_error'     => isset($_GET['error']) ? urldecode($_GET['error']) : ''
        ]));
        $this->display('page.wallet.admin.tpl');
    }

    public function transferir()
    {
        global $USER;
        $miCuenta = AdminBankHelper::getAccount($this->userId);
        $saldo = (float)($miCuenta['saldo'] ?? 0); $marca = (float)($miCuenta['marca_proyecto'] ?? 0); $disp  = $saldo - $marca;

        $cuentas = AdminBankHelper::getAllAccounts();
        $otrosAdmins = [];
        foreach ($cuentas as $c) {
            if ((int)$c['admin_id'] === $this->userId) continue;
            $otrosAdmins[] = [
                'admin_id'  => (int)$c['admin_id'], 'username' => isset($c['username']) ? $c['username'] : ('ID '.$c['admin_id']),
                'authlevel' => (int)($c['authlevel'] ?? 0)
            ];
        }

        $this->assign([
            'cup_disponible' => number_format($disp > 0 ? $disp : 0, 0, '', '.'), 'cup_disponible_raw' => ($disp > 0 ? $disp : 0),
            'otros_admins' => $otrosAdmins, 'feedback_error' => isset($_GET['error']) ? urldecode($_GET['error']) : '',
            'action_url' => 'game.php?page=walletadmin&mode=doTransferir', 'username' => $USER['username']
        ]);
        $this->display('page.wallet.transfer.tpl');
    }

    public function doTransferir()
    {
        $toAdminId = isset($_POST['to_admin_id']) ? (int)$_POST['to_admin_id'] : 0;
        $monto     = isset($_POST['monto'])       ? (float)$_POST['monto']     : 0;
        if ($toAdminId <= 0) { $this->redirect('game.php?page=walletadmin&mode=transferir&error='.urlencode('Debes elegir un admin destino.')); }
        if ($monto <= 0) { $this->redirect('game.php?page=walletadmin&mode=transferir&error='.urlencode('El monto debe ser mayor a 0.')); }
        $result = AdminBankHelper::crearTransferencia($this->userId, $toAdminId, $monto);
        if (isset($result['error'])) { $this->redirect('game.php?page=walletadmin&mode=transferir&error='.urlencode($result['error'])); }
        $this->redirect('game.php?page=walletadmin&mode=saldoCup&ok=transferencia_creada');
    }

    public function aceptarTransferencia()
    {
        $id = isset($_POST['id']) ? (int)$_POST['id'] : 0;
        if ($id <= 0) { $this->redirect('game.php?page=walletadmin&mode=saldoCup&error='.urlencode('ID invalido.')); }
        $result = AdminBankHelper::aceptarTransferencia($id, $this->userId);
        if (isset($result['error'])) { $this->redirect('game.php?page=walletadmin&mode=saldoCup&error='.urlencode($result['error'])); }
        $this->redirect('game.php?page=walletadmin&mode=saldoCup&ok=transferencia_aceptada');
    }

    public function rechazarTransferencia()
    {
        $id = isset($_POST['id']) ? (int)$_POST['id'] : 0;
        if ($id <= 0) { $this->redirect('game.php?page=walletadmin&mode=saldoCup&error='.urlencode('ID invalido.')); }
        $result = AdminBankHelper::rechazarTransferencia($id, $this->userId);
        if (isset($result['error'])) { $this->redirect('game.php?page=walletadmin&mode=saldoCup&error='.urlencode($result['error'])); }
        $this->redirect('game.php?page=walletadmin&mode=saldoCup&ok=transferencia_rechazada');
    }

    public function cancelarTransferencia()
    {
        $id = isset($_POST['id']) ? (int)$_POST['id'] : 0;
        if ($id <= 0) { $this->redirect('game.php?page=walletadmin&mode=saldoCup&error='.urlencode('ID invalido.')); }
        $result = AdminBankHelper::cancelarTransferencia($id, $this->userId);
        if (isset($result['error'])) { $this->redirect('game.php?page=walletadmin&mode=saldoCup&error='.urlencode($result['error'])); }
        $this->redirect('game.php?page=walletadmin&mode=saldoCup&ok=transferencia_cancelada');
    }

    public function historialCup()
    {
        global $USER;
        $filtros = [
            'tipo' => isset($_GET['tipo']) ? trim($_GET['tipo']) : '',
            'desde' => isset($_GET['desde']) ? strtotime($_GET['desde']) : 0,
            'hasta' => isset($_GET['hasta']) ? strtotime($_GET['hasta']) : 0,
            'admin_rel' => isset($_GET['admin_rel']) ? (int)$_GET['admin_rel'] : 0
        ];
        
        $filtroAdmin = null;
        $movs = AdminBankHelper::getMovimientos($filtroAdmin, $filtros, 200);
        
        $movsFmt = [];
        foreach ($movs as $m) {
            $movsFmt[] = [
                'id' => (int)$m['id'], 'tipo' => $m['tipo'], 'monto' => number_format((float)$m['monto'], 0, '', '.'),
                'monto_raw' => (float)$m['monto'], 'saldo' => number_format((float)$m['saldo_resultante'], 0, '', '.'),
                'admin_dueno' => isset($m['admin_name']) ? $m['admin_name'] : (isset($m['username']) ? $m['username'] : ('ID '.$m['admin_id'])),
                'admin_rel_id' => (int)($m['admin_relacionado'] ?? 0), 'admin_rel' => isset($m['admin_rel_name']) ? $m['admin_rel_name'] : '',
                'referencia_id' => (int)($m['referencia_id'] ?? 0), 'detalle' => $m['detalle'], 'fecha' => date('d/m/Y H:i', (int)$m['fecha'])
            ];
        }
        $this->assign(array_merge($this->varsComunes(), [
            'movimientos'    => $movsFmt,
            'filtros'        => [
                'tipo'  => $filtros['tipo'],
                'desde' => $filtros['desde'] ? date('Y-m-d', $filtros['desde']) : '',
                'hasta' => $filtros['hasta'] ? date('Y-m-d', $filtros['hasta']) : ''
            ],
            'tab'            => 'cup_historial', 'username' => $USER['username'],
            'action_url'     => 'game.php?page=walletadmin', 'feedback_ok' => isset($_GET['ok']) ? $_GET['ok'] : '',
            'feedback_error' => isset($_GET['error']) ? urldecode($_GET['error']) : ''
        ]));
        $this->display('page.wallet.admin.tpl');
    }

    public function ajusteManual()
    {
        global $USER;
        if ($this->authlevel < 3) { $this->redirect('game.php?page=walletadmin&mode=saldoCup&error='.urlencode('Solo el superadmin puede hacer ajustes manuales.')); }
        $cuentas = AdminBankHelper::getAllAccounts();
        $admins = [];
        foreach ($cuentas as $c) {
            if ((int)($c['authlevel'] ?? 0) < 2) continue;

            $admins[] = [
                'admin_id' => (int)$c['admin_id'], 'username' => isset($c['username']) ? $c['username'] : ('ID '.$c['admin_id']),
                'authlevel' => (int)($c['authlevel'] ?? 0), 'saldo' => number_format((float)$c['saldo'], 0, '', '.')
            ];
        }
        $this->assign([
            'admins' => $admins, 'feedback_error' => isset($_GET['error']) ? urldecode($_GET['error']) : '',
            'action_url' => 'game.php?page=walletadmin&mode=doAjusteManual', 'username' => $USER['username']
        ]);
        $this->display('page.wallet.ajuste.tpl');
    }

    public function doAjusteManual()
    {
        if ($this->authlevel < 3) { $this->redirect('game.php?page=walletadmin&mode=saldoCup&error='.urlencode('Solo el superadmin puede hacer ajustes manuales.')); }
        $targetAdminId = isset($_POST['admin_id']) ? (int)$_POST['admin_id']  : 0;
        $monto         = isset($_POST['monto'])    ? (float)$_POST['monto']   : 0;
        $motivo        = isset($_POST['motivo'])   ? trim($_POST['motivo'])   : '';
        if ($targetAdminId <= 0) { $this->redirect('game.php?page=walletadmin&mode=ajusteManual&error='.urlencode('Debes elegir un admin.')); }
        if ($monto == 0) { $this->redirect('game.php?page=walletadmin&mode=ajusteManual&error='.urlencode('El monto no puede ser 0.')); }
        if (strlen($motivo) < 3) { $this->redirect('game.php?page=walletadmin&mode=ajusteManual&error='.urlencode('El motivo es obligatorio (minimo 3 caracteres).')); }
        $result = AdminBankHelper::ajusteManual($targetAdminId, $monto, $motivo, $this->userId);
        if (isset($result['error'])) { $this->redirect('game.php?page=walletadmin&mode=ajusteManual&error='.urlencode($result['error'])); }
        $this->redirect('game.php?page=walletadmin&mode=saldoCup&ok=ajuste_aplicado');
    }

    public function approveInvest() { $this->confirmar(); }

    public function rejectInvest()
    {
        $id = $this->getRequestId();
        if ($id <= 0) { $this->redirect('game.php?page=walletadmin&mode=investments&error='.urlencode('ID invalido.')); }
        WalletHelper::rejectInvestment($id, $this->userId, '');
        $this->redirect('game.php?page=walletadmin&mode=investments&ok=inversion_rechazada');
    }

    public function getGrafico()
    {
        header('Content-Type: application/json');
        if ($this->authlevel < 2) { echo json_encode([]); exit; }
        $horas = isset($_GET['horas']) ? (int)$_GET['horas'] : 360;
        if (!in_array($horas, [0, 24, 360, 720], true)) { $horas = 360; }
        $rows = WalletHelper::getGraficoFlujo($horas);
        $out = [];
        foreach ($rows as $r) {
            $out[] = [
                'fecha'           => date('d/m H:i', (int)$r['fecha']),
                'kyber_banco'     => (int)$r['kyber_banco'],
                'total_invertido' => (int)$r['total_invertido'],
                'total_retirado'  => (int)$r['total_retirado']
            ];
        }
        echo json_encode($out);
        exit;
    }

    /* ════════════════════════════════════════════════════════════
     * 🆕 MERCADO CRUZADO — Dashboard y Conciliación
     * ════════════════════════════════════════════════════════════ */

    public function crossMarket()
    {
        global $USER;
        $db = Database::get();
        $prefix = $this->prefix();

        // Tasa QvaPay
        $tasaQvapay = 0;
        try {
            require_once ROOT_PATH . 'includes/qvapay.class.php';
            $cfg = $db->selectSingle("SELECT qvapay_app_id, qvapay_app_secret FROM `".$prefix."config` LIMIT 1");
            if ($cfg && !empty($cfg['qvapay_app_id'])) {
                $qp = new QvaPay($cfg['qvapay_app_id'], $cfg['qvapay_app_secret']);
                $avg = $qp->getP2PAverages();
                if (isset($avg['CUP']['average'])) {
                    $tasaQvapay = (float)$avg['CUP']['average'];
                }
            }
        } catch (Exception $e) {}
        if ($tasaQvapay <= 1) $tasaQvapay = 820.00; // Fallback

        // Reservas
        $resNac = $db->selectSingle("SELECT balance FROM `".$prefix."reserves` WHERE currency_code = 'NTX20_NAC'");
        $resInt = $db->selectSingle("SELECT balance FROM `".$prefix."reserves` WHERE currency_code = 'UNTX20_INT'");
        $balanceNac = $resNac ? (int)$resNac['balance'] : 0;
        $balanceInt = $resInt ? (int)$resInt['balance'] : 0;

        // Spread
        $spreadNac = $db->selectSingle("SELECT SUM(spread_amount) AS total FROM `".$prefix."cross_trades` WHERE spread_currency = 'NTX20_NAC'");
        $spreadInt = $db->selectSingle("SELECT SUM(spread_amount) AS total FROM `".$prefix."cross_trades` WHERE spread_currency = 'UNTX20_INT'");
        $totalSpreadNac = $spreadNac ? (int)$spreadNac['total'] : 0;
        $totalSpreadInt = $spreadInt ? (int)$spreadInt['total'] : 0;

        // Órdenes y Cruces
        $openOrders = $db->select("SELECT o.*, u.username FROM `".$prefix."cross_orders` o LEFT JOIN `".$prefix."users` u ON u.id = o.user_id WHERE o.status = 'open' ORDER BY o.created_at DESC");
        if (!is_array($openOrders)) $openOrders = [];
        foreach ($openOrders as &$o) {
            $o['is_sell'] = ($o['side'] === 'sell');
            $o['side_label'] = $o['is_sell'] ? 'Venta' : 'Compra';
            $o['amount_fmt'] = number_format((int)$o['amount'], 0, ',', '.');
            $o['price_fmt']  = number_format((int)$o['price_amount'], 0, ',', '.');
            $o['date'] = date('d/m H:i', (int)$o['created_at']);
        }
        unset($o);

        $trades = $db->select("SELECT t.*, ub.username AS buyer_name, us.username AS seller_name FROM `".$prefix."cross_trades` t LEFT JOIN `".$prefix."users` ub ON ub.id = t.buyer_id LEFT JOIN `".$prefix."users` us ON us.id = t.seller_id ORDER BY t.created_at DESC LIMIT 50");
        if (!is_array($trades)) $trades = [];
        foreach ($trades as &$t) {
            $t['amount_fmt'] = number_format((int)$t['amount'], 0, ',', '.');
            $t['price_fmt']  = number_format((int)$t['amount_buyer'], 0, ',', '.');
            $t['date'] = date('d/m H:i', (int)$t['created_at']);
            $t['spread_fmt'] = number_format((int)$t['spread_amount'], 0, ',', '.');
            $t['spread_curr'] = ($t['spread_currency'] === 'NTX20_NAC') ? 'CUP' : 'UNTX';
        }
        unset($t);

        $rebalanceEvents = $db->select("SELECT r.*, u.username AS admin_name FROM `".$prefix."rebalance_events` r LEFT JOIN `".$prefix."users` u ON u.id = r.admin_id ORDER BY r.created_at DESC LIMIT 20");
        if (!is_array($rebalanceEvents)) $rebalanceEvents = [];
        foreach ($rebalanceEvents as &$re) {
            $re['date'] = date('d/m H:i', (int)$re['created_at']);
        }
        unset($re);

        $this->assign(array_merge($this->varsComunes(), [
            'balance_nac'      => number_format($balanceNac, 0, ',', '.'),
            'balance_int'      => number_format($balanceInt, 0, ',', '.'),
            'spread_nac'       => number_format($totalSpreadNac, 0, ',', '.'),
            'spread_int'       => number_format($totalSpreadInt, 0, ',', '.'),
            'tasa_qvapay'      => number_format($tasaQvapay, 2, '.', ','),
            'open_orders'      => $openOrders,
            'trades'           => $trades,
            'rebalance_events' => $rebalanceEvents,
            'tab'              => 'crossmarket',
            'username'         => $USER['username'],
            'action_url'       => 'game.php?page=walletadmin',
            'feedback_ok'      => isset($_GET['ok']) ? $_GET['ok'] : '',
            'feedback_error'   => isset($_GET['error']) ? urldecode($_GET['error']) : ''
        ]));
        $this->display('page.wallet.admin.tpl');
    }

    public function doCrossRebalance()
    {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->redirect('game.php?page=walletadmin&mode=crossMarket&error='.urlencode('Método no permitido.'));
        }

        $db = Database::get();
        $prefix = $this->prefix();
        
        $from = $_POST['from_currency'] ?? '';
        $to = $_POST['to_currency'] ?? '';
        $amountFrom = (int)($_POST['amount_from'] ?? 0);
        $amountTo = (int)($_POST['amount_to'] ?? 0);
        $note = trim($_POST['note'] ?? '');
        
        if ($from && $to && $amountFrom > 0) {
            // Insertar evento
            $db->insert(
                "INSERT INTO `".$prefix."rebalance_events` 
                    (admin_id, from_currency, to_currency, amount_from, amount_to, note, created_at) 
                 VALUES (:aid, :fc, :tc, :af, :at, :n, :cr)", 
                [
                    ':aid' => $this->userId, ':fc' => $from, ':tc' => $to, 
                    ':af' => $amountFrom, ':at' => $amountTo, 
                    ':n' => $note, ':cr' => time()
                ]
            );
            
            // Actualizar reservas
            $db->update("UPDATE `".$prefix."reserves` SET balance = GREATEST(0, balance - :a) WHERE currency_code = :c", [':a' => $amountFrom, ':c' => $from]);
            $db->update("UPDATE `".$prefix."reserves` SET balance = balance + :a WHERE currency_code = :c", [':a' => $amountTo, ':c' => $to]);
            
            $this->redirect('game.php?page=walletadmin&mode=crossMarket&ok=rebalance_registrado');
        } else {
            $this->redirect('game.php?page=walletadmin&mode=crossMarket&error='.urlencode('Faltan datos para el rebalanceo.'));
        }
    }
}