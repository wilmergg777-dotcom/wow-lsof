{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/adm/AccountEditorPagePlanets.tpl === *}
{literal}
<style>
/* === ASTROIO v3.0 === */
h1, h2, h3, h4 { color:#fff; letter-spacing:.5px; text-shadow:0 1px 3px rgba(0,0,0,.5) }
a { color:#00e0ff; text-decoration:none; transition:.2s ease }
a:hover { color:#fff; text-shadow:0 0 10px rgba(0,224,255,.7) }
table { background:rgba(15,23,42,.55); border:1px solid #1e293b; border-radius:10px; border-collapse:collapse; overflow:hidden }
table th { background:linear-gradient(135deg,rgba(0,68,136,.85),rgba(0,119,204,.85)); border-bottom:1px solid rgba(0,224,255,.5); color:#fff; padding:6px 9px; text-align:left; text-transform:uppercase; font-size:10px; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
table td { padding:6px 9px; border-bottom:1px solid rgba(30,41,59,.7); color:#cbd5e1 }
table tr:hover td { background:rgba(0,224,255,.04) }
input[type=text], input[type=password], input[type=email], input[type=number], input[type=date], select, textarea { background:rgba(0,0,0,.5); color:#fff; border:1px solid rgba(0,204,255,.35); border-radius:8px; padding:5px 9px; font-size:12px; font-family:inherit; box-sizing:border-box; max-width:100%; transition:.25s ease }
input[type=text]:focus, input[type=password]:focus, input[type=email]:focus, input[type=number]:focus, select:focus, textarea:focus { outline:none; border-color:#00e0ff; box-shadow:0 0 12px rgba(0,224,255,.5); background:rgba(0,0,0,.65) }
textarea { width:100%; resize:vertical; font-family:inherit }
button, input[type=submit], input[type=button] { background:linear-gradient(180deg,#0066cc,#0099ff); color:#fff; border:1px solid #00e0ff; border-radius:8px; padding:5px 16px; font-size:11.5px; font-weight:600; font-family:inherit; cursor:pointer; transition:.25s ease; text-transform:uppercase; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
button:hover, input[type=submit]:hover, input[type=button]:hover { box-shadow:0 0 18px rgba(0,224,255,.5); transform:translateY(-2px) }
button:active, input[type=submit]:active, input[type=button]:active { transform:translateY(0) }
input[type=reset] { background:linear-gradient(180deg,#444,#666); border-color:#888 }
select option { background:#0f172a; color:#cbd5e1 }
.globalWarning { background:rgba(239,68,68,.12); border:1px solid rgba(239,68,68,.45); color:#fecaca; border-radius:10px; padding:8px 14px; text-align:center }
@media (max-width:760px) { { padding:6px; overflow-x:auto } table { font-size:11px } table th, table td { padding:5px 7px } }
</style>
{/literal}

{include file="overall_header.tpl"}
<form action="" method="post">
<table width="45%">
<tr>
<td colspan="3" align="left"><a href="?page=accounteditor">
<img src="./styles/resource/images/admin/arrowright.png" width="16" height="10"> {$LNG.ad_back_to_menu}</a></td>
</tr><tr>
	<th colspan="7">{$LNG.ad_pla_title}</th>
</tr><tr>
	<td>{$LNG.input_id_p_m}</td>
	<td><input name="id" type="text" size="5" maxlength="5"></td>
</tr><tr>
	<td>{$LNG.ad_pla_edit_name}</td>
	<td><input name="name" type="text" size="20"></td>
</tr><tr>
	<td>{$LNG.ad_pla_edit_diameter}</td>
	<td><input name="diameter" type="text" size="5"></td>
</tr><tr>
	<td>{$LNG.ad_pla_edit_fields}</td>
	<td><input name="fields" type="text" size="5"></td>
</tr><tr>
	<td>{$LNG.ad_pla_delete_b}</td>
	<td><input name="0_buildings" type="checkbox"></td>
</tr><tr>
	<td>{$LNG.ad_pla_delete_s}</td>
	<td><input name="0_ships" type="checkbox"></td>
</tr><tr>
	<td>{$LNG.ad_pla_delete_d}</td>
	<td><input name="0_defenses" type="checkbox"></td>
</tr><tr>
	<td>{$LNG.ad_pla_delete_hd}</td>
	<td><input name="0_c_hangar" type="checkbox"></td>
</tr><tr>
	<td>{$LNG.ad_pla_delete_cb}</td>
	<td><input name="0_c_buildings" type="checkbox"></td>
</tr><tr>
	<td><a href="#" class="tooltip" data-tooltip-content="{$LNG.ad_pla_title_l}">{$LNG.ad_pla_change_p}</a></td>
	<td><input name="change_position" type="checkbox" title="{$LNG.ad_pla_change_pp}">
	<input name="g" type="text" size="1" maxlength="1"> : <input name="s" type="text" size="3" maxlength="3"> : <input name="p" type="text" size="2" maxlength="2"></td>
</tr><tr>
	<td colspan="3"><input type="submit" value="{$LNG.button_submit}">&nbsp;
	<input type="reset" value="{$LNG.button_reset}"></td>
</tr>
</table>
</form>
{include file="overall_footer.tpl"}