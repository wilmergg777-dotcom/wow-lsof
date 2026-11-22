<?php
/**
 *  AstroIO - Página de la Tienda (Jugador) con Doble Riel
 *  Archivo: includes/pages/game/ShowShopPage.class.php
 *  URL:     game.php?page=shop
 *  Compatible con 2Moons 2.0.git (PDO)
 *
 *  Reglas:
 *   - El admin define las ofertas (precio + cantidad)
 *   - Descuento VIP del 25% al precio base
 *   - Ofertas fijas o temporales (7, 15, 29 días)
 *   - Si no hay ofertas activas → mensaje "No hay ofertas activas"
 *   - 🆕 v1.4 (DOBLE RIEL): Si el jugador es QVAPAY, el precio en UNTX-20
 *     es el DOBLE (x2) que en NTX-20. El icono siempre es 💲.
 */

class ShowShopPage extends AbstractGamePage
{
    function __construct()
    {
        parent::__construct();

        if (!class_exists('ShopHelper')) {
            require_once ROOT_PATH . 'includes/classes/ShopHelper.class.php';
        }
    }

    /**
     * Prefijo de las tablas
     */
    private function getPrefix()
    {
        if (defined('DB_PREFIX')) return DB_PREFIX;
        if (defined('PREFIX'))    return PREFIX;
        return 'uni1_';
    }

    /**
     * Formatea una duración en segundos a texto legible
     */
    private function formatDuration($seconds)
    {
        $seconds = (int)$seconds;
        if ($seconds <= 0) return '—';

        $days  = (int)floor($seconds / 86400);
        $hours = (int)floor(($seconds % 86400) / 3600);
        $mins  = (int)floor(($seconds % 3600) / 60);

        if ($days > 0)  return $days.'d';
        if ($hours > 0) return $hours.'h';
        return $mins.'m';
    }

    /**
     * Formatea un countdown completo
     */
    private function formatCountdown($seconds)
    {
        $seconds = (int)$seconds;
        if ($seconds <= 0) return '0s';

        $days  = (int)floor($seconds / 86400);
        $hours = (int)floor(($seconds % 86400) / 3600);
        $mins  = (int)floor(($seconds % 3600) / 60);
        $secs  = $seconds % 60;

        $parts = array();
        if ($days  > 0) $parts[] = $days.'d';
        if ($hours > 0) $parts[] = $hours.'h';
        if ($mins  > 0) $parts[] = $mins.'m';
        if ($secs  > 0 || empty($parts)) $parts[] = $secs.'s';

        return implode(' ', $parts);
    }

    /**
     * Devuelve el estado de urgencia según el tiempo restante
     */
    private function getUrgencyState($segundosRestantes)
    {
        $segundosRestantes = (int)$segundosRestantes;
        if ($segundosRestantes <= 0)             return 'expired';
        if ($segundosRestantes < 86400)          return 'urgent';
        if ($segundosRestantes < 3 * 86400)      return 'soon';
        return 'far';
    }

    /**
     * Devuelve el HTML del icono para una oferta.
     */
    private function buildIconoItem($tipo, $iconoAdmin)
    {
        if (!empty($iconoAdmin)) {
            return (string)$iconoAdmin;
        }

        $cofreImages = array(
            'cofre_common'    => '100.gif',
            'cofre_rare'      => '200.gif',
            'cofre_legendary' => '300.gif',
        );

        if (isset($cofreImages[$tipo])) {
            $file = $cofreImages[$tipo];
            $alt  = 'Cofre';
            return '<img src="styles/theme/gow/gebaeude/'.$file.'" '
                 . 'alt="'.$alt.'" '
                 . 'style="max-height:48px;max-width:48px;vertical-align:middle;">';
        }

        return ShopHelper::getTypeIcon($tipo);
    }

    /**
     * Devuelve el texto de "info extra" según tipo.
     */
    private function buildInfoExtra($tipo, $itemId)
    {
        global $db;
        $prefix = $this->getPrefix();

        if ($tipo === 'booster') {
            $bRow = $db->selectSingle(
                "SELECT booster_value, booster_duration FROM `".$prefix."boosters` WHERE booster_id = :id;",
                [':id' => $itemId]
            );
            if ($bRow) {
                $valor  = (float)$bRow['booster_value'];
                $durTxt = $this->formatDuration((int)$bRow['booster_duration']);
                return '+'.$valor.'% durante '.$durTxt;
            }
            return '';
        }

        if ($tipo === 'cofre_common') {
            return 'Contenido aleatorio · Multiplicador x2';
        }
        if ($tipo === 'cofre_rare') {
            return 'Contenido aleatorio · Multiplicador x5';
        }
        if ($tipo === 'cofre_legendary') {
            return 'Contenido aleatorio · Multiplicador x7';
        }
        if ($tipo === 'cofre') {
            return 'Contenido aleatorio';
        }

        return '';
    }

