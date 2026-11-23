{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/shared.statistics.playerTable.tpl === *}
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

				{* ✅ v6.0 — Bandera del país (users.country, ISO 3166-1 alpha-2).
				   Elige el país en el registro; sin país no se muestra nada. *}
				{if !empty($RangeInfo.country)}
					<img src="https://flagcdn.com/w20/{$RangeInfo.country|lower}.png" alt="{$RangeInfo.country}"
						 title="{$RangeInfo.country}" class="astrostat_flag"
						 style="width:20px;height:13px;vertical-align:middle;margin-left:4px;border-radius:2px;box-shadow:0 0 0 1px rgba(255,255,255,.15);">
				{/if}

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