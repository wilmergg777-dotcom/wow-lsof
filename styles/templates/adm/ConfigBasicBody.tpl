{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/adm/ConfigBasicBody.tpl === *}
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
<center>
<form action="" method="post">
<input type="hidden" name="opt_save" value="1">
<table width="70%" cellpadding="2" cellspacing="2">
<tr>
	<th colspan="2">{$LNG.se_server_parameters}</th>
	<th colspan="1" width="5%">(?)</th>
</tr><tr>
	<td>{$LNG.se_game_name}</td>
	<td><input name="game_name" value="{$game_name}" type="text" maxlength="60"></td>
	<td>&nbsp;</td>
</tr><tr>
    <td>{$LNG.se_ttf_file}</td>
    <td><input name="ttf_file" size="40" value="{$ttf_file}" type="text"></td>
	<td><img src="./styles/resource/images/admin/i.gif" width="16" height="16" alt="" class="tooltip" data-tooltip-content="{$LNG.se_ttf_file_info}"></td>
</tr><tr>
    <td>{$LNG.se_timzone}</td>
	<td>{html_options name=timezone options=$Selector.timezone selected=$timezone}</td>
	<td>&nbsp;</td>
</tr>
<tr>
	<th colspan="2">{$LNG.se_player_settings}</th><th>&nbsp;</th>
</tr><tr>
	<td>{$LNG.se_del_oldstuff}</td>
	<td><input name="del_oldstuff" maxlength="3" size="2" value="{$del_oldstuff}" type="text"> {$LNG.se_days}</td>
	<td><img src="./styles/resource/images/admin/i.gif" width="16" height="16" alt="" class="tooltip" data-tooltip-content="{$LNG.se_del_oldstuff_info}"></td>
</tr><tr>
	<td>{$LNG.se_del_user_manually}</td>
	<td><input name="del_user_manually" maxlength="3" size="2" value="{$del_user_manually}" type="text"> {$LNG.se_days}</td>
	<td><img src="./styles/resource/images/admin/i.gif" width="16" height="16" alt="" class="tooltip" data-tooltip-content="{$LNG.se_del_user_manually_info}"></td>
</tr><tr>
	<td>{$LNG.se_del_user_automatic}</td>
	<td><input name="del_user_automatic" maxlength="3" size="2" value="{$del_user_automatic}" type="text"> {$LNG.se_days}</td>
	<td><img src="./styles/resource/images/admin/i.gif" width="16" height="16" alt="" class="tooltip" data-tooltip-content="{$LNG.se_del_user_automatic_info}"></td>
</tr><tr>
	<td>{$LNG.se_sendmail_inactive}<br></td>
    <td><input name="sendmail_inactive"{if $sendmail_inactive} checked="checked"{/if}  type="checkbox"></td>
	<td>&nbsp;</td>
</tr><tr>
	<td>{$LNG.se_del_user_sendmail}</td>
	<td><input name="del_user_sendmail" maxlength="3" size="2" value="{$del_user_sendmail}" type="text"> {$LNG.se_days}</td>
	<td><img src="./styles/resource/images/admin/i.gif" width="16" height="16" alt="" class="tooltip" data-tooltip-content="{$LNG.se_del_user_sendmail_info}"></td>
</tr><tr>
	<th colspan="2">{$LNG.se_recaptcha_head}</th><th>&nbsp;</th>
</tr><tr>
	<td>{$LNG.se_recaptcha_active}<br></td>
    <td><input name="capaktiv"{if $capaktiv} checked="checked"{/if}  type="checkbox"></td>
	<td><img src="./styles/resource/images/admin/i.gif" width="16" height="16" alt="" class="tooltip" data-tooltip-content="{$LNG.se_recaptcha_desc}"></td>
</tr><tr>
	<td>{$LNG.se_recaptcha_public}</td>
	<td><input name="cappublic" maxlength="40" size="60" value="{$cappublic}" type="text"></td>
	<td>&nbsp;</td>
</tr><tr>
	<td>{$LNG.se_recaptcha_private}</td>
	<td><input name="capprivate" maxlength="40" size="60" value="{$capprivate}" type="text"></td>
	<td>&nbsp;</td>
</tr><tr>
	<th colspan="2">{$LNG.se_smtp}</th>
	<th><center><img src="./styles/resource/images/admin/i.gif" width="16" height="16" alt="" class="tooltip" data-tooltip-content="{$LNG.se_smtp_info}"></center></th>
</tr><tr>
	<td>{$LNG.se_mail_active}</td>
	<td><input name="mail_active"{if $mail_active} checked="checked"{/if}  type="checkbox"></td>
	<td>&nbsp;</td>
</tr><tr>
	<td>{$LNG.se_mail_use}</td>
	<td>{html_options name=mail_use options=$Selector.mail selected=$mail_use}</td>
	<td>&nbsp;</td>
