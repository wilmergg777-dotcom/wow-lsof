{include file="overall_header.tpl"}
<form action="" method="post">
<input type="hidden" name="opt_save" value="1">

{* ═══════════════════════════════════════════════════════════
   MENSAJE DE RESULTADO tras pulsar "Vaciar chat ahora"
   ═══════════════════════════════════════════════════════════ *}
{if isset($wipe_result) && $wipe_result !== null}
	{if $wipe_result.success}
		<div style="width:70%; margin:10px auto; padding:10px 14px; border-radius:6px;
		            background:rgba(0,180,90,0.18); border:1px solid #00cc66;
		            color:#aaffcc; font-weight:600; font-size:13px;">
			✅ Chat vaciado correctamente. Se eliminaron <strong>{$wipe_result.count}</strong> mensajes.
		</div>
	{else}
		<div style="width:70%; margin:10px auto; padding:10px 14px; border-radius:6px;
		            background:rgba(200,0,0,0.18); border:1px solid #ff4444;
		            color:#ffbbbb; font-weight:600; font-size:13px;">
			❌ Error al vaciar el chat: {$wipe_result.error}
		</div>
	{/if}
{/if}

<table width="70%" cellpadding="2" cellspacing="2">
<tr>
	<th colspan="2">{$se_server_parameters}</th>
	<th>(?)</th>
</tr><tr>
	<td>{$ch_channelname}</td>
	<td><input name="chat_channelname" value="{$chat_channelname}" type="text"></td>
	<td>&nbsp;</td>
</tr><tr>
	<td>{$ch_botname}</td>
	<td><input name="chat_botname" value="{$chat_botname}" type="text"></td>
	<td>&nbsp;</td>
</tr><tr>
	<td>{$ch_nickchange}</td>
	<td><input name="chat_nickchange"{if $chat_nickchange == '1'} checked="checked"{/if} type="checkbox"></td>
	<td>&nbsp;</td>
</tr><tr>
	<td>{$ch_logmessage}</td>
	<td><input name="chat_logmessage"{if $chat_logmessage == '1'} checked="checked"{/if} type="checkbox"></td>
	<td>&nbsp;</td>
</tr><tr>
	<td>{$ch_allowmes}</td>
	<td><input name="chat_allowmes"{if $chat_allowmes == '1'} checked="checked"{/if} type="checkbox"></td>
	<td>&nbsp;</td>
</tr><tr>
	<td>{$ch_allowchan}</td>
	<td><input name="chat_allowchan"{if $chat_allowchan == '1'} checked="checked"{/if} type="checkbox"></td>
	<td>&nbsp;</td>
</tr><tr>
	<td>{$ch_closed}</td>
	<td><input name="chat_closed"{if $chat_closed == '1'} checked="checked"{/if} type="checkbox"></td>
	<td>&nbsp;</td>
</tr><tr>
	<td>{$ch_retention}</td>
	<td>
		<select name="chat_retention_minutes">
			<option value="0"{if $chat_retention_minutes == 0} selected="selected"{/if}>Sin borrado automático</option>
			<option value="5"{if $chat_retention_minutes == 5} selected="selected"{/if}>5 minutos</option>
			<option value="15"{if $chat_retention_minutes == 15} selected="selected"{/if}>15 minutos</option>
			<option value="30"{if $chat_retention_minutes == 30} selected="selected"{/if}>30 minutos</option>
			<option value="60"{if $chat_retention_minutes == 60} selected="selected"{/if}>1 hora</option>
			<option value="180"{if $chat_retention_minutes == 180} selected="selected"{/if}>3 horas</option>
			<option value="360"{if $chat_retention_minutes == 360} selected="selected"{/if}>6 horas</option>
			<option value="720"{if $chat_retention_minutes == 720} selected="selected"{/if}>12 horas</option>
			<option value="1440"{if $chat_retention_minutes == 1440} selected="selected"{/if}>24 horas</option>
			<option value="10080"{if $chat_retention_minutes == 10080} selected="selected"{/if}>7 días</option>
			<option value="43200"{if $chat_retention_minutes == 43200} selected="selected"{/if}>30 días</option>
		</select>
	</td>
	<td title="{$ch_retention_hint}">(?)</td>
</tr>

{* ═══════════════════════════════════════════════════════════
   BOTONES: Guardar parámetros + Vaciar chat ahora
   ═══════════════════════════════════════════════════════════ *}
<tr>
	<td colspan="3" style="padding-top:12px;">
		<input value="{$se_save_parameters}" type="submit" style="margin-right:12px;">

		<button type="submit"
		        name="wipe_chat"
		        value="1"
		        style="background:linear-gradient(135deg,#cc2200,#ff5522);
		               color:#fff; border:1px solid #ff7744; border-radius:5px;
		               padding:4px 14px; font-weight:700; cursor:pointer;
		               font-size:12px; letter-spacing:0.4px;"
		        onclick="return confirm('⚠️ ¿Borrar TODOS los mensajes del chat?\n\nEsta acción NO se puede deshacer.\n\n¿Continuar?');">
			🗑️ Vaciar chat ahora
		</button>
	</td>
</tr>
</table>
</form>
{include file="overall_footer.tpl"}