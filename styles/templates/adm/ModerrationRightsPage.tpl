{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/adm/ModerrationRightsPage.tpl === *}
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
<form action="" method="post" name="users">
<table width="55%">
<tr>
	<th colspan="7">{$ad_authlevel_title}</th>
</tr><tr>
	<td colspan="2">
	<select name="id_1" size="20" style="width:80%;">
		{$UserList}
	</select>
	
	<script type="text/javascript">
		var UserList = new filterlist(document.getElementsByName('id_1')[0]);
	</script>
	<br>
	<a href="?page=rights&amp;mode=rights&amp;sid={$sid}&amp;get=adm">{$ad_authlevel_aa}</a>&nbsp;
	<a href="?page=rights&amp;mode=rights&amp;sid={$sid}&amp;get=ope">{$ad_authlevel_oo}</a>&nbsp;
	<a href="?page=rights&amp;mode=rights&amp;sid={$sid}&amp;get=mod">{$ad_authlevel_mm}</a>&nbsp;
	<a href="?page=rights&amp;mode=rights&amp;sid={$sid}&amp;get=pla">{$ad_authlevel_jj}</a>&nbsp;
	<a href="?page=rights&amp;mode=rights&amp;sid={$sid}">{$ad_authlevel_tt}</a>&nbsp;
	<br><br>
	<a href="javascript:UserList.set('^A')" title="{$bo_select_title} A">A</a>
	<a href="javascript:UserList.set('^B')" title="{$bo_select_title} B">B</a>
	<a href="javascript:UserList.set('^C')" title="{$bo_select_title} C">C</a>
	<a href="javascript:UserList.set('^D')" title="{$bo_select_title} D">D</a>
	<a href="javascript:UserList.set('^E')" title="{$bo_select_title} E">E</a>
	<a href="javascript:UserList.set('^F')" title="{$bo_select_title} F">F</a>
	<a href="javascript:UserList.set('^G')" title="{$bo_select_title} G">G</a>
	<a href="javascript:UserList.set('^H')" title="{$bo_select_title} H">H</a>
	<a href="javascript:UserList.set('^I')" title="{$bo_select_title} I">I</a>
	<a href="javascript:UserList.set('^J')" title="{$bo_select_title} J">J</a>
	<a href="javascript:UserList.set('^K')" title="{$bo_select_title} K">K</a>
	<a href="javascript:UserList.set('^L')" title="{$bo_select_title} L">L</a>
	<a href="javascript:UserList.set('^M')" title="{$bo_select_title} M">M</a>
	<a href="javascript:UserList.set('^N')" title="{$bo_select_title} N">N</a>
	<a href="javascript:UserList.set('^O')" title="{$bo_select_title} O">O</a>
	<a href="javascript:UserList.set('^P')" title="{$bo_select_title} P">P</a>
	<a href="javascript:UserList.set('^Q')" title="{$bo_select_title} Q">Q</a>
	<a href="javascript:UserList.set('^R')" title="{$bo_select_title} R">R</a>
	<a href="javascript:UserList.set('^S')" title="{$bo_select_title} S">S</a>
	<a href="javascript:UserList.set('^T')" title="{$bo_select_title} T">T</a>
	<a href="javascript:UserList.set('^U')" title="{$bo_select_title} U">U</a>
	<a href="javascript:UserList.set('^V')" title="{$bo_select_title} V">V</a>
	<a href="javascript:UserList.set('^W')" title="{$bo_select_title} W">W</a>
	<a href="javascript:UserList.set('^X')" title="{$bo_select_title} X">X</a>
	<a href="javascript:UserList.set('^Y')" title="{$bo_select_title} Y">Y</a>
	<a href="javascript:UserList.set('^Z')" title="{$bo_select_title} Z">Z</a>

	<BR>
	<INPUT NAME="regexp" onKeyUp="UserList.set(this.value)">
	<INPUT TYPE="button" onClick="UserList.set(this.form.regexp.value)" value="{$button_filter}">
	<INPUT TYPE="button" onClick="UserList.reset();this.form.regexp.value=''" value="{$button_deselect}">
	</td>
</tr>
	<td colspan="3"><input type="submit" value="{$button_submit}"></td>
</tr>
</table>
{include file="overall_footer.tpl"}