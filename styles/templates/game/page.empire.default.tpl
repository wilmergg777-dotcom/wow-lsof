{block name="title" prepend}{$LNG.lm_empire}{/block}
{block name="content"}

{* ============================================================
   ASTROIO EMPIRE v3.0 — Estilo Xnova (glassmorphism)
   Prefijo CSS: .astroemp_   (aislado, no rompe otros módulos)
   Acento del módulo: 🔷 Cyan (#00e0ff)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, sub-cajas 10px)
     - Tabla wrapper con borde cyan sutil + hover
     - Bloque headers con gradiente cyan + glassmorphism
     - Wrapper padding 15px
     - ⚠️ CRÍTICO: array_sum(), colspan dinámico, class res_XXX_text intactos
     - ⚠️ CRÍTICO: foreach anidados, hrefs, $planetList.* intactos
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
.astroemp_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Panel principal (glassmorphism) ====== */
.astroemp_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    padding: 15px;
    color: var(--text-main);
    max-width: 900px;
    margin: 0 auto;
}

/* ====== Título de sección ====== */
.astroemp_section_title {
    color: #00e0ff;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 0.6px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(0, 204, 255, 0.2);
    padding-bottom: 4px;
    margin-bottom: 10px;
    display: block;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.35);
}

/* ====== Contenedor con scroll horizontal ====== */
.astroemp_table_wrap {
    overflow-x: auto;
    border-radius: 10px;
    border: 1px solid rgba(0, 204, 255, 0.15);
    background: rgba(0, 0, 0, 0.3);
    transition: 0.2s ease;
}
.astroemp_table_wrap:hover {
    border-color: rgba(0, 204, 255, 0.3);
}

/* ====== Tabla ====== */
.astroemp_table {
    width: 100%;
    border-collapse: collapse;
    font-size: 10px;
    white-space: nowrap;
}

/* ====== Primera columna (etiqueta) ====== */
.astroemp_table tbody td:first-child,
.astroemp_table tbody th:first-child {
    text-align: left;
    padding-left: 6px !important;
    color: var(--text-muted) !important;
    font-weight: 600;
    font-size: 9.5px;
    width: 90px;
    min-width: 90px;
    background: rgba(0, 0, 0, 0.3);
    border-right: 1px solid rgba(30, 41, 59, 0.6);
}

/* ====== Segunda columna (total) ====== */
.astroemp_table tbody td:nth-child(2) {
    text-align: center;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    color: #ffaa33;
    background: rgba(255, 170, 51, 0.05);
    border-right: 1px solid rgba(255, 170, 51, 0.15);
    width: 60px;
    min-width: 60px;
    font-size: 9.5px;
}

/* ====== Celdas generales ====== */
.astroemp_table tbody td {
    padding: 4px;
    text-align: center;
    color: var(--text-main);
    vertical-align: middle;
    line-height: 1.25;
    border-bottom: 1px solid rgba(30, 41, 59, 0.4);
    font-size: 9.5px;
}

/* ====== Filas alternas ====== */
.astroemp_table tbody tr:nth-child(odd) {
    background: rgba(0, 0, 0, 0.15);
}
.astroemp_table tbody tr:hover td:not(:first-child):not(:nth-child(2)) {
    background: rgba(139, 92, 246, 0.06);
}

/* ====== Cabeceras de bloque (recursos, edificios, etc.) ====== */
.astroemp_table tbody tr.astroemp_block_header th {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    color: #ffffff;
    padding: 6px 8px;
    font-weight: 700;
    font-size: 9.5px;
    letter-spacing: 0.5px;
    text-transform: uppercase;
    text-align: center;
    border-top: 2px solid var(--accent-cyan);
    border-bottom: 1px solid var(--accent-cyan);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

/* ====== Imágenes de planetas ====== */
.astroemp_table tbody td.astroemp_planet_img {
    padding: 3px 2px;
    text-align: center;
}
.astroemp_table tbody td.astroemp_planet_img img {
    width: 40px;
    height: 40px;
    border-radius: 6px;
    border: 1px solid rgba(0, 204, 255, 0.3);
    transition: 0.25s ease;
    display: inline-block;
    vertical-align: middle;
}
.astroemp_table tbody td.astroemp_planet_img a:hover img {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.55);
    transform: scale(1.08);
}

/* ====== Fila sigma (Σ) ====== */
.astroemp_sigma {
    font-size: 20px !important;
    color: #00e0ff !important;
    font-weight: 700;
    text-align: center !important;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.5);
    padding: 2px !important;
    line-height: 1;
}

/* ====== Enlaces ====== */
.astroemp_table a {
    color: #00e0ff;
    text-decoration: none;
    font-weight: 600;
    transition: 0.15s ease;
}
.astroemp_table a:hover {
    color: #ffffff;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.9);
}

