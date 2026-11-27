{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.wallet.setbankdata.tpl === *}
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
   CSS AISLADO — Datos bancarios (admin + user)
   AstroIO v6.0 — Glassmorphism + Acento Cyan
   Prefijo: .astrowalbnk_
   ═══════════════════════════════════════════════════════════ */

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

.astrowalbnk_wrap {
    text-align: center;
    margin: 20px 0;
}

.astrowalbnk_panel {
    display: inline-block;
    width: 100%;
    max-width: 900px;
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 16px 20px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    text-align: left;
    font-size: 11px;
    color: var(--text-main);
    box-sizing: border-box;
}

.astrowalbnk_header {
    border-bottom: 1px solid rgba(0, 224, 255, 0.25);
    padding-bottom: 10px;
    margin-bottom: 14px;
    text-align: center;
}

.astrowalbnk_title {
    font-size: 14px;
    font-weight: bold;
    color: var(--accent-cyan);
    text-transform: uppercase;
    letter-spacing: 1px;
    margin: 0;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.35);
}

.astrowalbnk_subtitle {
    font-size: 10.5px;
    color: var(--text-muted);
    margin-top: 4px;
    font-style: italic;
}

.astrowalbnk_alerta {
    padding: 10px 14px;
    border-radius: 8px;
    margin-bottom: 14px;
    font-size: 11px;
    line-height: 1.5;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}

.astrowalbnk_alerta_obligatorio {
    background: rgba(251, 191, 36, 0.15);
    border-left: 3px solid var(--accent-gold);
    color: var(--accent-gold);
}

.astrowalbnk_alerta_edicion {
    background: rgba(0, 224, 255, 0.1);
    border-left: 3px solid var(--accent-cyan);
    color: var(--accent-cyan);
}

.astrowalbnk_alerta_pendiente {
    background: rgba(139, 92, 246, 0.15);
    border-left: 3px solid var(--accent-purple);
    color: #c4b5fd;
}

.astrowalbnk_alerta_error {
    background: rgba(239, 68, 68, 0.15);
    border-left: 3px solid var(--accent-red);
    color: var(--accent-red);
}

.astrowalbnk_alerta_ok {
    background: rgba(74, 255, 136, 0.15);
    border-left: 3px solid var(--accent-green);
    color: var(--accent-green);
}

.astrowalbnk_alerta strong {
    display: block;
    margin-bottom: 4px;
}

.astrowalbnk_form {
    display: block;
    width: 100%;
}

.astrowalbnk_field {
    margin-bottom: 14px;
}

.astrowalbnk_label {
    display: block;
    font-size: 11px;
    font-weight: bold;
    color: var(--accent-cyan);
    margin-bottom: 6px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.astrowalbnk_label .req {
    color: var(--accent-red);
    font-size: 13px;
    margin-left: 4px;
}

.astrowalbnk_label .opt {
    color: var(--text-muted);
    font-size: 9.5px;
    text-transform: none;
    font-weight: normal;
    font-style: italic;
    margin-left: 6px;
}

.astrowalbnk_input {
    width: 100%;
    padding: 9px 12px;
    background: rgba(0, 0, 0, 0.5);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    color: var(--text-main);
    font-size: 12px;
    font-family: 'Courier New', monospace;
    box-sizing: border-box;
    transition: 0.25s ease;
}

.astrowalbnk_input:focus {
    outline: none;
    border-color: var(--accent-cyan);
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.35);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}

.astrowalbnk_input::placeholder {
    color: #4a5a72;
    font-style: italic;
}

.astrowalbnk_help {
    font-size: 10px;
    color: var(--text-muted);
    margin-top: 4px;
    font-style: italic;
    line-height: 1.4;
}

.astrowalbnk_divider {
    height: 1px;
    background: linear-gradient(90deg, transparent, rgba(0, 224, 255, 0.3), transparent);
    margin: 16px 0;
}

.astrowalbnk_actions {
    text-align: center;
    margin-top: 18px;
    padding-top: 14px;
    border-top: 1px solid rgba(0, 224, 255, 0.15);
}

