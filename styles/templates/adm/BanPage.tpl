{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/adm/BanPage.tpl === *}
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
{nocache}{if isset($name)}
<form action="" method="post" name="countt">
<table width="50%">
<tr>
	<th colspan="3">{$bantitle}</th>
</tr><tr>
	<td>{$LNG.bo_username}</td>
	<td colspan="2"><input name="ban_name" type="text" value="{$name}" readonly="true" class="character"/></td>
</tr><tr>
	<td>{$LNG.bo_reason} <br><br>{$LNG.bo_characters_1}<input id="result2" value="50" size="2" readonly="true" class="character"></td> 
	<td colspan="2"><textarea name="why" maxlength="50" cols="20" rows="5" onkeyup="$('#result2').val(50 - parseInt($(this).val().length));">{$reas}</textarea></td>
</tr>
	{$timesus}
<tr>
	<th colspan="2">{$changedate}</th>
	{$changedate_advert}
</tr><tr>
	<td>{$LNG.bo_permanent}</td>
	<td><input name="permanent" type="checkbox"></td>
	{if $changedate_advert}<td>&nbsp;</td>{/if}
</tr><tr>
	<td>{$LNG.time_days}</td>
	<td><input name="days" type="text" value="0" size="5"></td>
	{if $changedate_advert}<td>&nbsp;</td>{/if}
</tr><tr>
	<td>{$LNG.time_hours}</td>
	<td><input name="hour" type="text" value="0" size="5"></td>
	{if $changedate_advert}<td>&nbsp;</td>{/if}
</tr><tr>
	<td>{$LNG.time_minutes}</td>
	<td><input name="mins" type="text" value="0" size="5"></td>
	{if $changedate_advert}<td>&nbsp;</td>{/if}
</tr><tr>
	<td>{$LNG.time_seconds}</td>
	<td><input name="secs" type="text" value="0" size="5"></td>
	{if $changedate_advert}<td>&nbsp;</td>{/if}
</tr><tr>
	<th colspan="3">{$LNG.bo_vacaations}</th>
</tr><tr>
	<td>{$LNG.bo_vacation_mode}</td>
	<td colspan="2"><input name="vacat" type="checkbox"{if $vacation} checked = "checked"{/if}></td>
</tr><tr>
	<td colspan="3">
	<input type="submit" value="{$LNG.button_submit}" name="bannow" style="width:20%;"/>
</tr>
</table>
</form>
{/if}{/nocache}
<form action="" method="POST" name="users">
<table width="100%" border="0px">
<td style="border:0px;width:50%" class="transparent">
<table align="center" width="90%">
<tr>
	<th>{$LNG.bo_ban_player}</th>
