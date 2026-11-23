{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/adm/marketAdminPage.tpl === *}
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
/* ===== FORZAR ANCHO COMPLETO ===== */
#content,
.content_page,
#main_content,
table.content,
div#content {
	width: 100% !important;
	max-width: 100% !important;
}

.astromkta_wrap {
	width: 100% !important;
	max-width: 100% !important;
	box-sizing: border-box !important;
	padding: 15px 20px !important;
	margin: 0 auto !important;
	color: #c8d6e5;
	font-family: 'Segoe UI', Roboto, sans-serif;
	font-size: 12px;
	display: block;
}

.astromkta_wrap * {
	box-sizing: border-box;
}

.astromkta_section {
	background: linear-gradient(180deg, #0f1624, #1a2332);
	border: 1px solid #1e2d44;
	border-radius: 10px;
	padding: 18px 20px;
	margin-bottom: 16px;
	box-shadow: 0 4px 14px rgba(0,0,0,0.4);
	width: 100%;
}

.astromkta_title {
	font-size: 13px;
	font-weight: 800;
	color: #00e0ff;
	text-transform: uppercase;
	letter-spacing: 1px;
	border-bottom: 1px solid #1e2d44;
	padding-bottom: 10px;
	margin-bottom: 16px;
}

/* ===== STATS ===== */
.astromkta_stats {
	display: grid;
	grid-template-columns: repeat(6, 1fr);
	gap: 14px;
	width: 100%;
}
.astromkta_stat {
	background: rgba(0, 0, 0, 0.3);
	border: 1px solid #1e2d44;
	border-radius: 8px;
	padding: 16px 12px;
	text-align: center;
	display: flex;
	flex-direction: column;
	justify-content: center;
	align-items: center;
	min-height: 80px;
}
.astromkta_stat .label {
	font-size: 10px;
	color: #7a8ba3;
	text-transform: uppercase;
	letter-spacing: 0.5px;
	margin-bottom: 6px;
	line-height: 1.2;
}
.astromkta_stat .value {
	font-size: 24px;
	font-weight: 800;
	color: #ffaa33;
	font-family: 'Courier New', monospace;
	line-height: 1;
}
.astromkta_stat .value.cyan  { color: #00e0ff; }
.astromkta_stat .value.pink  { color: #ff4488; }
.astromkta_stat .value.green { color: #66ff99; }

/* v2.2 — Stats de auto-cancelaciones */
.astromkta_stat .value.warn   { color: #ffcc33; }
.astromkta_stat .value.danger { color: #ff6644; }
.astromkta_stat.auto-warn   { border-color: rgba(255, 204, 51, 0.35); background: rgba(255, 204, 51, 0.05); }
.astromkta_stat.auto-danger { border-color: rgba(255, 102, 68, 0.35); background: rgba(255, 102, 68, 0.05); }

/* ===== FONDO ===== */
.astromkta_fund_top {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 14px;
	flex-wrap: wrap;
	gap: 12px;
}
.astromkta_fund_amount {
	font-size: 26px;
	color: #ffaa33;
	font-weight: 800;
	font-family: 'Courier New', monospace;
	line-height: 1;
}
.astromkta_fund_grid {
	display: grid;
	grid-template-columns: repeat(3, 1fr);
	gap: 14px;
	width: 100%;
}
.astromkta_fund_item {
	background: rgba(0, 0, 0, 0.3);
	border-left: 3px solid #00ccff;
	border-radius: 6px;
	padding: 12px 16px;
}
.astromkta_fund_item .label {
	color: #7a8ba3;
	font-size: 10px;
	text-transform: uppercase;
	letter-spacing: 0.5px;
	margin-bottom: 5px;
}
.astromkta_fund_item .value {
	color: #00e0ff;
	font-weight: 800;
	font-family: 'Courier New', monospace;
	font-size: 16px;
	line-height: 1;
}

/* ===== FORM ===== */
.astromkta_form_row {
	display: grid;
	grid-template-columns: 2.5fr 1fr 1fr 1fr auto;
	gap: 14px;
	align-items: end;
	width: 100%;
}
.astromkta_field {
	display: flex;
	flex-direction: column;
	width: 100%;
}
.astromkta_field label {
	display: block;
	font-size: 10px;
	color: #7a8ba3;
	text-transform: uppercase;
	letter-spacing: 0.5px;
	margin-bottom: 6px;
	font-weight: 600;
}
.astromkta_input,
.astromkta_select {
	width: 100%;
	padding: 10px 14px;
	background: #0b1220;
	border: 1px solid #1e2d44;
	border-radius: 6px;
	color: #c8d6e5;
	font-size: 12px;
	outline: none;
}
.astromkta_input:focus,
.astromkta_select:focus {
	border-color: #00ccff;
	box-shadow: 0 0 8px rgba(0,224,255,0.3);
}
.astromkta_btn {
	padding: 10px 20px;
	background: linear-gradient(135deg, #dd8800, #ffaa33);
	border: none;
	border-radius: 6px;
	color: #1a1000;
	font-weight: 800;
	font-size: 11px;
	text-transform: uppercase;
	cursor: pointer;
	transition: all 0.2s ease;
	white-space: nowrap;
}
.astromkta_btn:hover {
	box-shadow: 0 0 14px rgba(255,170,51,0.6);
	transform: translateY(-1px);
}
.astromkta_btn.danger {
	background: linear-gradient(135deg, #aa0044, #ff4488);
	color: #fff;
}
.astromkta_btn.cyan {
	background: linear-gradient(135deg, #0066cc, #00ccff);
	color: #fff;
}

/* ===== TABLA ===== */
.astromkta_table {
	width: 100%;
	border-collapse: collapse;
	margin-top: 10px;
}
.astromkta_table th {
	background: linear-gradient(135deg, #004488, #0077cc);
	color: #fff;
	padding: 12px 14px;
	text-align: left;
	font-size: 10px;
	text-transform: uppercase;
	letter-spacing: 0.5px;
	border-bottom: 1px solid #00ccff;
}
.astromkta_table td {
	padding: 12px 14px;
	border-bottom: 1px solid #1e2d44;
	font-size: 11px;
	color: #c8d6e5;
}
.astromkta_table tr:hover td {
	background: rgba(0, 200, 255, 0.05);
}
.astromkta_table .img_cell {
	width: 60px;
}
.astromkta_table .img_cell img {
	max-width: 32px;
	max-height: 32px;
}
.astromkta_badge {
	display: inline-block;
	padding: 3px 10px;
	border-radius: 5px;
	font-size: 9px;
	font-weight: 700;
	text-transform: uppercase;
}
.astromkta_badge.active    { background: rgba(102,255,153,0.15); color: #66ff99; }
.astromkta_badge.sold      { background: rgba(0,204,255,0.15);   color: #00ccff; }
.astromkta_badge.expired   { background: rgba(255,68,136,0.15);  color: #ff4488; }
.astromkta_badge.cancelled { background: rgba(90,106,128,0.2);   color: #7a8ba3; }

/* v2.2 — Badges para auto-cancelaciones */
.astromkta_badge.warn      { background: rgba(255,204,51,0.15);  color: #ffcc33; }
.astromkta_badge.danger    { background: rgba(255,102,68,0.15);  color: #ff6644; }

/* v2.2 — Texto de motivo en tabla */
.astromkta_reason {
	font-size: 10px;
	color: #ffcc33;
	font-weight: 600;
	line-height: 1.4;
}
.astromkta_reason.seller_attack { color: #ff6644; }
.astromkta_reason.buyer_no_ntx  { color: #ffcc33; }

/* v2.2 — Sección auto-canceladas */
.astromkta_autocancel_section .astromkta_title {
	color: #ffcc33;
	border-bottom-color: rgba(255, 204, 51, 0.35);
}
.astromkta_autocancel_section {
	border-color: rgba(255, 204, 51, 0.25);
	background: linear-gradient(180deg, rgba(45, 30, 10, 0.5), rgba(30, 20, 8, 0.5));
}

/* ===== FEEDBACK ===== */
.astromkta_feedback {
	padding: 12px 16px;
	border-radius: 8px;
	margin-bottom: 16px;
	font-weight: 600;
	font-size: 12px;
}
.astromkta_feedback.ok {
	background: rgba(102,255,153,0.12);
	border: 1px solid rgba(102,255,153,0.4);
	color: #66ff99;
}
.astromkta_feedback.err {
	background: rgba(255,68,136,0.12);
	border: 1px solid rgba(255,68,136,0.4);
	color: #ff4488;
}

.astromkta_empty {
	padding: 40px 20px;
	text-align: center;
	color: #5a6a80;
	background: rgba(0,0,0,0.2);
	border-radius: 8px;
	font-size: 12px;
}

/* ===== RESPONSIVE ===== */
@media (max-width: 1300px) {
	.astromkta_stats { grid-template-columns: repeat(3, 1fr); }
}
@media (max-width: 1100px) {
	.astromkta_stats    { grid-template-columns: repeat(2, 1fr); }
	.astromkta_form_row { grid-template-columns: 1fr 1fr; }
}
@media (max-width: 700px) {
	.astromkta_stats    { grid-template-columns: 1fr; }
	.astromkta_fund_grid { grid-template-columns: 1fr; }
	.astromkta_form_row { grid-template-columns: 1fr; }
}
</style>

<div class="astromkta_wrap">

	<h2 style="color:#00e0ff; font-size:18px; margin:0 0 18px 0; font-weight:800;">
		🛒 Panel de Administración del Mercado
	</h2>

	{* ===== FEEDBACK ===== *}
	{if $message}
		<div class="astromkta_feedback {if $msgType == 'error'}err{else}ok{/if}">
			{if $msgType == 'error'}⚠️{else}✅{/if} {$message}
		</div>
	{/if}

	{* ===== ESTADÍSTICAS ===== *}
	<div class="astromkta_section">
		<div class="astromkta_title">📊 Estadísticas Generales</div>
		<div class="astromkta_stats">
			<div class="astromkta_stat">
				<div class="label">Ofertas activas</div>
				<div class="value cyan">{$stats.active_offers}</div>
			</div>
			<div class="astromkta_stat">
				<div class="label">Ofertas vendidas</div>
				<div class="value green">{$stats.sold_offers}</div>
			</div>
			<div class="astromkta_stat">
				<div class="label">Ofertas admin</div>
				<div class="value">{$stats.admin_offers}</div>
			</div>
			<div class="astromkta_stat">
				<div class="label">Operaciones totales</div>
				<div class="value cyan">{$stats.total_logs}</div>
			</div>
			<div class="astromkta_stat auto-danger">
				<div class="label">⚠️ Auto-cancel. ataque</div>
				<div class="value danger">{$autocancel_stats.seller_no_resources}</div>
			</div>
			<div class="astromkta_stat auto-warn">
				<div class="label">⚠️ Auto-cancel. sin NTX</div>
				<div class="value warn">{$autocancel_stats.buyer_no_ntx}</div>
			</div>
		</div>
	</div>

	{* ===== FONDO DEL PROYECTO ===== *}
	<div class="astromkta_section">
		<div class="astromkta_title">💰 Fondo del Proyecto</div>

		<div class="astromkta_fund_top">
			<div class="astromkta_fund_amount">
				{$fund_total} NTX-20
			</div>
			<a href="admin.php?page=market&mode=clear"
			   class="astromkta_btn danger"
			   onclick="return confirm('¿Vaciar el fondo? Esta acción es irreversible.');">
				🗑️ Vaciar Fondo
			</a>
		</div>

		<div class="astromkta_fund_grid">
			<div class="astromkta_fund_item">
				<div class="label">De vendedores</div>
				<div class="value">{$fund_seller}</div>
			</div>
			<div class="astromkta_fund_item">
				<div class="label">De compradores</div>
				<div class="value">{$fund_buyer}</div>
			</div>
			<div class="astromkta_fund_item">
				<div class="label">De admin</div>
				<div class="value">0</div>
			</div>
		</div>
	</div>

	{* ===== CREAR OFERTA ADMIN ===== *}
	<div class="astromkta_section">
		<div class="astromkta_title">🛡️ Crear Oferta Oficial (Admin)</div>

		<form method="post" action="admin.php?page=market&mode=create" id="astromktaForm">

			<input type="hidden" name="item_type" id="admItemType" value="metal">
			<input type="hidden" name="item_id"   id="admItemId"   value="0">

			<div class="astromkta_form_row">

				<div class="astromkta_field">
					<label>Ítem</label>
					<select id="admItem" class="astromkta_select">
						{foreach $items as $it}
							<option value="{$it.type}|{$it.id}">
								{$it.name} ({$it.type})
							</option>
						{/foreach}
					</select>
				</div>

				<div class="astromkta_field">
					<label>Cantidad</label>
					<input type="number" name="amount" min="1" value="1" class="astromkta_input">
				</div>

				<div class="astromkta_field">
					<label>Precio (NTX-20)</label>
					<input type="number" name="price_ntx" min="1" value="1" class="astromkta_input">
				</div>

				<div class="astromkta_field">
					<label>Duración</label>
					<input type="text" value="∞ No expira" class="astromkta_input" disabled>
				</div>

				<div class="astromkta_field">
					<button type="submit" class="astromkta_btn">✅ Crear</button>
				</div>

			</div>

			<div style="margin-top:12px; font-size:10px; color:#7a8ba3;">
				💡 Las ofertas de admin NO pagan comisión, NO expiran, y NO aplican la regla del precio mínimo.
			</div>
		</form>
	</div>

	{* ===== LISTA DE OFERTAS ADMIN ===== *}
	<div class="astromkta_section">
		<div class="astromkta_title">📋 Ofertas de Admin</div>

		{if $admin_offers|@count > 0}
		<table class="astromkta_table">
			<thead>
				<tr>
					<th class="img_cell">Img</th>
					<th>Ítem</th>
					<th>Cantidad</th>
					<th>Precio</th>
					<th>Fecha</th>
					<th>Estado</th>
					<th>Motivo</th>
					<th>Acción</th>
				</tr>
			</thead>
			<tbody>
				{foreach $admin_offers as $o}
				<tr>
					<td class="img_cell"><img src="{$o.image}"></td>
					<td>
						<b>{$o.item_name}</b><br>
						<small style="color:#7a8ba3;">{$o.category}</small>
					</td>
					<td style="color:#ffaa33; font-family:'Courier New', monospace; font-weight:700;">
						x{$o.amount_fmt}
					</td>
					<td style="color:#ffaa33; font-family:'Courier New', monospace; font-weight:700;">
						{$o.price_fmt} NTX
					</td>
					<td style="color:#7a8ba3;">{$o.date}</td>
					<td><span class="astromkta_badge {$o.status}">{$o.status}</span></td>
					<td>
						{if $o.cancel_reason_label}
							<span class="astromkta_reason">{$o.cancel_reason_label}</span>
						{else}
							<span style="color:#5a6a80;">—</span>
						{/if}
					</td>
					<td>
						{if $o.status == 'active'}
							<a href="admin.php?page=market&mode=delete&id={$o.offer_id}"
							   class="astromkta_btn danger"
							   style="padding:6px 12px; font-size:10px;"
							   onclick="return confirm('¿Eliminar esta oferta de admin?');">
								❌
							</a>
						{else}
							—
						{/if}
					</td>
				</tr>
				{/foreach}
			</tbody>
		</table>
		{else}
			<div class="astromkta_empty">No hay ofertas de admin creadas</div>
		{/if}
	</div>

	{* ============================================================
	   v2.2 — OFERTAS AUTO-CANCELADAS
	   ------------------------------------------------------------
	   Muestra las ofertas que el cron canceló automáticamente
	   porque el vendedor ya no tenía los items (probable ataque)
	   o porque el comprador ya no tenía el NTX-20.
	   ============================================================ *}
	<div class="astromkta_section astromkta_autocancel_section">
		<div class="astromkta_title">
			🚨 Ofertas Auto-canceladas
			{if $has_auto_cancelled}
				<span style="color:#ffcc33; font-weight:600; font-size:11px; margin-left:10px; text-transform:none;">
					(Total: {$autocancel_stats.total})
				</span>
			{/if}
		</div>

		{if $has_auto_cancelled}
			<div style="display:flex; justify-content:flex-end; margin-bottom:12px;">
				<a href="admin.php?page=market&mode=cleanup_autocancelled"
				   class="astromkta_btn danger"
				   style="padding:8px 16px; font-size:10px;"
				   onclick="return confirm('¿Borrar TODAS las ofertas auto-canceladas del histórico? Esta acción es irreversible.');">
					🧹 Limpiar histórico
				</a>
			</div>

			<table class="astromkta_table">
				<thead>
					<tr>
						<th class="img_cell">Img</th>
						<th>Ítem</th>
						<th>Vendedor</th>
						<th>Cantidad</th>
						<th>Precio</th>
						<th>Fecha</th>
						<th>Motivo</th>
					</tr>
				</thead>
				<tbody>
					{foreach $auto_cancelled_offers as $ac}
					<tr>
						<td class="img_cell"><img src="{$ac.image}"></td>
						<td>
							<b>{$ac.item_name}</b><br>
							<small style="color:#7a8ba3;">{$ac.category}</small>
						</td>
						<td style="color:#00e0ff; font-weight:600;">
							{$ac.seller_name|default:'—'}
						</td>
						<td style="color:#ffaa33; font-family:'Courier New', monospace; font-weight:700;">
							x{$ac.amount_fmt}
						</td>
						<td style="color:#ffaa33; font-family:'Courier New', monospace; font-weight:700;">
							{$ac.price_fmt} NTX
						</td>
						<td style="color:#7a8ba3;">{$ac.date}</td>
						<td>
							{if $ac.is_seller_attack}
								<span class="astromkta_badge danger">⚠️ Vendedor atacado</span>
								<div class="astromkta_reason seller_attack">
									{$ac.cancel_reason_label}
								</div>
							{else}
								<span class="astromkta_badge warn">⚠️ Buyer sin NTX</span>
								<div class="astromkta_reason buyer_no_ntx">
									{$ac.cancel_reason_label}
								</div>
							{/if}
						</td>
					</tr>
					{/foreach}
				</tbody>
			</table>
		{else}
			<div class="astromkta_empty">
				✅ No hay ofertas auto-canceladas en el histórico.<br>
				<span style="font-size:10px; color:#5a6a80; margin-top:6px; display:inline-block;">
					Esto significa que ninguna oferta se rompió por ataque al vendedor o por falta de NTX del comprador.
				</span>
			</div>
		{/if}
	</div>

</div>

<script>
/* ===== Sincronizar select → hiddens ===== */
document.addEventListener('DOMContentLoaded', function() {
	var sel        = document.getElementById('admItem');
	var hiddenType = document.getElementById('admItemType');
	var hiddenId   = document.getElementById('admItemId');

	if (!sel) return;

	function syncIds() {
		var parts = sel.value.split('|');
		if (hiddenType) hiddenType.value = parts[0] || 'metal';
		if (hiddenId)   hiddenId.value   = parts[1] || '0';
	}

	sel.addEventListener('change', syncIds);
	syncIds();
});
</script>

{include file="overall_footer.tpl"}