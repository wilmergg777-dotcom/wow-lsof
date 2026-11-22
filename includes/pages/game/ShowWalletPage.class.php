<?php
/**
 * ShowWalletPage — Sistema de Banco/Wallet (usuario)
 * AstroIO v7.4 — Doble Sistema (CUP y QvaPay) con Método Bloqueado, Respeto de Config Global y Bancos Separados (30%)
 */

if (!defined('MODE')) die('Hacking attempt');

class ShowWalletPage extends AbstractGamePage
{
    public $defaultController = 'show';

    private $userId;
    private $metodoRetiro;

    public function __construct()
    {
        global $USER;

        parent::__construct();

        require_once ROOT_PATH.'includes/classes/WalletHelper.class.php';
        require_once ROOT_PATH.'includes/classes/WalletFundHelper.class.php';
        require_once ROOT_PATH.'includes/classes/AdminBankDataHelper.class.php';
        require_once ROOT_PATH.'includes/classes/UserBankDataHelper.class.php';

        if (file_exists(ROOT_PATH.'includes/classes/VIPHelper.class.php')) {
            require_once ROOT_PATH.'includes/classes/VIPHelper.class.php';
        }

        $this->userId = (int)$USER['id'];
        
        // 🆕 Leemos el método de retiro del usuario desde la BD
        $this->metodoRetiro = $this->getMetodoRetiro();

        WalletHelper::ensureWallet($this->userId);
    }

    /* ════════════════════════════════════════════════════════════
     * HELPERS INTERNOS
     * ════════════════════════════════════════════════════════════ */

    // 🆕 Obtiene el método de retiro (CUP, QVAPAY o NULL)
    private function getMetodoRetiro()
    {
        $prefix = defined('DB_PREFIX') ? DB_PREFIX : 'uni1_';
        $db = Database::get();
        try {
            $row = $db->selectSingle(
                "SELECT metodo_retiro FROM ".$prefix."users WHERE id = :uid LIMIT 1", 
                [':uid' => $this->userId]
            );
            return $row ? $row['metodo_retiro'] : null;
        } catch (Exception $e) {
            return null;
        }
    }

    // 🆕 Lee la configuración de QvaPay desde uni1_config
    private function getQvapayConfig()
    {
        $prefix = defined('DB_PREFIX') ? DB_PREFIX : 'uni1_';
        $db = Database::get();
        try {
            return $db->selectSingle("SELECT * FROM ".$prefix."config LIMIT 1");
        } catch (Exception $e) {
            return null;
        }
    }

    // 🆕 Revisa si el Admin habilitó la compra y/o el retiro
    private function isQvapayEnabled($type = 'both')
    {
        $config = $this->getQvapayConfig();
        if (!$config) return false;

        // Si el interruptor maestro está apagado, todo false.
        if (empty($config['qvapay_enabled'])) {
            return false;
        }

        $buy = !empty($config['qvapay_habilitado_inversion']);
        $withdraw = !empty($config['qvapay_habilitado_retiro']);

        if ($type == 'buy') return $buy;
        if ($type == 'withdraw') return $withdraw;
        return ($buy || $withdraw);
    }

    private function redirect($url)
    {
        header('Location: '.$url);
        exit;
    }

    private function esVIP()
    {
        try {
            if (class_exists('VIPHelper')) {
                return (bool)VIPHelper::isVIP($this->userId);
            }
        } catch (Exception $e) {}
        return false;
    }

    private function verificarDatosBancarios($excepto = false)
    {
        if ($excepto) return;

        if (!UserBankDataHelper::tieneDatos($this->userId)) {
            $this->redirect('game.php?page=wallet&mode=setbankdata');
        }
    }

