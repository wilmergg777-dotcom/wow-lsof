/* ============================================================
   ASTROIO FIX — Clase DecimalNumber (faltante)
   Esta clase es requerida por shipyard.js para funcionar.
   ============================================================ */
function DecimalNumber(value, precision) {
    this.value = parseFloat(value) || 0;
    this.precision = precision || 0;
}
DecimalNumber.prototype.sub = function(amount) {
    this.value -= parseFloat(amount) || 0;
    return this;
};
DecimalNumber.prototype.add = function(amount) {
    this.value += parseFloat(amount) || 0;
    return this;
};
DecimalNumber.prototype.toString = function() {
    return this.value.toFixed(this.precision);
};
DecimalNumber.prototype.reset = function(value) {
    this.value = parseFloat(value) || 0;
    return this;
};
/* ============================================================
   FIN DEL FIX
   ============================================================ */

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
	
	
	window.setInterval(function() {
		$('.countdown').each(function() {
			var s		= $(this).data('time') - (serverTime.getTime() - startTime) / 1000;
			if(s <= 0) {
				$(this).text('-');
			} else {
				$(this).text(GetRestTimeFormat(s));
			}
		});
	}, 1000);
	
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
   v3.0 — Alarma 24s + cooldown 30min
   Sin campana, sin mute, sin chat flotante
   ============================================================ */
(function() {
    'use strict';

    // ═══════════ CONFIGURACIÓN ═══════════
    var CHECK_INTERVAL   = 30000;               // Consultar servidor cada 30s
    var ALARM_SOUND_URL  = './styles/theme/gow/sounds/alarma.mp3';
    var ALARM_DURATION   = 24000;               // 🔔 Suena 24 segundos exactos
    var ALARM_COOLDOWN   = 30 * 60 * 1000;      // ⏸️ 30 minutos de silencio
    var LASTPLAY_KEY     = 'astroio_alarm_last';// Clave localStorage

    // ═══════════ COOLDOWN EN LOCALSTORAGE ═══════════
    function readLastPlay() {
        var v = null;
        try { v = localStorage.getItem(LASTPLAY_KEY); } catch (e) {}
        return v ? parseInt(v, 10) : 0;
    }
    function writeLastPlay(t) {
        try { localStorage.setItem(LASTPLAY_KEY, String(t)); } catch (e) {}
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
        audioAttack.loop          = true;
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

    // ═══════════ REPRODUCIR ALARMA 24 SEGUNDOS ═══════════
    function playAlarmFor24s() {
        if (alarmIsSounding) return;
        if (!audioAttack) return;

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
            console.log('[AstroIO] 🔇 Alarma detenida. Cooldown 30 min activo.');
        }, ALARM_DURATION);
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
                    if (alarmIsSounding) {
                        if (alarmTimer) clearTimeout(alarmTimer);
                        stopAlarm();
                        alarmIsSounding = false;
                    }
                    return;
                }

                // ¿Pasó el cooldown de 30 min?
                var now      = Date.now();
                var lastPlay = readLastPlay();
                var elapsed  = now - lastPlay;

                if (elapsed < ALARM_COOLDOWN) {
                    var minRest = Math.ceil((ALARM_COOLDOWN - elapsed) / 60000);
                    console.log('[AstroIO] Amenaza detectada, en cooldown. Faltan ' + minRest + ' min.');
                    return;
                }

                // 🔔 Toca sonar
                console.log('[AstroIO] 🔔 ALARMA: ' + (data.total||0) + ' ataque(s), ' + (data.spyTotal||0) + ' espionaje(s). Sonando 24s.');
                playAlarmFor24s();
                writeLastPlay(now);

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
        checkAttacks();
        setInterval(checkAttacks, CHECK_INTERVAL);

        // Desbloqueador de audio (los navegadores bloquean autoplay)
        var unlockAudio = function() {
            if (audioAttack) {
                audioAttack.play().then(function() {
                    audioAttack.pause();
                    audioAttack.currentTime = 0;
                }).catch(function(e) {});
            }
            document.removeEventListener('click', unlockAudio);
            document.removeEventListener('touchstart', unlockAudio);
            console.log('[AstroIO] Audio desbloqueado por interacción del usuario.');
        };
        document.addEventListener('click', unlockAudio);
        document.addEventListener('touchstart', unlockAudio);

        console.log('[AstroIO] Alarma activa v3.0 — 24s sonido + 30min cooldown');
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

})();
/* ============================================================
   FIN ASTROIO — ALARMA v3.0
   Sin campana, sin mute, sin chat flotante
   ============================================================ */