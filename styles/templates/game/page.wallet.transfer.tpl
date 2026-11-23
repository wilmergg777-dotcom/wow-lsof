{block name="title" prepend}Transferir CUP{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.wallet.transfer.tpl === *}
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
   TRANSFERIR CUP — Formulario Admin → Admin
   AstroIO v3.0 — Glassmorphism + Acento Dorado
   Prefijo: .wallet-transf_
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

.wallet-transf_wrapper {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    color: var(--text-main);
    padding: 16px 20px;
    border-radius: 12px;
    border: 1px solid var(--border-color);
    max-width: 720px;
    margin: 0 auto;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    box-sizing: border-box;
}

.wallet-transf_title {
    color: var(--accent-cyan);
    font-size: 16px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 1px;
    margin-bottom: 14px;
    padding-bottom: 10px;
    border-bottom: 1px solid rgba(0, 224, 255, 0.25);
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    flex-wrap: wrap;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.35);
}
.wallet-transf_title .admin-info {
    font-size: 11px;
    color: var(--text-muted);
    font-weight: normal;
    text-transform: none;
    letter-spacing: 0;
    text-shadow: none;
}

/* ─── BOTÓN VOLVER ───────────────────────────────────────── */
.wallet-transf_back {
    display: inline-block;
    color: var(--text-muted);
    font-size: 11px;
    text-decoration: none;
    margin-bottom: 14px;
    transition: 0.25s ease;
    padding: 4px 10px;
    border-radius: 5px;
    border: 1px solid var(--border-color);
    background: rgba(0, 0, 0, 0.2);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.wallet-transf_back:hover {
    color: var(--accent-cyan);
    border-color: rgba(0, 224, 255, 0.5);
    background: rgba(0, 224, 255, 0.08);
    transform: translateY(-1px);
}

/* ─── FEEDBACK ───────────────────────────────────────────── */
.wallet-transf_msg_error {
    background: rgba(239, 68, 68, 0.15);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border-left: 3px solid var(--accent-red);
    color: var(--accent-red);
    padding: 10px 14px;
    border-radius: 6px;
    margin-bottom: 14px;
    font-size: 11px;
}

/* ─── CAJA DE SALDO ──────────────────────────────────────── */
.wallet-transf_balance {
    background: linear-gradient(135deg, rgba(74, 255, 136, 0.12) 0%, rgba(0, 224, 255, 0.06) 100%);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(74, 255, 136, 0.35);
    border-radius: 10px;
    padding: 14px 18px;
    margin-bottom: 16px;
    text-align: center;
}
.wallet-transf_balance_label {
    font-size: 10.5px;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 4px;
}
.wallet-transf_balance_value {
    font-size: 26px;
    font-weight: bold;
    color: var(--accent-green);
    font-family: 'Courier New', monospace;
    letter-spacing: 1px;
    text-shadow: 0 0 12px rgba(74, 255, 136, 0.4);
}
.wallet-transf_balance_value small {
    font-size: 11px;
    color: var(--text-muted);
    font-weight: normal;
    margin-left: 6px;
    letter-spacing: 0;
    text-shadow: none;
}

/* ─── INFO BOX ───────────────────────────────────────────── */
.wallet-transf_info {
    background: rgba(0, 224, 255, 0.05);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 224, 255, 0.2);
    border-radius: 8px;
    padding: 10px 14px;
    margin-bottom: 16px;
    font-size: 11px;
    line-height: 1.7;
}
.wallet-transf_info strong {
    color: var(--accent-cyan);
    display: block;
    margin-bottom: 4px;
}
.wallet-transf_info ol {
    margin: 4px 0 0 0;
    padding-left: 20px;
    color: var(--text-muted);
}
.wallet-transf_info ol li {
    margin-bottom: 3px;
}

/* ─── FORM BOX ───────────────────────────────────────────── */
.wallet-transf_form_box {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 10px;
    padding: 18px 20px;
}

.wallet-transf_label {
    color: var(--accent-cyan);
    font-size: 10.5px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 6px;
    display: block;
    font-weight: bold;
}

/* ─── SELECT E INPUT (FIX APLICADO) ──────────────────────── */
.wallet-transf_input_group {
    display: flex;
    align-items: stretch; /* Mantiene la misma altura entre input y select */
    background: rgba(0, 0, 0, 0.4);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    margin-bottom: 16px;
    transition: 0.25s ease;
    min-height: 46px; /* Altura mínima para evitar que se aplaste el texto */
}
.wallet-transf_input_group:focus-within {
    border-color: var(--accent-cyan);
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.35);
}

