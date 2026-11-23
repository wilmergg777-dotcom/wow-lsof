{block name="title" prepend}Retirar{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.wallet.withdraw.tpl === *}
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
   RETIRAR — Vista del usuario
   AstroIO v6.0 — Sistema 1:1 SIN AMM + comision 10%
   Prefijo: .wallet-
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

.wallet-wrapper {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    color: var(--text-main);
    padding: 20px;
    border-radius: 12px;
    border: 1px solid var(--border-color);
    max-width: 950px;
    margin: 0 auto;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    box-sizing: border-box;
}
.wallet-title {
    color: var(--text-title);
    font-size: 22px;
    margin-bottom: 20px;
    text-shadow: 0 0 12px rgba(74, 255, 136, 0.35);
}
.wallet-tabs {
    display: flex;
    gap: 8px;
    margin-bottom: 20px;
    border-bottom: 1px solid rgba(74, 255, 136, 0.2);
    padding-bottom: 10px;
    flex-wrap: wrap;
}
.wallet-tab {
    background: rgba(0, 0, 0, 0.2);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid transparent;
    color: var(--text-muted);
    padding: 10px 20px;
    cursor: pointer;
    font-weight: 600;
    border-radius: 6px;
    text-decoration: none;
    font-size: 14px;
    transition: 0.25s ease;
}
.wallet-tab.active {
    background: linear-gradient(135deg, #0066cc 0%, #0099ff 100%);
    color: #ffffff;
    border-color: var(--accent-cyan);
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.35);
}
.wallet-tab:hover {
    background: rgba(0, 224, 255, 0.08);
    color: var(--text-main);
    border-color: rgba(0, 224, 255, 0.3);
    transform: translateY(-1px);
}
.wallet-form-box {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 10px;
    padding: 25px;
}
.wallet-form-label {
    color: var(--accent-cyan);
    font-size: 13px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 8px;
    display: block;
    font-weight: bold;
}
.wallet-input-group {
    display: flex;
    background: rgba(0, 0, 0, 0.5);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    overflow: hidden;
    margin-bottom: 20px;
    transition: 0.25s ease;
}
.wallet-input-group:focus-within {
    border-color: var(--accent-cyan);
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.35);
}
.wallet-input-group input {
    flex: 1;
    background: transparent;
    border: none;
    padding: 15px;
    color: var(--text-title);
    font-size: 16px;
    font-family: 'Courier New', monospace;
    font-weight: bold;
    outline: none;
    min-width: 0;
}
.wallet-input-suffix {
    padding: 15px 20px;
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
.wallet-btn {
    display: block;
    width: 100%;
    background: linear-gradient(135deg, #228833 0%, #4aff88 100%);
    color: #ffffff;
    border: 1px solid var(--accent-green);
    padding: 15px;
    border-radius: 8px;
    font-size: 16px;
    font-weight: bold;
    cursor: pointer;
    text-align: center;
    text-decoration: none;
    text-transform: uppercase;
    letter-spacing: 1px;
    transition: 0.25s ease;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.4);
    box-sizing: border-box;
}
.wallet-btn:hover {
    box-shadow: 0 0 14px rgba(74, 255, 136, 0.55);
    transform: translateY(-2px);
    color: #ffffff;
}
.wallet-btn:disabled {
    background: rgba(30, 41, 59, 0.85);
    border: 1px solid var(--border-color);
    color: var(--text-muted);
    cursor: not-allowed;
    box-shadow: none;
    transform: none;
}
.wallet-info-box {
    background: rgba(74, 255, 136, 0.1);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(74, 255, 136, 0.35);
    border-radius: 8px;
    padding: 12px;
    font-size: 13px;
    color: var(--accent-green);
    margin-bottom: 20px;
    line-height: 1.8;
}
.wallet-info-box strong { color: var(--text-title); }
.wallet-warning-box {
    background: rgba(251, 191, 36, 0.1);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(251, 191, 36, 0.4);
    border-radius: 8px;
    padding: 12px;
    font-size: 13px;
    color: var(--accent-gold);
    margin-bottom: 15px;
    line-height: 1.8;
}
.wallet-warning-box strong { color: var(--text-title); }
.wallet-vip-box {
    background: linear-gradient(135deg, rgba(251, 191, 36, 0.15) 0%, rgba(245, 158, 11, 0.15) 100%);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(251, 191, 36, 0.5);
    border-radius: 8px;
    padding: 12px;
    font-size: 13px;
    color: var(--accent-gold);
    margin-bottom: 20px;
    line-height: 1.8;
}
.wallet-vip-box strong { color: var(--text-title); }
.wallet-lock-box {
    background: linear-gradient(135deg, rgba(139, 92, 246, 0.15) 0%, rgba(59, 130, 246, 0.15) 100%);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(139, 92, 246, 0.5);
    border-radius: 8px;
    padding: 12px;
    font-size: 13px;
    color: #c4b5fd;
    margin-bottom: 20px;
    line-height: 1.8;
}
.wallet-lock-box strong { color: var(--text-title); }
.wallet-msg-error {
    background: rgba(239, 68, 68, 0.15);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(239, 68, 68, 0.5);
    color: var(--accent-red);
    padding: 12px;
    border-radius: 8px;
    margin-bottom: 15px;
}
.wallet-preview {
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(74, 255, 136, 0.5);
    border-radius: 10px;
    padding: 20px;
    margin-bottom: 20px;
    text-align: center;
}
.wallet-preview-label {
    color: var(--text-muted);
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 5px;
}
.wallet-preview-value {
    color: var(--accent-green);
    font-size: 32px;
    font-weight: bold;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 12px rgba(74, 255, 136, 0.4);
}
.wallet-preview-sub {
    color: var(--text-muted);
    font-size: 12px;
    margin-top: 8px;
}
.wallet-breakdown {
    background: rgba(0, 0, 0, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    padding: 14px 18px;
    margin-bottom: 20px;
    font-size: 13px;
}
.wallet-breakdown-row {
    display: flex;
    justify-content: space-between;
    padding: 5px 0;
    color: var(--text-muted);
}
.wallet-breakdown-row.total {
    border-top: 1px solid var(--border-color);
    margin-top: 6px;
    padding-top: 10px;
    color: var(--accent-green);
    font-weight: bold;
    font-size: 15px;
}
.wallet-breakdown-row .val {
    font-family: 'Courier New', monospace;
    color: var(--text-title);
}
.wallet-breakdown-row.total .val {
    color: var(--accent-green);
}
.wallet-min-warning {
    color: var(--accent-red);
    font-size: 12px;
    margin-top: 6px;
    margin-bottom: 10px;
    display: none;
}
.wallet-min-warning.visible { display: block; }
.wallet-min-warning strong { color: var(--accent-red); }

@media (max-width: 600px) {
    .wallet-preview-value { font-size: 26px; }
}
</style>

<div class="wallet-wrapper">

    <div class="wallet-title">📤 Retirar NXT-20</div>

    <div class="wallet-tabs">
        <a class="wallet-tab" href="game.php?page=wallet">📊 Resumen</a>
        <a class="wallet-tab" href="game.php?page=wallet&mode=deposit">📥 Depositar</a>
        <a class="wallet-tab active" href="game.php?page=wallet&mode=withdraw">📤 Retirar</a>
        <a class="wallet-tab" href="game.php?page=wallet&mode=history">📜 Historial</a>
    </div>

    {if $feedback_error != ''}
        <div class="wallet-msg-error">❌ {$feedback_error|escape:'html'}</div>
    {/if}

    {* ─── AVISO VIP (obligatorio para retirar) ─── *}
    <div class="wallet-vip-box">
        ⭐ <strong>Retiro exclusivo para VIP.</strong> Tu pase VIP está activo. Gracias por apoyar al proyecto.
    </div>

    {* ─── AVISO DE BLOQUEO INMEDIATO (v6.0) ─── *}
    <div class="wallet-lock-box">
        🔒 <strong>Atención:</strong> al solicitar el retiro, los NXT-20 quedan <strong>BLOQUEADOS</strong> inmediatamente.
        Si el admin no responde en 72h, se te devuelven automáticamente.<br>
        💡 Podes cancelar la solicitud mientras esté en estado <strong>pendiente</strong>.
    </div>

    <div class="wallet-form-box">

        {* ─── INFO DEL BANCO v6.0 ─── *}
        <div class="wallet-info-box">
            💲 NXT-20 retirables: <strong>{$nxt20_retirable}</strong><br>
            💱 Tasa de retiro: <strong>1 NXT-20 = 0.90 Kyber</strong> (comisión 10%)<br>
            💰 Recibís el neto en tu tarjeta, ya descontada la comisión.
        </div>

        {* ─── MÍNIMO ─── *}
        <div class="wallet-warning-box">
            🎯 <strong>Mínimo de retiro:</strong> <strong>{$min_retiro_nxt20} NXT-20</strong><br>
            🔼 <strong>Máximo retirable:</strong> <strong>{$nxt20_retirable} NXT-20</strong> (tu saldo retirable)
        </div>

        <form method="POST" action="{$action_url}" id="withdrawForm">

            <label class="wallet-form-label">Cantidad de NXT-20 a retirar</label>

            <div class="wallet-input-group">
                <input type="number" 
                       name="nxt20" 
                       id="nxt20Input"
                       min="{$min_retiro_nxt20}" 
                       max="{$nxt20_retirable_raw}" 
                       placeholder="0" 
                       required
                       autofocus>
                <span class="wallet-input-suffix">NXT-20</span>
            </div>

            <div class="wallet-min-warning" id="minWarning">
                ⚠️ No cumplís el mínimo. Necesitás al menos <strong>{$min_retiro_nxt20} NXT-20</strong>.
            </div>

            {* ─── PREVIEW EN VIVO ─── *}
            <div class="wallet-preview">
                <div class="wallet-preview-label">Vas a recibir</div>
                <div class="wallet-preview-value">
                    <span id="previewNeto">0</span> CUP
                </div>
                <div class="wallet-preview-sub">
                    Se quemarán 💲 <span id="previewBurn">0</span> NXT-20 de tu cuenta
                </div>
            </div>

            {* ─── DESGLOSE ─── *}
            <div class="wallet-breakdown">
                <div class="wallet-breakdown-row">
                    <span>💲 Bruto solicitado</span>
                    <span class="val"><span id="bdBruto">0</span> NXT-20</span>
                </div>
                <div class="wallet-breakdown-row">
                    <span>✂️ Comisión (10%)</span>
                    <span class="val">- <span id="bdComision">0</span> NXT-20</span>
                </div>
                <div class="wallet-breakdown-row total">
                    <span>✅ Neto a recibir</span>
                    <span class="val"><span id="bdNeto">0</span> CUP</span>
                </div>
            </div>

            <button type="submit" class="wallet-btn" id="submitBtn"
                    onclick="return confirm('¿Confirmar la solicitud de retiro?\n\nLos NXT-20 quedarán BLOQUEADOS hasta que un admin procese el retiro.');">
                ✅ Solicitar retiro
            </button>

        </form>

    </div>

</div>

<script>
(function() {
    // ═══════════════════════════════════════════════════════════
    // DATOS DEL BACKEND (v6.0)
    // ═══════════════════════════════════════════════════════════
    var minNxt20       = parseInt('{$min_retiro_nxt20}') || 0;
    var nxt20Retirable = parseInt('{$nxt20_retirable_raw}') || 0;

    // ═══════════════════════════════════════════════════════════
    // CÁLCULO EN VIVO DEL RETIRO (v6.0: 1:1 con 10% de comisión)
    // El usuario NO ve el split interno (7% proyecto + 3% referidor).
    // Solo ve la comisión total y el neto.
    // ═══════════════════════════════════════════════════════════
    var input         = document.getElementById('nxt20Input');
    var elPreviewNeto = document.getElementById('previewNeto');
    var elPreviewBurn = document.getElementById('previewBurn');
    var elBdBruto     = document.getElementById('bdBruto');
    var elBdComision  = document.getElementById('bdComision');
    var elBdNeto      = document.getElementById('bdNeto');
    var minWarning    = document.getElementById('minWarning');
    var submitBtn     = document.getElementById('submitBtn');

    function formatNumber(n) {
        return Math.floor(n).toLocaleString('es-AR');
    }

    function recalcular() {
        var nxt20 = parseInt(input.value) || 0;
        if (nxt20 < 0) nxt20 = 0;

        // v6.0: 1:1 con 10% comision
        var bruto     = nxt20;
        var comision  = Math.floor(bruto * 0.10);
        var neto      = bruto - comision;

        elPreviewNeto.textContent = formatNumber(neto);
        elPreviewBurn.textContent = formatNumber(nxt20);
        elBdBruto.textContent     = formatNumber(bruto);
        elBdComision.textContent  = formatNumber(comision);
        elBdNeto.textContent      = formatNumber(neto);

        // Validaciones
        var cumpleMin   = (nxt20 >= minNxt20);
        var cumpleSaldo = (nxt20 <= nxt20Retirable);

        var ok = (nxt20 > 0) && cumpleMin && cumpleSaldo;

        if (nxt20 > 0 && !cumpleMin) {
            minWarning.classList.add('visible');
        } else {
            minWarning.classList.remove('visible');
        }

        submitBtn.disabled = !ok;
    }

    if (input) {
        input.addEventListener('input', recalcular);
        recalcular();
    }

})();
</script>

{/block}