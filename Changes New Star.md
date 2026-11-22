En includes/pages/login/AbstractLoginPage.class.php

Despues de: 

'languages'				=> Language::getAllowedLangs(false),

Añades:

'google_on'				=> Config::get()->google_on,

En includes/pages/admin/ShowConfigUniPage.class.php

Despues de:

'facebook'				    => array('fb_on', 'fb_apikey', 'fb_skey'),

Añades:

'google'				    => array('google_on', 'google_apikey', 'google_skey'),

Despues de:

$config_class['facebook']

Añades:

$config_class['google']

En language/en/ADMIN.php

Despues de:

$LNG['cu_fb_skey']                                 = 'Private key';

Añades:

$LNG['cu_class_google']                            = 'Google';
$LNG['cu_google_on']                               = 'Enable Google';
$LNG['cu_google_apikey']                           = 'API ID';
$LNG['cu_google_skey']                             = 'Private key';

En styles/theme/nsc/templates/login/page.index.default.tpl

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