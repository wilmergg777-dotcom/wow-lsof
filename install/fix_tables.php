<?php
// Ejecuta xnova_db.sql sin romper si las tablas ya existen

$db = new mysqli('localhost', 'USUARIO', 'PASSWORD', 'BASE');
$db->set_charset('utf8mb4');

$sql = file_get_contents(__DIR__ . '/xnova_db.sql');

// Truco: hacerlo idempotente al vuelo
$sql = str_replace('CREATE TABLE `',              'CREATE TABLE IF NOT EXISTS `',  $sql);
$sql = str_replace('INSERT INTO `',               'INSERT IGNORE INTO `',          $sql);
$sql = str_replace('ADD PRIMARY KEY (`',          'ADD PRIMARY KEY IF NOT EXISTS (`', $sql);
$sql = str_replace('ADD UNIQUE KEY `',            'ADD UNIQUE KEY IF NOT EXISTS `',   $sql);
$sql = str_replace('ADD KEY `',                   'ADD KEY IF NOT EXISTS `',          $sql);

// Ejecutar sentencia por sentencia
$db->multi_query($sql);
while ($db->more_results()) {
    $db->next_result();
    if ($db->errno && stripos($db->error, 'already exists') === false
                  && stripos($db->error, 'duplicate') === false) {
        // solo loguear errores REALES
        file_put_contents(__DIR__ . '/../includes/error.log',
            date('Y-m-d H:i:s') . ' [fix] ' . $db->error . PHP_EOL, FILE_APPEND);
    }
}
echo "OK\n";