    /**
     * 🆕 v1.4 — Prepara las ofertas con doble riel.
     *
     * Añade el método de pago para calcular el precio final:
     *   - Si es CUP: precio normal (con descuento VIP aplicado)
     *   - Si es QVAPAY: precio * 2 (con descuento VIP aplicado)
     */
    private function prepareOffers($rawOffers, $isVip, $method)
    {
        $result = array();
        foreach ($rawOffers as $o) {
            $precioBase = (int)$o['precio_ntx'];

            // 🆕 Detectar el multiplicador según el método
            $multiplier = ($method === 'QVAPAY') ? 2 : 1;

            // Precio final: primero VIP, luego multiplicador
            $precioFin = ShopHelper::getFinalPrice($precioBase, $isVip, $method);
            $descuento = ($precioBase * $multiplier) - $precioFin;

            $tipo      = (string)$o['tipo'];
            $itemId    = (int)$o['item_id'];
            $cantidad  = max(1, (int)$o['cantidad']);
            $tipoIcon  = ShopHelper::getTypeIcon($tipo);
            $tipoLabel = ShopHelper::getTypeLabel($tipo);

            $iconoAdmin = isset($o['icono']) ? (string)$o['icono'] : '';
            $iconoItem  = $this->buildIconoItem($tipo, $iconoAdmin);

            $nombreReal = ShopHelper::getItemName($tipo, $itemId, '—');
            $infoExtra  = $this->buildInfoExtra($tipo, $itemId);
            $cantidadTxt = ($cantidad === 1) ? '1 unidad' : $cantidad.' unidades';

            // Expiración
            $expira       = (int)($o['expira'] ?? 0);
            $expiraEn     = (int)($o['expira_en'] ?? 0);
            $duracionDias = (int)($o['duracion_dias'] ?? 0);

            $esTemporal       = ($expira === 1 && $expiraEn > 0);
            $tiempoRestante   = $esTemporal ? ($expiraEn - TIMESTAMP) : 0;
            $tiempoTexto      = $esTemporal ? $this->formatCountdown(max(0, $tiempoRestante)) : '';
            $urgencia         = $esTemporal ? $this->getUrgencyState($tiempoRestante) : 'permanent';
            $expiraFecha      = $esTemporal ? date('d/m/Y H:i', $expiraEn) : '';

            $result[] = array(
                'id'             => (int)$o['id'],
                'nombre'         => (string)$o['nombre'],
                'nombre_real'    => $nombreReal,
                'descripcion'    => (string)$o['descripcion'],
                'tipo'           => $tipo,
                'tipo_icon'      => $tipoIcon,
                'tipo_label'     => $tipoLabel,
                'icono_item'     => $iconoItem,
                'cantidad'       => $cantidad,
                'cantidad_txt'   => $cantidadTxt,

                // Precios con multiplicador
                'precio_base'    => $precioBase * $multiplier,
                'precio_final'   => $precioFin,
                'descuento'      => max(0, $descuento),
                'popular'        => (int)$o['popular'],
                'tiene_desc'     => !empty($o['descripcion']),
                'muestra_desc'   => $isVip && $descuento > 0,
                'info_extra'     => $infoExtra,

                // Expiración
                'es_temporal'    => $esTemporal,
                'expira'         => $expira,
                'expira_en'      => $expiraEn,
                'expira_fecha'   => $expiraFecha,
                'duracion_dias'  => $duracionDias,
                'tiempo_restante'=> max(0, $tiempoRestante),
                'tiempo_texto'   => $tiempoTexto,
                'urgencia'       => $urgencia,
            );
        }
        return $result;
    }

    public function show()
    {
        global $USER, $LNG;

        $userId  = isset($USER['id']) ? (int)$USER['id'] : 0;
        $message = '';
        $msgType = 'info';

        // ============================================
        // PROCESAR COMPRA
        // ============================================
        if (isset($_POST['action']) && $_POST['action'] === 'buy') {
            $itemId = isset($_POST['item_id']) ? (int)$_POST['item_id'] : 0;

            if ($itemId <= 0) {
                $message = '❌ Oferta no válida.';
                $msgType = 'error';
            } else {
                $result  = ShopHelper::buy($userId, $itemId);
                $message = $result['msg'];
                $msgType = $result['ok'] ? 'success' : 'error';
            }
        }

        // ============================================
        // 🆕 DETECTAR MÉTODO Y MONEDA
        // ============================================
        $method  = ShopHelper::getPlayerMethod($userId);
        $moneda  = ShopHelper::getCurrencyLabel($method);
        $isInternational = ($method === 'QVAPAY');

        // ============================================
        // CARGAR DATOS PARA LA VISTA
        // ============================================
        $isVip    = ShopHelper::isVip($userId);
        $saldo    = ShopHelper::getBalance($userId);
        $raw      = ShopHelper::getOffers();
        $hasOffer = count($raw) > 0;

        // 🆕 Pasar el método a prepareOffers
        $offers = $this->prepareOffers($raw, $isVip, $method);

        $temporalesCount = 0;
        foreach ($offers as $of) {
            if (!empty($of['es_temporal'])) $temporalesCount++;
        }

        $vipDiscountPct = (int)(ShopHelper::VIP_DISCOUNT * 100);

        $this->assign(array(
            'is_vip'            => $isVip,
            'vip_discount_pct'  => $vipDiscountPct,

            // 🆕 Doble riel
            'metodo_retiro'     => $method,
            'moneda'            => $moneda,          // 'NTX-20' o 'UNTX-20'
            'es_internacional'  => $isInternational, // true/false

            'saldo'             => $saldo,
            'has_offer'         => $hasOffer,
            'offers'            => $offers,
            'offers_count'      => count($offers),
            'temporales_count'  => $temporalesCount,
            'message'           => $message,
            'msgType'           => $msgType,

            // Título dinámico
            'pageTitle'         => 'Tienda ' . $moneda,
            'shop_url'          => 'game.php?page=shop',
        ));

        $this->display('page.shop.default.tpl');
    }
}