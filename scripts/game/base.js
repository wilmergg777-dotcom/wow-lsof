function number_format (number, decimals) {
    number = (number + '').replace(/[^0-9+\-Ee.]/g, '');
    var n = !isFinite(+number) ? 0 : +number,
        prec = !isFinite(+decimals) ? 0 : Math.abs(decimals),
        sep = '.',
        dec = ',',
        s = '',
        toFixedFix = function (n, prec) {
            var k = Math.pow(10, prec);
            return '' + Math.round(n * k) / k;
        };
    s = (prec ? toFixedFix(n, prec) : '' + Math.round(n)).split('.');
    if (s[0].length > 3) {        s[0] = s[0].replace(/\B(?=(?:\d{3})+(?!\d))/g, sep);
    }
    if ((s[1] || '').length < prec) {
        s[1] = s[1] || '';
        s[1] += new Array(prec - s[1].length + 1).join('0');    }
    return s.join(dec);
}

function NumberGetHumanReadable(value, dec) {
	if(typeof dec === "undefined") {
		dec = 0;
	}
	if(dec == 0)
	{
		value	= removeE(Math.floor(value));
	}
	return number_format(value, dec);
}

function shortly_number(number)
{
    var unit	= ["", "K", "M", "B", "T", "Q", "Q+", "S", "S+", "O", "N"];
	var negate	= number < 0 ? -1 : 1;
	var key		= 0;
	number		= Math.abs(number);
	
	if(number >= 1000000) {
		++key;
		while(number >= 1000000)
		{
			++key;
			number = number / 1000000;
		}
	} else if(number >= 1000) {
		++key;
		number = number / 1000;
	}
	
	decial	= key != 0 && number != 0 && number < 100;
	return NumberGetHumanReadable(negate * number, decial)+(key !== 0 ? '&nbsp;'+unit[key] : '');
}

function removeE(Number) {
	Number = String(Number);
	if (Number.search(/e\+/) == -1) 
		return Number;
	var e = parseInt(Number.replace(/\S+.?e\+/g, ''));
	if (isNaN(e) || e == 0) 
		return Number;
	else if ($.browser.webkit || $.browser.msie) 
		return parseFloat(Number).toPrecision(Math.min(e + 1, 21));
	else 
		return parseFloat(Number).toPrecision(e + 1);
}

function getFormatedDate(timestamp, format) {
	var currTime = new Date();
	currTime.setTime(timestamp + (ServerTimezoneOffset * 1000));
	str = format;
	str = str.replace('[d]', dezInt(currTime.getDate(), 2));
	str = str.replace('[D]', days[currTime.getDay()]);
	str = str.replace('[m]', dezInt(currTime.getMonth() + 1, 2));
	str = str.replace('[M]', months[currTime.getMonth()]);
	str = str.replace('[j]', parseInt(currTime.getDate()));
	str = str.replace('[Y]', currTime.getFullYear());
	str = str.replace('[y]', currTime.getFullYear().toString().substr(2, 4));
	str = str.replace('[G]', currTime.getHours());
	str = str.replace('[H]', dezInt(currTime.getHours(), 2));
	str = str.replace('[i]', dezInt(currTime.getMinutes(), 2));
	str = str.replace('[s]', dezInt(currTime.getSeconds(), 2));
	return str;
}
function dezInt(num, size, prefix) {
	prefix = (prefix) ? prefix : "0";
	var minus = (num < 0) ? "-" : "", 
	result = (prefix == "0") ? minus : "";
	num = Math.abs(parseInt(num, 10));
	size -= ("" + num).length;
	for (var i = 1; i <= size; i++) {
		result += "" + prefix;
	}
	result += ((prefix != "0") ? minus : "") + num;
	return result;
}

function getFormatedTime(time) {
	hours = Math.floor(time / 3600);
	timeleft = time % 3600;
	minutes = Math.floor(timeleft / 60);
	timeleft = timeleft % 60;
	seconds = timeleft;
	return dezInt(hours, 2) + ":" + dezInt(minutes, 2) + ":" + dezInt(seconds, 2);
}