    private function formatearSolicitud($r)
    {
        $estado = isset($r['estado']) ? $r['estado'] : '';

        $etiquetas = [
            'pendiente_sin_asignar'  => ['Esperando admin',   'pendiente'],
            'pendiente_asignada'     => ['Admin asignado',    'info'],
            'datos_enviados'         => ['Datos enviados',    'info'],
            'pendiente_verificacion' => ['Verificando pago',  'info'],
            'completada'             => ['Completada',        'ok'],
            'rechazada'              => ['Rechazada',         'error'],
            'cancelada'              => ['Cancelada',         'gray'],
            'expirada'               => ['Expirada',          'gray']
        ];

        $etiqueta = isset($etiquetas[$estado]) ? $etiquetas[$estado] : ['—', 'gray'];

        return [
            'id'                => (int)$r['id'],
            'cantidad_kyber'    => number_format((int)$r['cantidad_kyber'], 0, ',', '.'),
            'cantidad_raw'      => (int)$r['cantidad_kyber'],
            'nxt20_entregado'   => number_format((int)$r['nxt20_entregado'], 0, ',', '.'),
            'fondo_visible'     => '0',
            'fondo_proyecto'    => '0',
            'referidor_add'     => '0',
            'nxt20_referidor'   => number_format((int)($r['nxt20_referidor_add'] ?? 0), 0, ',', '.'),
            'referidor_id'      => (int)($r['referidor_id'] ?? 0),
            'estado'            => $estado,
            'estado_label'      => $etiqueta[0],
            'estado_clase'      => $etiqueta[1],
            'referencia'        => isset($r['referencia']) ? $r['referencia'] : '',
            'motivo'            => isset($r['motivo']) && $r['motivo'] ? $r['motivo'] : '',
            'fecha'             => date('d/m/Y H:i', (int)$r['fecha']),
            'fecha_resolucion'  => !empty($r['fecha_resolucion']) 
                                    ? date('d/m/Y H:i', (int)$r['fecha_resolucion']) 
                                    : '',
            'admin_tarjeta'     => isset($r['admin_tarjeta_snapshot']) ? $r['admin_tarjeta_snapshot'] : '',
            'admin_telefono'    => isset($r['admin_telefono_snapshot']) ? $r['admin_telefono_snapshot'] : ''
        ];
    }

    /* ════════════════════════════════════════════════════════════
     * SHOW — PANTALLA PRINCIPAL
     * ════════════════════════════════════════════════════════════ */

