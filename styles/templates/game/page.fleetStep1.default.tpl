{block name="title" prepend}{$LNG.lm_fleet}{/block}
{block name="content"}

{* ============================================================
   ASTROIO FLEET STEP 1 v3.0 — Estilo Xnova moderno (glassmorphism)
   Prefijo CSS: .astrofs_   (aislado, no rompe otros módulos)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, sub-secciones 10px)
     - Sub-paneles con borde cyan sutil + hover
     - Inputs/selects con radius 8px + focus translateY
     - Wrapper padding 15px
     - Todos los IDs, names, onclick y Smarty intactos
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

/* ====== Wrapper ====== */
.astrofs_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Panel principal ====== */
.astrofs_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    padding: 15px;
    color: var(--text-main);
    margin-bottom: 10px;
    max-width: 620px;
    margin-left: auto;
    margin-right: auto;
}

/* ====== Título interno de sección ====== */
.astrofs_section_title {
    color: #00e0ff;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 0.6px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(0, 204, 255, 0.2);
    padding-bottom: 5px;
    margin-bottom: 10px;
    display: block;
}

/* ====== Tabla de destino / info ====== */
.astrofs_table {
    width: 100%;
    border-collapse: separate;
    border-spacing: 0 3px;
    table-layout: fixed;
}
.astrofs_table td {
    padding: 3px 6px;
    vertical-align: middle;
    color: var(--text-main);
    font-size: 11px;
    line-height: 1.2;
}
.astrofs_table td:first-child {
    color: var(--text-muted);
    font-weight: 600;
    width: 42%;
}
.astrofs_table td:last-child {
    color: var(--text-title);
    font-weight: 700;
}
.astrofs_table tr:hover td {
    background: rgba(0, 204, 255, 0.05);
    border-radius: 4px;
}

/* ====== Inputs de coordenadas y tipo ====== */
.astrofs_input {
    padding: 4px 6px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    color: #ffffff;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    font-size: 11px;
    outline: none;
    transition: 0.25s ease;
    text-align: center;
}
.astrofs_input:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}
.astrofs_input.astrofs_galaxy { width: 42px; }
.astrofs_input.astrofs_system { width: 50px; }
.astrofs_input.astrofs_planet { width: 42px; }

.astrofs_select {
    padding: 4px 8px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    color: #ffffff;
    font-weight: 700;
    font-size: 11px;
    font-family: inherit;
    cursor: pointer;
    outline: none;
    transition: 0.25s ease;
}
.astrofs_select:focus,
.astrofs_select:hover {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5);
    transform: translateY(-1px);
}
.astrofs_select option {
    background: #0f1624;
    color: #ffffff;
    padding: 4px;
}

/* ====== Valores informativos ====== */
.astrofs_info_val {
    color: #66ff99 !important;
    font-family: 'Courier New', monospace !important;
    font-weight: 700 !important;
    font-size: 11px !important;
    text-shadow: 0 0 6px rgba(102, 255, 153, 0.25);
}

/* ====== Sub-paneles (atajos / colonias / ACS) ====== */
.astrofs_subpanel {
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    padding: 10px 12px;
    margin-bottom: 10px;
    transition: 0.2s ease;
}
.astrofs_subpanel:hover {
    border-color: rgba(0, 204, 255, 0.3);
}
.astrofs_subpanel_header {
    color: #00e0ff;
    font-weight: 700;
    font-size: 10.5px;
    letter-spacing: 0.6px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(0, 204, 255, 0.2);
    padding-bottom: 5px;
    margin-bottom: 8px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 6px;
    flex-wrap: wrap;
}
.astrofs_subpanel_header a {
    color: #66ff99;
    text-decoration: none;
    font-weight: 700;
    font-size: 10px;
    padding: 2px 8px;
    border-radius: 6px;
    background: rgba(102, 255, 153, 0.08);
    border: 1px solid rgba(102, 255, 153, 0.3);
    transition: 0.25s ease;
    cursor: pointer;
}
.astrofs_subpanel_header a:hover {
    background: rgba(102, 255, 153, 0.2);
    box-shadow: 0 0 10px rgba(102, 255, 153, 0.4);
    color: #ffffff;
    transform: translateY(-1px);
}

/* Atajos y colonias */
.astrofs_shortcut_table,
.astrofs_colony_table {
    width: 100%;
    border-collapse: separate;
    border-spacing: 2px;
}
.astrofs_shortcut_table td,
.astrofs_colony_table td {
    padding: 3px 5px;
    border-radius: 4px;
    vertical-align: top;
}
.astrofs_shortcut_table td a,
.astrofs_colony_table td a {
    color: #00e0ff;
    text-decoration: none;
    font-weight: 600;
    font-size: 10.5px;
    display: inline-block;
    padding: 2px 6px;
    border-radius: 6px;
    transition: 0.2s ease;
    word-break: break-word;
}
.astrofs_shortcut_table td a:hover,
.astrofs_colony_table td a:hover {
    background: rgba(0, 204, 255, 0.12);
    color: #ffffff;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.8);
}

