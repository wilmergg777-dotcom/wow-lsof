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