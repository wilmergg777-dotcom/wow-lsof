{* ═══════════════════════════════════════════════════════════════════
   ASTROIO v7.1 — SIDEBAR "ASTROIO ECOSYSTEM" (mockup8_3 aplicado)
   Grupos COLONIA/MILITAR/SOCIEDAD/CUENTA + submenús + buscador +
   JACKPOT + Personalización + Ayuda. Todos los links del nav viejo
   portados con sus checks de módulo, badges PvE/PvP (ids intactos:
   pve_mop_link/pve_mop_badge, pvp_mop_link/pvp_mop_badge), admin por
   authlevel, alianza y alerts. Chat del sidebar retirado: el chat
   flotante v4.0 del footer es el oficial (aiofc).
   ═══════════════════════════════════════════════════════════════════ *}

<style>
/* ═══ SIDEBAR ASTROIO ECOSYSTEM ═══ */
#leftmenu { background: #0a0f1c !important; border-right:1px solid #1e293b !important; width:240px !important; padding:0 !important; font-family:'Segoe UI',Roboto,sans-serif !important }
#leftmenu * { box-sizing:border-box }
#leftmenu a { text-decoration:none }

.aio_logo { display:flex; align-items:center; gap:9px; padding:16px 16px 12px }
.aio_logo .aio_logo_badge { width:34px; height:34px; border-radius:10px; background:linear-gradient(135deg,#2563eb,#60a5fa); color:#fff; font-weight:900; font-size:17px; display:flex; align-items:center; justify-content:center; box-shadow:0 0 12px rgba(59,130,246,.5) }
.aio_logo b { color:#fff; font-size:14px; letter-spacing:1.5px; display:block; line-height:1.1 }
.aio_logo small { color:#64748b; font-size:8.5px; letter-spacing:2px; font-weight:700 }

.aio_planet { display:flex; align-items:center; gap:10px; margin:2px 12px 10px; background:linear-gradient(90deg, rgba(37,99,235,.22), rgba(37,99,235,.08)); border:1px solid rgba(96,165,250,.35); border-radius:12px; padding:10px 12px; text-decoration:none; transition:.2s ease }
.aio_planet:hover { border-color:rgba(96,165,250,.7) }
.aio_planet .aio_planet_ava { width:32px; height:32px; border-radius:50%; background:radial-gradient(circle at 35% 30%, #93c5fd, #1d4ed8 70%); box-shadow:0 0 8px rgba(96,165,250,.5); flex:0 0 32px }
.aio_planet b { color:#fff; font-size:12px; display:block }
.aio_planet small { color:#93c5fd; font-size:10.5px; font-weight:700 }

.aio_search { position:relative; margin:0 12px 12px }
.aio_search input { width:100%; background:rgba(2,6,12,.6); border:1px solid #22314f; border-radius:9px; color:#cbd5e1; font-size:11px; padding:8px 10px 8px 28px; outline:none; transition:.2s ease }
.aio_search input:focus { border-color:rgba(56,189,248,.6); color:#fff }
.aio_search:before { content:'🔍'; position:absolute; left:8px; top:50%; transform:translateY(-50%); font-size:11px; opacity:.6 }

.aio_alerts { display:flex; gap:6px; margin:0 12px 12px }
.aio_alerts .aio_al { flex:1; text-align:center; background:rgba(2,6,12,.55); border:1px solid #22314f; border-radius:8px; padding:6px 0; font-size:12px; opacity:.35 }
.aio_alerts .aio_al.active { opacity:1; background:rgba(239,68,68,.12); border-color:rgba(239,68,68,.5); box-shadow:0 0 8px rgba(239,68,68,.25); animation:aio_blink 1.6s infinite }
.aio_alerts .aio_al.off { opacity:.35 }
@keyframes aio_blink { 50% { box-shadow:0 0 14px rgba(239,68,68,.5) } }

.aio_group { margin:0 12px 2px }
.aio_glabel { color:#64748b; font-size:8.5px; font-weight:900; letter-spacing:1.6px; text-transform:uppercase; padding:10px 6px 5px; display:block }
.aio_item { display:flex; align-items:center; gap:9px; background:transparent; border:1px solid transparent; border-radius:10px; padding:8px 10px; color:#cbd5e1; font-size:12px; font-weight:600; margin:1px 0; cursor:pointer; transition:.15s ease; text-transform:none; letter-spacing:0 }
.aio_item:hover { background:rgba(255,255,255,.05); color:#fff }
.aio_item.active { background:linear-gradient(90deg,#2563eb,#3b82f6); color:#fff !important; font-weight:800; box-shadow:0 4px 12px rgba(37,99,235,.4) }
.aio_item .aio_ic { width:18px; text-align:center; flex:0 0 18px }
.aio_item .aio_txt { flex:1; min-width:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap }
.aio_item .aio_caret { font-size:9px; color:#64748b; transition:transform .2s ease }
.aio_item.open .aio_caret { transform:rotate(90deg) }
.aio_item.active .aio_caret { color:#fff }
.aio_badge { background:rgba(239,68,68,.2); border:1px solid rgba(239,68,68,.55); color:#fca5a5; font-size:9px; font-weight:900; border-radius:7px; padding:2px 7px; white-space:nowrap }
.aio_badge.state-off { background:rgba(100,116,139,.15); border-color:#334155; color:#94a3b8 }

.aio_sub { max-height:0; overflow:hidden; transition:max-height .25s ease; margin:0 0 2px }
.aio_group_wrap.open .aio_sub { max-height:600px }
.aio_sub .aio_item { padding-left:37px; font-size:11.5px; margin:1px 0 }

.aio_jackpot { display:flex; align-items:center; gap:9px; margin:10px 12px 2px; background:linear-gradient(90deg, rgba(245,158,11,.25), rgba(245,158,11,.08)); border:1px solid rgba(245,158,11,.6); border-radius:11px; padding:10px 12px; color:#fbbf24 !important; font-weight:900; font-size:11px; letter-spacing:1px; text-decoration:none; transition:.2s ease; text-transform:uppercase }
.aio_jackpot:hover { box-shadow:0 0 14px rgba(245,158,11,.4); color:#fde68a !important }
.aio_jackpot small { display:block; color:#f59e0b; font-size:8.5px; letter-spacing:1.5px; font-weight:800 }

.aio_admin { margin:10px 12px 0; border-top:1px dashed #22314f; padding-top:8px }
.aio_admin .aio_item { color:#fca5a5 }
.aio_admin .aio_glabel { padding-top:4px }

.aio_ally { margin:12px 12px 0; background:rgba(2,6,12,.5); border:1px solid #22314f; border-radius:12px; padding:10px 12px }
.aio_ally .aio_ally_title { color:#93c5fd; font-weight:800; font-size:11.5px; margin-bottom:6px }
.aio_ally .ally_member { display:flex; justify-content:space-between; gap:8px; font-size:10.5px; color:#cbd5e1; padding:2.5px 0 }
.aio_ally .ally_member .time { color:#64748b; font-size:9.5px }
.aio_ally .ally_member.offline { opacity:.55 }

.aio_design { margin:12px 12px 0; background:rgba(2,6,12,.5); border:1px solid #22314f; border-radius:12px; padding:9px 11px }
.aio_design .aio_glabel { padding:0 0 6px }
.aio_design .aio_dbtns { display:flex; gap:6px }
.aio_design button { flex:1; background:rgba(2,6,12,.6); border:1px solid #334155; color:#94a3b8; border-radius:8px; padding:6px 4px; font-size:10px; font-weight:800; cursor:pointer; font-family:inherit; transition:.15s ease; text-transform:none; letter-spacing:0 }
.aio_design button.aio_dactive { background:rgba(56,189,248,.15); border-color:rgba(56,189,248,.6); color:#38bdf8 }

.aio_foot { margin:12px 12px 14px; color:#475569; font-size:9px; line-height:1.7; border-top:1px dashed #1e293b; padding-top:8px }
.aio_foot b { color:#64748b }
</style>

<div id="leftmenu" class="aio_nav">

	{* ─── Logo ─── *}
	<div class="aio_logo">
		<span class="aio_logo_badge">A</span>
		<span><b>ASTROIO</b><small>ECOSYSTEM</small></span>
	</div>

	{* ─── Tarjeta del planeta ─── *}
	<a href="game.php?page=overview" class="aio_planet">
		<span class="aio_planet_ava"></span>
		<span><b>Planeta Principal</b><small id="aio_nav_coords">Ver imperio &rsaquo;</small></span>
	</a>

	{* ─── Buscador de funciones ─── *}
	<div class="aio_search"><input type="text" id="aio_nav_search" placeholder="Buscar función..." autocomplete="off"></div>

	{* ─── Alertas de ataque / espionaje / transporte (v6.6 intacto) ─── *}
	<div class="aio_alerts">
		<div class="aio_al {if !empty($globalAlerts.attack)}active{else}off{/if}" title="Ataque{if !empty($globalAlerts.attack)} ({count($globalAlerts.attack)}){/if}">&#9876;&#65039;</div>
		<div class="aio_al {if !empty($globalAlerts.spy)}active{else}off{/if}" title="Espionaje{if !empty($globalAlerts.spy)} ({count($globalAlerts.spy)}){/if}">&#128379;&#65039;</div>
		<div class="aio_al {if !empty($globalAlerts.transport)}active{else}off{/if}" title="Transporte{if !empty($globalAlerts.transport)} ({count($globalAlerts.transport)}){/if}">&#128229;</div>
	</div>

	{* ─── COLONIA ─── *}
	<span class="aio_glabel">Colonia</span>
	<a href="game.php?page=overview" class="aio_item" data-aio-page="overview"><span class="aio_ic">&#127968;</span><span class="aio_txt">Centro de mando</span></a>

	<div class="aio_group_wrap" data-aio-group>
		<div class="aio_item" data-aio-toggle><span class="aio_ic">&#129691;</span><span class="aio_txt">Mi planeta</span><span class="aio_caret">&#9656;</span></div>
		<div class="aio_sub">
			{if isModuleAvailable($smarty.const.MODULE_RESSOURCE_LIST)}<a href="game.php?page=resources" class="aio_item" data-aio-page="resources"><span class="aio_ic">&#128142;</span><span class="aio_txt">Producci&oacute;n</span></a>{/if}
			{if isModuleAvailable($smarty.const.MODULE_FLEET_TABLE)}<a href="game.php?page=fleetTable" class="aio_item" data-aio-page="fleetTable"><span class="aio_ic">&#9875;&#65039;</span><span class="aio_txt">Flotas en vuelo</span></a>{/if}
			{if isModuleAvailable($smarty.const.MODULE_FLEET_TRADER)}<a href="game.php?page=fleetDealer" class="aio_item" data-aio-page="fleetDealer"><span class="aio_ic">&#127966;</span><span class="aio_txt">Comerciante de flotas</span></a>{/if}
		</div>
	</div>

	<div class="aio_group_wrap" data-aio-group>
		<div class="aio_item" data-aio-toggle><span class="aio_ic">&#128300;</span><span class="aio_txt">Tecnolog&iacute;a</span><span class="aio_caret">&#9656;</span></div>
		<div class="aio_sub">
			{if isModuleAvailable($smarty.const.MODULE_BUILDING)}<a href="game.php?page=buildings" class="aio_item" data-aio-page="buildings"><span class="aio_ic">&#127960;&#65039;</span><span class="aio_txt">Edificios</span></a>{/if}
			{if isModuleAvailable($smarty.const.MODULE_RESEARCH)}<a href="game.php?page=research" class="aio_item" data-aio-page="research"><span class="aio_ic">&#128300;</span><span class="aio_txt">Investigaciones</span></a>{/if}
			<a href="game.php?page=techtree" class="aio_item" data-aio-page="techtree"><span class="aio_ic">&#128366;&#65039;</span><span class="aio_txt">&Aacute;rbol tecnol&oacute;gico</span></a>
		</div>
	</div>

	{* ─── MILITAR ─── *}
	<span class="aio_glabel">Militar</span>

	<div class="aio_group_wrap" data-aio-group>
		<div class="aio_item" data-aio-toggle><span class="aio_ic">&#128640;</span><span class="aio_txt">Flota y defensa</span><span class="aio_caret">&#9656;</span></div>
		<div class="aio_sub">
			{if isModuleAvailable($smarty.const.MODULE_SHIPYARD_FLEET)}<a href="game.php?page=shipyard&amp;mode=fleet" class="aio_item" data-aio-page="shipyard"><span class="aio_ic">&#128640;</span><span class="aio_txt">Hangar</span></a>{/if}
			{if isModuleAvailable($smarty.const.MODULE_SHIPYARD_DEFENSIVE)}<a href="game.php?page=shipyard&amp;mode=defense" class="aio_item" data-aio-page="shipyard-defense"><span class="aio_ic">&#128737;&#65039;</span><span class="aio_txt">Defensas</span></a>{/if}
			{if isModuleAvailable($smarty.const.MODULE_SIMULATOR)}<a href="game.php?page=battleSimulator" class="aio_item" data-aio-page="battleSimulator"><span class="aio_ic">&#128165;</span><span class="aio_txt">Simulador de batalla</span></a>{/if}
		</div>
	</div>

	<div class="aio_group_wrap" data-aio-group>
		<div class="aio_item" data-aio-toggle><span class="aio_ic">&#129517;</span><span class="aio_txt">Galaxia</span><span class="aio_caret">&#9656;</span></div>
		<div class="aio_sub">
			{if isModuleAvailable($smarty.const.MODULE_GALAXY)}<a href="game.php?page=galaxy" class="aio_item" data-aio-page="galaxy"><span class="aio_ic">&#129517;</span><span class="aio_txt">Galaxia</span></a>{/if}
			<a href="game.php?page=imperium" class="aio_item" data-aio-page="imperium"><span class="aio_ic">&#127756;</span><span class="aio_txt">Imperio</span></a>
		</div>
	</div>

	{* ─── SOCIEDAD ─── *}
	<span class="aio_glabel">Sociedad</span>

	<div class="aio_group_wrap" data-aio-group>
		<div class="aio_item" data-aio-toggle><span class="aio_ic">&#127983;</span><span class="aio_txt">Alianza</span><span class="aio_caret">&#9656;</span></div>
		<div class="aio_sub">
			{if isModuleAvailable($smarty.const.MODULE_ALLIANCE)}<a href="game.php?page=alliance" class="aio_item" data-aio-page="alliance"><span class="aio_ic">&#127983;</span><span class="aio_txt">Mi alianza</span></a>{/if}
			<a href="game.php?page=buddyList" class="aio_item" data-aio-page="buddyList"><span class="aio_ic">&#128101;</span><span class="aio_txt">Compa&ntilde;eros</span></a>
			<a href="game.php?page=statistics" class="aio_item" data-aio-page="statistics"><span class="aio_ic">&#128202;</span><span class="aio_txt">Estad&iacute;sticas</span></a>
		</div>
	</div>

	<div class="aio_group_wrap" data-aio-group>
		<div class="aio_item" data-aio-toggle><span class="aio_ic">&#128717;&#65039;</span><span class="aio_txt">Mercado</span><span class="aio_caret">&#9656;</span></div>
		<div class="aio_sub">
			{if isModuleAvailable($smarty.const.MODULE_MARKET)}<a href="game.php?page=market" class="aio_item" data-aio-page="market"><span class="aio_ic">&#128717;&#65039;</span><span class="aio_txt">Mercado</span></a>{/if}
			{if isModuleAvailable($smarty.const.MODULE_RESOURCE_TRADER)}<a href="game.php?page=resourceTrader" class="aio_item" data-aio-page="resourceTrader"><span class="aio_ic">&#128184;</span><span class="aio_txt">Comercio de recursos</span></a>{/if}
			{if isModuleAvailable($smarty.const.MODULE_WALLET)}<a href="game.php?page=wallet" class="aio_item" data-aio-page="wallet"><span class="aio_ic">&#127963;&#65039;</span><span class="aio_txt">Banco</span></a>{/if}
		</div>
	</div>

	<div class="aio_group_wrap" data-aio-group>
		<div class="aio_item" data-aio-toggle><span class="aio_ic">&#129520;</span><span class="aio_txt">Misiones</span><span class="aio_caret">&#9656;</span></div>
		<div class="aio_sub">
			{if isModuleAvailable($smarty.const.MODULE_TASKS)}<a href="game.php?page=tasks" class="aio_item" data-aio-page="tasks"><span class="aio_ic">&#127919;</span><span class="aio_txt">Tareas</span></a>{/if}
			{if isModuleAvailable($smarty.const.MODULE_EVENTS)}<a href="game.php?page=events" class="aio_item" data-aio-page="events"><span class="aio_ic">&#10024;</span><span class="aio_txt">Eventos</span></a>{/if}
			{if isModuleAvailable($smarty.const.MODULE_NOTICE)}<a href="javascript:OpenPopup('?page=notes', 'notes', 720, 300);" class="aio_item"><span class="aio_ic">&#128221;</span><span class="aio_txt">Notas</span></a>{/if}
		</div>
	</div>

	{* ─── CUENTA ─── *}
	<span class="aio_glabel">Cuenta</span>

	<div class="aio_group_wrap" data-aio-group>
		<div class="aio_item" data-aio-toggle><span class="aio_ic">&#127942;</span><span class="aio_txt">Competiciones</span><span class="aio_caret">&#9656;</span></div>
		<div class="aio_sub">
			{if isModuleAvailable($smarty.const.MODULE_PVE)}
			{assign var="pveCrisisTime"    value=0}{assign var="pveCrisisActive"  value=0}{assign var="pveEmpireTime"    value=0}{assign var="pveEmpireActive"  value=0}{assign var="pveBossTime"      value=0}{assign var="pveBossEndTime"   value=0}{assign var="pveBossActive"    value=0}{assign var="pveBossStatus"    value='idle'}{assign var="pveAnyActive"     value=0}
			{if isset($pve) && is_array($pve)}
				{if isset($pve.crisis_next_time)}{assign var="pveCrisisTime"    value=$pve.crisis_next_time}{/if}
				{if isset($pve.crisis_active)}{assign var="pveCrisisActive"  value=$pve.crisis_active}{/if}
				{if isset($pve.empire_next_time)}{assign var="pveEmpireTime"    value=$pve.empire_next_time}{/if}
				{if isset($pve.empire_active)}{assign var="pveEmpireActive"  value=$pve.empire_active}{/if}
				{if isset($pve.boss_next_time)}{assign var="pveBossTime"      value=$pve.boss_next_time}{/if}
				{if isset($pve.boss_end_time)}{assign var="pveBossEndTime"   value=$pve.boss_end_time}{/if}
				{if isset($pve.boss_active)}{assign var="pveBossActive"    value=$pve.boss_active}{/if}
				{if isset($pve.boss_status)}{assign var="pveBossStatus"    value=$pve.boss_status}{/if}
				{if isset($pve.any_active)}{assign var="pveAnyActive"     value=$pve.any_active}{/if}
			{/if}
			<a href="game.php?page=pve" class="aio_item" id="pve_mop_link" data-aio-page="pve"
			   data-crisis-time="{$pveCrisisTime}" data-crisis-active="{$pveCrisisActive}"
			   data-empire-time="{$pveEmpireTime}" data-empire-active="{$pveEmpireActive}"
			   data-boss-time="{$pveBossTime}" data-boss-end-time="{$pveBossEndTime}"
			   data-boss-active="{$pveBossActive}" data-boss-status="{$pveBossStatus}"
			   data-any-active="{$pveAnyActive}">
				<span class="aio_ic">&#9876;&#65039;</span><span class="aio_txt">Eventos PvE</span>
				<span class="aio_badge state-off" id="pve_mop_badge">--</span>
			</a>
			{/if}
			{if isModuleAvailable($smarty.const.MODULE_PVP)}
			{assign var="pvpArenaActive"      value=0}{assign var="pvpArenaWaiting"     value=0}{assign var="pvpTournamentActive" value=0}{assign var="pvpTournamentStatus" value=''}{assign var="pvpTournamentTime"   value=0}
			{if isset($pvp) && is_array($pvp)}
				{if isset($pvp.arenas_active)}{assign var="pvpArenaActive"  value=$pvp.arenas_active}{/if}
				{if isset($pvp.arenas_waiting)}{assign var="pvpArenaWaiting" value=$pvp.arenas_waiting}{/if}
				{if isset($pvp.tournament_active)}{assign var="pvpTournamentActive" value=$pvp.tournament_active}{/if}
				{if isset($pvp.tournament_status)}{assign var="pvpTournamentStatus" value=$pvp.tournament_status}{/if}
				{if isset($pvp.tournament_time)}{assign var="pvpTournamentTime"   value=$pvp.tournament_time}{/if}
			{/if}
			<a href="game.php?page=pvp" class="aio_item" id="pvp_mop_link" data-aio-page="pvp"
			   data-arena-active="{$pvpArenaActive}" data-arena-waiting="{$pvpArenaWaiting}"
			   data-tournament-active="{$pvpTournamentActive}" data-tournament-status="{$pvpTournamentStatus}"
			   data-tournament-time="{$pvpTournamentTime}">
				<span class="aio_ic">&#9876;&#65039;</span><span class="aio_txt">PvP</span>
				<span class="aio_badge state-off" id="pvp_mop_badge">--</span>
			</a>
			{/if}
			{if isModuleAvailable($smarty.const.MODULE_TOURNEY)}<a href="game.php?page=tourney" class="aio_item" data-aio-page="tourney"><span class="aio_ic">&#127942;</span><span class="aio_txt">Mini Torneos</span></a>{/if}
			{if isModuleAvailable($smarty.const.MODULE_WAR)}<a href="game.php?page=war" class="aio_item" data-aio-page="war"><span class="aio_ic">&#128293;</span><span class="aio_txt">Guerra WAR</span></a>{/if}
		</div>
	</div>

	<div class="aio_group_wrap" data-aio-group>
		<div class="aio_item" data-aio-toggle><span class="aio_ic">&#11088;</span><span class="aio_txt">Mejoras</span><span class="aio_caret">&#9656;</span></div>
		<div class="aio_sub">
			{if isModuleAvailable($smarty.const.MODULE_OFFICIER) && isModuleAvailable($smarty.const.MODULE_DMEXTRAS)}<a href="game.php?page=officier" class="aio_item" data-aio-page="officier"><span class="aio_ic">&#127894;&#65039;</span><span class="aio_txt">Oficiales</span></a>{/if}
			{if isModuleAvailable($smarty.const.MODULE_VIP)}<a href="game.php?page=vip" class="aio_item" data-aio-page="vip"><span class="aio_ic">&#127803;</span><span class="aio_txt">VIP Prime</span></a>{/if}
			{if isModuleAvailable($smarty.const.MODULE_SHOP)}<a href="game.php?page=shop" class="aio_item" data-aio-page="shop"><span class="aio_ic">&#128717;&#65039;</span><span class="aio_txt">Tienda NTX-20</span></a>{/if}
			{if isModuleAvailable($smarty.const.MODULE_BATTLEPASS)}<a href="game.php?page=battlepass" class="aio_item" data-aio-page="battlepass"><span class="aio_ic">&#127941;</span><span class="aio_txt">Pase de Batalla</span></a>{/if}
			{if isModuleAvailable($smarty.const.MODULE_REFERRAL)}<a href="game.php?page=referral" class="aio_item" data-aio-page="referral"><span class="aio_ic">&#128279;</span><span class="aio_txt">Referidos</span></a>{/if}
		</div>
	</div>

	<div class="aio_group_wrap" data-aio-group>
		<div class="aio_item" data-aio-toggle><span class="aio_ic">&#127918;</span><span class="aio_txt">Entretenimiento</span><span class="aio_caret">&#9656;</span></div>
		<div class="aio_sub">
			{if isModuleAvailable($smarty.const.MODULE_CUEVA)}<a href="game.php?page=cueva" class="aio_item" data-aio-page="cueva"><span class="aio_ic">&#127988;&#8205;&#9792;&#65039;</span><span class="aio_txt">La Cueva Pirata</span></a>{/if}
			{if isModuleAvailable($smarty.const.MODULE_MINIJUEGOTOPO)}<a href="game.php?page=minijuegotopo" class="aio_item" data-aio-page="minijuegotopo"><span class="aio_ic">&#128057;</span><span class="aio_txt">Golpea al Topo</span></a>{/if}
			{if isModuleAvailable($smarty.const.MODULE_MINIJUEGONAVIDAD)}<a href="game.php?page=minijuegonavidad" class="aio_item" data-aio-page="minijuegonavidad"><span class="aio_ic">&#127876;</span><span class="aio_txt">Memoria Navide&ntilde;a</span></a>{/if}
			{if isModuleAvailable($smarty.const.MODULE_RAFFLES)}<a href="game.php?page=raffles" class="aio_item" data-aio-page="raffles"><span class="aio_ic">&#127920;</span><span class="aio_txt">Rifas</span></a>{/if}
			{if isModuleAvailable($smarty.const.MODULE_LOTTERY)}<a href="game.php?page=lottery" class="aio_item" data-aio-page="lottery"><span class="aio_ic">&#127903;</span><span class="aio_txt">Loter&iacute;a</span></a>{/if}
			{if isModuleAvailable($smarty.const.MODULE_CONTAINERS)}<a href="game.php?page=containers" class="aio_item" data-aio-page="containers"><span class="aio_ic">&#128230;</span><span class="aio_txt">Contenedores</span></a>{/if}
		</div>
	</div>

	<div class="aio_group_wrap" data-aio-group>
		<div class="aio_item" data-aio-toggle><span class="aio_ic">&#128100;</span><span class="aio_txt">Cuenta</span><span class="aio_caret">&#9656;</span></div>
		<div class="aio_sub">
			<a href="game.php?page=settings" class="aio_item" data-aio-page="settings"><span class="aio_ic">&#9881;&#65039;</span><span class="aio_txt">Ajustes</span></a>
			<a href="index.php?page=rules" class="aio_item"><span class="aio_ic">&#128220;</span><span class="aio_txt">Reglas del servidor</span></a>
			{if isModuleAvailable($smarty.const.MODULE_SUPPORT)}<a href="game.php?page=ticket" class="aio_item" data-aio-page="ticket"><span class="aio_ic">&#128736;&#65039;</span><span class="aio_txt">Soporte</span></a>{/if}
			{if isModuleAvailable($smarty.const.MODULE_BUGREPORT)}<a href="game.php?page=bugreport&mode=new" class="aio_item" data-aio-page="bugreport"><span class="aio_ic">&#128027;</span><span class="aio_txt">Reportar Bug</span></a>{/if}
		</div>
	</div>

	{* ─── JACKPOT (recompensa diaria) ─── *}
	{if isModuleAvailable($smarty.const.MODULE_LOTTERY)}
	<a href="game.php?page=lottery" class="aio_jackpot">
		&#127873;
		<span>JACKPOT<small>RECOMPENSA DIARIA</small></span>
	</a>
	{/if}

	{* ─── Personalización ─── *}
	<div class="aio_group_wrap" data-aio-group>
		<div class="aio_item" data-aio-toggle><span class="aio_ic">&#127912;</span><span class="aio_txt">Personalizaci&oacute;n</span><span class="aio_caret">&#9656;</span></div>
		<div class="aio_sub">
			{if isModuleAvailable($smarty.const.MODULE_RACES)}<a href="game.php?page=race" class="aio_item" data-aio-page="race"><span class="aio_ic">&#129516;</span><span class="aio_txt">Raza</span></a>{/if}
			{if isModuleAvailable($smarty.const.MODULE_FACTIONS)}<a href="game.php?page=faction" class="aio_item" data-aio-page="faction"><span class="aio_ic">&#9878;&#65039;</span><span class="aio_txt">Facci&oacute;n</span></a>{/if}
		</div>
	</div>

	{* ─── Ayuda y ajustes ─── *}
	<div class="aio_group_wrap" data-aio-group>
		<div class="aio_item" data-aio-toggle><span class="aio_ic">&#10067;</span><span class="aio_txt">Ayuda y ajustes</span><span class="aio_caret">&#9656;</span></div>
		<div class="aio_sub">
			<a href="game.php?page=settings" class="aio_item" data-aio-page="settings"><span class="aio_ic">&#9881;&#65039;</span><span class="aio_txt">Ajustes</span></a>
			<a href="index.php?page=rules" class="aio_item"><span class="aio_ic">&#128220;</span><span class="aio_txt">Reglas</span></a>
			{if isModuleAvailable($smarty.const.MODULE_SUPPORT)}<a href="game.php?page=ticket" class="aio_item" data-aio-page="ticket"><span class="aio_ic">&#128736;&#65039;</span><span class="aio_txt">Soporte</span></a>{/if}
		</div>
	</div>

	{* ─── Administración (solo staff) ─── *}
	{if $authlevel > 0}
	<div class="aio_admin">
		<span class="aio_glabel">Administraci&oacute;n</span>
		{if $authlevel >= 2}
		<a href="game.php?page=walletadmin" class="aio_item" id="adminwallet_btn_link" data-aio-page="walletadmin">
			<span class="aio_ic">&#128188;</span><span class="aio_txt">Admin Wallet</span>
			<span class="aio_badge" id="adminwallet_badge">&#9888;&#65039;</span>
		</a>
		{/if}
		<a href="./admin.php" class="aio_item"><span class="aio_ic">&#128272;</span><span class="aio_txt">Panel admin</span></a>
	</div>
	{/if}

	{* ─── Alianza (v6.6 intacto) ─── *}
	{if $allyName && $allyMembersList}
	<div class="aio_ally">
		<div class="aio_ally_title">&#127983; [{$allyTag}] {$allyName}</div>
		{foreach $allyMembersList as $member}
		<div class="ally_member {if $member.online}online{else}offline{/if}">
			<span class="name"><span class="status_dot">{if $member.online}&#128994;{else}&#9879;{/if}</span> {$member.username}</span>
			<span class="time {if !$member.online}offline_time{/if}">{$member.lastSeen|default:'-'}</span>
		</div>
		{/foreach}
	</div>
	{/if}

	{* ─── Selector de diseño: Fotos (por defecto) / Clásico (emojis) ─── *}
	<div class="aio_design">
		<span class="aio_glabel">&#127912; Dise&ntilde;o del juego</span>
		<div class="aio_dbtns">
			<button type="button" id="aio_dbtn_fotos" onclick="ASTROIO_setDesign('fotos')">&#128248; Fotos</button>
			<button type="button" id="aio_dbtn_clasico" onclick="ASTROIO_setDesign('clasico')">&#128512; Cl&aacute;sico</button>
		</div>
	</div>

	{* ─── Footer ─── *}
	<div class="aio_foot">
		&#128994; &Uacute;ltimas 24h: <b>{$onlineCount}/{$totalCount}</b> &middot; &#128340; <b>{$servertime}</b><br>
		&copy; Copyright AstroIO 2026
	</div>

	{* ─── Coordenadas del planeta desde el selector de la topbar ─── *}
	<script>
	(function() {
		/* Submenús */
		document.querySelectorAll('#leftmenu [data-aio-toggle]').forEach(function(el) {
			el.addEventListener('click', function(ev) {
				ev.preventDefault();
				var g = el.closest('[data-aio-group]');
				if (g) g.classList.toggle('open');
			});
		});
		/* Buscador: filtra items y abre los grupos con resultados */
		var si = document.getElementById('aio_nav_search');
		if (si) si.addEventListener('input', function() {
			var q = si.value.toLowerCase();
			document.querySelectorAll('#leftmenu .aio_group_wrap').forEach(function(g) {
				var hits = 0;
				g.querySelectorAll('.aio_sub .aio_item').forEach(function(it) {
					var txt = it.textContent.toLowerCase();
					it.style.display = (!q || txt.indexOf(q) !== -1) ? 'flex' : 'none';
					if (q && txt.indexOf(q) !== -1) hits++;
				});
				var top = g.querySelector('[data-aio-toggle]');
				var topTxt = top ? top.textContent.toLowerCase() : '';
				if (q) { if (hits || topTxt.indexOf(q) !== -1) g.classList.add('open'); else g.classList.remove('open'); }
				else g.classList.remove('open');
				g.style.display = (q && !hits && topTxt.indexOf(q) === -1) ? 'none' : 'block';
			});
			document.querySelectorAll('#leftmenu > .aio_item, #leftmenu > .aio_glabel, #leftmenu > .aio_jackpot, #leftmenu > .aio_planet, #leftmenu > .aio_design, #leftmenu > .aio_admin, #leftmenu > .aio_ally').forEach(function(el) {
				el.style.display = (!q || el.textContent.toLowerCase().indexOf(q) !== -1) ? '' : 'none';
			});
		});
		/* Item activo según la página actual + abre su grupo */
		var m = location.search.match(/page=([a-zA-Z0-9_]+)/);
		var cur = m ? m[1] : 'overview';
		document.querySelectorAll('#leftmenu .aio_item').forEach(function(it) {
			var pg = it.getAttribute('data-aio-page');
			if (pg === cur || (cur === 'shipyard' && pg === 'shipyard') || (cur === 'shipyard' && pg === 'shipyard-defense' && location.search.indexOf('mode=defense') !== -1)) {
				it.classList.add('active');
				var g = it.closest('[data-aio-group]');
				if (g) g.classList.add('open');
			}
		});
		/* Coordenadas de la tarjeta planeta (desde el selector de la topbar) */
		function fillCoords() {
			var sel = document.querySelector('#header select, .astromenu_head select');
			if (!sel || !sel.options || !sel.selectedIndex) return false;
			var opt = sel.options[sel.selectedIndex].text || '';
			if (opt) { var el = document.getElementById('aio_nav_coords'); if (el) el.textContent = opt.trim(); return true; }
			return false;
		}
		if (!fillCoords()) setTimeout(fillCoords, 800);
	})();
	</script>

	{* ─── JS portado v6.6: badges PvE/PvP + polling cueva (verbatim) ─── *}
	<script>


/* ═══════════════════════════════════════════════════════════
 * ASTROIO v1.5 — Cuenta regresiva de Eventos PvE en el MOP
 * ═══════════════════════════════════════════════════════════ */
(function() {
	var link  = document.getElementById('pve_mop_link');
	var badge = document.getElementById('pve_mop_badge');
	if (!link || !badge) return;

	var crisisTime    = parseInt(link.getAttribute('data-crisis-time')    || '0', 10);
	var crisisActive  = parseInt(link.getAttribute('data-crisis-active')  || '0', 10);
	var empireTime    = parseInt(link.getAttribute('data-empire-time')    || '0', 10);
	var empireActive  = parseInt(link.getAttribute('data-empire-active')  || '0', 10);
	var bossTime      = parseInt(link.getAttribute('data-boss-time')      || '0', 10);
	var bossEndTime   = parseInt(link.getAttribute('data-boss-end-time')  || '0', 10);
	var bossActive    = parseInt(link.getAttribute('data-boss-active')    || '0', 10);
	var bossStatus    = (link.getAttribute('data-boss-status') || 'idle').trim();
	var anyActive     = parseInt(link.getAttribute('data-any-active')     || '0', 10);

	function formatCountdown(seconds) {
		if (seconds <= 0) return '0s';
		var d = Math.floor(seconds / 86400);
		var h = Math.floor((seconds % 86400) / 3600);
		var m = Math.floor((seconds % 3600) / 60);
		var s = seconds % 60;
		if (d > 0)  return d + 'd ' + h + 'h';
		if (h > 0)  return h + 'h ' + m + 'm';
		if (m > 0)  return m + 'm ' + s + 's';
		return s + 's';
	}

	function setBadge(text, stateClass) {
		badge.textContent = text;
		badge.className = 'pve_countdown_badge ' + stateClass;
	}

	function updatePVEBadge() {
		var now = Math.floor(Date.now() / 1000);

		if (crisisActive === 1) { setBadge('🔴 ACTIVA', 'state-active'); return; }
		if (crisisTime > now) {
			var diff = crisisTime - now;
			if (diff < 86400) setBadge('⏰ ' + formatCountdown(diff), 'state-soon');
			else setBadge(formatCountdown(diff), 'state-far');
			return;
		}
		if (bossActive === 1) {
			if (bossEndTime > now) {
				var diffEnd = bossEndTime - now;
				if (diffEnd < 86400) setBadge('🌌 ' + formatCountdown(diffEnd), 'state-boss-running');
				else setBadge('🌌 ' + formatCountdown(diffEnd), 'state-boss');
			} else setBadge('🌌 Finalizando', 'state-boss');
			return;
		}
		if (bossStatus === 'registration') {
			if (bossTime > now) setBadge('🌌 ' + formatCountdown(bossTime - now), 'state-boss-soon');
			else setBadge('🌌 Registro', 'state-boss-soon');
			return;
		}
		if (bossStatus === 'scheduled' && bossTime > now) {
			var diffSch = bossTime - now;
			if (diffSch < 86400) setBadge('🌌 ' + formatCountdown(diffSch), 'state-boss-soon');
			else setBadge('🌌 ' + formatCountdown(diffSch), 'state-far');
			return;
		}
		if (empireActive === 1) { setBadge('🏛️ ACTIVO', 'state-active'); return; }
		if (empireTime > now) { setBadge(formatCountdown(empireTime - now), 'state-far'); return; }
		setBadge('Sin activar', 'state-off');
	}

	setInterval(updatePVEBadge, 1000);
	updatePVEBadge();
})();


/* ═══════════════════════════════════════════════════════════
 * ASTROIO — Cuenta regresiva del Sistema PvP en el MOP
 * ═══════════════════════════════════════════════════════════ */
(function() {
	var link  = document.getElementById('pvp_mop_link');
	var badge = document.getElementById('pvp_mop_badge');
	if (!link || !badge) return;

	var arenaActive      = parseInt(link.getAttribute('data-arena-active')      || '0', 10);
	var arenaWaiting     = parseInt(link.getAttribute('data-arena-waiting')     || '0', 10);
	var tournamentActive = parseInt(link.getAttribute('data-tournament-active') || '0', 10);
	var tournamentStatus = (link.getAttribute('data-tournament-status') || '').trim();
	var tournamentTime   = parseInt(link.getAttribute('data-tournament-time')   || '0', 10);

	function formatCountdown(seconds) {
		if (seconds <= 0) return '0s';
		var d = Math.floor(seconds / 86400);
		var h = Math.floor((seconds % 86400) / 3600);
		var m = Math.floor((seconds % 3600) / 60);
		var s = seconds % 60;
		if (d > 0)  return d + 'd ' + h + 'h';
		if (h > 0)  return h + 'h ' + m + 'm';
		if (m > 0)  return m + 'm ' + s + 's';
		return s + 's';
	}

	function setBadge(text, stateClass) {
		badge.textContent = text;
		badge.className = 'pvp_countdown_badge ' + stateClass;
	}

	function updatePVPBadge() {
		var now = Math.floor(Date.now() / 1000);
		if (tournamentActive === 1 && tournamentStatus === 'running') {
			setBadge('🏆 EN CURSO', 'state-active'); return;
		}
		if (tournamentActive === 1 && tournamentStatus === 'registration') {
			if (tournamentTime > now) setBadge('🏆 ' + formatCountdown(tournamentTime - now), 'state-soon');
			else setBadge('🏆 Inscripción', 'state-soon');
			return;
		}
		if (arenaActive > 0) { setBadge('⚔️ ' + arenaActive + ' activas', 'state-active'); return; }
		if (arenaWaiting > 0) { setBadge('🏟️ ' + arenaWaiting + ' abiertas', 'state-far'); return; }
		setBadge('Sin actividad', 'state-off');
	}

	setInterval(updatePVPBadge, 1000);
	updatePVPBadge();
})();


/* ═══════════════════════════════════════════════════════════
 * ASTROIO — RADAR GLOBAL LA CUEVA PIRATA
 * Redirige al jugador al tablero si tiene una partida activa
 * ═══════════════════════════════════════════════════════════ */
(function() {
    // Solo preguntar si NO estamos ya en la página de la partida
    if (window.location.href.indexOf('page=cuevaPartida') === -1) {
        setInterval(function() {
            $.post('game.php?page=cuevaAjax', { accion: 'check_estado_global' }, function(res) {
                if (res.status === 'jugando' && res.sala_id) {
                    // Redirigir automáticamente al tablero
                    window.location.href = 'game.php?page=cuevaPartida&sala=' + res.sala_id;
                }
            });
        }, 5000); // Consulta cada 5 segundos
    }
})();</script>