/* Inputs de atajos */
.astrofs_shortcut_input {
    padding: 3px 5px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(0, 204, 255, 0.3);
    border-radius: 6px;
    color: #ffffff;
    font-size: 10px;
    font-family: 'Courier New', monospace;
    outline: none;
    transition: 0.2s ease;
    max-width: 100%;
    box-sizing: border-box;
}
.astrofs_shortcut_input:focus {
    border-color: #00ccff;
    box-shadow: 0 0 8px rgba(0, 204, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
}

/* Estado vacío */
.astrofs_empty {
    color: var(--text-muted) !important;
    font-size: 10.5px !important;
    text-align: center !important;
    padding: 6px !important;
    font-style: italic;
}

/* ====== Botón continuar ====== */
.astrofs_submit_row {
    text-align: center;
    padding-top: 8px;
    margin-top: 8px;
    border-top: 1px solid rgba(0, 204, 255, 0.15);
}
.astrofs_submit {
    display: inline-block;
    padding: 10px 32px;
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
    border: 1px solid #00ccff;
    border-radius: 8px;
    color: #ffffff;
    font-weight: 700;
    font-size: 12px;
    cursor: pointer;
    transition: 0.25s ease;
    letter-spacing: 0.5px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    font-family: inherit;
    box-shadow: 0 3px 10px rgba(0, 102, 204, 0.4);
    text-transform: uppercase;
}
.astrofs_submit:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 16px rgba(0, 224, 255, 0.6), 0 3px 10px rgba(0, 102, 204, 0.5);
    transform: translateY(-2px);
}
.astrofs_submit:active {
    transform: translateY(0);
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .astrofs_wrap { padding: 10px; }
    .astrofs_panel { padding: 8px; max-width: 100%; }
    .astrofs_table td { padding: 2px 4px; font-size: 10.5px; }
    .astrofs_input { padding: 3px 5px; font-size: 10.5px; }
    .astrofs_input.astrofs_galaxy { width: 30px; }
    .astrofs_input.astrofs_system { width: 40px; }
    .astrofs_input.astrofs_planet { width: 30px; }
    .astrofs_submit { width: 100%; padding: 10px 20px; }
}
</style>

