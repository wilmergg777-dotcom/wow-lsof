<!-- ═══════════════════════════════════════════════
     ASTROIO — Chat Flotante v3 (debajo de la campanita)
     v2.4.3:
       - Pestañas General / Alianza (abre por defecto en GENERAL)
       - Badge con el nº de mensajes NO LEÍDOS de ambos chats
         (se guarda en localStorage → sobrevive a recargas)
       - Al abrir la burbuja el badge se quita (todo marcado leído)
       - Canal Alianza solo visible si el jugador tiene alianza
       - Backend: chat_bridge.php v1.4 (acción unread nueva)
     ═══════════════════════════════════════════════ -->

<style>
/* ====== BOTÓN FLOTANTE ====== */
#astrofloat_chat_btn {
    position: fixed;
    bottom: 80px;       /* ← Ajustar según altura de la campanita */
    right: 20px;        /* ← Ajustar según posición de la campanita */
    width: 50px;
    height: 50px;
    background: linear-gradient(135deg, #008844, #00cc66);
    border: 2px solid #00ff88;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 24px;
    color: #fff;
    cursor: pointer;
    box-shadow: 0 4px 14px rgba(0, 255, 136, 0.5);
    z-index: 99998;
    transition: all 0.25s ease;
    user-select: none;
}

#astrofloat_chat_btn:hover {
    transform: scale(1.08) translateY(-2px);
    box-shadow: 0 6px 20px rgba(0, 255, 136, 0.8);
}

#astrofloat_chat_btn:active {
    transform: scale(0.96);
}

/* Icono real de la burbuja (icons8 telegrama del tema gow) */
#astrofloat_chat_btn img.astrofloat_icon {
    width: 30px;
    height: 30px;
    display: block;
    pointer-events: none;
    filter: drop-shadow(0 1px 2px rgba(0, 0, 0, 0.4));
}

/* Badge rojo de mensajes nuevos (General + Alianza) */
#astrofloat_chat_badge {
    position: absolute;
    top: -4px;
    right: -4px;
    min-width: 20px;
    height: 20px;
    padding: 0 5px;
    background: #ff2266;
    color: #fff;
    font-size: 10px;
    font-weight: 700;
    border-radius: 10px;
    display: none;
    align-items: center;
    justify-content: center;
    box-shadow: 0 0 8px rgba(255, 34, 102, 0.8);
    animation: astrofloat_pulse 1.5s infinite;
}

@keyframes astrofloat_pulse {
    0%, 100% { transform: scale(1); }
    50%      { transform: scale(1.15); }
}

/* ====== VENTANA FLOTANTE ====== */
#astrofloat_chat_window {
    position: fixed;
    bottom: 145px;      /* ← Ajustar según el botón */
    right: 20px;
    width: 340px;
    height: 440px;
    background: linear-gradient(180deg, #0a0f1a 0%, #131a2a 100%);
    border: 1px solid rgba(0, 255, 136, 0.4);
    border-radius: 12px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.6), 0 0 30px rgba(0, 255, 136, 0.15);
    display: none;
    flex-direction: column;
    z-index: 99999;
    overflow: hidden;
    font-family: 'Segoe UI', Roboto, sans-serif;
}

#astrofloat_chat_window.open {
    display: flex;
    animation: astrofloat_open 0.25s ease;
}

@keyframes astrofloat_open {
    from { opacity: 0; transform: translateY(15px) scale(0.96); }
    to   { opacity: 1; transform: translateY(0) scale(1); }
}

