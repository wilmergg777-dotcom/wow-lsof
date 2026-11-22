<!-- ═══════════════════════════════════════════════
     ASTROIO — Chat Flotante (debajo de la campanita)
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

/* Badge rojo de mensajes nuevos */
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

<!-- Botón flotante -->
<div id="astrofloat_chat_btn" onclick="astrofloat_toggle()" title="Chat rápido">
    💬
    <span id="astrofloat_chat_badge">0</span>
</div>

<!-- Ventana flotante -->
<div id="astrofloat_chat_window">
    <div class="astrofloat_header">
        <span class="title">💬 Chat Rápido</span>
        <span class="status">En línea</span>
        <span class="close" onclick="astrofloat_toggle()">✖</span>
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
/* ═══════════════════════════════════════════════
   ASTROIO — Chat Flotante
   ═══════════════════════════════════════════════ */
(function() {
    var lastId      = 0;
    var myId        = 0;
    var interval    = null;
    var isOpen      = false;
    var unreadCount = 0;
    var initialized = false;

    var btn     = document.getElementById('astrofloat_chat_btn');
    var win     = document.getElementById('astrofloat_chat_window');
    var msgBox  = document.getElementById('astrofloat_messages');
    var input   = document.getElementById('astrofloat_input');
    var badge   = document.getElementById('astrofloat_chat_badge');

    // ---- Toggle abrir/cerrar ----
    window.astrofloat_toggle = function() {
        isOpen = !isOpen;
        if (isOpen) {
            win.classList.add('open');
            unreadCount = 0;
            badge.style.display = 'none';
            if (!initialized) {
                initialized = true;
                astrofloat_load();
            }
            astrofloat_startPolling();
            setTimeout(function(){ input.focus(); }, 150);
        } else {
            win.classList.remove('open');
            astrofloat_stopPolling();
        }
    };

    // ---- Polling ----
    function astrofloat_startPolling() {
        astrofloat_stopPolling();
        interval = setInterval(astrofloat_load, 4000);
    }

    function astrofloat_stopPolling() {
        if (interval) { clearInterval(interval); interval = null; }
    }

    // ---- Cargar mensajes ----
    function astrofloat_load() {
        var url = 'chat_bridge.php?action=get';
        if (lastId > 0) url += '&last_id=' + lastId;

        var xhr = new XMLHttpRequest();
        xhr.open('GET', url, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4 || xhr.status !== 200) return;
            try {
                var data = JSON.parse(xhr.responseText);
                if (data.error) return;
                myId = data.userId;

                if (lastId === 0) msgBox.innerHTML = '';

                data.messages.forEach(function(msg) {
                    astrofloat_addMsg(msg);
                    if (parseInt(msg.id) > lastId) lastId = parseInt(msg.id);

                    // Contar no leídos (si la ventana está cerrada)
                    if (!isOpen && parseInt(msg.userID) !== parseInt(myId)) {
                        unreadCount++;
                    }
                });

                if (!isOpen && unreadCount > 0) {
                    badge.textContent = unreadCount > 99 ? '99+' : unreadCount;
                    badge.style.display = 'flex';
                }
            } catch (e) { console.error(e); }
        };
        xhr.send();
    }

    // ---- Añadir mensaje ----
    function astrofloat_addMsg(msg) {
        var isMe = (parseInt(msg.userID) === parseInt(myId));
        var tmp = document.createElement('div');
        tmp.innerHTML = msg.text;
        var plain = tmp.textContent || tmp.innerText || '';

        var div = document.createElement('div');
        div.className = 'astrofloat_msg ' + (isMe ? 'me' : 'other');

        var hora = '';
        if (msg.dateTime) {
            var d = new Date(msg.dateTime.replace(' ', 'T'));
            if (!isNaN(d)) {
                hora = String(d.getHours()).padStart(2,'0') + ':' + String(d.getMinutes()).padStart(2,'0');
            }
        }

        div.innerHTML = '<span class="name">' + escapeHtml(msg.userName) + '</span>' +
                        escapeHtml(plain) +
                        '<span class="time">' + hora + '</span>';

        msgBox.appendChild(div);

        // Auto-scroll si está cerca del fondo
        var nearBottom = (msgBox.scrollHeight - msgBox.scrollTop - msgBox.clientHeight) < 100;
        if (nearBottom || isMe) msgBox.scrollTop = msgBox.scrollHeight;
    }

    function escapeHtml(t) {
        var d = document.createElement('div');
        d.textContent = t;
        return d.innerHTML;
    }

    // ---- Enviar ----
    window.astrofloat_send = function() {
        var text = input.value.trim();
        if (text === '') return;
        input.value = '';
        input.focus();

        var fd = new FormData();
        fd.append('action', 'send');
        fd.append('text', text);

        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'chat_bridge.php', true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4) return;
            if (xhr.status !== 200) { alert('Error al enviar'); return; }
            try {
                var data = JSON.parse(xhr.responseText);
                if (data.success) astrofloat_load();
                else alert('Error: ' + (data.error || 'desconocido'));
            } catch (e) { console.error(e); }
        };
        xhr.send(fd);
    };

    // ---- Polling ligero incluso si está cerrado (para el badge) ----
    setInterval(function() {
        if (!isOpen) astrofloat_load();
    }, 15000);
})();
</script>