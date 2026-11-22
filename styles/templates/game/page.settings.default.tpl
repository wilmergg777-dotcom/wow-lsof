{block name="title" prepend}{$LNG.lm_options}{/block}
{block name="content"}

{* ============================================================
   ASTROIO SETTINGS v3.0 — Estilo Xnova moderno (glassmorphism)
   Prefijo CSS: .astroset_   (aislado, no rompe otros módulos)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism)
     - Overrides !important mantenidos (core usa .content_page genérico)
     - Inputs/selects con radius 8px + focus translateY
     - Botones con radius 8px + hover translateY
     - Bloque Discord preservado intacto
     - IDs, names, Smarty y estructura original intactos
   FIX v3.0.1 (responsive banner):
     - Banner userpic se adapta al ancho en mobile
     - Tabla interna HTML/BBCode y sus inputs readonly no desbordan
   ============================================================ *}

<style>
/* ====== Variables globales ====== */
:root {
    --bg-dark:       rgba(11, 16, 30, 0.55);
    --bg-card:       rgba(15, 23, 42, 0.75);
    --bg-card-solid: rgba(15, 23, 42, 0.85);
    --bg-inner:      rgba(0, 0, 0, 0.35);
    --border-color:  #1e293b;
    --text-main:     #cbd5e1;
    --text-muted:    #94a3b8;
    --text-title:    #ffffff;
    --accent-blue:   #3b82f6;
    --accent-cyan:   #00e0ff;
    --accent-purple: #8b5cf6;
    --accent-gold:   #fbbf24;
    --accent-green:  #4aff88;
    --accent-red:    #ef4444;
}

/* ====== Panel principal (mismo ancho original) ====== */
.content_page {
    color: var(--text-main);
}

/* ====== Título principal ====== */
.content_page > .title {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85)) !important;
    backdrop-filter: blur(6px) !important;
    -webkit-backdrop-filter: blur(6px) !important;
    color: #ffffff !important;
    border-bottom: 2px solid var(--accent-cyan) !important;
    border-radius: 12px 12px 0 0 !important;
    padding: 10px 14px !important;
    font-weight: 700 !important;
    font-size: 13px !important;
    letter-spacing: 0.5px !important;
    text-shadow: 0 1px 3px rgba(0, 0, 0, 0.4) !important;
}

/* ====== Tabla ====== */
.content_page table {
    background: transparent !important;
}

/* ====== Cabeceras de bloque ====== */
.content_page tr.title {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85)) !important;
    backdrop-filter: blur(6px) !important;
    -webkit-backdrop-filter: blur(6px) !important;
}
.content_page tr.title th {
    color: #ffffff !important;
    padding: 6px 10px !important;
    font-weight: 700 !important;
    font-size: 11px !important;
    letter-spacing: 0.6px !important;
    text-transform: uppercase !important;
    text-align: center !important;
    border-top: 2px solid var(--accent-cyan) !important;
    border-bottom: 1px solid var(--accent-cyan) !important;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4) !important;
}

/* ====== Filas de datos ====== */
.content_page tbody tr:not(.title) {
    background: rgba(0, 0, 0, 0.3) !important;
    border-bottom: 1px solid rgba(0, 204, 255, 0.06) !important;
    transition: 0.15s ease !important;
}
.content_page tbody tr:not(.title):hover {
    background: rgba(0, 204, 255, 0.07) !important;
}
.content_page tbody td {
    padding: 5px 10px !important;
    color: var(--text-main) !important;
    vertical-align: middle !important;
}
.content_page tbody td:first-child {
    color: var(--text-muted) !important;
    font-weight: 600 !important;
}
.content_page tbody td:last-child {
    color: var(--text-title) !important;
}
.content_page tbody td a {
    color: #00e0ff !important;
    text-decoration: none !important;
    font-weight: 600 !important;
    transition: 0.15s ease !important;
    cursor: help !important;
}
.content_page tbody td a:hover {
    color: #ffffff !important;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.9) !important;
}

