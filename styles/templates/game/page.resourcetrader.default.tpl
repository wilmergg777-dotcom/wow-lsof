{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.resourcetrader.default.tpl === *}
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


{* ============================================================
   RESOURCE TRADER v2.4 — Estilo Xnova moderno + Doble Riel
   - Icono 💲 fijo
   - Texto dinámico: NTX-20 o UNTX-20
   - Coste fallback ajustado al doble si es internacional
   ============================================================ *}

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

.rt_wrap { width: 100%; padding: 15px; box-sizing: border-box; }
.rt_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    padding: 15px;
    color: var(--text-main);
    max-width: 720px;
    margin: 0 auto;
}
.rt_header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 15px;
    padding-bottom: 12px;
    border-bottom: 1px solid rgba(255, 170, 51, 0.2);
    margin-bottom: 15px;
    flex-wrap: wrap;
}
.rt_img_box {
    width: 90px; height: 90px;
    border-radius: 10px;
    background: rgba(0, 0, 0, 0.4);
    border: 1px solid rgba(255, 170, 51, 0.4);
    box-shadow: 0 0 15px rgba(255, 170, 51, 0.15) inset;
    display: flex; align-items: center; justify-content: center;
    overflow: hidden; flex-shrink: 0; font-size: 46px;
}
.rt_header_text { flex-grow: 1; min-width: 220px; }
.rt_header_title {
    color: #ffaa33; font-weight: 800; font-size: 18px;
    letter-spacing: 1px;
    text-shadow: 0 2px 10px rgba(255, 170, 51, 0.5);
}
.rt_header_sub {
    color: var(--text-muted); font-size: 11px;
    letter-spacing: 0.3px; margin-top: 4px; font-style: italic;
}
.rt_section {
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    padding: 10px 12px;
    margin-bottom: 10px;
    transition: 0.2s ease;
}
.rt_section:hover { border-color: rgba(0, 204, 255, 0.3); }
.rt_section_label {
    color: #00e0ff; font-weight: 700; font-size: 11px;
    letter-spacing: 0.8px; text-transform: uppercase;
    margin-bottom: 8px; display: block;
    border-bottom: 1px solid rgba(0, 204, 255, 0.15);
    padding-bottom: 6px;
}
.rt_select {
    width: 100%;
    padding: 8px 30px 8px 12px;
    background: rgba(0, 0, 0, 0.4);
    border: 1px solid rgba(255, 170, 51, 0.5);
    border-radius: 8px;
    color: #ffffff; font-weight: 700; font-size: 12px;
    font-family: inherit; cursor: pointer; outline: none;
    transition: 0.25s ease;
    appearance: none; -webkit-appearance: none; -moz-appearance: none;
    background-image:
        linear-gradient(45deg, transparent 50%, #ffaa33 50%),
        linear-gradient(135deg, #ffaa33 50%, transparent 50%);
    background-position: calc(100% - 16px) center, calc(100% - 11px) center;
    background-size: 5px 5px, 5px 5px;
    background-repeat: no-repeat;
    box-sizing: border-box;
}
.rt_select:hover, .rt_select:focus {
    border-color: #ffcc66;
    box-shadow: 0 0 12px rgba(255, 170, 51, 0.5);
    transform: translateY(-1px);
}
.rt_select:disabled { opacity: 0.5; cursor: not-allowed; color: var(--text-muted); }
.rt_select option { background: #0f1624; color: #ffffff; padding: 6px; }
.rt_input_row { display: flex; gap: 8px; align-items: stretch; max-width: 100%; }
.rt_input {
    flex-grow: 1;
    padding: 10px 12px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    color: #ffffff;
    font-family: 'Courier New', monospace;
    font-weight: 700; font-size: 13px;
    outline: none; transition: 0.25s ease;
    text-align: center; min-width: 0; box-sizing: border-box;
}
.rt_input:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}
.rt_max_btn {
    padding: 10px 18px;
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.9), rgba(0, 102, 204, 0.9));
    border: 1px solid rgba(0, 204, 255, 0.6);
    border-radius: 8px;
    color: #ffffff; font-weight: 700; font-size: 11px;
    cursor: pointer; transition: 0.25s ease;
    white-space: nowrap; letter-spacing: 0.5px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    font-family: inherit; text-transform: uppercase;
}
.rt_max_btn:hover {
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.95), rgba(0, 153, 255, 0.95));
    box-shadow: 0 0 16px rgba(0, 204, 255, 0.6);
    transform: translateY(-2px);
}
.rt_values {
    display: flex; flex-wrap: wrap; gap: 8px 12px;
    font-size: 12px; padding: 4px 0;
}
.rt_val_item {
    display: flex; align-items: center; gap: 6px;
    font-weight: 600;
    background: rgba(0, 0, 0, 0.3);
    padding: 5px 10px; border-radius: 6px;
    border: 1px solid rgba(255, 255, 255, 0.06);
    transition: 0.2s ease; cursor: help;
}
.rt_val_item:hover {
    background: rgba(0, 0, 0, 0.5);
    border-color: rgba(0, 204, 255, 0.3);
}
.rt_val_item span {
    font-family: 'Courier New', monospace;
    font-weight: 700; font-size: 12px;
}
.rt_val_item.rt_val_dar { background: rgba(255, 100, 100, 0.08); }
.rt_val_item.rt_val_rec { background: rgba(102, 255, 153, 0.08); }
.res_metal    { color: #c8d6e5 !important; }
.res_crystal  { color: #88ddff !important; }
.res_deut     { color: #aaff88 !important; }
.res_mo       { color: #aa44ff !important; }
.res_ntx      { color: #ffdd55 !important; }
.rt_submit_row { text-align: center; padding-top: 8px; }
.rt_submit {
    display: inline-block;
    padding: 12px 40px;
    background: linear-gradient(135deg, rgba(119, 0, 204, 0.9), rgba(170, 68, 255, 0.9));
    border: 1px solid #cc66ff;
    border-radius: 8px;
    color: #ffffff; font-weight: 700; font-size: 12px;
    cursor: pointer; transition: 0.25s ease;
    letter-spacing: 0.8px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    font-family: inherit;
    box-shadow: 0 4px 15px rgba(119, 0, 204, 0.5);
    text-transform: uppercase;
}
.rt_submit:hover:not(:disabled) {
    background: linear-gradient(135deg, rgba(170, 68, 255, 0.95), rgba(204, 102, 255, 0.95));
    box-shadow: 0 0 22px rgba(170, 68, 255, 0.7), 0 4px 15px rgba(119, 0, 204, 0.5);
    transform: translateY(-2px);
}
.rt_submit:disabled { opacity: 0.4; cursor: not-allowed; box-shadow: none; }
.rt_charge {
    text-align: center; padding: 10px 0 0 0; margin-top: 10px;
    border-top: 1px solid rgba(255, 170, 51, 0.2);
    color: #ffaa33; font-weight: 700; font-size: 12px; letter-spacing: 0.5px;
}
.rt_charge b {
    color: #ffffff;
    font-family: 'Courier New', monospace;
    font-size: 14px;
    text-shadow: 0 0 10px rgba(255, 170, 51, 0.5);
}
.rt_pago_box {
    display: flex; justify-content: space-between; align-items: center;
    padding: 8px 12px; margin-top: 8px;
    background: rgba(0, 0, 0, 0.25); border-radius: 8px; font-size: 12px;
}
.rt_pago_label { color: var(--text-muted); font-weight: 600; }
.rt_pago_val {
    font-weight: 700;
    font-family: 'Courier New', monospace;
    font-size: 12px;
}
.rt_pago_val.ok    { color: #66ff99; text-shadow: 0 0 8px rgba(102,255,153,0.5); }
.rt_pago_val.fall  { color: #00e0ff; text-shadow: 0 0 8px rgba(0, 224, 255, 0.5); }
.rt_pago_val.error { color: #ff4488; text-shadow: 0 0 8px rgba(255,68,136,0.5); }
.rt_msg {
    padding: 10px 14px; margin-bottom: 12px; border-radius: 8px;
    font-size: 12px; border-left: 4px solid; font-weight: 600;
    backdrop-filter: blur(4px); -webkit-backdrop-filter: blur(4px);
}
.rt_msg.success {
    background: rgba(102, 255, 153, 0.12);
    border-color: #66ff99; color: #88ffbb;
    box-shadow: 0 0 15px rgba(102, 255, 153, 0.15);
}
.rt_msg.error {
    background: rgba(255, 68, 136, 0.12);
    border-color: #ff4488; color: #ff88aa;
    box-shadow: 0 0 15px rgba(255, 68, 136, 0.15);
}
@media (max-width: 720px) {
    .rt_header { justify-content: center; text-align: center; }
    .rt_img_box { margin: 0 auto; }
    .rt_header_text { min-width: 100%; }
    .rt_input_row { flex-direction: column; }
    .rt_max_btn { width: 100%; }
    .rt_submit { width: 100%; padding: 12px 20px; }
    .rt_values { justify-content: center; }
    .rt_panel { max-width: 100%; padding: 12px; }
}
</style>

<div class="rt_wrap">
    <form method="post" action="game.php?page=resourceTrader" id="rt_form" onsubmit="return ResourceTrader.validate();">
        <input type="hidden" name="mode" value="doTrade" />
        <input type="hidden" name="dar" id="form_dar" value="" />
        <input type="hidden" name="recibir" id="form_recibir" value="" />
        <input type="hidden" name="cantidad" id="form_cantidad" value="0" />

        <div class="rt_panel">

            <div class="rt_header">
                <div class="rt_img_box">&#128176;</div>
                <div class="rt_header_text">
                    <div class="rt_header_title">Comerciante de Recursos</div>
                    <div class="rt_header_sub">Intercambio con tasas fijas &middot; Planeta: {$planet_name|escape:'html'}</div>
                </div>
            </div>

            {if $mensaje}
                <div class="rt_msg {$mensaje_tipo}">{$mensaje|escape:'html'}</div>
            {/if}

            <div class="rt_section">
                <span class="rt_section_label">1. Recurso a entregar</span>
                <select class="rt_select" id="sel_dar" onchange="ResourceTrader.selectDar(this.value);">
                    <option value="">&mdash; Selecciona un recurso &mdash;</option>
                    {foreach from=$recursos_dar item=r}
                        <option value="{$r.id}" data-cant="{$r.cantidad}">{$r.nombre} &mdash; Disponible: {$r.cantidad|number_format:0:',':'.'}</option>
                    {/foreach}
                </select>
            </div>

            <div class="rt_section">
                <span class="rt_section_label">2. Recurso a recibir</span>
                <select class="rt_select" id="sel_recibir" onchange="ResourceTrader.selectRecibir(this.value);" disabled>
                    <option value="">&mdash; Elige primero el recurso a entregar &mdash;</option>
                    {foreach from=$recursos_recibir item=r}
                        <option value="{$r.id}" data-dar="{$r.dar}" data-tasa="{$r.tasa}" style="display:none;">
                            {$r.nombre} &mdash; {$r.cuenta_dar} {$r.dar_nombre} = {$r.cuenta_recibir} {$r.nombre}
                        </option>
                    {/foreach}
                </select>
            </div>

            <div class="rt_section">
                <span class="rt_section_label">3. Cantidad a entregar</span>
                <div class="rt_input_row">
                    <input type="number" class="rt_input" id="inp_cantidad" min="0" value="0" oninput="ResourceTrader.updateCalc();" />
                    <button type="button" class="rt_max_btn" onclick="ResourceTrader.setMax();">M&aacute;x</button>
                </div>
            </div>

            <div class="rt_section">
                <span class="rt_section_label">Tus recursos</span>
                <div class="rt_values">
                    <div class="rt_val_item" title="Metal: {$recursos.metal|number_format:0:',':'.'}">
                        Metal: <span class="res_metal">{shortly_number($recursos.metal)}</span>
                    </div>
                    <div class="rt_val_item" title="Cristal: {$recursos.crystal|number_format:0:',':'.'}">
                        Cristal: <span class="res_crystal">{shortly_number($recursos.crystal)}</span>
                    </div>
                    <div class="rt_val_item" title="Deuterio: {$recursos.deuterium|number_format:0:',':'.'}">
                        Deuterio: <span class="res_deut">{shortly_number($recursos.deuterium)}</span>
                    </div>
                    <div class="rt_val_item" title="Materia Oscura: {$recursos.darkmatter|number_format:0:',':'.'}">
                        Materia Oscura: <span class="res_mo">{shortly_number($recursos.darkmatter)}</span>
                    </div>
                    {* 🆕 v2.4 — Saldo dinámico según método *}
                    <div class="rt_val_item" title="{$moneda}: {$ntx_actual|number_format:0:',':'.'}">
                        💲 {$moneda}: <span class="res_ntx">{shortly_number($ntx_actual)}</span>
                    </div>
                </div>
            </div>

            <div class="rt_section">
                <span class="rt_section_label">Total</span>
                <div class="rt_values">
                    <div class="rt_val_item rt_val_dar">
                        Entregas: <span class="res_metal" id="tot_dar">&mdash;</span>
                    </div>
                    <div class="rt_val_item rt_val_rec">
                        Recibes: <span class="res_crystal" id="tot_rec">&mdash;</span>
                    </div>
                </div>
            </div>

            <div class="rt_pago_box">
                <span class="rt_pago_label">M&eacute;todo de pago:</span>
                <span class="rt_pago_val" id="calc_estado">&mdash;</span>
            </div>

            <div class="rt_submit_row">
                <button type="submit" class="rt_submit" id="btn_submit" disabled>Enviar</button>
            </div>

            {* 🆕 v2.4 — Texto del coste con moneda dinámica *}
            <div class="rt_charge">
                Coste: <b>{$coste_mo} MO</b>{if $descuento_vip > 0} (VIP -{$descuento_vip}%){/if} &middot; Fallback: <b>{$coste_ntx20} {$moneda}</b>
            </div>

            {if $comerciante_nivel > 0}
            <div class="rt_charge">💼 Oficial Comerciante nivel <b>{$comerciante_nivel}</b>: <b>+{$comerciante_pct}%</b> de recursos en cada intercambio</div>
            {/if}

        </div>
    </form>
</div>

<script>
var ResourceTrader = (function () {
    var TASAS      = {$tasas_json};
    var RECURSOS   = {$recursos_json};
    var NOMBRES    = {$nombres_json};
    var MO_ACTUAL  = {$mo_actual};
    var NTX_ACTUAL = {$ntx_actual};
    var COSTE_MO   = {$coste_mo};
    var COSTE_NTX  = {$coste_ntx20};
    var MONEDA     = '{$moneda}';
    var COMERCIANTE_MULTI = {$comerciante_multi}; {* 🆕 v2.5 — Oficial Comerciante (ID 617) *}

    var selectedDar = null;
    var selectedRec = null;

    function q(id) { return document.getElementById(id); }

    function selectDar(id) {
        selectedDar = id || null;
        selectedRec = null;

        if (!id) {
            q('sel_recibir').disabled = true;
            q('inp_cantidad').value = 0;
            q('form_dar').value = '';
            updateCalc();
            return;
        }

        var selRec = q('sel_recibir');
        selRec.value = '';
        selRec.disabled = false;

        Array.prototype.forEach.call(selRec.options, function (opt) {
            if (!opt.value) { opt.style.display = ''; return; }
            opt.style.display = (opt.dataset.dar === id) ? '' : 'none';
        });

        q('inp_cantidad').value = 0;
        q('form_dar').value = id;
        q('form_recibir').value = '';
        q('form_cantidad').value = 0;

        updateCalc();
    }

    function selectRecibir(id) {
        selectedRec = id || null;
        q('form_recibir').value = id;
        updateCalc();
    }

    function setMax() {
        if (!selectedDar || !RECURSOS[selectedDar]) return;
        q('inp_cantidad').value = RECURSOS[selectedDar];
        updateCalc();
    }

    function updateCalc() {
        var cant = parseInt(q('inp_cantidad').value, 10) || 0;
        q('form_cantidad').value = cant;

        q('tot_dar').textContent = '\u2014';
        q('tot_rec').textContent = '\u2014';

        var est = q('calc_estado');
        est.className = 'rt_pago_val';
        est.textContent = '\u2014';
        q('btn_submit').disabled = true;

        if (!selectedDar || !selectedRec || cant <= 0) return;

        var tasa = (TASAS[selectedDar] && TASAS[selectedDar][selectedRec]) || 0;
        var ganancia = Math.floor(cant * tasa * COMERCIANTE_MULTI); {* 🆕 v2.5 — bonus Oficial Comerciante, igual que en ejecutarIntercambio *}
        if (ganancia <= 0) return;

        q('tot_dar').textContent = '-' + cant.toLocaleString() + ' ' + NOMBRES[selectedDar];
        q('tot_rec').textContent = '+' + ganancia.toLocaleString() + ' ' + NOMBRES[selectedRec];

        if (MO_ACTUAL >= COSTE_MO) {
            est.textContent = 'Pago con ' + COSTE_MO + ' MO';
            est.classList.add('ok');
            q('btn_submit').disabled = false;
        } else if (NTX_ACTUAL >= COSTE_NTX) {
            est.textContent = 'Fallback: ' + COSTE_NTX + ' ' + MONEDA;
            est.classList.add('fall');
            q('btn_submit').disabled = false;
        } else {
            est.textContent = 'Sin fondos (ni MO ni ' + MONEDA + ')';
            est.classList.add('error');
            q('btn_submit').disabled = true;
        }
    }

    function validate() {
        if (!selectedDar)      { alert('Selecciona el recurso a entregar'); return false; }
        if (!selectedRec)      { alert('Selecciona el recurso a recibir');  return false; }
        var cant = parseInt(q('inp_cantidad').value, 10) || 0;
        if (cant <= 0)         { alert('Ingresa una cantidad valida');      return false; }
        if (q('btn_submit').disabled) { alert('No puedes ejecutar el intercambio'); return false; }
        return true;
    }

    return {
        selectDar: selectDar,
        selectRecibir: selectRecibir,
        setMax: setMax,
        updateCalc: updateCalc,
        validate: validate
    };
})();

/* Preselección desde GET (flechas ⇄ del topnav) */
(function() {
    var preseleccion = '{$preseleccion_dar|default:""|escape:"javascript"}';
    if (!preseleccion) return;

    var selDar = document.getElementById('sel_dar');
    if (!selDar) return;

    var opcionExiste = false;
    for (var i = 0; i < selDar.options.length; i++) {
        if (selDar.options[i].value === preseleccion) {
            opcionExiste = true;
            break;
        }
    }

    if (!opcionExiste) return;

    selDar.value = preseleccion;

    if (typeof ResourceTrader !== 'undefined' && ResourceTrader.selectDar) {
        ResourceTrader.selectDar(preseleccion);
    }
})();
</script>

{/block}