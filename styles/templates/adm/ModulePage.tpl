{include file="overall_header.tpl"}

{* ══════════════════════════════════════════════════════════════
   ASTROIO MODULE PAGE (admin) v3.0
   Prefijo: .astromod_
   Acento del módulo: 🟢 Verde (#4aff88)
   FIX v3.0:
     - Patrón fleetDealer aplicado (glassmorphism, radius 10-12px)
     - Tabla con header gradiente cyan + hover
     - Estados con badges (verde activo / rojo inactivo)
     - Links con hover translateY
     - ⚠️ CRÍTICO: overall_header/footer intactos (admin)
     - ⚠️ CRÍTICO: foreach, if, links mode=aktiv/deaktiv, {$ID} intactos
     - ⚠️ CRÍTICO: estructura <table> preservada
   ══════════════════════════════════════════════════════════════ *}

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

.astromod_wrap {
    max-width: 700px;
    margin: 0 auto;
    padding: 15px;
    box-sizing: border-box;
    color: var(--text-main);
    font-family: 'Segoe UI', Tahoma, sans-serif;
    text-align: center;
}

.astromod_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    padding: 15px;
    color: var(--text-main);
    display: inline-block;
    text-align: left;
    width: 100%;
    max-width: 700px;
    box-sizing: border-box;
}

.astromod_table {
    width: 100%;
    border-collapse: collapse;
    font-size: 11px;
    table-layout: fixed;
}

.astromod_table tr > th {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    color: #ffffff;
    padding: 10px 12px;
    font-weight: 700;
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    text-align: center;
    border-bottom: 1px solid var(--accent-cyan);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    border-radius: 10px 10px 0 0;
}

.astromod_table tr > td {
    padding: 8px 12px;
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
    color: var(--text-main);
    vertical-align: middle;
    text-align: center;
}

.astromod_table tr > td:first-child {
    text-align: left;
    color: var(--text-title);
    font-weight: 600;
}

.astromod_table tr:hover td {
    background: rgba(0, 204, 255, 0.06);
}

/* Estado info */
.astromod_info {
    color: var(--text-muted);
    font-style: italic;
    font-size: 11px;
    padding: 10px 12px;
    text-align: center;
    background: rgba(0, 0, 0, 0.2);
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
}

/* Badges de estado */
.astromod_state {
    display: inline-block;
    padding: 3px 10px;
    border-radius: 6px;
    font-weight: 700;
    font-size: 10px;
    letter-spacing: 0.4px;
    text-transform: uppercase;
}
.astromod_state.active {
    color: #66ff99 !important;
    background: rgba(102, 255, 153, 0.1);
    border: 1px solid rgba(102, 255, 153, 0.35);
    text-shadow: 0 0 6px rgba(102, 255, 153, 0.4);
}
.astromod_state.inactive {
    color: #ff4488 !important;
    background: rgba(255, 68, 136, 0.1);
    border: 1px solid rgba(255, 68, 136, 0.35);
    text-shadow: 0 0 6px rgba(255, 68, 136, 0.4);
}

/* Links de acción */
.astromod_table tr > td a {
    color: #00e0ff;
    text-decoration: none;
    font-weight: 700;
    font-size: 10.5px;
    padding: 4px 10px;
    border: 1px solid rgba(0, 204, 255, 0.3);
    border-radius: 6px;
    display: inline-block;
    transition: 0.25s ease;
    text-transform: uppercase;
    letter-spacing: 0.4px;
}
.astromod_table tr > td a:hover {
    background: rgba(0, 204, 255, 0.15);
    color: #ffffff;
    border-color: #00e0ff;
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.5);
    transform: translateY(-2px);
}
.astromod_table tr > td a:active {
    transform: translateY(0);
}

/* Responsive */
@media (max-width: 720px) {
    .astromod_wrap { padding: 10px; }
    .astromod_panel { padding: 12px; }
    .astromod_table { font-size: 10px; }
    .astromod_table tr > th { padding: 8px 10px; font-size: 11px; }
    .astromod_table tr > td { padding: 6px 8px; }
    .astromod_table tr > td a {
        padding: 3px 8px;
        font-size: 9.5px;
    }
}
</style>

<div class="astromod_wrap">
<div class="astromod_panel">
<table class="astromod_table" width="500">
<tr>
    <th colspan="3">{$mod_module}</th>
</tr>
<tr>
    <td colspan="3" class="astromod_info">{$mod_info}</td>
</tr>
{foreach key=ID item=Info from=$Modules}
<tr>
	<td>{$Info.name}</td>
	{if $Info.state == 1}
		<td><span class="astromod_state active">{$mod_active}</span></td>
		<td><a href="?page=module&amp;mode=deaktiv&amp;id={$ID}">{$mod_change_deactive}</a></td>
	{else}
		<td><span class="astromod_state inactive">{$mod_deactive}</span></td>
		<td><a href="?page=module&amp;mode=aktiv&amp;id={$ID}">{$mod_change_active}</a></td>
	{/if}
	</tr>
{/foreach}
</table>
</div>
</div>

{include file="overall_footer.tpl"}