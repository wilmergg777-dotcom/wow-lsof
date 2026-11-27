{include file="overall_header.tpl"}

{* ══════════════════════════════════════════════════════════════
   ASTROIO — MultiIPs con botón de BANEO rápido
   Nueva columna "Acciones" con botón rojo al Panel de Sanciones
   ══════════════════════════════════════════════════════════════ *}

<style>
/* ═══ Botón de banear (rojo pulsante) ═══ */
.astroban_btn {
	display: inline-block;
	background: linear-gradient(135deg, rgba(180, 0, 0, 0.95), rgba(255, 40, 40, 0.95)) !important;
	backdrop-filter: blur(4px);
	-webkit-backdrop-filter: blur(4px);
	border: 1px solid rgba(255, 100, 100, 0.7) !important;
	border-radius: 6px !important;
	color: #ffffff !important;
	padding: 5px 12px !important;
	font-weight: 800 !important;
	font-size: 10px !important;
	text-decoration: none !important;
	text-transform: uppercase !important;
	letter-spacing: 0.7px !important;
	text-shadow: 0 1px 3px rgba(0, 0, 0, 0.7);
	transition: 0.25s ease !important;
	white-space: nowrap;
	cursor: pointer;
	box-shadow: 0 0 10px rgba(255, 50, 50, 0.5);
}
.astroban_btn:hover {
	background: linear-gradient(135deg, rgba(255, 40, 40, 0.98), rgba(255, 80, 80, 0.98)) !important;
	box-shadow: 0 0 18px rgba(255, 50, 50, 0.9), 0 2px 8px rgba(0, 0, 0, 0.6) !important;
	color: #ffffff !important;
	transform: translateY(-1px) scale(1.03);
	text-decoration: none !important;
}
</style>

<table style="width:960px">
	<tr>
		<th>{$LNG.mip_ip}</th>
		<th>{$LNG.se_id_owner}</th>
		<th>{$LNG.se_name}</th>
		<th>{$LNG.se_email}</th>
		<th>{$LNG.ac_register_time}</th>
		<th>{$LNG.ac_act_time}</th>
		<th>{$LNG.mip_known}</th>
		<th>Acciones</th>
	</tr>
	{foreach $multiGroups as $IP => $Users}
	<tr>
		<td rowspan="{count($Users)}">{$IP}</td>
		{foreach $Users as $ID => $User}
		<td class="left" style="padding:3px;">{$ID}</td>
		<td class="left" style="padding:3px;"><a href="admin.php?page=accountdata&id_u={$ID}">{$User.username} (?)</a></td>
		<td class="left" style="padding:3px;">{$User.email}</td>
		<td class="left" style="padding:3px;">{$User.register_time}</td>
		<td class="left" style="padding:3px;">{$User.onlinetime}</td>
		<td class="center" style="padding:3px;">{if ($User.isKnown != 0)}<a href="admin.php?page=multiips&amp;action=unknown&amp;id={$ID}"><img src="styles/resource/images/true.png"></a>{else}<a href="admin.php?page=multiips&amp;action=known&amp;id={$ID}"><img src="styles/resource/images/false.png"></a>{/if}</td>
		<td class="center" style="padding:3px;">
			<a href="admin.php?page=bans&amp;ban_user={$User.username|escape:'url'}&amp;ban_id={$ID}"
			   class="astroban_btn"
			   title="Ir al Panel de Sanciones con {$User.username} pre-seleccionado">
				🔨 BANEAR
			</a>
		</td>
		</tr>{if !$User@last}<tr>{/if}
		{/foreach}
	{/foreach}
</table>

{include file="overall_footer.tpl"}