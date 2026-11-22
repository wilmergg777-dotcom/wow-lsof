<?php
/**
 * ShowBattlepassPage — Página del Pase de Batalla (jugador)
 * AstroIO v1.5 — Doble Riel (CUP / QvaPay)
 *
 * URL: game.php?page=battlepass
 * Modos:
 *   - show()             -> Vista principal con los 60 niveles
 *   - reclamar()         -> POST reclamar recompensa
 *   - reclamarTodo()     -> POST reclamar todas las recompensas disponibles
 *
 * Cambios v1.1 (FASE 1 — Bug fixes):
 *   - FIX: reclamarTodo() ya no confia en la lectura stale de claimed_*.
 *   - FIX: reclamar() propaga el motivo del error via URL.
 *   - Mejora: getMsgError() muestra el motivo real.
 *
 * Cambios v1.2 (FASE 2 — Mostrar que se entrega):
 *   - formatearRecompensa() muestra NOMBRE REAL de nave o defensa.
 *   - reclamar() pasa el mensaje de entrega via URL.
 *   - getMsgSuccess() muestra "Recompensa reclamada: +5 Cazador Ligero".
 *
 * Cambios v1.3 (FASE 3 — Compatibilidad con Helper v1.5):
 *   - Soporte para mensajes de ALTERNATIVA.
 *
 * Cambios v1.4 (FASE 4 — Compatibilidad con Helper v1.6):
 *   - FIX CRITICO: esMensajeAlternativa() NO detectaba los mensajes
 *     nuevos del Helper v1.6 ("sustituye a ... por requisitos, valor
 *     equivalente").
 *
 * Cambios v1.5 (FASE 5 — Doble Riel):
 *   - NEW: show() detecta el método del jugador (CUP o QVAPAY).
 *   - NEW: formatearRecompensa() recibe $method y muestra UNTX-20 con el
 *     DOBLE de cantidad si el jugador es internacional.
 *   - NEW: Los textos de cofre_final_vip también se adaptan.
 */

if (!defined('MODE')) die('Hacking attempt');

require_once ROOT_PATH . 'includes/classes/BattlePassHelper.class.php';

class ShowBattlepassPage extends AbstractGamePage
{
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

        $userId = (int)$USER['id'];

        // Verificar reinicio automático (32 días)
        BattlePassHelper::verificarReinicio();

        // Obtener datos
        $user      = BattlePassHelper::getUsuario($userId);
        $config    = BattlePassHelper::getConfig();
        $tiempo    = BattlePassHelper::getTiempoRestante();
        $vipActivo = BattlePassHelper::esVipActivo($userId);

        // 🆕 v1.5: Detectar método de pago del jugador
        $method = BattlePassHelper::getPlayerMethod($userId);

        // Preparar niveles para el template
        $niveles = [];
        foreach ($user['levels_data'] as $n => $data) {
            $nivel = (int)$n;

            // Estado carril normal
            if (!empty($user['claimed_normal'][$nivel - 1])) {
                $estadoNormal = 'reclamado';
            } elseif ($nivel <= (int)$user['current_level']) {
                $estadoNormal = 'disponible';
            } else {
                $estadoNormal = 'bloqueado';
            }

            // Estado carril VIP
            if (!empty($user['claimed_vip'][$nivel - 1])) {
                $estadoVip = 'reclamado';
            } elseif (!$vipActivo) {
                $estadoVip = 'sin_vip';
            } elseif ($nivel <= (int)$user['current_level']) {
                $estadoVip = 'disponible';
            } else {
                $estadoVip = 'bloqueado';
            }

            // Preparar datos de recompensa normal
            if ($data['es_cofre_normal']) {
                $recompensaNormal = [
                    'icono'    => '🎁',
                    'texto'    => 'COFRE',
                    'cantidad' => 0,
                    'nombre'   => 'Cofre'
                ];
            } else {
                // 🆕 Pasar $method a formatearRecompensa
                $recompensaNormal = $this->formatearRecompensa($data['normal_reward'], $method);
            }

            // Preparar datos de recompensa VIP
            if ($data['es_cofre_vip']) {
                $recompensaVip = [
                    'icono'    => '🎁',
                    'texto'    => 'COFRE VIP',
                    'cantidad' => 0,
                    'nombre'   => 'Cofre VIP'
                ];
            } else {
                // 🆕 Pasar $method a formatearRecompensa
                $recompensaVip = $this->formatearRecompensa($data['vip_reward'], $method);
            }

            $niveles[] = [
                'nivel'             => $nivel,
                'coste'             => BattlePassHelper::getCoste($nivel),
                'estado_normal'     => $estadoNormal,
                'estado_vip'        => $estadoVip,
                'recompensa_normal' => $recompensaNormal,
                'recompensa_vip'    => $recompensaVip,
                'es_cofre_normal'   => $data['es_cofre_normal'],
                'es_cofre_vip'      => $data['es_cofre_vip'],
            ];
        }

