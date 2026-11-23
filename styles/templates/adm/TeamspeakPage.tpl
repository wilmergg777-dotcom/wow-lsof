{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/adm/TeamspeakPage.tpl === *}
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
<script type='text/javascript'>
function change2(){
	$("#lang_udp").text("{$ts_udpport}:");
	document.getElementsByName("ts_v")[0].checked = true;
	$(".v3only").hide();
}
function change3(){
	$("#lang_udp").text("{$ts_server_query}:");
	document.getElementsByName("ts_v")[1].checked = true;
	$(".v3only").show();
}
</script>

<form action="" method="post">
<input type="hidden" name="opt_save" value="1">
<table width="519" cellpadding="2" cellspacing="2">
<tr>
	<th colspan="2">{$ts_settings}</th>
</tr><tr>
	<td>{$ts_active}<br></td>
	<td><input name="ts_on"{if $ts_on == 1} checked="checked"{/if} type="checkbox"></td>
</tr><tr>
	<td>{$ts_version}</td>
	<td><input type="radio" name="ts_v" value="2" onclick="change2();"> 2 
    <input type="radio" name="ts_v" value="3" onclick="change3();"> 3</td>
</tr><tr>
	<td>{$ts_serverip}:</td>
	<td><input name="ts_ip" maxlength="15" size="10" value="{$ts_ip}" type="text"></td>
</tr><tr>
	<td>{$ts_tcpport}:</td>
	<td><input name="ts_tcp" maxlength="5" size="10" value="{$ts_tcp}" type="text"></td>
</tr><tr>
	<td id="lang_udp">{$ts_udpport}:</td>
	<td><input name="ts_udp" maxlength="5" size="10" value="{$ts_udp}" type="text"></td>
</tr><tr class="v3only">
	<td>{$ts_sq_login}:</td>
	<td><input name="ts_login" size="20" value="{$ts_login}" type="text"></td>
</tr><tr class="v3only">
	<td>{$ts_sq_pass}:</td>
	<td><input name="ts_password" size="20" value="{$ts_password}" type="password"></td>
</tr><tr>
	<td>{$ts_timeout}:</td>
	<td><input name="ts_to" maxlength="2" size="10" value="{$ts_to}" type="text"></td>
</tr><tr>
	<td>{$ts_lng_cron}:</td>
	<td><input name="ts_cron" maxlength="2" size="10" value="{$ts_cron}" type="text"></td>
</tr><tr>
	<td colspan="3"><input value="{$se_save_parameters}" type="submit"></td>
</tr>
</table>
<script type="text/javascript">
change{$ts_v}();
</script>
</form>
{include file="overall_footer.tpl"}