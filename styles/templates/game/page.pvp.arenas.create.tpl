{block name="content"}

<style>
/* ═══════════════════════════════════════════════════════════
   PvP — Crear Arena
   AstroIO v3.1 — Doble Riel (NTX-20 / UNTX-20)
   Prefijo: .astropvp_

   FIX v3.1:
     - Badge de saldo del riel del jugador arriba
     - Límites del input en BASE NTX-20 (Helper valida base)
     - Hint "Tú pagas ≈ X {$moneda}" en vivo para QVAPAY
     - Labels con {$moneda} dinámica
     - CSS preservado 100% + estilos nuevos
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

/* ─── RESET GLOBAL ──────────────────────────────────────── */
.astropvp_create_wrap,
.astropvp_create_wrap *,
.astropvp_create_wrap *::before,
.astropvp_create_wrap *::after {
    box-sizing: border-box;
}

/* ─── WRAPPER ───────────────────────────────────────────── */
.astropvp_create_wrap {
    padding: 20px;
    color: #c8d6e5;
}

/* ─── TÍTULO ────────────────────────────────────────────── */
.astropvp_create_title {
    color: #ff6666;
    text-align: center;
    font-size: 24px;
    margin-bottom: 20px;
    text-shadow: 0 0 14px rgba(239, 68, 68, 0.6);
    letter-spacing: 1px;
}

/* ─── 🆕 BALANCE BADGE (riel del jugador) ───────────────── */
.astropvp_balance_box {
    max-width: 600px;
    margin: 0 auto 18px;
    text-align: center;
}

.astropvp_balance_badge {
    display: inline-block;
    padding: 8px 20px;
    border-radius: 10px;
    font-size: 13px;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(74, 255, 136, 0.5);
    background: linear-gradient(135deg, rgba(0, 200, 100, 0.15), rgba(0, 150, 255, 0.10));
    color: #cbd5e1;
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.4);
}

.astropvp_balance_badge b {
    color: #88ffbb;
    font-family: 'Courier New', monospace;
    font-weight: 800;
    letter-spacing: 0.5px;
    text-shadow: 0 0 10px rgba(74, 255, 136, 0.4);
}

.astropvp_balance_badge .moneda {
    color: #88ddff;
    font-weight: 700;
    letter-spacing: 0.5px;
}

/* ─── PANEL ─────────────────────────────────────────────── */
.astropvp_create_panel {
    max-width: 600px;
    margin: 0 auto;
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 2px solid rgba(255, 100, 100, 0.4);
    border-radius: 12px;
    padding: 25px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

/* ─── NTX DISPLAY ───────────────────────────────────────── */
.astropvp_create_ntx {
    text-align: center;
    color: #aabbcc;
    font-size: 13px;
    margin-bottom: 20px;
}
.astropvp_create_ntx b {
    color: #ffee88;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 8px rgba(251, 191, 36, 0.4);
}

/* ─── SECCIONES ─────────────────────────────────────────── */
.astropvp_create_section {
    margin-bottom: 20px;
}

.astropvp_create_label {
    display: block;
    color: #ff8888;
    font-size: 13px;
    font-weight: bold;
    margin-bottom: 10px;
}

/* ─── SELECTOR DE MODOS (radios) ────────────────────────── */
.astropvp_mode_grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 10px;
}

.astropvp_mode_option {
    padding: 12px;
    background: rgba(255, 100, 100, 0.08);
    border: 2px solid rgba(255, 100, 100, 0.4);
    border-radius: 8px;
    text-align: center;
    cursor: pointer;
    transition: 0.25s ease;
    display: block;
    min-width: 0;
}
.astropvp_mode_option:hover {
    background: rgba(255, 100, 100, 0.18);
    border-color: rgba(255, 100, 100, 0.7);
    transform: translateY(-2px);
    box-shadow: 0 4px 14px rgba(239, 68, 68, 0.3);
}
.astropvp_mode_option:has(input:checked) {
    background: rgba(255, 100, 100, 0.22);
    border-color: #ef4444;
    box-shadow: 0 0 16px rgba(239, 68, 68, 0.5), inset 0 0 12px rgba(239, 68, 68, 0.15);
}

.astropvp_mode_option input {
    display: none;
}

.astropvp_mode_name {
    font-size: 20px;
    font-weight: bold;
    color: #ff8888;
    text-shadow: 0 0 6px rgba(239, 68, 68, 0.4);
}

.astropvp_mode_hint {
    font-size: 11px;
    color: #aabbcc;
    margin-top: 2px;
}