</tr>
<tr>
	<td>
	<select name="ban_name" style="width:70%;" size="20">
	{$UserSelect.List}
	</select>
	<br>
	<a href="?page=bans">{$LNG.bo_order_username}</a> &nbsp; <a href="?page=bans&amp;order=id">{$LNG.bo_order_id}</a> &nbsp; 
	<a href="?page=bans&amp;view=bana">{$LNG.bo_order_banned}</a>
	<script TYPE="text/javascript">
		var UserList = new filterlist(document.getElementsByName('ban_name')[0]);
	</script>
	
	<br><br>
	<a href="javascript:UserList.set('^A')" title="{$LNG.bo_select_title} A">A</A>
	<a href="javascript:UserList.set('^B')" title="{$LNG.bo_select_title} B">B</A>
	<a href="javascript:UserList.set('^C')" title="{$LNG.bo_select_title} C">C</A>
	<a href="javascript:UserList.set('^D')" title="{$LNG.bo_select_title} D">D</A>

	<a href="javascript:UserList.set('^E')" title="{$LNG.bo_select_title} E">E</A>
	<a href="javascript:UserList.set('^F')" title="{$LNG.bo_select_title} F">F</A>
	<a href="javascript:UserList.set('^G')" title="{$LNG.bo_select_title} G">G</A>
	<a href="javascript:UserList.set('^H')" title="{$LNG.bo_select_title} H">H</A>
	<a href="javascript:UserList.set('^I')" title="{$LNG.bo_select_title} I">I</A>
	<a href="javascript:UserList.set('^J')" title="{$LNG.bo_select_title} J">J</A>
	<a href="javascript:UserList.set('^K')" title="{$LNG.bo_select_title} K">K</A>
	<a href="javascript:UserList.set('^L')" title="{$LNG.bo_select_title} L">L</A>
	<a href="javascript:UserList.set('^M')" title="{$LNG.bo_select_title} M">M</A>

	<a href="javascript:UserList.set('^N')" title="{$LNG.bo_select_title} N">N</A>
	<a href="javascript:UserList.set('^O')" title="{$LNG.bo_select_title} O">O</A>
	<a href="javascript:UserList.set('^P')" title="{$LNG.bo_select_title} P">P</A>
	<a href="javascript:UserList.set('^Q')" title="{$LNG.bo_select_title} Q">Q</A>
	<a href="javascript:UserList.set('^R')" title="{$LNG.bo_select_title} R">R</A>
	<a href="javascript:UserList.set('^S')" title="{$LNG.bo_select_title} S">S</A>
	<a href="javascript:UserList.set('^T')" title="{$LNG.bo_select_title} T">T</A>
	<a href="javascript:UserList.set('^U')" title="{$LNG.bo_select_title} U">U</A>
	<a href="javascript:UserList.set('^V')" title="{$LNG.bo_select_title} V">V</A>

	<a href="javascript:UserList.set('^W')" title="{$LNG.bo_select_title} W">W</A>
	<a href="javascript:UserList.set('^X')" title="{$LNG.bo_select_title} X">X</A>
	<a href="javascript:UserList.set('^Y')" title="{$LNG.bo_select_title} Y">Y</A>
	<a href="javascript:UserList.set('^Z')" title="{$LNG.bo_select_title} Z">Z</A>
	<br>
	<input NAME="regexp" onKeyUp="UserList.set(this.value)">
	<input TYPE="button" onClick="UserList.set(this.form.regexp.value)" value="{$LNG.button_filter}">
	<input TYPE="button" onClick="UserList.reset();this.form.regexp.value=''" value="{$LNG.button_deselect}">
</td>
</tr><tr>
	<td>
	<input type="submit" value="{$LNG.bo_ban}" name="panel" style="width:20%;">&nbsp;
	<input TYPE="button" onClick="UserList.reset();this.form.regexp.value=''" value="{$LNG.button_reset}">
	</td>
</tr><tr>
	<td align="left">
		{$LNG.bo_total_users}<span style="color:lime">{$usercount}</span>
	</td>
</tr>
</table>
</form>
</td>
<td style="border:0px;width:50%;" class="transparent">
<br>
<form action="" method="POST" name="userban">
<table align="center" width="90%">
<tr>
	<th>{$LNG.bo_unban_player}</th>
