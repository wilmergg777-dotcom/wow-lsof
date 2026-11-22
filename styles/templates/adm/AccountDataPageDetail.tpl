{include file="overall_header.tpl"}

{* ============================================================
   AstroIO FIX: Definir claves LNG faltantes para PHP 8.4
   Evita "Undefined array key" cuando el ADMIN.php no tiene
   alguna de las traducciones ac_* usadas en este template.
   ============================================================ *}
{assign var="ac_register_ally_time" value=$ac_register_ally_time|default:''}
{assign var="ac_ali_logo_11"        value=$ac_ali_logo_11|default:''}
{assign var="ac_ali_text_11"        value=$ac_ali_text_11|default:''}
{assign var="ac_ali_text_22"        value=$ac_ali_text_22|default:''}
{assign var="ac_ali_text_33"        value=$ac_ali_text_33|default:''}
{assign var="ac_user_system"        value=$ac_user_system|default:''}
{assign var="ac_recent_destroyed_planets" value=$ac_recent_destroyed_planets|default:''}
{assign var="ac_isnodestruyed"      value=$ac_isnodestruyed|default:''}
{assign var="ac_time_destruyed"     value=$ac_time_destruyed|default:''}
{assign var="ac_coords"             value=$ac_coords|default:''}
{assign var="ac_officier_research"  value=$ac_officier_research|default:''}
{assign var="ac_ally_ranking"       value=$ac_ally_ranking|default:''}
{assign var="ac_view_image"         value=$ac_view_image|default:''}
{assign var="ac_urlnow"             value=$ac_urlnow|default:''}
{* ============================================================ *}

<style type="text/css">
a.link{
font-size:14px;font-variant:small-caps;margin-left:120px;
}
span.no_moon{
font-size:14px;font-variant:small-caps;margin-left:120px;font-family: Arial, Helvetica, sans-serif;
}
span.no_moon:hover{
font-size:14px;font-variant:small-caps;margin-left:120px;color:#FF0000;cursor:default;font-family: Arial, Helvetica, sans-serif;
}
a.ccc{
font-size:15px;
}
a.ccc:hover{
font-size:15px;color:aqua
;}
table.tableunique{
border:0px;background:url(./styles/resource/images/admin/blank.gif);width:100%;
}
td.unico{
border:0px;text-align:left;
}
td.unico2{
border:0px;text-align:center;
}
td{
color:#FFFFFF;font-size:10px;font-variant:normal;
}
td.blank{
border:0px;background:url(./styles/resource/images/admin/blank.gif);text-align:right;padding-right:80px;font-size:15px;
}
</style>