/* Input normal */
.wallet-transf_input_group input {
    flex: 1;
    background: transparent;
    border: none;
    padding: 0 16px; /* Padding horizontal solamente */
    color: var(--text-main);
    font-size: 15px;
    font-family: 'Courier New', monospace;
    outline: none;
    font-weight: bold;
    letter-spacing: 0.5px;
    min-width: 0;
    box-sizing: border-box;
}

/* 🔥 FIX DEFINITIVO PARA EL SELECT (Fondo sólido y flecha) */
.wallet-transf_input_group select {
    flex: 1;
    padding: 0 40px 0 16px; /* Espacio para la flecha a la derecha */
    background-color: #0f1624 !important; 
    border: none !important;
    color: #ffffff !important; /* Fuerza el texto a blanco */
    font-weight: 700;
    font-size: 13px;
    font-family: inherit;
    cursor: pointer;
    outline: none;
    
    /* Quitar apariencia por defecto del navegador */
    appearance: none;
    -webkit-appearance: none;
    -moz-appearance: none;
    
    /* Poner flecha personalizada */
    background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%2300e0ff'%3e%3cpath d='M7 10l5 5 5-5z'/%3e%3c/svg%3e");
    background-repeat: no-repeat;
    background-position: right 12px center;
    background-size: 20px;
    
    width: 100%;
    line-height: normal; /* Centrado vertical */
    box-sizing: border-box;
}

.wallet-transf_input_group select:focus {
    color: #ffffff !important;
    background-color: #0f1624 !important;
}

.wallet-transf_input_group select option {
    background-color: #0f1624 !important;
    color: #ffffff !important;
    padding: 10px;
}

.wallet-transf_input_group input::placeholder {
    color: #4a5a72;
    font-style: italic;
    letter-spacing: 0;
    font-family: 'Segoe UI', sans-serif;
    font-weight: normal;
}

.wallet-transf_input_suffix {
    padding: 0 18px;
    background: rgba(74, 255, 136, 0.1);
    color: var(--accent-green);
    font-weight: bold;
    display: flex;
    align-items: center;
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    white-space: nowrap;
}

.wallet-transf_help {
    font-size: 10.5px;
    color: var(--text-muted);
    font-style: italic;
    margin-top: -10px;
    margin-bottom: 16px;
    line-height: 1.5;
}
.wallet-transf_help strong {
    color: var(--accent-cyan);
    font-style: normal;
}