function GetRestTimeFormat(Secs) {
	var s = Secs;
	var m = 0;
	var h = 0;
	if (s > 59) {
		m = Math.floor(s / 60);
		s = s - m * 60;
	}
	if (m > 59) {
		h = Math.floor(m / 60);
		m = m - h * 60;
	}
	return dezInt(h, 2) + ':' + dezInt(m, 2) + ":" + dezInt(s, 2);
}

function OpenPopup(target_url, win_name, width, height) {
	var new_win = window.open(target_url+'&ajax=1', win_name, 'scrollbars=yes,statusbar=no,toolbar=no,location=no,directories=no,resizable=no,menubar=no,width='+width+',height='+height+',screenX='+((screen.width-width) / 2)+",screenY="+((screen.height-height) / 2)+",top="+((screen.height-height) / 2)+",left="+((screen.width-width) / 2));
	new_win.focus();
}

function DestroyMissiles() {
	$.getJSON('?page=information&mode=destroyMissiles&'+$('.missile').serialize(), function(data) {
		$('#missile_502').text(NumberGetHumanReadable(data[0]));
		$('#missile_503').text(NumberGetHumanReadable(data[1]));
		$('.missile').val('');
	});
}

function handleErr(errMessage, url, line) 
{ 
	error = "There is an error at this page.\n";
	error += "Error: " + errMessage+ "\n";
	error += "URL: " + url + "\n";
	error += "Line: " + line + "\n\n";
	error += "Click OK to continue viewing this page,\n";
	alert(error);
	if(typeof console == "object")
		console.log(error);
 
	return true; 
}

var Dialog	= {	
	info: function(ID){
		return Dialog.open('game.php?page=information&id='+ID, 590, (ID > 600 && ID < 800) ? 210 : ((ID > 100 && ID < 200) ? 300 : 620));
	},
	
	alert: function(msg, callback){
		alert(msg);
		if(typeof callback === "function") {
			callback();
		}
	},
	
	PM: function(ID, Subject, Message) {
		if(typeof Subject !== 'string')
			Subject	= '';

		return Dialog.open('game.php?page=messages&mode=write&id='+ID+'&subject='+encodeURIComponent(Subject)+'&message='+encodeURIComponent(Subject), 650, 350);
	},
	
	Playercard: function(ID) {
		return isPlayerCardActive && Dialog.open('game.php?page=playerCard&id='+ID, 650, 600);
	},
	
	Buddy: function(ID) {
		return Dialog.open('game.php?page=buddyList&mode=request&id='+ID, 650, 300);
	},
	
	PlanetAction: function() {
		return Dialog.open('game.php?page=overview&mode=actions', 400, 180);
	},
	
	AllianceChat: function() {
	    return OpenPopup('game.php?page=chat&action=alliance', "alliance_chat", 960, 900);
	},
	
	open: function(url, width, height) {
		$.fancybox({
			width: width,
			padding: 0,
			height: height,
			type: 'iframe',
			href: url
		});
		
		return false;
	}
}

function NotifyBox(text) {
	tip = $('#tooltip')
	tip.html(text).addClass('notify').css({
		left : (($(window).width() - $('#leftmenu').width()) / 2 - tip.outerWidth() / 2) + $('#leftmenu').width(),
	}).show();
	window.setTimeout(function(){tip.fadeOut(1000, function() {tip.removeClass('notify')})}, 500);
}


function UhrzeitAnzeigen() {
   $(".servertime").text(getFormatedDate(serverTime.getTime(), tdformat));
}


$.widget("custom.catcomplete", $.ui.autocomplete, {
	_renderMenu: function( ul, items ) {
		var self = this,
			currentCategory = "";
		$.each( items, function( index, item ) {
			if ( item.category != currentCategory ) {
				ul.append( "<li class='ui-autocomplete-category'>" + item.category + "</li>" );
				currentCategory = item.category;
			}
			self._renderItem( ul, item );
		});
	}
});

