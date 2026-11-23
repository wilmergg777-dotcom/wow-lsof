{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/adm/QuickEditorPlanet.tpl === *}
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
<script type="text/javascript">
function check(){
	$.post('?page=qeditor&edit=planet&id={$id}&action=send', $('#userform').serialize(), function(data){
		Dialog.alert(data, function() {
			opener.location.reload();
			window.close();
		});
	});
	return false;
}
</script>
<form method="post" id="userform" action="" onsubmit="return check();">
<table width="100%" style="color:#FFFFFF"><tr>
        <th colspan="3">{$LNG.qe_info}</th>
</tr>
<tr style="height:26px;"><td width="50%">{$LNG.qe_id}:</td><td width="50%">{$id}</td></tr>
<tr><td width="50%">{$LNG.qe_planetname}:</td><td width="50%"><input name="name" type="text" size="15" value="{$name}"></td></tr>
<tr style="height:26px;"><td width="50%">{$LNG.qe_coords}:</td><td width="50%">[{$galaxy}:{$system}:{$planet}]</td></tr>
<tr style="height:26px;"><td width="50%">{$LNG.qe_owner}:</td><td width="50%">{$ownername} ({$LNG.qe_id}: {$ownerid})</td></tr>
<tr><td width="50%">{$LNG.qe_fields}:</td><td width="50%">{$field_min} / <input name="field_max" type="text" size="3" value="{$field_max}"></td></tr>
<tr style="height:26px;"><td width="50%">{$LNG.qe_temp}:</td><td width="50%">{$temp_min} / {$temp_max}</td></tr>
</table>
<table width="100%" style="color:#FFFFFF">
<tr>
        <th colspan="3">{$LNG.qe_resources}</th>
</tr>
<tr>
        <td></td><td>{$LNG.qe_count}</td><td>{$LNG.qe_input}</td>
</tr>
<tr><td width="30%">{$LNG.tech.901}:</td><td width="30%">{$metal_c}</td><td width="40%"><input name="metal" type="text" value="{$metal}"></td></tr>
<tr><td width="30%">{$LNG.tech.902}:</td><td width="30%">{$crystal_c}</td><td width="40%"><input name="crystal" type="text" value="{$crystal}"></td></tr>
<tr><td width="30%">{$LNG.tech.903}:</td><td width="30%">{$deuterium_c}</td><td width="40%"><input name="deuterium" type="text" value="{$deuterium}"></td></tr>
</table>
<table width="100%" style="color:#FFFFFF">
<tr>
        <th colspan="3">{$LNG.qe_build}</th>
</tr>
<tr>
        <td></td><td>{$LNG.qe_level}</td><td>{$LNG.qe_input}</td>
</tr>
{foreach item=Element from=$build}
<tr><td width="30%">{$Element.name}:</td><td width="30%">{$Element.count}</td><td width="40%"><input name="{$Element.type}" type="text" value="{$Element.input}"></td>
{/foreach}
</table>
<table width="100%" style="color:#FFFFFF">
<tr>
        <th colspan="3">{$LNG.qe_fleet}</th>
</tr>
<tr>
        <td></td><td>{$LNG.qe_count}</td><td>{$LNG.qe_input}</td>
</tr>
{foreach item=Element from=$fleet}
<tr><td width="30%">{$Element.name}:</td><td width="30%">{$Element.count}</td><td width="40%"><input name="{$Element.type}" type="text" value="{$Element.input}"></td>
{/foreach}
</table>
<table width="100%" style="color:#FFFFFF">
<tr>
        <th colspan="3">{$LNG.qe_defensive}</th>
</tr>
<tr>
        <td></td><td>{$LNG.qe_count}</td><td>{$LNG.qe_input}</td>
</tr>
{foreach item=Element from=$defense}
<tr><td width="30%">{$Element.name}:</td><td width="30%">{$Element.count}</td><td width="40%"><input name="{$Element.type}" type="text" value="{$Element.input}"></td>
{/foreach}
<tr>
        <td colspan="3"><input type="submit" value="{$LNG.qe_submit}"> <input type="reset" value="{$LNG.qe_reset}"></td>
</tr>
</table>
</form>
{include file="overall_footer.tpl"}