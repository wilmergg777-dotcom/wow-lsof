{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/adm/bugreportAdminPage.tpl === *}
{literal}
<style>
/* === ASTROIO v3.0 === */
h1, h2, h3, h4 { color:#fff; letter-spacing:.5px; text-shadow:0 1px 3px rgba(0,0,0,.5) }
a { color:#00e0ff; text-decoration:none; transition:.2s ease }
a:hover { color:#fff; text-shadow:0 0 10px rgba(0,224,255,.7) }
table { background:rgba(15,23,42,.55); border:1px solid #1e293b; border-radius:10px; border-collapse:collapse; overflow:hidden }
table th { background:linear-gradient(135deg,rgba(0,68,136,.85),rgba(0,119,204,.85)); border-bottom:1px solid rgba(0,224,255,.5); color:#fff; padding:6px 9px; text-align:left; text-transform:uppercase; font-size:10px; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
table td { padding:6px 9px; border-bottom:1px solid rgba(30,41,59,.7); color:#cbd5e1 }
table tr:hover td { background:rgba(0,224,255,.04) }
input[type=text], input[type=password], input[type=email], input[type=number], input[type=date], select, textarea { background:rgba(0,0,0,.5); color:#fff; border:1px solid rgba(0,204,255,.35); border-radius:8px; padding:5px 9px; font-size:12px; font-family:inherit; box-sizing:border-box; max-width:100%; transition:.25s ease }
input[type=text]:focus, input[type=password]:focus, input[type=email]:focus, input[type=number]:focus, select:focus, textarea:focus { outline:none; border-color:#00e0ff; box-shadow:0 0 12px rgba(0,224,255,.5); background:rgba(0,0,0,.65) }
textarea { width:100%; resize:vertical; font-family:inherit }
button, input[type=submit], input[type=button] { background:linear-gradient(180deg,#0066cc,#0099ff); color:#fff; border:1px solid #00e0ff; border-radius:8px; padding:5px 16px; font-size:11.5px; font-weight:600; font-family:inherit; cursor:pointer; transition:.25s ease; text-transform:uppercase; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
button:hover, input[type=submit]:hover, input[type=button]:hover { box-shadow:0 0 18px rgba(0,224,255,.5); transform:translateY(-2px) }
button:active, input[type=submit]:active, input[type=button]:active { transform:translateY(0) }
input[type=reset] { background:linear-gradient(180deg,#444,#666); border-color:#888 }
select option { background:#0f172a; color:#cbd5e1 }
.globalWarning { background:rgba(239,68,68,.12); border:1px solid rgba(239,68,68,.45); color:#fecaca; border-radius:10px; padding:8px 14px; text-align:center }
@media (max-width:760px) { { padding:6px; overflow-x:auto } table { font-size:11px } table th, table td { padding:5px 7px } }
</style>
{/literal}

{include file="overall_header.tpl"}

{* ══════════════════════════════════════════════════════════════
   ASTRO BUG REPORT v3.0 — Panel Admin
   Prefijo: .astrobuga_
   Acento del módulo: 🟡 Dorado (#ffaa33)
   FIX v3.0:
     - Patrón fleetDealer aplicado (glassmorphism, radius 10-12px)
     - Sub-cajas con borde cyan sutil + hover
     - Botones con radius 8px + hover translateY
     - ⚠️ CRÍTICO: overall_header/footer intactos (admin)
     - ⚠️ CRÍTICO: IDs del modal y JS intactos
     - ⚠️ CRÍTICO: clases .active, .pendiente, .aceptado, .solucionado, .cancelado, .borrado intactas
     - ⚠️ CRÍTICO: style inline dinámico de estado intacto
     - if, foreach, in_array, Smarty, forms, inputs, onclick, onsubmit intactos
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

body { background: linear-gradient(180deg, #0f1624 0%, #1a2332 100%) !important; }

.astrobuga_wrap {
    max-width: 1300px;
    margin: 0 auto;
    padding: 15px;
    color: var(--text-main);
    font-family: 'Segoe UI', Tahoma, sans-serif;
    box-sizing: border-box;
}

/* Cabecera (glassmorphism) */
.astrobuga_header {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 20px 25px;
    margin-bottom: 18px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    text-align: center;
}

.astrobuga_title {
    font-size: 22px;
    font-weight: 700;
    color: #ffaa33;
    text-shadow: 0 0 14px rgba(255, 170, 51, 0.5);
    letter-spacing: 1px;
    margin-bottom: 6px;
}

.astrobuga_subtitle {
    font-size: 12px;
    color: var(--text-muted);
    font-style: italic;
}

/* Mensajes */
.astrobuga_msg {
    padding: 12px 18px;
    border-radius: 10px;
    margin-bottom: 15px;
    font-size: 13px;
    font-weight: bold;
    text-align: center;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.astrobuga_msg.success {
    background: rgba(102, 255, 153, 0.1);
    border: 1px solid rgba(102, 255, 153, 0.4);
    color: #66ff99;
}
.astrobuga_msg.error {
    background: rgba(255, 68, 136, 0.1);
    border: 1px solid rgba(255, 68, 136, 0.4);
    color: #ff4488;
}

/* Tabs */
.astrobuga_tabs {
    display: flex;
    gap: 6px;
    margin-bottom: 18px;
    flex-wrap: wrap;
    justify-content: center;
}

.astrobuga_tab {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    color: #66ccff;
    padding: 10px 20px;
    border-radius: 8px;
    text-decoration: none;
    font-size: 12px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    transition: all 0.25s ease;
}
.astrobuga_tab:hover {
    background: rgba(0, 204, 255, 0.1);
    border-color: rgba(0, 204, 255, 0.5);
    color: #00e0ff;
    box-shadow: 0 0 14px rgba(0, 204, 255, 0.4);
    transform: translateY(-2px);
}
.astrobuga_tab.active {
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
    color: #fff;
    border-color: #00ccff;
    box-shadow: 0 0 14px rgba(0, 204, 255, 0.6);
}

.astrobuga_tab .count {
    background: rgba(255, 255, 255, 0.2);
    padding: 2px 8px;
    border-radius: 10px;
    font-size: 10px;
    font-weight: 900;
}

/* Dashboard */
.astrobuga_dash {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    gap: 12px;
    margin-bottom: 18px;
}

.astrobuga_stat {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    padding: 18px 15px;
    text-align: center;
    transition: all 0.25s ease;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
}
.astrobuga_stat:hover {
    border-color: rgba(0, 204, 255, 0.5);
    box-shadow: 0 0 18px rgba(0, 224, 255, 0.3);
    transform: translateY(-2px);
}

.astrobuga_stat .icon {
    font-size: 32px;
    display: block;
    margin-bottom: 8px;
    line-height: 1;
}

.astrobuga_stat .value {
    font-size: 28px;
    font-weight: 900;
    font-family: 'Courier New', monospace;
    color: #00e0ff;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.5);
    display: block;
    margin-bottom: 4px;
}

.astrobuga_stat .label {
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    color: var(--text-muted);
}

.astrobuga_stat.pendientes .value    { color: #ffdd88; text-shadow: 0 0 10px rgba(255, 221, 136, 0.5); }
.astrobuga_stat.aceptados  .value    { color: #00ccff; text-shadow: 0 0 10px rgba(0, 204, 255, 0.5); }
.astrobuga_stat.solucionados .value  { color: #ffaa33; text-shadow: 0 0 10px rgba(255, 170, 51, 0.5); }
.astrobuga_stat.cancelados .value    { color: #ff4488; text-shadow: 0 0 10px rgba(255, 68, 136, 0.5); }
.astrobuga_stat.borrados   .value    { color: #8899aa; text-shadow: 0 0 10px rgba(136, 153, 170, 0.5); }

/* Lista de reportes */
.astrobuga_list {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.astrobuga_card {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-left: 4px solid #00ccff;
    border-radius: 10px;
    padding: 14px 18px;
    transition: all 0.25s ease;
}
.astrobuga_card:hover {
    border-color: rgba(0, 204, 255, 0.5);
    border-left-color: #00e0ff;
    box-shadow: 0 0 18px rgba(0, 224, 255, 0.3);
    transform: translateX(2px);
}

/* Estados funcionales (preservar) */
.astrobuga_card.pendiente   { border-left-color: #ffdd88; }
.astrobuga_card.aceptado    { border-left-color: #00ccff; }
.astrobuga_card.solucionado { border-left-color: #ffaa33; }
.astrobuga_card.cancelado   { border-left-color: #ff4488; }
.astrobuga_card.borrado     { border-left-color: #666666; }

.astrobuga_card_head {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    flex-wrap: wrap;
    margin-bottom: 8px;
}

.astrobuga_card_left {
    display: flex;
    align-items: center;
    gap: 10px;
    flex: 1;
    min-width: 0;
}

.astrobuga_card_id {
    color: #00ccff;
    font-weight: 700;
    font-family: 'Courier New', monospace;
    font-size: 12px;
    white-space: nowrap;
    text-shadow: 0 0 6px rgba(0, 204, 255, 0.4);
}

.astrobuga_card_titulo {
    color: var(--text-title);
    font-size: 14px;
    font-weight: 700;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.astrobuga_card_estado {
    display: inline-block;
    padding: 3px 10px;
    border-radius: 12px;
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    white-space: nowrap;
}

.astrobuga_card_meta {
    display: flex;
    gap: 14px;
    font-size: 11px;
    color: var(--text-muted);
    margin-bottom: 10px;
    flex-wrap: wrap;
}

.astrobuga_card_meta span {
    display: inline-flex;
    align-items: center;
    gap: 4px;
}

.astrobuga_card_actions {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
    justify-content: flex-end;
    align-items: center;
}

/* Botones */
.astrobuga_btn {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    border: none;
    border-radius: 8px;
    color: #fff;
    font-size: 11px;
    font-weight: 700;
    padding: 8px 16px;
    cursor: pointer;
    transition: all 0.25s ease;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    text-decoration: none;
    font-family: inherit;
}
.astrobuga_btn:active {
    transform: translateY(0) !important;
}

.astrobuga_btn.green {
    background: linear-gradient(135deg, rgba(0, 102, 51, 0.9), rgba(0, 204, 102, 0.9));
    border: 1px solid #00ff88;
}
.astrobuga_btn.green:hover {
    background: linear-gradient(135deg, rgba(0, 204, 102, 0.95), rgba(0, 255, 136, 0.95));
    box-shadow: 0 0 14px rgba(0, 255, 136, 0.5);
    transform: translateY(-2px);
}

.astrobuga_btn.red {
    background: linear-gradient(135deg, rgba(102, 0, 34, 0.9), rgba(204, 34, 68, 0.9));
    border: 1px solid #ff4488;
}
.astrobuga_btn.red:hover {
    background: linear-gradient(135deg, rgba(204, 34, 68, 0.95), rgba(255, 68, 136, 0.95));
    box-shadow: 0 0 14px rgba(255, 68, 136, 0.5);
    transform: translateY(-2px);
}

.astrobuga_btn.orange {
    background: linear-gradient(135deg, rgba(170, 102, 0, 0.9), rgba(255, 170, 51, 0.9));
    border: 1px solid #ffcc66;
}
.astrobuga_btn.orange:hover {
    background: linear-gradient(135deg, rgba(255, 170, 51, 0.95), rgba(255, 204, 102, 0.95));
    box-shadow: 0 0 14px rgba(255, 170, 51, 0.5);
    color: #1a1000;
    transform: translateY(-2px);
}

.astrobuga_btn.blue {
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
    border: 1px solid #00ccff;
}
.astrobuga_btn.blue:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.5);
    transform: translateY(-2px);
}

.astrobuga_btn.grey {
    background: linear-gradient(135deg, rgba(51, 68, 85, 0.9), rgba(85, 102, 119, 0.9));
    border: 1px solid #667788;
}
.astrobuga_btn.grey:hover {
    background: linear-gradient(135deg, rgba(85, 102, 119, 0.95), rgba(102, 119, 136, 0.95));
    box-shadow: 0 0 14px rgba(100, 120, 140, 0.5);
    transform: translateY(-2px);
}

/* Estado vacío */
.astrobuga_empty {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px dashed rgba(0, 204, 255, 0.3);
    border-radius: 12px;
    padding: 50px 20px;
    text-align: center;
    color: var(--text-muted);
    font-size: 13px;
}

.astrobuga_empty .icon {
    font-size: 48px;
    display: block;
    margin-bottom: 12px;
    opacity: 0.4;
}

/* Detalle de reporte */
.astrobuga_detail {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    padding: 20px 25px;
    margin-bottom: 15px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    transition: 0.2s ease;
}
.astrobuga_detail:hover {
    border-color: rgba(0, 204, 255, 0.3);
}

.astrobuga_detail_title {
    color: #00ccff;
    font-size: 13px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1px;
    margin-bottom: 10px;
    padding-bottom: 8px;
    border-bottom: 1px solid rgba(0, 204, 255, 0.15);
    text-shadow: 0 0 6px rgba(0, 204, 255, 0.3);
}

.astrobuga_detail_content {
    color: var(--text-main);
    font-size: 13px;
    line-height: 1.6;
    white-space: pre-wrap;
    word-wrap: break-word;
}

/* Modal de cancelación */
.astrobuga_modal {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.75);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    z-index: 9999;
    justify-content: center;
    align-items: center;
}

.astrobuga_modal.active {
    display: flex;
}

.astrobuga_modal_content {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(255, 68, 136, 0.5);
    border-radius: 12px;
    padding: 25px;
    max-width: 500px;
    width: 90%;
    box-shadow: 0 0 40px rgba(255, 68, 136, 0.4);
}

.astrobuga_modal_title {
    color: #ff4488;
    font-size: 16px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1px;
    margin-bottom: 15px;
    text-shadow: 0 0 10px rgba(255, 68, 136, 0.5);
}

.astrobuga_modal_label {
    display: block;
    color: #00ccff;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1px;
    margin-bottom: 6px;
}

.astrobuga_modal_input {
    width: 100%;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    color: #ffffff;
    padding: 10px 14px;
    font-size: 13px;
    font-family: inherit;
    min-height: 100px;
    resize: vertical;
    box-sizing: border-box;
    margin-bottom: 15px;
    transition: 0.25s ease;
    outline: none;
}
.astrobuga_modal_input:focus {
    border-color: #00e0ff;
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}

.astrobuga_modal_actions {
    display: flex;
    gap: 10px;
    justify-content: flex-end;
}

/* Responsive */
@media (max-width: 720px) {
    .astrobuga_wrap { padding: 10px; }
    .astrobuga_header { padding: 16px 18px; }
    .astrobuga_title { font-size: 18px; }
    .astrobuga_dash { grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); }
    .astrobuga_card { padding: 12px 14px; }
    .astrobuga_card_titulo { white-space: normal; }
    .astrobuga_card_actions { justify-content: stretch; }
    .astrobuga_btn { width: 100%; justify-content: center; box-sizing: border-box; }
}
</style>

<div class="astrobuga_wrap">

    {if $astrobuga_msg_success}
        <div class="astrobuga_msg success">{$astrobuga_msg_success}</div>
    {/if}
    {if $astrobuga_msg_error}
        <div class="astrobuga_msg error">{$astrobuga_msg_error}</div>
    {/if}

    <div class="astrobuga_header">
        <div class="astrobuga_title">🐛 GESTIÓN DE REPORTES DE BUG</div>
        <div class="astrobuga_subtitle">Administrá los bugs reportados por los jugadores</div>
    </div>

    {* ===== TABS ===== *}
    <div class="astrobuga_tabs">
        <a href="admin.php?page=bugreportadmin" class="astrobuga_tab {if $astrobuga_current_mode == 'show' || $astrobuga_current_mode == ''}active{/if}">
            📊 Dashboard
        </a>
        <a href="admin.php?page=bugreportadmin&mode=pendientes" class="astrobuga_tab {if $astrobuga_current_mode == 'pendientes'}active{/if}">
            📥 Pendientes {if $astrobuga_stats.pendientes > 0}<span class="count">{$astrobuga_stats.pendientes}</span>{/if}
        </a>
        <a href="admin.php?page=bugreportadmin&mode=aceptados" class="astrobuga_tab {if $astrobuga_current_mode == 'aceptados'}active{/if}">
            ✅ Aceptados {if $astrobuga_stats.aceptados > 0}<span class="count">{$astrobuga_stats.aceptados}</span>{/if}
        </a>
        <a href="admin.php?page=bugreportadmin&mode=solucionados" class="astrobuga_tab {if $astrobuga_current_mode == 'solucionados'}active{/if}">
            🟠 Solucionados {if $astrobuga_stats.solucionados > 0}<span class="count">{$astrobuga_stats.solucionados}</span>{/if}
        </a>
        <a href="admin.php?page=bugreportadmin&mode=historial" class="astrobuga_tab {if $astrobuga_current_mode == 'historial'}active{/if}">
            📜 Historial
        </a>
    </div>

    {* ===== MODO: DASHBOARD ===== *}
    {if $astrobuga_current_mode == 'show' || $astrobuga_current_mode == ''}
        <div class="astrobuga_dash">
            <div class="astrobuga_stat pendientes">
                <span class="icon">📥</span>
                <span class="value">{$astrobuga_stats.pendientes}</span>
                <span class="label">Pendientes</span>
            </div>
            <div class="astrobuga_stat aceptados">
                <span class="icon">✅</span>
                <span class="value">{$astrobuga_stats.aceptados}</span>
                <span class="label">Aceptados</span>
            </div>
            <div class="astrobuga_stat solucionados">
                <span class="icon">🟠</span>
                <span class="value">{$astrobuga_stats.solucionados}</span>
                <span class="label">Solucionados</span>
            </div>
            <div class="astrobuga_stat cancelados">
                <span class="icon">❌</span>
                <span class="value">{$astrobuga_stats.cancelados}</span>
                <span class="label">Cancelados</span>
            </div>
            <div class="astrobuga_stat borrados">
                <span class="icon">🗑️</span>
                <span class="value">{$astrobuga_stats.borrados}</span>
                <span class="label">Borrados</span>
            </div>
            <div class="astrobuga_stat">
                <span class="icon">📊</span>
                <span class="value">{$astrobuga_stats.total}</span>
                <span class="label">Total</span>
            </div>
        </div>

        <div class="astrobuga_detail">
            <div class="astrobuga_detail_title">📌 ¿Cómo funciona el sistema?</div>
            <div class="astrobuga_detail_content">
                1. Los jugadores crean reportes desde el juego (menú MOP → Reportar Bug).
                2. Los reportes llegan a la pestaña "Pendientes".
                3. El admin puede ACEPTARLO (es un bug real) o CANCELARLO (no es bug).
                4. Si se acepta → aparece en "Aceptados". El jugador lo ve como "En Proceso".
                5. Cuando el admin arregla el bug en código → MARCAR SOLUCIONADO.
                6. El jugador lo ve como "Pendiente Update".
                7. Cuando se aplica el update en el servidor → BORRAR.
                8. El reporte desaparece para todos.

                Los reportes BORRADOS y CANCELADOS quedan en el "Historial".
            </div>
        </div>
    {/if}

    {* ===== MODO: VER DETALLE ===== *}
    {if $astrobuga_current_mode == 'ver' && $astrobuga_reporte}
        <div class="astrobuga_detail">
            <div class="astrobuga_detail_title">
                Reporte #{$astrobuga_reporte.id} — {$astrobuga_reporte.titulo}
            </div>
            <div class="astrobuga_card_meta" style="margin-bottom: 15px;">
                <span>{$astrobuga_reporte.categoria_emoji} {$astrobuga_reporte.categoria_nombre}</span>
                <span>👤 {$astrobuga_reporte.jugador}</span>
                <span>📅 {$astrobuga_reporte.fecha_creacion|date_format:"%d/%m/%Y - %H:%M"}</span>
                <span class="astrobuga_card_estado" style="background: {$astrobuga_reporte.estado_info.color}22; color: {$astrobuga_reporte.estado_info.color}; border: 1px solid {$astrobuga_reporte.estado_info.color};">
                    {$astrobuga_reporte.estado_info.icono} {$astrobuga_reporte.estado_info.texto}
                </span>
            </div>
            <div class="astrobuga_detail_content">{$astrobuga_reporte.descripcion}</div>
        </div>

        {if $astrobuga_log}
            <div class="astrobuga_detail">
                <div class="astrobuga_detail_title">🕐 Historial del reporte</div>
                <div class="astrobuga_detail_content">
                    {foreach $astrobuga_log as $l}
                        • [{$l.fecha|date_format:"%d/%m/%Y - %H:%M"}] <strong>{$l.accion}</strong>{if $l.detalle} — {$l.detalle}{/if}
                        {"\n"}
                    {/foreach}
                </div>
            </div>
        {/if}

        <div style="text-align: center; margin-top: 15px;">
            <a href="admin.php?page=bugreportadmin&mode={$astrobuga_reporte.estado}" class="astrobuga_btn grey">← Volver</a>
        </div>
    {/if}

    {* ===== MODO: LISTADOS (pendientes, aceptados, solucionados, historial) ===== *}
    {if in_array($astrobuga_current_mode, ['pendientes', 'aceptados', 'solucionados', 'historial'])}
        {if $astrobuga_reportes}
            <div class="astrobuga_list">
                {foreach $astrobuga_reportes as $r}
                    <div class="astrobuga_card {$r.estado}">
                        <div class="astrobuga_card_head">
                            <div class="astrobuga_card_left">
                                <span class="astrobuga_card_id">#{$r.id}</span>
                                <span class="astrobuga_card_titulo">{$r.titulo}</span>
                            </div>
                            <span class="astrobuga_card_estado" style="background: {$r.estado_info.color}22; color: {$r.estado_info.color}; border: 1px solid {$r.estado_info.color};">
                                {$r.estado_info.icono} {$r.estado_info.texto}
                            </span>
                        </div>

                        <div class="astrobuga_card_meta">
                            <span>{$r.categoria_emoji} {$r.categoria_nombre}</span>
                            <span>👤 {$r.jugador}</span>
                            <span>📅 {$r.fecha_creacion|date_format:"%d/%m/%Y"}</span>
                            {if isset($r.admin_nombre) && $r.admin_nombre}<span>🛡️ {$r.admin_nombre}</span>{/if}
                        </div>

                        <div class="astrobuga_card_actions">
                            <a href="admin.php?page=bugreportadmin&mode=ver&id={$r.id}" class="astrobuga_btn blue">👁️ Ver</a>

                            {if $r.estado == 'pendiente'}
                                <form method="post" action="admin.php?page=bugreportadmin" style="margin:0;display:inline;">
                                    <input type="hidden" name="action" value="aceptar">
                                    <input type="hidden" name="report_id" value="{$r.id}">
                                    <button type="submit" class="astrobuga_btn green">✅ Aceptar</button>
                                </form>
                                <button type="button" class="astrobuga_btn red" onclick="astrobuga_openCancel({$r.id});">❌ Cancelar</button>
                            {/if}

                            {if $r.estado == 'aceptado'}
                                <form method="post" action="admin.php?page=bugreportadmin" style="margin:0;display:inline;">
                                    <input type="hidden" name="action" value="solucionar">
                                    <input type="hidden" name="report_id" value="{$r.id}">
                                    <button type="submit" class="astrobuga_btn orange">🟠 Marcar Solucionado</button>
                                </form>
                                <button type="button" class="astrobuga_btn red" onclick="astrobuga_openCancel({$r.id});">❌ Cancelar</button>
                            {/if}

                            {if $r.estado == 'solucionado'}
                                <form method="post" action="admin.php?page=bugreportadmin" style="margin:0;display:inline;" onsubmit="return confirm('¿Borrar el reporte #{$r.id}? Una vez borrado no se puede recuperar.');">
                                    <input type="hidden" name="action" value="borrar">
                                    <input type="hidden" name="report_id" value="{$r.id}">
                                    <button type="submit" class="astrobuga_btn red">🗑️ Borrar</button>
                                </form>
                            {/if}
                        </div>
                    </div>
                {/foreach}
            </div>
        {else}
            <div class="astrobuga_empty">
                <span class="icon">📭</span>
                <strong>No hay reportes en esta sección.</strong>
            </div>
        {/if}
    {/if}

</div>

{* ===== MODAL DE CANCELACIÓN ===== *}
<div class="astrobuga_modal" id="astrobuga_cancel_modal">
    <div class="astrobuga_modal_content">
        <div class="astrobuga_modal_title">⚠️ Cancelar Reporte</div>
        <form method="post" action="admin.php?page=bugreportadmin" id="astrobuga_cancel_form">
            <input type="hidden" name="action" value="cancelar">
            <input type="hidden" name="report_id" id="astrobuga_cancel_report_id" value="">

            <label class="astrobuga_modal_label">Motivo (obligatorio, mínimo 5 caracteres)</label>
            <textarea name="motivo" class="astrobuga_modal_input" placeholder="Explicá por qué se cancela este reporte..." required minlength="5"></textarea>

            <div class="astrobuga_modal_actions">
                <button type="button" class="astrobuga_btn grey" onclick="astrobuga_closeCancel();">Cancelar</button>
                <button type="submit" class="astrobuga_btn red">🗑️ Cancelar Reporte</button>
            </div>
        </form>
    </div>
</div>

<script>
function astrobuga_openCancel(reportId) {
    document.getElementById('astrobuga_cancel_report_id').value = reportId;
    document.getElementById('astrobuga_cancel_modal').classList.add('active');
}

function astrobuga_closeCancel() {
    document.getElementById('astrobuga_cancel_modal').classList.remove('active');
    document.getElementById('astrobuga_cancel_report_id').value = '';
}

document.getElementById('astrobuga_cancel_modal').addEventListener('click', function(e) {
    if (e.target === this) {
        astrobuga_closeCancel();
    }
});
</script>

{include file="overall_footer.tpl"}