    public function show()
    {
        global $USER;

        // 🆕 Si es primera vez (NULL), lo mandamos a elegir el método
        if ($this->metodoRetiro === null) {
            $this->redirect('game.php?page=wallet&mode=elegir_metodo');
        }

        // 🆕 Si es CUP, le exigimos datos bancarios. Si es QVAPAY, pasa directo.
        if ($this->metodoRetiro === 'CUP') {
            $this->verificarDatosBancarios();
        }

        // 🆕 Obtenemos el estado global de QvaPay desde uni1_config
        $qvapay_compra_activa = $this->isQvapayEnabled('buy');
        $qvapay_retiro_activa = $this->isQvapayEnabled('withdraw');

        $wallet = WalletHelper::getWallet($this->userId);
        $fund   = WalletFundHelper::getFund();

        $nxt20Total       = WalletHelper::getNxt20($this->userId);
        $nxt20Retirable   = WalletHelper::getNxt20Retirable($this->userId);
        $nxt20Bloqueado   = WalletHelper::getNxt20Bloqueado($this->userId);

        $referrerId = WalletHelper::getReferrerId($this->userId);

        $movimientos = WalletHelper::getTransactions($this->userId, 10);
        $solicitudesActivas = WalletHelper::getSolicitudesByUser($this->userId, true);

        $solicitudesFormateadas = [];
        foreach ($solicitudesActivas as $r) {
            $solicitudesFormateadas[] = $this->formatearSolicitud($r);
        }

        $retiroPendiente = null;
        $retirosUser = WalletHelper::getRetirosByUser($this->userId, 5);
        foreach ($retirosUser as $w) {
            if (in_array($w['estado'], ['pendiente', 'aceptada'])) {
                $retiroPendiente = [
                    'id'         => (int)$w['id'],
                    'nxt20'      => number_format((int)$w['nxt20_retirados'], 0, ',', '.'),
                    'neto'       => number_format((int)$w['neto'], 0, ',', '.'),
                    'estado'     => $w['estado'],
                    'fecha'      => date('d/m/Y H:i', (int)$w['fecha']),
                    'cancelable' => ($w['estado'] === 'pendiente')
                ];
                break;
            }
        }

        $countActivas = count($solicitudesFormateadas);
        $maxActivas   = WalletHelper::MAX_SOLICITUDES_ACTIVAS;
        $puedeCrear   = ($countActivas < $maxActivas);

        // 🆕 Leemos el cajón de Kyber que corresponde al método del usuario
        $prefix = defined('DB_PREFIX') ? DB_PREFIX : 'uni1_';
        $db = Database::get();
        $fundRow = $db->selectSingle("SELECT kyber_banco_cup, kyber_banco_qvapay FROM ".$prefix."wallet_fund LIMIT 1");
        
        $kyberBancoReal = 0;
        if ($fundRow) {
            if ($this->metodoRetiro === 'CUP') {
                $kyberBancoReal = (int)$fundRow['kyber_banco_cup'];
            } else {
                $kyberBancoReal = (int)$fundRow['kyber_banco_qvapay'];
            }
        }
        
        // 🆕 FIX: El usuario ve el 100% de la liquidez real de su sistema
        $kyberBanco = $kyberBancoReal;

        $totalInvertido   = WalletHelper::getTotalInvertidoHistorico();
        $totalRetirado    = WalletHelper::getTotalRetiradoHistorico();

        $minRetiroNxt20 = WalletHelper::getMinRetiroNxt20();

        $esVIP           = $this->esVIP();
        $retirosAbiertos = WalletFundHelper::retirosAbiertos();

        $bankData = UserBankDataHelper::getDatos($this->userId);
        $solicitudCambio = UserBankDataHelper::getSolicitudPendiente($this->userId);

        $movimientosFormateados = [];
        foreach ($movimientos as $m) {
            $movimientosFormateados[] = [
                'tipo'      => $m['tipo'],
                'moneda'    => $m['moneda'],
                'cantidad'  => number_format((int)$m['cantidad'], 0, ',', '.'),
                'detalle'   => $m['detalle'],
                'fecha'     => date('d/m/Y H:i', (int)$m['fecha'])
            ];
        }

        $feedbackOk    = isset($_GET['ok']) ? $_GET['ok'] : '';
        $feedbackError = isset($_GET['error']) ? urldecode($_GET['error']) : '';

        $this->assign([
            'metodo_retiro'      => $this->metodoRetiro, 
            
            // 🆕 Enviamos las variables al TPL
            'qvapay_compra_activa' => $qvapay_compra_activa,
            'qvapay_retiro_activa' => $qvapay_retiro_activa,
            
            'nxt20_total'        => number_format($nxt20Total, 0, ',', '.'),
            'nxt20_total_raw'    => $nxt20Total,
            'nxt20_retirable'    => number_format($nxt20Retirable, 0, ',', '.'),
            'nxt20_retirable_raw'=> $nxt20Retirable,
            'nxt20_bloqueado'    => number_format($nxt20Bloqueado, 0, ',', '.'),
            'nxt20_bloqueado_raw'=> $nxt20Bloqueado,

            // 🆕 Aquí enviamos el Kyber real (sin el 30%)
            'kyber_banco'        => number_format($kyberBanco, 0, ',', '.'),
            'kyber_banco_raw'    => $kyberBanco,
            
            'total_invertido'    => number_format($totalInvertido, 0, ',', '.'),
            'total_invertido_raw'=> $totalInvertido,
            'total_retirado'     => number_format($totalRetirado, 0, ',', '.'),
            'total_retirado_raw' => $totalRetirado,

            'min_retiro_nxt20'   => $minRetiroNxt20,
            'retiros_abiertos'   => $retirosAbiertos,

            'es_vip'             => $esVIP,
            'tiene_referidor'    => ($referrerId !== null),
            'referrer_id'        => $referrerId ?: 0,

            'solicitudes'        => $solicitudesFormateadas,
            'solicitudes_count'  => $countActivas,
            'max_solicitudes'    => $maxActivas,
            'puede_crear'        => $puedeCrear,

            'retiro_pendiente'   => $retiroPendiente,

            'movimientos'        => $movimientosFormateados,

            'bank_data'          => $bankData,
            'solicitud_cambio'   => $solicitudCambio,

            'feedback_ok'        => $feedbackOk,
            'feedback_error'     => $feedbackError,
            'action_url'         => 'game.php?page=wallet',
            'username'           => $USER['username']
        ]);

        $this->display('page.wallet.default.tpl');
    }

    /* ════════════════════════════════════════════════════════════
     * ELECCIÓN DE MÉTODO (NUEVO)
     * ════════════════════════════════════════════════════════════ */

    // 🆕 Muestra la pantalla de elección
    public function elegir_metodo()
    {
        if ($this->metodoRetiro !== null) {
            $this->redirect('game.php?page=wallet');
        }
        $this->display('page.wallet.elegir_retiro.tpl');
    }

