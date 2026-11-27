<?php
/**
 *  AstroIO - Panel Admin de la Tienda NTX-20
 *  Archivo: includes/pages/adm/ShowShopAdminPage.php
 *  URL:     admin.php?page=shopadmin
 *  Compatible con 2Moons 2.0.git (PDO)
 *
 *  Pestañas:
 *   - 📦 Ofertas (CRUD + activar/desactivar + duración)
 *   - 💾 Plantillas (guardar/cargar/renombrar/borrar)
 *   - 📜 Historial (compras de todos los jugadores)
 *
 *  Extras:
 *   - 🔄 Rollback del último cambio (auto-snapshot)
 *   - ⏰ Soporte para ofertas temporales (7, 15, 29 días)
 *
 *  FIX 2026-10-18:
 *   - HTTP::_GP ahora recibe `true` como tercer parámetro para forzar
 *     la codificación UTF-8 (multibyte). Esto permite guardar emojis (4 bytes)
 *     sin que se conviertan en "?".
 *   - Se agregó el cálculo de `expira_fmt` para `$editOffer` cuando se edita
 *     una oferta, evitando el error "Undefined array key expira_fmt" en el template.
 *
 *  v1.1 (2026-11-08):
 *   - Revisado para cofres climáticos. No requiere cambios en el backend
 *     porque los tipos se pasan como string genérico al Helper.
 *   - La lógica visual (opciones del desplegable) recae en el .tpl.
 */