$(function() {
	$('#drop-admin').on('click', function() {
		$.get('admin.php?page=logout', function() {
			$('.globalWarning').animate({
				'height' :0,
				'padding' :0,
				'opacity' :0
			}, function() {
				$(this).hide();
			});
		});
	});
	
	// ============================================================
	// ASTROIO v1.8 FIX — Countdown de flotas (SELECTOR CORRECTO)
	// ------------------------------------------------------------
	// BUG ANTERIOR (v1.7): el JS buscaba la clase `.countdown` y el
	// atributo `data-time`, pero el HTML real NO los usa. Por eso el
	// contador nunca bajaba y había que refrescar la página.
	//
	// El HTML real de las flotas activas usa:
	//   <span class="fleet-time"
	//         data-fleet-time="17918282692"
	//         data-fleet-end-time="1791828269"
	//         data-fleet-time="75">00:12:37</span>
	//
	// FIX v1.8: leer la clase `.fleet-time` y el atributo
	// `data-fleet-end-time` (timestamp Unix en segundos de cuándo
	// llega la flota).
	//
	// Cálculo del tiempo restante:
	//   1) Al cargar, se calcula `astroServerOffset` = diferencia
	//      entre la hora del server y la del navegador. Se calcula
	//      UNA SOLA VEZ para compensar desfases de reloj.
	//   2) Cada segundo:
	//        nowServer  = Date.now() + astroServerOffset   → hora server en vivo
	//        endTimeMs  = data-fleet-end-time × 1000       → timestamp fin (ms)
	//        s          = (endTimeMs - nowServer) / 1000   → segundos restantes
	//   3) Se pinta en el <span> con formato HH:MM:SS.
	//
	// Si `s <= 0` → se muestra "-" (la flota ya llegó).
	// ============================================================
	var astroServerOffset = 0;
	if (typeof serverTime !== 'undefined' && serverTime && typeof serverTime.getTime === 'function') {
		astroServerOffset = serverTime.getTime() - Date.now();
	}
	window.setInterval(function() {
		var nowServer = Date.now() + astroServerOffset;
		$('.fleet-time').each(function() {
			var endTimeSec = parseInt($(this).attr('data-fleet-end-time'), 10);
			if (isNaN(endTimeSec) || endTimeSec <= 0) {
				return;
			}
			var endTimeMs = endTimeSec * 1000;
			var s = (endTimeMs - nowServer) / 1000;
			if (s <= 0) {
				$(this).text('-');
			} else {
				$(this).text(GetRestTimeFormat(s));
			}
		});
	}, 1000);
	// ============================================================
	// FIN ASTROIO v1.8 FIX
	// ============================================================
	
	$('#planetSelector').on('change', function() {
		document.location = '?'+queryString+'&cp='+$(this).val();
	});

	UhrzeitAnzeigen();
	setInterval(UhrzeitAnzeigen, 1000);
	
	$("button#create_new_alliance_rank").click(function() {
		$("div#new_alliance_rank").dialog(		{
			draggable: false,
			resizable: false,
			modal: true,
			width: 760
		});

		return false;
	});
});


/* ============================================================
   ASTROIO — ALARMA DE ATAQUES ENTRANTES
   v2.1 — Alarma 24s persistente entre páginas + cooldown 30min
   ------------------------------------------------------------
   FIX v2.1 (persistencia entre páginas):
     - Se guarda en localStorage `astroio_alarm_start` con el
       timestamp del momento EXACTO en que empezó a sonar.
     - Al cargar cualquier página:
         * Si hay un `start` reciente (< 24s) → REANUDA la alarma
           solo por el tiempo RESTANTE (no desde 0).
         * Si `start` es viejo (> 24s) → limpia y aplica cooldown.
     - Al cambiar de página dentro del juego, el audio NO se corta
       ni se reinicia: continúa hasta completar los 24s totales.
     - Tras los 24s → 30 min de silencio (cooldown normal).
   ============================================================ */
