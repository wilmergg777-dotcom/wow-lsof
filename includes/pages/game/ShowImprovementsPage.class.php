<?php
require_once 'includes/classes/ImprovementHelper.class.php';

class ShowImprovementsPage extends AbstractGamePage {

    public $defaultController = 'show';

    // Mapa de nombres de naves y defensas
    private $unitNames = [
        202 => 'Reciclador',
        203 => 'Carguero Pequeño',
        204 => 'Caza Ligero',
        205 => 'Caza Pesado',
        206 => 'Crucero',
        207 => 'Nave de Batalla',
        208 => 'Acorazado',
        209 => 'Bombardero',
        210 => 'Destructor',
        211 => 'Estrella de la Muerte',
        212 => 'Crucero de Batalla',
        213 => 'Acorazado de Batalla',
        214 => 'Explorador',
        215 => 'Carguero Grande',
        216 => 'Colonizador',
        217 => 'Nave de Espionaje',
        218 => 'Nave de Reciclaje',
        219 => 'Nave de Carga',
        220 => 'Nave de Colonizacion',
        401 => 'Lanzamisiles',
        402 => 'Laser Pequeño',
        403 => 'Laser Grande',
        404 => 'Cañon Gauss',
        405 => 'Cañon Ionico',
        406 => 'Cañon de Plasma',
        407 => 'Cupula Pequeña',
        408 => 'Cupula Grande',
        409 => 'Misil Interplanetario',
        410 => 'Laser de Defensa',
        411 => 'Blindaje Adicional'
    ];

    // Listas separadas para el selector
    private $ships = [
        202 => 'Reciclador',
        203 => 'Carguero Pequeño',
        204 => 'Caza Ligero',
        205 => 'Caza Pesado',
        206 => 'Crucero',
        207 => 'Nave de Batalla',
        208 => 'Acorazado',
        209 => 'Bombardero',
        210 => 'Destructor',
        211 => 'Estrella de la Muerte',
        212 => 'Crucero de Batalla',
        213 => 'Acorazado de Batalla',
        214 => 'Explorador',
        215 => 'Carguero Grande',
        216 => 'Colonizador',
        217 => 'Nave de Espionaje',
        218 => 'Nave de Reciclaje',
        219 => 'Nave de Carga',
        220 => 'Nave de Colonizacion'
    ];

    private $defenses = [
        401 => 'Lanzamisiles',
        402 => 'Laser Pequeño',
        403 => 'Laser Grande',
        404 => 'Cañon Gauss',
        405 => 'Cañon Ionico',
        406 => 'Cañon de Plasma',
        407 => 'Cupula Pequeña',
        408 => 'Cupula Grande',
        409 => 'Misil Interplanetario',
        410 => 'Laser de Defensa',
        411 => 'Blindaje Adicional'
    ];

    public function __construct() {
        parent::__construct();
    }

    public function show() {
        $userId = isset($GLOBALS['USER']['id']) ? (int)$GLOBALS['USER']['id'] : 0;
        $unitId = isset($_GET['unit_id']) ? (int)$_GET['unit_id'] : 204;
        $tab = isset($_GET['tab']) ? $_GET['tab'] : 'equipar';
        $filter = isset($_GET['filter']) ? $_GET['filter'] : 'all';
        
        $category = ($unitId >= 400) ? 'defense' : 'ship';
        $unitName = isset($this->unitNames[$unitId]) ? $this->unitNames[$unitId] : ('Unidad ' . $unitId);

        // Construir array del selector (naves + defensas)
        $selector = [];
        foreach ($this->ships as $id => $name) {
            $selector[] = ['id' => $id, 'name' => $name, 'cat' => 'ship'];
        }
        foreach ($this->defenses as $id => $name) {
            $selector[] = ['id' => $id, 'name' => $name, 'cat' => 'defense'];
        }

        // Mensajes
        $msgSuccess = '';
        $msgError   = '';
        if (isset($_GET['msg'])) {
            switch ($_GET['msg']) {
                case 'comprar_ok':
                    $msgSuccess = '✅ Compra realizada con exito. La mejora ya esta en tu inventario.';
                    break;
                case 'equipar_ok':
                    $msgSuccess = '✅ Mejora equipada correctamente.';
                    break;
                case 'desequipar_ok':
                    $msgSuccess = '✅ Mejora desequipada. Ahora esta en tu inventario (penalizada).';
                    break;
                case 'vender_ok':
                    $msgSuccess = '✅ Mejora vendida correctamente.';
                    break;
                case 'fusionar_ok':
                    $msgSuccess = '✅ Fusion completada.';
                    break;
                case 'error':
                    $msgError = isset($_GET['text']) ? urldecode($_GET['text']) : 'No se pudo completar la accion.';
                    break;
            }
        }

        // Contar compras disponibles hoy
        $comprasHoy = isset($GLOBALS['USER']['improvements_compras_hoy']) ? (int)$GLOBALS['USER']['improvements_compras_hoy'] : 0;
        $comprasDisponibles = max(0, 7 - $comprasHoy);

        // Determinar qué categoría pasar al Helper
        $catalogCategory = $category;
        if ($tab == 'comprar') {
            if ($filter === 'ship') {
                $catalogCategory = 'ship';
            } elseif ($filter === 'defense') {
                $catalogCategory = 'defense';
            } else {
                $catalogCategory = 'todas';
            }
        }

        $this->assign([
            'unit_id'            => $unitId,
            'unit_name'          => $unitName,
            'tab'                => $tab,
            'filter'             => $filter,
            'category'           => $category,
            'selector'           => $selector,
            'equipped'           => ImprovementHelper::getEquipped($userId, $unitId),
            'inventory'          => ImprovementHelper::getInventory($userId),
            'catalog'            => ImprovementHelper::getCatalog($catalogCategory),
            'bonuses'            => ImprovementHelper::getBonuses($userId, $unitId),
            'mo'                 => isset($GLOBALS['USER']['darkmatter']) ? $GLOBALS['USER']['darkmatter'] : 0,
            'inv_slots'          => ImprovementHelper::countInventorySlots($userId),
            'compras_hoy'        => $comprasHoy,
            'compras_disponibles'=> $comprasDisponibles,
            'msg_success'        => $msgSuccess,
            'msg_error'          => $msgError
        ]);

        $this->display('page.improvements.default.tpl');
    }

