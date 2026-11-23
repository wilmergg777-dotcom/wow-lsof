{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/adm/SearchPage.tpl === *}
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
<form action="" method="POST">
<table width="90%">
<tr>
<td class="transparent left">
<input type="checkbox" {$minimize} name="minimize"><input type="submit" value="{$se_contrac}" class="button">
<img src="./styles/resource/images/admin/GO.png" onClick="javascript:$('#seeker').slideToggle();" style="cursor:pointer;padding-right:60px;" class="tooltip" data-tooltip-content="{$ac_minimize_maximize}">
</td>
</tr>
</table>
<div id="seeker"{$diisplaay}>
<table width="90%">
	<tr>
		<th colspan="8">
			{$se_search_title}
		</td>
	</tr>
	<tr>
		<td>
			{$se_intro}
		</td>
		<td>
			{$se_type_typee}
		</td>
		<td>
			{$se_search_in}
		</td>
		<td>
			{$se_filter_title}
		</td>
		<td>
			{$se_limit}
		</td>
		<td>
			{$se_asc_desc}
		</td>
		{if $OrderBYParse}
		<td>
			{$se_search_order}
		</td>
		{/if}
		<td>
			&nbsp;
		</td>
	</tr>
<tr>
	<td>
		<input type="text" name="key_user" value="{$search}">
	</td>
	<td>
		{html_options name=search options=$Selector.list selected=$SearchFile}
	</td>
	<td>
		{html_options name=search_in options=$Selector.search selected=$SearchFor}
	</td>
	<td>
		{html_options name=fucki options=$Selector.filter selected=$SearchMethod}
	</td>
	<td>
		{html_options name=limit options=$Selector.limit selected=$limit}
	</td>
	<td>
		{html_options name=key_acc options=$Selector.order selected=$OrderBY}
	</td>
	{if $OrderBYParse}
	<td>
		{html_options name=key_order options=$OrderBYParse selected=$Order}
	</td>
	{/if}
	<td>
		<input type="submit" value="{$se_search}">
	</td>
</tr>
{if !empty($error)}
<tr>
	<td colspan="8">
		<span style="color:red">{$error}</span>
	</td>
</tr>
{/if}
</table>
</div>
<br>
<table width="90%" border="0px">
{$PAGES}
</table>
{$LIST}
<br>
<table width="90%" border="0px">
{$PAGES}
</table>
</form>