/* ====== Colores de recursos (clases dinámicas intactas) ====== */
.res_901_text { color: #c8d6e5 !important; font-family: 'Courier New', monospace; font-weight: 700; }
.res_902_text { color: #88ddff !important; font-family: 'Courier New', monospace; font-weight: 700; }
.res_903_text { color: #aaff88 !important; font-family: 'Courier New', monospace; font-weight: 700; }
.res_921_text { color: #aa44ff !important; font-family: 'Courier New', monospace; font-weight: 700; }

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .astroemp_wrap { padding: 10px; }
    .astroemp_panel { padding: 12px; max-width: 100%; }
    .astroemp_table { font-size: 9px; }
    .astroemp_table tbody td { padding: 3px; font-size: 9px; }
    .astroemp_table tbody td:first-child {
        width: 70px;
        min-width: 70px;
        font-size: 9px;
    }
    .astroemp_table tbody td:nth-child(2) {
        width: 50px;
        min-width: 50px;
        font-size: 9px;
    }
    .astroemp_table tbody td.astroemp_planet_img img {
        width: 32px;
        height: 32px;
    }
    .astroemp_sigma { font-size: 16px !important; }
}
</style>

<div class="astroemp_wrap">

	<div class="astroemp_panel">

		<span class="astroemp_section_title">🌍 {$LNG.lv_imperium_title}</span>

		<div class="astroemp_table_wrap">
		<table class="astroemp_table">
			<tbody>

				{* ============ IMÁGENES DE PLANETAS ============ *}
				<tr>
					<td style="width:90px">{$LNG.lv_planet}</td>
					<td class="astroemp_sigma">&Sigma;</td>
					{foreach $planetList.image as $planetID => $image}
					<td class="astroemp_planet_img">
						<a href="game.php?page=overview&amp;cp={$planetID}">
							<img src="{$dpath}planeten/small/s_{$image}.jpg" alt="">
						</a>
					</td>
					{/foreach}
				</tr>

				{* ============ NOMBRES ============ *}
				<tr>
					<td>{$LNG.lv_name}</td>
					<td>{$LNG.lv_total}</td>
					{foreach $planetList.name as $name}
					<td>{$name}</td>
					{/foreach}
				</tr>

				{* ============ COORDENADAS ============ *}
				<tr>
					<td>{$LNG.lv_coords}</td>
					<td>-</td>
					{foreach $planetList.coords as $coords}
					<td>
						<a href="game.php?page=galaxy&amp;galaxy={$coords.galaxy}&amp;system={$coords.system}">[{$coords.galaxy}:{$coords.system}:{$coords.planet}]</a>
					</td>
					{/foreach}
				</tr>

				{* ============ CAMPOS ============ *}
				<tr>
					<td>{$LNG.lv_fields}</td>
					<td>-</td>
					{foreach $planetList.field as $field}
					<td>{$field.current} / {$field.max}</td>
					{/foreach}
				</tr>

				{* ============ RECURSOS ============ *}
				<tr class="astroemp_block_header">
					<th colspan="{$colspan}">{$LNG.lv_resources}</th>
				</tr>
				{foreach $planetList.resource as $elementID => $resourceArray}
				<tr>
					<td>{$LNG.tech.$elementID}</td>
					<td class="res_{$elementID}_text">{array_sum($resourceArray)|number}</td>
					{foreach $resourceArray as $planetID => $resource}
					<td class="res_{$elementID}_text">{$resource|number}</td>
					{/foreach}
				</tr>
				{/foreach}

				{* ============ EDIFICIOS ============ *}
				<tr class="astroemp_block_header">
					<th colspan="{$colspan}">{$LNG.lv_buildings}</th>
				</tr>
				{foreach $planetList.build as $elementID => $buildArray}
				<tr>
					<td>{$LNG.tech.$elementID}</td>
					<td>{array_sum($buildArray)|number}</td>
					{foreach $buildArray as $planetID => $build}
					<td>{$build|number}</td>
					{/foreach}
				</tr>
				{/foreach}

				{* ============ TECNOLOGÍA ============ *}
				<tr class="astroemp_block_header">
					<th colspan="{$colspan}">{$LNG.lv_technology}</th>
				</tr>
				{foreach $planetList.tech as $elementID => $tech}
				<tr>
					<td>{$LNG.tech.$elementID}</td>
					<td>{$tech|number}</td>
					{foreach $planetList.name as $name}
					<td>{$tech|number}</td>
					{/foreach}
				</tr>
				{/foreach}

				{* ============ NAVES ============ *}
				<tr class="astroemp_block_header">
					<th colspan="{$colspan}">{$LNG.lv_ships}</th>
				</tr>
				{foreach $planetList.fleet as $elementID => $fleetArray}
				<tr>
					<td>{$LNG.tech.$elementID}</td>
					<td>{array_sum($fleetArray)|number}</td>
					{foreach $fleetArray as $planetID => $fleet}
					<td>{$fleet|number}</td>
					{/foreach}
				</tr>
				{/foreach}

				{* ============ DEFENSAS ============ *}
				<tr class="astroemp_block_header">
					<th colspan="{$colspan}">{$LNG.lv_defenses}</th>
				</tr>
				{foreach $planetList.defense as $elementID => $fleetArray}
				<tr>
					<td>{$LNG.tech.$elementID}</td>
					<td>{array_sum($fleetArray)|number}</td>
					{foreach $fleetArray as $planetID => $fleet}
					<td>{$fleet|number}</td>
					{/foreach}
				</tr>
				{/foreach}

			</tbody>
		</table>
		</div>

	</div>

</div>

{/block}