.astrowalbnk_btn {
    display: inline-block;
    padding: 11px 32px;
    background: linear-gradient(135deg, #0066cc 0%, #0099ff 100%);
    border: 1px solid var(--accent-cyan);
    border-radius: 8px;
    color: #ffffff;
    font-size: 12px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 1px;
    cursor: pointer;
    transition: 0.25s ease;
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.4);
    text-decoration: none;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.astrowalbnk_btn:hover {
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.55);
    transform: translateY(-2px);
}

.astrowalbnk_btn:active {
    transform: translateY(0);
}

.astrowalbnk_btn_volver {
    background: rgba(30, 41, 59, 0.85);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    color: var(--text-main);
    margin-left: 8px;
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.4);
}

.astrowalbnk_btn_volver:hover {
    box-shadow: 0 0 14px rgba(148, 163, 184, 0.35);
    transform: translateY(-2px);
}

@media (max-width: 720px) {
    .astrowalbnk_panel { padding: 12px 14px; }
    .astrowalbnk_title { font-size: 12px; }
    .astrowalbnk_btn { padding: 10px 22px; font-size: 11px; }
}

@media (max-width: 480px) {
    .astrowalbnk_btn { display: block; width: 100%; margin: 0 0 8px 0; }
    .astrowalbnk_btn_volver { margin-left: 0; }
}
</style>

{* ═══════════════════════════════════════════════════════════
   LÓGICA INLINE — sin {assign} condicionales
   Reglas:
     - es_admin:   isset($es_edicion)
     - user_con_datos: !es_admin AND $bank_data.tarjeta_magnetica != ''
     - user_sin_datos: !es_admin AND (NO bank_data o tarjeta vacía)
     - tiene_solicitud: !es_admin AND $solicitud_cambio
   ═══════════════════════════════════════════════════════════ *}

