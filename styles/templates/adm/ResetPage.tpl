{include file="overall_header.tpl"}
<form action="" method="post" onsubmit="return confirm('{$re_reset_universe_confirmation}');">
<table width="40%">
<tr><th colspan="2">{$re_player_and_planets}</th></tr>
<tr><td style="text-align:left">{$re_reset_player}</td><td style="text-align:right"><input type="checkbox" name="players"></td></tr>
<tr><td style="text-align:left">{$re_reset_planets}</td><td style="text-align:right"><input type="checkbox" name="planets"></td></tr>
<tr><td style="text-align:left">{$re_reset_moons}</td><td style="text-align:right"><input type="checkbox" name="moons"></td></tr>

<tr><th colspan="2">{$re_defenses_and_ships}</th></tr>
<tr><td style="text-align:left">{$re_defenses}</td><td style="text-align:right"><input type="checkbox" name="defenses"></td></tr>
<tr><td style="text-align:left">{$re_ships}</td><td style="text-align:right"><input type="checkbox" name="ships"></td></tr>
<tr><td style="text-align:left">{$re_reset_hangar}</td><td style="text-align:right"><input type="checkbox" name="h_d"></td></tr>

<tr><th colspan="2">{$re_buldings}</th></tr>
<tr><td style="text-align:left">{$re_buildings_pl}</td><td style="text-align:right"><input type="checkbox" name="edif_p"></td></tr>
<tr><td style="text-align:left">{$re_buildings_lu}</td><td style="text-align:right"><input type="checkbox" name="edif_l"></td></tr>
<tr><td style="text-align:left">{$re_reset_buldings}</td><td style="text-align:right"><input type="checkbox" name="edif"></td></tr>

<tr><th colspan="2">{$re_inve_ofis}</th></tr>
<tr><td style="text-align:left">{$re_ofici}</td><td style="text-align:right"><input type="checkbox" name="ofis"></td></tr>
<tr><td style="text-align:left">{$re_investigations}</td><td style="text-align:right"><input type="checkbox" name="inves"></td></tr>
<tr><td style="text-align:left">{$re_reset_invest}</td><td style="text-align:right"><input type="checkbox" name="inves_c"></td></tr>

<tr><th colspan="2">{$re_resources}</th></tr>
<tr><td style="text-align:left">{$re_resources_dark}</td><td style="text-align:right"><input type="checkbox" name="dark"></td></tr>
<tr><td style="text-align:left">{$re_resources_met_cry}</td><td style="text-align:right"><input type="checkbox" name="resources"></td></tr>

<tr><th colspan="2">{$re_general}</th></tr>
<tr><td style="text-align:left">{$re_reset_notes}</td><td style="text-align:right"><input type="checkbox" name="notes"></td></tr>
<tr><td style="text-align:left">{$re_reset_rw}</td><td style="text-align:right"><input type="checkbox" name="rw"></td></tr>
<tr><td style="text-align:left">{$re_reset_buddies}</td><td style="text-align:right"><input type="checkbox" name="friends"></td></tr>
<tr><td style="text-align:left">{$re_reset_allys}</td><td style="text-align:right"><input type="checkbox" name="alliances"></td></tr>
<tr><td style="text-align:left">{$re_reset_fleets}</td><td style="text-align:right"><input type="checkbox" name="fleets"></td></tr>
<tr><td style="text-align:left">{$re_reset_errors}</td><td style="text-align:right"><input type="checkbox" name="errors"></td></tr>
<tr><td style="text-align:left">{$re_reset_banned}</td><td style="text-align:right"><input type="checkbox" name="banneds"></td></tr>
<tr><td style="text-align:left">{$re_reset_messages}</td><td style="text-align:right"><input type="checkbox" name="messages"></td></tr>
<tr><td style="text-align:left">{$re_reset_statpoints}</td><td style="text-align:right"><input type="checkbox" name="statpoints"></td></tr>