<table class="tableunique">
	<tr>
		<td class="blank"><a class="tooltip" data-tooltip-content="{$ac_note_k|default:''}">{$ac_leyend|default:''}&nbsp; <img src="./styles/resource/images/admin/i.gif" height="12" width="12"></a></td>
	</tr>
	<tr>
		<td class="unico transparent"><a href="#" onclick="$('#datos').slideToggle();return false" class="link">
		<img src="./styles/resource/images/admin/arrowright.png" width="16" height="10"> {$ac_account_data|default:''}</a></td>
	</tr><tr>
		<td class="unico transparent">
			<div id="datos">
			<table align="center" width="60%">
			<tr><th colspan="2">&nbsp;</th></tr>
			<tr><td height="22px">{$input_id|default:''}</td><td>{$id|default:''}</td></tr>
			<tr><td height="22px">{$ac_name|default:''}</td><td>{$nombre|default:''}</td></tr>
			<tr><td height="22px">{$ac_mail|default:''}</td><td>{$email_1|default:''}</td></tr>
			<tr><td height="22px">{$ac_perm_mail|default:''}</td><td>{$email_2|default:''}</td></tr>
			<tr><td height="22px">{$ac_auth_level|default:''}</td><td>{$nivel|default:''}</td></tr>
			<tr><td height="22px">{$ac_on_vacation|default:''}</td><td>{$vacas|default:''}</td></tr>
			<tr><td height="22px">{$ac_banned|default:''}</td><td>{$suspen|default:''} {$mas|default:''}</td></tr>
			<tr><td height="22px">{$ac_alliance|default:''}</td><td>{$alianza|default:''}{$id_ali|default:''}</td></tr>
			<tr><td height="22px">{$ac_reg_ip|default:''}</td><td>{$ip|default:''}</td></tr>
			<tr><td height="22px">{$ac_last_ip|default:''}</td><td>{$ip2|default:''}</td></tr>
			<tr><td height="22px">{$ac_checkip_title|default:''}</td><td>{$ipcheck|default:''}</td></tr>
			<tr><td height="22px">{$ac_register_time|default:''}</td><td>{$reg_time|default:''}</td></tr>
			<tr><td height="22px">{$ac_act_time|default:''}</td><td>{$onlinetime|default:''}</td></tr>
			<tr><td height="22px">{$ac_home_planet_id|default:''}</td><td>{$id_p|default:''}</td></tr>
			<tr><td height="22px">{$ac_home_planet_coord|default:''}</td><td>[{$g|default:''}:{$s|default:''}:{$p|default:''}]</td></tr>
			{if $info}<tr><td height="22px">{$ac_user_system|default:''}</td><td>{$info}</td></tr>{/if}
			<tr><td height="22px">{$ac_ranking|default:''}</td><td><a href="#" onclick="$('#puntaje').slideToggle();return false">{$ac_see_ranking|default:''}</a></td></tr>
			</table>
			<br>
			
			<!-- PUNTAJE DEL USUARIO -->
			<div id="puntaje" style="display:none">
			<table align="center" width="60%">
			<tr><th colspan="3" class="centrado2">{$ac_user_ranking|default:''}</th></tr>
			<td width="15%"></td><td width="40%" class="centrado">{$ac_points_count|default:''}</td><td width="5%" class="centrado">{$ac_ranking|default:''}</td>
			<tr><td width="15%" class="centrado">{$researchs_title|default:''}</td><td width="40%">{$point_tecno|default:''} ({$count_tecno|default:''} {$researchs_title|default:''})</td><td width="5%" class="ranking"># {$ranking_tecno|default:''}</td></tr>
			<tr><td width="15%" class="centrado">{$defenses_title|default:''}</td><td width="40%">{$point_def|default:''} ({$count_def|default:''} {$defenses_title|default:''})</td><td width="5%" class="ranking"># {$ranking_def|default:''}</td></tr>
			<tr><td width="15%" class="centrado">{$ships_title|default:''}</td><td width="40%">{$point_fleet|default:''} ({$count_fleet|default:''} {$ships_title|default:''})</td><td width="5%" class="ranking"># {$ranking_fleet|default:''}</td></tr>
			<tr><td width="15%" class="centrado">{$buildings_title|default:''}</td><td width="40%">{$point_builds|default:''} ({$count_builds|default:''} {$buildings_title|default:''})</td><td width="5%" class="ranking"># {$ranking_builds|default:''}</td></tr>
			<tr><td colspan="3" class="total">{$ac_total_points|default:''}<span style="color:#FF0000">{$total_points|default:''}</span></td></tr>
			</table>
			<br>
			</div>
			
			
			<div id="banned" style="display:none">
			<table align="center" width="60%">
			<tr><th colspan="4">{$ac_suspended_title|default:''}</th></tr>
			<tr><td>{$ac_suspended_time|default:''}</td><td>{$sus_time|default:''}</td></tr>
			<tr><td>{$ac_suspended_longer|default:''}</td><td>{$sus_longer|default:''}</td></tr>
			<tr><td>{$ac_suspended_reason|default:''}</td><td>{$sus_reason|default:''}</td></tr>
			<tr><td>{$ac_suspended_autor|default:''}</td><td>{$sus_author|default:''}</td></tr>
			</table>
			<br>
			</div>
			</div>
		</td>
	</tr><tr>
		<td class="unico transparent">{$AllianceHave|default:''}</td>
	</tr><tr>
		<td class="unico transparent">
			<div id="alianza" style="display:none">
			<table align="center" width="60%">
			<tr><th colspan="2">{$ac_info_ally|default:''}</th></tr>
			<tr><td width="25%" align="center" >{$input_id|default:''}</td><td>{$id_aliz|default:''}</td></tr>
			<tr><td>{$ac_leader|default:''}</td><td>{$ali_lider|default:''}</td></tr>
			<tr><td>{$ac_tag|default:''}</td><td>{$tag|default:''}</td></tr>
			<tr><td>{$ac_name_ali|default:''}</td><td>{$ali_nom|default:''}</td></tr>
			<tr><td>{$ac_ext_text|default:''}</td><td>{$ali_ext|default:''}</td></tr>
			<tr><td>{$ac_int_text|default:''}</td><td>{$ali_int|default:''}</td></tr>
			<tr><td>{$ac_sol_text|default:''}</td><td>{$ali_sol|default:''}</td></tr>
			<tr><td>{$ac_image|default:''}</td><td>{$ali_logo|default:''}</td></tr>
			<tr><td>{$ac_ally_web|default:''}</td><td>{$ali_web|default:''}</td></tr>
			<tr><td>{$ac_register_ally_time|default:''}</td><td>{$ally_register_time|default:''}</td></tr>
			<tr><td>{$ac_total_members|default:''}</td><td>{$ali_cant|default:''}</td></tr>
			<tr><td>{$ac_ranking|default:''}</td><td><a href="#" rel="toggle[puntaje_ali]">{$ac_see_ranking|default:''}</a></td></tr>
			</table>
			<br>

			<div id="imagen" style="display:none">
			<table align="center" width="60%">
			<tr><th>{$ac_ali_logo_11|default:''}</th></tr>
			<tr><td width="60%"><img src="{$ali_logo2|default:''}" class="image"></td></tr>
			<tr><td><a href="{$ali_logo2|default:''}" target="_blank">{$ac_view_image|default:''}</a></td></tr>
			<tr><td>{$ac_urlnow|default:''} <input type="text" size="50" value="{$ali_logo2|default:''}"></td></tr>
			</table>
			<br>
			</div>

			<div id="externo" style="display:none">
			<table align="center" width="60%">
			<tr><th>{$ac_ali_text_11|default:''}</th></tr>
			<tr><td width="60%">{$ali_ext2|default:''}</td></tr>
			</table>
			<br>
			</div>

			<div id="interno" style="display:none">
			<table align="center" width="60%">
			<tr><td class="c">{$ac_ali_text_22|default:''}</td></tr>
			<tr><td width="60%">{$ali_int2|default:''}</td></tr>
			</table>
			<br>
			</div>

			<div id="solicitud" style="display:none">
			<table align="center" width="60%">
			<tr><th>{$ac_ali_text_33|default:''}</th></tr>
			<tr><td width="60%">{$ali_sol2|default:''}</td></tr>
			</table>
			<br>
			</div>

			<!-- PUNTAJE DE LA ALIANZA DEL USUARIO -->
			<div id="puntaje_ali" style="display:none">
			<table align="center" width="60%">
			<tr><td class="c" colspan="3">{$ac_ally_ranking|default:''}</td></tr>
			<td width="15%"></td><td width="40%">{$ac_points_count|default:''}</td><td width="5%" class="centrado">{$ac_ranking|default:''}</td>
			<tr><td width="15%">{$researchs_title|default:''}</td><td width="40%">{$point_tecno_ali|default:''} ({$count_tecno_ali|default:''} {$researchs_title|default:''})</td><td width="5%"># {$ranking_tecno_ali|default:''}</td></tr>
			<tr><td width="15%">{$defenses_title|default:''}</td><td width="40%">{$point_def_ali|default:''} ({$count_def_ali|default:''} {$defenses_title|default:''})</td><td width="5%"># {$ranking_def_ali|default:''}</td></tr>
			<tr><td width="15%">{$ships_title|default:''}</td><td width="40%">{$point_fleet_ali|default:''} ({$count_fleet_ali|default:''} {$ships_title|default:''})</td><td width="5%"># {$ranking_fleet_ali|default:''}</td></tr>
			<tr><td width="15%">{$buildings_title|default:''}</td><td width="40%">{$point_builds_ali|default:''} ({$count_builds_ali|default:''} {$buildings_title|default:''})</td><td width="5%"># {$ranking_builds_ali|default:''}</td></tr>
			<tr><td colspan="3">{$ac_total_points|default:''}<span style="color:#FF0000">{$total_points_ali|default:''}</span></td></tr>
			</table>
			<br>
			</div>
			</div>
		</td>
	</tr><tr>
		<td class="unico transparent"><a href="#" onclick="$('#pla').slideToggle();return false" class="link">
		<img src="./styles/resource/images/admin/arrowright.png" width="16" height="10"> {$ac_id_names_coords|default:''}</a></td>
	</tr><tr>
		<td class="unico transparent">
			<div id="pla" style="display:none">
			<table width="70%" align="center">
			<tr>
				<th>{$ac_name|default:''}</th>
				<th>{$input_id|default:''}</th>
				<th>{$ac_diameter|default:''}</th>
				<th>{$ac_fields|default:''}</th>
				<th>{$ac_temperature|default:''}</th>
				{if $canedit == 1}<th>{$se_search_edit|default:''}</th>{/if}
			</tr>
				{$planets_moons|default:''}
			</table>
			<br>
			</div>
		</td>
	</tr><tr>
		<td class="unico transparent"><a href="#" onclick="$('#recursos').slideToggle();return false" class="link">
		<img src="./styles/resource/images/admin/arrowright.png" width="16" height="10"> {$resources_title|default:''}</a></td>
	</tr><tr>
		<td class="unico transparent">
			<div id="recursos" style="display:none">
			<table width="70%" align="center">
			<tr>
				<th>{$ac_name|default:''}</th>
				<th>{$Metal|default:''}</th>
				<th>{$Crystal|default:''}</th>
				<th>{$Deuterium|default:''}</th>
				<th>{$Energy|default:''}</th>
			</tr>
				{$resources|default:''}
			<tr>
				<td colspan="5" height="30px">{$Darkmatter|default:''}: &nbsp;&nbsp;{$mo|default:''}</td>
			</tr>
			</table>
			<br >
			</div>	
		</td>
	</tr><tr>
		<td class="unico transparent"><a href="#" onclick="$('#edificios').slideToggle();return false" class="link">
		<img src="./styles/resource/images/admin/arrowright.png" width="16" height="10"> {$buildings_title|default:''}</a></td>
	</tr><tr>
		<td class="unico transparent">
			<div id="edificios" style="display:none">
			<table width="100%" align="center">
				{$names|default:''}
				{$build|default:''}
			</table>
			<br >
			</div>
		</td>
	</tr><tr>
		<td class="unico transparent"><a href="#" onclick="$('#naves').slideToggle();return false" class="link">
		<img src="./styles/resource/images/admin/arrowright.png" width="16" height="10"> {$ships_title|default:''}</a></td>
	</tr><tr>
		<td class="unico transparent">
			<div id="naves" style="display:none">
			<table align="center" width="100%">
				{$names|default:''}
				{$fleet|default:''}
			</table>
			<br >
			</div>
		</td>
	</tr><tr>
		<td class="unico transparent"><a href="#" onclick="$('#defensa').slideToggle();return false" class="link">
		<img src="./styles/resource/images/admin/arrowright.png" width="16" height="10"> {$defenses_title|default:''}</a></td>
	</tr><tr>
		<td class="unico transparent">
			<div id="defensa" style="display:none">
			<table align="center" width="100%">
				{$names|default:''}
				{$defense|default:''}
			</table>
			<br >
			</div>
		</td>
	</tr><tr>
		<td class="unico transparent"><a href="#" onclick="$('#inves').slideToggle();return false" class="link">
		<img src="./styles/resource/images/admin/arrowright.png" width="16" height="10"> {$ac_officier_research|default:''}</a></td>
	</tr><tr>
		<td class="unico transparent">
			<div id="inves" style="display:none">
			<table align="center" width="60%">
			<tr>
			<th width="50%">{$researchs_title|default:''}</th>
			<th width="50%">{$officiers_title|default:''}</th>
			</tr>
			{$techoffi|default:''}
			</table>
			<br >
			</div>
		</td>
	</tr><tr>
		<td class="unico transparent">
			{if $DestruyeD != 0}<a href="#" onclick="$('#destr').slideToggle();return false" class="link">
			<img src="./styles/resource/images/admin/arrowright.png" width="16" height="10"> {$ac_recent_destroyed_planets|default:''}</a>
			{else}<span class="no_moon"><img src="./styles/resource/images/admin/arrowright.png" width="16" height="10"> 
			{$ac_recent_destroyed_planets|default:''}&nbsp;{$ac_isnodestruyed|default:''}</span>{/if}
		</td>
	</tr><tr>
		<td class="unico transparent">
			<div id="destr" style="display:none">
			<table align="center" width="60%">
			<tr>
				<th>{$ac_name|default:''}</th>
				<th>{$input_id|default:''}</th>
				<th>{$ac_coords|default:''}</th>
				<th>{$ac_time_destruyed|default:''}</th>
			</tr>
				{$destroyed|default:''}
			</table>
			<br>
			</div>
		</td>
	</tr>
</table>
{include file="overall_footer.tpl"}