{* ============================================================ *}
{* ASTROIO STATISTICS - ALLIANCE TABLE v2.2                     *}
{* Tabla de alianzas con estructura <table>                     *}
{* ============================================================ *}
<table>
	<thead>
		<tr>
			<th style="width:60px;">{$LNG.st_position}</th>
			<th>{$LNG.st_alliance}</th>
			<th style="width:80px;">{$LNG.st_members}</th>
			<th style="width:110px;">{$LNG.st_points}</th>
			<th style="width:110px;">{$LNG.st_per_member}</th>
		</tr>
	</thead>
	<tbody>
		{foreach name=RangeList item=RangeInfo from=$RangeList}
		<tr>
			{* Posición con tooltip de movimiento *}
			<td>
				<a class="tooltip" data-tooltip-content="{if $RangeInfo.ranking == 0}<span style='color:#87CEEB'>*</span>{elseif $RangeInfo.ranking < 0}<span style='color:red'>{$RangeInfo.ranking}</span>{elseif $RangeInfo.ranking > 0}<span style='color:green'>+{$RangeInfo.ranking}</span>{/if}">{$RangeInfo.rank}</a>
			</td>

			{* Nombre de la alianza *}
			<td>
				<a href="game.php?page=alliance&amp;mode=info&amp;id={$RangeInfo.id}" target="ally"{if $RangeInfo.id == $CUser_ally} style="color:lime"{/if}>{$RangeInfo.name}</a>
			</td>

			{* Miembros *}
			<td>{$RangeInfo.members}</td>

			{* Puntos totales *}
			<td>{$RangeInfo.points}</td>

			{* Puntos por miembro *}
			<td>{$RangeInfo.mppoints}</td>
		</tr>
		{/foreach}
	</tbody>
</table>