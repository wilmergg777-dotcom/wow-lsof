{block name="title" prepend}Detalle de Retiro{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.wallet.admin.verRetiro.tpl === *}
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
   DETALLE DE RETIRO — Vista del admin (página completa)
   Prefijo: .astrowalad_
   ═══════════════════════════════════════════════════════════ */

.astrowalad_wrap {
    text-align: center;
    margin: 20px 0;
}

.astrowalad_panel {
    display: inline-block;
    width: 100%;
    max-width: 900px;
    background: linear-gradient(135deg, #0f1624 0%, #1a2332 100%);
    border: 1px solid rgba(0,204,255,0.35);
    border-radius: 12px;
    padding: 18px 22px;
    box-shadow: 0 8px 30px rgba(0,0,0,0.7);
    text-align: left;
    font-size: 11px;
    color: #c8d6e5;
    box-sizing: border-box;
    position: relative;
}

/* ─── HEADER ─────────────────────────────────────────────── */
.astrowalad_header {
    border-bottom: 1px solid rgba(0,204,255,0.25);
    padding-bottom: 12px;
    margin-bottom: 16px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 10px;
}
.astrowalad_title {
    font-size: 15px;
    font-weight: bold;
    color: #00e0ff;
    text-transform: uppercase;
    letter-spacing: 1px;
    margin: 0;
}
.astrowalad_id {
    font-family: 'Courier New', monospace;
    color: #7a8ba0;
    font-size: 11px;
    margin-left: 6px;
}

/* ─── BADGES ESTADO ──────────────────────────────────────── */
.astrowalad_badge {
    display: inline-block;
    padding: 5px 12px;
    border-radius: 6px;
    font-size: 10.5px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}
.astrowalad_badge.pendiente { background: rgba(255,170,51,0.2);  color: #ffaa33; border: 1px solid #ffaa33; }
.astrowalad_badge.info      { background: rgba(0,224,255,0.2);   color: #00e0ff; border: 1px solid #00e0ff; }
.astrowalad_badge.ok        { background: rgba(102,255,153,0.2); color: #66ff99; border: 1px solid #66ff99; }
.astrowalad_badge.error     { background: rgba(255,68,136,0.2);  color: #ff4488; border: 1px solid #ff4488; }
.astrowalad_badge.gray      { background: rgba(122,139,160,0.2); color: #7a8ba0; border: 1px solid #7a8ba0; }

/* ─── ALERTAS ────────────────────────────────────────────── */
.astrowalad_alerta {
    padding: 10px 14px;
    border-radius: 8px;
    margin-bottom: 14px;
    font-size: 11px;
    line-height: 1.6;
}
.astrowalad_alerta_ok    { background: rgba(102,255,153,0.12); border-left: 3px solid #66ff99; color: #66ff99; }
.astrowalad_alerta_error { background: rgba(255,68,136,0.12);  border-left: 3px solid #ff4488; color: #ff4488; }
.astrowalad_alerta_info  { background: rgba(0,204,255,0.1);    border-left: 3px solid #00ccff; color: #00e0ff; }
.astrowalad_alerta_warn  { background: rgba(221,136,0,0.12);   border-left: 3px solid #dd8800; color: #ffaa33; }
.astrowalad_alerta strong { display: block; margin-bottom: 4px; font-size: 12px; }

/* ─── GRID DE DATOS ──────────────────────────────────────── */
.astrowalad_grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    gap: 10px;
    margin-bottom: 16px;
}
.astrowalad_card {
    background: rgba(15,22,36,0.6);
    border: 1px solid rgba(0,204,255,0.15);
    border-radius: 8px;
    padding: 10px 12px;
}
.astrowalad_card_label {
    font-size: 9.5px;
    color: #7a8ba0;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 4px;
}
.astrowalad_card_value {
    font-size: 14px;
    font-weight: bold;
    font-family: 'Courier New', monospace;
    color: #00e0ff;
}
.astrowalad_card_value.nxt  { color: #aa44ff; }
.astrowalad_card_value.ok   { color: #66ff99; }
.astrowalad_card_value.err  { color: #ff4488; }
.astrowalad_card_value.gray { color: #7a8ba0; }

/* ─── SECCIONES ──────────────────────────────────────────── */
.astrowalad_section {
    background: rgba(15,22,36,0.6);
    border: 1px solid rgba(0,204,255,0.15);
    border-radius: 8px;
    padding: 14px 16px;
    margin-bottom: 14px;
}
.astrowalad_section_title {
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
.astrowalad_banco {
    background: linear-gradient(135deg, rgba(0,102,204,0.15) 0%, rgba(0,153,255,0.08) 100%);
    border: 1px solid #00ccff;
    border-radius: 8px;
    padding: 16px;
    margin-bottom: 14px;
}
.astrowalad_banco_title {
    color: #00e0ff;
    font-size: 12px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin: 0 0 12px 0;
    text-align: center;
}
.astrowalad_banco_row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 8px 0;
    border-bottom: 1px dashed rgba(0,204,255,0.2);
    gap: 10px;
    flex-wrap: wrap;
}
.astrowalad_banco_row:last-child {
    border-bottom: none;
}
.astrowalad_banco_label {
    color: #7a8ba0;
    font-size: 10.5px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-weight: bold;
}
.astrowalad_banco_value {
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
.astrowalad_banco_value.highlight {
    color: #ffaa33;
    background: rgba(255,170,51,0.15);
    border: 1px solid rgba(255,170,51,0.4);
}

/* ─── TIMELINE DE LOGS ───────────────────────────────────── */
.astrowalad_timeline {
    list-style: none;
    padding: 0;
    margin: 0;
    position: relative;
    padding-left: 20px;
}
.astrowalad_timeline:before {
    content: '';
    position: absolute;
    left: 6px;
    top: 6px;
    bottom: 6px;
    width: 2px;
    background: linear-gradient(180deg, #00ccff 0%, rgba(0,204,255,0.1) 100%);
}
.astrowalad_timeline_item {
    position: relative;
    padding: 6px 0 12px 12px;
    font-size: 11px;
}
.astrowalad_timeline_item:before {
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
.astrowalad_timeline_accion {
    color: #00e0ff;
    font-weight: bold;
    text-transform: uppercase;
    font-size: 10px;
    letter-spacing: 0.5px;
    display: block;
    margin-bottom: 2px;
}
.astrowalad_timeline_detalle {
    color: #c8d6e5;
    display: block;
    line-height: 1.4;
}
.astrowalad_timeline_meta {
    color: #7a8ba0;
    font-size: 9.5px;
    display: block;
    margin-top: 3px;
    font-style: italic;
}

/* ─── ACCIONES ───────────────────────────────────────────── */
.astrowalad_actions {
    text-align: center;
    margin-top: 18px;
    padding-top: 14px;
    border-top: 1px solid rgba(0,204,255,0.15);
}
.astrowalad_btn {
    display: inline-block;
    padding: 10px 22px;
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
    font-family: 'Segoe UI', sans-serif;
}
.astrowalad_btn_primary {
    background: linear-gradient(135deg, #0066cc 0%, #0099ff 100%);
    color: #ffffff;
}
.astrowalad_btn_primary:hover {
    box-shadow: 0 0 14px rgba(0,224,255,0.55);
    transform: translateY(-1px);
}
.astrowalad_btn_ok {
    background: linear-gradient(135deg, #00aa55 0%, #00dd77 100%);
    color: #ffffff;
}
.astrowalad_btn_ok:hover {
    box-shadow: 0 0 14px rgba(102,255,153,0.55);
    transform: translateY(-1px);
}
.astrowalad_btn_danger {
    background: linear-gradient(135deg, #aa2255 0%, #ff4488 100%);
    color: #ffffff;
}
.astrowalad_btn_danger:hover {
    box-shadow: 0 0 14px rgba(255,68,136,0.55);
    transform: translateY(-1px);
}
.astrowalad_btn_warn {
    background: linear-gradient(135deg, #aa6600 0%, #fbbf24 100%);
    color: #1a1000;
}
.astrowalad_btn_warn:hover {
    box-shadow: 0 0 14px rgba(251,191,36,0.55);
    transform: translateY(-1px);
}
.astrowalad_btn_gray {
    background: linear-gradient(135deg, #2a3a52 0%, #3a4a62 100%);
    color: #ffffff;
}
.astrowalad_btn_gray:hover {
    box-shadow: 0 0 14px rgba(122,139,160,0.35);
    transform: translateY(-1px);
}

/* ─── BOTÓN DESHABILITADO ────────────────────────────────── */
.astrowalad_btn:disabled,
.astrowalad_btn.disabled {
    opacity: 0.45;
    cursor: not-allowed;
    transform: none !important;
    box-shadow: none !important;
    pointer-events: none;
}

/* ─── AVISO TASA NO CONFIGURADA ──────────────────────────── */
.astrowalad_qvapay_blocked {
    background: rgba(255,68,136,0.12);
    border: 1px solid #ff4488;
    border-radius: 8px;
    padding: 12px 14px;
    margin: 8px 0;
    color: #ff4488;
    font-size: 11px;
    line-height: 1.6;
}
.astrowalad_qvapay_blocked strong {
    display: block;
    margin-bottom: 4px;
    font-size: 12px;
}

/* ─── PREVIEW MONTO USD ──────────────────────────────────── */
.astrowalad_qvapay_preview {
    background: rgba(74,255,136,0.1);
    border: 1px solid #4aff88;
    border-radius: 8px;
    padding: 10px 14px;
    margin: 8px 0;
    font-size: 11px;
    color: #4aff88;
    line-height: 1.6;
}
.astrowalad_qvapay_preview strong {
    color: #ffffff;
    font-family: 'Courier New', monospace;
    font-size: 13px;
}

/* ─── RESPONSIVE ─────────────────────────────────────────── */
@media (max-width: 720px) {
    .astrowalad_panel { padding: 14px 16px; }
    .astrowalad_title { font-size: 13px; }
    .astrowalad_banco_value { font-size: 11px; padding: 5px 10px; }
    .astrowalad_card_value { font-size: 12px; }
}
@media (max-width: 480px) {
    .astrowalad_btn { display: block; width: 100%; margin: 4px 0; }
    .astrowalad_banco_row { flex-direction: column; align-items: flex-start; }
    .astrowalad_banco_value { width: 100%; text-align: center; }
}
</style>

<div class="astrowalad_wrap">
    <div class="astrowalad_panel">

        {* ─── HEADER ─────────────────────────────────────── *}
        <div class="astrowalad_header">
            <div>
                <span class="astrowalad_title">📤 Retiro</span>
                <span class="astrowalad_id">#{$retiro.id}</span>
            </div>
            <span class="astrowalad_badge 
                {if $retiro.estado == 'pendiente'}pendiente
                {elseif $retiro.estado == 'aceptada'}info
                {elseif $retiro.estado == 'completada'}ok
                {elseif $retiro.estado == 'rechazada'}error
                {else}gray{/if}">
                {if $retiro.estado == 'pendiente'}⏳ Pendiente
                {elseif $retiro.estado == 'aceptada'}✅ Aceptado
                {elseif $retiro.estado == 'completada'}🏁 Completado
                {elseif $retiro.estado == 'rechazada'}❌ Rechazado
                {elseif $retiro.estado == 'cancelada_user'}🚫 Cancel. user
                {elseif $retiro.estado == 'cancelada_admin'}🚫 Cancel. admin
                {else}⏰ Expirado{/if}
            </span>
        </div>

        {* ─── FEEDBACK ───────────────────────────────────── *}
        {if $feedback_error}
            <div class="astrowalad_alerta astrowalad_alerta_error">
                <strong>❌ Error</strong>
                {$feedback_error|escape:'html'}
            </div>
        {/if}

        {* ─── ALERTAS SEGÚN ESTADO ───────────────────────── *}
        {if $retiro.estado == 'pendiente'}
            <div class="astrowalad_alerta astrowalad_alerta_warn">
                <strong>⏳ Retiro pendiente de aceptación</strong>
                El usuario ya tiene bloqueados <strong>{$retiro.nxt20_retirados} UNTX-20</strong>.
                Al aceptar, se te mostrarán sus datos bancarios para hacer la transferencia.
            </div>
        {elseif $retiro.estado == 'aceptada'}
            <div class="astrowalad_alerta astrowalad_alerta_info">
                <strong>✅ Retiro aceptado — pendiente de pago</strong>
                Método de pago seleccionado: <b style="text-transform:uppercase;">{$retiro.metodo_pago}</b><br>
                {if $retiro.metodo_pago == 'QVAPAY'}
                    Presioná <strong>PAGAR CON QVAPAY</strong> para enviar la plata automáticamente.
                {else}
                    Transferí <strong>{$retiro.neto} UNTX-20</strong> al usuario y luego presioná <strong>CONFIRMAR RETIRO</strong>.
                {/if}
            </div>
        {elseif $retiro.estado == 'completada'}
            <div class="astrowalad_alerta astrowalad_alerta_ok">
                <strong>🏁 Retiro completado</strong>
                Se quemaron <strong>{$retiro.nxt20_retirados} UNTX-20</strong>, 
                se bajaron <strong>{$retiro.bruto} UNTX-20</strong> del banco, 
                y se descontaron <strong>{$retiro.neto} UNTX-20</strong>.
            </div>
        {elseif $retiro.estado == 'rechazada'}
            <div class="astrowalad_alerta astrowalad_alerta_error">
                <strong>❌ Retiro rechazado</strong>
                {$retiro.motivo|escape:'html'|default:'Sin motivo especificado.'}
            </div>
        {elseif $retiro.estado == 'cancelada_user' || $retiro.estado == 'cancelada_admin'}
            <div class="astrowalad_alerta astrowalad_alerta_warn">
                <strong>🚫 Retiro cancelado</strong>
                {$retiro.motivo|escape:'html'|default:'Sin motivo especificado.'}
            </div>
        {/if}

        {* ─── GRID DE DATOS ──────────────────────────────── *}
        <div class="astrowalad_grid">
            <div class="astrowalad_card">
                <div class="astrowalad_card_label">👤 Usuario</div>
                <div class="astrowalad_card_value" style="font-size:12px;">{$retiro.username|escape:'html'}</div>
            </div>
            <div class="astrowalad_card">
                <div class="astrowalad_card_label">💲 UNTX-20 retirados</div>
                <div class="astrowalad_card_value nxt">{$retiro.nxt20_retirados}</div>
            </div>
            <div class="astrowalad_card">
                <div class="astrowalad_card_label">Bruto</div>
                <div class="astrowalad_card_value">{$retiro.bruto} UNTX-20</div>
            </div>
            <div class="astrowalad_card">
                <div class="astrowalad_card_label">Neto a pagar</div>
                <div class="astrowalad_card_value ok">{$retiro.neto} UNTX-20</div>
            </div>
            <div class="astrowalad_card">
                <div class="astrowalad_card_label">Comisión proyecto</div>
                <div class="astrowalad_card_value">{$retiro.comision_proyecto} UNTX-20</div>
            </div>
            {if $retiro.referidor_id > 0}
            <div class="astrowalad_card">
                <div class="astrowalad_card_label">🔗 Comisión referidor</div>
                <div class="astrowalad_card_value">{$retiro.comision_referidor} UNTX-20</div>
            </div>
            {/if}
            <div class="astrowalad_card">
                <div class="astrowalad_card_label">Método de Pago</div>
                <div class="astrowalad_card_value {if $retiro.metodo_pago == 'QVAPAY'}ok{/if}" style="font-size:12px; text-transform:uppercase;">
                    {$retiro.metodo_pago}
                </div>
            </div>
            <div class="astrowalad_card">
                <div class="astrowalad_card_label">Solicitado</div>
                <div class="astrowalad_card_value" style="font-size:11px;">{$retiro.fecha}</div>
            </div>
        </div>

        {* ─── DATOS BANCARIOS DEL USER ───────────────────── *}
        <div class="astrowalad_banco">
            <h3 class="astrowalad_banco_title">🏦 Datos bancarios del usuario</h3>

            {if $retiro.user_tiene_datos}
                <div class="astrowalad_banco_row">
                    <span class="astrowalad_banco_label">💳 Tarjeta magnética</span>
                    <span class="astrowalad_banco_value">{$retiro.user_tarjeta|escape:'html'}</span>
                </div>
                <div class="astrowalad_banco_row">
                    <span class="astrowalad_banco_label">📱 Teléfono</span>
                    <span class="astrowalad_banco_value">{$retiro.user_telefono|escape:'html'}</span>
                </div>
                <div class="astrowalad_banco_row">
                    <span class="astrowalad_banco_label">👤 Titular</span>
                    <span class="astrowalad_banco_value">{$retiro.user_titular|escape:'html'|default:'—'}</span>
                </div>
                <div class="astrowalad_banco_row">
                    <span class="astrowalad_banco_label">🏛️ Banco</span>
                    <span class="astrowalad_banco_value">{$retiro.user_banco|escape:'html'|default:'—'}</span>
                </div>
                <div class="astrowalad_banco_row">
                    <span class="astrowalad_banco_label">💰 Monto a transferir</span>
                    <span class="astrowalad_banco_value highlight">{$retiro.neto} UNTX-20</span>
                </div>
            {else}
                <div class="astrowalad_alerta astrowalad_alerta_warn" style="margin:0;">
                    <strong>⚠️ Sin datos bancarios</strong>
                    El usuario <strong>{$retiro.username|escape:'html'}</strong> no tiene
                    datos bancarios cargados. Contactalo o pedile que los cargue antes
                    de continuar.
                </div>
            {/if}
        </div>

        {* ─── HISTORIAL / TIMELINE ───────────────────────── *}
        <div class="astrowalad_section">
            <h3 class="astrowalad_section_title">📜 Historial del retiro</h3>
            <ul class="astrowalad_timeline">
                <li class="astrowalad_timeline_item">
                    <span class="astrowalad_timeline_accion">Creado</span>
                    <span class="astrowalad_timeline_detalle">
                        Solicitud creada por <strong>{$retiro.username|escape:'html'}</strong> 
                        por <strong>{$retiro.nxt20_retirados} UNTX-20</strong>.
                    </span>
                    <span class="astrowalad_timeline_meta">{$retiro.fecha}</span>
                </li>

                {if $retiro.fecha_aceptacion}
                <li class="astrowalad_timeline_item">
                    <span class="astrowalad_timeline_accion">Aceptado</span>
                    <span class="astrowalad_timeline_detalle">
                        El admin aceptó el retiro. Se enviaron los datos bancarios al usuario.
                    </span>
                    <span class="astrowalad_timeline_meta">{$retiro.fecha_aceptacion}</span>
                </li>
                {/if}

                {if $retiro.fecha_procesado}
                <li class="astrowalad_timeline_item">
                    <span class="astrowalad_timeline_accion">Procesado</span>
                    <span class="astrowalad_timeline_detalle">
                        Retiro confirmado. UNTX-20 quemados, UNTX-20 bajados del banco,
                        y UNTX-20 descontados.
                    </span>
                    <span class="astrowalad_timeline_meta">{$retiro.fecha_procesado}</span>
                </li>
                {/if}

                {if $retiro.motivo && ($retiro.estado == 'rechazada' || $retiro.estado == 'cancelada_user' || $retiro.estado == 'cancelada_admin')}
                <li class="astrowalad_timeline_item">
                    <span class="astrowalad_timeline_accion" style="color:#ff4488;">Motivo</span>
                    <span class="astrowalad_timeline_detalle">{$retiro.motivo|escape:'html'}</span>
                </li>
                {/if}
            </ul>
        </div>

        {* ─── ACCIONES ───────────────────────────────────── *}
        <div class="astrowalad_actions">

            <a href="game.php?page=walletadmin&mode=withdrawals&estado={$retiro.estado}" 
               class="astrowalad_btn astrowalad_btn_gray">
                ← Volver al listado
            </a>

            {if $retiro.estado == 'pendiente'}
                <form method="POST" 
                      action="game.php?page=walletadmin&mode=aceptarRetiro" 
                      style="display:inline-block; margin:0;"
                      onsubmit="return deshabilitarBoton(this, 'Aceptando...');">
                    <input type="hidden" name="csrf_token" value="{$csrf_token|default:''}">
                    <input type="hidden" name="id" value="{$retiro.id}">
                    <button type="submit" 
                            class="astrowalad_btn astrowalad_btn_ok"
                            onclick="return window.confirm('¿ACEPTAR este retiro?\n\nSe mostrarán los datos bancarios para transferir {$retiro.neto} UNTX-20.');">
                        ✅ ACEPTAR RETIRO
                    </button>
                </form>

                <form method="POST" 
                      action="game.php?page=walletadmin&mode=rechazarRetiro" 
                      style="display:inline-block; margin:0;"
                      onsubmit="return validarMotivo(this);">
                    <input type="hidden" name="csrf_token" value="{$csrf_token|default:''}">
                    <input type="hidden" name="id" value="{$retiro.id}">
                    <input type="hidden" name="motivo" value="">
                    <button type="submit" 
                            class="astrowalad_btn astrowalad_btn_danger"
                            onclick="var m = prompt('Motivo del rechazo (obligatorio, mín. 3 caracteres):'); if (!m || m.length < 3) { return false; } this.form.motivo.value = m;">
                        ❌ RECHAZAR RETIRO
                    </button>
                </form>
            {elseif $retiro.estado == 'aceptada'}
                
                {if $retiro.metodo_pago == 'QVAPAY'}

                    {* ═══════════════════════════════════════════════
                       🆕 FASE 3: BOTÓN QVAPAY CON TASA REAL + CSRF
                       ═══════════════════════════════════════════════ *}

                    {if !isset($tasa_cup_por_usd) || $tasa_cup_por_usd <= 1}

                        {* TASA NO CONFIGURADA → BOTÓN BLOQUEADO *}
                        <div class="astrowalad_qvapay_blocked">
                            <strong>🚨 Tasa de conversión NO configurada</strong>
                            El sistema no puede convertir <strong>{$retiro.neto} UNTX-20</strong> a USD reales.
                            Un superadmin debe ir a <em>Panel Wallet → QvaPay</em> y configurar
                            la tasa real (ej: 820 CUP = 1 USD) antes de pagar este retiro.
                            <br><br>
                            <strong>⚠️ SIN ESTO, EL PAGO SE ENVIARÍA COMO SI FUERAN USD, PERDIENDO ~$800 USD POR RETIRO.</strong>
                        </div>

                    {else}

                        {* TASA CONFIGURADA → MOSTRAR PREVIEW + BOTÓN HABILITADO *}
                        <div class="astrowalad_qvapay_preview">
                            <strong>💱 Conversión que se aplicará:</strong><br>
                            {$retiro.neto} UNTX-20 ÷ {$tasa_cup_por_usd} (tasa) = 
                            <strong id="qvapay_monto_usd_preview">calculando...</strong> USD
                            <br>
                            <span style="font-size:10px; color:#7a8ba0;">
                                Se enviará este monto exacto a la cuenta QvaPay del usuario.
                            </span>
                        </div>

                        <form method="POST" 
                              action="game.php?page=walletadmin&mode=pagarRetiroQvaPay" 
                              style="display:inline-block; margin:0;"
                              id="form_pagar_qvapay"
                              onsubmit="return confirmarPagoQvaPay(this, {$retiro.neto}, {$tasa_cup_por_usd}, '{$retiro.username|escape:'javascript'}');">
                            <input type="hidden" name="csrf_token" value="{$csrf_token|default:''}">
                            <input type="hidden" name="id" value="{$retiro.id}">
                            <button type="submit" 
                                    class="astrowalad_btn" 
                                    id="btn_pagar_qvapay"
                                    style="background: #4aff88; color: #000; text-shadow: none; font-weight: 900;">
                                💸 PAGAR CON QVAPAY (Automático)
                            </button>
                        </form>

                    {/if}

                {else}
                    {* BOTÓN MANUAL ORIGINAL (CUP) *}
                    <form method="POST" 
                          action="game.php?page=walletadmin&mode=confirmarRetiro" 
                          style="display:inline-block; margin:0;"
                          onsubmit="return deshabilitarBoton(this, 'Confirmando...');">
                        <input type="hidden" name="csrf_token" value="{$csrf_token|default:''}">
                        <input type="hidden" name="id" value="{$retiro.id}">
                        <button type="submit" 
                                class="astrowalad_btn astrowalad_btn_ok"
                                onclick="return window.confirm('¿CONFIRMAR este retiro manualmente?\n\n🔒 Se quemarán {$retiro.nxt20_retirados} UNTX-20.\n💰 Se descontarán {$retiro.neto} UNTX-20.\n\nIRREVERSIBLE.');">
                            🏁 CONFIRMAR RETIRO (Manual)
                        </button>
                    </form>
                {/if}

                <form method="POST" 
                      action="game.php?page=walletadmin&mode=cancelarRetiroAdmin" 
                      style="display:inline-block; margin:0;"
                      onsubmit="return validarMotivo(this);">
                    <input type="hidden" name="csrf_token" value="{$csrf_token|default:''}">
                    <input type="hidden" name="id" value="{$retiro.id}">
                    <input type="hidden" name="motivo" value="">
                    <button type="submit" 
                            class="astrowalad_btn astrowalad_btn_warn"
                            onclick="var m = prompt('Motivo de la cancelación (obligatorio, mín. 3 caracteres):'); if (!m || m.length < 3) { return false; } this.form.motivo.value = m;">
                        🚫 CANCELAR RETIRO
                    </button>
                </form>
            {/if}

        </div>

    </div>
</div>

<script>
/* ═══════════════════════════════════════════════════════════
   FASE 3 — Funciones de seguridad
   ═══════════════════════════════════════════════════════════ */

// 1. Validar que el motivo tenga al menos 3 caracteres
function validarMotivo(form) {
    if (!form.motivo.value || form.motivo.value.length < 3) {
        alert('El motivo debe tener al menos 3 caracteres.');
        return false;
    }
    return true;
}

// 2. Deshabilitar botón después del submit (anti doble clic)
function deshabilitarBoton(form, textoBoton) {
    var btn = form.querySelector('button[type="submit"]');
    if (btn) {
        btn.disabled = true;
        btn.classList.add('disabled');
        if (textoBoton) btn.innerHTML = textoBoton;
    }
    return true;
}

// 3. Calcular monto USD y confirmar pago QvaPay
function confirmarPagoQvaPay(form, montoCup, tasa, username) {
    // Calcular monto USD
    var montoUsd = (montoCup / tasa).toFixed(2);

    // Validar que el monto sea válido
    if (montoUsd <= 0 || !isFinite(montoUsd)) {
        alert('❌ Error: el monto calculado en USD no es válido.');
        return false;
    }

    // Confirmación explícita con el monto USD real
    var mensaje = '⚠️ ¿PAGAR AUTOMÁTICAMENTE VÍA QVAPAY?\n\n' +
                  '👤 Usuario: ' + username + '\n' +
                  '💰 Monto en UNTX-20: ' + montoCup + ' UNTX-20\n' +
                  '💱 Tasa aplicada: ' + tasa + ' CUP = 1 USD\n' +
                  '💵 MONTO A ENVIAR: $' + montoUsd + ' USD REALES\n\n' +
                  '────────────────────────\n' +
                  'Esta operación enviará $' + montoUsd + ' USD desde tu cuenta QvaPay.\n' +
                  'Se descontarán los UNTX-20 correspondientes.\n\n' +
                  '¿Confirmás el pago?';

    if (!window.confirm(mensaje)) {
        return false;
    }

    // Segundo factor: pedir que escriba CONFIRMAR
    var verificacion = prompt(
        'Para confirmar el pago de $' + montoUsd + ' USD, escribí la palabra CONFIRMAR en MAYÚSCULAS:'
    );
    if (verificacion !== 'CONFIRMAR') {
        alert('❌ Pago cancelado (verificación incorrecta).');
        return false;
    }

    // Deshabilitar botón (anti doble clic)
    deshabilitarBoton(form, '💸 Enviando...');
    return true;
}

// 4. Calcular y mostrar el preview del monto USD al cargar la página
document.addEventListener('DOMContentLoaded', function() {
    var preview = document.getElementById('qvapay_monto_usd_preview');
    if (preview && typeof window.qvapayTasa !== 'undefined') {
        // Si el controlador pasó la tasa como variable global JS
        var montoCup = parseFloat(preview.dataset.monto || 0);
        var tasa = parseFloat(window.qvapayTasa || 0);
        if (tasa > 0) {
            preview.textContent = '$' + (montoCup / tasa).toFixed(2);
        }
    }
});
</script>

{/block}