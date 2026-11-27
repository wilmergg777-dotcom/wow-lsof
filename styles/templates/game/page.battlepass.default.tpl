{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.battlepass.default.tpl === *}
{literal}
<style>
/* === ASTROIO v3.0 === */
#content h1, #content h2, #content h3, #content h4 { color:#fff; letter-spacing:.5px; text-shadow:0 1px 3px rgba(0,0,0,.5) }
#content a { color:#00e0ff; text-decoration:none; transition:.2s ease }
#content a:hover { color:#fff; text-shadow:0 0 10px rgba(0,224,255,.7) }
#content table { background:rgba(15,23,42,.55); border:1px solid #1e293b; border-radius:10px; border-collapse:collapse; overflow:hidden }
#content table th { background:linear-gradient(135deg,rgba(0,68,136,.85),rgba(0,119,204,.85)); border-bottom:1px solid rgba(0,224,255,.5); color:#fff; padding:6px 9px; text-align:left; text-transform:uppercase; font-size:10px; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
#content table td { padding:6px 9px; border-bottom:1px solid rgba(30,41,59,.7); color:#cbd5e1 }
#content table tr:hover td { background:rgba(0,224,255,.04) }
#content input[type=text], #content input[type=password], #content input[type=email], #content input[type=number], #content input[type=date], #content select, #content textarea { background:rgba(0,0,0,.5); color:#fff; border:1px solid rgba(0,204,255,.35); border-radius:8px; padding:5px 9px; font-size:12px; font-family:inherit; box-sizing:border-box; max-width:100%; transition:.25s ease }
#content input[type=text]:focus, #content input[type=password]:focus, #content input[type=email]:focus, #content input[type=number]:focus, #content select:focus, #content textarea:focus { outline:none; border-color:#00e0ff; box-shadow:0 0 12px rgba(0,224,255,.5); background:rgba(0,0,0,.65) }
#content textarea { width:100%; resize:vertical; font-family:inherit }
#content button, #content input[type=submit], #content input[type=button] { background:linear-gradient(180deg,#0066cc,#0099ff); color:#fff; border:1px solid #00e0ff; border-radius:8px; padding:5px 16px; font-size:11.5px; font-weight:600; font-family:inherit; cursor:pointer; transition:.25s ease; text-transform:uppercase; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
#content button:hover, #content input[type=submit]:hover, #content input[type=button]:hover { box-shadow:0 0 18px rgba(0,224,255,.5); transform:translateY(-2px) }
#content button:active, #content input[type=submit]:active, #content input[type=button]:active { transform:translateY(0) }
#content input[type=reset] { background:linear-gradient(180deg,#444,#666); border-color:#888 }
#content select option { background:#0f172a; color:#cbd5e1 }
#content .globalWarning { background:rgba(239,68,68,.12); border:1px solid rgba(239,68,68,.45); color:#fecaca; border-radius:10px; padding:8px 14px; text-align:center }
@media (max-width:760px) { #content { padding:6px; overflow-x:auto } #content table { font-size:11px } #content table th, #content table td { padding:5px 7px } }
</style>
{/literal}


{* ══════════════════════════════════════════════════════════════
   ASTRO BATTLE PASS v3.2 — Estilo Xnova (glassmorphism)
   Prefijo: .astrobp_
   Acento del módulo: 🔷 Cyan (#00e0ff)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, sub-cajas 10px)
     - Sub-cajas con borde cyan sutil + hover
     - Botones con radius 8px + hover translateY
     - Wrapper padding 15px
     - ⚠️ CRÍTICO: display:contents en forms (grid funciona con forms)
     - ⚠️ CRÍTICO: 4 estados + 2 animaciones pulse + inline width% intactos
     - ⚠️ CRÍTICO: {if $n.estado_normal/vip} anidados intactos
   FIX v3.1 (Mostrar nombre real de recompensa):
     - Columna central ampliada de 100px a 120px (nombres largos)
     - .astrobp_reward_texto: quitado nowrap/ellipsis -> permite 2 líneas
     - Responsive ajustado (columna central 90px en móvil)
   FIX v3.2 (Mensaje de alternativa):
     - NEW: .astrobp_msg.warning (amarillo) para cuando el Helper
       entrega una alternativa en vez de la nave sorteada.
     - NEW: Los mensajes detectan la variable $esAlternativa que asigna
       ShowBattlepassPage y cambian el estilo (verde -> amarillo).
     - NEW: Cabecera del bloque de mensajes reordenada para claridad.
   ══════════════════════════════════════════════════════════════ *}

<style>
/* ====== Variables globales ====== */
:root {
    --bg-dark:       rgba(11, 16, 30, 0.55);
    --bg-card:       rgba(15, 23, 42, 0.75);
    --bg-card-solid: rgba(15, 23, 42, 0.85);
    --bg-inner:      rgba(0, 0, 0, 0.35);
    --border-color:  #1e293b;
    --text-main:     #cbd5e1;
    --text-muted:    #94a3b8;
    --text-title:    #ffffff;
    --accent-blue:   #3b82f6;
    --accent-cyan:   #00e0ff;
    --accent-purple: #8b5cf6;
    --accent-gold:   #fbbf24;
    --accent-green:  #4aff88;
    --accent-red:    #ef4444;
}

.astrobp_wrap {
    max-width: 1100px;
    margin: 0 auto;
    text-align: center;
    color: var(--text-main);
    font-family: 'Segoe UI', Tahoma, sans-serif;
    padding: 15px;
    box-sizing: border-box;
}

/* ─── CABECERA ─────────────────────────────────────────────── */
.astrobp_header {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 25px 20px;
    margin-bottom: 20px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astrobp_title {
    font-size: 24px;
    font-weight: bold;
    color: #00ccff;
    text-shadow: 0 0 14px rgba(0, 224, 255, 0.5);
    margin-bottom: 8px;
    letter-spacing: 1px;
}

.astrobp_subtitle {
    font-size: 12px;
    color: var(--text-muted);
    font-style: italic;
    margin-bottom: 15px;
}

.astrobp_badges {
    display: inline-flex;
    gap: 12px;
    flex-wrap: wrap;
    justify-content: center;
    margin-top: 10px;
}

.astrobp_badge {
    background: rgba(0, 204, 255, 0.1);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.4);
    border-radius: 20px;
    padding: 6px 16px;
    font-size: 12px;
    color: #00ccff;
}

.astrobp_badge.vip {
    background: rgba(255, 68, 136, 0.1);
    border-color: rgba(255, 68, 136, 0.5);
    color: #ff88aa;
}

/* ─── PROGRESO ─────────────────────────────────────────────── */
.astrobp_progress_box {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    padding: 15px 20px;
    margin-bottom: 20px;
    text-align: left;
    transition: 0.2s ease;
}
.astrobp_progress_box:hover {
    border-color: rgba(0, 204, 255, 0.3);
}

.astrobp_progress_label {
    display: flex;
    justify-content: space-between;
    font-size: 12px;
    color: #00ccff;
    font-weight: bold;
    margin-bottom: 8px;
    text-transform: uppercase;
}

.astrobp_progress_bar {
    background: rgba(0, 0, 0, 0.5);
    border-radius: 6px;
    height: 14px;
    overflow: hidden;
    border: 1px solid rgba(0, 204, 255, 0.2);
}

.astrobp_progress_fill {
    height: 100%;
    background: linear-gradient(90deg, #004488, #00ccff);
    border-radius: 6px;
    transition: width 0.4s ease;
    box-shadow: 0 0 10px rgba(0, 204, 255, 0.5);
}

.astrobp_coins_display {
    text-align: center;
    margin-top: 10px;
    font-size: 13px;
    color: var(--text-main);
}

.astrobp_coins_display strong {
    color: #00ccff;
    font-size: 15px;
}

/* ─── CABECERA DE LA LISTA (Normal | Nivel | VIP) ─────────── */
.astrobp_list_header {
    display: grid;
    grid-template-columns: 1fr 120px 1fr;
    gap: 8px;
    background: linear-gradient(135deg, #004488, #0077cc);
    border-radius: 12px 12px 0 0;
    padding: 10px 12px;
    font-size: 12px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 1px;
    color: #fff;
    border-bottom: 2px solid #00ccff;
}

.astrobp_list_header .col_normal {
    text-align: center;
    color: #aaffff;
}

.astrobp_list_header .col_nivel {
    text-align: center;
    color: #ffffff;
    border-left: 1px solid rgba(255, 255, 255, 0.2);
    border-right: 1px solid rgba(255, 255, 255, 0.2);
}

.astrobp_list_header .col_vip {
    text-align: center;
    color: #ffbbdd;
}

/* ─── FILA DE NIVEL (Normal | Nivel | VIP) ────────────────── */
.astrobp_row {
    display: grid;
    grid-template-columns: 1fr 120px 1fr;
    gap: 8px;
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-top: none;
    padding: 10px 12px;
    align-items: stretch;
    transition: all 0.2s ease;
}

.astrobp_row:hover {
    border-color: rgba(0, 204, 255, 0.3);
}

.astrobp_row:last-child {
    border-radius: 0 0 12px 12px;
    border-bottom: 1px solid rgba(0, 204, 255, 0.15);
}

/* Columna Nivel (centro) */
.astrobp_col_nivel {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    text-align: center;
    padding: 6px 4px;
    border-left: 1px solid rgba(0, 204, 255, 0.15);
    border-right: 1px solid rgba(0, 204, 255, 0.15);
    background: rgba(0, 0, 0, 0.4);
    border-radius: 8px;
}

.astrobp_nivel_num {
    font-size: 16px;
    font-weight: bold;
    color: #00ccff;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.5);
    margin-bottom: 3px;
}

.astrobp_nivel_coste {
    font-size: 10px;
    color: #6688aa;
}

/* ═══════════════════════════════════════════════════════════
   COLUMNAS DE RECOMPENSA (izquierda / derecha)
   ═══════════════════════════════════════════════════════════ */
.astrobp_col_reward {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
    padding: 8px 12px;
    border-radius: 8px;
    min-height: 55px;
    font-family: inherit;
    text-align: left;
    transition: all 0.25s ease;
}

/* ─── ESTADO: BLOQUEADO (MUY OSCURO, casi negro) ─────────── */
.astrobp_col_reward.bloqueado {
    background: #05070c;
    border: 1px solid #1a2230;
    opacity: 0.85;
    box-shadow: inset 0 0 20px rgba(0, 0, 0, 0.8);
}

.astrobp_col_reward.bloqueado .astrobp_reward_icon {
    filter: grayscale(100%) brightness(0.3);
    opacity: 0.25;
}

.astrobp_col_reward.bloqueado .astrobp_reward_texto {
    color: #2a3441;
    font-weight: 500;
    text-shadow: none;
}

.astrobp_col_reward.bloqueado .astrobp_reward_texto.cofre {
    color: #2a3441;
}

.astrobp_row_estado.bloqueado {
    color: #2a3441;
    background: rgba(10, 15, 20, 0.8);
    border: 1px solid #1a2230;
    font-size: 14px;
    font-weight: bold;
    padding: 4px 8px;
    border-radius: 6px;
    opacity: 0.6;
}

/* ─── ESTADO: DISPONIBLE (color vivo, clickeable) ───────── */
.astrobp_col_reward.disponible {
    background: linear-gradient(135deg, #003a66 0%, #0077cc 100%);
    border: 2px solid #00ccff;
    box-shadow: 0 0 16px rgba(0, 224, 255, 0.5),
                inset 0 0 12px rgba(0, 224, 255, 0.15);
    cursor: pointer;
    animation: astrobp_pulse_normal 2s ease-in-out infinite;
    color: #fff;
    width: 100%;
    padding: 8px 12px;
    border-radius: 8px;
}

.astrobp_col_reward.disponible:hover {
    background: linear-gradient(135deg, #005599 0%, #00aaff 100%);
    border-color: #66ffff;
    box-shadow: 0 0 24px rgba(0, 224, 255, 0.9),
                inset 0 0 18px rgba(0, 224, 255, 0.3);
    transform: scale(1.02);
}

.astrobp_col_reward.disponible.vip {
    background: linear-gradient(135deg, #660033 0%, #cc2266 100%);
    border: 2px solid #ff4488;
    box-shadow: 0 0 16px rgba(255, 68, 136, 0.5),
                inset 0 0 12px rgba(255, 68, 136, 0.15);
    animation: astrobp_pulse_vip 2s ease-in-out infinite;
}

.astrobp_col_reward.disponible.vip:hover {
    background: linear-gradient(135deg, #aa0055 0%, #ff4488 100%);
    border-color: #ff88aa;
    box-shadow: 0 0 24px rgba(255, 136, 170, 0.9),
                inset 0 0 18px rgba(255, 136, 170, 0.3);
}

.astrobp_col_reward.disponible .astrobp_reward_icon {
    filter: drop-shadow(0 0 6px rgba(255, 255, 255, 0.9));
    font-size: 24px;
}

.astrobp_col_reward.disponible .astrobp_reward_texto {
    color: #ffffff;
    font-weight: 800;
    text-shadow: 0 0 6px rgba(255, 255, 255, 0.6);
}

.astrobp_col_reward.disponible .astrobp_reward_texto.cofre {
    color: #ffff88;
    font-weight: 900;
}

/* Etiqueta "RECLAMAR" grande */
.astrobp_claim_tag {
    display: inline-block;
    font-size: 11px;
    font-weight: 900;
    letter-spacing: 0.8px;
    padding: 5px 10px;
    border-radius: 6px;
    background: rgba(255, 255, 255, 0.25);
    color: #ffffff;
    text-shadow: 0 0 6px rgba(255, 255, 255, 0.8);
    border: 1px solid rgba(255, 255, 255, 0.5);
    white-space: nowrap;
}

.astrobp_col_reward.disponible.vip .astrobp_claim_tag {
    background: rgba(255, 255, 255, 0.25);
}

/* ─── ESTADO: RECLAMADO (verde tenue) ────────────────────── */
.astrobp_col_reward.reclamado {
    background: rgba(0, 40, 20, 0.55);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(102, 255, 153, 0.35);
    opacity: 0.7;
}

.astrobp_col_reward.reclamado .astrobp_reward_texto {
    color: #88ffbb;
}

.astrobp_row_estado.reclamado {
    color: #66ff99;
    background: rgba(102, 255, 153, 0.12);
    border: 1px solid rgba(102, 255, 153, 0.4);
    font-size: 11px;
    font-weight: bold;
    padding: 5px 10px;
    border-radius: 6px;
    text-transform: uppercase;
    white-space: nowrap;
}

/* ─── ESTADO: SIN VIP ────────────────────────────────────── */
.astrobp_col_reward.sin_vip {
    background: rgba(30, 10, 20, 0.6);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px dashed rgba(255, 68, 136, 0.3);
    opacity: 0.7;
}

.astrobp_col_reward.sin_vip .astrobp_reward_icon {
    filter: grayscale(50%);
    opacity: 0.6;
}

.astrobp_col_reward.sin_vip .astrobp_reward_texto {
    color: #884466;
}

.astrobp_row_estado.sin_vip {
    color: #ff88aa;
    background: rgba(255, 68, 136, 0.12);
    border: 1px solid rgba(255, 68, 136, 0.35);
    font-size: 10px;
    font-weight: bold;
    padding: 4px 8px;
    border-radius: 6px;
    text-transform: uppercase;
    white-space: nowrap;
}

/* Info de recompensa */
.astrobp_reward_info {
    display: flex;
    align-items: center;
    gap: 8px;
    flex: 1;
    text-align: left;
    min-width: 0;
}

.astrobp_reward_icon {
    font-size: 22px;
    line-height: 1;
    flex-shrink: 0;
}

/* v3.1: permite 2 lineas para nombres largos ("Estrella de la Muerte") */
.astrobp_reward_texto {
    font-size: 11px;
    color: var(--text-main);
    font-weight: 600;
    line-height: 1.25;
    white-space: normal;
    word-break: break-word;
    overflow-wrap: break-word;
}

.astrobp_reward_texto.cofre {
    color: #ffaa33;
    font-weight: 700;
}

/* Asegurar que el <button> no rompa el estilo */
button.astrobp_col_reward {
    font-family: inherit;
    text-align: left;
    outline: none;
}

/* ─── ANIMACIONES DE PULSO ───────────────────────────────── */
@keyframes astrobp_pulse_normal {
    0%, 100% {
        box-shadow: 0 0 16px rgba(0, 224, 255, 0.5),
                    inset 0 0 12px rgba(0, 224, 255, 0.15);
    }
    50% {
        box-shadow: 0 0 28px rgba(0, 224, 255, 0.9),
                    inset 0 0 20px rgba(0, 224, 255, 0.3);
    }
}

@keyframes astrobp_pulse_vip {
    0%, 100% {
        box-shadow: 0 0 16px rgba(255, 68, 136, 0.5),
                    inset 0 0 12px rgba(255, 68, 136, 0.15);
    }
    50% {
        box-shadow: 0 0 28px rgba(255, 68, 136, 0.9),
                    inset 0 0 20px rgba(255, 68, 136, 0.3);
    }
}

/* ─── BOTONES GENERALES ────────────────────────────────────── */
.astrobp_actions {
    margin-top: 20px;
    display: flex;
    gap: 12px;
    justify-content: center;
    flex-wrap: wrap;
}

.astrobp_btn {
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
    border: 1px solid #00ccff;
    border-radius: 8px;
    color: #fff;
    font-size: 13px;
    font-weight: bold;
    padding: 11px 26px;
    cursor: pointer;
    transition: all 0.25s ease;
    text-transform: uppercase;
    letter-spacing: 1px;
    text-decoration: none;
    display: inline-block;
    font-family: inherit;
}

.astrobp_btn:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.5);
    transform: translateY(-2px);
}
.astrobp_btn:active {
    transform: translateY(0);
}

.astrobp_btn.gris {
    background: linear-gradient(135deg, rgba(51, 68, 85, 0.9), rgba(85, 102, 119, 0.9));
    border: 1px solid #667788;
}

.astrobp_btn.gris:hover {
    background: linear-gradient(135deg, rgba(85, 102, 119, 0.95), rgba(102, 119, 136, 0.95));
    box-shadow: 0 0 14px rgba(100, 120, 140, 0.5);
}

/* ─── MENSAJES ─────────────────────────────────────────────── */
.astrobp_msg {
    padding: 12px 18px;
    border-radius: 10px;
    margin-bottom: 15px;
    font-size: 13px;
    font-weight: bold;
    text-align: center;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}

.astrobp_msg.success {
    background: rgba(102, 255, 153, 0.1);
    border: 1px solid rgba(102, 255, 153, 0.4);
    color: #66ff99;
}

.astrobp_msg.error {
    background: rgba(255, 68, 136, 0.1);
    border: 1px solid rgba(255, 68, 136, 0.4);
    color: #ff4488;
}

/* v3.2: mensaje de ALTERNATIVA (amarillo/dorado) */
.astrobp_msg.warning {
    background: rgba(251, 191, 36, 0.1);
    border: 1px solid rgba(251, 191, 36, 0.5);
    color: #fbbf24;
    box-shadow: 0 0 12px rgba(251, 191, 36, 0.15);
}

/* ─── RESPONSIVE ───────────────────────────────────────────── */
@media (max-width: 720px) {
    .astrobp_wrap { padding: 8px 4px !important; }
    .astrobp_header { padding: 15px 10px !important; }
    .astrobp_title { font-size: 18px !important; }
    .astrobp_subtitle { font-size: 10px !important; }
    .astrobp_badges { gap: 6px !important; }
    .astrobp_badge { font-size: 9px !important; padding: 4px 10px !important; }

    /* Reducir la columna central (Nivel) para dar más espacio a las recompensas */
    .astrobp_list_header,
    .astrobp_row {
        grid-template-columns: 1fr 45px 1fr !important;
        padding: 6px 4px !important;
        gap: 4px !important;
    }

    .astrobp_list_header {
        font-size: 8px !important;
        padding: 8px 4px !important;
    }

    /* ─── REESTRUCTURAR LAS COLUMNAS DE RECOMPENSA EN MÓVIL ─── */
    .astrobp_col_reward {
        flex-direction: column !important; /* Apila icono, texto y botón verticalmente */
        justify-content: center !important;
        text-align: center !important;
        padding: 6px 4px !important;
        gap: 4px !important;
        min-height: 75px !important;
    }

    .astrobp_reward_info {
        flex-direction: column !important; /* Icono arriba, texto abajo */
        gap: 2px !important;
        text-align: center !important;
        align-items: center !important;
    }

    .astrobp_reward_icon { 
        font-size: 18px !important; 
    }

    .astrobp_reward_texto { 
        font-size: 8px !important; 
        line-height: 1.1 !important; 
        text-align: center !important;
    }

    /* Etiqueta RECLAMAR adaptada a la columna */
    .astrobp_claim_tag {
        width: 100% !important;
        font-size: 7.5px !important;
        padding: 3px 2px !important;
        margin-top: 2px !important;
        text-align: center !important;
        box-sizing: border-box !important;
        letter-spacing: 0px !important;
    }

    /* Estados (OK, Candado, VIP) */
    .astrobp_row_estado {
        width: 100% !important;
        font-size: 7.5px !important;
        padding: 2px 0 !important;
        text-align: center !important;
        box-sizing: border-box !important;
        margin-top: 2px !important;
    }

    /* Columna central (Nivel y Coste) */
    .astrobp_col_nivel {
        padding: 4px 2px !important;
    }
    .astrobp_nivel_num { font-size: 12px !important; margin-bottom: 2px !important; }
    .astrobp_nivel_coste { font-size: 7px !important; }

    /* Botones generales (Reclamar todo / Volver) */
    .astrobp_actions { flex-direction: column !important; }
    .astrobp_btn { 
        width: 100% !important; 
        text-align: center !important; 
        box-sizing: border-box !important; 
        padding: 10px !important;
    }
}
</style>

<div class="astrobp_wrap">

    <!-- ═══ MENSAJES ═══ -->
    {* v3.2: si fue alternativa -> clase "warning" (amarillo), si no -> "success" (verde) *}
    {if $msgSuccess}
        <div class="astrobp_msg {if $esAlternativa}warning{else}success{/if}">
            {$msgSuccess}
        </div>
    {/if}
    {if $msgError}
        <div class="astrobp_msg error">{$msgError}</div>
    {/if}

    <!-- ═══ CABECERA ═══ -->
    <div class="astrobp_header">
        <div class="astrobp_title">⚔️ PASE DE BATALLA ⚔️</div>
        <div class="astrobp_subtitle">Subí de nivel completando eventos y ganá recompensas exclusivas</div>

        <div class="astrobp_badges">
            <div class="astrobp_badge">📅 {$seasonName}</div>
            <div class="astrobp_badge">⏳ Reinicio en: {$tiempoRestante}</div>
            <div class="astrobp_badge{if $vipActivo} vip{/if}">
                👑 {if $vipActivo}VIP Activo{else}Sin VIP{/if}
            </div>
        </div>
    </div>

    <!-- ═══ PROGRESO ═══ -->
    <div class="astrobp_progress_box">
        <div class="astrobp_progress_label">
            <span>📊 Progreso</span>
            <span>Nivel {$nivelActual} / {$totalNiveles}</span>
        </div>
        <div class="astrobp_progress_bar">
            <div class="astrobp_progress_fill" style="width: {$porcentaje}%;"></div>
        </div>
        <div class="astrobp_coins_display">
            🎟️ <strong>{$monedasActuales}</strong> monedas
            {if $nivelActual < $totalNiveles}
                &nbsp;·&nbsp; Próximo nivel: <strong>{$costeSiguiente}</strong> monedas ({$porcentaje}%)
            {else}
                &nbsp;·&nbsp; <strong>¡Nivel máximo alcanzado!</strong>
            {/if}
        </div>
    </div>

    <!-- ═══ CABECERA DE LA LISTA (Normal | Nivel | VIP) ═══ -->
    <div class="astrobp_list_header">
        <div class="col_normal">🟢 Carril Normal</div>
        <div class="col_nivel">Nivel</div>
        <div class="col_vip">⭐ Carril VIP</div>
    </div>

    <!-- ═══ LISTA DE NIVELES ═══ -->
    {foreach $niveles as $n}
        <div class="astrobp_row">

            <!-- ═══ Columna Carril Normal (izquierda) ═══ -->
            {if $n.estado_normal == 'disponible'}
                <form method="post" action="game.php?page=battlepass&mode=reclamar" style="margin:0; display:contents;">
                    <input type="hidden" name="nivel" value="{$n.nivel}">
                    <input type="hidden" name="carril" value="normal">
                    <button type="submit" class="astrobp_col_reward disponible">
                        <div class="astrobp_reward_info">
                            <span class="astrobp_reward_icon">{$n.recompensa_normal.icono}</span>
                            <span class="astrobp_reward_texto{if $n.es_cofre_normal} cofre{/if}">
                                {$n.recompensa_normal.texto}
                            </span>
                        </div>
                        <span class="astrobp_claim_tag">🎁 RECLAMAR</span>
                    </button>
                </form>
            {else}
                <div class="astrobp_col_reward {$n.estado_normal}">
                    <div class="astrobp_reward_info">
                        <span class="astrobp_reward_icon">{$n.recompensa_normal.icono}</span>
                        <span class="astrobp_reward_texto{if $n.es_cofre_normal} cofre{/if}">
                            {$n.recompensa_normal.texto}
                        </span>
                    </div>
                    {if $n.estado_normal == 'reclamado'}
                        <div class="astrobp_row_estado reclamado">✔ OK</div>
                    {else}
                        <div class="astrobp_row_estado bloqueado">🔒</div>
                    {/if}
                </div>
            {/if}

            <!-- ═══ Columna Nivel (centro) ═══ -->
            <div class="astrobp_col_nivel">
                <div class="astrobp_nivel_num">N{$n.nivel}</div>
                <div class="astrobp_nivel_coste">🎟️ {$n.coste}</div>
            </div>

            <!-- ═══ Columna Carril VIP (derecha) ═══ -->
            {if $n.estado_vip == 'disponible'}
                <form method="post" action="game.php?page=battlepass&mode=reclamar" style="margin:0; display:contents;">
                    <input type="hidden" name="nivel" value="{$n.nivel}">
                    <input type="hidden" name="carril" value="vip">
                    <button type="submit" class="astrobp_col_reward disponible vip">
                        <div class="astrobp_reward_info">
                            <span class="astrobp_reward_icon">{$n.recompensa_vip.icono}</span>
                            <span class="astrobp_reward_texto{if $n.es_cofre_vip} cofre{/if}">
                                {$n.recompensa_vip.texto}
                            </span>
                        </div>
                        <span class="astrobp_claim_tag">🎁 RECLAMAR</span>
                    </button>
                </form>
            {else}
                <div class="astrobp_col_reward vip {$n.estado_vip}">
                    <div class="astrobp_reward_info">
                        <span class="astrobp_reward_icon">{$n.recompensa_vip.icono}</span>
                        <span class="astrobp_reward_texto{if $n.es_cofre_vip} cofre{/if}">
                            {$n.recompensa_vip.texto}
                        </span>
                    </div>
                    {if $n.estado_vip == 'reclamado'}
                        <div class="astrobp_row_estado reclamado">✔ OK</div>
                    {elseif $n.estado_vip == 'sin_vip'}
                        <div class="astrobp_row_estado sin_vip">👑 VIP</div>
                    {else}
                        <div class="astrobp_row_estado bloqueado">🔒</div>
                    {/if}
                </div>
            {/if}

        </div>
    {/foreach}

    <!-- ═══ ACCIONES ═══ -->
    <div class="astrobp_actions">
        {if $reclamablesNormal > 0 || $reclamablesVip > 0}
            <form method="post" action="game.php?page=battlepass&mode=reclamarTodo" style="margin:0;">
                <button type="submit" class="astrobp_btn">
                    🎁 Reclamar Todo ({$reclamablesNormal + $reclamablesVip})
                </button>
            </form>
        {/if}
        <a href="game.php?page=overview" class="astrobp_btn gris">↩ Volver</a>
    </div>

</div>

{/block}