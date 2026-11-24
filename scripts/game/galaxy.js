/**
 * AstroIO v3.2 — Galaxy JS
 * - doit(missionID, planetID): envío AJAX clásico (espionaje, reciclaje de escombros)
 * - doitAst(galaxy, system, planet): NUEVO — reciclaje AUTOMÁTICO de asteroide (misión 32)
 * - astrogxToast(msg, ok): aviso flotante para que el jugador vea el resultado
 *   sin buscar el mensaje al final de la tabla.
 */

function astrogxToast(msg, ok) {
	var $old = $('#astrogx_toast');
	if ($old.length) { $old.remove(); }

	var $toast = $('<div />').attr('id', 'astrogx_toast').text(msg);
	if (ok) { $toast.addClass('ok'); } else { $toast.addClass('fail'); }
	$('body').append($toast);

	setTimeout(function() {
		$toast.fadeOut(400, function() { $(this).remove(); });
	}, 4200);
}

function astrogxFleetAjax(url) {
	$.getJSON(url, function(data)
	{
		$('#slots').text(data.slots);
		if (typeof data.ships !== "undefined")
		{
			$.each(data.ships, function(elementID, value) {
				$('#elementID' + elementID).text(number_format(value));
			});
		}

		var ok = (data.code == 600);

		var statustable	= $('#fleetstatusrow');
		var messages	= statustable.find("~tr");
		if (messages.length == MaxFleetSetting) {
			messages.filter(':last').remove();
		}
		var element		= $('<td />').attr('colspan', 8).attr('class', ok ? "success" : "error").text(data.mess).wrap('<tr />').parent();
		statustable.removeAttr('style').after(element);

		astrogxToast(data.mess, ok);
	}).fail(function() {
		astrogxToast('Error de conexión', false);
	});
}

function doit(missionID, planetID) {
	astrogxFleetAjax("game.php?page=fleetAjax&ajax=1&mission=" + missionID + "&planetID=" + planetID);
}

/**
 * ASTROIO v3.2 — Reciclaje AUTOMÁTICO de asteroide.
 * El asteroide no tiene registro de planeta, por eso se pasan coordenadas.
 */
function doitAst(galaxy, system, planet) {
	astrogxFleetAjax("game.php?page=fleetAjax&ajax=1&mission=32&galaxy=" + galaxy + "&system=" + system + "&planet=" + planet);
}

function galaxy_submit(value) {
	$('#auto').attr('name', value);
	$('#galaxy_form').submit();
}