(function() {
    'use strict';

    // ═══════════ CONFIGURACIÓN ═══════════
    var CHECK_INTERVAL   = 30000;               // Consultar servidor cada 30s
    var ALARM_SOUND_URL  = './styles/theme/gow/sounds/alarma.mp3';
    var ALARM_DURATION   = 24000;               // 🔔 Suena 24 segundos exactos
    var ALARM_COOLDOWN   = 30 * 60 * 1000;      // ⏸️ 30 minutos de silencio
    var LASTPLAY_KEY     = 'astroio_alarm_last';// Cooldown (último play)
    var ALARM_START_KEY  = 'astroio_alarm_start';// 🆕 Timestamp de inicio de la alarma actual

    // ═══════════ PERSISTENCIA EN LOCALSTORAGE ═══════════
    function readLastPlay() {
        var v = null;
        try { v = localStorage.getItem(LASTPLAY_KEY); } catch (e) {}
        return v ? parseInt(v, 10) : 0;
    }
    function writeLastPlay(t) {
        try { localStorage.setItem(LASTPLAY_KEY, String(t)); } catch (e) {}
    }
    function readAlarmStart() {
        var v = null;
        try { v = localStorage.getItem(ALARM_START_KEY); } catch (e) {}
        return v ? parseInt(v, 10) : 0;
    }
    function writeAlarmStart(t) {
        try { localStorage.setItem(ALARM_START_KEY, String(t)); } catch (e) {}
    }
    function clearAlarmStart() {
        try { localStorage.removeItem(ALARM_START_KEY); } catch (e) {}
    }

    // ═══════════ ESTADO ═══════════
    var audioAttack      = null;
    var alarmTimer       = null;
    var alarmIsSounding  = false;

    // ═══════════ CREAR ELEMENTO DE AUDIO ═══════════
    function createAudio() {
        audioAttack = document.createElement('audio');
        audioAttack.id            = 'astroio_alarm_attack';
        audioAttack.src           = ALARM_SOUND_URL;
        audioAttack.loop          = true;   // Repite mientras duren los 24s
        audioAttack.preload       = 'auto';
        audioAttack.volume        = 0.8;
        audioAttack.style.display = 'none';
        document.body.appendChild(audioAttack);
    }

    // ═══════════ PARAR ALARMA ═══════════
    function stopAlarm() {
        if (!audioAttack) return;
        try {
            audioAttack.pause();
            audioAttack.currentTime = 0;
        } catch (e) {}
    }

    // ═══════════ REPRODUCIR ALARMA POR X ms ═══════════
    // Reproduce el audio durante `durationMs` milisegundos exactos
    // y luego lo detiene. NO escribe en localStorage (eso lo hace
    // el llamador para controlar el estado desde fuera).
    function playAlarmForMs(durationMs) {
        if (alarmIsSounding) return;
        if (!audioAttack) return;
        if (durationMs <= 0) return;

        alarmIsSounding = true;

        try {
            audioAttack.currentTime = 0;
            var p = audioAttack.play();
            if (p && typeof p.catch === 'function') {
                p.catch(function() {
                    console.log('[AstroIO] Autoplay bloqueado. Haz clic en la página.');
                });
            }
        } catch (e) {}

        if (alarmTimer) clearTimeout(alarmTimer);
        alarmTimer = setTimeout(function() {
            stopAlarm();
            alarmIsSounding = false;
            console.log('[AstroIO] 🔇 Alarma detenida.');
        }, durationMs);
    }

    // ═══════════ ALARMA NUEVA (24s desde 0) ═══════════
    function playAlarmFor24s() {
        var now = Date.now();
        // Guardar timestamp de inicio de la alarma en curso
        writeAlarmStart(now);
        // Guardar también en el registro de cooldown
        writeLastPlay(now);
        // Reproducir 24s
        playAlarmForMs(ALARM_DURATION);
    }

    // ═══════════ REANUDAR ALARMA EN CURSO ═══════════
    // Si existe una alarma iniciada hace menos de 24s, la reanuda
    // por el tiempo RESTANTE. Si ya pasó, limpia el start.
    function resumeAlarmIfNeeded() {
        var startTime = readAlarmStart();
        if (!startTime || startTime <= 0) return false;

        var now      = Date.now();
        var elapsed  = now - startTime;

        if (elapsed >= ALARM_DURATION) {
            // Ya expiró → limpiar
            clearAlarmStart();
            return false;
        }

        var remaining = ALARM_DURATION - elapsed;
        console.log('[AstroIO] 🔊 Alarma reanudada (' + Math.round(remaining / 1000) + 's restantes).');
        playAlarmForMs(remaining);
        return true;
    }

    // ═══════════ CONSULTAR SERVIDOR ═══════════
    function checkAttacks() {
        var xhr = new XMLHttpRequest();
        xhr.open('GET', './check_attacks.php?t=' + Date.now(), true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4) return;
            if (xhr.status !== 200) return;

            try {
                var data = JSON.parse(xhr.responseText);

                // ¿Hay ataque O espionaje activo?
                var underThreat = (data.hasAttack && data.total > 0) ||
                                  (data.hasSpy    && data.spyTotal > 0);

                if (!underThreat) {
                    // Sin amenaza → parar cualquier cosa y limpiar start
                    if (alarmIsSounding) {
                        if (alarmTimer) clearTimeout(alarmTimer);
                        stopAlarm();
                        alarmIsSounding = false;
                    }
                    clearAlarmStart();
                    return;
                }

                // ─── ¿Alarma en curso ahora mismo? ───
                // Si ya está sonando (en esta pestaña) → no hacer nada
                if (alarmIsSounding) return;

                // ─── ¿Hay una alarma iniciada en otra pestaña/página? ───
                if (resumeAlarmIfNeeded()) return;

                // ─── ¿Pasó el cooldown de 30 min? ───
                var now      = Date.now();
                var lastPlay = readLastPlay();
                var elapsed  = now - lastPlay;

                if (elapsed < ALARM_COOLDOWN) {
                    var minRest = Math.ceil((ALARM_COOLDOWN - elapsed) / 60000);
                    console.log('[AstroIO] Amenaza detectada, en cooldown. Faltan ' + minRest + ' min.');
                    return;
                }

                // 🔔 Toca sonar nueva alarma 24s
                console.log('[AstroIO] 🔔 ALARMA: ' + (data.total||0) + ' ataque(s), ' + (data.spyTotal||0) + ' espionaje(s). Sonando 24s.');
                playAlarmFor24s();

            } catch (e) {
                console.log('[AstroIO] Error JSON:', e.message);
            }
        };
        xhr.send();
    }

    // ═══════════ INICIALIZACIÓN ═══════════
    function init() {
        if (!document.body) {
            setTimeout(init, 100);
            return;
        }

        createAudio();

        // ─── 🆕 Reanudar alarma en curso INMEDIATAMENTE ───
        // Si venimos de otra página y todavía quedaban segundos,
        // arranca ya sin esperar al primer checkAttacks.
        resumeAlarmIfNeeded();

        // Arrancar comprobación periódica
        checkAttacks();
        setInterval(checkAttacks, CHECK_INTERVAL);

        // Desbloqueador de audio (los navegadores bloquean autoplay)
        var unlockAudio = function() {
            if (audioAttack) {
                // Solo probar si NO está sonando, para no cortarla
                if (!alarmIsSounding) {
                    audioAttack.play().then(function() {
                        audioAttack.pause();
                        audioAttack.currentTime = 0;
                    }).catch(function(e) {});
                }
            }
            document.removeEventListener('click', unlockAudio);
            document.removeEventListener('touchstart', unlockAudio);
            console.log('[AstroIO] Audio desbloqueado por interacción del usuario.');
        };
        document.addEventListener('click', unlockAudio);
        document.addEventListener('touchstart', unlockAudio);

        console.log('[AstroIO] Alarma activa v2.1 — 24s persistente + 30min cooldown');
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

})();
/* ============================================================
   FIN ASTROIO — ALARMA v2.1
   ============================================================ */