/* ─── INPUT DE ENTRADA ──────────────────────────────────── */
.astropvp_fee_input {
    width: 100%;
    padding: 10px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(255, 100, 100, 0.4);
    border-radius: 8px;
    color: #ffffff;
    font-size: 14px;
    font-family: 'Courier New', monospace;
    font-weight: bold;
    outline: none;
    transition: 0.25s ease;
}
.astropvp_fee_input:focus {
    border-color: #ef4444;
    box-shadow: 0 0 12px rgba(239, 68, 68, 0.5);
    background: rgba(0, 0, 0, 0.65);
}

.astropvp_fee_hint {
    font-size: 11px;
    color: #8899aa;
    margin-top: 6px;
}

/* 🆕 Hint del pago real (solo QVAPAY) */
.astropvp_fee_real_hint {
    font-size: 12px;
    color: #88ddff;
    margin-top: 6px;
    font-weight: bold;
    text-shadow: 0 0 6px rgba(136, 221, 255, 0.3);
}

.astropvp_fee_real_hint b {
    color: #ffee88;
    font-family: 'Courier New', monospace;
    font-weight: 800;
    text-shadow: 0 0 8px rgba(251, 191, 36, 0.4);
}

/* ─── BOTONES DE ACCIÓN ─────────────────────────────────── */
.astropvp_create_actions {
    display: flex;
    gap: 10px;
    justify-content: center;
    flex-wrap: wrap;
}