/* ====== Inputs ====== */
.content_page input[type="text"],
.content_page input[type="password"],
.content_page input[type="int"] {
    padding: 5px 8px !important;
    background: rgba(0, 0, 0, 0.5) !important;
    border: 1px solid rgba(0, 204, 255, 0.35) !important;
    border-radius: 8px !important;
    color: #ffffff !important;
    font-family: 'Courier New', monospace !important;
    font-weight: 700 !important;
    outline: none !important;
    transition: 0.25s ease !important;
    box-sizing: border-box !important;
}
.content_page input[type="text"]:focus,
.content_page input[type="password"]:focus,
.content_page input[type="int"]:focus {
    border-color: #00ccff !important;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5) !important;
    background: rgba(0, 0, 0, 0.65) !important;
    transform: translateY(-1px) !important;
}

/* ====== Checkbox ====== */
.content_page input[type="checkbox"] {
    accent-color: #00ccff !important;
    width: 15px !important;
    height: 15px !important;
    cursor: pointer !important;
    vertical-align: middle !important;
}

/* ====== Selects ====== */
.content_page select {
    padding: 5px 10px !important;
    background: rgba(0, 0, 0, 0.5) !important;
    border: 1px solid rgba(0, 204, 255, 0.35) !important;
    border-radius: 8px !important;
    color: #ffffff !important;
    font-weight: 700 !important;
    font-family: inherit !important;
    cursor: pointer !important;
    outline: none !important;
    transition: 0.25s ease !important;
}
.content_page select:hover,
.content_page select:focus {
    border-color: #00ccff !important;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5) !important;
    transform: translateY(-1px) !important;
}
.content_page select option {
    background: #0f1624 !important;
    color: #ffffff !important;
}

/* ====== Imágenes de atajos ====== */
.content_page img {
    vertical-align: middle !important;
    margin-right: 4px !important;
    border-radius: 3px !important;
    border: 1px solid rgba(0, 204, 255, 0.2) !important;
}

/* ====== Bloque del banner (mantiene tamaño original) ====== */
.content_page img#userpic {
    border-radius: 8px !important;
    border: 1px solid rgba(0, 204, 255, 0.3) !important;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.2) !important;
}

/* ====== Botón guardar ====== */
.content_page input[type="submit"] {
    padding: 8px 26px !important;
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9) 0%, rgba(0, 153, 255, 0.9) 100%) !important;
    border: 1px solid #00ccff !important;
    border-radius: 8px !important;
    color: #ffffff !important;
    font-weight: 700 !important;
    cursor: pointer !important;
    transition: 0.25s ease !important;
    letter-spacing: 0.4px !important;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4) !important;
    text-transform: uppercase !important;
}
.content_page input[type="submit"]:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95) 0%, rgba(0, 204, 255, 0.95) 100%) !important;
    box-shadow: 0 0 16px rgba(0, 224, 255, 0.6) !important;
    transform: translateY(-2px) !important;
}
.content_page input[type="submit"]:active {
    transform: translateY(0) !important;
}