    // 🆕 Guarda la elección del usuario
    public function guardar_metodo()
    {
        if ($this->metodoRetiro !== null) {
            $this->redirect('game.php?page=wallet');
        }

        $metodo = isset($_POST['metodo']) ? $_POST['metodo'] : '';

        if (in_array($metodo, ['CUP', 'QVAPAY'])) {
            $prefix = defined('DB_PREFIX') ? DB_PREFIX : 'uni1_';
            $db = Database::get();
            try {
                $db->update(
                    "UPDATE ".$prefix."users SET metodo_retiro = :m WHERE id = :uid", 
                    [':m' => $metodo, ':uid' => $this->userId]
                );
            } catch (Exception $e) {
                $this->redirect('game.php?page=wallet&error='.urlencode('Error al guardar el método. Intenta de nuevo.'));
            }
        }

        // Si elige CUP, lo mandamos directo a cargar los datos bancarios
        if ($metodo === 'CUP') {
            $this->redirect('game.php?page=wallet&mode=setbankdata');
        } else {
            $this->redirect('game.php?page=wallet');
        }
    }

    /* ════════════════════════════════════════════════════════════
     * DEPOSITO / INVERSION
     * ════════════════════════════════════════════════════════════ */

    public function deposit()
    {
        global $USER;

        $this->verificarDatosBancarios();

        $countActivas = WalletHelper::contarActivasByUser($this->userId);
        $maxActivas   = WalletHelper::MAX_SOLICITUDES_ACTIVAS;
        $puedeCrear   = ($countActivas < $maxActivas);
        $feedbackError = isset($_GET['error']) ? urldecode($_GET['error']) : '';
        $referrerId = WalletHelper::getReferrerId($this->userId);

        $this->assign([
            'solicitudes_count'  => $countActivas,
            'max_solicitudes'    => $maxActivas,
            'puede_crear'        => $puedeCrear,
            'tiene_referidor'    => ($referrerId !== null),
            'referrer_id'        => $referrerId ?: 0,
            'feedback_error'     => $feedbackError,
            'action_url'         => 'game.php?page=wallet&mode=doInvest',
            'username'           => $USER['username']
        ]);

        $this->display('page.wallet.deposit.tpl');
    }

    public function deposit_qvapay()
    {
        global $USER;

        // 🆕 Verificamos que el admin tenga habilitada la compra
        if (!$this->isQvapayEnabled('buy')) {
            $this->redirect('game.php?page=wallet&error='.urlencode('La compra por QvaPay está deshabilitada temporalmente.'));
        }

        $feedbackError = isset($_GET['error']) ? urldecode($_GET['error']) : '';

        $this->assign([
            'feedback_error'     => $feedbackError,
            'username'           => $USER['username']
        ]);

        $this->display('page.wallet.deposit_qvapay.tpl');
    }

    public function doInvest()
    {
        $this->verificarDatosBancarios();

        $cantidad = isset($_POST['cantidad']) ? (int)$_POST['cantidad'] : 0;

        if ($cantidad <= 0) {
            $this->redirect('game.php?page=wallet&mode=deposit&error='.urlencode('La cantidad debe ser mayor a 0.'));
        }

        $referrerId = WalletHelper::getReferrerId($this->userId);

        $result = WalletHelper::createInvestment($this->userId, $cantidad, $referrerId);

        if (isset($result['error'])) {
            $this->redirect('game.php?page=wallet&mode=deposit&error='.urlencode($result['error']));
        }

        $this->redirect('game.php?page=wallet&ok=inversion_creada_'.$result['investment_id']);
    }

    /* ════════════════════════════════════════════════════════════
     * RETIRO (NUEVO FLUJO v6.0 y QvaPay v7.0)
     * ════════════════════════════════════════════════════════════ */