<div class="astrowalbnk_wrap">
    <div class="astrowalbnk_panel">

        {* ─── HEADER ─────────────────────────────────────── *}
        <div class="astrowalbnk_header">
            {if isset($es_edicion)}
                {* MODO ADMIN *}
                {if $es_edicion}
                    <h2 class="astrowalbnk_title">🏦 Mis Datos Bancarios</h2>
                    <div class="astrowalbnk_subtitle">Actualizá tus datos cuando quieras</div>
                {else}
                    <h2 class="astrowalbnk_title">⚠️ Datos Bancarios Requeridos</h2>
                    <div class="astrowalbnk_subtitle">Completalos para poder operar el banco</div>
                {/if}
            {else}
                {* MODO USER *}
                {if isset($bank_data) && isset($bank_data.tarjeta_magnetica) && $bank_data.tarjeta_magnetica != ''}
                    <h2 class="astrowalbnk_title">🏦 Tus Datos Bancarios</h2>
                    <div class="astrowalbnk_subtitle">Si los cambiás, se enviará una solicitud al admin</div>
                {else}
                    <h2 class="astrowalbnk_title">⚠️ Datos Bancarios Requeridos</h2>
                    <div class="astrowalbnk_subtitle">Completalos para poder invertir y retirar</div>
                {/if}
            {/if}
        </div>

        {* ─── ALERTA OBLIGATORIO (primera vez) ────────────── *}
        {if isset($es_edicion)}
            {* ADMIN *}
            {if !$es_edicion}
                <div class="astrowalbnk_alerta astrowalbnk_alerta_obligatorio">
                    <strong>🚨 Acción obligatoria</strong>
                    Antes de poder tomar solicitudes de inversión, necesitás registrar tu tarjeta
                    magnética y tu teléfono. Estos datos se enviarán automáticamente a los usuarios
                    cuando aceptes una solicitud.
                </div>
            {/if}
        {else}
            {* USER *}
            {if !isset($bank_data) || !isset($bank_data.tarjeta_magnetica) || $bank_data.tarjeta_magnetica == ''}
                {if !isset($solicitud_cambio) || !$solicitud_cambio}
                    <div class="astrowalbnk_alerta astrowalbnk_alerta_obligatorio">
                        <strong>🚨 Acción obligatoria</strong>
                        Antes de poder invertir o retirar NXT-20, necesitás registrar tu tarjeta
                        magnética y tu teléfono. El admin usará estos datos para hacerte la
                        transferencia cuando retires.
                    </div>
                {/if}
            {/if}
        {/if}

        {* ─── ALERTA EDICIÓN ──────────────────────────────── *}
        {if isset($es_edicion)}
            {* ADMIN *}
            {if $es_edicion}
                <div class="astrowalbnk_alerta astrowalbnk_alerta_edicion">
                    <strong>💡 Datos ya cargados</strong>
                    Podés modificar tus datos en cualquier momento. Los cambios se aplicarán
                    a las <strong>próximas</strong> solicitudes que tomes (las actuales mantienen
                    los datos anteriores por seguridad).
                </div>
            {/if}
        {else}
            {* USER *}
            {if isset($bank_data) && isset($bank_data.tarjeta_magnetica) && $bank_data.tarjeta_magnetica != ''}
                {if !isset($solicitud_cambio) || !$solicitud_cambio}
                    <div class="astrowalbnk_alerta astrowalbnk_alerta_edicion">
                        <strong>💡 Datos ya cargados</strong>
                        Podés modificar tus datos. Al guardar, se enviará una <strong>solicitud
                        al admin</strong> para que la apruebe. Hasta entonces, tus datos actuales
                        siguen vigentes.
                    </div>
                {/if}
            {/if}
        {/if}

        {* ─── ALERTA SOLICITUD PENDIENTE (solo user) ──────── *}
        {if !isset($es_edicion)}
            {if isset($solicitud_cambio) && $solicitud_cambio}
                <div class="astrowalbnk_alerta astrowalbnk_alerta_pendiente">
                    <strong>⏳ Tenés una solicitud de cambio pendiente</strong>
                    El admin debe aprobarla o rechazarla antes de que puedas solicitar otro cambio.
                    Mientras tanto, tus datos actuales siguen vigentes.
                </div>
            {/if}
        {/if}

        {* ─── FEEDBACK ────────────────────────────────────── *}
        {if isset($feedback_error) && $feedback_error}
            <div class="astrowalbnk_alerta astrowalbnk_alerta_error">
                <strong>❌ Error</strong>
                {$feedback_error|escape:'html'}
            </div>
        {/if}

        {if isset($feedback_ok) && $feedback_ok == 'datos_guardados'}
            <div class="astrowalbnk_alerta astrowalbnk_alerta_ok">
                <strong>✅ Datos guardados correctamente</strong>
                {if isset($es_edicion)}
                    Ya podés operar el banco con normalidad.
                {else}
                    Ya podés invertir y retirar con normalidad.
                {/if}
            </div>
        {/if}

        {if isset($feedback_ok) && $feedback_ok == 'cambio_solicitado'}
            <div class="astrowalbnk_alerta astrowalbnk_alerta_ok">
                <strong>✅ Solicitud de cambio enviada</strong>
                El admin la revisará pronto. Tus datos actuales siguen vigentes hasta que sea aprobada.
            </div>
        {/if}

        {* ─── FORMULARIO (solo si NO tiene solicitud pendiente) ─── *}
        {if isset($es_edicion) || !isset($solicitud_cambio) || !$solicitud_cambio}
        <form method="post" action="{$action_url}" class="astrowalbnk_form">

            {* ─── Tarjeta magnética ───────────────────────── *}
            <div class="astrowalbnk_field">
                <label class="astrowalbnk_label">
                    💳 Tarjeta magnética
                    <span class="req">*</span>
                </label>
                <input 
                    type="text" 
                    name="{if isset($es_edicion)}tarjeta{else}tarjeta_magnetica{/if}" 
                    class="astrowalbnk_input" 
                    value="{if isset($es_edicion)}{if isset($tarjeta)}{$tarjeta|escape:'html'}{/if}{else}{if isset($bank_data) && isset($bank_data.tarjeta_magnetica)}{$bank_data.tarjeta_magnetica|escape:'html'}{/if}{/if}" 
                    placeholder="Ejemplo: 1234-5678-9012-3456"
                    maxlength="50"
                    required
                    autocomplete="off"
                />
                <div class="astrowalbnk_help">
                    {if isset($es_edicion)}
                        Número completo de la tarjeta donde los usuarios harán las transferencias.
                        Mínimo 10 caracteres.
                    {else}
                        Número completo de tu tarjeta donde recibirás las transferencias.
                        Mínimo 16 caracteres.
                    {/if}
                </div>
            </div>

            {* ─── Teléfono ────────────────────────────────── *}
            <div class="astrowalbnk_field">
                <label class="astrowalbnk_label">
                    📱 Teléfono
                    <span class="req">*</span>
                </label>
                <input 
                    type="text" 
                    name="telefono" 
                    class="astrowalbnk_input" 
                    value="{if isset($es_edicion)}{if isset($telefono)}{$telefono|escape:'html'}{/if}{else}{if isset($bank_data) && isset($bank_data.telefono)}{$bank_data.telefono|escape:'html'}{/if}{/if}" 
                    placeholder="Ejemplo: +54 9 11 1234-5678"
                    maxlength="30"
                    required
                    autocomplete="off"
                />
                <div class="astrowalbnk_help">
                    {if isset($es_edicion)}
                        Teléfono de contacto que se mostrará al usuario que invierte.
                        Mínimo 6 caracteres.
                    {else}
                        Teléfono de contacto para que el admin coordine la transferencia.
                        Mínimo 8 caracteres.
                    {/if}
                </div>
            </div>

            <div class="astrowalbnk_divider"></div>

            {* ─── Titular (opcional) ──────────────────────── *}
            <div class="astrowalbnk_field">
                <label class="astrowalbnk_label">
                    👤 Titular de la tarjeta
                    <span class="opt">(opcional)</span>
                </label>
                <input 
                    type="text" 
                    name="titular" 
                    class="astrowalbnk_input" 
                    value="{if isset($es_edicion)}{if isset($titular)}{$titular|escape:'html'}{/if}{else}{if isset($bank_data) && isset($bank_data.titular)}{$bank_data.titular|escape:'html'}{/if}{/if}" 
                    placeholder="Nombre completo del titular"
                    maxlength="100"
                    autocomplete="off"
                />
                <div class="astrowalbnk_help">
                    Nombre completo del titular de la tarjeta.
                </div>
            </div>

            {* ─── Banco (opcional) ────────────────────────── *}
            <div class="astrowalbnk_field">
                <label class="astrowalbnk_label">
                    🏛️ Banco
                    <span class="opt">(opcional)</span>
                </label>
                <input 
                    type="text" 
                    name="banco" 
                    class="astrowalbnk_input" 
                    value="{if isset($es_edicion)}{if isset($banco)}{$banco|escape:'html'}{/if}{else}{if isset($bank_data) && isset($bank_data.banco)}{$bank_data.banco|escape:'html'}{/if}{/if}" 
                    placeholder="Ejemplo: Banco Nacional de Cuba"
                    maxlength="100"
                    autocomplete="off"
                />
                <div class="astrowalbnk_help">
                    Nombre del banco de la tarjeta.
                </div>
            </div>

            {* ─── Botones ─────────────────────────────────── *}
            <div class="astrowalbnk_actions">
                <button type="submit" class="astrowalbnk_btn">
                    {if isset($es_edicion)}
                        {if $es_edicion}💾 Actualizar datos{else}✅ Guardar datos{/if}
                    {else}
                        {if isset($bank_data) && isset($bank_data.tarjeta_magnetica) && $bank_data.tarjeta_magnetica != ''}
                            📤 Enviar solicitud de cambio
                        {else}
                            ✅ Guardar datos
                        {/if}
                    {/if}
                </button>

                {if isset($es_edicion)}
                    {if $es_edicion}
                        <a href="game.php?page=walletadmin" class="astrowalbnk_btn astrowalbnk_btn_volver">
                            ← Volver al panel
                        </a>
                    {/if}
                {else}
                    {if isset($bank_data) && isset($bank_data.tarjeta_magnetica) && $bank_data.tarjeta_magnetica != ''}
                        <a href="game.php?page=wallet" class="astrowalbnk_btn astrowalbnk_btn_volver">
                            ← Volver al wallet
                        </a>
                    {/if}
                {/if}
            </div>

        </form>
        {else}
            {* USER con solicitud pendiente: solo botón volver *}
            <div class="astrowalbnk_actions">
                <a href="game.php?page=wallet" class="astrowalbnk_btn astrowalbnk_btn_volver">
                    ← Volver al wallet
                </a>
            </div>
        {/if}

    </div>
</div>

{/block}