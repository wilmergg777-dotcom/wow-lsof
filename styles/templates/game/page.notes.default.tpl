{block name="title" prepend}{$LNG.lm_notes}{/block}
{block name="content"}

{* ============================================================
   ASTROIO NOTES v2.1 — Estilo FleetTable compacto
   Prefijo CSS: .astront_   (aislado, no rompe otros módulos)
   ============================================================ *}

<style>
/* ====== Wrapper ====== */
.astront_wrap { width: 100%; padding: 0; box-sizing: border-box; }

/* ====== Panel principal ====== */
.astront_panel {
    background: linear-gradient(135deg, #0f1624 0%, #1a2332 100%);
    border: 1px solid rgba(0, 204, 255, 0.25);
    border-radius: 10px;
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.4);
    padding: 10px 14px;
    color: #c8d6e5;
    max-width: 720px;
    margin: 0 auto;
}

/* ====== Título de sección ====== */
.astront_section_title {
    color: #00e0ff;
    font-weight: 700;
    font-size: 12px;
    letter-spacing: 0.6px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(0, 204, 255, 0.2);
    padding-bottom: 6px;
    margin-bottom: 10px;
    display: block;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.35);
}

/* ====== Barra superior (Nueva nota) ====== */
.astront_topbar {
    text-align: center;
    padding: 6px 10px;
    background: rgba(0, 0, 0, 0.25);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 6px;
    margin-bottom: 8px;
}
.astront_new_btn {
    display: inline-block;
    padding: 5px 18px;
    background: linear-gradient(135deg, #0066cc, #0099ff);
    border: 1px solid #00ccff;
    border-radius: 5px;
    color: #ffffff !important;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 0.4px;
    text-decoration: none;
    transition: 0.2s ease;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astront_new_btn:hover {
    background: linear-gradient(135deg, #0099ff, #00ccff);
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.55);
    transform: translateY(-1px);
}

/* ====== Tabla de notas ====== */
.astront_table_wrap {
    overflow-x: auto;
    border-radius: 6px;
    border: 1px solid rgba(0, 204, 255, 0.15);
    background: rgba(0, 0, 0, 0.2);
}
.astront_table {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
    font-size: 10.5px;
}

/* Cabecera */
.astront_table thead tr {
    background: linear-gradient(135deg, #004488, #0077cc);
}
.astront_table thead th {
    padding: 5px 6px;
    font-weight: 700;
    font-size: 10px;
    letter-spacing: 0.3px;
    text-align: center;
    color: #ffffff;
    border-bottom: 1px solid #00ccff;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astront_table thead th:first-child {
    padding-left: 8px;
}
.astront_table thead th:nth-child(3) {
    text-align: left;
}

/* Filas */
.astront_table tbody tr {
    background: rgba(0, 0, 0, 0.2);
    border-bottom: 1px solid rgba(0, 204, 255, 0.06);
    transition: 0.15s ease;
}
.astront_table tbody tr:hover {
    background: rgba(0, 204, 255, 0.07);
}
.astront_table tbody td {
    padding: 4px 6px;
    text-align: center;
    color: #c8d6e5;
    vertical-align: middle;
    line-height: 1.2;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}
.astront_table tbody td:nth-child(3) {
    text-align: left;
}

/* Anchos de columna */
.astront_table th:nth-child(1), .astront_table td:nth-child(1) { width: 40px;  }
.astront_table th:nth-child(2), .astront_table td:nth-child(2) { width: 130px; }
.astront_table th:nth-child(3), .astront_table td:nth-child(3) { width: auto;  }
.astront_table th:nth-child(4), .astront_table td:nth-child(4) { width: 60px;  }

/* Enlaces de la tabla */
.astront_table a {
    color: #00e0ff;
    text-decoration: none;
    font-weight: 600;
    transition: 0.15s ease;
}
.astront_table a:hover {
    color: #ffffff;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.9);
}

/* ====== Prioridades ====== */
.astront_prio_low { color: #66ff99 !important; text-shadow: 0 0 6px rgba(102, 255, 153, 0.35); }
.astront_prio_normal { color: #ffaa33 !important; text-shadow: 0 0 6px rgba(255, 170, 51, 0.35); }
.astront_prio_high { color: #ff4488 !important; text-shadow: 0 0 6px rgba(255, 68, 136, 0.35); }

/* ====== Checkbox ====== */
.astront_table input[type="checkbox"] {
    accent-color: #ff4488;
    width: 14px;
    height: 14px;
    cursor: pointer;
    vertical-align: middle;
    margin: 0;
}

/* ====== Botón eliminar ====== */
.astront_delete_row {
    text-align: right !important;
    padding: 8px 10px !important;
    border-top: 1px solid rgba(0, 204, 255, 0.15);
    background: rgba(0, 0, 0, 0.25);
}
.astront_delete_btn {
    display: inline-block;
    padding: 5px 18px;
    background: linear-gradient(135deg, #aa0044, #cc2266);
    border: 1px solid #ff4488;
    border-radius: 5px;
    color: #ffffff;
    font-weight: 700;
    font-size: 11px;
    cursor: pointer;
    transition: 0.2s ease;
    letter-spacing: 0.4px;
    font-family: inherit;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astront_delete_btn:hover {
    background: linear-gradient(135deg, #cc2266, #ff4488);
    box-shadow: 0 0 12px rgba(255, 68, 136, 0.55);
    transform: translateY(-1px);
}

/* ====== Fila vacía ====== */
.astront_empty {
    color: #8899aa !important;
    font-style: italic;
    text-align: center !important;
    padding: 12px !important;
    font-size: 11px;
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .astront_panel { padding: 8px 10px; max-width: 100%; }
    .astront_table { font-size: 10px; table-layout: auto; }
    .astront_table thead th { padding: 4px 4px; font-size: 9.5px; }
    .astront_table tbody td { padding: 3px 4px; }
    .astront_new_btn,
    .astront_delete_btn { padding: 4px 12px; font-size: 10.5px; }
}
</style>

<div class="astront_wrap">

	<div class="astront_panel">

		<span class="astront_section_title">📝 {$LNG.nt_notes}</span>

		<form action="game.php?page=notes&amp;mode=delete" method="post">

			{* ============ BOTÓN NUEVA NOTA ============ *}
			<div class="astront_topbar">
				<a href="game.php?page=notes&amp;mode=detail" class="astront_new_btn">➕ {$LNG.nt_create_new_note}</a>
			</div>

			{* ============ TABLA DE NOTAS ============ *}
			<div class="astront_table_wrap">
			<table class="astront_table">
				<thead>
					<tr>
						<th>{$LNG.nt_dlte_note}</th>
						<th>{$LNG.nt_date_note}</th>
						<th>{$LNG.nt_subject_note}</th>
						<th>{$LNG.nt_size_note}</th>
					</tr>
				</thead>
				<tbody>
				{foreach $notesList as $notesID => $notesRow}
				<tr>
					<td><input name="delmes[{$notesID}]" type="checkbox"></td>
					<td>{$notesRow.time}</td>
					<td>
						<a href="game.php?page=notes&amp;mode=detail&amp;id={$notesID}">
						{if $notesRow.priority == 0}
						<span class="astront_prio_low">{$notesRow.title}</span>
						{elseif $notesRow.priority == 2}
						<span class="astront_prio_high">{$notesRow.title}</span>
						{else}
						<span class="astront_prio_normal">{$notesRow.title}</span>
						{/if}
						</a>
					</td>
					<td>{$notesRow.size|number}</td>
				</tr>
				{if $notesRow@last}
				<tr>
					<td colspan="4" class="astront_delete_row">
						<input value="{$LNG.nt_dlte_note}" type="submit" class="astront_delete_btn">
					</td>
				</tr>
				{/if}
				{foreachelse}
				<tr>
					<td colspan="4" class="astront_empty">{$LNG.nt_you_dont_have_notes}</td>
				</tr>
				{/foreach}
				</tbody>
			</table>
			</div>

		</form>

	</div>

</div>

{/block}