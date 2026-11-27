{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/adm/ModerrationUsersPage.tpl === *}
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


<form action="" method="post" name="users">
{include file="overall_header.tpl"}
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
	<a href="?page=rights&amp;mode=users&amp;sid={$sid}&amp;get=adm">{$ad_authlevel_aa}</a>&nbsp;
	<a href="?page=rights&amp;mode=users&amp;sid={$sid}&amp;get=ope">{$ad_authlevel_oo}</a>&nbsp;
	<a href="?page=rights&amp;mode=users&amp;sid={$sid}&amp;get=mod">{$ad_authlevel_mm}</a>&nbsp;
	<a href="?page=rights&amp;mode=users&amp;sid={$sid}&amp;get=pla">{$ad_authlevel_jj}</a>&nbsp;
	<a href="?page=rights&amp;mode=users&amp;sid={$sid}">{$ad_authlevel_tt}</a>&nbsp;
	<br><br>
	<A HREF="javascript:UserList.set('^A')" TITLE="{$bo_select_title} A">A</A>
	<A HREF="javascript:UserList.set('^B')" TITLE="{$bo_select_title} B">B</A>
	<A HREF="javascript:UserList.set('^C')" TITLE="{$bo_select_title} C">C</A>
	<A HREF="javascript:UserList.set('^D')" TITLE="{$bo_select_title} D">D</A>

	<A HREF="javascript:UserList.set('^E')" TITLE="{$bo_select_title} E">E</A>
	<A HREF="javascript:UserList.set('^F')" TITLE="{$bo_select_title} F">F</A>
	<A HREF="javascript:UserList.set('^G')" TITLE="{$bo_select_title} G">G</A>
	<A HREF="javascript:UserList.set('^H')" TITLE="{$bo_select_title} H">H</A>
	<A HREF="javascript:UserList.set('^I')" TITLE="{$bo_select_title} I">I</A>
	<A HREF="javascript:UserList.set('^J')" TITLE="{$bo_select_title} J">J</A>
	<A HREF="javascript:UserList.set('^K')" TITLE="{$bo_select_title} K">K</A>
	<A HREF="javascript:UserList.set('^L')" TITLE="{$bo_select_title} L">L</A>
	<A HREF="javascript:UserList.set('^M')" TITLE="{$bo_select_title} M">M</A>

	<A HREF="javascript:UserList.set('^N')" TITLE="{$bo_select_title} N">N</A>
	<A HREF="javascript:UserList.set('^O')" TITLE="{$bo_select_title} O">O</A>
	<A HREF="javascript:UserList.set('^P')" TITLE="{$bo_select_title} P">P</A>
	<A HREF="javascript:UserList.set('^Q')" TITLE="{$bo_select_title} Q">Q</A>
	<A HREF="javascript:UserList.set('^R')" TITLE="{$bo_select_title} R">R</A>
	<A HREF="javascript:UserList.set('^S')" TITLE="{$bo_select_title} S">S</A>
	<A HREF="javascript:UserList.set('^T')" TITLE="{$bo_select_title} T">T</A>
	<A HREF="javascript:UserList.set('^U')" TITLE="{$bo_select_title} U">U</A>
	<A HREF="javascript:UserList.set('^V')" TITLE="{$bo_select_title} V">V</A>

	<A HREF="javascript:UserList.set('^W')" TITLE="{$bo_select_title} W">W</A>
	<A HREF="javascript:UserList.set('^X')" TITLE="{$bo_select_title} X">X</A>
	<A HREF="javascript:UserList.set('^Y')" TITLE="{$bo_select_title} Y">Y</A>
	<A HREF="javascript:UserList.set('^Z')" TITLE="{$bo_select_title} Z">Z</A>

	<BR>
	<INPUT NAME="regexp" onKeyUp="UserList.set(this.value)">
	<INPUT TYPE="button" onClick="UserList.set(this.form.regexp.value)" value="{$button_filter}">
	<INPUT TYPE="button" onClick="UserList.reset();this.form.regexp.value=''" value="{$button_deselect}">
	</td>
</tr><tr>
	<td>{$ad_authlevel_insert_id}</td>
	<td><input name="id_2" type="text" size="5"></td>
</tr><tr>
	<td>{$ad_authlevel_auth}</td>
	<td>{html_options name=authlevel options=$Selector}</td>
</tr><tr>
	<td colspan="3"><input type="submit" value="{$button_submit}"></td>
</tr>
</table>
{include file="overall_footer.tpl"}