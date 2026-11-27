{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/adm/CronjobOverview.tpl === *}
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
<table width="80%">
<tr>
	<th>{$LNG.cronjob_id}</th>
	<th>{$LNG.cronjob_name}</th>
	<th>{$LNG.cronjob_min}</th>
	<th>{$LNG.cronjob_hours}</th>
	<th>{$LNG.cronjob_dom}</th>
	<th>{$LNG.cronjob_month}</th>
	<th>{$LNG.cronjob_dow}</th>
	<th>{$LNG.cronjob_class}</th>
	<th>{$LNG.cronjob_nextTime}</th>
	<th>{$LNG.cronjob_inActive}</th>
	<th>{$LNG.cronjob_lock}</th>
	<th>{$LNG.cronjob_edit}</th>
	<th>{$LNG.cronjob_delete}</th>
</tr>
{foreach item=CronjobInfo from=$CronjobArray}
<tr>
	<td>{$CronjobInfo.id}</td>
	<td>{$LNG["cronName_{$CronjobInfo.name}"]}</td>
	<td>{$CronjobInfo.min}</td>
	<td>{$CronjobInfo.hours}</td>
	<td>{$CronjobInfo.dom}</td>
	<td>{if $CronjobInfo.month == '*'}{$CronjobInfo.month}{else}{foreach item=month from=$CronjobInfo.month}{$LNG.months.{$month-1}}{/foreach}{/if}</td>
	<td>{if $CronjobInfo.dow == '*'}{$CronjobInfo.dow}{else}{foreach item=d from=$CronjobInfo.dow}{$LNG.week_day.{$d}} {/foreach}{/if}</td>
	<td>{$CronjobInfo.class}</td>
	<td>{if $CronjobInfo.isActive}{date($LNG.php_tdformat, $CronjobInfo.nextTime)}{else}-{/if}</td>
	<td><a href="admin.php?page=cronjob&amp;action=enable&amp;id={$CronjobInfo.id}&amp;enable={if $CronjobInfo.isActive}0" style="color:lime">{$LNG.cronjob_inactive}{else}1" style="color:red">{$LNG.cronjob_active}{/if}</a></td>
	<td><a href="admin.php?page=cronjob&amp;id={$CronjobInfo.id}&amp;action={if $CronjobInfo.lock}unlock" style="color:red">{$LNG.cronjob_is_lock}{else}lock" style="color:lime">{$LNG.cronjob_is_unlock}{/if}</a></td>
	<td><a href="admin.php?page=cronjob&amp;action=detail&amp;id={$CronjobInfo.id}"><img src="./styles/resource/images/admin/GO.png"></a></td>
	<td><a href="admin.php?page=cronjob&amp;action=delete&amp;id={$CronjobInfo.id}"><img src="./styles/resource/images/false.png" width="16" height="16"></a></td>
</tr>
{/foreach}
<tr>
<td colspan="13"><a href="admin.php?page=cronjob&amp;action=detail">{$LNG.cronjob_new}</a></td>
</tr>
</table>
</body>
{include file="overall_footer.tpl"}