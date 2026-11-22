En includes/pages/login/AbstractLoginPage.class.php

Despues de: 

'languages'				=> Language::getAllowedLangs(false),

Añades:

'google_on'				=> Config::get()->google_on,

En includes/pages/admin/ShowConfigBasicPage.php

Despues de: 

'message_delete_days'	=> $config->message_delete_days,

Añades:

'google_on'				=> $config->google_on,
'google_apikey'			=> $config->google_apikey,
'google_skey'			=> $config->google_skey,

Despues de:

$message_delete_days	= HTTP::_GP('message_delete_days', 0);

Añades:

$google_on		= HTTP::_GP('google_on', 0);
$google_apikey	= HTTP::_GP('google_apikey', '');
$google_skey	= HTTP::_GP('google_skey', '');

Despues de:

'message_delete_days'	=> $message_delete_days,

Añades:

'google_on'				=> $google_on,
'google_apikey'			=> $google_apikey,
'google_skey'			=> $google_skey

Despues de:

'message_delete_days'         	=> $config->message_delete_days,

Añades:

'google_on'         			=> $config->google_on,
'google_apikey'         		=> $config->google_apikey,
'google_skey'         			=> $config->google_skey,

En styles/templates/adm/ConfigBasicBody.tpl

Despues de:

<tr>
    <td>{$LNG.se_google_key}</td>
    <td><input name="ga_key" size="20" maxlength="15" value="{$ga_key}" type="text"></td>
	<td><img src="./styles/resource/images/admin/i.gif" width="16" height="16" alt="" class="tooltip" data-tooltip-content="{$LNG.se_google_key_info}"></td>
</tr>

Añades:

<tr>
	<th colspan="2">{$LNG.google_config}</th>
</tr><tr>
	<td>{$LNG.google_on}</td>
	<td><input type="checkbox" name="google_on" {if $google_on}checked="checked"{/if} value="1">
</tr><tr>
	<td>{$LNG.se_recaptcha_public}</td>
	<td><input type="text" name="google_apikey" value="{$google_apikey}" size="60">
</tr><tr>
	<td>{$LNG.se_recaptcha_private}</td>
	<td><input type="text" name="google_skey" value="{$google_skey}">
</tr>

En language/en/ADMIN.php

Despues de:

$LNG['du_not_tables_selected']		= '...';

Añades:

$LNG['google_config']               = 'Google Login Configuration';
$LNG['google_on']                   = 'Activate Login With Google';

En styles/templates/login/page.index.default.tpl

Despues de:

<div style="text-align: center">

Añades:

{if $google_on}
<a href="index.php?page=externalAuth&method=google">
    {$LNG.google_connect}
</a>
<br>
{/if}

En language/en/PUBLIC.php

Añades:

$LNG['google_connect'] = 'Connect With Google';
$LNG['mail_google_subject'] = 'New registration on %s';