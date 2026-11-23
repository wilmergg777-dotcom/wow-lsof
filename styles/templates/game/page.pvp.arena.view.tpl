{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.pvp.arena.view.tpl === *}
{literal}
<style>
/* === ASTROIO v3.0 === */
#content h1, #content h2, #content h3, #content h4 { color:#fff; letter-spacing:.5px; text-shadow:0 1px 3px rgba(0,0,0,.5) }
#content a { color:#00e0ff; text-decoration:none; transition:.2s ease }
#content a:hover { color:#fff; text-shadow:0 0 10px rgba(0,224,255,.7) }
#content table { background:rgba(15,23,42,.55); border:1px solid #1e293b; border-radius:10px; border-collapse:collapse; overflow:hidden }
#content table th { background:linear-gradient(135deg,rgba(0,68,136,.85),rgba(0,119,204,.85)); border-bottom:1px solid rgba(0,224,255,.5); color:#fff; padding:6px 9px; text-align:left; text-transform:uppercase; font-size:10px; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
#content table td { padding:6px 9px; border-bottom:1px solid rgba(30,41,59,.7); color:#cbd5e1 }
#content table tr:hover td { background:rgba(0,224,255,.04) }
#content input[type=text], #content input[type=password], #content input[type=email], #content input[type=number], #content input[type=date], #content select, #content textarea { background:rgba(0,0,0,.5); color:#fff; border:1px solid rgba(0,204,255,.35); border-radius:8px; padding:5px 9px; font-size:12px; font-family:inherit; box-sizing:border-box; max-width:100%; transition:.25s ease }
#content input[type=text]:focus, #content input[type=password]:focus, #content input[type=email]:focus, #content input[type=number]:focus, #content select:focus, #content textarea:focus { outline:none; border-color:#00e0ff; box-shadow:0 0 12px rgba(0,224,255,.5); background:rgba(0,0,0,.65) }
#content textarea { width:100%; resize:vertical; font-family:inherit }
#content button, #content input[type=submit], #content input[type=button] { background:linear-gradient(180deg,#0066cc,#0099ff); color:#fff; border:1px solid #00e0ff; border-radius:8px; padding:5px 16px; font-size:11.5px; font-weight:600; font-family:inherit; cursor:pointer; transition:.25s ease; text-transform:uppercase; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
#content button:hover, #content input[type=submit]:hover, #content input[type=button]:hover { box-shadow:0 0 18px rgba(0,224,255,.5); transform:translateY(-2px) }
#content button:active, #content input[type=submit]:active, #content input[type=button]:active { transform:translateY(0) }
#content input[type=reset] { background:linear-gradient(180deg,#444,#666); border-color:#888 }
#content select option { background:#0f172a; color:#cbd5e1 }
#content .globalWarning { background:rgba(239,68,68,.12); border:1px solid rgba(239,68,68,.45); color:#fecaca; border-radius:10px; padding:8px 14px; text-align:center }
@media (max-width:760px) { #content { padding:6px; overflow-x:auto } #content table { font-size:11px } #content table th, #content table td { padding:5px 7px } }
</style>
{/literal}


<style>
/* ═══════════════════════════════════════════════════════════
   PvP — Ver Arena
   AstroIO v3.1 — Doble Riel (NTX-20 / UNTX-20)
   Prefijo: .astropvp_arena_

   FIX v3.1:
     - Badge de saldo del riel del jugador arriba
     - Bote/premio/entrada con {$moneda} dinámica
     - Confirmaciones con {$moneda} dinámica
     - CSS preservado 100% + estilos para balance badge
   ═══════════════════════════════════════════════════════════ */

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

/* ─── RESET GLOBAL ──────────────────────────────────────── */
.astropvp_arena_wrap,
.astropvp_arena_wrap *,
.astropvp_arena_wrap *::before,
.astropvp_arena_wrap *::after {
    box-sizing: border-box;
}

/* ─── WRAPPER ───────────────────────────────────────────── */
.astropvp_arena_wrap {
    padding: 20px;
    color: #c8d6e5;
}

/* ─── TÍTULO ────────────────────────────────────────────── */
.astropvp_arena_title {
    color: #ff6666;
    text-align: center;
    font-size: 24px;
    margin-bottom: 20px;
    text-shadow: 0 0 14px rgba(239, 68, 68, 0.6);
    letter-spacing: 1px;
}

/* ─── 🆕 BALANCE BADGE (riel del jugador) ───────────────── */
.astropvp_balance_box {
    max-width: 900px;
    margin: 0 auto 18px;
    text-align: center;
}

.astropvp_balance_badge {
    display: inline-block;
    padding: 8px 20px;
    border-radius: 10px;
    font-size: 13px;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(74, 255, 136, 0.5);
    background: linear-gradient(135deg, rgba(0, 200, 100, 0.15), rgba(0, 150, 255, 0.10));
    color: #cbd5e1;
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.4);
}