</tr>
<tr>
	<td>
	<select name="unban_name" size="20" style="width:70%;">
	{$UserSelect.ListBan}
	</select>
	<br>
	<a href="?page=bans">{$LNG.bo_order_username}</a> &nbsp; <a href="?page=bans&amp;order2=id">{$LNG.bo_order_id}</a>
	<script TYPE="text/javascript">
		var UsersBan = new filterlist(document.getElementsByName('unban_name')[0]);
	</script>
	
	<br><br>
	<a href="javascript:UsersBan.set('^A')" title="{$LNG.bo_select_title} A">A</A>
	<a href="javascript:UsersBan.set('^B')" title="{$LNG.bo_select_title} B">B</A>
	<a href="javascript:UsersBan.set('^C')" title="{$LNG.bo_select_title} C">C</A>
	<a href="javascript:UsersBan.set('^D')" title="{$LNG.bo_select_title} D">D</A>

	<a href="javascript:UsersBan.set('^E')" title="{$LNG.bo_select_title} E">E</A>
	<a href="javascript:UsersBan.set('^F')" title="{$LNG.bo_select_title} F">F</A>
	<a href="javascript:UsersBan.set('^G')" title="{$LNG.bo_select_title} G">G</A>
	<a href="javascript:UsersBan.set('^H')" title="{$LNG.bo_select_title} H">H</A>
	<a href="javascript:UsersBan.set('^I')" title="{$LNG.bo_select_title} I">I</A>
	<a href="javascript:UsersBan.set('^J')" title="{$LNG.bo_select_title} J">J</A>
	<a href="javascript:UsersBan.set('^K')" title="{$LNG.bo_select_title} K">K</A>
	<a href="javascript:UsersBan.set('^L')" title="{$LNG.bo_select_title} L">L</A>
	<a href="javascript:UsersBan.set('^M')" title="{$LNG.bo_select_title} M">M</A>

	<a href="javascript:UsersBan.set('^N')" title="{$LNG.bo_select_title} N">N</A>
	<a href="javascript:UsersBan.set('^O')" title="{$LNG.bo_select_title} O">O</A>
	<a href="javascript:UsersBan.set('^P')" title="{$LNG.bo_select_title} P">P</A>
	<a href="javascript:UsersBan.set('^Q')" title="{$LNG.bo_select_title} Q">Q</A>
	<a href="javascript:UsersBan.set('^R')" title="{$LNG.bo_select_title} R">R</A>
	<a href="javascript:UsersBan.set('^S')" title="{$LNG.bo_select_title} S">S</A>
	<a href="javascript:UsersBan.set('^T')" title="{$LNG.bo_select_title} T">T</A>
	<a href="javascript:UsersBan.set('^U')" title="{$LNG.bo_select_title} U">U</A>
	<a href="javascript:UsersBan.set('^V')" title="{$LNG.bo_select_title} V">V</A>

	<a href="javascript:UsersBan.set('^W')" title="{$LNG.bo_select_title} W">W</A>
	<a href="javascript:UsersBan.set('^X')" title="{$LNG.bo_select_title} X">X</A>
	<a href="javascript:UsersBan.set('^Y')" title="{$LNG.bo_select_title} Y">Y</A>
	<a href="javascript:UsersBan.set('^Z')" title="{$LNG.bo_select_title} Z">Z</A>

	<br>
	<input NAME="regexp" onKeyUp="UsersBan.set(this.value)">
	<input TYPE="button" onClick="UsersBan.set(this.form.regexp.value)" value="{$LNG.button_filter}">
	<input TYPE="button" onClick="UsersBan.set(this.form.regexp.value)" value="{$LNG.button_deselect}">
</td>
</tr>
<tr>
	<td><input value="{$LNG.bo_unban}" type="submit" style="width:20%;">&nbsp;
	<input TYPE="button" onClick="UsersBan.reset();this.form.regexp.value=''" value="{$LNG.button_reset}"></td>
</tr><tr>
	<td align="left">
		{$LNG.bo_total_banneds}<span style="color:lime">{$bancount}</span>
	</td>
</tr>
</table>
</form>
</td>
</table>

{* ══════════════════════════════════════════════════════════════
   ASTROIO — Auto-selección de jugador en el Panel de Sanciones
   Detecta ?ban_user=X o ?ban_id=Y en la URL y auto-selecciona
   ese jugador en el <select name="unban_name"> y en el <select name="ban_name">
   ══════════════════════════════════════════════════════════════ *}
