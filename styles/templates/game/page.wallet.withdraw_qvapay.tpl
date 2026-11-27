{block name="title" prepend}Retirar vía QvaPay{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.wallet.withdraw_qvapay.tpl === *}
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
   RETIRAR QVAPAY — Estilo Web3 (Ronin/Kriptomat)
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
.rn-dep-calc-value.green { color: var(--rn-green); }
.rn-dep-calc-value.red { color: var(--rn-red); }

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

@media (max-width: 720px) {
    .rn-dep-wrapper { padding: 16px; margin-top: 10px; }
    .rn-dep-title h2 { font-size: 16px; }
    .rn-dep-tab { padding: 6px 12px; font-size: 11px; }
    .rn-dep-input-group input { font-size: 16px; padding: 12px; }
    .rn-dep-input-suffix { padding: 12px 14px; font-size: 11px; }
}
</style>

<div class="rn-dep-wrapper">

    {* ─── HEADER ─────────────────────────────────────── *}
    <div class="rn-dep-title">
        <h2>📤 Retirar UNTX-20 vía QvaPay</h2>
    </div>

    {* ─── TABS ───────────────────────────────────────── *}
    <div class="rn-dep-tabs">
        <a class="rn-dep-tab" href="game.php?page=wallet">📊 Resumen</a>
        <a class="rn-dep-tab" href="game.php?page=wallet&mode=deposit">📥 Invertir</a>
        <a class="rn-dep-tab" href="game.php?page=wallet&mode=history">📜 Historial</a>
        <a class="rn-dep-tab active" href="game.php?page=wallet&mode=withdraw_qvapay">📤 Retirar</a>
    </div>

    {* ─── ALERTAS ────────────────────────────────────── *}
    <div class="rn-alert info">
        <strong>ℹ️ ¿Cómo funciona?</strong>
        Al solicitar el retiro, los UNTX-20 quedan bloqueados. Un administrador revisará tu solicitud y te enviará el dinero a tu cuenta de QvaPay. El proceso suele tardar menos de 24 horas.
    </div>

    <div class="rn-alert warn">
        <strong>⚠️ Comisiones de Retiro</strong>
        El sistema aplica una comisión del <strong>10%</strong> sobre el monto que retirás.<br>
        • <strong>7%</strong> va al Fondo del Proyecto.<br>
        • <strong>3%</strong> va al sistema de referidos.<br>
        El dinero neto que recibirás en QvaPay será el 90% del total.
    </div>

    {* ─── FORMULARIO ─────────────────────────────────── *}
    <div class="rn-dep-form-box">

        <form method="POST" action="banco_qvapay_crear_retiro.php" id="formRetiroQvaPay">

            <label class="rn-dep-label">
                👤 Tu usuario de QvaPay
            </label>
            <div class="rn-dep-input-group">
                <input 
                    type="text" 
                    name="qvapay_username" 
                    id="qvapayUsername"
                    placeholder="@tunombre" 
                    required
                    autocomplete="off"
                >
            </div>
            <div class="rn-dep-help">
                Asegurate de que sea tu usuario real en QvaPay para que te llegue la transferencia.
            </div>

            <label class="rn-dep-label">
                💲 Cantidad de UNTX-20 a retirar
            </label>
            <div class="rn-dep-input-group">
                <input 
                    type="number" 
                    name="nxt20" 
                    id="nxt20Cantidad"
                    min="300" 
                    placeholder="300" 
                    required
                    autocomplete="off"
                >
                <span class="rn-dep-input-suffix">UNTX-20</span>
            </div>
            <div class="rn-dep-help">
                Mínimo de retiro: <strong>300 UNTX-20</strong>.
            </div>

            {* ─── Resumen de cálculo (se llena con JS) ─── *}
            <div class="rn-dep-calc" id="calcQvaPay" style="display:none;">
                <div class="rn-dep-calc-row">
                    <span class="rn-dep-calc-label">💲 Monto bruto</span>
                    <span class="rn-dep-calc-value" id="calcBruto">0 UNTX-20</span>
                </div>
                <div class="rn-dep-calc-row">
                    <span class="rn-dep-calc-label">✂️ Comisión (10%)</span>
                    <span class="rn-dep-calc-value red" id="calcComision">- 0 UNTX-20</span>
                </div>
                <div class="rn-dep-calc-row">
                    <span class="rn-dep-calc-label">✅ Recibirás en QvaPay</span>
                    <span class="rn-dep-calc-value green" id="calcNeto">0 UNTX-20</span>
                </div>
            </div>

            <button type="submit" class="rn-dep-btn" id="btnSolicitar">
                ✅ Solicitar Retiro
            </button>

        </form>

    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const inputNxt = document.getElementById('nxt20Cantidad');
    const calcBox = document.getElementById('calcQvaPay');
    const elBruto = document.getElementById('calcBruto');
    const elComision = document.getElementById('calcComision');
    const elNeto = document.getElementById('calcNeto');
    const form = document.getElementById('formRetiroQvaPay');
    const btnSolicitar = document.getElementById('btnSolicitar');

    const MIN_RETIRO = 300;

    function formatNumber(n) {
        return Math.floor(n).toLocaleString('es-AR');
    }

    inputNxt.addEventListener('input', function() {
        let val = parseInt(this.value) || 0;

        if (val < MIN_RETIRO) {
            calcBox.style.display = 'none';
            return;
        }

        // v6.4: comision 10% (7% proyecto + 3% referidor)
        let bruto = val;
        let comision = Math.floor(bruto * 0.10);
        let neto = bruto - comision;

        elBruto.textContent = formatNumber(bruto) + ' UNTX-20';
        elComision.textContent = '- ' + formatNumber(comision) + ' UNTX-20';
        elNeto.textContent = formatNumber(neto) + ' UNTX-20';

        calcBox.style.display = 'block';
    });

    // Envío AJAX
    form.addEventListener('submit', function(e) {
        e.preventDefault();

        let username = document.getElementById('qvapayUsername').value.trim();
        let cantidad = parseInt(inputNxt.value);

        if (username === '') {
            alert('Por favor, ingresá tu usuario de QvaPay.');
            return;
        }

        if (cantidad < MIN_RETIRO) {
            alert('El mínimo de retiro es de ' + MIN_RETIRO + ' UNTX-20.');
            return;
        }

        let textoOriginal = btnSolicitar.innerHTML;
        btnSolicitar.innerHTML = "⏳ Procesando...";
        btnSolicitar.disabled = true;

        let formData = new FormData();
        formData.append('nxt20', cantidad);
        formData.append('qvapay_username', username);

        fetch('banco_qvapay_crear_retiro.php', {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())
        .then(data => {
            if (data.error) {
                alert("❌ Error: " + data.error);
                btnSolicitar.innerHTML = textoOriginal;
                btnSolicitar.disabled = false;
            } else if (data.success) {
                alert("✅ ¡Solicitud enviada! Recibirás " + data.neto + " UNTX-20 vía QvaPay pronto.");
                window.location.href = "game.php?page=wallet"; // Redirigir al resumen
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert("❌ Error de conexión al procesar el retiro.");
            btnSolicitar.innerHTML = textoOriginal;
            btnSolicitar.disabled = false;
        });
    });
});
</script>

{/block}