function ShowShopAdmin()
{
    global $LNG, $USER;

    if (!class_exists('ShopHelper')) {
        require_once ROOT_PATH . 'includes/classes/ShopHelper.class.php';
    }

    $prefix  = defined('DB_PREFIX') ? DB_PREFIX : 'uni1_';
    $tab     = HTTP::_GP('tab', 'offers');
    $mode    = HTTP::_GP('mode', '');

    $message = '';
    $msgType = 'info';

    // ============================================================
    // PROCESAR ACCIONES
    // ============================================================

    // ---------- CREAR OFERTA ----------
    if ($mode === 'create') {
        ShopHelper::createAutosave('Antes de crear oferta', (int)$USER['id']);
        ShopHelper::createOffer(array(
            'nombre'      => HTTP::_GP('nombre', '', true), // true = multibyte (UTF-8)
            'descripcion' => HTTP::_GP('descripcion', '', true),
            'tipo'        => HTTP::_GP('tipo', 'recurso'),
            'item_id'     => (int)HTTP::_GP('item_id', 0),
            'cantidad'    => (int)HTTP::_GP('cantidad', 1),
            'precio_ntx'  => (int)HTTP::_GP('precio_ntx', 0),
            'icono'       => HTTP::_GP('icono', '', true),
            'popular'     => (int)HTTP::_GP('popular', 0),
            'activo'      => (int)HTTP::_GP('activo', 1),
            'orden'       => (int)HTTP::_GP('orden', 0),
            'duracion'    => (int)HTTP::_GP('duracion', 0),
        ));
        $message = '✅ Oferta creada correctamente.';
        $msgType = 'success';
    }

    // ---------- ACTUALIZAR OFERTA ----------
    if ($mode === 'update') {
        $id = (int)HTTP::_GP('id', 0);
        if ($id > 0) {
            ShopHelper::createAutosave('Antes de editar oferta #'.$id, (int)$USER['id']);
            ShopHelper::updateOffer($id, array(
                'nombre'      => HTTP::_GP('nombre', '', true),
                'descripcion' => HTTP::_GP('descripcion', '', true),
                'tipo'        => HTTP::_GP('tipo', 'recurso'),
                'item_id'     => (int)HTTP::_GP('item_id', 0),
                'cantidad'    => (int)HTTP::_GP('cantidad', 1),
                'precio_ntx'  => (int)HTTP::_GP('precio_ntx', 0),
                'icono'       => HTTP::_GP('icono', '', true),
                'popular'     => (int)HTTP::_GP('popular', 0),
                'activo'      => (int)HTTP::_GP('activo', 1),
                'orden'       => (int)HTTP::_GP('orden', 0),
                'duracion'    => (int)HTTP::_GP('duracion', 0),
            ));
            $message = '✅ Oferta actualizada.';
            $msgType = 'success';
        }
    }

    // ---------- BORRAR OFERTA ----------
    if ($mode === 'delete') {
        $id = (int)HTTP::_GP('id', 0);
        if ($id > 0) {
            ShopHelper::createAutosave('Antes de borrar oferta #'.$id, (int)$USER['id']);
            ShopHelper::deleteOffer($id);
            $message = '🗑️ Oferta borrada.';
            $msgType = 'success';
        }
    }

    // ---------- TOGGLE ACTIVO ----------
    if ($mode === 'toggle') {
        $id = (int)HTTP::_GP('id', 0);
        if ($id > 0) {
            ShopHelper::createAutosave('Antes de toggle oferta #'.$id, (int)$USER['id']);
            ShopHelper::toggleOffer($id);
            $message = '🔄 Oferta actualizada.';
            $msgType = 'success';
        }
    }

    // ---------- GUARDAR PLANTILLA ----------
    if ($mode === 'saveTemplate') {
        $nombre = HTTP::_GP('template_nombre', '', true);
        $desc   = HTTP::_GP('template_desc', '', true);
        if (!empty($nombre)) {
            ShopHelper::saveTemplate($nombre, $desc, (int)$USER['id']);
            $message = '💾 Plantilla guardada: '.htmlspecialchars($nombre);
            $msgType = 'success';
        } else {
            $message = '❌ El nombre de la plantilla no puede estar vacío.';
            $msgType = 'error';
        }
    }

    // ---------- CARGAR PLANTILLA ----------
    if ($mode === 'loadTemplate') {
        $id = (int)HTTP::_GP('id', 0);
        if ($id > 0 && ShopHelper::loadTemplate($id)) {
            $message = '📥 Plantilla cargada. Todas las ofertas fueron reemplazadas.';
            $msgType = 'success';
        } else {
            $message = '❌ No se pudo cargar la plantilla.';
            $msgType = 'error';
        }
    }

    // ---------- RENOMBRAR PLANTILLA ----------
    if ($mode === 'renameTemplate') {
        $id   = (int)HTTP::_GP('id', 0);
        $nom  = HTTP::_GP('template_nombre', '', true);
        $desc = HTTP::_GP('template_desc', '', true);
        if ($id > 0 && !empty($nom)) {
            ShopHelper::renameTemplate($id, $nom, $desc);
            $message = '✏️ Plantilla renombrada.';
            $msgType = 'success';
        }
    }

    // ---------- BORRAR PLANTILLA ----------
    if ($mode === 'deleteTemplate') {
        $id = (int)HTTP::_GP('id', 0);
        if ($id > 0) {
            ShopHelper::deleteTemplate($id);
            $message = '🗑️ Plantilla borrada.';
            $msgType = 'success';
        }
    }

    // ---------- ROLLBACK ----------
    if ($mode === 'rollback') {
        if (ShopHelper::restoreLastAutosave()) {
            $message = '🔄 Rollback aplicado correctamente.';
            $msgType = 'success';
        } else {
            $message = '❌ No hay auto-snapshot disponible.';
            $msgType = 'error';
        }
    }

    // ============================================================
    // CARGAR DATOS PARA LA VISTA
    // ============================================================

    // Ofertas (con datos de expiración)
    $offers = ShopHelper::getAllOffers();
    foreach ($offers as &$o) {
        $o['tipo_label'] = ShopHelper::getTypeLabel($o['tipo']);
        $o['tipo_icon']  = ShopHelper::getTypeIcon($o['tipo']);
        $o['item_name']  = ShopHelper::getItemName($o['tipo'], $o['item_id'], '—');
        $o['fecha_creacion_fmt'] = !empty($o['fecha_creacion'])
            ? date('d/m/Y H:i', (int)$o['fecha_creacion'])
            : '—';
        $o['fecha_actualizacion_fmt'] = !empty($o['fecha_actualizacion'])
            ? date('d/m/Y H:i', (int)$o['fecha_actualizacion'])
            : '—';

        // Datos de expiración
        $expira       = (int)($o['expira'] ?? 0);
        $expiraEn     = (int)($o['expira_en'] ?? 0);
        $duracionDias = (int)($o['duracion_dias'] ?? 0);

        $o['es_temporal']      = ($expira === 1 && $expiraEn > 0);
        $o['duracion_label']   = '—';
        $o['expira_fmt']       = '—';
        $o['tiempo_restante_txt'] = '—';

        if ($o['es_temporal']) {
            $restante = $expiraEn - TIMESTAMP;

            // Fecha legible
            $o['expira_fmt'] = date('d/m/Y H:i', $expiraEn);

            // Duración
            $duraciones = ShopHelper::getDuraciones();
            $o['duracion_label'] = isset($duraciones[$duracionDias])
                ? $duraciones[$duracionDias]
                : $duracionDias.' días';

            // Tiempo restante
            if ($restante > 0) {
                $d = (int)floor($restante / 86400);
                $h = (int)floor(($restante % 86400) / 3600);
                $m = (int)floor(($restante % 3600) / 60);

                $parts = array();
                if ($d > 0) $parts[] = $d.'d';
                if ($h > 0) $parts[] = $h.'h';
                if ($m > 0) $parts[] = $m.'m';
                if (empty($parts)) $parts[] = '<1m';

                $o['tiempo_restante_txt'] = implode(' ', $parts);

                // Urgencia
                if ($restante < 86400)         $o['urgencia'] = 'urgent';
                elseif ($restante < 3 * 86400) $o['urgencia'] = 'soon';
                else                            $o['urgencia'] = 'permanent';
            } else {
                $o['tiempo_restante_txt'] = 'Expirada';
                $o['urgencia'] = 'expired';
            }
        } else {
            $o['urgencia'] = 'permanent';
        }
    }
    unset($o);

    // Catálogos para el desplegable dinámico
    $shipsCatalog    = ShopHelper::getShipsCatalog();
    $defensesCatalog = ShopHelper::getDefensesCatalog();
    $missilesCatalog = ShopHelper::getMissilesCatalog();
    $boostersCatalog = ShopHelper::getBoostersCatalog();

    // Duraciones disponibles para el selector
    $duracionesDisponibles = ShopHelper::getDuraciones();

    // Plantillas
    $templates = ShopHelper::getTemplates();
    foreach ($templates as &$t) {
        $t['fecha_creacion_fmt']     = !empty($t['fecha_creacion'])
            ? date('d/m/Y H:i', (int)$t['fecha_creacion'])
            : '—';
        $t['fecha_actualizacion_fmt'] = !empty($t['fecha_actualizacion'])
            ? date('d/m/Y H:i', (int)$t['fecha_actualizacion'])
            : '—';
    }
    unset($t);

    // Historial
    $history = ShopHelper::getAllHistory(100);
    foreach ($history as &$h) {
        $h['fecha_fmt'] = !empty($h['fecha'])
            ? date('d/m/Y H:i', (int)$h['fecha'])
            : '—';
    }
    unset($h);

    // Auto-snapshot (rollback)
    $lastAuto = ShopHelper::getLastAutosave();
    $hasAuto  = !empty($lastAuto);
    $lastAutoAccion = $hasAuto ? $lastAuto['accion'] : '';
    $lastAutoFecha  = $hasAuto && !empty($lastAuto['fecha'])
        ? date('d/m/Y H:i', (int)$lastAuto['fecha'])
        : '';

    // Oferta a editar (si viene por GET)
    $editOffer = null;
    if ($mode === 'edit') {
        $editId = (int)HTTP::_GP('id', 0);
        if ($editId > 0) {
            $editOffer = ShopHelper::getOffer($editId);

            // ✅ FIX: Calcular expira_fmt para la oferta en edición
            if ($editOffer) {
                $expEn = (int)($editOffer['expira_en'] ?? 0);
                $editOffer['expira_fmt'] = '—';
                if ((int)$editOffer['expira'] === 1 && $expEn > 0) {
                    $editOffer['expira_fmt'] = date('d/m/Y H:i', $expEn);
                }
            }
        }
    }

    // ============================================================
    // ASIGNAR VARIABLES Y RENDER
    // ============================================================

    $template = new Template();
    $template->assign_vars(array(
        // Mensajes
        'message'     => $message,
        'msgType'     => $msgType,

        // Pestaña activa
        'tab'         => $tab,

        // Ofertas
        'offers'      => $offers,
        'offers_count'=> count($offers),

        // Catálogos (para los desplegables)
        'ships_catalog'    => $shipsCatalog,
        'defenses_catalog' => $defensesCatalog,
        'missiles_catalog' => $missilesCatalog,
        'boosters_catalog' => $boostersCatalog,

        // Duraciones disponibles (para el selector)
        'duraciones_disponibles' => $duracionesDisponibles,

        // Plantillas
        'templates'       => $templates,
        'templates_count' => count($templates),

        // Historial
        'history'       => $history,
        'history_count' => count($history),

        // Rollback
        'has_auto'        => $hasAuto,
        'last_auto_accion'=> $lastAutoAccion,
        'last_auto_fecha' => $lastAutoFecha,

        // Edición
        'edit_offer'      => $editOffer,
        'is_editing'      => !empty($editOffer),

        // URLs
        'shop_admin_url'  => 'admin.php?page=shopadmin',
    ));

    $template->show('shopAdminPage.tpl');
}