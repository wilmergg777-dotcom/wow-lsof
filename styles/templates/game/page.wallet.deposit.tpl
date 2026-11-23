{block name="title" prepend}Invertir{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.wallet.deposit.tpl === *}
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
   DEPOSITAR / INVERTIR — Estilo Web3 (Ronin/Kriptomat)
   Prefijo: .rn-dep
   ═══════════════════════════════════════════════════════════ */

@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

:root {
    --rn-bg:          rgba(15, 23, 42, 0.65);
    --rn-card:        rgba(15, 23, 42, 0.85);
    --rn-card-hover:  rgba(30, 41, 59, 0.9);
    --rn-border:      rgba(255, 255, 255, 0.08);
    --rn-text-main:   #ffffff;
    --rn-text-muted:  #8b8c98;
    --rn-blue:        #2b6bf3;
    --rn-cyan:        #00e0ff;
    --rn-green:       #4aff88;
    --rn-red:         #ef4444;
    --rn-purple:      #8b5cf6;
    --rn-gold:        #fbbf24;
}

.rn-dep-wrapper {
    background: var(--rn-bg);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    color: var(--rn-text-main);
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
    padding: 20px;
    border-radius: 16px;
    max-width: 900px;
    margin: 15px auto 0 auto;
    box-sizing: border-box;
    border: 1px solid var(--rn-border);
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
}

/* Header */
.rn-dep-title {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 10px;
    margin-bottom: 16px;
    padding-bottom: 12px;
    border-bottom: 1px solid var(--rn-border);
}
.rn-dep-title h2 {
    font-size: 18px;
    font-weight: 700;
    margin: 0;
    color: var(--rn-text-main);
    display: flex;
    align-items: center;
    gap: 8px;
}
.rn-dep-title .counter {
    font-size: 12px;
    color: var(--rn-text-muted);
    background: rgba(255, 255, 255, 0.05);
    padding: 4px 10px;
    border-radius: 20px;
    border: 1px solid var(--rn-border);
}
.rn-dep-title .counter strong {
    color: var(--rn-cyan);
}
.rn-dep-title .counter.limit strong {
    color: var(--rn-gold);
}