/* ====== Discord Link (AstroIO) ====== */
.astroset_discord_box {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 6px 14px;
    border-radius: 8px;
    font-weight: 700;
    font-size: 12px;
    text-decoration: none;
    transition: 0.25s ease;
    letter-spacing: 0.3px;
    cursor: pointer;
    border: 1px solid transparent;
}
.astroset_discord_link {
    background: linear-gradient(135deg, rgba(88, 101, 242, 0.9) 0%, rgba(71, 82, 196, 0.9) 100%);
    color: #ffffff !important;
    border-color: #7289DA;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astroset_discord_link:hover {
    background: linear-gradient(135deg, rgba(71, 82, 196, 0.95) 0%, rgba(88, 101, 242, 0.95) 100%);
    box-shadow: 0 0 14px rgba(88, 101, 242, 0.7);
    transform: translateY(-2px);
}
.astroset_discord_linked {
    background: linear-gradient(135deg, rgba(26, 58, 26, 0.9) 0%, rgba(45, 90, 45, 0.9) 100%);
    color: #b8ffb8 !important;
    border-color: #43b581;
}
.astroset_discord_unlink {
    background: linear-gradient(135deg, rgba(74, 26, 26, 0.9) 0%, rgba(107, 32, 32, 0.9) 100%);
    color: #ffb8b8 !important;
    border-color: #c94a4a;
    padding: 5px 12px;
    font-size: 11px;
    border-radius: 6px;
    text-decoration: none;
    font-weight: 700;
    transition: 0.25s ease;
    margin-left: 6px;
    display: inline-block;
}
.astroset_discord_unlink:hover {
    background: linear-gradient(135deg, rgba(107, 32, 32, 0.95) 0%, rgba(139, 42, 42, 0.95) 100%);
    box-shadow: 0 0 10px rgba(201, 74, 74, 0.6);
    color: #ffffff !important;
    transform: translateY(-1px);
}
.astroset_discord_icon {
    width: 16px;
    height: 16px;
    flex-shrink: 0;
}
.astroset_discord_account {
    color: var(--text-muted);
    font-family: 'Courier New', monospace;
    font-size: 11px;
    margin-left: 4px;
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    /* 1. Contenedor principal */
    .content_page {
        padding: 5px 8px !important;
        box-sizing: border-box !important;
        width: 100% !important;
        overflow: hidden !important;
    }

    /* 2. Tabla principal */
    .content_page > table {
        display: table !important;
        width: 100% !important;
        table-layout: fixed !important; 
        box-sizing: border-box !important;
        border-collapse: collapse !important;
    }
    
    .content_page tbody { display: table-row-group !important; }
    .content_page tr { display: table-row !important; }

    /* 3. Celdas (AQUÍ ESTÁ EL TRUCO: ignorar las celdas con colspan) */
    .content_page td {
        display: table-cell !important;
        padding: 6px 4px !important;
        font-size: 11px !important;
        vertical-align: middle !important;
        word-break: break-word !important; 
        box-sizing: border-box !important;
    }
    
    /* Solo aplicamos el 50% a las celdas normales (sin colspan) */
    .content_page td:not([colspan]):first-child { 
        width: 50% !important; 
        text-align: left !important;
    } 
    .content_page td:not([colspan]):last-child { 
        width: 50% !important; 
        text-align: center !important; 
    }  

    /* 4. Inputs, Selects y Checkboxes */
    .content_page input[type="text"],
    .content_page input[type="password"],
    .content_page input[type="int"],
    .content_page select {
        width: 100% !important;
        max-width: 100% !important;
        box-sizing: border-box !important;
        padding: 6px !important;
        font-size: 11px !important;
        margin: 0 auto !important;
        display: block !important;
    }

    .content_page input[type="checkbox"] {
        width: 20px !important;
        height: 20px !important;
        margin: 0 auto !important;
        display: block !important;
    }

    /* 5. Títulos de sección */
    .content_page tr.title th {
        white-space: normal !important;
        word-break: break-word !important;
        font-size: 11px !important;
        padding: 6px !important;
        text-align: center !important;
    }

    /* ====== 6. ARREGLO DEL BANNER (AHORA SÍ) ====== */
    
    /* La celda con colspan ocupa TODO el ancho de la tabla */
    .content_page td[colspan] {
        display: table-cell !important;
        width: 100% !important;
        max-width: 100% !important;
        box-sizing: border-box !important;
        padding: 10px !important;
        text-align: center !important;
    }

    /* La imagen del banner se estira al 100% */
    .content_page img#userpic {
        width: 100% !important;
        max-width: 100% !important;
        height: auto !important;
        display: block !important;
        margin: 0 auto 10px auto !important;
    }

    /* La tabla interna (HTML/BBCode) ocupa el 100% */
    .content_page td[colspan] table {
        width: 100% !important;
        max-width: 100% !important;
        table-layout: fixed !important;
        margin: 0 auto !important;
    }

    /* Celdas de la tabla interna */
    .content_page td[colspan] table td {
        display: table-cell !important;
        width: auto !important;
        padding: 4px !important;
        text-align: left !important;
    }

    /* Inputs del banner ignoran el style="450px" */
    .content_page td[colspan] table input[type="text"] {
        width: 100% !important;
        max-width: 100% !important;
        box-sizing: border-box !important;
        font-size: 10px !important;
    }

    /* 7. Botón Guardar */
    .content_page input[type="submit"] {
        width: 100% !important;
        padding: 12px !important;
        font-size: 13px !important;
        margin-top: 15px !important;
        display: block !important;
    }

    /* 8. Discord */
    .astroset_discord_box { 
        width: 100% !important; 
        justify-content: center !important; 
        box-sizing: border-box !important; 
        font-size: 11px !important;
        padding: 8px !important;
        margin: 0 auto !important;
        display: flex !important;
    }
    
    .astroset_discord_unlink {
        width: 100% !important;
        margin: 6px 0 0 0 !important;
        text-align: center !important;
        box-sizing: border-box !important;
        display: block !important;
    }
}
</style>