.astropvp_btn_cancel {
    padding: 12px 30px;
    background: rgba(120, 120, 120, 0.3);
    color: #aabbcc;
    border: 1px solid rgba(120, 120, 120, 0.4);
    border-radius: 8px;
    font-size: 13px;
    font-weight: bold;
    text-decoration: none;
    transition: 0.25s ease;
    display: inline-block;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astropvp_btn_cancel:hover {
    background: rgba(120, 120, 120, 0.45);
    color: #ffffff;
    transform: translateY(-1px);
}

.astropvp_btn_submit {
    padding: 12px 30px;
    background: linear-gradient(135deg, #cc2222, #ff6666);
    color: #ffffff;
    border: 1px solid rgba(255, 100, 100, 0.7);
    border-radius: 8px;
    font-size: 13px;
    font-weight: bold;
    cursor: pointer;
    box-shadow: 0 4px 14px rgba(255, 50, 50, 0.5);
    transition: 0.25s ease;
    font-family: inherit;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astropvp_btn_submit:hover {
    background: linear-gradient(135deg, #ef4444, #ff8888);
    box-shadow: 0 6px 20px rgba(255, 50, 50, 0.7);
    transform: translateY(-2px);
}
.astropvp_btn_submit:active {
    transform: translateY(0);
}

/* ─── RESPONSIVE ────────────────────────────────────────── */
@media (max-width: 720px) {
    .astropvp_create_wrap {
        padding: 12px;
    }
    .astropvp_create_title {
        font-size: 18px;
    }
    .astropvp_create_panel {
        padding: 18px;
        max-width: 100%;
    }
    .astropvp_mode_grid {
        grid-template-columns: 1fr;
    }
    .astropvp_create_actions {
        flex-direction: column;
    }
    .astropvp_btn_cancel,
    .astropvp_btn_submit {
        width: 100%;
        text-align: center;
    }
    .astropvp_balance_badge {
        font-size: 12px;
        padding: 6px 14px;
    }
}
</style>

<div class="astropvp_create_wrap">
	<h1 class="astropvp_create_title">
		➕ Crear Arena
	</h1>

	{* 🆕 BADGE DE SALDO DEL RIEL DEL JUGADOR *}
	<div class="astropvp_balance_box">
		<span class="astropvp_balance_badge">
			💲 Tu saldo: <b>{$saldo_actual|number_format}</b>
			<span class="moneda">{$moneda}</span>
		</span>
	</div>

	<div class="astropvp_create_panel">

		<p class="astropvp_create_ntx">
			Saldo disponible: <b>{$my_ntx|number_format} {$moneda}</b>
		</p>

		<form method="POST" action="game.php?page=pvp&mode=createArena">

			{* SELECTOR DE MODO *}
			<div class="astropvp_create_section">
				<label class="astropvp_create_label">
					Modalidad
				</label>
				<div class="astropvp_mode_grid">

					<label class="astropvp_mode_option">
						<input type="radio" name="arena_mode" value="1v1" {if $selected_mode == '1v1'}checked{/if} onclick="updateFee('1v1')">
						<div class="astropvp_mode_name">1v1</div>
						<div class="astropvp_mode_hint">Tú defines</div>
					</label>

					<label class="astropvp_mode_option">
						<input type="radio" name="arena_mode" value="2v2" {if $selected_mode == '2v2'}checked{/if} onclick="updateFee('2v2')">
						<div class="astropvp_mode_name">2v2</div>
						<div class="astropvp_mode_hint">
							{$prices_base.2v2} base
							{if $es_internacional} (≈ {$prices.2v2} {$moneda}){/if}
						</div>
					</label>

					<label class="astropvp_mode_option">
						<input type="radio" name="arena_mode" value="3v3" {if $selected_mode == '3v3'}checked{/if} onclick="updateFee('3v3')">
						<div class="astropvp_mode_name">3v3</div>
						<div class="astropvp_mode_hint">
							{$prices_base.3v3} base
							{if $es_internacional} (≈ {$prices.3v3} {$moneda}){/if}
						</div>
					</label>

				</div>
			</div>

			{* PRECIO *}
			<div id="fee_block" class="astropvp_create_section">
				<label class="astropvp_create_label">
					Entrada (base NTX-20)
				</label>
				<input type="number" name="fee" id="fee_input" value="{$entry_fee}" min="{$prices_base.1v1_min}" max="{$prices_base.1v1_max}" step="1"
				       class="astropvp_fee_input">
				<div id="fee_hint" class="astropvp_fee_hint">
					Mínimo: {$prices_base.1v1_min} base · Máximo: {$prices_base.1v1_max} base
				</div>
				{if $es_internacional}
					<div id="fee_real_hint" class="astropvp_fee_real_hint">
						Tú pagas: ≈ <b>{$prices.1v1_min|number_format} {$moneda}</b>
					</div>
				{/if}
			</div>

			{* BOTONES *}
			<div class="astropvp_create_actions">
				<a href="game.php?page=pvp&mode=arenas" class="astropvp_btn_cancel">
					← Cancelar
				</a>
				<button type="submit" class="astropvp_btn_submit">
					⚔️ Crear arena
				</button>
			</div>

		</form>
	</div>
</div>

{literal}
<script type="text/javascript">
var PRICES_BASE = {
	'1v1_min': {/literal}{$prices_base.1v1_min}{literal},
	'1v1_max': {/literal}{$prices_base.1v1_max}{literal},
	'2v2': {/literal}{$prices_base.2v2}{literal},
	'3v3': {/literal}{$prices_base.3v3}{literal}
};

var MULTIPLIER = {/literal}{$multiplier}{literal};
var MONEDA     = "{/literal}{$moneda}{literal}";
var IS_INTL    = {/literal}{if $es_internacional}true{else}false{/if}{literal};

function updateFee(mode) {
	var feeBlock = document.getElementById('fee_block');
	var feeInput = document.getElementById('fee_input');
	var feeHint  = document.getElementById('fee_hint');

	if (mode === '1v1') {
		feeBlock.style.display = 'block';
		feeInput.value = PRICES_BASE['1v1_min'];
		feeInput.min = PRICES_BASE['1v1_min'];
		feeInput.max = PRICES_BASE['1v1_max'];
		feeHint.innerHTML = 'Mínimo: ' + PRICES_BASE['1v1_min'] + ' base · Máximo: ' + PRICES_BASE['1v1_max'] + ' base';
	} else if (mode === '2v2') {
		feeBlock.style.display = 'block';
		feeInput.value = PRICES_BASE['2v2'];
		feeInput.min = PRICES_BASE['2v2'];
		feeInput.max = PRICES_BASE['2v2'];
		feeHint.innerHTML = 'Precio fijo configurado por el admin.';
	} else if (mode === '3v3') {
		feeBlock.style.display = 'block';
		feeInput.value = PRICES_BASE['3v3'];
		feeInput.min = PRICES_BASE['3v3'];
		feeInput.max = PRICES_BASE['3v3'];
		feeHint.innerHTML = 'Precio fijo configurado por el admin.';
	}

	updateRealHint();
}

function updateRealHint() {
	if (!IS_INTL) return;
	var hint = document.getElementById('fee_real_hint');
	var input = document.getElementById('fee_input');
	if (!hint || !input) return;

	var base = parseInt(input.value) || 0;
	var real = base * MULTIPLIER;

	hint.innerHTML = 'Tú pagas: ≈ <b>' + real.toLocaleString('es-ES') + ' ' + MONEDA + '</b>';
}

document.addEventListener('DOMContentLoaded', function() {
	var input = document.getElementById('fee_input');
	if (input) {
		input.addEventListener('input', updateRealHint);
		updateRealHint();
	}
});
</script>
{/literal}
{/block}