.astropvp_balance_badge b {
    color: #88ffbb;
    font-family: 'Courier New', monospace;
    font-weight: 800;
    letter-spacing: 0.5px;
    text-shadow: 0 0 10px rgba(74, 255, 136, 0.4);
}

.astropvp_balance_badge .moneda {
    color: #88ddff;
    font-weight: 700;
    letter-spacing: 0.5px;
}

/* ─── BOTÓN VOLVER ──────────────────────────────────────── */
.astropvp_arena_back_wrap {
    max-width: 900px;
    margin: 0 auto 20px;
    text-align: center;
}
.astropvp_arena_back {
    display: inline-block;
    padding: 10px 20px;
    background: rgba(120, 120, 120, 0.3);
    color: #aabbcc;
    border: 1px solid rgba(120, 120, 120, 0.4);
    border-radius: 8px;
    font-size: 12px;
    font-weight: bold;
    text-decoration: none;
    transition: 0.25s ease;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.astropvp_arena_back:hover {
    background: rgba(120, 120, 120, 0.45);
    color: #ffffff;
    transform: translateY(-1px);
}

/* ─── PANEL INFO ARENA ──────────────────────────────────── */
.astropvp_arena_info_panel {
    max-width: 900px;
    margin: 0 auto 20px;
    background: linear-gradient(160deg, rgba(60, 15, 15, 0.85) 0%, rgba(90, 25, 25, 0.85) 100%);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 2px solid rgba(255, 100, 100, 0.5);
    border-radius: 14px;
    padding: 20px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astropvp_arena_info_grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
    gap: 15px;
}

.astropvp_arena_info_item {
    min-width: 0;
}

.astropvp_arena_info_label {
    font-size: 11px;
    color: #8899aa;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 4px;
}

.astropvp_arena_info_value {
    font-size: 18px;
    font-weight: bold;
    font-family: 'Courier New', monospace;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}
.astropvp_arena_info_value.mode    { color: #ff8888; text-shadow: 0 0 8px rgba(239, 68, 68, 0.4); }
.astropvp_arena_info_value.status  { color: #ffee88; text-shadow: 0 0 8px rgba(251, 191, 36, 0.4); }
.astropvp_arena_info_value.pool    { color: #88ffbb; text-shadow: 0 0 8px rgba(74, 255, 136, 0.4); }
.astropvp_arena_info_value.time    { color: #88bbff; text-shadow: 0 0 8px rgba(100, 150, 255, 0.4); }

/* ─── PANEL JUGADORES ───────────────────────────────────── */
.astropvp_arena_players_panel {
    max-width: 900px;
    margin: 0 auto 20px;
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(255, 200, 50, 0.4);
    border-radius: 12px;
    padding: 20px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astropvp_arena_players_title {
    color: #ffdd88;
    font-size: 16px;
    margin-bottom: 15px;
    text-shadow: 0 0 10px rgba(251, 191, 36, 0.4);
}

.astropvp_arena_teams_grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 15px;
}

.astropvp_arena_team {
    padding: 12px;
    border-radius: 8px;
    min-width: 0;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.astropvp_arena_team.team0 {
    background: rgba(100, 150, 255, 0.08);
    border-left: 3px solid #88bbff;
}
.astropvp_arena_team.team1 {
    background: rgba(255, 100, 100, 0.08);
    border-left: 3px solid #ff8888;
}

.astropvp_arena_team_title {
    font-size: 12px;
    font-weight: bold;
    margin-bottom: 10px;
}
.astropvp_arena_team.team0 .astropvp_arena_team_title { color: #88bbff; }
.astropvp_arena_team.team1 .astropvp_arena_team_title { color: #ff8888; }

/* ─── CARD DE JUGADOR ───────────────────────────────────── */
.astropvp_arena_player {
    background: rgba(0, 0, 0, 0.35);
    border-radius: 8px;
    padding: 10px 12px;
    margin-bottom: 10px;
    border-left: 3px solid #88bbff;
    transition: 0.25s ease;
    min-width: 0;
    overflow: hidden;
}
.astropvp_arena_player:hover {
    background: rgba(0, 0, 0, 0.5);
}
.astropvp_arena_player.is_me {
    border-left-color: #4CAF50;
    background: rgba(76, 175, 80, 0.08);
}
.astropvp_arena_team.team1 .astropvp_arena_player:not(.is_me) {
    border-left-color: #ff8888;
}

.astropvp_arena_player_name {
    font-size: 13px;
    color: #ffffff;
    font-weight: bold;
    margin-bottom: 6px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}
.astropvp_arena_player_name .icon {
    margin-right: 3px;
}
.astropvp_arena_player_name .leader {
    color: #ffee88;
    margin-left: 3px;
}

.astropvp_arena_player_planet_name {
    font-size: 11px;
    color: #8899aa;
    margin-bottom: 2px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}
.astropvp_arena_player_planet_name .name {
    color: #c8d6e5;
}

.astropvp_arena_player_coords {
    font-size: 12px;
    color: #ffd54f;
    font-family: monospace;
    margin-bottom: 8px;
}

.astropvp_arena_player_tag_me {
    display: inline-block;
    padding: 5px 12px;
    background: rgba(76, 175, 80, 0.2);
    color: #88ffbb;
    border: 1px solid rgba(76, 175, 80, 0.5);
    border-radius: 6px;
    font-size: 11px;
    font-weight: bold;
}

.astropvp_arena_btn_attack {
    display: inline-block;
    padding: 6px 16px;
    background: linear-gradient(135deg, #e53935, #b71c1c);
    color: #ffffff;
    border: 1px solid rgba(229, 57, 53, 0.7);
    border-radius: 6px;
    font-size: 12px;
    font-weight: bold;
    text-decoration: none;
    box-shadow: 0 2px 8px rgba(229, 57, 53, 0.4);
    transition: 0.25s ease;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astropvp_arena_btn_attack:hover {
    background: linear-gradient(135deg, #ff5252, #d32f2f);
    box-shadow: 0 4px 14px rgba(229, 57, 53, 0.6);
    transform: translateY(-2px);
}

.astropvp_arena_player_no_planet {
    font-size: 11px;
    color: #ff8888;
}

/* ─── DAÑO POR EQUIPO ───────────────────────────────────── */
.astropvp_arena_damage {
    margin-top: 20px;
    padding-top: 15px;
    border-top: 1px solid rgba(255, 255, 255, 0.08);
}

.astropvp_arena_damage_title {
    color: #ffdd88;
    font-size: 13px;
    margin-bottom: 10px;
    text-shadow: 0 0 8px rgba(251, 191, 36, 0.4);
}

.astropvp_arena_damage_grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 15px;
}

.astropvp_arena_damage_item {
    text-align: center;
    min-width: 0;
}

.astropvp_arena_damage_label {
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}
.astropvp_arena_damage_item.team0 .astropvp_arena_damage_label { color: #88bbff; }
.astropvp_arena_damage_item.team1 .astropvp_arena_damage_label { color: #ff8888; }

.astropvp_arena_damage_value {
    font-size: 20px;
    font-weight: bold;
    font-family: 'Courier New', monospace;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}
.astropvp_arena_damage_item.team0 .astropvp_arena_damage_value {
    color: #88bbff;
    text-shadow: 0 0 8px rgba(100, 150, 255, 0.4);
}
.astropvp_arena_damage_item.team1 .astropvp_arena_damage_value {
    color: #ff8888;
    text-shadow: 0 0 8px rgba(239, 68, 68, 0.4);
}

/* ─── ACCIONES ──────────────────────────────────────────── */
.astropvp_arena_action_wrap {
    max-width: 900px;
    margin: 0 auto 12px;
    text-align: center;
}

.astropvp_arena_btn_claim {
    padding: 14px 40px;
    background: linear-gradient(135deg, #ccaa22, #ffdd88);
    color: #111111;
    border: 1px solid #ffdd88;
    border-radius: 10px;
    font-size: 14px;
    font-weight: bold;
    cursor: pointer;
    box-shadow: 0 4px 14px rgba(255, 200, 50, 0.5);
    transition: 0.25s ease;
    font-family: inherit;
    text-shadow: 0 1px 2px rgba(255, 255, 255, 0.2);
}
.astropvp_arena_btn_claim:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(255, 200, 50, 0.7);
}

.astropvp_arena_claim_note {
    margin-top: 8px;
    font-size: 11px;
    color: #aabbcc;
}
.astropvp_arena_claim_note .pool {
    color: #88ffbb;
    font-weight: bold;
}
.astropvp_arena_claim_note .count {
    color: #ffdd88;
    font-weight: bold;
}

.astropvp_arena_btn_cancel {
    padding: 12px 30px;
    background: rgba(255, 50, 50, 0.2);
    color: #ff8888;
    border: 1px solid rgba(255, 50, 50, 0.5);
    border-radius: 10px;
    font-size: 13px;
    font-weight: bold;
    cursor: pointer;
    transition: 0.25s ease;
    font-family: inherit;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astropvp_arena_btn_cancel:hover {
    background: rgba(255, 50, 50, 0.35);
    box-shadow: 0 0 14px rgba(239, 68, 68, 0.5);
    transform: translateY(-2px);
}

/* ─── RESPONSIVE ────────────────────────────────────────── */
@media (max-width: 1200px) {
    .astropvp_arena_info_grid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }
}

@media (max-width: 720px) {
    .astropvp_arena_wrap {
        padding: 12px;
    }
    .astropvp_arena_title {
        font-size: 18px;
    }
    .astropvp_arena_info_panel,
    .astropvp_arena_players_panel {
        padding: 14px;
    }
    .astropvp_arena_info_grid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 10px;
    }
    .astropvp_arena_info_value {
        font-size: 14px;
    }
    .astropvp_arena_teams_grid {
        grid-template-columns: 1fr;
    }
    .astropvp_arena_damage_grid {
        grid-template-columns: 1fr;
    }
    .astropvp_arena_damage_value {
        font-size: 16px;
    }
    .astropvp_arena_btn_claim,
    .astropvp_arena_btn_cancel {
        width: 100%;
        padding: 12px 20px;
    }
    .astropvp_balance_badge {
        font-size: 12px;
        padding: 6px 14px;
    }
}
</style>

<div class="astropvp_arena_wrap">
	<h1 class="astropvp_arena_title">
		🏟️ Arena #{$arena.id}
	</h1>

	{* 🆕 BADGE DE SALDO DEL RIEL DEL JUGADOR *}
	<div class="astropvp_balance_box">
		<span class="astropvp_balance_badge">
			💲 Tu saldo: <b>{$saldo_actual|number_format}</b>
			<span class="moneda">{$moneda}</span>
		</span>
	</div>

	<div class="astropvp_arena_back_wrap">
		<a href="game.php?page=pvp&mode=arenas" class="astropvp_arena_back">
			← Volver a arenas
		</a>
	</div>

	{* INFO ARENA *}
	<div class="astropvp_arena_info_panel">
		<div class="astropvp_arena_info_grid">
			<div class="astropvp_arena_info_item">
				<div class="astropvp_arena_info_label">Modalidad</div>
				<div class="astropvp_arena_info_value mode">{$arena.mode_label}</div>
			</div>
			<div class="astropvp_arena_info_item">
				<div class="astropvp_arena_info_label">Estado</div>
				<div class="astropvp_arena_info_value status">{$arena.status}</div>
			</div>
			<div class="astropvp_arena_info_item">
				<div class="astropvp_arena_info_label">Bote</div>
				<div class="astropvp_arena_info_value pool">{$arena.pool_fmt} {$moneda}</div>
			</div>
			<div class="astropvp_arena_info_item">
				<div class="astropvp_arena_info_label">Tiempo restante</div>
				<div class="astropvp_arena_info_value time">{$arena.time_left_fmt}</div>
			</div>
		</div>
	</div>

	{* JUGADORES *}
	<div class="astropvp_arena_players_panel">
		<h2 class="astropvp_arena_players_title">👥 Jugadores</h2>

		<div class="astropvp_arena_teams_grid">

			{* EQUIPO 0 *}
			<div class="astropvp_arena_team team0">
				<div class="astropvp_arena_team_title">EQUIPO 0</div>

				{foreach $players as $p}
					{if $p.team == 0}
						<div class="astropvp_arena_player{if $p.user_id == $my_user_id} is_me{/if}">
							<div class="astropvp_arena_player_name">
								<span class="icon">{if $p.user_id == $my_user_id}👤{else}⚔️{/if}</span>
								{$p.username}
								{if $p.is_leader == 1}<span class="leader">👑</span>{/if}
							</div>

							{if $p.main_planet_id}
								<div class="astropvp_arena_player_planet_name">
									🌍 <span class="name">{$p.planet_name}</span>
								</div>
								<div class="astropvp_arena_player_coords">
									📍 [{$p.galaxy}:{$p.system}:{$p.planet}]
								</div>

								{if $p.user_id == $my_user_id}
									<span class="astropvp_arena_player_tag_me">
										📍 Tú
									</span>
								{elseif $arena.status == 'active' || $arena.status == 'extra_time'}
									<a href="game.php?page=fleetTable&galaxy={$p.galaxy}&system={$p.system}&planet={$p.planet}&planettype={$p.planet_type}&target_mission=1"
									   class="astropvp_arena_btn_attack">
										🚀 Atacar
									</a>
								{/if}
							{else}
								<div class="astropvp_arena_player_no_planet">⚠️ Sin planeta principal</div>
							{/if}
						</div>
					{/if}
				{/foreach}
			</div>

			{* EQUIPO 1 *}
			<div class="astropvp_arena_team team1">
				<div class="astropvp_arena_team_title">EQUIPO 1</div>

				{foreach $players as $p}
					{if $p.team == 1}
						<div class="astropvp_arena_player{if $p.user_id == $my_user_id} is_me{/if}">
							<div class="astropvp_arena_player_name">
								<span class="icon">{if $p.user_id == $my_user_id}👤{else}⚔️{/if}</span>
								{$p.username}
								{if $p.is_leader == 1}<span class="leader">👑</span>{/if}
							</div>

							{if $p.main_planet_id}
								<div class="astropvp_arena_player_planet_name">
									🌍 <span class="name">{$p.planet_name}</span>
								</div>
								<div class="astropvp_arena_player_coords">
									📍 [{$p.galaxy}:{$p.system}:{$p.planet}]
								</div>

								{if $p.user_id == $my_user_id}
									<span class="astropvp_arena_player_tag_me">
										📍 Tú
									</span>
								{elseif $arena.status == 'active' || $arena.status == 'extra_time'}
									<a href="game.php?page=fleetTable&galaxy={$p.galaxy}&system={$p.system}&planet={$p.planet}&planettype={$p.planet_type}&target_mission=1"
									   class="astropvp_arena_btn_attack">
										🚀 Atacar
									</a>
								{/if}
							{else}
								<div class="astropvp_arena_player_no_planet">⚠️ Sin planeta principal</div>
							{/if}
						</div>
					{/if}
				{/foreach}
			</div>
		</div>

		{* DAÑO POR EQUIPO *}
		{if $arena.status == 'active' || $arena.status == 'extra_time' || $arena.status == 'finished'}
			<div class="astropvp_arena_damage">
				<h3 class="astropvp_arena_damage_title">💥 Daño acumulado</h3>
				<div class="astropvp_arena_damage_grid">
					<div class="astropvp_arena_damage_item team0">
						<div class="astropvp_arena_damage_label">Equipo 0</div>
						<div class="astropvp_arena_damage_value">{$team_damage[0]}</div>
					</div>
					<div class="astropvp_arena_damage_item team1">
						<div class="astropvp_arena_damage_label">Equipo 1</div>
						<div class="astropvp_arena_damage_value">{$team_damage[1]}</div>
					</div>
				</div>
			</div>
		{/if}
	</div>

	{* ACCIONES *}
	{if $arena.i_can_claim}
		<div class="astropvp_arena_action_wrap">
			<form method="POST" action="game.php?page=pvp&mode=claimPrize" style="display: inline;">
				<input type="hidden" name="arena_id" value="{$arena.id}">
				<button type="submit" class="astropvp_arena_btn_claim">
					🎁 Reclamar premio ({$arena.prize_individual_fmt} {$moneda})
				</button>
			</form>

			{if $arena.winner_count > 1}
				<div class="astropvp_arena_claim_note">
					Bote total: <strong class="pool">{$arena.pool_fmt} {$moneda}</strong>
					— repartido entre <strong class="count">{$arena.winner_count}</strong> ganadores
				</div>
			{/if}
		</div>
	{/if}

	{if $arena.can_cancel}
		<div class="astropvp_arena_action_wrap">
			<form method="POST" action="game.php?page=pvp&mode=cancelArena" style="display: inline;">
				<input type="hidden" name="arena_id" value="{$arena.id}">
				<button type="submit" class="astropvp_arena_btn_cancel" onclick="return confirm('¿Cancelar esta arena? Se devolverá el {$moneda} a todos.');">
					❌ Cancelar arena
				</button>
			</form>
		</div>
	{/if}
</div>
{/block}