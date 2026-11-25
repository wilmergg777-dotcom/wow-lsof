<?php
require_once __DIR__ . '/includes/auth.php';
logout_user();
session_start();
flash('Sesión cerrada. ¡Hasta pronto! 🌸', 'info');
header('Location: index.php');