    public function withdraw()
    {
        global $USER;

        if ($this->metodoRetiro !== 'CUP') {
            $this->redirect('game.php?page=wallet&error='.urlencode('Tu método de retiro es QvaPay. No podés retirar por CUP.'));
        }

        $this->verificarDatosBancarios();

        if (!$this->esVIP()) {
            $this->redirect('game.php?page=wallet&error='.urlencode('Necesitas ser VIP para retirar. Compra un pase VIP primero.'));
        }

        if (!WalletFundHelper::retirosAbiertos()) {
            $this->redirect('game.php?page=wallet&error='.urlencode('Los retiros estan cerrados temporalmente.'));
        }

        $retirosPendientes = WalletHelper::contarRetirosPendientesByUser($this->userId);
        if ($retirosPendientes >= WalletHelper::MAX_RETIROS_PENDIENTES) {
            $this->redirect('game.php?page=wallet&error='.urlencode('Ya tenes un retiro pendiente. Espera a que se procese.'));
        }

        $nxt20Retirable = WalletHelper::getNxt20Retirable($this->userId);
        $minRetiroNxt20 = WalletHelper::getMinRetiroNxt20();

        $feedbackError = isset($_GET['error']) ? urldecode($_GET['error']) : '';

        $this->assign([
            'nxt20_retirable'     => number_format($nxt20Retirable, 0, ',', '.'),
            'nxt20_retirable_raw' => $nxt20Retirable,
            'min_retiro_nxt20'    => $minRetiroNxt20,
            'feedback_error'      => $feedbackError,
            'action_url'          => 'game.php?page=wallet&mode=solicitarRetiro',
            'username'            => $USER['username']
        ]);

        $this->display('page.wallet.withdraw.tpl');
    }

    public function withdraw_qvapay()
    {
        global $USER;

        if ($this->metodoRetiro !== 'QVAPAY') {
            $this->redirect('game.php?page=wallet&error='.urlencode('Tu método de retiro es CUP. No podés retirar por QvaPay.'));
        }
        
        // 🆕 Verificamos que el admin tenga habilitado el retiro por QvaPay
        if (!$this->isQvapayEnabled('withdraw')) {
            $this->redirect('game.php?page=wallet&error='.urlencode('Los retiros por QvaPay están deshabilitados temporalmente.'));
        }
        
        if (!$this->esVIP()) {
            $this->redirect('game.php?page=wallet&error='.urlencode('Necesitas ser VIP para retirar.'));
        }

        if (!WalletFundHelper::retirosAbiertos()) {
            $this->redirect('game.php?page=wallet&error='.urlencode('Los retiros estan cerrados temporalmente.'));
        }

        $retirosPendientes = WalletHelper::contarRetirosPendientesByUser($this->userId);
        if ($retirosPendientes >= WalletHelper::MAX_RETIROS_PENDIENTES) {
            $this->redirect('game.php?page=wallet&error='.urlencode('Ya tenes un retiro pendiente. Espera a que se procese.'));
        }

        $nxt20Retirable = WalletHelper::getNxt20Retirable($this->userId);
        $minRetiroNxt20 = WalletHelper::getMinRetiroNxt20();

        $feedbackError = isset($_GET['error']) ? urldecode($_GET['error']) : '';

        $this->assign([
            'nxt20_retirable'     => number_format($nxt20Retirable, 0, ',', '.'),
            'nxt20_retirable_raw' => $nxt20Retirable,
            'min_retiro_nxt20'    => $minRetiroNxt20,
            'feedback_error'      => $feedbackError,
            'username'            => $USER['username']
        ]);

        $this->display('page.wallet.withdraw_qvapay.tpl');
    }

    public function solicitarRetiro()
    {
        if ($this->metodoRetiro !== 'CUP') {
            $this->redirect('game.php?page=wallet&error='.urlencode('Método de retiro incorrecto.'));
        }

        $this->verificarDatosBancarios();

        if (!$this->esVIP()) {
            $this->redirect('game.php?page=wallet&error='.urlencode('Necesitas ser VIP para retirar.'));
        }

        if (!WalletFundHelper::retirosAbiertos()) {
            $this->redirect('game.php?page=wallet&error='.urlencode('Los retiros estan cerrados.'));
        }

        $nxt20 = isset($_POST['nxt20']) ? (int)$_POST['nxt20'] : 0;

        if ($nxt20 <= 0) {
            $this->redirect('game.php?page=wallet&mode=withdraw&error='.urlencode('La cantidad debe ser mayor a 0.'));
        }

        $result = WalletHelper::solicitarRetiro($this->userId, $nxt20);

        if (isset($result['error'])) {
            $this->redirect('game.php?page=wallet&mode=withdraw&error='.urlencode($result['error']));
        }

        $this->redirect('game.php?page=wallet&ok=retiro_solicitado');
    }