<tr><th colspan="2" style="color:#00ccff;">ASTROIO v2.1.3 - MODULOS BASE</th></tr>
<tr><td style="text-align:left">Resetear VIP</td><td style="text-align:right"><input type="checkbox" name="astroio_vip"></td></tr>
<tr><td style="text-align:left">Resetear Eventos (reinstala los 14 auto)</td><td style="text-align:right"><input type="checkbox" name="astroio_events"></td></tr>
<tr><td style="text-align:left">Resetear Wallet (inversiones, retiros, historial)</td><td style="text-align:right"><input type="checkbox" name="astroio_wallet"></td></tr>
<tr><td style="text-align:left">Resetear Mercado (ofertas, log, stats)</td><td style="text-align:right"><input type="checkbox" name="astroio_market"></td></tr>
<tr><td style="text-align:left">Resetear Pase de Batalla</td><td style="text-align:right"><input type="checkbox" name="astroio_bp"></td></tr>
<tr><td style="text-align:left">Resetear Reportes de Bugs</td><td style="text-align:right"><input type="checkbox" name="astroio_bugs"></td></tr>
<tr><td style="text-align:left">Resetear Rifas</td><td style="text-align:right"><input type="checkbox" name="astroio_raffles"></td></tr>
<tr><td style="text-align:left">Resetear Loteria</td><td style="text-align:right"><input type="checkbox" name="astroio_lottery"></td></tr>
<tr><td style="text-align:left">Resetear Mejoras (inventario + equipadas)</td><td style="text-align:right"><input type="checkbox" name="astroio_improvements"></td></tr>
<tr><td style="text-align:left">Resetear NTX-20 (usuarios y planetas)</td><td style="text-align:right"><input type="checkbox" name="astroio_ntx20"></td></tr>
<tr><td style="text-align:left">Resetear Fondos (wallet_fund + market_fund)</td><td style="text-align:right"><input type="checkbox" name="astroio_funds"></td></tr>
<tr><td style="text-align:left">Resetear Referidos (ref_id, ref_bonus)</td><td style="text-align:right"><input type="checkbox" name="astroio_refs"></td></tr>
<tr><td style="text-align:left">Resetear Guerra WAR (batallas, puntos, cofres, historial)</td><td style="text-align:right"><input type="checkbox" name="astroio_war"></td></tr>
<tr><td style="text-align:left">Resetear Banco de Alianza (saldo, bonus, tesorero)</td><td style="text-align:right"><input type="checkbox" name="astroio_allybank"></td></tr>
<tr><td style="text-align:left">Resetear FleetTools (favoritos, presets, logs)</td><td style="text-align:right"><input type="checkbox" name="astroio_fleettools"></td></tr>
<tr><td style="text-align:left">Resetear Tareas (progreso del jugador)</td><td style="text-align:right"><input type="checkbox" name="astroio_tasks"></td></tr>
<tr><td style="text-align:left">Resetear Logros (progreso del jugador)</td><td style="text-align:right"><input type="checkbox" name="astroio_achievements"></td></tr>
<tr><td style="text-align:left">Resetear Discord (OAuth + vinculaciones)</td><td style="text-align:right"><input type="checkbox" name="astroio_discord"></td></tr>
<tr><td style="text-align:left">Resetear Boosters (activos de jugadores)</td><td style="text-align:right"><input type="checkbox" name="astroio_boosters"></td></tr>
<tr><td style="text-align:left"><b style="color:#ffcc00;">⭐ Restaurar Catálogo de Potenciadores (7 base)</b></td><td style="text-align:right"><input type="checkbox" name="astroio_boosters_catalog"></td></tr>
<tr><td style="text-align:left">Resetear Contenedores (historial de aperturas)</td><td style="text-align:right"><input type="checkbox" name="astroio_containers"></td></tr>
<tr><td style="text-align:left">Resetear Razas/Facciones (eleccion del jugador)</td><td style="text-align:right"><input type="checkbox" name="astroio_races"></td></tr>
<tr><td style="text-align:left"><b>Resetear Sistema PvE (Crisis + Imperio + Fantasmas)</b></td><td style="text-align:right"><input type="checkbox" name="astroio_pve"></td></tr>
<tr><td style="text-align:left"><b>Resetear Tienda NTX-20 (historial + rollback)</b></td><td style="text-align:right"><input type="checkbox" name="astroio_shop"></td></tr>

<tr><th colspan="2" style="color:#ffcc00;">ASTROIO v3.0 - SISTEMAS NUEVOS</th></tr>
<tr><td style="text-align:left"><b>Resetear Boss System (El Devorador Estelar)</b></td><td style="text-align:right"><input type="checkbox" name="astroio_boss"></td></tr>
<tr><td style="text-align:left"><b>Resetear Bastion de la Alianza</b></td><td style="text-align:right"><input type="checkbox" name="astroio_bastion"></td></tr>
<tr><td style="text-align:left">Resetear Banco Admin (saldos y movimientos)</td><td style="text-align:right"><input type="checkbox" name="astroio_admin_bank"></td></tr>
<tr><td style="text-align:left">Resetear PvP (Arenas + Torneos + Puntos)</td><td style="text-align:right"><input type="checkbox" name="astroio_pvp"></td></tr>
<tr><td style="text-align:left">Resetear Asteroides (activos actuales)</td><td style="text-align:right"><input type="checkbox" name="astroio_asteroids"></td></tr>
<tr><td style="text-align:left">Resetear Talentos de Alianza</td><td style="text-align:right"><input type="checkbox" name="astroio_talent"></td></tr>
<tr><td style="text-align:left">Resetear Wallet AMM (historial de tasa)</td><td style="text-align:right"><input type="checkbox" name="astroio_wallet_amm"></td></tr>
<tr><td style="text-align:left">Resetear Auth Externa (users_auth)</td><td style="text-align:right"><input type="checkbox" name="astroio_users_auth"></td></tr>
<tr><td style="text-align:left">Resetear Misiles nuevos (Antimateria + Interceptor Av.)</td><td style="text-align:right"><input type="checkbox" name="astroio_misiles"></td></tr>
<tr><td style="text-align:left">Resetear Planetario (droides + teleport + rename)</td><td style="text-align:right"><input type="checkbox" name="astroio_planetario"></td></tr>
<tr><td style="text-align:left"><b style="color:#88ff88;">🎉 Resetear Boost Fin de Semana (config a defaults)</b></td><td style="text-align:right"><input type="checkbox" name="astroio_weekend_boost"></td></tr>

<tr><th colspan="2" style="color:#ffaa33;">ASTROIO v3.4 - MINI TORNEOS</th></tr>
<tr><td style="text-align:left"><b style="color:#ffcc66;">🏆 Resetear Mini Torneos (torneos + inscripciones + historial)</b></td><td style="text-align:right"><input type="checkbox" name="astroio_tourney"></td></tr>

<tr><th style="text-align:left;">{$re_reset_all}</th><th style="text-align:right;margin-right:2px;padding-right:5px;width:10px;"><input type="checkbox" name="resetall" onclick="$('input').attr('checked', this.checked ? 'checked' : false)"></th></tr>


<tr><td colspan="2" height="60"><input type="submit" value="{$button_submit}"></td></tr>
</table>
{include file="overall_footer.tpl"}