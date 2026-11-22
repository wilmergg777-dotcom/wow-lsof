<?php
/**
 * fix_loot.php v2
 * Arregla los IDs del loot de contenedores + crea el booster faltante
 * BORRAR DESPUÉS DE USAR
 */

define('MODE', 'INGAME');
define('ROOT_PATH', str_replace('\\', '/', dirname(__FILE__)) . '/');
set_include_path(ROOT_PATH);
chdir(ROOT_PATH);

require 'includes/config.php';
require 'includes/common.php';

$db = Database::get();
$prefix = 'uni1_';

echo "<h2>Arreglando loot de contenedores</h2>";
echo "<style>body{font-family:sans-serif;background:#0f1624;color:#cbd5e1;padding:20px;} table{border-collapse:collapse;margin-top:10px;} th,td{border:1px solid #1e293b;padding:6px 10px;} th{background:#1e293b;color:#00e0ff;} .ok{color:#4aff88;} .fail{color:#ef4444;}</style>";

// ============================================
// PASO 1: Crear el booster "exp_resources" si no existe
// ============================================
echo "<h3>PASO 1 — Crear booster exp_resources</h3>";

$existe = $db->selectSingle(
    "SELECT booster_id FROM `" . $prefix . "boosters` WHERE booster_type = 'exp_resources'"
);

if ($existe) {
    $nuevoId = (int)$existe['booster_id'];
    echo "<p>✅ Ya existe el booster <b>exp_resources</b> con ID <b>$nuevoId</b></p>";
} else {
    $db->query(
        "INSERT INTO `" . $prefix . "boosters` 
         (booster_name, booster_desc, booster_icon, booster_color, booster_type, booster_value, booster_duration)
         VALUES 
         ('Pot. Expediciones', 'Bonus de recursos obtenidos en expediciones', 'EXP', '#00ccff', 'exp_resources', 20.00, 86400)"
    );
    $row = $db->selectSingle(
        "SELECT booster_id FROM `" . $prefix . "boosters` WHERE booster_type = 'exp_resources'"
    );
    $nuevoId = (int)$row['booster_id'];
    echo "<p>✅ Booster <b>exp_resources</b> creado con ID <b>$nuevoId</b></p>";
}

// ============================================
// PASO 2: Arreglar los loot_extra_id (inyección directa)
// ============================================
echo "<h3>PASO 2 — Actualizar loot_extra_id</h3>";

$fixes = [
    1 => $nuevoId,  // Recursos de Expedición → el nuevo ID
    2 => 9,         // Extracción de MO        → Pot. Materia Oscura
    3 => 10,        // Producción de Recursos  → Pot. Minero
    4 => 11,        // Poder de Espionaje      → Pot. Espía
    5 => 12,        // Producción de Energía   → Pot. Energía
];

foreach ($fixes as $from => $to) {
    $from = (int)$from;
    $to   = (int)$to;
    
    try {
        // Inyección directa (sin :params)
        $db->query(
            "UPDATE `" . $prefix . "container_loot` 
             SET loot_extra_id = " . $to . " 
             WHERE loot_type = 'booster' AND loot_extra_id = " . $from
        );
        echo "<p class='ok'>✅ Actualizado: loot_extra_id <b>$from</b> → <b>$to</b></p>";
    } catch (Exception $e) {
        echo "<p class='fail'>❌ Error en $from → $to: " . htmlspecialchars($e->getMessage()) . "</p>";
    }
}

// ============================================
// PASO 3: Verificación final
// ============================================
echo "<h3>PASO 3 — Verificación</h3>";

$rows = $db->select(
    "SELECT cl.loot_id, cl.loot_name, cl.loot_extra_id, 
            b.booster_id, b.booster_name, b.booster_type
     FROM `" . $prefix . "container_loot` cl
     LEFT JOIN `" . $prefix . "boosters` b ON b.booster_id = cl.loot_extra_id
     WHERE cl.loot_type = 'booster'
     ORDER BY cl.loot_id"
);

echo "<table>";
echo "<tr><th>loot_id</th><th>loot_name</th><th>apunta_a</th><th>booster_name</th><th>estado</th></tr>";
$ok = 0; $fail = 0;
foreach ($rows as $r) {
    $estado = $r['booster_id'] ? "<span class='ok'>✅ OK</span>" : "<span class='fail'>❌ FALTA</span>";
    if ($r['booster_id']) $ok++; else $fail++;
    
    echo "<tr>";
    echo "<td>" . (int)$r['loot_id'] . "</td>";
    echo "<td>" . htmlspecialchars($r['loot_name']) . "</td>";
    echo "<td>" . (int)$r['loot_extra_id'] . "</td>";
    echo "<td>" . htmlspecialchars($r['booster_name'] ?? '—') . "</td>";
    echo "<td>$estado</td>";
    echo "</tr>";
}
echo "</table>";

echo "<p><b>Total: $ok OK, $fail FALTAN</b></p>";

echo "<br><hr><br>";
echo "<p style='color:#ef4444;font-weight:bold;font-size:18px;'>⚠️ BORRAR ESTE ARCHIVO DESPUÉS DE USARLO</p>";