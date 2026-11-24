{block name="title" prepend}{$LNG.lm_options}{/block}
{block name="content"}

{* ============================================================
   ASTROIO SETTINGS v4.0 — Configuración con tarjetas (estilo foto 2)
   Prefijo CSS: .astros_   (aislado, no rompe otros módulos)
   - Tarjetas: Perfil / Modo Vacaciones / Notificaciones / Galaxia y
     Flotas / Seguridad / Preferencias / Estadísticas / Zona de Peligro
   - TODAS las opciones originales se conservan (ids, names, Smarty):
     adminProtection, username, password, newpassword, newpassword2,
     email, permaEmail, Discord, timezone, language, planetSort,
     planetOrder, theme, queueMessages, spyMessagesMode, blockPM,
     spycount, fleetactions, galaxySpy, galaxyMessage, galaxyBuddyList,
     galaxyMissle, vacation, delete, banner (userpic)
   - NUEVO: subida de foto de avatar (funcional, visible para los demás)
   ============================================================ *}

{literal}
<style>
/* ====== ASTROIO Configuración (tarjetas) ====== */
.astros_wrap { max-width:640px; margin:0 auto; padding:0 4px }
.astros_card { background:rgba(15,23,42,.75); border:1px solid #1e293b; border-radius:14px; margin:0 auto 14px; overflow:hidden; backdrop-filter:blur(6px); -webkit-backdrop-filter:blur(6px) }
.astros_card_t { display:flex; align-items:center; gap:9px; padding:11px 14px; border-bottom:1px solid rgba(30,41,59,.8); background:linear-gradient(135deg,rgba(0,68,136,.85),rgba(0,119,204,.85)); color:#fff; font-weight:800; font-size:12.5px; letter-spacing:.4px; text-transform:uppercase; text-shadow:0 1px 2px rgba(0,0,0,.4) }
.astros_card_t .astros_ico { font-size:15px }
.astros_card_t.astros_t_danger { background:linear-gradient(135deg,rgba(120,20,30,.9),rgba(180,40,50,.9)); border-bottom:1px solid rgba(239,68,68,.6) }
.astros_card_b { padding:6px 0 }
.astros_row { display:flex; justify-content:space-between; align-items:center; gap:12px; padding:9px 14px; border-bottom:1px solid rgba(30,41,59,.55) }
.astros_row:last-child { border-bottom:none }
.astros_row:hover { background:rgba(0,224,255,.04) }
.astros_lbl { color:#cbd5e1; font-size:12px; font-weight:600; line-height:1.45 }
.astros_hint { display:block; color:#64748b; font-size:10.5px; font-weight:400; margin-top:2px }
.astros_field { width:46%; min-width:150px; max-width:280px }
.astros_field.wide { width:60% }
.astros_input { width:100%; box-sizing:border-box; padding:7px 10px; background:rgba(0,0,0,.5); border:1px solid rgba(0,204,255,.35); border-radius:8px; color:#fff; font-size:12px; font-family:inherit; outline:none; transition:.25s ease }
.astros_input:focus { border-color:#00e0ff; box-shadow:0 0 12px rgba(0,224,255,.5); background:rgba(0,0,0,.65) }
.astros_input[readonly] { color:#94a3b8; border-style:dashed; background:rgba(0,0,0,.35) }
select.astros_input { cursor:pointer }
select.astros_input option { background:#0f172a; color:#cbd5e1 }

/* switches (como la foto) */
.astros_switch { position:relative; display:inline-block; flex-shrink:0; cursor:pointer }
.astros_switch input { position:absolute; opacity:0; width:0; height:0 }
.astros_track { display:block; width:40px; height:21px; border-radius:11px; background:rgba(255,255,255,.15); transition:.2s ease; border:1px solid rgba(255,255,255,.12); box-sizing:border-box }
.astros_track::after { content:''; position:absolute; left:2px; top:2px; width:15px; height:15px; border-radius:50%; background:#94a3b8; transition:.2s ease }
.astros_switch input:checked + .astros_track { background:rgba(0,224,255,.4); border-color:rgba(0,224,255,.6) }
.astros_switch input:checked + .astros_track::after { left:21px; background:#00e0ff; box-shadow:0 0 8px rgba(0,224,255,.8) }
.astros_switch input:focus-visible + .astros_track { outline:1px solid #00e0ff }

/* avatar */
.astros_avatar_box { display:flex; align-items:center; gap:14px; padding:14px; flex-wrap:wrap }
.astros_avatar_box img { width:74px; height:74px; border-radius:50%; object-fit:cover; border:2px solid rgba(0,224,255,.55); box-shadow:0 0 16px rgba(0,224,255,.25); background:#0A1220 }
.astros_avatar_btns { display:flex; flex-direction:column; gap:7px }
.astros_btn { display:inline-flex; align-items:center; gap:6px; justify-content:center; padding:6px 14px; border-radius:8px; font-size:11.5px; font-weight:700; cursor:pointer; text-decoration:none !important; transition:.2s ease; border:1px solid transparent; letter-spacing:.3px }
.astros_btn_edit { background:linear-gradient(180deg,#0066cc,#0099ff); color:#fff !important; border-color:#00e0ff; position:relative; overflow:hidden }
.astros_btn_edit:hover { box-shadow:0 0 14px rgba(0,224,255,.5); transform:translateY(-1px) }
.astros_btn_del { background:rgba(239,68,68,.12); color:#ffb8b8 !important; border-color:rgba(239,68,68,.5) }
.astros_btn_del:hover { background:rgba(239,68,68,.2); color:#fff !important }
.astros_avatar_hint { flex-basis:100%; color:#64748b; font-size:10.5px; padding-left:2px }
.astros_filename { color:#00e0ff; font-size:11px; padding-left:2px }

/* danger */
.astros_row.astros_danger { background:rgba(239,68,68,.05) }
.astros_switch.astros_red input:checked + .astros_track { background:rgba(239,68,68,.45); border-color:rgba(239,68,68,.7) }
.astros_switch.astros_red input:checked + .astros_track::after { background:#ef4444; box-shadow:0 0 8px rgba(239,68,68,.8) }
.astros_warn { margin:10px 14px; background:rgba(251,191,36,.08); border:1px solid rgba(251,191,36,.4); color:#fde68a; border-radius:9px; padding:8px 12px; font-size:11px; line-height:1.5 }

/* estadísticas mini */
.astros_stats { display:flex; gap:10px; padding:12px 14px; flex-wrap:wrap }
.astros_stat { flex:1; min-width:120px; background:rgba(0,0,0,.3); border:1px solid #1e293b; border-radius:10px; padding:10px 12px; text-align:center }
.astros_stat_n { color:#fff; font-weight:800; font-size:16px; margin-top:3px }
.astros_stat_l { color:#64748b; font-size:10px; text-transform:uppercase; letter-spacing:.5px }
.astros_rank_pill { display:inline-block; border:1px solid rgba(251,191,36,.55); background:rgba(251,191,36,.08); color:#fbbf24; font-size:11px; font-weight:800; letter-spacing:.5px; text-transform:uppercase; border-radius:999px; padding:3px 12px }

/* banner */
.astros_banner { padding:12px 14px; text-align:center }
.astros_banner img { max-width:100%; height:auto; border-radius:8px; border:1px solid rgba(0,204,255,.3) }
.astros_banner table { width:100%; margin-top:8px }
.astros_banner td { padding:4px; text-align:left; color:#94a3b8; font-size:11px }
.astros_banner input[type=text] { width:100%; max-width:100% }

/* guardar */
.astros_save_row { text-align:center; padding:16px 0 4px }
.astros_save { display:inline-flex; align-items:center; gap:8px; padding:10px 34px; background:linear-gradient(180deg,#0066cc,#0099ff); color:#fff; border:1px solid #00e0ff; border-radius:9px; font-size:13px; font-weight:800; letter-spacing:.5px; text-transform:uppercase; cursor:pointer; font-family:inherit; transition:.25s ease; text-shadow:0 1px 2px rgba(0,0,0,.4) }
.astros_save:hover { box-shadow:0 0 20px rgba(0,224,255,.55); transform:translateY(-2px) }
.astros_save:active { transform:translateY(0) }

/* discord (conservado) */
.astros_discord_link { display:inline-flex; align-items:center; gap:8px; padding:6px 14px; border-radius:8px; font-weight:700; font-size:11.5px; background:linear-gradient(135deg,rgba(88,101,242,.9),rgba(71,82,196,.9)); color:#fff !important; border-color:#7289DA; text-decoration:none !important; transition:.2s ease }
.astros_discord_link:hover { box-shadow:0 0 14px rgba(88,101,242,.7); transform:translateY(-1px) }
.astros_discord_linked { display:inline-flex; align-items:center; gap:8px; padding:6px 14px; border-radius:8px; font-weight:700; font-size:11.5px; background:linear-gradient(135deg,rgba(26,58,26,.9),rgba(45,90,45,.9)); color:#b8ffb8 !important; border-color:#43b581 }
.astros_discord_unlink { color:#ff8080 !important; font-size:10.5px; text-decoration:none !important; margin-left:8px }
.astros_discord_unlink:hover { color:#fff !important }
.astros_discord_icon { width:15px; height:15px; flex-shrink:0 }
.astros_discord_acct { color:#64748b; font-size:10.5px; margin-top:3px }

@media (max-width:640px) {
        .astros_wrap { padding:0 2px }
        .astros_field, .astros_field.wide { width:100%; max-width:100% }
        .astros_row { flex-wrap:wrap; gap:8px }
        .astros_row .astros_lbl { flex-basis:100% }
        .astros_avatar_box { gap:10px }
}
</style>
{/literal}

<form action="game.php?page=settings" method="post" enctype="multipart/form-data">
<input type="hidden" name="mode" value="send">

<div class="astros_wrap">
        <div class="astros_card">
                <div class="astros_card_t"><span class="astros_ico">👤</span> Perfil</div>
                <div class="astros_card_b">

                        <div class="astros_avatar_box">
                                <img id="astros_avatar_img" src="{if $userHasAvatar}{$userAvatar}{else}{$AIO_AVATAR_DEF}{/if}" alt="avatar">
                                <div class="astros_avatar_btns">
                                        <label class="astros_btn astros_btn_edit">✏️ Editar foto
                                                <input type="file" name="avatar" id="astros_avatar_file" accept="image/jpeg,image/png,image/gif,image/webp" style="display:none">
                                        </label>
                                        {if $userHasAvatar}
                                        <a class="astros_btn astros_btn_del" href="game.php?page=settings&amp;mode=avatarRemove" onclick="return confirm('¿Quitar tu foto de perfil? Volverás al avatar por defecto.');">🗑️ Quitar foto</a>
                                        {/if}
                                </div>
                                <div class="astros_filename" id="astros_filename"></div>
                                <div class="astros_avatar_hint">JPG · PNG · GIF · WEBP — máx. 2 MB. Los demás jugadores verán esta foto en tu menú, tu tarjeta de jugador y las estadísticas.</div>
                        </div>

                        <div class="astros_row">
                                <span class="astros_lbl">{$LNG.op_username}</span>
                                <span class="astros_field">{if $changeNickTime < 0}<input class="astros_input" name="username" value="{$username}" type="text">{else}<input class="astros_input" value="{$username}" type="text" readonly>{/if}</span>
                        </div>
                        <div class="astros_row">
                                <span class="astros_lbl">{$LNG.op_old_pass}</span>
                                <span class="astros_field"><input class="astros_input autocomplete" name="password" type="password" autocomplete="current-password"></span>
                        </div>
                        <div class="astros_row">
                                <span class="astros_lbl">{$LNG.op_new_pass}<span class="astros_hint">Cambia tu contraseña y tu correo</span></span>
                                <span class="astros_field"><input class="astros_input autocomplete" name="newpassword" maxlength="40" type="password" autocomplete="new-password"></span>
                        </div>
                        <div class="astros_row">
                                <span class="astros_lbl">{$LNG.op_repeat_new_pass}</span>
                                <span class="astros_field"><input class="astros_input autocomplete" name="newpassword2" maxlength="40" type="password" autocomplete="new-password"></span>
                        </div>
                        <div class="astros_row">
                                <span class="astros_lbl"><a title="{$LNG.op_email_adress_descrip}" style="color:#00e0ff;cursor:help">{$LNG.op_email_adress}</a></span>
                                <span class="astros_field wide"><input class="astros_input" name="email" maxlength="64" value="{$email}" type="text"></span>
                        </div>
                        <div class="astros_row">
                                <span class="astros_lbl">{$LNG.op_permanent_email_adress}</span>
                                <span class="astros_field wide"><input class="astros_input" value="{$permaEmail}" type="text" readonly></span>
                        </div>
                        {if $discordEnable}
                        <div class="astros_row">
                                <span class="astros_lbl"><a title="Vincula tu cuenta de AstroIO con tu cuenta de Discord. Así podrás entrar al juego sin contraseña." style="color:#94a3b8;cursor:help">Discord</a></span>
                                <span>
                                        {if $discord_linked}
                                                <span class="astros_discord_linked">
                                                        <svg class="astros_discord_icon" viewBox="0 0 127.14 96.36" fill="currentColor"><path d="M107.7,8.07A105.15,105.15,0,0,0,81.47,0a72.06,72.06,0,0,0-3.36,6.83A97.68,97.68,0,0,0,49,6.83,72.37,72.37,0,0,0,45.64,0,105.89,105.89,0,0,0,19.39,8.09C2.79,32.65-1.71,56.6.54,80.21h0A105.73,105.73,0,0,0,32.71,96.36,77.7,77.7,0,0,0,39.6,85.25a68.42,68.42,0,0,1-10.85-5.18c.91-.66,1.8-1.34,2.66-2a75.57,75.57,0,0,0,64.32,0c.87.71,1.76,1.39,2.66,2a68.68,68.68,0,0,1-10.87,5.19,77,77,0,0,0,6.89,11.1A105.25,105.25,0,0,0,126.6,80.22h0C129.24,52.84,122.09,29.11,107.7,8.07ZM42.45,65.69C36.18,65.69,31,60,31,53s5-12.74,11.43-12.74S54,46,53.89,53,48.84,65.69,42.45,65.69Zm42.24,0C78.41,65.69,73.25,60,73.25,53s5-12.74,11.44-12.74S96.23,46,96.12,53,91.08,65.69,84.69,65.69Z"/></svg>
                                                        Discord vinculado
                                                </span>
                                                <a href="game.php?page=ExternalAuth&amp;method=discord&amp;unlink=1" class="astros_discord_unlink" onclick="return confirm('¿Seguro que quieres desvincular tu cuenta de Discord?');">Desvincular</a>
                                                <div class="astros_discord_acct">{$discord_account}</div>
                                        {else}
                                                <a href="game.php?page=ExternalAuth&amp;method=discord&amp;link=1" class="astros_discord_link">
                                                        <svg class="astros_discord_icon" viewBox="0 0 127.14 96.36" fill="currentColor"><path d="M107.7,8.07A105.15,105.15,0,0,0,81.47,0a72.06,72.06,0,0,0-3.36,6.83A97.68,97.68,0,0,0,49,6.83,72.37,72.37,0,0,0,45.64,0,105.89,105.89,0,0,0,19.39,8.09C2.79,32.65-1.71,56.6.54,80.21h0A105.73,105.73,0,0,0,32.71,96.36,77.7,77.7,0,0,0,39.6,85.25a68.42,68.42,0,0,1-10.85-5.18c.91-.66,1.8-1.34,2.66-2a75.57,75.57,0,0,0,64.32,0c.87.71,1.76,1.39,2.66,2a68.68,68.68,0,0,1-10.87,5.19,77,77,0,0,0,6.89,11.1A105.25,105.25,0,0,0,126.6,80.22h0C129.24,52.84,122.09,29.11,107.7,8.07ZM42.45,65.69C36.18,65.69,31,60,31,53s5-12.74,11.43-12.74S54,46,53.89,53,48.84,65.69,42.45,65.69Zm42.24,0C78.41,65.69,73.25,60,73.25,53s5-12.74,11.44-12.74S96.23,46,96.12,53,91.08,65.69,84.69,65.69Z"/></svg>
                                                        Vincular cuenta con Discord
                                                </a>
                                        {/if}
                                </span>
                        </div>
                        {/if}
                </div>
        </div>

        <div class="astros_card">
                <div class="astros_card_t"><span class="astros_ico">🏖️</span> Modo Vacaciones</div>
                <div class="astros_card_b">
                        <div class="astros_row">
                                <span class="astros_lbl"><a title="{$LNG.op_activate_vacation_mode_descrip}" style="color:#00e0ff;cursor:help">{$LNG.op_activate_vacation_mode}</a><span class="astros_hint">Tu producción se detiene mientras esté activo</span></span>
                                <label class="astros_switch"><input name="vacation" type="checkbox" value="1"><span class="astros_track"></span></label>
                        </div>
                        <div class="astros_warn">⚠️ Al activarlo no podrás atacar ni recibir ataques y la cuenta queda protegida tras el tiempo mínimo configurado por el administrador.</div>
                </div>
        </div>

        <div class="astros_card">
                <div class="astros_card_t"><span class="astros_ico">🔔</span> Notificaciones</div>
                <div class="astros_card_b">
                        <div class="astros_row">
                                <span class="astros_lbl">{$LNG.op_active_build_messages}<span class="astros_hint">Mensajes al terminar construcciones e investigaciones</span></span>
                                <label class="astros_switch"><input name="queueMessages" type="checkbox" value="1" {if $queueMessages == 1}checked="checked"{/if}><span class="astros_track"></span></label>
                        </div>
                        <div class="astros_row">
                                <span class="astros_lbl">{$LNG.op_active_spy_messages_mode}</span>
                                <label class="astros_switch"><input name="spyMessagesMode" type="checkbox" value="1" {if $spyMessagesMode == 1}checked="checked"{/if}><span class="astros_track"></span></label>
                        </div>
                        <div class="astros_row">
                                <span class="astros_lbl">{$LNG.op_block_pm}<span class="astros_hint">Nadie podrá enviarte mensajes privados</span></span>
                                <label class="astros_switch"><input name="blockPM" type="checkbox" value="1" {if $blockPM == 1}checked="checked"{/if}><span class="astros_track"></span></label>
                        </div>
                </div>
        </div>

        <div class="astros_card">
                <div class="astros_card_t"><span class="astros_ico">🌌</span> Galaxia y flotas</div>
                <div class="astros_card_b">
                        <div class="astros_row">
                                <span class="astros_lbl"><a title="{$LNG.op_spy_probes_number_descrip}" style="color:#00e0ff;cursor:help">{$LNG.op_spy_probes_number}</a></span>
                                <span class="astros_field"><input class="astros_input" name="spycount" size="{$spycount|count_characters + 3}" value="{$spycount}" type="int"></span>
                        </div>
                        <div class="astros_row">
                                <span class="astros_lbl">{$LNG.op_max_fleets_messages}</span>
                                <span class="astros_field"><input class="astros_input" name="fleetactions" maxlength="2" size="{$fleetActions|count_characters + 2}" value="{$fleetActions}" type="int"></span>
                        </div>
                        <div class="astros_row">
                                <span class="astros_lbl"><img src="{$dpath}img/e.gif" alt=""> {$LNG.op_spy}</span>
                                <label class="astros_switch"><input name="galaxySpy" type="checkbox" value="1" {if $galaxySpy == 1}checked="checked"{/if}><span class="astros_track"></span></label>
                        </div>
                        <div class="astros_row">
                                <span class="astros_lbl"><img src="{$dpath}img/m.gif" alt=""> {$LNG.op_write_message}</span>
                                <label class="astros_switch"><input name="galaxyMessage" type="checkbox" value="1" {if $galaxyMessage == 1}checked="checked"{/if}><span class="astros_track"></span></label>
                        </div>
                        <div class="astros_row">
                                <span class="astros_lbl"><img src="{$dpath}img/b.gif" alt=""> {$LNG.op_add_to_buddy_list}</span>
                                <label class="astros_switch"><input name="galaxyBuddyList" type="checkbox" value="1" {if $galaxyBuddyList == 1}checked="checked"{/if}><span class="astros_track"></span></label>
                        </div>
                        <div class="astros_row">
                                <span class="astros_lbl"><img src="{$dpath}img/r.gif" alt=""> {$LNG.op_missile_attack}</span>
                                <label class="astros_switch"><input name="galaxyMissle" type="checkbox" value="1" {if $galaxyMissle == 1}checked="checked"{/if}><span class="astros_track"></span></label>
                        </div>
                </div>
        </div>

        {if $userAuthlevel > 0}
        <div class="astros_card">
                <div class="astros_card_t"><span class="astros_ico">🛡️</span> Seguridad</div>
                <div class="astros_card_b">
                        <div class="astros_row">
                                <span class="astros_lbl">{$LNG.op_admin_planets_protection}</span>
                                <label class="astros_switch"><input name="adminprotection" type="checkbox" value="1" {if $adminProtection > 0}checked="checked"{/if}><span class="astros_track"></span></label>
                        </div>
                </div>
        </div>
        {/if}

        <div class="astros_card">
                <div class="astros_card_t"><span class="astros_ico">⚙️</span> Preferencias</div>
                <div class="astros_card_b">
                        <div class="astros_row">
                                <span class="astros_lbl">{$LNG.op_timezone}</span>
                                <span class="astros_field wide">{html_options name=timezone options=$Selectors.timezones selected=$timezone class="astros_input"}</span>
                        </div>
                        {* ✅ v2.4.2 — País del jugador: bandera en la tabla de estadísticas *}
                        <div class="astros_row">
                                <span class="astros_lbl">País (bandera en estadísticas)</span>
                                <span class="astros_field wide">{html_options name=country options=$countryList selected=$userCountry id="country" class="astros_input" onchange="astroioFlagPreview()"}</span>
                        </div>
                        <div class="astros_row">
                                <span class="astros_lbl">&nbsp;</span>
                                <span class="astros_field wide">
                                        <img id="astroio_flag_prev" src="styles/theme/gow/images/flags/{$userCountry|lower}.png" alt=""
                                             style="width:40px;height:27px;vertical-align:middle;border-radius:3px;box-shadow:0 0 0 1px rgba(255,255,255,.2);{if empty($userCountry)}display:none;{/if}">
                                </span>
                        </div>
                        <script>
                        function astroioFlagPreview(){
                                var v = document.getElementById('country').value;
                                var img = document.getElementById('astroio_flag_prev');
                                if(v){ img.src = 'styles/theme/gow/images/flags/' + v.toLowerCase() + '.png'; img.style.display = 'inline-block'; }
                                else { img.style.display = 'none'; }
                        }
                        </script>
                        {if count($Selectors.lang) > 1}
                        <div class="astros_row">
                                <span class="astros_lbl">{$LNG.op_lang}</span>
                                <span class="astros_field wide">{html_options name=language options=$Selectors.lang selected=$userLang class="astros_input"}</span>
                        </div>
                        {/if}
                        <div class="astros_row">
                                <span class="astros_lbl">{$LNG.op_sort_planets_by}</span>
                                <span class="astros_field wide">{html_options name=planetSort options=$Selectors.Sort selected=$planetSort class="astros_input"}</span>
                        </div>
                        <div class="astros_row">
                                <span class="astros_lbl">{$LNG.op_sort_kind}</span>
                                <span class="astros_field wide">{html_options name=planetOrder options=$Selectors.SortUpDown selected=$planetOrder class="astros_input"}</span>
                        </div>
                        {if count($Selectors.Skins) > 1}
                        <div class="astros_row">
                                <span class="astros_lbl">{$LNG.op_skin_example}</span>
                                <span class="astros_field wide">{html_options options=$Selectors.Skins selected=$theme name="theme" id="theme" class="astros_input"}</span>
                        </div>
                        {/if}
                </div>
        </div>

        <div class="astros_card">
                <div class="astros_card_t"><span class="astros_ico">📊</span> Estadísticas</div>
                <div class="astros_stats">
                        <div class="astros_stat">
                                <div class="astros_stat_l">Puntos</div>
                                <div class="astros_stat_n">{pretty_number($userPoints)}</div>
                        </div>
                        <div class="astros_stat">
                                <div class="astros_stat_l">Rango</div>
                                <div class="astros_stat_n" style="font-size:12px"><span class="astros_rank_pill">{$userRankName}</span></div>
                        </div>
                </div>
        </div>

        <div class="astros_card">
                <div class="astros_card_t astros_t_danger"><span class="astros_ico">⚠️</span> Zona de Peligro</div>
                <div class="astros_card_b">
                        <div class="astros_row astros_danger">
                                <span class="astros_lbl"><a title="{$LNG.op_dlte_account_descrip}" style="color:#00e0ff;cursor:help">{$LNG.op_dlte_account}</a><span class="astros_hint">Marca la casilla y guarda para programar el borrado de la cuenta</span></span>
                                <label class="astros_switch astros_red"><input name="delete" type="checkbox" value="1" {if $delete > 0}checked="checked"{/if}><span class="astros_track"></span></label>
                        </div>
                </div>
        </div>

        {if isModuleAvailable($smarty.const.MODULE_BANNER)}
        <div class="astros_card">
                <div class="astros_card_t"><span class="astros_ico">🖼️</span> {$LNG.ov_userbanner}</div>
                <div class="astros_banner">
                        <img src="userpic.php?id={$userid}" alt="" id="userpic">
                        <table>
                                <tr>
                                        <td>HTML:</td>
                                        <td><input class="astros_input" type="text" value='<a href="{$SELF_URL}{if isset($ref_active) && $ref_active}index.php?ref={$userid}{/if}"><img src="{$SELF_URL}userpic.php?id={$userid}"></a>' readonly="readonly"></td>
                                </tr>
                                <tr>
                                        <td>BBCode:</td>
                                        <td><input class="astros_input" type="text" value="[url={$SELF_URL}{if isset($ref_active) && $ref_active}index.php?ref={$userid}{/if}][img]{$SELF_URL}userpic.php?id={$userid}[/img][/url]" readonly="readonly"></td>
                                </tr>
                        </table>
                </div>
        </div>
        {/if}

        <div class="astros_save_row">
                <button type="submit" class="astros_save">💾 {$LNG.op_save_changes}</button>
        </div>
</div>
</form>

<script type="text/javascript">
{literal}
(function () {
        var input = document.getElementById('astros_avatar_file');
        var img   = document.getElementById('astros_avatar_img');
        var name  = document.getElementById('astros_filename');
        if (!input) return;
        input.addEventListener('change', function () {
                var file = input.files && input.files[0];
                if (!file) return;
                if (file.size > 2 * 1024 * 1024) {
                        alert('La foto no puede superar 2 MB.');
                        input.value = '';
                        return;
                }
                if (name) { name.textContent = file.name; }
                try {
                        var reader = new FileReader();
                        reader.onload = function (e) { if (img) { img.src = e.target.result; } };
                        reader.readAsDataURL(file);
                } catch (err) {}
        });
})();
{/literal}
</script>

{/block}