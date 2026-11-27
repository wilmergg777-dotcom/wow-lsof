{block name="title" prepend}Mensajes{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.messages.default.tpl === *}
{literal}
<style>
/* === ASTROIO v3.0 === */
#content h1, #content h2, #content h3, #content h4 { color:#fff; letter-spacing:.5px; text-shadow:0 1px 3px rgba(0,0,0,.5) }
#content a { color:#00e0ff; text-decoration:none; transition:.2s ease }
#content a:hover { color:#fff; text-shadow:0 0 10px rgba(0,224,255,.7) }
#content table { background:rgba(15,23,42,.55); border:1px solid #1e293b; border-radius:10px; border-collapse:collapse; overflow:hidden }
#content table th { background:linear-gradient(135deg,rgba(0,68,136,.85),rgba(0,119,204,.85)); border-bottom:1px solid rgba(0,224,255,.5); color:#fff; padding:6px 9px; text-align:left; text-transform:uppercase; font-size:10px; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
#content table td { padding:6px 9px; border-bottom:1px solid rgba(30,41,59,.7); color:#cbd5e1 }
#content table tr:hover td { background:rgba(0,224,255,.04) }
#content input[type=text], #content input[type=password], #content input[type=email], #content input[type=number], #content input[type=date], #content select, #content textarea { background:rgba(0,0,0,.5); color:#fff; border:1px solid rgba(0,204,255,.35); border-radius:8px; padding:5px 9px; font-size:12px; font-family:inherit; box-sizing:border-box; max-width:100%; transition:.25s ease }
#content input[type=text]:focus, #content input[type=password]:focus, #content input[type=email]:focus, #content input[type=number]:focus, #content select:focus, #content textarea:focus { outline:none; border-color:#00e0ff; box-shadow:0 0 12px rgba(0,224,255,.5); background:rgba(0,0,0,.65) }
#content textarea { width:100%; resize:vertical; font-family:inherit }
#content button, #content input[type=submit], #content input[type=button] { background:linear-gradient(180deg,#0066cc,#0099ff); color:#fff; border:1px solid #00e0ff; border-radius:8px; padding:5px 16px; font-size:11.5px; font-weight:600; font-family:inherit; cursor:pointer; transition:.25s ease; text-transform:uppercase; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
#content button:hover, #content input[type=submit]:hover, #content input[type=button]:hover { box-shadow:0 0 18px rgba(0,224,255,.5); transform:translateY(-2px) }
#content button:active, #content input[type=submit]:active, #content input[type=button]:active { transform:translateY(0) }
#content input[type=reset] { background:linear-gradient(180deg,#444,#666); border-color:#888 }
#content select option { background:#0f172a; color:#cbd5e1 }
#content .globalWarning { background:rgba(239,68,68,.12); border:1px solid rgba(239,68,68,.45); color:#fecaca; border-radius:10px; padding:8px 14px; text-align:center }
@media (max-width:760px) { #content { padding:6px; overflow-x:auto } #content table { font-size:11px } #content table th, #content table td { padding:5px 7px } }
</style>
{/literal}


<style>
.content_page { padding: 0 !important; margin: 0 !important; background: transparent !important; }

.msg-wrapper {
    display: flex;
    flex-direction: column;
    min-height: 420px;
    max-height: calc(100vh - 150px);
    max-width: 1150px;
    margin: 0 auto;
    background: rgba(15, 23, 42, 0.65);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(0, 224, 255, 0.2);
    border-radius: 10px;
    overflow: hidden;
    color: #cbd5e1;
    font-family: 'Inter', 'Segoe UI', sans-serif;
}

.msg-header { display: flex; justify-content: space-between; align-items: center; padding: 15px 20px; background: rgba(15, 23, 42, 0.85); border-bottom: 1px solid rgba(0, 224, 255, 0.15); }
.msg-header h2 { margin: 0; font-size: 18px; color: #fff; display: flex; align-items: center; gap: 8px; }
.msg-btn { padding: 8px 16px; border-radius: 6px; font-size: 13px; font-weight: 700; cursor: pointer; border: none; display: inline-flex; align-items: center; gap: 6px; transition: 0.2s; margin-left: 8px; }
.msg-btn-danger { background: rgba(239, 68, 68, 0.15); color: #ef4444; border: 1px solid rgba(239, 68, 68, 0.5); }
.msg-btn-danger:hover { background: #ef4444; color: #fff; }
.msg-btn-primary { background: #00d4ff; color: #000; }
.msg-btn-primary:hover { box-shadow: 0 0 14px rgba(0, 212, 255, 0.6); }

/* 🆕 v1.1 — Botón "Marcar como leído" (cyan suave) */
.msg-btn-success { background: rgba(0, 212, 255, 0.15); color: #00d4ff; border: 1px solid rgba(0, 212, 255, 0.5); }
.msg-btn-success:hover { background: #00d4ff; color: #000; }

.msg-tabs { display: flex; gap: 8px; padding: 12px 20px; background: rgba(0, 0, 0, 0.25); border-bottom: 1px solid rgba(0, 224, 255, 0.1); }
.msg-tab { padding: 8px 16px; font-size: 13px; font-weight: 600; color: #94a3b8; border-radius: 6px; cursor: pointer; transition: 0.2s; background: transparent; border: none; }
.msg-tab:hover { background: rgba(0, 212, 255, 0.1); color: #fff; }
.msg-tab.active { background: #00d4ff; color: #000; font-weight: 700; }

.msg-subtabs { display: flex; flex-wrap: wrap; gap: 6px; padding: 12px 20px; background: rgba(0, 0, 0, 0.15); border-bottom: 1px solid rgba(0, 224, 255, 0.1); }
.msg-subtab { padding: 6px 14px; font-size: 11px; font-weight: 600; color: #94a3b8; background: rgba(0, 0, 0, 0.3); border: 1px solid rgba(0, 212, 255, 0.15); border-radius: 20px; cursor: pointer; transition: 0.2s; position: relative; }
.msg-subtab:hover { border-color: #00d4ff; color: #fff; }
.msg-subtab.active { background: rgba(0, 212, 255, 0.15); border-color: #00d4ff; color: #00d4ff; }

/* ═══════════════════════════════════════════════════════════
   CATEGORÍA CON MENSAJES NO LEÍDOS
   Estilo sutil cyan con puntito luminoso — pega con el tema
   ═══════════════════════════════════════════════════════════ */
.msg-subtab.has-unread {
    background: rgba(0, 212, 255, 0.10);
    border-color: rgba(0, 212, 255, 0.55);
    color: #7dd3fc;
}
.msg-subtab.has-unread:hover {
    background: rgba(0, 212, 255, 0.18);
    border-color: #00d4ff;
    color: #ffffff;
}
.msg-subtab.has-unread::after {
    content: '';
    display: inline-block;
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background: #00d4ff;
    box-shadow: 0 0 6px rgba(0, 212, 255, 0.9);
    margin-left: 7px;
    vertical-align: middle;
    animation: subtle-pulse 2.5s ease-in-out infinite;
}
@keyframes subtle-pulse {
    0%, 100% { box-shadow: 0 0 6px rgba(0, 212, 255, 0.9); }
    50%      { box-shadow: 0 0 10px rgba(0, 212, 255, 1); }
}
.msg-subtab.has-unread.active {
    background: rgba(0, 212, 255, 0.20);
    border-color: #00d4ff;
    color: #ffffff;
}

.msg-body { display: flex; flex: 1; overflow: hidden; min-height: 0; }
.msg-list { width: 380px; border-right: 1px solid rgba(0, 224, 255, 0.15); overflow-y: auto; background: transparent; }
.msg-list::-webkit-scrollbar { width: 6px; }
.msg-list::-webkit-scrollbar-thumb { background: #334155; border-radius: 3px; }
.msg-reader { flex: 1; padding: 20px; overflow-y: auto; background: transparent; display: flex; flex-direction: column; }

.msg-item { padding: 12px 15px; border-bottom: 1px solid rgba(255,255,255,0.05); cursor: pointer; display: flex; gap: 10px; align-items: flex-start; transition: 0.2s; position: relative; }
.msg-item:hover { background: rgba(0, 212, 255, 0.06); }
.msg-item.unread { border-left: 3px solid #00d4ff; background: rgba(0, 212, 255, 0.04); }
.msg-item.active { background: rgba(0, 212, 255, 0.12); border-left: 3px solid #00d4ff; }
.msg-avatar { width: 32px; height: 32px; background: #1e293b; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: #00d4ff; font-size: 14px; flex-shrink: 0; }
.msg-item-body { flex: 1; overflow: hidden; }
.msg-item-sender { font-size: 12px; color: #00d4ff; font-weight: 700; margin-bottom: 2px; }
.msg-item-subject { font-size: 13px; color: #fff; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.msg-item-preview { font-size: 11px; color: #64748b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; margin-top: 3px; }
.msg-item-date { font-size: 10px; color: #64748b; white-space: nowrap; align-self: flex-start; margin-left: 8px; }

/* ====== DIFERENCIACIÓN LEÍDO vs NO LEÍDO ====== */
.msg-item.unread .msg-item-subject { color: #ffffff; font-weight: 700; }
.msg-item.unread .msg-item-sender { color: #00d4ff; }
.msg-item.unread::after {
    content: '';
    position: absolute;
    right: 12px;
    top: 50%;
    transform: translateY(-50%);
    width: 8px; height: 8px;
    background: #00d4ff;
    border-radius: 50%;
    box-shadow: 0 0 8px rgba(0, 212, 255, 0.8);
}
.msg-item:not(.unread) .msg-item-subject { color: #94a3b8; font-weight: 500; }
.msg-item:not(.unread) .msg-item-sender { color: #64748b; }
.msg-item:not(.unread) { opacity: 0.85; }

.msg-reader-header { border-bottom: 1px solid rgba(0, 212, 255, 0.1); padding-bottom: 15px; margin-bottom: 20px; }
.msg-reader-header h3 { color: #fff; margin: 0 0 6px 0; font-size: 20px; font-weight: 700; }
.msg-reader-meta { font-size: 12px; color: #94a3b8; }
.msg-reader-body { font-size: 14px; line-height: 1.8; color: #cbd5e1; white-space: pre-wrap; flex: 1; }
.msg-reader-actions { margin-top: 20px; padding-top: 15px; border-top: 1px solid rgba(0, 212, 255, 0.1); display: flex; gap: 10px; justify-content: flex-end; }

.msg-btn-delete {
    background: rgba(239, 68, 68, 0.15);
    border: 1px solid rgba(239, 68, 68, 0.4);
    color: #ef4444;
    width: 32px; height: 32px;
    border-radius: 6px;
    cursor: pointer;
    font-size: 14px;
    transition: 0.2s;
    display: flex; align-items: center; justify-content: center;
}
.msg-btn-delete:hover { background: #ef4444; color: #fff; }

.msg-empty { display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%; color: #475569; text-align: center; padding: 40px 20px; }
.msg-empty svg { width: 48px; height: 48px; margin-bottom: 15px; opacity: 0.4; }
.msg-empty p { margin: 0; font-size: 13px; }

.msg-modal-bg { position: fixed; inset: 0; background: rgba(0,0,0,0.75); backdrop-filter: blur(6px); display: none; align-items: center; justify-content: center; z-index: 9999; }
.msg-modal-bg.open { display: flex; }
.msg-modal { background: #0f172a; border: 1px solid #1e293b; border-radius: 12px; width: 520px; max-width: 95%; padding: 24px; box-shadow: 0 20px 60px rgba(0,0,0,0.9); box-sizing: border-box; }
.msg-modal h3 { color: #fff; margin: 0 0 20px 0; font-size: 18px; display: flex; align-items: center; justify-content: space-between; }
.msg-modal h3 span { cursor: pointer; color: #64748b; font-size: 22px; }
.msg-modal h3 span:hover { color: #fff; }
.msg-modal label { display: block; font-size: 11px; color: #94a3b8; font-weight: 600; margin-bottom: 5px; text-transform: uppercase; letter-spacing: 0.5px; }
.msg-modal input, .msg-modal textarea { width: 100%; padding: 10px 12px; margin-bottom: 15px; background: rgba(0,0,0,0.4); border: 1px solid #334155; border-radius: 6px; color: #fff; font-family: inherit; font-size: 13px; box-sizing: border-box; }
.msg-modal input:focus, .msg-modal textarea:focus { border-color: #00d4ff; outline: none; box-shadow: 0 0 0 2px rgba(0, 212, 255, 0.15); }
.msg-modal textarea { min-height: 200px; resize: vertical; }
.msg-modal-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 5px; }
.msg-btn-cancel { background: transparent; border: 1px solid #334155; color: #94a3b8; padding: 9px 18px; border-radius: 6px; cursor: pointer; font-weight: 600; font-size: 13px; }
.msg-btn-cancel:hover { border-color: #fff; color: #fff; }
.msg-btn-send { background: #00d4ff; border: none; color: #000; padding: 9px 18px; border-radius: 6px; cursor: pointer; font-weight: 700; font-size: 13px; }
.msg-btn-send:hover { box-shadow: 0 0 12px rgba(0, 212, 255, 0.6); }

/* ============================================================
   RESPONSIVE MÓVIL — apilar lista + lector
   ============================================================ */
@media (max-width: 768px) {
    /* Contenedor principal: ya no dos columnas */
    .msg-body {
        flex-direction: column !important;
        overflow: visible !important;
    }
    /* Lista ocupa todo el ancho y limita su altura */
    .msg-list {
        width: 100% !important;
        max-height: 40vh !important;
        border-right: none !important;
        border-bottom: 1px solid rgba(0, 224, 255, 0.15) !important;
        box-sizing: border-box !important;
    }
    /* Lector debajo, ocupa todo */
    .msg-reader {
        width: 100% !important;
        min-height: 55vh !important;
        padding: 15px !important;
        box-sizing: border-box !important;
    }
    /* Header: botones apilados */
    .msg-header {
        flex-direction: column !important;
        align-items: stretch !important;
        gap: 10px !important;
        padding: 12px 15px !important;
    }
    .msg-header h2 {
        justify-content: center !important;
    }
    .msg-header > div {
        display: flex !important;
        flex-wrap: wrap !important;
        gap: 6px !important;
        justify-content: center !important;
    }
    .msg-btn {
        margin-left: 0 !important;
        flex: 1 1 auto !important;
        justify-content: center !important;
        font-size: 12px !important;
        padding: 10px 12px !important;
    }
    /* Tabs y subtabs */
    .msg-tabs, .msg-subtabs {
        padding: 8px 10px !important;
        justify-content: center !important;
    }
    .msg-subtab {
        font-size: 10px !important;
        padding: 5px 10px !important;
    }
    /* Wrapper: menos altura mínima */
    .msg-wrapper {
        max-height: none !important;
        min-height: 0 !important;
        width: 100% !important;
        max-width: 100% !important;
        border-radius: 8px !important;
    }
}
</style>

<div class="msg-wrapper">

    <div class="msg-header">
        <h2>✉️ Mensajes</h2>
        <div>
            <button class="msg-btn msg-btn-success" onclick="Message.markAllRead();">📬 Marcar todo como leído</button>
            
            <button class="msg-btn msg-btn-danger" onclick="if(confirm('¿Borrar todos los mensajes?'))Message.deleteAll();">🗑️ Borrar todos los mensajes</button>
            
            <button class="msg-btn msg-btn-primary" onclick="document.getElementById('newMsgModal').classList.add('open');">✉️ Nuevo Mensaje</button>
        </div>
    </div>

    <div class="msg-tabs">
        <button class="msg-tab active" onclick="Message.getMessages(100,0); setActive(this);">Recibidos</button>
        <button class="msg-tab" onclick="Message.getMessages(999,0); setActive(this);">Enviados</button>
        <button class="msg-tab" style="display:none;">Público</button>
    </div>

    <div class="msg-subtabs">
        <button class="msg-subtab active" id="tab_cat_100"
                data-category="100"
                data-unread="{$CategoryList.100.unread|default:0}"
                onclick="Message.getMessages(100,0); setActive(this);">Todos</button>

        <button class="msg-subtab" id="tab_cat_101"
                data-category="101"
                data-unread="{$CategoryList.101.unread|default:0}"
                onclick="Message.getMessages(101,0); setActive(this);">No leídos</button>

        <button class="msg-subtab" id="tab_cat_1"
                data-category="1"
                data-unread="{$CategoryList.1.unread|default:0}"
                onclick="Message.getMessages(1,0); setActive(this);">Jugadores</button>

        <button class="msg-subtab" id="tab_cat_2"
                data-category="2"
                data-unread="{$CategoryList.2.unread|default:0}"
                onclick="Message.getMessages(2,0); setActive(this);">Alianza</button>

        <button class="msg-subtab" id="tab_cat_4"
                data-category="4"
                data-unread="{$CategoryList.4.unread|default:0}"
                onclick="Message.getMessages(4,0); setActive(this);">Sistema</button>

        <button class="msg-subtab" id="tab_cat_3"
                data-category="3"
                data-unread="{$CategoryList.3.unread|default:0}"
                onclick="Message.getMessages(3,0); setActive(this);">Batallas</button>

        <button class="msg-subtab" id="tab_cat_0"
                data-category="0"
                data-unread="{$CategoryList.0.unread|default:0}"
                onclick="Message.getMessages(0,0); setActive(this);">Espionaje</button>

        <button class="msg-subtab" id="tab_cat_15"
                data-category="15"
                data-unread="{$CategoryList.15.unread|default:0}"
                onclick="Message.getMessages(15,0); setActive(this);">Expediciones</button>
    </div>

    <div class="msg-body">
        <div class="msg-list" id="message_list">
            <div class="msg-empty">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M3 7l9 6 9-6M3 7v10a2 2 0 002 2h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2z"/></svg>
                <p>Sin mensajes</p>
            </div>
        </div>
        <div class="msg-reader" id="message_content">
            <div class="msg-empty">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M3 7l9 6 9-6M3 7v10a2 2 0 002 2h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2z"/></svg>
                <p>Selecciona un mensaje para leerlo</p>
            </div>
        </div>
    </div>
</div>

<div class="msg-modal-bg" id="newMsgModal">
    <div class="msg-modal">
        <h3>✉️ Nuevo Mensaje <span onclick="document.getElementById('newMsgModal').classList.remove('open');">&times;</span></h3>
        <label>Destinatario</label>
        <input type="text" id="new_msg_to" placeholder="Escribe el nombre del jugador...">
        <label>Asunto</label>
        <input type="text" id="new_msg_subject" placeholder="Asunto del mensaje...">
        <label>Mensaje</label>
        <textarea id="new_msg_body" rows="10" placeholder="Escribe tu mensaje aquí..."></textarea>
        <div class="msg-modal-actions">
            <button class="msg-btn-cancel" onclick="document.getElementById('newMsgModal').classList.remove('open');">Cancelar</button>
            <button class="msg-btn-send" onclick="Message.sendMessage();">Enviar</button>
        </div>
    </div>
</div>

<script>
/* ═══════════════════════════════════════════════════════════
   setActive — Cambia el botón activo
   ═══════════════════════════════════════════════════════════ */
function setActive(el) {
    var parent = el.parentElement;
    parent.querySelectorAll('button, a').forEach(function(b){ b.classList.remove('active'); });
    el.classList.add('active');
}

/* ═══════════════════════════════════════════════════════════
   Pintar botones con mensajes NO LEÍDOS
   ═══════════════════════════════════════════════════════════ */
function pintarBotonesNoLeidos() {
    var tabs = document.querySelectorAll('.msg-subtab[data-unread]');
    tabs.forEach(function(btn) {
        var n = parseInt(btn.getAttribute('data-unread'), 10) || 0;
        if (n > 0) {
            btn.classList.add('has-unread');
        } else {
            btn.classList.remove('has-unread');
        }
    });
}

/* ═══════════════════════════════════════════════════════════
   AUTO-CARGA AL ENTRAR
   ═══════════════════════════════════════════════════════════ */
document.addEventListener('DOMContentLoaded', function() {
    pintarBotonesNoLeidos();

    var hayCategoriaPHP = false;
    {if !empty($category)}
        hayCategoriaPHP = true;
    {/if}

    if (!hayCategoriaPHP) {
        if (typeof Message !== 'undefined' && typeof Message.getMessages === 'function') {
            Message.getMessages(100, 0);
        }
    }
});
</script>

{/block}
{block name="script" append}
{if !empty($category)}
<script>$(function() { Message.getMessages({$category}, {$side}); })</script>
{/if}
{/block}