<form action="game.php?page=settings" method="post">
<input type="hidden" name="mode" value="send">

<div class="content_page">
	<div class="title">
		{$LNG.lm_options}
	</div>

	<div>
		<table style="width:100%;">
			<tbody>
				{if $userAuthlevel > 0}
				<tr class="title">
					<th colspan="2">{$LNG.op_admin_title_options}</th>
				</tr>
				<tr>
					<td>{$LNG.op_admin_planets_protection}</td>
					<td><input name="adminprotection" type="checkbox" value="1" {if $adminProtection > 0}checked="checked"{/if}></td>
				</tr>
				{/if}
				<tr class="title">
					<th colspan="2">{$LNG.op_user_data}</th>
				</tr>
				<tr>
					<td width="50%">{$LNG.op_username}</td>
					<td width="50%" style="height:22px;">{if $changeNickTime < 0}<input name="username" size="20" value="{$username}" type="text">{else}{$username}{/if}</td>
				</tr>
				<tr>
					<td>{$LNG.op_old_pass}</td>
					<td><input name="password" size="20" type="password" class="autocomplete"></td>
				</tr>
				<tr>
					<td>{$LNG.op_new_pass}</td>
					<td><input name="newpassword" size="20" maxlength="40" type="password" class="autocomplete"></td>
				</tr>
				<tr>
					<td>{$LNG.op_repeat_new_pass}</td>
					<td><input name="newpassword2" size="20" maxlength="40" type="password" class="autocomplete"></td>
				</tr>
				<tr>
					<td><a title="{$LNG.op_email_adress_descrip}">{$LNG.op_email_adress}</a></td>
					<td><input name="email" maxlength="64" size="20" value="{$email}" type="text"></td>
				</tr>
				<tr>
					<td style="height:22px;">{$LNG.op_permanent_email_adress}</td>
					<td>{$permaEmail}</td>
				</tr>
				{if $discordEnable}
				<tr>
					<td>
						<a title="Vincula tu cuenta de AstroIO con tu cuenta de Discord. Así podrás entrar al juego sin contraseña." style="color:#94a3b8; font-weight:600; cursor:help;">Discord</a>
					</td>
					<td>
						{if $discord_linked}
							<span class="astroset_discord_box astroset_discord_linked">
								<svg class="astroset_discord_icon" viewBox="0 0 127.14 96.36" fill="currentColor">
									<path d="M107.7,8.07A105.15,105.15,0,0,0,81.47,0a72.06,72.06,0,0,0-3.36,6.83A97.68,97.68,0,0,0,49,6.83,72.37,72.37,0,0,0,45.64,0,105.89,105.89,0,0,0,19.39,8.09C2.79,32.65-1.71,56.6.54,80.21h0A105.73,105.73,0,0,0,32.71,96.36,77.7,77.7,0,0,0,39.6,85.25a68.42,68.42,0,0,1-10.85-5.18c.91-.66,1.8-1.34,2.66-2a75.57,75.57,0,0,0,64.32,0c.87.71,1.76,1.39,2.66,2a68.68,68.68,0,0,1-10.87,5.19,77,77,0,0,0,6.89,11.1A105.25,105.25,0,0,0,126.6,80.22h0C129.24,52.84,122.09,29.11,107.7,8.07ZM42.45,65.69C36.18,65.69,31,60,31,53s5-12.74,11.43-12.74S54,46,53.89,53,48.84,65.69,42.45,65.69Zm42.24,0C78.41,65.69,73.25,60,73.25,53s5-12.74,11.44-12.74S96.23,46,96.12,53,91.08,65.69,84.69,65.69Z"/>
								</svg>
								Discord vinculado
							</span>
							<a href="game.php?page=ExternalAuth&method=discord&unlink=1"
							   class="astroset_discord_unlink"
							   onclick="return confirm('¿Seguro que quieres desvincular tu cuenta de Discord?');">
								Desvincular
							</a>
							<div class="astroset_discord_account">{$discord_account}</div>
						{else}
							<a href="game.php?page=ExternalAuth&method=discord&link=1"
							   class="astroset_discord_box astroset_discord_link">
								<svg class="astroset_discord_icon" viewBox="0 0 127.14 96.36" fill="currentColor">
									<path d="M107.7,8.07A105.15,105.15,0,0,0,81.47,0a72.06,72.06,0,0,0-3.36,6.83A97.68,97.68,0,0,0,49,6.83,72.37,72.37,0,0,0,45.64,0,105.89,105.89,0,0,0,19.39,8.09C2.79,32.65-1.71,56.6.54,80.21h0A105.73,105.73,0,0,0,32.71,96.36,77.7,77.7,0,0,0,39.6,85.25a68.42,68.42,0,0,1-10.85-5.18c.91-.66,1.8-1.34,2.66-2a75.57,75.57,0,0,0,64.32,0c.87.71,1.76,1.39,2.66,2a68.68,68.68,0,0,1-10.87,5.19,77,77,0,0,0,6.89,11.1A105.25,105.25,0,0,0,126.6,80.22h0C129.24,52.84,122.09,29.11,107.7,8.07ZM42.45,65.69C36.18,65.69,31,60,31,53s5-12.74,11.43-12.74S54,46,53.89,53,48.84,65.69,42.45,65.69Zm42.24,0C78.41,65.69,73.25,60,73.25,53s5-12.74,11.44-12.74S96.23,46,96.12,53,91.08,65.69,84.69,65.69Z"/>
								</svg>
								Vincular cuenta con Discord
							</a>
						{/if}
					</td>
				</tr>
				{/if}
				<tr class="title">
					<th colspan="2">{$LNG.op_general_settings}</th>
				</tr>
				<tr>
					<td>{$LNG.op_timezone}</td>
					<td>{html_options name=timezone options=$Selectors.timezones selected=$timezone}</td>
				</tr>
				{if count($Selectors.lang) > 1}
				<tr>
					<td>{$LNG.op_lang}</td>
					<td>{html_options name=language options=$Selectors.lang selected=$userLang}</td>
				</tr>
				{/if}
				<tr>
					<td>{$LNG.op_sort_planets_by}</td>
					<td>{html_options name=planetSort options=$Selectors.Sort selected=$planetSort}</td>
				</tr>
				<tr>
					<td>{$LNG.op_sort_kind}</td>
					<td>
						{html_options name=planetOrder options=$Selectors.SortUpDown selected=$planetOrder}
					</td>
				</tr>
				{if count($Selectors.Skins) > 1}
				<tr>
					<td>{$LNG.op_skin_example}</td>
					<td>{html_options options=$Selectors.Skins selected=$theme name="theme" id="theme"}</td>
				</tr>
				{/if}
				<tr>
					<td>{$LNG.op_active_build_messages}</td>
					<td><input name="queueMessages" type="checkbox" value="1" {if $queueMessages == 1}checked="checked"{/if}></td>
				</tr>
				<tr>
					<td>{$LNG.op_active_spy_messages_mode}</td>
					<td><input name="spyMessagesMode" type="checkbox" value="1" {if $spyMessagesMode == 1}checked="checked"{/if}></td>
				</tr>
				<tr>
					<td>{$LNG.op_block_pm}</td>
					<td><input name="blockPM" type="checkbox" value="1" {if $blockPM == 1}checked="checked"{/if}></td>
				</tr>
				<tr class="title">
					<th colspan="2">{$LNG.op_galaxy_settings}</th>
				</tr>
				<tr>
					<td><a title="{$LNG.op_spy_probes_number_descrip}">{$LNG.op_spy_probes_number}</a></td>
					<td><input name="spycount" size="{$spycount|count_characters + 3}" value="{$spycount}" type="int"></td>
				</tr>
				<tr>
					<td>{$LNG.op_max_fleets_messages}</td>
					<td><input name="fleetactions" maxlength="2" size="{$fleetActions|count_characters + 2}" value="{$fleetActions}" type="int"></td>
				</tr>
				<tr class="title">
					<th>{$LNG.op_shortcut}</th>
					<th>{$LNG.op_show}</th>
				</tr>
				<tr>
					<td><img src="{$dpath}img/e.gif" alt="">{$LNG.op_spy}</td>
					<td><input name="galaxySpy" type="checkbox" value="1" {if $galaxySpy == 1}checked="checked"{/if}></td>
				</tr>
				<tr>
					<td><img src="{$dpath}img/m.gif" alt="">{$LNG.op_write_message}</td>
					<td><input name="galaxyMessage" type="checkbox" value="1" {if $galaxyMessage == 1}checked="checked"{/if}></td>
				</tr>
				<tr>
					<td><img src="{$dpath}img/b.gif" alt="">{$LNG.op_add_to_buddy_list}</td>
					<td><input name="galaxyBuddyList" type="checkbox" value="1" {if $galaxyBuddyList == 1}checked="checked"{/if}></td>
				</tr>
				<tr>
					<td><img src="{$dpath}img/r.gif" alt="">{$LNG.op_missile_attack}</td>
					<td><input name="galaxyMissle" type="checkbox" value="1" {if $galaxyMissle == 1}checked="checked"{/if}></td>
				</tr>
				<tr class="title">
					<th colspan="2">{$LNG.op_vacation_delete_mode}</th>
				</tr>
				<tr>
					<td><a title="{$LNG.op_activate_vacation_mode_descrip}">{$LNG.op_activate_vacation_mode}</a></td>
					<td><input name="vacation" type="checkbox" value="1"></td>
				</tr>
				<tr>
					<td><a title="{$LNG.op_dlte_account_descrip}">{$LNG.op_dlte_account}</a></td>
					<td><input name="delete" type="checkbox" value="1" {if $delete > 0}checked="checked"{/if}></td>
				</tr>
				{if isModuleAvailable($smarty.const.MODULE_BANNER)}
				<tr class="title">
					<th colspan="3">{$LNG.ov_userbanner}</th>
				</tr>
				<tr>
					<td colspan="3"><img src="userpic.php?id={$userid}" alt="" width="590" height="95" id="userpic"><br><br><table><tr><td class="transparent">HTML:</td><td class="transparent"><input type="text" value='<a href="{$SELF_URL}{if isset($ref_active) && $ref_active}index.php?ref={$userid}{/if}"><img src="{$SELF_URL}userpic.php?id={$userid}"></a>' readonly="readonly" style="width:450px;"></td></tr><tr><td class="transparent">BBCode:</td><td class="transparent"><input type="text" value="[url={$SELF_URL}{if isset($ref_active) && $ref_active}index.php?ref={$userid}{/if}][img]{$SELF_URL}userpic.php?id={$userid}[/img][/url]" readonly="readonly" style="width:450px;"></td></tr></table></td>
				</tr>
				{/if}
				<tr>
					<td colspan="2"><input value="{$LNG.op_save_changes}" type="submit"></td>
				</tr>
			</tbody>
		</table>
	</div>
</div>
</form>
{/block}