    public function doEquip() {
        $userId = (int)$GLOBALS['USER']['id'];
        $unitId = isset($_POST['unit_id']) ? (int)$_POST['unit_id'] : 204;
        $slot   = isset($_POST['slot'])    ? (int)$_POST['slot']    : 1;
        $itemId = isset($_POST['item_id']) ? (int)$_POST['item_id'] : 0;

        $ok = ImprovementHelper::equip($userId, $unitId, $slot, $itemId);

        if ($ok) {
            $this->redirectTo('game.php?page=improvements&unit_id='.$unitId.'&msg=equipar_ok');
        } else {
            $this->redirectTo('game.php?page=improvements&unit_id='.$unitId.'&msg=error&text='.urlencode('No se puede equipar: revisa las reglas de progresion escalonada.'));
        }
    }

    public function doUnequip() {
        $userId = (int)$GLOBALS['USER']['id'];
        $unitId = isset($_GET['unit_id']) ? (int)$_GET['unit_id'] : 204;
        $slot   = isset($_GET['slot'])    ? (int)$_GET['slot']    : 1;

        $ok = ImprovementHelper::unequip($userId, $unitId, $slot);

        if ($ok) {
            $this->redirectTo('game.php?page=improvements&unit_id='.$unitId.'&msg=desequipar_ok');
        } else {
            $this->redirectTo('game.php?page=improvements&unit_id='.$unitId.'&msg=error&text='.urlencode('No se pudo quitar la mejora (ya tienes 5 en el inventario).'));
        }
    }

    public function doBuy() {
        $userId = (int)$GLOBALS['USER']['id'];
        $itemId = isset($_POST['item_id']) ? (int)$_POST['item_id'] : 0;

        $result = ImprovementHelper::buy($userId, $itemId);

        if (isset($result['error'])) {
            $this->redirectTo('game.php?page=improvements&tab=comprar&msg=error&text='.urlencode($result['error']));
        } else {
            $this->redirectTo('game.php?page=improvements&tab=comprar&msg=comprar_ok');
        }
    }

    public function doSell() {
        $userId = (int)$GLOBALS['USER']['id'];
        $itemId = isset($_POST['item_id'])  ? (int)$_POST['item_id']  : 0;
        $qty    = isset($_POST['quantity']) ? (int)$_POST['quantity'] : 1;

        $result = ImprovementHelper::sell($userId, $itemId, $qty);

        if (isset($result['error'])) {
            $this->redirectTo('game.php?page=improvements&tab=vender&msg=error&text='.urlencode($result['error']));
        } else {
            $this->redirectTo('game.php?page=improvements&tab=vender&msg=vender_ok');
        }
    }

    public function doFuse() {
        $userId = (int)$GLOBALS['USER']['id'];
        $itemId = isset($_POST['item_id']) ? (int)$_POST['item_id'] : 0;

        $result = ImprovementHelper::fuse($userId, $itemId);

        if (isset($result['error'])) {
            $this->redirectTo('game.php?page=improvements&tab=vender&msg=error&text='.urlencode($result['error']));
        } else {
            $this->redirectTo('game.php?page=improvements&tab=vender&msg=fusionar_ok');
        }
    }
}
?>