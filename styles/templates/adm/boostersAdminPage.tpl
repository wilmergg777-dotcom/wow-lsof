{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/adm/boostersAdminPage.tpl === *}
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

<style>
.boa_wrap {
	max-width: 900px;
	margin: 20px auto;
	padding: 20px;
	color: #c8d6e5;
	font-family: 'Segoe UI', Roboto, sans-serif;
}

.boa_title {
	font-size: 22px;
	color: #00e0ff;
	text-shadow: 0 0 12px rgba(0,224,255,0.6);
	margin-bottom: 6px;
	letter-spacing: 1px;
}

.boa_subtitle {
	font-size: 12px;
	color: #7a8ba3;
	margin-bottom: 20px;
}

.boa_msg {
	padding: 14px 18px;
	border-radius: 10px;
	margin-bottom: 20px;
	font-size: 13px;
	border-left: 4px solid;
	line-height: 1.5;
}
.boa_msg.success {
	background: linear-gradient(135deg, #0a2a1a, #0f3d24);
	border-color: #66ff99;
	color: #66ff99;
}
.boa_msg.error {
	background: linear-gradient(135deg, #2a0a14, #3d0f1e);
	border-color: #ff4488;
	color: #ff4488;
}
.boa_msg.info {
	background: linear-gradient(135deg, #0a1a2a, #0f243d);
	border-color: #00ccff;
	color: #00ccff;
}

.boa_form {
	background: linear-gradient(135deg, #0f1624, #1a2332);
	border: 1px solid rgba(0,204,255,0.25);
	border-radius: 12px;
	padding: 20px;
	box-shadow: 0 8px 24px rgba(0,0,0,0.4);
}

.boa_field {
	margin-bottom: 20px;
}

.boa_label {
	display: block;
	font-size: 12px;
	color: #00ccff;
	font-weight: 700;
	text-transform: uppercase;
	letter-spacing: 1px;
	margin-bottom: 8px;
}

.boa_select,
.boa_input {
	width: 100%;
	max-width: 400px;
	background: rgba(0,0,0,0.4);
	border: 1px solid rgba(0,204,255,0.4);
	border-radius: 6px;
	color: #00e0ff;
	padding: 8px 12px;
	font-size: 13px;
	font-family: 'Courier New', monospace;
	box-sizing: border-box;
}
.boa_select:focus,
.boa_input:focus {
	outline: none;
	border-color: #00e0ff;
	box-shadow: 0 0 12px rgba(0,224,255,0.5);
}

.boa_grid {
	display: grid;
	grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
	gap: 10px;
}

.boa_card {
	background: linear-gradient(135deg, #0a1a2a, #0f243d);
	border: 2px solid rgba(0,204,255,0.2);
	border-radius: 8px;
	padding: 12px;
	cursor: pointer;
	transition: all 0.25s ease;
	display: flex;
	align-items: center;
	gap: 10px;
	user-select: none;
}
.boa_card:hover {
	border-color: #00e0ff;
	box-shadow: 0 0 16px rgba(0,224,255,0.3);
	transform: translateY(-2px);
}
.boa_card.selected {
	background: linear-gradient(135deg, #123045, #1a4050);
	border-color: #00e0ff;
	box-shadow: 0 0 20px rgba(0,224,255,0.5);
}

.boa_card_icon {
	font-size: 24px;
	flex-shrink: 0;
}

.boa_card_info {
	flex: 1;
	min-width: 0;
}

.boa_card_name {
	font-size: 12px;
	font-weight: 700;
	color: #00e0ff;
	margin-bottom: 2px;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
}

.boa_card_desc {
	font-size: 10px;
	color: #7a8ba3;
	line-height: 1.3;
}

.boa_card_check {
	width: 18px;
	height: 18px;
	flex-shrink: 0;
	border: 2px solid rgba(0,204,255,0.5);
	border-radius: 4px;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 12px;
	color: #00e0ff;
	transition: all 0.2s ease;
}
.boa_card.selected .boa_card_check {
	background: linear-gradient(135deg, #0066cc, #00ccff);
	border-color: #00e0ff;
	color: #fff;
}

.boa_submit {
	margin-top: 20px;
	padding: 12px 40px;
	background: linear-gradient(135deg, #0066cc, #0099ff);
	color: #fff;
	border: none;
	border-radius: 8px;
	font-size: 14px;
	font-weight: 700;
	letter-spacing: 1.5px;
	cursor: pointer;
	text-transform: uppercase;
	transition: all 0.25s ease;
}
.boa_submit:hover {
	background: linear-gradient(135deg, #0099ff, #00ccff);
	box-shadow: 0 0 24px rgba(0,224,255,0.6);
	transform: translateY(-2px);
}
.boa_submit:disabled {
	opacity: 0.4;
	cursor: not-allowed;
	background: linear-gradient(135deg, #333, #555);
}

.boa_wrap ::-webkit-scrollbar { width: 6px; height: 6px; }
.boa_wrap ::-webkit-scrollbar-track { background: rgba(0,0,0,0.3); border-radius: 3px; }
.boa_wrap ::-webkit-scrollbar-thumb { background: linear-gradient(180deg, #0066cc, #00ccff); border-radius: 3px; }
</style>

<div class="boa_wrap">

	<div class="boa_title">⚡ Regalar Potenciadores</div>
	<div class="boa_subtitle">Da uno o varios potenciadores a un jugador o a TODOS los jugadores.</div>

	{if $message}
		<div class="boa_msg {$msgType}">{$message}</div>
	{/if}

	<form method="post" action="" class="boa_form" id="boa_form">
		<input type="hidden" name="action" value="send">

		{* ============ SELECTOR DE JUGADOR ============ *}
		<div class="boa_field">
			<label class="boa_label">👤 Destinatario</label>
			<select name="user_id" class="boa_select" required>
				<option value="-1">🌟 TODOS LOS JUGADORES</option>
				<option value="0" disabled>-- Elegir jugador específico --</option>
				{foreach $users as $user}
					<option value="{$user.id}">{$user.username} (ID: {$user.id})</option>
				{/foreach}
			</select>
		</div>

		{* ============ SELECTOR DE POTENCIADORES ============ *}
		<div class="boa_field">
			<label class="boa_label">🎁 Potenciadores a Regalar</label>
			<div class="boa_grid">
				{foreach $boosters as $booster}
				<div class="boa_card" data-id="{$booster.booster_id}" onclick="boa_toggle(this)">
					<div class="boa_card_icon">{$booster.icon_emoji}</div>
					<div class="boa_card_info">
						<div class="boa_card_name">{$booster.booster_name}</div>
						<div class="boa_card_desc">+{$booster.booster_value}% bono</div>
					</div>
					<div class="boa_card_check">✓</div>
					<input type="checkbox" name="boosters[]" value="{$booster.booster_id}" style="display:none;">
				</div>
				{foreachelse}
					<div style="color:#ff4488;">⚠️ No hay potenciadores configurados en la BD</div>
				{/foreach}
			</div>
		</div>

		{* ============ DURACIÓN ============ *}
		<div class="boa_field">
			<label class="boa_label">⏰ Duración (en horas)</label>
			<input type="number" name="hours" class="boa_input" value="24" min="1" max="720" required>
			<div style="font-size:11px;color:#7a8ba3;margin-top:4px;">
				(1 = 1 hora · 24 = 1 día · 168 = 1 semana · máx 720 = 30 días)
			</div>
		</div>

		{* ============ BOTÓN ============ *}
		<div style="text-align:center;">
			<button type="submit" class="boa_submit">🎁 Enviar Potenciadores</button>
		</div>
	</form>

</div>

<script>
function boa_toggle(card) {
	card.classList.toggle('selected');
	var checkbox = card.querySelector('input[type="checkbox"]');
	checkbox.checked = !checkbox.checked;
}
</script>

{include file="overall_footer.tpl"}