        // Calcular progreso hacia el siguiente nivel
        $nivelActual = (int)$user['current_level'];
        $monedas     = (int)$user['current_coins'];

        if ($nivelActual < BattlePassHelper::NUM_NIVELES) {
            $costeSig = BattlePassHelper::getCoste($nivelActual + 1);
            $porcentaje = $costeSig > 0 ? min(100, (int)(($monedas / $costeSig) * 100)) : 0;
        } else {
            $costeSig   = 0;
            $porcentaje = 100;
        }

        // Contar recompensas disponibles para reclamar
        $reclamablesNormal = 0;
        $reclamablesVip    = 0;
        for ($i = 0; $i < $nivelActual; $i++) {
            if (empty($user['claimed_normal'][$i])) $reclamablesNormal++;
            if ($vipActivo && empty($user['claimed_vip'][$i])) $reclamablesVip++;
        }

        // Asignar variables al template
        $this->assign([
            'userId'            => $userId,
            'username'          => $USER['username'],
            'seasonName'        => $config['season_name'],
            'tiempoRestante'    => $tiempo['texto'],
            'nivelActual'       => $nivelActual,
            'totalNiveles'      => BattlePassHelper::NUM_NIVELES,
            'monedasActuales'   => $monedas,
            'costeSiguiente'    => $costeSig,
            'porcentaje'        => $porcentaje,
            'vipActivo'         => $vipActivo,
            'niveles'           => $niveles,
            'reclamablesNormal' => $reclamablesNormal,
            'reclamablesVip'    => $reclamablesVip,
            'msgSuccess'        => $this->getMsgSuccess(),
            'msgError'          => $this->getMsgError(),
            'esAlternativa'     => $this->esAlternativa(),
            // 🆕 v1.5
            'metodo_retiro'     => $method,
            'moneda'            => BattlePassHelper::getCurrencyLabel($method),
        ]);