/* ====== Cabecera ====== */
.astrofloat_header {
    display: flex;
    align-items: center;
    padding: 10px 14px;
    background: linear-gradient(135deg, #008844, #00cc66);
    border-bottom: 2px solid #00ff88;
    gap: 10px;
}

.astrofloat_header .title {
    color: #fff;
    font-size: 13px;
    font-weight: 700;
    letter-spacing: 0.5px;
}

.astrofloat_header .status {
    margin-left: auto;
    font-size: 10px;
    color: #ccffe0;
    display: flex;
    align-items: center;
    gap: 5px;
}

.astrofloat_header .status::before {
    content: '';
    width: 7px;
    height: 7px;
    border-radius: 50%;
    background: #fff;
    box-shadow: 0 0 6px #fff;
    animation: astrofloat_online 1.5s infinite;
}

@keyframes astrofloat_online {
    0%, 100% { opacity: 1; }
    50%      { opacity: 0.3; }
}

.astrofloat_header .close {
    color: #fff;
    font-size: 20px;
    font-weight: 700;
    cursor: pointer;
    padding: 0 4px;
    transition: all 0.2s ease;
    line-height: 1;
}

.astrofloat_header .close:hover {
    color: #ffbbbb;
    transform: scale(1.2);
}

/* ====== PESTAÑAS General / Alianza (v3) ====== */
.astrofloat_tabs {
    display: flex;
    gap: 6px;
    padding: 8px 10px;
    background: rgba(0, 0, 0, 0.2);
    border-bottom: 1px solid rgba(0, 255, 136, 0.2);
}

.astrofloat_tab {
    flex: 1;
    padding: 7px 4px;
    background: rgba(0, 0, 0, 0.35);
    border: 1px solid rgba(0, 255, 136, 0.25);
    border-radius: 7px;
    color: #9fd8b8;
    font-size: 11px;
    font-weight: 700;
    cursor: pointer;
    transition: all 0.2s ease;
    font-family: 'Segoe UI', Roboto, sans-serif;
    letter-spacing: 0.3px;
}

.astrofloat_tab:hover {
    color: #fff;
    border-color: rgba(0, 255, 136, 0.5);
}

.astrofloat_tab.active {
    background: linear-gradient(135deg, #008844, #00cc66);
    color: #fff;
    border-color: #00ff88;
    box-shadow: 0 0 10px rgba(0, 255, 136, 0.4);
}

.astrofloat_tab.hidden { display: none; }

/* ====== Mensajes ====== */
.astrofloat_messages {
    flex: 1;
    overflow-y: auto;
    padding: 10px;
    display: flex;
    flex-direction: column;
    gap: 8px;
    scrollbar-width: thin;
    scrollbar-color: #00cc66 #0a0f1a;
}

.astrofloat_messages::-webkit-scrollbar { width: 6px; }
.astrofloat_messages::-webkit-scrollbar-track { background: #0a0f1a; }
.astrofloat_messages::-webkit-scrollbar-thumb {
    background: #00cc66;
    border-radius: 3px;
}

.astrofloat_msg {
    max-width: 82%;
    padding: 7px 11px;
    border-radius: 10px;
    font-size: 12px;
    line-height: 1.4;
    word-wrap: break-word;
    animation: astrofloat_msgin 0.25s ease;
}

@keyframes astrofloat_msgin {
    from { opacity: 0; transform: translateY(5px); }
    to   { opacity: 1; transform: translateY(0); }
}

.astrofloat_msg .name {
    display: block;
    font-size: 10px;
    font-weight: 700;
    margin-bottom: 2px;
    opacity: 0.85;
}

.astrofloat_msg.other {
    align-self: flex-start;
    background: linear-gradient(135deg, #1a3a2a, #22553a);
    border: 1px solid rgba(0, 255, 136, 0.3);
    border-bottom-left-radius: 3px;
    color: #e0ffe8;
}

.astrofloat_msg.other .name { color: #66ff99; }

.astrofloat_msg.me {
    align-self: flex-end;
    background: linear-gradient(135deg, #0066cc, #0099ff);
    border-bottom-right-radius: 3px;
    color: #fff;
}

.astrofloat_msg.me .name { color: #cceeff; }

.astrofloat_msg .time {
    display: block;
    font-size: 8px;
    opacity: 0.6;
    margin-top: 2px;
    font-family: 'Courier New', monospace;
}

/* ====== Input ====== */
.astrofloat_input_area {
    display: flex;
    gap: 6px;
    padding: 8px 10px;
    border-top: 1px solid rgba(0, 255, 136, 0.25);
    background: rgba(0, 0, 0, 0.3);
}

.astrofloat_input {
    flex: 1;
    padding: 8px 11px;
    background: rgba(0, 0, 0, 0.4);
    border: 1px solid rgba(0, 255, 136, 0.3);
    border-radius: 6px;
    color: #fff;
    font-size: 12px;
    outline: none;
    font-family: 'Segoe UI', Roboto, sans-serif;
}

.astrofloat_input:focus {
    border-color: #00ff88;
    box-shadow: 0 0 10px rgba(0, 255, 136, 0.4);
}

.astrofloat_input::placeholder { color: #667799; }

.astrofloat_send {
    padding: 0 16px;
    background: linear-gradient(135deg, #008844, #00cc66);
    border: 1px solid #00ff88;
    border-radius: 6px;
    color: #fff;
    font-size: 15px;
    font-weight: 700;
    cursor: pointer;
    transition: all 0.2s ease;
}

.astrofloat_send:hover {
    background: linear-gradient(135deg, #00cc66, #00ff88);
    box-shadow: 0 0 12px rgba(0, 255, 136, 0.7);
}

/* ====== Responsive ====== */
@media (max-width: 500px) {
    #astrofloat_chat_window { width: 300px; height: 400px; }
}
</style>

<!-- Botón flotante — icono del tema gow -->
<div id="astrofloat_chat_btn" onclick="astrofloat_toggle()" title="Chat rápido">
    <img class="astrofloat_icon" src="styles/theme/gow/images/icons8-aplicaci&oacute;n-telegrama-48.png" alt="Chat">
    <span id="astrofloat_chat_badge">0</span>
</div>

<!-- Ventana flotante -->
<div id="astrofloat_chat_window">
    <div class="astrofloat_header">
        <span class="title">Chat R&aacute;pido</span>
        <span class="status">En l&iacute;nea</span>
        <span class="close" onclick="astrofloat_toggle()">✖</span>
    </div>
    <div class="astrofloat_tabs">
        <button type="button" class="astrofloat_tab active" id="astrofloat_tab_gen" onclick="astrofloat_setChannel('gen')">💬 General</button>
        <button type="button" class="astrofloat_tab hidden" id="astrofloat_tab_ally" onclick="astrofloat_setChannel('ally')">🛡️ Alianza</button>
    </div>
    <div class="astrofloat_messages" id="astrofloat_messages"></div>
    <div class="astrofloat_input_area">
        <input type="text"
               class="astrofloat_input"
               id="astrofloat_input"
               placeholder="Escribe..."
               maxlength="500"
               onkeypress="if(event.key==='Enter') astrofloat_send()">
        <button class="astrofloat_send" onclick="astrofloat_send()">➤</button>
    </div>
</div>

<script>
{literal}
/* ═══════════════════════════════════════════════
   ASTROIO — Chat Flotante v3
   Canales: General (0) y Alianza (ally_id + 100)
   Badge  : nº de mensajes no leídos de ambos canales
   ═══════════════════════════════════════════════ */
(function() {
    var OPEN_POLL_MS    = 4000;   /* mensaje nuevo con la ventana abierta */
    var CLOSED_POLL_MS  = 15000;  /* chequeo del badge con la ventana cerrada */

    var st = {
        ch: 'gen',            /* canal activo en la ventana — DEFAULT: General */
        genLast: 0,           /* último mensaje de General VISTO (localStorage) */
        allyLast: 0,          /* último mensaje de Alianza VISTO (localStorage) */
        genId: 0, allyId: 0,  /* último mensaje CARGADO en el panel */
        allyCh: 0,            /* canal numérico de la alianza (ally_id + 100) */
        hasAlly: false,
        myId: 0,
        isOpen: false,
        timer: null,
        baseline: false       /* primera visita: lo viejo no cuenta como no leído */
    };

    try {
        st.genLast  = parseInt(localStorage.getItem('astrofloat_lastGen'))  || 0;
        st.allyLast = parseInt(localStorage.getItem('astrofloat_lastAlly')) || 0;
        st.baseline = localStorage.getItem('astrofloat_baseline') === '1';
    } catch (e) {}

    var btn     = document.getElementById('astrofloat_chat_btn');
    var win     = document.getElementById('astrofloat_chat_window');
    var msgBox  = document.getElementById('astrofloat_messages');
    var input   = document.getElementById('astrofloat_input');
    var badge   = document.getElementById('astrofloat_chat_badge');
    var tabGen  = document.getElementById('astrofloat_tab_gen');
    var tabAlly = document.getElementById('astrofloat_tab_ally');

    /* ---- Persistencia del "ya leído" ---- */
    function saveSeen() {
        try {
            localStorage.setItem('astrofloat_lastGen',  String(st.genLast));
            localStorage.setItem('astrofloat_lastAlly', String(st.allyLast));
        } catch (e) {}
    }

    function markRead(which, id) {
        id = parseInt(id) || 0;
        if (id <= 0) return;
        if (which === 'gen' && id > st.genLast)   { st.genLast  = id; saveSeen(); }
        if (which === 'ally' && id > st.allyLast) { st.allyLast = id; saveSeen(); }
    }

    /* ---- API ---- */
    function api(params, cb) {
        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'chat_bridge.php?' + params, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4 || xhr.status !== 200) return;
            try { cb(JSON.parse(xhr.responseText)); } catch (e) { console.error(e); }
        };
        xhr.send();
    }

    /* ---- Badge ---- */
    function setBadge(n) {
        n = parseInt(n) || 0;
        if (n > 0 && !st.isOpen) {
            badge.textContent = n > 99 ? '99+' : String(n);
            badge.style.display = 'flex';
        } else {
            badge.style.display = 'none';
        }
    }

    /* ---- Polling del badge (ventana cerrada) ---- */
    function pollUnread() {
        api('action=unread&genLast=' + st.genLast + '&allyLast=' + st.allyLast, function(d) {
            if (!d || d.error) return;
            st.hasAlly = !!d.hasAlly;
            if (parseInt(d.userAllyId) > 0) st.allyCh = parseInt(d.userAllyId) + 100;
            tabAlly.classList.toggle('hidden', !st.hasAlly);
            if (st.isOpen) return;   /* abierta → el badge no se muestra */

            /* Primera visita: lo que ya estaba en el chat no cuenta como no leído */
            if (!st.baseline) {
                st.baseline = true;
                if (st.genLast === 0  && parseInt(d.latestGen)  > 0) st.genLast  = parseInt(d.latestGen);
                if (st.allyLast === 0 && parseInt(d.latestAlly) > 0) st.allyLast = parseInt(d.latestAlly);
                try { localStorage.setItem('astrofloat_baseline', '1'); } catch (e) {}
                saveSeen();
                return;
            }
            setBadge(parseInt(d.gen) + parseInt(d.ally));
        });
    }

    /* ---- Polling / carga de mensajes ---- */
    function stopPolling() {
        if (st.timer) { clearInterval(st.timer); st.timer = null; }
    }

    function startPolling(open) {
        stopPolling();
        if (open) {
            st.timer = setInterval(function() { loadChannel(false); }, OPEN_POLL_MS);
        } else {
            st.timer = setInterval(pollUnread, CLOSED_POLL_MS);
        }
    }

    function loadChannel(reset) {
        var ch = st.ch;
        if (ch === 'ally' && (!st.hasAlly || !st.allyCh)) return;

        var chanId = (ch === 'gen') ? 0 : st.allyCh;
        var lastId = reset ? 0 : (ch === 'gen' ? st.genId : st.allyId);

        api('action=get&channel=' + chanId + '&last_id=' + lastId, function(d) {
            if (!d || d.error) return;
            st.myId = parseInt(d.userId) || 0;
            if (parseInt(d.userAllyId) > 0) {
                st.hasAlly = true;
                st.allyCh = parseInt(d.userAllyId) + 100;
                tabAlly.classList.remove('hidden');
            }

            if (reset) msgBox.innerHTML = '';
            var msgs = d.messages || [];
            for (var i = 0; i < msgs.length; i++) {
                appendMsg(msgs[i]);
                if (ch === 'gen') { if (msgs[i].id > st.genId) st.genId = parseInt(msgs[i].id); }
                else              { if (msgs[i].id > st.allyId) st.allyId = parseInt(msgs[i].id); }
            }

            /* Viendo el canal activo con la ventana abierta → marcado leído */
            markRead(ch, ch === 'gen' ? st.genId : st.allyId);
            scrollBottom(reset);
        });
    }

    function appendMsg(m) {
        var isMe = (parseInt(m.userID) === parseInt(st.myId));
        var tmp = document.createElement('div');
        tmp.innerHTML = m.text;
        var plain = tmp.textContent || tmp.innerText || '';

        var div = document.createElement('div');
        div.className = 'astrofloat_msg ' + (isMe ? 'me' : 'other');

        var hora = '';
        if (m.dateTime) {
            var d = new Date(String(m.dateTime).replace(' ', 'T'));
            if (!isNaN(d)) {
                hora = String(d.getHours()).padStart(2, '0') + ':' + String(d.getMinutes()).padStart(2, '0');
            }
        }

        div.innerHTML = '<span class="name">' + escapeHtml(m.userName || '???') + '</span>' +
                        escapeHtml(plain) +
                        '<span class="time">' + hora + '</span>';

        msgBox.appendChild(div);
    }

    function scrollBottom(force) {
        var nearBottom = (msgBox.scrollHeight - msgBox.scrollTop - msgBox.clientHeight) < 100;
        if (nearBottom || force) msgBox.scrollTop = msgBox.scrollHeight;
    }

    function escapeHtml(t) {
        var d = document.createElement('div');
        d.textContent = t;
        return d.innerHTML;
    }

    /* ---- Cambiar de canal (pestañas) ---- */
    function setChannel(ch) {
        if (ch === 'ally' && !st.hasAlly) return;
        st.ch = ch;
        tabGen.classList.toggle('active', ch === 'gen');
        tabAlly.classList.toggle('active', ch === 'ally');
        loadChannel(true);           /* historial del canal */
        startPolling(true);          /* polling del canal activo */
    }
    window.astrofloat_setChannel = setChannel;

    /* ---- Abrir / cerrar la burbuja ---- */
    window.astrofloat_toggle = function() {
        st.isOpen = !st.isOpen;
        if (st.isOpen) {
            win.classList.add('open');
            badge.style.display = 'none';

            /* Al entrar al chat TODO se marca leído → el número desaparece */
            api('action=unread&genLast=' + st.genLast + '&allyLast=' + st.allyLast, function(d) {
                if (!d || d.error) return;
                st.hasAlly = !!d.hasAlly;
                if (parseInt(d.userAllyId) > 0) st.allyCh = parseInt(d.userAllyId) + 100;
                tabAlly.classList.toggle('hidden', !st.hasAlly);
                markRead('gen',  d.latestGen);
                markRead('ally', d.latestAlly);
            });

            setChannel('gen');       /* SIEMPRE abre en General */
            setTimeout(function() { input.focus(); }, 150);
        } else {
            win.classList.remove('open');
            startPolling(false);
            pollUnread();            /* recalcular el badge al cerrar */
        }
    };

    /* ---- Enviar ---- */
    window.astrofloat_send = function() {
        var text = input.value.trim();
        if (text === '') return;
        input.value = '';
        input.focus();

        var chanId = (st.ch === 'gen') ? 0 : st.allyCh;
        var fd = new FormData();
        fd.append('action', 'send');
        fd.append('channel', String(chanId));
        fd.append('text', text);

        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'chat_bridge.php', true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4) return;
            if (xhr.status !== 200) { alert('Error al enviar'); return; }
            try {
                var d = JSON.parse(xhr.responseText);
                if (d.success) {
                    loadChannel(true);   /* recarga el canal y lo marca leído */
                } else {
                    alert('Error: ' + (d.error || 'desconocido'));
                }
            } catch (e) { console.error(e); }
        };
        xhr.send(fd);
    };

    /* ---- Inicio: badge desde el primer segundo + chequeo cada 15 s ---- */
    pollUnread();
    startPolling(false);
})();
{/literal}
</script>