/* Tabs */
.rn-dep-tabs {
    display: flex;
    gap: 6px;
    margin-bottom: 20px;
    flex-wrap: wrap;
}
.rn-dep-tab {
    background: rgba(255, 255, 255, 0.05);
    border: 1px solid transparent;
    color: var(--rn-text-muted);
    padding: 8px 16px;
    font-size: 12px;
    font-weight: 600;
    border-radius: 20px;
    text-decoration: none;
    transition: 0.2s;
    display: flex;
    align-items: center;
    gap: 6px;
}
.rn-dep-tab:hover { background: rgba(255, 255, 255, 0.1); color: var(--rn-text-main); }
.rn-dep-tab.active { background: var(--rn-blue); color: #fff; border-color: var(--rn-blue); }
.rn-dep-tab-bank { border-color: rgba(139, 92, 246, 0.3); color: var(--rn-cyan); }
.rn-dep-tab-bank:hover { background: rgba(139, 92, 246, 0.15); border-color: var(--rn-purple); color: #fff; }

/* Alertas */
.rn-alert {
    padding: 12px 16px;
    border-radius: 10px;
    font-size: 12px;
    line-height: 1.5;
    margin-bottom: 16px;
    border: 1px solid transparent;
}
.rn-alert.err   { background: rgba(239, 68, 68, 0.1);  border-color: rgba(239, 68, 68, 0.3); color: var(--rn-red); }
.rn-alert.warn  { background: rgba(251, 191, 36, 0.1); border-color: rgba(251, 191, 36, 0.3); color: var(--rn-gold); }
.rn-alert.info  { background: rgba(0, 224, 255, 0.1);  border-color: rgba(0, 224, 255, 0.3); color: var(--rn-cyan); }
.rn-alert.purp  { background: rgba(139, 92, 246, 0.1); border-color: rgba(139, 92, 246, 0.3); color: var(--rn-text-main); }
.rn-alert strong { display: block; margin-bottom: 4px; font-size: 13px; }
.rn-alert code { background: rgba(0,0,0,0.3); padding: 2px 6px; border-radius: 4px; color: var(--rn-gold); font-family: monospace; }

/* Flujo de pasos */
.rn-dep-flow {
    background: var(--rn-card);
    border: 1px solid var(--rn-border);
    border-radius: 12px;
    padding: 16px;
    margin-bottom: 16px;
}
.rn-dep-flow-title {
    color: var(--rn-cyan);
    font-size: 13px;
    font-weight: 600;
    margin: 0 0 12px 0;
    padding-bottom: 8px;
    border-bottom: 1px solid var(--rn-border);
}
.rn-dep-flow-list {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 10px;
    list-style: none;
    padding: 0;
    margin: 0;
    counter-reset: step;
}
.rn-dep-flow-list li {
    counter-increment: step;
    position: relative;
    padding: 10px 10px 10px 40px;
    background: rgba(0, 0, 0, 0.2);
    border: 1px solid var(--rn-border);
    border-radius: 8px;
    font-size: 11.5px;
    line-height: 1.5;
    color: var(--rn-text-main);
}
.rn-dep-flow-list li:before {
    content: counter(step);
    position: absolute;
    left: 10px;
    top: 50%;
    transform: translateY(-50%);
    width: 22px;
    height: 22px;
    border-radius: 50%;
    background: var(--rn-blue);
    color: #ffffff;
    font-weight: bold;
    font-size: 11px;
    display: flex;
    align-items: center;
    justify-content: center;
}
.rn-dep-flow-list li strong { color: var(--rn-cyan); }

/* Formulario */
.rn-dep-form-box {
    background: var(--rn-card);
    border: 1px solid var(--rn-border);
    border-radius: 12px;
    padding: 20px;
}
.rn-dep-label {
    color: var(--rn-text-muted);
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 8px;
    display: block;
    font-weight: 600;
}
.rn-dep-input-group {
    display: flex;
    background: rgba(0, 0, 0, 0.4);
    border: 1px solid var(--rn-border);
    border-radius: 12px;
    overflow: hidden;
    margin-bottom: 8px;
    transition: 0.25s ease;
}
.rn-dep-input-group:focus-within {
    border-color: var(--rn-blue);
    box-shadow: 0 0 10px rgba(43, 107, 243, 0.3);
}
.rn-dep-input-group input {
    flex: 1;
    background: transparent;
    border: none;
    padding: 16px;
    color: var(--rn-text-main);
    font-size: 20px;
    font-family: 'Inter', monospace;
    outline: none;
    font-weight: 700;
    min-width: 0;
}
.rn-dep-input-group input::placeholder {
    color: rgba(255,255,255,0.2);
    font-weight: 400;
}
.rn-dep-input-suffix {
    padding: 16px 20px;
    background: rgba(43, 107, 243, 0.1);
    color: var(--rn-blue);
    font-weight: 700;
    display: flex;
    align-items: center;
    font-size: 12px;
    letter-spacing: 0.5px;
}

.rn-dep-help {
    font-size: 11px;
    color: var(--rn-text-muted);
    margin-bottom: 20px;
    line-height: 1.5;
}
.rn-dep-help strong { color: var(--rn-text-main); }

/* Caja de cálculo */
.rn-dep-calc {
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid var(--rn-border);
    border-radius: 10px;
    padding: 14px;
    margin-bottom: 20px;
}
.rn-dep-calc-row {
    display: flex;
    justify-content: space-between;
    padding: 6px 0;
    font-size: 12px;
    border-bottom: 1px dashed var(--rn-border);
}
.rn-dep-calc-row:last-child { border-bottom: none; }
.rn-dep-calc-label { color: var(--rn-text-muted); }
.rn-dep-calc-value { color: var(--rn-text-main); font-weight: 600; font-family: 'Inter', monospace; }
.rn-dep-calc-value.cyan { color: var(--rn-cyan); }
.rn-dep-calc-value.purple { color: var(--rn-purple); }

/* Botón */
.rn-dep-btn {
    display: block;
    width: 100%;
    background: var(--rn-green);
    color: #000000;
    border: none;
    padding: 16px;
    border-radius: 30px;
    font-size: 13px;
    font-weight: 700;
    cursor: pointer;
    text-align: center;
    text-decoration: none;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    transition: 0.25s ease;
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.4);
    box-sizing: border-box;
}
.rn-dep-btn:hover {
    background: #3be673;
    box-shadow: 0 0 20px rgba(74, 255, 136, 0.4);
    transform: translateY(-1px);
}
.rn-dep-btn:disabled, .rn-dep-btn.disabled {
    background: rgba(255, 255, 255, 0.1);
    color: var(--rn-text-muted);
    cursor: not-allowed;
    box-shadow: none;
    transform: none;
}
.rn-dep-btn-gray {
    display: inline-block;
    background: rgba(255, 255, 255, 0.1);
    border: 1px solid var(--rn-border);
    color: var(--rn-text-main);
    padding: 10px 24px;
    border-radius: 30px;
    font-size: 12px;
    font-weight: 600;
    text-decoration: none;
    transition: 0.25s ease;
    margin-top: 12px;
}
.rn-dep-btn-gray:hover { background: rgba(255, 255, 255, 0.2); color: #fff; }

@media (max-width: 720px) {
    .rn-dep-wrapper { padding: 16px; margin-top: 10px; }
    .rn-dep-title h2 { font-size: 16px; }
    .rn-dep-tab { padding: 6px 12px; font-size: 11px; }
    .rn-dep-input-group input { font-size: 16px; padding: 12px; }
    .rn-dep-input-suffix { padding: 12px 14px; font-size: 11px; }
    .rn-dep-flow-list { grid-template-columns: 1fr; }
}
</style>

<div class="rn-dep-wrapper">

    {* ─── HEADER ─────────────────────────────────────── *}
    <div class="rn-dep-title">
        <h2>📥 Invertir Cristales Kyber</h2>
        <span class="counter {if $solicitudes_count >= $max_solicitudes}limit{/if}">
            Solicitudes activas: <strong>{$solicitudes_count} / {$max_solicitudes}</strong>
        </span>
    </div>

    {* ─── TABS ───────────────────────────────────────── *}
    <div class="rn-dep-tabs">
        <a class="rn-dep-tab" href="game.php?page=wallet">📊 Resumen</a>
        <a class="rn-dep-tab active" href="game.php?page=wallet&mode=deposit">📥 Invertir</a>
        <a class="rn-dep-tab" href="game.php?page=wallet&mode=history">📜 Historial</a>
        <a class="rn-dep-tab rn-dep-tab-bank" 
           href="game.php?page=wallet&mode=setbankdata"
           title="Ver o editar tus datos bancarios">
            💳 Datos Bancarios
        </a>
    </div>

    {* ─── FEEDBACK ERROR ─────────────────────────────── *}
    {if $feedback_error != ''}
        <div class="rn-alert err">
            <strong>❌ Error</strong>
            {$feedback_error|escape:'html'}
        </div>
    {/if}

    {* ─── AVISO DE LÍMITE ALCANZADO ──────────────────── *}
    {if !$puede_crear}
        <div class="rn-alert warn">
            <strong>⚠️ Límite de solicitudes alcanzado</strong>
            Ya tenés <strong>{$max_solicitudes} solicitudes activas</strong> 
            (el máximo permitido). Para poder crear otra, primero tenés que:
            <br>• <strong>Esperar</strong> a que se resuelvan (completada / rechazada), o
            <br>• <strong>Cancelar</strong> una desde el 
            <a href="game.php?page=wallet" style="color:var(--rn-gold); text-decoration:underline;">panel de resumen</a>.
        </div>
    {/if}

    {* ─── INFO MODELO v6.0 ───────────────────────────── *}
    <div class="rn-alert purp">
        <strong>💹 Modelo 1:1 SIN AMM</strong><br>
        · Inversión: <strong>100 💎 Kyber = 100 💲 NXT-20</strong> (retirables).<br>
        · El banco <strong>nunca quiebra</strong>: los fondos siempre están disponibles.<br>
        · Los 💲 NXT-20 que recibís son <strong>retirables</strong> (a diferencia de los que ganás en el juego).<br>
        · El pago lo hacés con <strong>transferencia bancaria real (CUP)</strong> al admin.
    </div>

    {* ─── INFO IMPORTANTE ────────────────────────────── *}
    <div class="rn-alert info">
        <strong>ℹ️ ¿Cómo pagás?</strong>
        El banco NO usa tu Kyber in-game. Una vez que un admin tome tu solicitud,
        te enviará sus <strong>datos bancarios</strong> (tarjeta + teléfono) para que hagas 
        una <strong>transferencia real en CUP</strong>. Después subís el ID de la transferencia 
        y el admin confirma tu inversión.
    </div>

    {* ─── FLUJO DE 6 PASOS ───────────────────────────── *}
    <div class="rn-dep-flow">
        <h3 class="rn-dep-flow-title">📋 ¿Cómo funciona la inversión?</h3>
        <ol class="rn-dep-flow-list">
            <li><strong>Solicitás</strong> la inversión desde acá</li>
            <li><strong>Un admin</strong> la toma y bloquea</li>
            <li><strong>Te envía</strong> sus datos bancarios</li>
            <li><strong>Hacés</strong> la transferencia real (CUP)</li>
            <li><strong>Subís</strong> el ID de transferencia</li>
            <li><strong>El admin</strong> verifica y confirma</li>
        </ol>
    </div>

    {* ─── INFO REFERIDOR ─────────────────────────────── *}
    {if $tiene_referidor}
        <div class="rn-alert info" style="border-color: rgba(139, 92, 246, 0.4); color: var(--rn-purple); background: rgba(139, 92, 246, 0.08);">
            <strong>🔗 Tenés un referidor vinculado</strong>
            Tu referidor recibirá una comisión en <strong>NXT-20</strong> por tu inversión. 
            ¡Seguí invitando amigos para ganar vos también!
        </div>
    {/if}

    {* ─── FORMULARIO ─────────────────────────────────── *}
    <div class="rn-dep-form-box">

        {if $puede_crear}
            <form method="POST" action="{$action_url}" id="astrowaldep_form">

                <label class="rn-dep-label">
                    💎 Cantidad de Kyber a invertir
                </label>

                <div class="rn-dep-input-group">
                    <input 
                        type="number" 
                        name="cantidad" 
                        id="astrowaldep_cantidad"
                        min="100" 
                        placeholder="100" 
                        required
                        autofocus
                        autocomplete="off"
                    >
                    <span class="rn-dep-input-suffix">KYBER</span>
                </div>

                <div class="rn-dep-help">
                    Mínimo: <strong>100 Kyber</strong> · 
                    Escribí la cantidad que querés invertir (sin límite máximo).
                </div>

                {* ─── Resumen de cálculo (se llena con JS) ─── *}
                <div class="rn-dep-calc" id="astrowaldep_calc" style="display:none;">
                    <div class="rn-dep-calc-row">
                        <span class="rn-dep-calc-label">💰 Vas a invertir</span>
                        <span class="rn-dep-calc-value cyan" id="astrowaldep_r_kyber">0 Kyber</span>
                    </div>
                    <div class="rn-dep-calc-row">
                        <span class="rn-dep-calc-label">💲 NXT-20 que recibirás (100%)</span>
                        <span class="rn-dep-calc-value purple" id="astrowaldep_r_nxt">0 NXT-20</span>
                    </div>
                </div>

                <button type="submit" class="rn-dep-btn"
                        onclick="return confirm('¿Confirmar la solicitud de inversión?\n\nPodrás cancelarla después si cambiás de opinión.');">
                    ✅ Solicitar inversión
                </button>

            </form>
        {else}
            {* ─── Formulario bloqueado ─── *}
            <div style="text-align:center; padding: 20px 0;">
                <div style="font-size: 32px; margin-bottom: 10px;">🔒</div>
                <div style="color:var(--rn-gold); font-size:14px; font-weight:bold; margin-bottom:6px;">
                    No podés crear nuevas solicitudes
                </div>
                <div style="color:var(--rn-text-muted); font-size:12px; line-height:1.6; margin-bottom:16px;">
                    Alcanzaste el límite de {$max_solicitudes} solicitudes activas.<br>
                    Cancelá una o esperá a que se resuelvan.
                </div>
                <a href="game.php?page=wallet" class="rn-dep-btn-gray">
                    ← Volver al panel
                </a>
            </div>
        {/if}

    </div>

</div>

{* ─── JS — Cálculo en vivo (v6.0: 1:1) ──────────────────── *}
{if $puede_crear}
<script type="text/javascript">
(function() {
    var input     = document.getElementById('astrowaldep_cantidad');
    var calc      = document.getElementById('astrowaldep_calc');
    var rKyber    = document.getElementById('astrowaldep_r_kyber');
    var rNxt      = document.getElementById('astrowaldep_r_nxt');

    if (!input || !calc) return;

    // v6.0: minimo de inversion (debe coincidir con WalletHelper::MIN_INVERSION_KYBER)
    var MIN_INVERSION = 100;

    function fmt(n) {
        return Math.floor(n).toLocaleString('es-AR');
    }

    function update() {
        var v = parseInt(input.value, 10);

        if (!v || v <= 0 || v < MIN_INVERSION) {
            calc.style.display = 'none';
            return;
        }

        // v6.0 — Modelo 1:1
        // - Invierte v Kyber
        // - Recibe v NXT-20 (100% del monto invertido, retirables)
        // El reparto interno (banco / proyecto / referidor) NO se muestra.

        var nxtUser = v;

        rKyber.textContent = fmt(v)       + ' Kyber';
        rNxt.textContent   = fmt(nxtUser) + ' NXT-20';

        calc.style.display = 'block';
    }

    input.addEventListener('input', update);
    input.addEventListener('change', update);

    if (input.value) update();
})();
</script>
{/if}

{/block}