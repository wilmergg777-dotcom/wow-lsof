var pageLoadTime;
var totalRemainingAtLoad = 0;
var currentUnitStartTime = 0;
var currentUnitDuration = 0;

function ShipyardInit() {
	// ✅ FIX: Si la cola está vacía (ej: en Defensas pero solo hay Naves), no hacemos nada
	if (!data.Queue || data.Queue.length === 0) {
		$('#timeleft').text('00:00:00');
		var select = document.getElementById('auftr');
		if (select) {
			select.options[0] = new Option(Ready);
		}
		return;
	}
	
	Shipyard		= data.Queue;
	Amount			= new DecimalNumber(Shipyard[0][1], 0);
	
	var hanger		= data.b_hangar_id_plus || 0;
	
	// ✅ Calcular tiempo TOTAL de todas las colas filtradas (en segundos)
	totalRemainingAtLoad = 0;
	for (var i = 0; i < Shipyard.length; i++) {
		totalRemainingAtLoad += Shipyard[i][2] * Shipyard[i][1];
	}
	totalRemainingAtLoad -= hanger;
	if (totalRemainingAtLoad < 0) totalRemainingAtLoad = 0;
	
	pageLoadTime			= new Date();
	currentUnitStartTime	= pageLoadTime.getTime() - hanger * 1000;
	currentUnitDuration		= Shipyard[0][2];
	
	$('#timeleft').text(GetRestTimeFormat(totalRemainingAtLoad));
	
	ShipyardList();
	BuildlistShipyard();
	ShipyardInterval	= window.setInterval(BuildlistShipyard, 1000);
}

function BuildlistShipyard() {
	if (Shipyard.length === 0) return;
	
	var now					= new Date();
	var elapsedSinceLoad	= (now.getTime() - pageLoadTime.getTime()) / 1000;
	
	// ✅ Tiempo TOTAL restante (segundos) — se actualiza cada segundo
	var totalRemaining		= totalRemainingAtLoad - elapsedSinceLoad;
	if (totalRemaining < 0) totalRemaining = 0;
	$('#timeleft').text(GetRestTimeFormat(totalRemaining));
	
	// Tiempo en la unidad actual
	var elapsedOnCurrent	= (now.getTime() - currentUnitStartTime) / 1000;
	var s					= currentUnitDuration - elapsedOnCurrent;
	
	var shiftNeeded = false;
	
	// Si la unidad actual ya terminó, avanzamos a la siguiente
	while (s <= 0 && Shipyard.length > 0) {
		var overshoot	= -s;
		Amount.sub('1');
		
		$('#val_'+Shipyard[0][3]).text(function(i, old){
			return ' ('+bd_available+NumberGetHumanReadable(parseInt(old.replace(/.* (.*)\)/, '$1').replace(/\./g, ''))+1)+')';
		});
		
		if (Amount.toString() == '0') {
			Shipyard.shift();
			if (Shipyard.length == 0) {
				$("#bx").html(Ready);
				document.getElementById('auftr').options[0] = new Option(Ready);
				document.location.href	= document.location.href;
				window.clearInterval(ShipyardInterval);
				return;
			}
			Amount = Amount.reset(Shipyard[0][1]);
			shiftNeeded = true;
		}
		
		currentUnitDuration		= Shipyard[0][2];
		currentUnitStartTime	= now.getTime() - overshoot * 1000;
		elapsedOnCurrent		= overshoot;
		s						= currentUnitDuration - elapsedOnCurrent;
	}
	
	if (shiftNeeded) {
		ShipyardList();
	} else {
		// Actualizar el texto del primer ítem (la unidad actual)
		var select = document.getElementById('auftr');
		if (select && select.options.length > 0) {
			var remainingInCurrent	= Math.max(0, currentUnitDuration - elapsedOnCurrent);
			var remainingUnits		= parseInt(Amount.toString()) - 1;
			if (remainingUnits < 0) remainingUnits = 0;
			var entryDuration		= remainingInCurrent + remainingUnits * currentUnitDuration;
			if (entryDuration < 0) entryDuration = 0;
			
			select.options[0].text = Amount.toString() + " " + Shipyard[0][0] + " " + bd_operating + " (" + GetRestTimeFormat(entryDuration) + ")";
		}
	}
}

function ShipyardList() {
	var select = document.getElementById('auftr');
	if (!select) return;
	
	while (select.length > 0) {
		select.options[select.length - 1] = null;
	}
	
	var now = new Date();
	
	for (var iv = 0; iv < Shipyard.length; iv++) {
		var name		= Shipyard[iv][0];
		var count		= Shipyard[iv][1];
		var timePerUnit	= Shipyard[iv][2];
		var duration;
		var displayCount;
		
		if (iv == 0) {
			// Primera entrada: tiempo restante real (unidad actual + unidades restantes)
			var elapsedOnCurrent	= (now.getTime() - currentUnitStartTime) / 1000;
			var remainingInCurrent	= Math.max(0, currentUnitDuration - elapsedOnCurrent);
			var remainingUnits		= parseInt(Amount.toString()) - 1;
			if (remainingUnits < 0) remainingUnits = 0;
			duration				= remainingInCurrent + remainingUnits * currentUnitDuration;
			displayCount			= Amount.toString();
		} else {
			// Otras entradas: tiempo completo de esa entrada (tiempo × cantidad)
			duration				= timePerUnit * count;
			displayCount			= count;
		}
		
		if (duration < 0) duration = 0;
		var timeStr = GetRestTimeFormat(duration);
		
		select.options[iv] = new Option(displayCount + " " + name + " " + bd_operating + " (" + timeStr + ")", iv);
	}
}