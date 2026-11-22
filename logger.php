<?php
// Forzar a PHP a guardar los errores en un archivo dentro de la carpeta del juego
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/error_log'); // Se guardará en la misma carpeta donde pongas este archivo
ini_set('display_errors', 0); // No mostrar en pantalla (para producción)
error_reporting(E_ALL);
?>