/* ─── BOTONES ────────────────────────────────────────────── */
.wallet-transf_btn {
    display: block;
    width: 100%;
    background: linear-gradient(135deg, #228833 0%, #4aff88 100%);
    color: #ffffff;
    border: 1px solid var(--accent-green);
    padding: 14px;
    border-radius: 8px;
    font-size: 12px;
    font-weight: bold;
    cursor: pointer;
    text-align: center;
    text-decoration: none;
    text-transform: uppercase;
    letter-spacing: 1px;
    transition: 0.25s ease;
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.4);
    box-sizing: border-box;
    margin-top: 6px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.wallet-transf_btn:hover {
    box-shadow: 0 0 14px rgba(74, 255, 136, 0.55);
    transform: translateY(-2px);
    color: #ffffff;
}
.wallet-transf_btn:disabled,
.wallet-transf_btn.disabled {
    background: rgba(30, 41, 59, 0.85);
    border: 1px solid var(--border-color);
    cursor: not-allowed;
    opacity: 0.6;
    box-shadow: none;
    transform: none;
}

/* ─── EMPTY STATE ────────────────────────────────────────── */
.wallet-transf_empty {
    text-align: center;
    padding: 30px 20px;
    color: var(--text-muted);
    font-size: 12px;
    font-style: italic;
}
.wallet-transf_empty .icon {
    font-size: 32px;
    margin-bottom: 10px;
    display: block;
}

/* ─── RESPONSIVE ─────────────────────────────────────────── */
@media (max-width: 720px) {
    .wallet-transf_wrapper { padding: 12px 14px; }
    .wallet-transf_title { font-size: 13px; }
    .wallet-transf_balance_value { font-size: 22px; }
    .wallet-transf_input_group input { font-size: 14px; padding: 0 12px; }
    .wallet-transf_input_group select { font-size: 13px; padding: 0 30px 0 12px; }
    .wallet-transf_input_suffix { padding: 0 12px; font-size: 10px; }
}
</style>

<div class="wallet-transf_wrapper">

    {* ─── HEADER ─────────────────────────────────────────── *}
    <div class="wallet-transf_title">
        <span>📤 Transferir CUP</span>
        <span class="admin-info">Admin: <strong>{$username}</strong></span>
    </div>

    {* ─── BOTÓN VOLVER ───────────────────────────────────── *}
    <a href="game.php?page=walletadmin&mode=saldoCup" class="wallet-transf_back">
        ← Volver a Saldo CUP
    </a>

    {* ─── FEEDBACK ERROR ─────────────────────────────────── *}
    {if $feedback_error != ''}
        <div class="wallet-transf_msg_error">
            ❌ {$feedback_error|escape:'html'}
        </div>
    {/if}

    {* ─── CAJA DE SALDO DISPONIBLE ───────────────────────── *}
    <div class="wallet-transf_balance">
        <div class="wallet-transf_balance_label">Tu saldo disponible</div>
        <div class="wallet-transf_balance_value">
            {$cup_disponible} <small>CUP</small>
        </div>
    </div>

    {* ─── INFO DEL FLUJO ─────────────────────────────────── *}
    <div class="wallet-transf_info">
        <strong>ℹ️ ¿Cómo funciona la transferencia?</strong>
        <ol>
            <li>Elegís el admin destino y el monto a transferir.</li>
            <li>El admin destino recibe un <strong>mensaje interno</strong> avisándole.</li>
            <li>Si <strong>acepta</strong>: el saldo se mueve a su cuenta CUP inmediatamente.</li>
            <li>Si <strong>rechaza</strong> o no responde en <strong>24 horas</strong>: el saldo sigue siendo tuyo.</li>
        </ol>
    </div>

    {* ─── AVISO: SOLO DISPONIBLE ─────────────────────────── *}
    <div class="wallet-transf_info" style="border-color:rgba(251,191,36,0.3); background:rgba(251,191,36,0.05);">
        ⚠️ Solo podés transferir tu <strong>disponible</strong> (saldo total menos la marca de Fondo Proyecto).
        El CUP marcado como proyecto no es transferible.
    </div>

    {* ─── FORMULARIO ─────────────────────────────────────── *}
    <div class="wallet-transf_form_box">

        {if $otros_admins|@count > 0 && $cup_disponible_raw > 0}

            <form method="POST" action="{$action_url}" id="wallet_transf_form">

                <label class="wallet-transf_label">
                    👤 Admin destino
                </label>
                <div class="wallet-transf_input_group">
                    <select name="to_admin_id" required>
                        <option value="" style="color: #94a3b8;">— Elegí un admin —</option>
                        {foreach $otros_admins as $adm}
                            <option value="{$adm.admin_id}">{$adm.username|escape:'html'} (Nivel {$adm.authlevel})</option>
                        {/foreach}
                    </select>
                </div>

                <label class="wallet-transf_label">
                    💰 Monto a transferir
                </label>
                <div class="wallet-transf_input_group">
                    <input
                        type="number"
                        name="monto"
                        id="wallet_transf_monto"
                        min="0.01"
                        step="0.01"
                        max="{$cup_disponible_raw}"
                        placeholder="0.00"
                        required
                        autocomplete="off"
                    >
                    <span class="wallet-transf_input_suffix">CUP</span>
                </div>
                <div class="wallet-transf_help">
                    Disponible: <strong>{$cup_disponible} CUP</strong> · 
                    Mínimo: <strong>0.01 CUP</strong>
                </div>

                <button type="submit" class="wallet-transf_btn"
                        onclick="return confirm('¿Confirmar esta transferencia?\n\nSe creará una solicitud que el admin destino debe aceptar.\nSi no responde en 24h, expira automáticamente.');">
                    📤 Enviar transferencia
                </button>

            </form>

        {elseif $otros_admins|@count == 0}

            <div class="wallet-transf_empty">
                <span class="icon">👥</span>
                No hay otros admins registrados en el sistema.<br>
                Necesitás al menos 2 admins para poder transferir.
            </div>
            <a href="game.php?page=walletadmin&mode=saldoCup" class="wallet-transf_btn" style="background:rgba(30,41,59,0.85); border-color:var(--border-color); color:var(--text-main);">
                ← Volver al panel
            </a>

        {else}

            <div class="wallet-transf_empty">
                <span class="icon">💸</span>
                No tenés saldo disponible para transferir.<br>
                Tu saldo está marcado como Fondo Proyecto o es 0.
            </div>
            <a href="game.php?page=walletadmin&mode=saldoCup" class="wallet-transf_btn" style="background:rgba(30,41,59,0.85); border-color:var(--border-color); color:var(--text-main);">
                ← Volver al panel
            </a>

        {/if}

    </div>

</div>

{/block}