{block name="title" prepend}Detalle de Solicitud{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.wallet.solicitud.tpl === *}
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


<style>
/* ═══════════════════════════════════════════════════════════
   DETALLE DE SOLICITUD — Vista del usuario
   AstroIO v5.0
   Prefijo: .astrowalsol_
   ═══════════════════════════════════════════════════════════ */

.astrowalsol_wrap {
    text-align: center;
    margin: 20px 0;
}

.astrowalsol_panel {
    display: inline-block;
    width: 100%;
    max-width: 900px;
    background: linear-gradient(135deg, #0f1624 0%, #1a2332 100%);
    border: 1px solid rgba(0,204,255,0.25);
    border-radius: 10px;
    padding: 16px 20px;
    box-shadow: 0 4px 14px rgba(0,0,0,0.4);
    text-align: left;
    font-size: 11px;
    color: #c8d6e5;
    box-sizing: border-box;
}

/* ─── HEADER ─────────────────────────────────────────────── */
.astrowalsol_header {
    border-bottom: 1px solid rgba(0,204,255,0.2);
    padding-bottom: 12px;
    margin-bottom: 16px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 10px;
}

.astrowalsol_title {
    font-size: 15px;
    font-weight: bold;
    color: #00e0ff;
    text-transform: uppercase;
    letter-spacing: 1px;
    margin: 0;
}

.astrowalsol_id {
    font-family: 'Courier New', monospace;
    color: #7a8ba0;
    font-size: 11px;
    margin-left: 6px;
}

/* ─── BADGES ESTADO ──────────────────────────────────────── */
.astrowalsol_badge {
    display: inline-block;
    padding: 5px 12px;
    border-radius: 6px;
    font-size: 10.5px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}
.astrowalsol_badge.pendiente { background: rgba(255,170,51,0.2);  color: #ffaa33; border: 1px solid #ffaa33; }
.astrowalsol_badge.info      { background: rgba(0,224,255,0.2);   color: #00e0ff; border: 1px solid #00e0ff; }
.astrowalsol_badge.ok        { background: rgba(102,255,153,0.2); color: #66ff99; border: 1px solid #66ff99; }
.astrowalsol_badge.error     { background: rgba(255,68,136,0.2);  color: #ff4488; border: 1px solid #ff4488; }
.astrowalsol_badge.gray      { background: rgba(122,139,160,0.2); color: #7a8ba0; border: 1px solid #7a8ba0; }

/* ─── ALERTAS ────────────────────────────────────────────── */
.astrowalsol_alerta {
    padding: 10px 14px;
    border-radius: 8px;
    margin-bottom: 14px;
    font-size: 11px;
    line-height: 1.6;
}
.astrowalsol_alerta_ok     { background: rgba(102,255,153,0.12); border-left: 3px solid #66ff99; color: #66ff99; }
.astrowalsol_alerta_error  { background: rgba(255,68,136,0.12);  border-left: 3px solid #ff4488; color: #ff4488; }
.astrowalsol_alerta_info   { background: rgba(0,204,255,0.1);    border-left: 3px solid #00ccff; color: #00e0ff; }
.astrowalsol_alerta_warn   { background: rgba(221,136,0,0.12);   border-left: 3px solid #dd8800; color: #ffaa33; }
.astrowalsol_alerta strong { display: block; margin-bottom: 4px; font-size: 12px; }

/* ─── GRID DE DATOS ──────────────────────────────────────── */
.astrowalsol_grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    gap: 10px;
    margin-bottom: 16px;
}
.astrowalsol_card {
    background: rgba(15,22,36,0.6);
    border: 1px solid rgba(0,204,255,0.15);
    border-radius: 8px;
    padding: 10px 12px;
}
.astrowalsol_card_label {
    font-size: 9.5px;
    color: #7a8ba0;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 4px;
}
.astrowalsol_card_value {
    font-size: 14px;
    font-weight: bold;
    font-family: 'Courier New', monospace;
    color: #00e0ff;
}
.astrowalsol_card_value.kyber  { color: #00e0ff; }
.astrowalsol_card_value.nxt    { color: #aa44ff; }
.astrowalsol_card_value.ok     { color: #66ff99; }
.astrowalsol_card_value.err    { color: #ff4488; }
.astrowalsol_card_value.gray   { color: #7a8ba0; }

/* ─── SECCIONES ──────────────────────────────────────────── */
.astrowalsol_section {
    background: rgba(15,22,36,0.6);
    border: 1px solid rgba(0,204,255,0.15);
    border-radius: 8px;
    padding: 14px 16px;
    margin-bottom: 14px;
}
.astrowalsol_section_title {
    color: #00e0ff;
    font-size: 12px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin: 0 0 12px 0;
    padding-bottom: 8px;
    border-bottom: 1px solid rgba(0,204,255,0.15);
}

/* ─── DATOS BANCARIOS ────────────────────────────────────── */
.astrowalsol_banco {
    background: linear-gradient(135deg, rgba(0,102,204,0.15) 0%, rgba(0,153,255,0.08) 100%);
    border: 1px solid #00ccff;
    border-radius: 8px;
    padding: 16px;
    margin-bottom: 14px;
}
.astrowalsol_banco_title {
    color: #00e0ff;
    font-size: 12px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin: 0 0 12px 0;
    text-align: center;
}
.astrowalsol_banco_row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 8px 0;
    border-bottom: 1px dashed rgba(0,204,255,0.2);
    gap: 10px;
    flex-wrap: wrap;
}
.astrowalsol_banco_row:last-child {
    border-bottom: none;
}
.astrowalsol_banco_label {
    color: #7a8ba0;
    font-size: 10.5px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-weight: bold;
}
.astrowalsol_banco_value {
    color: #ffffff;
    font-family: 'Courier New', monospace;
    font-size: 13px;
    font-weight: bold;
    background: rgba(0,0,0,0.3);
    padding: 6px 12px;
    border-radius: 6px;
    letter-spacing: 0.5px;
    user-select: all;
}
.astrowalsol_banco_value.highlight {
    color: #ffaa33;
    background: rgba(255,170,51,0.15);
    border: 1px solid rgba(255,170,51,0.4);
}

/* ─── FORM SUBIR COMPROBANTE ─────────────────────────────── */
.astrowalsol_form_group {
    margin-bottom: 12px;
}
.astrowalsol_form_label {
    display: block;
    color: #00e0ff;
    font-size: 11px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 6px;
}
.astrowalsol_form_input {
    width: 100%;
    padding: 11px 14px;
    background: #0a0e17;
    border: 1px solid #2a3a52;
    border-radius: 6px;
    color: #c8d6e5;
    font-size: 13px;
    font-family: 'Courier New', monospace;
    box-sizing: border-box;
    outline: none;
    transition: 0.2s ease;
    letter-spacing: 1px;
}
.astrowalsol_form_input:focus {
    border-color: #00ccff;
    box-shadow: 0 0 14px rgba(0,224,255,0.35);
    background: #0d121c;
}
.astrowalsol_form_input::placeholder {
    color: #4a5a72;
    font-style: italic;
    letter-spacing: 0;
    font-family: 'Segoe UI', sans-serif;
}
.astrowalsol_form_help {
    font-size: 10px;
    color: #7a8ba0;
    font-style: italic;
    margin-top: 4px;
    line-height: 1.4;
}

/* ─── TIMELINE DE LOGS ───────────────────────────────────── */
.astrowalsol_timeline {
    list-style: none;
    padding: 0;
    margin: 0;
    position: relative;
    padding-left: 20px;
}
.astrowalsol_timeline:before {
    content: '';
    position: absolute;
    left: 6px;
    top: 6px;
    bottom: 6px;
    width: 2px;
    background: linear-gradient(180deg, #00ccff 0%, rgba(0,204,255,0.1) 100%);
}
.astrowalsol_timeline_item {
    position: relative;
    padding: 6px 0 12px 12px;
    font-size: 11px;
}
.astrowalsol_timeline_item:before {
    content: '';
    position: absolute;
    left: -20px;
    top: 10px;
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: #00ccff;
    box-shadow: 0 0 8px rgba(0,224,255,0.6);
    border: 2px solid #0f1624;
}
.astrowalsol_timeline_accion {
    color: #00e0ff;
    font-weight: bold;
    text-transform: uppercase;
    font-size: 10px;
    letter-spacing: 0.5px;
    display: block;
    margin-bottom: 2px;
}
.astrowalsol_timeline_detalle {
    color: #c8d6e5;
    display: block;
    line-height: 1.4;
}
.astrowalsol_timeline_meta {
    color: #7a8ba0;
    font-size: 9.5px;
    display: block;
    margin-top: 3px;
    font-style: italic;
}

/* ─── ACCIONES ───────────────────────────────────────────── */
.astrowalsol_actions {
    text-align: center;
    margin-top: 18px;
    padding-top: 14px;
    border-top: 1px solid rgba(0,204,255,0.15);
}

.astrowalsol_btn {
    display: inline-block;
    padding: 10px 24px;
    border-radius: 8px;
    font-size: 11px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    text-decoration: none;
    border: none;
    cursor: pointer;
    margin: 4px 4px;
    transition: 0.2s ease;
    box-shadow: 0 4px 14px rgba(0,0,0,0.4);
}
.astrowalsol_btn_primary {
    background: linear-gradient(135deg, #0066cc 0%, #0099ff 100%);
    color: #ffffff;
}
.astrowalsol_btn_primary:hover {
    box-shadow: 0 0 14px rgba(0,224,255,0.55);
    transform: translateY(-1px);
}
.astrowalsol_btn_ok {
    background: linear-gradient(135deg, #00aa55 0%, #00dd77 100%);
    color: #ffffff;
}
.astrowalsol_btn_ok:hover {
    box-shadow: 0 0 14px rgba(102,255,153,0.55);
    transform: translateY(-1px);
}
.astrowalsol_btn_danger {
    background: linear-gradient(135deg, #aa2255 0%, #ff4488 100%);
    color: #ffffff;
}
.astrowalsol_btn_danger:hover {
    box-shadow: 0 0 14px rgba(255,68,136,0.55);
    transform: translateY(-1px);
}
.astrowalsol_btn_gray {
    background: linear-gradient(135deg, #2a3a52 0%, #3a4a62 100%);
    color: #ffffff;
}
.astrowalsol_btn_gray:hover {
    box-shadow: 0 0 14px rgba(122,139,160,0.35);
    transform: translateY(-1px);
}

/* ─── MODAL CANCELAR ─────────────────────────────────────── */
.astrowalsol_modal_bg {
    display: none;
    position: fixed;
    top: 0; left: 0;
    width: 100%; height: 100%;
    background: rgba(0,0,0,0.7);
    z-index: 9999;
    text-align: center;
}
.astrowalsol_modal_bg:target {
    display: block;
}
.astrowalsol_modal {
    display: inline-block;
    background: linear-gradient(135deg, #0f1624 0%, #1a2332 100%);
    border: 1px solid #00ccff;
    border-radius: 10px;
    padding: 20px;
    max-width: 480px;
    width: 90%;
    margin-top: 100px;
    box-shadow: 0 4px 14px rgba(0,0,0,0.4);
    text-align: left;
    position: relative;
}
.astrowalsol_modal_title {
    color: #ff4488;
    font-size: 13px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin: 0 0 12px 0;
    padding-bottom: 8px;
    border-bottom: 1px solid rgba(255,68,136,0.25);
}
.astrowalsol_modal_textarea {
    width: 100%;
    background: #0a0e17;
    border: 1px solid #2a3a52;
    border-radius: 6px;
    padding: 10px;
    color: #c8d6e5;
    font-size: 11px;
    font-family: 'Segoe UI', sans-serif;
    box-sizing: border-box;
    resize: vertical;
    outline: none;
    min-height: 70px;
}
.astrowalsol_modal_textarea:focus {
    border-color: #00ccff;
    box-shadow: 0 0 14px rgba(0,224,255,0.35);
}
.astrowalsol_modal_actions {
    margin-top: 14px;
    padding-top: 12px;
    border-top: 1px solid rgba(0,204,255,0.15);
    text-align: right;
}
.astrowalsol_modal_close {
    position: absolute;
    top: 10px;
    right: 14px;
    color: #7a8ba0;
    text-decoration: none;
    font-size: 20px;
    font-weight: bold;
    line-height: 1;
}
.astrowalsol_modal_close:hover {
    color: #ff4488;
}

/* ─── RESPONSIVE ─────────────────────────────────────────── */
@media (max-width: 720px) {
    .astrowalsol_panel { padding: 12px 14px; }
    .astrowalsol_title { font-size: 13px; }
    .astrowalsol_banco_value { font-size: 11px; padding: 5px 10px; }
    .astrowalsol_card_value { font-size: 12px; }
}
@media (max-width: 480px) {
    .astrowalsol_btn { display: block; width: 100%; margin: 4px 0; }
    .astrowalsol_banco_row { flex-direction: column; align-items: flex-start; }
    .astrowalsol_banco_value { width: 100%; text-align: center; }
}
</style>

<div class="astrowalsol_wrap">
    <div class="astrowalsol_panel">

        {* ─── HEADER ─────────────────────────────────────── *}
        <div class="astrowalsol_header">
            <div>
                <span class="astrowalsol_title">📋 Solicitud</span>
                <span class="astrowalsol_id">#{$solicitud.id}</span>
            </div>
            <span class="astrowalsol_badge {$solicitud.estado_clase}">
                {$solicitud.estado_label}
            </span>
        </div>

        {* ─── FEEDBACK ───────────────────────────────────── *}
        {if $feedback_error}
            <div class="astrowalsol_alerta astrowalsol_alerta_error">
                <strong>❌ Error</strong>
                {$feedback_error|escape:'html'}
            </div>
        {/if}

        {if $feedback_ok == 'comprobante_enviado'}
            <div class="astrowalsol_alerta astrowalsol_alerta_ok">
                <strong>✅ Comprobante enviado</strong>
                Tu ID de transferencia fue registrado. El admin lo verificará y te notificará.
            </div>
        {/if}

        {if $feedback_ok == 'solicitud_cancelada'}
            <div class="astrowalsol_alerta astrowalsol_alerta_info">
                <strong>ℹ️ Solicitud cancelada</strong>
                Tu solicitud fue cancelada correctamente. Podés crear una nueva cuando quieras.
            </div>
        {/if}

        {* ─── ESTADO: rechazada / cancelada / expirada ───── *}
        {if $solicitud.estado == 'rechazada'}
            <div class="astrowalsol_alerta astrowalsol_alerta_error">
                <strong>❌ Solicitud rechazada</strong>
                {$solicitud.motivo|escape:'html'|default:'Sin motivo especificado.'}
                <br><br>
                ¿Tenés dudas? Abrí un ticket en el foro para que un admin te explique.
            </div>
        {/if}

        {if $solicitud.estado == 'cancelada'}
            <div class="astrowalsol_alerta astrowalsol_alerta_warn">
                <strong>🚫 Solicitud cancelada</strong>
                {$solicitud.motivo|escape:'html'|default:'Sin motivo especificado.'}
            </div>
        {/if}

        {if $solicitud.estado == 'expirada'}
            <div class="astrowalsol_alerta astrowalsol_alerta_warn">
                <strong>⌛ Solicitud expirada</strong>
                {$solicitud.motivo|escape:'html'|default:'La solicitud expiró por inactividad.'}
            </div>
        {/if}

        {* ─── ESTADO: completada ─────────────────────────── *}
        {if $solicitud.estado == 'completada'}
            <div class="astrowalsol_alerta astrowalsol_alerta_ok">
                <strong>✅ ¡Inversión completada!</strong>
                Recibiste <strong>💲 {$solicitud.nxt20_entregado} NXT-20</strong> en tu cuenta.
                Ya podés usarlos en el juego o retirarlos cuando quieras.
            </div>
        {/if}

        {* ─── ESTADO: esperando admin ───────────────────── *}
        {if $solicitud.estado == 'pendiente_sin_asignar'}
            <div class="astrowalsol_alerta astrowalsol_alerta_info">
                <strong>⏳ Esperando ser tomada por un admin</strong>
                Tu solicitud está en la cola. En cuanto un admin la tome,
                te enviará los datos bancarios para hacer la transferencia.
            </div>
        {/if}

        {* ─── ESTADO: admin asignado ─────────────────────── *}
        {if $solicitud.estado == 'pendiente_asignada'}
            <div class="astrowalsol_alerta astrowalsol_alerta_info">
                <strong>👤 Admin asignado</strong>
                Un administrador ya tomó tu solicitud. En breve recibirás
                los datos bancarios para hacer la transferencia.
            </div>
        {/if}

        {* ─── ESTADO: verificación ───────────────────────── *}
        {if $solicitud.estado == 'pendiente_verificacion'}
            <div class="astrowalsol_alerta astrowalsol_alerta_info">
                <strong>🔍 Verificando tu pago</strong>
                Tu comprobante fue recibido. El admin está verificando la transferencia.
                Recibirás una notificación cuando se confirme.
            </div>
        {/if}

        {* ─── DATOS DE LA SOLICITUD (v5.0: solo lo que el usuario ve) ─── *}
        <div class="astrowalsol_grid">
            <div class="astrowalsol_card">
                <div class="astrowalsol_card_label">Monto invertido</div>
                <div class="astrowalsol_card_value kyber">{$solicitud.cantidad_kyber} <small style="font-size:10px;color:#7a8ba0;">Kyber</small></div>
            </div>
            <div class="astrowalsol_card">
                <div class="astrowalsol_card_label">💲 NXT-20 a recibir</div>
                <div class="astrowalsol_card_value nxt">{$solicitud.nxt20_entregado}</div>
            </div>
            <div class="astrowalsol_card">
                <div class="astrowalsol_card_label">Fecha de creación</div>
                <div class="astrowalsol_card_value" style="font-size:11px;">{$solicitud.fecha}</div>
            </div>
            {if $solicitud.fecha_resolucion}
            <div class="astrowalsol_card">
                <div class="astrowalsol_card_label">Fecha de resolución</div>
                <div class="astrowalsol_card_value" style="font-size:11px;">{$solicitud.fecha_resolucion}</div>
            </div>
            {/if}
        </div>

        {* ─── DATOS BANCARIOS (solo si corresponde) ──────── *}
        {if $mostrar_banco}
            <div class="astrowalsol_banco">
                <h3 class="astrowalsol_banco_title">💳 Datos para tu transferencia</h3>

                <div class="astrowalsol_banco_row">
                    <span class="astrowalsol_banco_label">💳 Tarjeta magnética</span>
                    <span class="astrowalsol_banco_value">{$solicitud.admin_tarjeta|escape:'html'}</span>
                </div>

                <div class="astrowalsol_banco_row">
                    <span class="astrowalsol_banco_label">📱 Teléfono</span>
                    <span class="astrowalsol_banco_value">{$solicitud.admin_telefono|escape:'html'}</span>
                </div>

                <div class="astrowalsol_banco_row">
                    <span class="astrowalsol_banco_label">💰 Monto a transferir</span>
                    <span class="astrowalsol_banco_value highlight">{$solicitud.cantidad_kyber} Kyber equivalente</span>
                </div>

                {if $solicitud.referencia}
                <div class="astrowalsol_banco_row">
                    <span class="astrowalsol_banco_label">🔢 ID de transferencia enviado</span>
                    <span class="astrowalsol_banco_value">{$solicitud.referencia|escape:'html'}</span>
                </div>
                {/if}
            </div>
        {/if}

        {* ─── FORMULARIO SUBIR COMPROBANTE ───────────────── *}
        {if $puede_subir_comprobante}
            <div class="astrowalsol_section">
                <h3 class="astrowalsol_section_title">📤 Subir comprobante de transferencia</h3>

                <div class="astrowalsol_alerta astrowalsol_alerta_info" style="margin-top:0;">
                    <strong>ℹ️ ¿Cómo proceder?</strong>
                    1. Hacé la transferencia desde tu banco.<br>
                    2. Copiá el <strong>ID/número de operación</strong> que te dio el banco.<br>
                    3. Pegalo abajo y enviá el comprobante.<br>
                    4. El admin lo verificará y te confirmará la inversión.
                </div>

                <form method="post" action="game.php?page=wallet&mode=doSubirComprobante">
                    <input type="hidden" name="id" value="{$solicitud.id}">

                    <div class="astrowalsol_form_group">
                        <label class="astrowalsol_form_label">🔢 ID de transferencia</label>
                        <input 
                            type="text" 
                            name="transferencia_id" 
                            class="astrowalsol_form_input" 
                            placeholder="Ejemplo: ABC-987654 o 2024091812345"
                            maxlength="100"
                            required
                            autocomplete="off"
                        />
                        <div class="astrowalsol_form_help">
                            Copialo EXACTAMENTE como aparece en tu comprobante bancario.
                            Esto ayuda al admin a identificar tu pago.
                        </div>
                    </div>

                    <div style="text-align:center; margin-top:14px;">
                        <button type="submit" class="astrowalsol_btn astrowalsol_btn_ok"
                                onclick="return confirm('¿Enviar comprobante?\n\nAsegurate de que el ID sea correcto.');">
                            ✅ Enviar comprobante
                        </button>
                    </div>
                </form>
            </div>
        {/if}

        {* ─── TIMELINE DE LOGS ───────────────────────────── *}
        {if $logs|@count > 0}
            <div class="astrowalsol_section">
                <h3 class="astrowalsol_section_title">📜 Historial de la solicitud</h3>

                <ul class="astrowalsol_timeline">
                    {foreach $logs as $log}
                        <li class="astrowalsol_timeline_item">
                            <span class="astrowalsol_timeline_accion">{$log.accion|escape:'html'}</span>
                            <span class="astrowalsol_timeline_detalle">{$log.detalle|escape:'html'}</span>
                            <span class="astrowalsol_timeline_meta">
                                {$log.fecha}
                                {if $log.admin} · Admin: {$log.admin|escape:'html'}{/if}
                            </span>
                        </li>
                    {/foreach}
                </ul>
            </div>
        {/if}

        {* ─── ACCIONES ───────────────────────────────────── *}
        <div class="astrowalsol_actions">

            <a href="game.php?page=wallet" class="astrowalsol_btn astrowalsol_btn_gray">
                ← Volver al Wallet
            </a>

            {if $puede_cancelar}
                <a href="#modal_cancelar" class="astrowalsol_btn astrowalsol_btn_danger">
                    🔴 Cancelar solicitud
                </a>
            {/if}

        </div>

        {* ─── MODAL CANCELAR ─────────────────────────────── *}
        {if $puede_cancelar}
            <div id="modal_cancelar" class="astrowalsol_modal_bg">
                <div class="astrowalsol_modal">
                    <a href="#" class="astrowalsol_modal_close">×</a>
                    <h4 class="astrowalsol_modal_title">🔴 Cancelar Solicitud #{$solicitud.id}</h4>

                    <p style="font-size:11px; color:#c8d6e5; margin:0 0 10px 0; line-height:1.6;">
                        Si cancelás ahora:
                    </p>
                    <ul style="font-size:11px; color:#7a8ba0; margin:0 0 12px 18px; padding:0; line-height:1.6;">
                        <li>La solicitud se elimina del panel del admin</li>
                        <li>NO se ejecutará ninguna inversión</li>
                        <li>NO perderás Cristales Kyber (no se habían descontado)</li>
                        <li>Podés crear una nueva solicitud cuando quieras</li>
                    </ul>

                    <form method="post" action="game.php?page=wallet&mode=doCancelar">
                        <input type="hidden" name="id" value="{$solicitud.id}">

                        <label class="astrowalsol_form_label" style="margin-bottom:6px; display:block;">
                            Motivo (opcional)
                        </label>
                        <textarea 
                            name="motivo" 
                            class="astrowalsol_modal_textarea" 
                            placeholder="Ej: Cambié de opinión, prefiero invertir otro monto, etc."
                            maxlength="300"
                        ></textarea>

                        <div class="astrowalsol_modal_actions">
                            <a href="#" class="astrowalsol_btn astrowalsol_btn_gray">No, volver</a>
                            <button type="submit" class="astrowalsol_btn astrowalsol_btn_danger">
                                Sí, cancelar
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        {/if}

    </div>
</div>

{/block}