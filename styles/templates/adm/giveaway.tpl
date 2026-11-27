{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/adm/giveaway.tpl === *}
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
<form method="post">
<input type="hidden" name="action" value="send">
<!-- Zielplaneten definieren -->
<table width="760px" style="color:#FFFFFF"><tr>
        <th colspan="3">{$LNG.ga_definetarget}</th>
</tr>
<tr style="height:26px;">
	<td width="50%">{$LNG.ga_planettypes}:</td>
	<td width="50%">
		<table style="color:#FFFFFF">
			<tr>
				<td class="transparent"><input type="checkbox" name="planet" value="1" checked></td>
				<td class="transparent left">{$LNG.fcm_planet}</td>
			</tr>
			<tr>
				<td class="transparent"><input type="checkbox" name="moon" value="1"></td>
				<td class="transparent left">{$LNG.fcm_moon}</td>
			</tr>
		</table>
	</td>
</tr>
<tr style="height:26px;"><td width="50%">{$LNG.ga_homecoordinates}:</td><td width="50%"><input type="checkbox" name="mainplanet" value="1"></td></tr>
<tr style="height:26px;"><td width="50%">{$LNG.ga_no_inactives}:</td><td width="50%"><input type="checkbox" name="no_inactive" value="1"></td></tr>
</table>


<!-- Rohstoffe -->
<table width="760px" style="color:#FFFFFF">
<tr>
        <th colspan="2">{$LNG.tech.900}</th>
</tr>
{foreach item=Element from=$reslist.resstype.1}
<tr><td width="50%">{$LNG.tech.{$Element}}:</td><td width="50%"><input type="text" name="element_{$Element}" value="0" pattern="[0-9]*"></td></tr>
{/foreach}
{foreach item=Element from=$reslist.resstype.3}
<tr><td width="50%">{$LNG.tech.{$Element}}:</td><td width="50%"><input type="text" name="element_{$Element}" value="0" pattern="[0-9]*"></td></tr>
{/foreach}
</table>

<!-- ============================================ -->
<!-- ASTROIO - NTX-20 y Contenedores              -->
<!-- ============================================ -->
<table width="760px" style="color:#FFFFFF; border:1px solid #00ccff; margin-top:10px;">
<tr>
        <th colspan="2" style="background:linear-gradient(135deg,#0066cc,#0099ff); color:#fff; padding:8px;">🎁 AstroIO - Criptomoneda y Contenedores</th>
</tr>
<tr style="height:26px;">
	<td width="50%" style="color:#00ff88; font-weight:bold;">💎 NTX-20 (criptomoneda):</td>
	<td width="50%"><input type="text" name="element_930" value="0" pattern="[0-9]*"></td>
</tr>
<tr style="height:26px;">
	<td width="50%" style="color:#ffcc00; font-weight:bold;">📦 Contenedores:</td>
	<td width="50%"><input type="text" name="element_931" value="0" pattern="[0-9]*"></td>
</tr>
<tr>
	<td colspan="2" style="font-size:11px; color:#888; font-style:italic; padding:6px;">
		Estos recursos se dan al <strong>USUARIO</strong>, no al planeta. Se respetan los mismos filtros (activos / tipo de planeta).
	</td>
</tr>
</table>

<!-- Gebäude -->
<table width="760px" style="color:#FFFFFF">
<tr>
        <th colspan="2">{$LNG.tech.0}</th>
</tr>
{foreach item=Element from=$reslist.build}
<tr><td width="50%">{$LNG.tech.{$Element}}:</td><td width="50%"><input type="text" name="element_{$Element}" value="0" pattern="[0-9]*"></td></tr>
{/foreach}
</table>

<!-- Technologie -->
<table width="760px" style="color:#FFFFFF">
<tr>
        <th colspan="2">{$LNG.tech.100}</th>
</tr>
{foreach item=Element from=$reslist.tech}
<tr><td width="50%">{$LNG.tech.{$Element}}:</td><td width="50%"><input type="text" name="element_{$Element}" value="0" pattern="[0-9]*"></td></tr>
{/foreach}
</table>

<!-- Schiffe -->
<table width="760px" style="color:#FFFFFF">
<tr>
        <th colspan="2">{$LNG.tech.200}</th>
</tr>
{foreach item=Element from=$reslist.fleet}
<tr><td width="50%">{$LNG.tech.{$Element}}:</td><td width="50%"><input type="text" name="element_{$Element}" value="0" pattern="[0-9]*"></td></tr>
{/foreach}
</table>

<!-- Verteidigung -->
<table width="760px" style="color:#FFFFFF">
<tr>
        <th colspan="2">{$LNG.tech.400}</th>
</tr>
{foreach item=Element from=$reslist.defense}
<tr><td width="50%">{$LNG.tech.{$Element}}:</td><td width="50%"><input type="text" name="element_{$Element}" value="0" pattern="[0-9]*"></td></tr>
{/foreach}
</table>

<!-- Offiziere -->
<table width="760px" style="color:#FFFFFF">
<tr>
        <th colspan="2">{$LNG.tech.600}</th>
</tr>
{foreach item=Element from=$reslist.officier}
<tr><td width="50%">{$LNG.tech.{$Element}}:</td><td width="50%"><input type="text" name="element_{$Element}" value="0" pattern="[0-9]*"></td></tr>
{/foreach}
</table>


<table width="760px" style="color:#FFFFFF">
<tr>
        <td><input type="submit" value="{$LNG.qe_send}"></td>
</tr>
</table>
</form>
{include file="overall_footer.tpl"}