<script type="text/javascript">
(function() {
	function getParam(name) {
		var m = new RegExp('[?&]' + name + '=([^&#]*)').exec(window.location.search);
		return m ? decodeURIComponent(m[1].replace(/\+/g, ' ')) : null;
	}

	var banUser = getParam('ban_user');
	var banId   = getParam('ban_id');

	if (!banUser && !banId) return;

	// ═══ Busca y selecciona el jugador en un <select> dado ═══
	function selectInSelect(sel, needleUser, needleId) {
		if (!sel) return false;

		// Pasada 1: coincidencia exacta
		for (var i = 0; i < sel.options.length; i++) {
			var opt = sel.options[i];
			var val = (opt.value || '').toString().toLowerCase().trim();
			var txt = (opt.textContent || opt.text || '').toString().toLowerCase().trim();

			if (needleId && (val === needleId || txt === needleId)) {
				sel.selectedIndex = i;
				return opt;
			}
			if (needleUser && (val === needleUser || txt === needleUser)) {
				sel.selectedIndex = i;
				return opt;
			}
		}

		// Pasada 2: coincidencia parcial
		for (var i = 0; i < sel.options.length; i++) {
			var opt = sel.options[i];
			var val = (opt.value || '').toString().toLowerCase();
			var txt = (opt.textContent || opt.text || '').toString().toLowerCase();

			if (needleUser && (val.indexOf(needleUser) !== -1 || txt.indexOf(needleUser) !== -1)) {
				sel.selectedIndex = i;
				return opt;
			}
		}

		return false;
	}

	function highlight(el, nombre) {
		try { el.scrollIntoView({ block: 'center' }); } catch (e) {}
		el.style.outline   = '3px solid #00e0ff';
		el.style.boxShadow = '0 0 25px rgba(0, 224, 255, 0.8)';
	}

	function showAviso(nombre, cual) {
		var aviso = document.createElement('div');
		aviso.innerHTML = '✅ Jugador <b>' + nombre + '</b> pre-seleccionado en <b>' + cual + '</b>.';
		aviso.style.cssText =
			'position:fixed;top:20px;left:50%;transform:translateX(-50%);' +
			'background:linear-gradient(135deg,#006633,#009955);color:#fff;' +
			'padding:14px 28px;border-radius:10px;border:2px solid #66ff99;' +
			'font-weight:700;z-index:999999;box-shadow:0 0 30px rgba(102,255,153,0.8);' +
			'font-size:14px;letter-spacing:0.5px;font-family:Segoe UI, sans-serif;';
		document.body.appendChild(aviso);

		setTimeout(function() {
			aviso.style.transition = 'opacity 0.6s';
			aviso.style.opacity = '0';
		}, 3500);
		setTimeout(function() {
			if (aviso.parentNode) aviso.parentNode.removeChild(aviso);
		}, 4200);
	}

	function trySelect() {
		var needleUser = banUser ? String(banUser).toLowerCase().trim() : '';
		var needleId   = banId   ? String(banId).trim()                : '';

		// ─── Select de BANEAR (izquierda) ───
		var selBan   = document.querySelector('select[name="ban_name"]');
		// ─── Select de DESBANEAR (derecha) ───
		var selUnban = document.querySelector('select[name="unban_name"]');

		var hitBan   = selectInSelect(selBan, needleUser, needleId);
		var hitUnban = selectInSelect(selUnban, needleUser, needleId);

		if (hitBan) {
			highlight(selBan, banUser || banId);
			showAviso(banUser || banId, 'Banear');
		} else if (hitUnban) {
			highlight(selUnban, banUser || banId);
			showAviso(banUser || banId, 'Desbanear');
		}

		return !!(hitBan || hitUnban);
	}

	// Intentar múltiples veces por si el <select> aún no está renderizado
	var intentos = 0;
	var timer = setInterval(function() {
		intentos++;
		if (trySelect() || intentos > 30) {
			clearInterval(timer);
		}
	}, 100);

	// Segundo intento al cargar todo
	window.addEventListener('load', function() {
		setTimeout(trySelect, 300);
	});

	// Limpiar los parámetros de la URL sin recargar (después de seleccionar)
	setTimeout(function() {
		if (window.history && window.history.replaceState) {
			var urlLimpia = window.location.href
				.replace(/[?&]ban_user=[^&#]*/g, '')
				.replace(/[?&]ban_id=[^&#]*/g, '')
				.replace(/[?&]+&/g, '?')
				.replace(/\?&/, '?');
			try { window.history.replaceState({}, document.title, urlLimpia); } catch (e) {}
		}
	}, 500);
})();
</script>

{include file="overall_footer.tpl"}