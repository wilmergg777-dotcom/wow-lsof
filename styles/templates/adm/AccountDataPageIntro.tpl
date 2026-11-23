{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/adm/AccountDataPageIntro.tpl === *}
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
<form action="" method="POST" name="users">
<table width="50%">
<th colspan="3">{$ac_enter_user_id}</th>
<tr>
<td>
	<select name="id_u" size="20" style="width:80%;">
		{$Userlist}
	</select>
	
	<SCRIPT type="text/javascript">
		var UserList = new filterlist(document.users.id_u);
	</SCRIPT>
	
	<br><br>
	<a href="javascript:UserList.set('^A')" title="{$bo_select_title} A">A</A>
	<a href="javascript:UserList.set('^B')" title="{$bo_select_title} B">B</A>
	<a href="javascript:UserList.set('^C')" title="{$bo_select_title} C">C</A>
	<a href="javascript:UserList.set('^D')" title="{$bo_select_title} D">D</A>

	<a href="javascript:UserList.set('^E')" title="{$bo_select_title} E">E</A>
	<a href="javascript:UserList.set('^F')" title="{$bo_select_title} F">F</A>
	<a href="javascript:UserList.set('^G')" title="{$bo_select_title} G">G</A>
	<a href="javascript:UserList.set('^H')" title="{$bo_select_title} H">H</A>
	<a href="javascript:UserList.set('^I')" title="{$bo_select_title} I">I</A>
	<a href="javascript:UserList.set('^J')" title="{$bo_select_title} J">J</A>
	<a href="javascript:UserList.set('^K')" title="{$bo_select_title} K">K</A>
	<a href="javascript:UserList.set('^L')" title="{$bo_select_title} L">L</A>
	<a href="javascript:UserList.set('^M')" title="{$bo_select_title} M">M</A>

	<a href="javascript:UserList.set('^N')" title="{$bo_select_title} N">N</A>
	<a href="javascript:UserList.set('^O')" title="{$bo_select_title} O">O</A>
	<a href="javascript:UserList.set('^P')" title="{$bo_select_title} P">P</A>
	<a href="javascript:UserList.set('^Q')" title="{$bo_select_title} Q">Q</A>
	<a href="javascript:UserList.set('^R')" title="{$bo_select_title} R">R</A>
	<a href="javascript:UserList.set('^S')" title="{$bo_select_title} S">S</A>
	<a href="javascript:UserList.set('^T')" title="{$bo_select_title} T">T</A>
	<a href="javascript:UserList.set('^U')" title="{$bo_select_title} U">U</A>
	<a href="javascript:UserList.set('^V')" title="{$bo_select_title} V">V</A>

	<a href="javascript:UserList.set('^W')" title="{$bo_select_title} W">W</A>
	<a href="javascript:UserList.set('^X')" title="{$bo_select_title} X">X</A>
	<a href="javascript:UserList.set('^Y')" title="{$bo_select_title} Y">Y</A>
	<a href="javascript:UserList.set('^Z')" title="{$bo_select_title} Z">Z</A>

	<br>
	<input name="regexp" onKeyUp="UserList.set(this.value)">
	<input type="button" onClick="UserList.set(this.form.regexp.value)" value="{$button_filter}">
	<input type="button" onClick="UserList.reset();this.form.regexp.value=''" value="{$button_deselect}">
</td>
</tr>
<tr><td height="45">{$ac_select_id_num}&nbsp;<input type="text" name="id_u2" size="4"></td></tr>
<tr><td colspan="3"><input type="Submit" value="{$button_submit}"></td></tr>
</table>
</form>
{include file="overall_footer.tpl"}