</tr><tr>
	<td>{$LNG.se_smtp_sendmail}</td>
	<td><input name="smtp_sendmail" size="20" value="{$smtp_sendmail}" type="text" autocomplete="off"></td>
	<td><img src="./styles/resource/images/admin/i.gif" width="16" height="16" alt="" class="tooltip" data-tooltip-content="{$LNG.se_smtp_sendmail_info}"></td>
</tr><tr>
	<td>{$LNG.se_smail_path}</td>
	<td><input name="smail_path" size="20" value="{$smail_path}" type="text"></td>
	<td>&nbsp;</td>
</tr><tr>
	<td>{$LNG.se_smtp_host}</td>
	<td><input name="smtp_host" size="20" value="{$smtp_host}" type="text" autocomplete="off"></td>
	<td><img src="./styles/resource/images/admin/i.gif" width="16" height="16" alt="" class="tooltip" data-tooltip-content="{$LNG.se_smtp_host_info}"></td>
</tr><tr>
	<td>{$LNG.se_smtp_ssl}</td>
	<td>{html_options name=smtp_ssl options=$Selector.encry selected=$smtp_ssl}</td>
	<td><img src="./styles/resource/images/admin/i.gif" width="16" height="16" alt="" class="tooltip" data-tooltip-content="{$LNG.se_smtp_ssl_info}"></td>
</tr><tr>
	<td>{$LNG.se_smtp_port}</td>
	<td><input name="smtp_port" size="20" value="{$smtp_port}" type="text" autocomplete="off"></td>
	<td><img src="./styles/resource/images/admin/i.gif" width="16" height="16" alt="" class="tooltip" data-tooltip-content="{$LNG.se_smtp_port_info}"></td>
</tr><tr>
	<td>{$LNG.se_smtp_user}</td>
	<td><input name="smtp_user" size="20" value="{$smtp_user}" type="text" autocomplete="off"></td>
	<td>&nbsp;</td>
</tr><tr>
	<td>{$LNG.se_smtp_pass}</td>
	<td><input name="smtp_pass" size="20" value="{$smtp_pass}" type="password" autocomplete="off"></td>
	<td>&nbsp;</td>
</tr><tr>
	<th colspan="2">{$LNG.se_messages}</th><th>&nbsp;</th>
</tr><tr>
    <td>{$LNG.se_message_delete_behavior}</td>
    <td>{html_options name=message_delete_behavior options=$Selector.message_delete_behavior selected=$message_delete_behavior}</td>
	<td>&nbsp;</td>
</tr><tr>
    <td>{$LNG.se_message_delete_days}</td>
    <td><input name="message_delete_days" size="20" value="{$message_delete_days}" type="number"></td>
	<td>&nbsp;</td>
</tr><tr>
	<th colspan="2">{$LNG.se_google}</th><th>&nbsp;</th>
</tr><tr>
    <td>{$LNG.se_google_active}</td>
    <td><input name="ga_active"{if $ga_active} checked="checked"{/if}  type="checkbox"></td>
	<td><img src="./styles/resource/images/admin/i.gif" width="16" height="16" alt="" class="tooltip" data-tooltip-content="{$LNG.se_google_info}"></td>
</tr><tr>
    <td>{$LNG.se_google_key}</td>
    <td><input name="ga_key" size="20" maxlength="15" value="{$ga_key}" type="text"></td>
	<td><img src="./styles/resource/images/admin/i.gif" width="16" height="16" alt="" class="tooltip" data-tooltip-content="{$LNG.se_google_key_info}"></td>
</tr><tr>
	<th colspan="2">Discord Connect</th><th>&nbsp;</th>
</tr><tr>
    <td>Activar conexión con Discord</td>
    <td><input name="discord_on"{if $discord_on} checked="checked"{/if}  type="checkbox"></td>
	<td><img src="./styles/resource/images/admin/i.gif" width="16" height="16" alt="" class="tooltip" data-tooltip-content="Permite a los jugadores iniciar sesión usando su cuenta de Discord."></td>
</tr><tr>
    <td>Discord Client ID</td>
    <td><input name="discord_apikey" size="60" maxlength="64" value="{$discord_apikey}" type="text"></td>
	<td><img src="./styles/resource/images/admin/i.gif" width="16" height="16" alt="" class="tooltip" data-tooltip-content="El Client ID de tu aplicación de Discord (Developer Portal → OAuth2)."></td>
</tr><tr>
    <td>Discord Client Secret</td>
    <td><input name="discord_skey" size="60" maxlength="128" value="{$discord_skey}" type="text"></td>
	<td><img src="./styles/resource/images/admin/i.gif" width="16" height="16" alt="" class="tooltip" data-tooltip-content="El Client Secret de tu aplicación de Discord. No lo compartas con nadie."></td>
</tr><tr>
	<td colspan="3"><input value="{$LNG.se_save_parameters}" type="submit"></td>
</tr>
</table>
</form>
</center>
{include file="overall_footer.tpl"}