    public function cancelarRetiro()
    {
        $id     = isset($_POST['id']) ? (int)$_POST['id'] : 0;
        $motivo = isset($_POST['motivo']) ? trim($_POST['motivo']) : '';

        if ($id <= 0) {
            $this->redirect('game.php?page=wallet&error='.urlencode('ID inválido.'));
        }

        $result = WalletHelper::cancelarRetiro($id, $this->userId, $motivo);

        if (isset($result['error'])) {
            $this->redirect('game.php?page=wallet&error='.urlencode($result['error']));
        }

        $this->redirect('game.php?page=wallet&ok=retiro_cancelado');
    }

    /* ════════════════════════════════════════════════════════════
     * HISTORIAL
     * ════════════════════════════════════════════════════════════ */

    public function history()
    {
        global $USER;

        $movimientos = WalletHelper::getTransactions($this->userId, 100);
        $movimientosFormateados = [];
        foreach ($movimientos as $m) {
            $movimientosFormateados[] = [
                'tipo'      => $m['tipo'],
                'moneda'    => $m['moneda'],
                'cantidad'  => number_format((int)$m['cantidad'], 0, ',', '.'),
                'detalle'   => $m['detalle'],
                'fecha'     => date('d/m/Y H:i', (int)$m['fecha'])
            ];
        }

        $resueltas = WalletHelper::getHistorialByUser($this->userId, 100);
        $solicitudesFormateadas = [];
        foreach ($resueltas as $r) {
            $solicitudesFormateadas[] = $this->formatearSolicitud($r);
        }

        $esVIP           = $this->esVIP();
        $retirosAbiertos = WalletFundHelper::retirosAbiertos();

        $this->assign([
            'movimientos'      => $movimientosFormateados,
            'solicitudes'      => $solicitudesFormateadas,
            'es_vip'           => $esVIP,
            'retiros_abiertos' => $retirosAbiertos,
            'username'         => $USER['username']
        ]);

        $this->display('page.wallet.history.tpl');
    }

    /* ════════════════════════════════════════════════════════════
     * DETALLE DE SOLICITUD DE INVERSION
     * ════════════════════════════════════════════════════════════ */

    public function verSolicitud()
    {
        global $USER;

        $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;

        if ($id <= 0) {
            $this->redirect('game.php?page=wallet&error='.urlencode('ID inválido.'));
        }

        $inv = WalletHelper::getInvestmentById($id);

        if (!$inv) {
            $this->redirect('game.php?page=wallet&error='.urlencode('Solicitud no encontrada.'));
        }

        if ((int)$inv['user_id'] !== $this->userId) {
            $this->redirect('game.php?page=wallet&error='.urlencode('Esta solicitud no te pertenece.'));
        }

        $solicitud = $this->formatearSolicitud($inv);
        $puedeCancelar = WalletHelper::puedeCancelar($inv);
        $puedeSubirComprobante = ($inv['estado'] === 'datos_enviados');
        $mostrarBanco = in_array($inv['estado'], ['datos_enviados', 'pendiente_verificacion']);

        $logs = WalletHelper::getLogByInvestment($id);
        $logsFormateados = [];
        foreach ($logs as $l) {
            $logsFormateados[] = [
                'accion'  => $l['accion'],
                'detalle' => $l['detalle'],
                'admin'   => !empty($l['admin_name']) ? $l['admin_name'] : '',
                'fecha'   => date('d/m/Y H:i', (int)$l['fecha'])
            ];
        }

        $feedbackOk    = isset($_GET['ok']) ? $_GET['ok'] : '';
        $feedbackError = isset($_GET['error']) ? urldecode($_GET['error']) : '';

        $this->assign([
            'solicitud'               => $solicitud,
            'puede_cancelar'          => $puedeCancelar,
            'puede_subir_comprobante' => $puedeSubirComprobante,
            'mostrar_banco'           => $mostrarBanco,
            'logs'                    => $logsFormateados,
            'feedback_ok'             => $feedbackOk,
            'feedback_error'          => $feedbackError,
            'username'                => $USER['username']
        ]);

        $this->display('page.wallet.solicitud.tpl');
    }