<div class="astrofs_wrap">

	<div class="astrofs_panel">

		<span class="astrofs_section_title">🚀 {$LNG.fl_send_fleet}</span>

		<form action="game.php?page=fleetStep2" method="post" onsubmit="return CheckTarget()" id="form">
			<input type="hidden" name="token" value="{$token}">
			<input type="hidden" name="fleet_group" value="0">
			<input type="hidden" name="target_mission" value="{$mission}">

			{* ============ TABLA DE DESTINO ============ *}
			<table class="astrofs_table">
				<tr>
					<td>{$LNG.fl_destiny}</td>
					<td>
						<input type="text" id="galaxy" name="galaxy" size="3" maxlength="2" onkeyup="updateVars()" value="{$galaxy}" class="astrofs_input astrofs_galaxy">
						<input type="text" id="system" name="system" size="3" maxlength="3" onkeyup="updateVars()" value="{$system}" class="astrofs_input astrofs_system">
						<input type="text" id="planet" name="planet" size="3" maxlength="2" onkeyup="updateVars()" value="{$planet}" class="astrofs_input astrofs_planet">
						<select id="type" name="type" onchange="updateVars()" class="astrofs_select">
							{html_options options=$typeSelect selected=$type}
						</select>
					</td>
				</tr>
				<tr>
					<td>{$LNG.fl_fleet_speed}</td>
					<td>
						<select id="speed" name="speed" onChange="updateVars()" class="astrofs_select">
							{html_options options=$speedSelect}
						</select> %
					</td>
				</tr>
				<tr>
					<td>{$LNG.fl_distance}</td>
					<td id="distance" class="astrofs_info_val">-</td>
				</tr>
				<tr>
					<td>{$LNG.fl_flying_time}</td>
					<td id="duration" class="astrofs_info_val">-</td>
				</tr>
				<tr>
					<td>{$LNG.fl_flying_arrival}</td>
					<td id="arrival" class="astrofs_info_val">-</td>
				</tr>
				<tr>
					<td>{$LNG.fl_flying_return}</td>
					<td id="return" class="astrofs_info_val">-</td>
				</tr>
				<tr>
					<td>{$LNG.fl_fuel_consumption}</td>
					<td id="consumption" class="astrofs_info_val">-</td>
				</tr>
				<tr>
					<td>{$LNG.fl_max_speed}</td>
					<td id="maxspeed" class="astrofs_info_val">-</td>
				</tr>
				<tr>
					<td>{$LNG.fl_cargo_capacity}</td>
					<td id="storage" class="astrofs_info_val">-</td>
				</tr>
			</table>

		</form>

		{* ============ ATAJOS (SHORTCUTS) ============ *}
		{if isModuleAvailable($smarty.const.MODULE_SHORTCUTS)}
		<div class="astrofs_subpanel">
			<div class="astrofs_subpanel_header">
				<span>{$LNG.fl_shortcut}</span>
				<span>
					(<a href="#" onclick="EditShortcuts();return false" class="shortcut-link-edit shortcut-link">{$LNG.fl_shortcut_edition}</a>
					<a href="#" onclick="SaveShortcuts();return false" class="shortcut-edit">{$LNG.fl_shortcut_save}</a>)
				</span>
			</div>

			<table class="shortcut astrofs_shortcut_table" style="table-layout: fixed; width: 100%;">
				{foreach $shortcutList as $shortcutID => $shortcutRow}
					{if ($shortcutRow@iteration % $themeSettings.SHORTCUT_ROWS_ON_FLEET1) === 1}<tr class="shortcut-row">{/if}
					<td style="width:{100 / $themeSettings.SHORTCUT_ROWS_ON_FLEET1}%" class="shortcut-colum shortcut-isset">
						<div class="shortcut-link">
							<a href="javascript:setTarget({$shortcutRow.galaxy},{$shortcutRow.system},{$shortcutRow.planet},{$shortcutRow.type});updateVars();">{$shortcutRow.name}{if $shortcutRow.type == 1}{$LNG.fl_planet_shortcut}{elseif $shortcutRow.type == 2}{$LNG.fl_debris_shortcut}{elseif $shortcutRow.type == 3}{$LNG.fl_moon_shortcut}{/if} [{$shortcutRow.galaxy}:{$shortcutRow.system}:{$shortcutRow.planet}]</a>
						</div>
						<div class="shortcut-edit">
							<input type="text" class="shortcut-input astrofs_shortcut_input" name="shortcut[{$shortcutID}][name]" value="{$shortcutRow.name}">
							<div class="shortcut-delete" title="{$LNG.fl_dlte_shortcut}"></div>
						</div>
						<div class="shortcut-edit">
							<input type="text" class="shortcut-input astrofs_shortcut_input" name="shortcut[{$shortcutID}][galaxy]" value="{$shortcutRow.galaxy}" size="3" maxlength="2">:<input type="text" class="shortcut-input astrofs_shortcut_input" name="shortcut[{$shortcutID}][system]" value="{$shortcutRow.system}" size="3" maxlength="3">:<input type="text" class="shortcut-input astrofs_shortcut_input" name="shortcut[{$shortcutID}][planet]" value="{$shortcutRow.planet}" size="3" maxlength="2">
							<select class="shortcut-input astrofs_shortcut_input" name="shortcut[{$shortcutID}][type]">
								{html_options selected=$shortcutRow.type options=$typeSelect}
							</select>
						</div>
					</td>
					{if $shortcutRow@last && ($shortcutRow@iteration % $themeSettings.SHORTCUT_ROWS_ON_FLEET1) !== 0}
					{$to = $themeSettings.SHORTCUT_ROWS_ON_FLEET1 - ($shortcutRow@iteration % $themeSettings.SHORTCUT_ROWS_ON_FLEET1)}
					{for $foo=1 to $to}
					<td class="shortcut-colum" style="width:{100 / $themeSettings.SHORTCUT_ROWS_ON_FLEET1}%">&nbsp;</td>
					{/for}
					{/if}
					{if ($shortcutRow@iteration % $themeSettings.SHORTCUT_ROWS_ON_FLEET1) === 0}</tr>{/if}
				{foreachelse}
				<tr class="shortcut-none">
					<td colspan="{$themeSettings.SHORTCUT_ROWS_ON_FLEET1}" class="astrofs_empty">{$LNG.fl_no_shortcuts}</td>
				</tr>
				{/foreach}
				<tr class="shortcut-edit shortcut-new">
					<td>
						<div class="shortcut-link">
							
						</div>
						<div class="shortcut-edit">
							<input type="text" class="shortcut-input astrofs_shortcut_input" name="shortcut[][name]" placeholder="{$LNG.fl_shortcut_name}">
							<div class="shortcut-delete" title="{$LNG.fl_dlte_shortcut}"></div>
						</div>
						<div class="shortcut-edit">
							<input type="text" class="shortcut-input astrofs_shortcut_input" name="shortcut[][galaxy]" value="" size="3" maxlength="2" placeholder="G" pattern="[0-9]*">:<input type="text" class="shortcut-input astrofs_shortcut_input" name="shortcut[][system]" value="" size="3" maxlength="3" placeholder="S" pattern="[0-9]*">:<input type="text" class="shortcut-input astrofs_shortcut_input" name="shortcut[][planet]" value="" size="3" maxlength="2" placeholder="P" pattern="[0-9]*">
							<select class="shortcut-input astrofs_shortcut_input" name="shortcut[][type]">
								{html_options options=$typeSelect}
							</select>
						</div>
					</td>
				</tr>
				<tr class="shortcut-edit">
					<td colspan="{$themeSettings.SHORTCUT_ROWS_ON_FLEET1}">
						<a href="#" onclick="AddShortcuts();return false">{$LNG.fl_shortcut_add}</a>
					</td>
				</tr>
			</table>
		</div>
		{/if}

		{* ============ MIS PLANETAS / COLONIAS ============ *}
		<div class="astrofs_subpanel">
			<div class="astrofs_subpanel_header">
				<span>{$LNG.fl_my_planets}</span>
			</div>

			<table class="astrofs_colony_table" style="table-layout: fixed; width: 100%;">
				{foreach $colonyList as $ColonyRow}
				{if ($ColonyRow@iteration % $themeSettings.COLONY_ROWS_ON_FLEET1) === 1}<tr>{/if}
				<td>
					<a href="javascript:setTarget({$ColonyRow.galaxy},{$ColonyRow.system},{$ColonyRow.planet},{$ColonyRow.type});updateVars();">{$ColonyRow.name}{if $ColonyRow.type == 3}{$LNG.fl_moon_shortcut}{/if} [{$ColonyRow.galaxy}:{$ColonyRow.system}:{$ColonyRow.planet}]</a>
				</td>
				{if $ColonyRow@last && ($ColonyRow@iteration % $themeSettings.COLONY_ROWS_ON_FLEET1) !== 0}
				{$to = $themeSettings.COLONY_ROWS_ON_FLEET1 - ($ColonyRow@iteration % $themeSettings.COLONY_ROWS_ON_FLEET1)}
				{for $foo=1 to $to}<td>&nbsp;</td>{/for}
				{/if}
				{if ($ColonyRow@iteration % $themeSettings.COLONY_ROWS_ON_FLEET1) === 0}</tr>{/if}
				{foreachelse}
				<tr>
					<td colspan="{$themeSettings.COLONY_ROWS_ON_FLEET1}" class="astrofs_empty">{$LNG.fl_no_colony}</td>
				</tr>
				{/foreach}
			</table>
		</div>

		{* ============ LISTA ACS ============ *}
		{if $ACSList}
		<div class="astrofs_subpanel">
			<div class="astrofs_subpanel_header">
				<span>{$LNG.fl_acs_title}</span>
			</div>

			<table class="table519 astrofs_colony_table" style="table-layout: fixed; width: 100%;">
				{foreach $ACSList as $ACSRow}
				{if ($ACSRow@iteration % $themeSettings.ACS_ROWS_ON_FLEET1) === 1}<tr>{/if}
				<tr>
					<td><a href="javascript:setACSTarget({$ACSRow.galaxy},{$ACSRow.system},{$ACSRow.planet},{$ACSRow.planet_type},{$ACSRow.id});">{$ACSRow.name} - [{$ACSRow.galaxy}:{$ACSRow.system}:{$ACSRow.planet}]</a></td>
				</tr>
				{if $ACSRow@last && ($ACSRow@iteration % $themeSettings.ACS_ROWS_ON_FLEET1) !== 0}
				{$to = $themeSettings.ACS_ROWS_ON_FLEET1 - ($ACSRow@iteration % $themeSettings.ACS_ROWS_ON_FLEET1)}
				{for $foo=1 to $to}<td>&nbsp;</td>{/for}
				{/if}
				{if ($ACSRow@iteration % $themeSettings.ACS_ROWS_ON_FLEET1) === 0}</tr>{/if}
				{/foreach}
			</table>
		</div>
		{/if}

		{* ============ BOTÓN CONTINUAR ============ *}
		<div class="astrofs_submit_row">
			<input type="submit" value="{$LNG.fl_continue}" class="astrofs_submit" form="form">
		</div>

	</div>

</div>

<script type="text/javascript">
data			= {$fleetdata|json};
shortCutRows	= {$themeSettings.SHORTCUT_ROWS_ON_FLEET1};
fl_no_shortcuts	= '{$LNG.fl_no_shortcuts}';
</script>
{/block}