{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/shared.mission.spyReport.tpl === *}
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

<div class="spyRaport">
	<div class="spyRaportHead">
		<a href="game.php?page=galaxy&amp;galaxy={$targetPlanet.galaxy}&amp;system={$targetPlanet.system}">{$title}</a>
	</div>

	<!-- 🌦️ BLOQUE DE CLIMA ASTROIO -->
	{if isset($climaActual) && $climaActual}
	<div class="spyRaportContainer" style="margin-top: 10px; border: 1px solid #4a9eff; background-color: #1a2332; padding: 10px; border-radius: 4px;">
		<div class="spyRaportContainerHead" style="background-color: #2a3a52; color: #4a9eff; padding: 5px; font-weight: bold; border-radius: 3px; margin-bottom: 8px;">
			🌦️ CLIMA DEL PLANETA
		</div>
		<div style="padding: 5px; color: #ddd; font-size: 12px;">
			<b>Actual:</b> 
			{if $climaActual.clave == 'despejado'}☀️ Cielo Despejado
			{elseif $climaActual.clave == 'brisa_solar'}🌤️ Brisa Solar
			{elseif $climaActual.clave == 'viento_estelar'}🍃 Viento Estelar Suave
			{elseif $climaActual.clave == 'cristalino'}✨ Cielo Cristalino
			{elseif $climaActual.clave == 'niebla'}🌫️ Niebla Densísima
			{elseif $climaActual.clave == 'tormenta_solar'}⚡ Tormenta Solar
			{elseif $climaActual.clave == 'meteoros'}☄️ Lluvia de Meteoros
			{elseif $climaActual.clave == 'nebulosa'}💰 Nebulosa Mineral
			{elseif $climaActual.clave == 'plasma'}🌌 Nube de Plasma
			{elseif $climaActual.clave == 'eclipse'}🌓 Eclipse Solar
			{elseif $climaActual.clave == 'campo_mag'}🌀 Campo Magnético
			{elseif $climaActual.clave == 'aurora'}🌈 Aurora Cósmica
			{elseif $climaActual.clave == 'agujero'}🕳️ Agujero de Gusano
			{elseif $climaActual.clave == 'singularidad'}⚫ Singularidad
			{/if}
			<br>
			<span style="font-size: 11px; color: #9ca3af;"><i>"{$climaActual.descripcion}"</i></span><br>
			
			<b>Ataque:</b> {if $climaActual.factor_ataque > 1}+{/if}{math equation="round((x-1)*100)" x=$climaActual.factor_ataque format="%d"}% | 
			<b>Defensa:</b> {if $climaActual.factor_defensa > 1}+{/if}{math equation="round((x-1)*100)" x=$climaActual.factor_defensa format="%d"}% | 
			<b>Bajas:</b> {if $climaActual.factor_bajas > 1}+{/if}{math equation="round((x-1)*100)" x=$climaActual.factor_bajas format="%d"}% | 
			<b>Botín:</b> {if $climaActual.factor_botin > 1}+{/if}{math equation="round((x-1)*100)" x=$climaActual.factor_botin format="%d"}%
			
			{if isset($climaPrevisto) && $climaPrevisto}
			<div style="margin-top: 8px; border-top: 1px dashed #4a9eff; padding-top: 8px;">
				<b>Mañana:</b> 
				{if $climaPrevisto.clave == 'despejado'}☀️ Cielo Despejado
				{elseif $climaPrevisto.clave == 'brisa_solar'}🌤️ Brisa Solar
				{elseif $climaPrevisto.clave == 'viento_estelar'}🍃 Viento Estelar Suave
				{elseif $climaPrevisto.clave == 'cristalino'}✨ Cielo Cristalino
				{elseif $climaPrevisto.clave == 'niebla'}🌫️ Niebla Densísima
				{elseif $climaPrevisto.clave == 'tormenta_solar'}⚡ Tormenta Solar
				{elseif $climaPrevisto.clave == 'meteoros'}☄️ Lluvia de Meteoros
				{elseif $climaPrevisto.clave == 'nebulosa'}💰 Nebulosa Mineral
				{elseif $climaPrevisto.clave == 'plasma'}🌌 Nube de Plasma
				{elseif $climaPrevisto.clave == 'eclipse'}🌓 Eclipse Solar
				{elseif $climaPrevisto.clave == 'campo_mag'}🌀 Campo Magnético
				{elseif $climaPrevisto.clave == 'aurora'}🌈 Aurora Cósmica
				{elseif $climaPrevisto.clave == 'agujero'}🕳️ Agujero de Gusano
				{elseif $climaPrevisto.clave == 'singularidad'}⚫ Singularidad
				{/if}
				<br>
				<span style="font-size: 11px; color: #9ca3af;"><i>"{$climaPrevisto.descripcion}"</i></span>
			</div>
			{/if}
		</div>
	</div>
	{/if}
	<!-- FIN BLOQUE DE CLIMA -->

	{foreach $spyData as $Class => $elementIDs}
	<div class="spyRaportContainer">
	<div class="spyRaportContainerHead spyRaportContainerHeadClass{$Class}">{$LNG.tech.$Class}</div>
	{foreach $elementIDs as $elementID => $amount}
	{if ($amount@iteration % 2) === 1}<div class="spyRaportContainerRow clearfix">{/if}
		<div class="spyRaportContainerCell">{$LNG.tech.$elementID}</div>
		<div class="spyRaportContainerCell">{$amount|number}</div>
	{if ($amount@iteration % 2) === 0}</div>{/if}
	{/foreach}
	</div>
	{/foreach}
	<div class="spyRaportFooter">
		<a href="game.php?page=fleetTable&amp;galaxy={$targetPlanet.galaxy}&amp;system={$targetPlanet.system}&amp;planet={$targetPlanet.planet}&amp;planettype={$targetPlanet.planet_type}&amp;target_mission=1">{$LNG.type_mission_1}</a>
		<br>{if $targetChance >= $spyChance}{$LNG.sys_mess_spy_destroyed}{else}{sprintf($LNG.sys_mess_spy_lostproba, $targetChance)}{/if}
		{if $isBattleSim}<br><a href="game.php?page=battleSimulator{foreach $spyData as $Class => $elementIDs}{foreach $elementIDs as $elementID => $amount}&amp;im[{$elementID}]={$amount}{/foreach}{/foreach}">{$LNG.fl_simulate}</a>{/if}
	</div>
</div>