    public function doSubirComprobante()
    {
        $id              = isset($_POST['id']) ? (int)$_POST['id'] : 0;
        $transferenciaId = isset($_POST['transferencia_id']) ? trim($_POST['transferencia_id']) : '';

        if ($id <= 0) {
            $this->redirect('game.php?page=wallet&error='.urlencode('ID inválido.'));
        }

        if ($transferenciaId === '') {
            $this->redirect('game.php?page=wallet&mode=verSolicitud&id='.$id.'&error='.urlencode('Debés ingresar el ID de transferencia.'));
        }

        $result = WalletHelper::subirComprobante($id, $this->userId, $transferenciaId);

        if (isset($result['error'])) {
            $this->redirect('game.php?page=wallet&mode=verSolicitud&id='.$id.'&error='.urlencode($result['error']));
        }

        $this->redirect('game.php?page=wallet&mode=verSolicitud&id='.$id.'&ok=comprobante_enviado');
    }

    public function doCancelar()
    {
        $id     = isset($_POST['id']) ? (int)$_POST['id'] : 0;
        $motivo = isset($_POST['motivo']) ? trim($_POST['motivo']) : '';

        if ($id <= 0) {
            $this->redirect('game.php?page=wallet&error='.urlencode('ID inválido.'));
        }

        $result = WalletHelper::cancelarSolicitud($id, $this->userId, $motivo);

        if (isset($result['error'])) {
            $this->redirect('game.php?page=wallet&mode=verSolicitud&id='.$id.'&error='.urlencode($result['error']));
        }

        $this->redirect('game.php?page=wallet&ok=solicitud_cancelada');
    }

    /* ════════════════════════════════════════════════════════════
     * DATOS BANCARIOS DEL USER
     * ════════════════════════════════════════════════════════════ */

    public function setbankdata()
    {
        global $USER;

        $bankData = UserBankDataHelper::getDatos($this->userId);
        $solicitudCambio = UserBankDataHelper::getSolicitudPendiente($this->userId);

        $feedbackOk    = isset($_GET['ok']) ? $_GET['ok'] : '';
        $feedbackError = isset($_GET['error']) ? urldecode($_GET['error']) : '';

        $this->assign([
            'bank_data'        => $bankData,
            'solicitud_cambio' => $solicitudCambio,
            'feedback_ok'      => $feedbackOk,
            'feedback_error'   => $feedbackError,
            'action_url'       => 'game.php?page=wallet&mode=doSetBankData',
            'username'         => $USER['username']
        ]);

        $this->display('page.wallet.setbankdata.tpl');
    }

    public function doSetBankData()
    {
        $tarjeta  = isset($_POST['tarjeta_magnetica']) ? trim($_POST['tarjeta_magnetica']) : '';
        $telefono = isset($_POST['telefono']) ? trim($_POST['telefono']) : '';
        $titular  = isset($_POST['titular']) ? trim($_POST['titular']) : '';
        $banco    = isset($_POST['banco']) ? trim($_POST['banco']) : '';

        if ($tarjeta === '' || $telefono === '') {
            $this->redirect('game.php?page=wallet&mode=setbankdata&error='.urlencode('Tarjeta y teléfono son obligatorios.'));
        }

        // 🆕 FLUJO LIMPIO: Guardamos o actualizamos directo, sin solicitudes de cambio.
        $result = UserBankDataHelper::saveDatos(
            $this->userId, $tarjeta, $telefono, $titular, $banco
        );

        if (isset($result['error'])) {
            $this->redirect('game.php?page=wallet&mode=setbankdata&error='.urlencode($result['error']));
        }

        $this->redirect('game.php?page=wallet&ok=datos_guardados');
    }

    /* ════════════════════════════════════════════════════════════
     * GRAFICO (AJAX)
     * ════════════════════════════════════════════════════════════ */

    public function getGrafico()
    {
        header('Content-Type: application/json');

        $horas = isset($_GET['horas']) ? (int)$_GET['horas'] : 360;
        if (!in_array($horas, [0, 24, 360, 720], true)) {
            $horas = 360;
        }

        $rows = WalletHelper::getGraficoFlujo($horas);

        $out = [];
        foreach ($rows as $r) {
            $out[] = [
                'fecha'          => date('d/m H:i', (int)$r['fecha']),
                'kyber_banco'    => (int)$r['kyber_banco'],
                'total_invertido'=> (int)$r['total_invertido'],
                'total_retirado' => (int)$r['total_retirado']
            ];
        }

        echo json_encode($out);
        exit;
    }
}