{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/adm/CronjobDetail.tpl === *}
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
<table width=512>
{if !empty($error_msg)}
{foreach from=$error_msg item=error}<tr><td colspan=2>{$error}</td></tr>{/foreach}
{/if}
<tr>
	<th colspan=3>{if $id == 0}{$LNG.cronjob_new}{else}{$LNG.cronjob_headline}{$id}{/if}</th>
</tr>
<form method="POST" action="">
<input type="hidden" name="action" value="edit">
<input type="hidden" name="id" value="{$id}">
<tr>
	<td>{$LNG.cronjob_name}</td>
	<td><input type="text" name="name" value="{$name}"></td>
	<td><img src="./styles/resource/images/admin/i.gif" width="16" height="16" alt="" class="tooltip" data-tooltip-content="{$LNG.cronjob_desc_name}"></td>
</tr>
<tr>
<td colspan=3>{$LNG.cronjob_desc}</td>
</tr>
<tr>
	<td>{$LNG.cronjob_min}</td>
	<td colspan=2><select style="height:100px;width:80px;" name="min[]" multiple="multiple">{html_options values=range(0, 59) output=range(0, 59) selected=$min}</select><br>
	<input name="min_all" id="min_all" type="checkbox" value="1" {if isset($min.0) && $min.0==="*"}checked{/if}><label for="min_all">{$LNG.cronjob_selectall}</label></td>
</tr>
<tr>
	<td>{$LNG.cronjob_hours}</td>
	<td colspan=2><select style="height:100px;width:80px;" name="hours[]" multiple="multiple">{html_options values=range(0, 23) output=range(0, 23) selected=$hours}</select><br>
	<input name="hours_all" id="hours_all" type="checkbox" value="1" {if isset($hours.0) && $hours.0==="*"}checked{/if}><label for="hours_all">{$LNG.cronjob_selectall}</label></td>
</tr>
<tr>
	<td>{$LNG.cronjob_dom}</td>
	<td colspan=2><select style="height:100px;width:80px;" name="dom[]" multiple="multiple">{html_options values=range(1, 31) output=range(1, 31) selected=$dom}</select><br>
	<input name="dom_all" id="dom_all" type="checkbox" value="1" {if isset($dom.0) && $dom.0==="*"}checked{/if}><label for="dom_all">{$LNG.cronjob_selectall}</label></td>
</tr>
<tr>
	<td>{$LNG.cronjob_month}</td>
	<td colspan=2><select style="height:100px;width:80px;" name="month[]" multiple="multiple">{html_options values=range(1, 12) output=$LNG.months selected=$month}</select><br>
	<input name="month_all" id="month_all" type="checkbox" value="1" {if isset($month.0) && $month.0==="*"}checked{/if}><label for="month_all">{$LNG.cronjob_selectall}</label></td>
</tr>
<tr>
	<td>{$LNG.cronjob_dow}</td>
	<td colspan=2><select style="height:100px;width:80px;" name="dow[]" multiple="multiple">{html_options values=range(0, 6) output=$LNG.week_day selected=$dow}</select><br>
	<input name="dow_all" id="dow_all" type="checkbox" value="1" {if isset($dow.0) && $dow.0==="*"}checked{/if}><label for="dow_all">{$LNG.cronjob_selectall}</label></td>
</tr>
<tr>
	<td>{$LNG.cronjob_class}</td>
	<td>{html_options name="class" output=$avalibleCrons values=$avalibleCrons selected=$class}</td>
	<td><img src="./styles/resource/images/admin/i.gif" width="16" height="16" alt="" class="tooltip" data-tooltip-content="{$LNG.cronjob_desc_class}"></td>
</tr>
<tr>
<td colspan=3>
	<input type="submit" value="OK">
</td>
</form>
</tr>
</table>
</body>
{include file="overall_footer.tpl"}