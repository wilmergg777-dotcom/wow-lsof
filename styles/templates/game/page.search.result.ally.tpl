{block name="content"}

{* ============================================================
   ASTROIO SEARCH RESULT ALLY v3.0 — Estilo Xnova (glassmorphism)
   Prefijo CSS: .astrosrchra_   (aislado, no rompe otros módulos)
   Acento del módulo: 🔷 Cyan (#00e0ff)
   FIX v3.0:
     - Patrón fleetDealer aplicado (tabla glassmorphism, header cyan)
     - Wrapper con class
     - ⚠️ CRÍTICO: id="resulttable" intacto (usado por JS)
     - ⚠️ CRÍTICO: foreach, href, {$searchRow.*}, {$LNG.sh_*} intactos
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

/* ====== Tabla de resultados de alianzas ====== */
.astrosrchra_table {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
    font-size: 10.5px;
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    overflow: hidden;
}

/* Cabecera */
.astrosrchra_table tr:first-child th {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    padding: 6px 8px;
    font-weight: 700;
    font-size: 10px;
    letter-spacing: 0.3px;
    text-align: left;
    color: #ffffff;
    border-bottom: 1px solid var(--accent-cyan);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    white-space: nowrap;
}

/* Filas de datos */
.astrosrchra_table tr:not(:first-child) {
    background: rgba(0, 0, 0, 0.2);
    border-bottom: 1px solid rgba(0, 204, 255, 0.06);
    transition: 0.15s ease;
}
.astrosrchra_table tr:not(:first-child):hover {
    background: rgba(0, 204, 255, 0.07);
}
.astrosrchra_table tr:not(:first-child) td {
    padding: 5px 8px;
    color: var(--text-main);
    vertical-align: middle;
    line-height: 1.3;
    word-break: break-word;
}

/* Primera columna (TAG) — resaltada */
.astrosrchra_table tr:not(:first-child) td:first-child {
    font-weight: 700;
}

/* Enlaces */
.astrosrchra_table a {
    color: #00e0ff;
    text-decoration: none;
    font-weight: 600;
    transition: 0.15s ease;
}
.astrosrchra_table a:hover {
    color: #ffffff;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.9);
}

/* Responsive */
@media (max-width: 720px) {
    .astrosrchra_table { font-size: 10px; table-layout: auto; }
    .astrosrchra_table tr:first-child th { padding: 5px 5px; font-size: 9.5px; }
    .astrosrchra_table tr:not(:first-child) td { padding: 4px 5px; }
}
</style>

<table class="astrosrchra_table" style="width:100%;" id="resulttable">
	<tr>
		<th>{$LNG.sh_tag}</th>
		<th>{$LNG.sh_name}</th>
		<th>{$LNG.sh_members}</th>
		<th>{$LNG.sh_points}</th>
	</tr>
	{foreach $searchList as $searchRow}
	<tr>
		<td><a href="game.php?page=alliance&amp;mode=info&amp;tag={$searchRow.allytag}">{$searchRow.allytag}</a></td>
		<td>{$searchRow.allyname}</td>
		<td>{$searchRow.allymembers}</td>
		<td>{$searchRow.allypoints}</td>
	</tr>
	{/foreach}
</table>
{/block}