        $this->display('page.battlepass.default.tpl');
    }

    /* ============================================================
     * RECLAMAR UNA RECOMPENSA
     * ============================================================ */
    public function reclamar()
    {
        global $USER;

        $userId = (int)$USER['id'];
        $nivel  = isset($_POST['nivel']) ? (int)$_POST['nivel'] : 0;
        $carril = isset($_POST['carril']) ? $_POST['carril'] : 'normal';

        if ($nivel < 1 || $nivel > BattlePassHelper::NUM_NIVELES) {
            $this->bpRedirect('game.php?page=battlepass&msg=error&reason=' . urlencode('Nivel invalido.'));
            return;
        }

        $result = BattlePassHelper::reclamar($userId, $nivel, $carril);

        if (!empty($result['success'])) {
            $entrega = isset($result['message']) ? $result['message'] : '';
            $url = 'game.php?page=battlepass&msg=reclamado';
            if ($entrega !== '') {
                $url .= '&entrega=' . urlencode($entrega);
            }
            if ($this->esMensajeAlternativa($entrega)) {
                $url .= '&es_alt=1';
            }
            $this->bpRedirect($url);
        } else {
            $reason = isset($result['message']) ? $result['message'] : 'No se pudo reclamar.';
            $this->bpRedirect('game.php?page=battlepass&msg=error&reason=' . urlencode($reason));
        }
    }

    /* ============================================================
     * RECLAMAR TODAS LAS DISPONIBLES
     * ============================================================ */
    public function reclamarTodo()
    {
        global $USER;

        $userId = (int)$USER['id'];
        $user   = BattlePassHelper::getUsuario($userId);
        $vip    = BattlePassHelper::esVipActivo($userId);

        $reclamadas   = 0;
        $errores      = 0;
        $alternativas = 0;
        $nivelActual  = (int)$user['current_level'];

        // Carril Normal
        for ($i = 0; $i < $nivelActual; $i++) {
            $r = BattlePassHelper::reclamar($userId, $i + 1, 'normal');

            if (!empty($r['success'])) {
                $reclamadas++;
                if ($this->esMensajeAlternativa($r['message'] ?? '')) {
                    $alternativas++;
                }
            } else {
                $msg = isset($r['message']) ? $r['message'] : '';
                if (strpos($msg, 'Ya reclamaste') === false) {
                    $errores++;
                }
            }
        }

        // Carril VIP
        if ($vip) {
            for ($i = 0; $i < $nivelActual; $i++) {
                $r = BattlePassHelper::reclamar($userId, $i + 1, 'vip');

                if (!empty($r['success'])) {
                    $reclamadas++;
                    if ($this->esMensajeAlternativa($r['message'] ?? '')) {
                        $alternativas++;
                    }
                } else {
                    $msg = isset($r['message']) ? $r['message'] : '';
                    if (strpos($msg, 'Ya reclamaste') === false) {
                        $errores++;
                    }
                }
            }
        }

        $url = 'game.php?page=battlepass&msg=reclamado_todo&count=' . $reclamadas;
        if ($errores > 0) {
            $url .= '&errors=' . $errores;
        }
        if ($alternativas > 0) {
            $url .= '&alternativas=' . $alternativas;
        }
        $this->bpRedirect($url);
    }

    /* ============================================================
     * DETECTAR SI UN MENSAJE ES UNA ALTERNATIVA
     * ============================================================ */
    private function esMensajeAlternativa($mensaje)
    {
        if (empty($mensaje)) return false;

        $patrones = [
            'sustituye a',
            'valor equivalente',
            'recursos equivalentes',
            'no disponible',
            'alternativa basica',
            'sin naves desbloqueadas',
            'sin defensas desbloqueadas',
        ];

        foreach ($patrones as $patron) {
            if (stripos($mensaje, $patron) !== false) {
                return true;
            }
        }
        return false;
    }

    /* ============================================================
     * DETECTAR SI LA ULTIMA ENTREGA FUE ALTERNATIVA (via URL)
     * ============================================================ */
    private function esAlternativa()
    {
        return isset($_GET['es_alt']) && $_GET['es_alt'] == '1';
    }

    /* ============================================================
     * 🆕 v1.5 — FORMATEAR RECOMPENSA CON DOBLE RIEL
     *
     * $method: 'CUP' o 'QVAPAY'
     * - Si es QVAPAY y la recompensa es NTX-20, mostrar UNTX-20 (x2).
     * ============================================================ */
    private function formatearRecompensa($recompensa, $method = 'CUP')
    {
        if (!$recompensa) {
            return [
                'icono'    => '❓',
                'texto'    => '???',
                'cantidad' => 0,
                'nombre'   => '???'
            ];
        }

        $tipo = $recompensa['tipo'] ?? '';
        $esInternacional = ($method === 'QVAPAY');

        switch ($tipo) {
            case 'ntx20':
                $cantBase = (int)$recompensa['cantidad'];
                $cantFinal = $esInternacional ? ($cantBase * 2) : $cantBase;
                $moneda = $esInternacional ? 'UNTX-20' : 'NTX-20';
                return [
                    'icono'    => '🪙',
                    'texto'    => '+' . $cantFinal . ' ' . $moneda,
                    'cantidad' => $cantFinal,
                    'nombre'   => $moneda
                ];

            case 'recurso':
                $recurso = $recompensa['recurso'];
                $iconos  = ['metal' => '⛏️', 'crystal' => '💎', 'deuterium' => '🧪'];
                $nombres = ['metal' => 'Metal', 'crystal' => 'Cristal', 'deuterium' => 'Deuterio'];
                $icono   = $iconos[$recurso]  ?? '📦';
                $nombre  = $nombres[$recurso] ?? ucfirst($recurso);
                $cant    = (int)$recompensa['cantidad'];
                $abrev   = $this->abreviarNumero($cant);
                return [
                    'icono'    => $icono,
                    'texto'    => '+' . $abrev . ' ' . $nombre,
                    'cantidad' => $cant,
                    'nombre'   => $nombre
                ];

            case 'nave':
                $cant   = (int)$recompensa['cantidad'];
                $nombre = BattlePassHelper::nombreLegible($recompensa['columna'], 'nave');
                return [
                    'icono'    => '🚀',
                    'texto'    => '+' . $cant . ' ' . $nombre,
                    'cantidad' => $cant,
                    'nombre'   => $nombre
                ];

            case 'defensa':
                $cant   = (int)$recompensa['cantidad'];
                $nombre = BattlePassHelper::nombreLegible($recompensa['columna'], 'defensa');
                return [
                    'icono'    => '🛡️',
                    'texto'    => '+' . $cant . ' ' . $nombre,
                    'cantidad' => $cant,
                    'nombre'   => $nombre
                ];

            case 'cofre_final_vip':
                $cantBase = (int)$recompensa['ntx20'];
                $cantFinal = $esInternacional ? ($cantBase * 2) : $cantBase;
                $moneda = $esInternacional ? 'UNTX-20' : 'NTX-20';
                $nave = BattlePassHelper::nombreLegible($recompensa['nave'], 'nave');
                return [
                    'icono'    => '🎁',
                    'texto'    => 'COFRE VIP FINAL',
                    'cantidad' => $cantFinal,
                    'nombre'   => 'Cofre VIP Final (' . $cantFinal . ' ' . $moneda . ' + ' . $nave . ')'
                ];
        }

        return [
            'icono'    => '🎁',
            'texto'    => 'Premio',
            'cantidad' => 0,
            'nombre'   => 'Premio'
        ];
    }

    /* ============================================================
     * ABREVIAR NÚMEROS (10K, 1M, etc)
     * ============================================================ */
    private function abreviarNumero($n)
    {
        $n = (int)$n;
        if ($n >= 1000000) return round($n / 1000000, 1) . 'M';
        if ($n >= 1000)    return round($n / 1000, 1) . 'K';
        return (string)$n;
    }

    /* ============================================================
     * MENSAJES DE REDIRECCIÓN
     * ============================================================ */
    private function getMsgSuccess()
    {
        if (!isset($_GET['msg'])) return '';
        switch ($_GET['msg']) {
            case 'reclamado':
                if (isset($_GET['entrega']) && $_GET['entrega'] !== '') {
                    $esAlt = isset($_GET['es_alt']) && $_GET['es_alt'] == '1';
                    $prefijo = $esAlt
                        ? '⚠ Recompensa sustituida (mismo valor): '
                        : '✅ Recompensa reclamada: ';
                    return $prefijo
                        . htmlspecialchars($_GET['entrega'], ENT_QUOTES, 'UTF-8');
                }
                return '✅ Recompensa reclamada con éxito.';

            case 'reclamado_todo':
                $count        = isset($_GET['count'])        ? (int)$_GET['count']        : 0;
                $errors       = isset($_GET['errors'])       ? (int)$_GET['errors']       : 0;
                $alternativas = isset($_GET['alternativas']) ? (int)$_GET['alternativas'] : 0;

                if ($alternativas > 0) {
                    $msg = '⚠ Recompensas reclamadas (' . $count . ' en total, '
                         . $alternativas . ' sustituidas por valor equivalente).';
                } else {
                    $msg = '✅ Se reclamaron ' . $count . ' recompensa(s).';
                }
                if ($errors > 0) {
                    $msg .= ' (' . $errors . ' con error)';
                }
                return $msg;
        }
        return '';
    }

    private function getMsgError()
    {
        if (!isset($_GET['msg'])) return '';
        switch ($_GET['msg']) {
            case 'error_nivel':
                return '❌ Nivel inválido.';
            case 'error':
                if (isset($_GET['reason']) && $_GET['reason'] !== '') {
                    return '❌ ' . htmlspecialchars($_GET['reason'], ENT_QUOTES, 'UTF-8');
                }
                return '❌ No se pudo reclamar la recompensa.';
        }
        return '';
    }

    /* ============================================================
     * REDIRECCIÓN (renombrado para no chocar con AbstractGamePage)
     * ============================================================ */
    private function bpRedirect($url)
    {
        header('Location: ' . $url);
        exit;
    }
}