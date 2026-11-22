{* ============================================================ *}
{* ASTROIO STATISTICS - PLAYER TABLE v2.5                       *}
{* ============================================================ *}
<table>
	<thead>
		<tr>
			<th style="width:60px;">{$LNG.st_position}</th>
			<th>{$LNG.st_player}</th>
			<th style="width:70px;">Enviar</th>
			<th>{$LNG.st_alliance}</th>
			<th style="width:110px;">{$LNG.st_points}</th>
		</tr>
	</thead>
	<tbody>
		{foreach name=RangeList item=RangeInfo from=$RangeList}
		<tr>
			{* Posición con tooltip de movimiento *}
			<td>
				<a class="tooltip" data-tooltip-content="{if $RangeInfo.ranking == 0}<span style='color:#87CEEB'>*</span>{elseif $RangeInfo.ranking < 0}<span style='color:red'>-{$RangeInfo.ranking}</span>{elseif $RangeInfo.ranking > 0}<span style='color:green'>+{$RangeInfo.ranking}</span>{/if}">{$RangeInfo.rank}</a>
			</td>

			{* Nombre del jugador con Letras (F) y (D) *}
			<td>
				<a href="#" onclick="return Dialog.Playercard({$RangeInfo.id}, '{$RangeInfo.name}');" class="rel_{$RangeInfo.relation|default:'default'}">{$RangeInfo.name}</a>
				
				{* 🔥 NUEVO: Añadir (F) si es Fuerte y (D) si es Débil *}
				{if $RangeInfo.relation == 'fuerte'}
					<span style="color: #ff4444; font-weight: bold; font-size: 11px; margin-left: 2px;">(F)</span>
				{elseif $RangeInfo.relation == 'debil'}
					<span style="color: #66ff99; font-weight: bold; font-size: 11px; margin-left: 2px;">(D)</span>
				{/if}
				{* FIN NUEVO *}

				{if isset($RangeInfo.is_vip) && $RangeInfo.is_vip}
					<span class="astrostat_vip_star tooltip" data-tooltip-content="<span style='color:#ffcc00;font-weight:bold;'>⭐ Jugador VIP</span><br><span style='color:#c8d6e5;font-size:11px;'>Suscripción activa</span>">⭐</span>
				{/if}
			</td>

			{* Botón de enviar mensaje ✉️ *}
			<td>
				{if $RangeInfo.id != $CUser_id}
					<a href="#" onclick="return Dialog.PM({$RangeInfo.id});" class="astrostat_pm_btn tooltip" data-tooltip-content="<span style='color:#00e0ff;font-weight:bold;'>✉️ Enviar mensaje</span><br><span style='color:#c8d6e5;font-size:11px;'>Escribir a {$RangeInfo.name}</span>">✉️</a>
				{/if}
			</td>

			{* Alianza *}
			<td>
				{if $RangeInfo.allyid != 0}
					<a href="game.php?page=alliance&amp;mode=info&amp;id={$RangeInfo.allyid}" 
					   style="color: {if $RangeInfo.allyid == $CUser_ally}#33ff88 !important; text-shadow: 0 0 6px rgba(51, 255, 136, 0.4);{else}#00e0ff !important;{/if} font-weight: bold; text-decoration: none;">
						{$RangeInfo.allyname}
					</a>
				{else}
					<span style="color:#7a8ba0; font-style:italic; font-size:10px;">Sin alianza</span>
				{/if}
			</td>

			{* Puntos *}
			<td>{$RangeInfo.points}</td>
		</tr>
		{/foreach}
	</tbody>
</table>