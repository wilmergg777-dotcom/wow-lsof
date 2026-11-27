{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/install/ins_update.tpl === *}
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

{include file="ins_header.tpl"}

<style>
/* ═══════════════════════════════════════════════
   AstroIO v2.2 — Installer Upgrade (ins_update)
   Prefijo: .astroins_upd_
   ═══════════════════════════════════════════════ */

.astroins_upd_wrap {
    padding: 12px 0;
    font-family: 'Segoe UI', Roboto, Arial, sans-serif;
}

/* ─── Cabecera h2 ─── */
.astroins_upd_header {
    color: #00ccff;
    font-size: 15px;
    font-weight: 700;
    margin: 0 0 14px 0;
    text-transform: uppercase;
    letter-spacing: 1.2px;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.35);
}

/* ─── Párrafos generales ─── */
.astroins_upd_wrap p {
    color: #c8d6e5;
    font-size: 13px;
    line-height: 1.7;
    margin: 0 0 12px 0;
}

.astroins_upd_wrap p.left {
    text-align: left;
}

/* ─── Mensaje destacado (info principal) ─── */
.astroins_upd_info {
    padding: 12px 16px;
    background: rgba(0, 224, 255, 0.03);
    border: 1px solid #1e3a5f;
    border-left: 3px solid #00ccff;
    border-radius: 6px;
    color: #c8d6e5;
    font-size: 13px;
    line-height: 1.7;
    margin-bottom: 16px;
}

.astroins_upd_info p {
    margin: 0;
    color: #c8d6e5;
}

/* ─── Lista de updates (contenedor) ─── */
.astroins_upd_list {
    display: flex;
    flex-direction: column;
    gap: 14px;
    margin-bottom: 20px;
}

/* ─── Cada update (archivo + contenido) ─── */
.astroins_upd_item {
    background: linear-gradient(135deg, #0f1624 0%, #1a2332 100%);
    border: 1px solid #1e3a5f;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.35);
    overflow: hidden;
}

.astroins_upd_item_name {
    background: linear-gradient(180deg, #004488 0%, #0077cc 100%);
    border-bottom: 1px solid #00ccff;
    color: #ffffff;
    font-size: 12px;
    font-weight: 700;
    padding: 8px 14px;
    text-transform: uppercase;
    letter-spacing: 1px;
    font-family: 'Segoe UI', Roboto, Arial, sans-serif;
}

.astroins_upd_item_content {
    padding: 10px 14px;
    background: rgba(0, 0, 0, 0.25);
    color: #c8d6e5;
    font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
    font-size: 11.5px;
    line-height: 1.55;
    max-height: 240px;
    overflow-y: auto;
    overflow-x: auto;
    white-space: pre-wrap;
    word-wrap: break-word;
    scrollbar-width: thin;
    scrollbar-color: #00ccff #1a2332;
}

/* ─── Scrollbar custom del contenido ─── */
.astroins_upd_item_content::-webkit-scrollbar {
    width: 8px;
    height: 8px;
}
.astroins_upd_item_content::-webkit-scrollbar-track {
    background: #1a2332;
    border-radius: 4px;
}
.astroins_upd_item_content::-webkit-scrollbar-thumb {
    background: linear-gradient(180deg, #0066cc 0%, #00ccff 100%);
    border-radius: 4px;
}
.astroins_upd_item_content::-webkit-scrollbar-thumb:hover {
    background: linear-gradient(180deg, #0099ff 0%, #00e0ff 100%);
}

/* ─── Contenedor de acciones ─── */
.astroins_upd_actions {
    display: flex;
    justify-content: flex-start;
    align-items: center;
    gap: 10px;
    margin-top: 6px;
}

.astroins_upd_actions a {
    text-decoration: none;
    display: inline-block;
}

/* ─── Botones (submit y button) ─── */
.astroins_upd_btn {
    background: linear-gradient(180deg, #0066cc 0%, #0099ff 100%) !important;
    border: 1px solid #00ccff !important;
    border-radius: 6px !important;
    color: #ffffff !important;
    padding: 10px 28px !important;
    font-size: 12px !important;
    font-weight: 700 !important;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    cursor: pointer;
    transition: 0.25s ease;
    font-family: 'Segoe UI', Roboto, Arial, sans-serif;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.2);
}
.astroins_upd_btn:hover {
    background: linear-gradient(180deg, #0099ff 0%, #00ccff 100%) !important;
    box-shadow: 0 0 18px rgba(0, 224, 255, 0.6);
    transform: translateY(-1px);
}
.astroins_upd_btn:active {
    transform: translateY(0);
}

/* ─── Botón "Volver" (contexto sin updates) ─── */
.astroins_upd_back_btn {
    background: linear-gradient(180deg, #3a1e2a 0%, #5a2a3a 100%) !important;
    border: 1px solid #ff4488 !important;
    color: #ff88aa !important;
}
.astroins_upd_back_btn:hover {
    background: linear-gradient(180deg, #5a2a3a 0%, #7a3a4a 100%) !important;
    color: #ffffff !important;
    box-shadow: 0 0 18px rgba(255, 68, 136, 0.5) !important;
}

/* ─── Responsive ─── */
@media (max-width: 768px) {
    .astroins_upd_item_name {
        font-size: 11px;
        padding: 6px 10px;
    }
    .astroins_upd_item_content {
        padding: 8px 10px;
        font-size: 11px;
        max-height: 180px;
    }
    .astroins_upd_actions {
        flex-direction: column;
        align-items: stretch;
    }
    .astroins_upd_btn,
    .astroins_upd_actions a {
        width: 100%;
        box-sizing: border-box;
        text-align: center;
    }
}
</style>

<tr>
    <td colspan="2">
        <div id="main" class="astroins_upd_wrap">

            {* ─── Título principal ─── *}
            <h2 class="left astroins_upd_header">{$LNG.upgrade_intro_welcome}</h2>

            {if !empty($updates)}
                {* ═══ Caso: hay updates pendientes ═══ *}
                <form action="?mode=doupgrade" method="POST">

                    <div class="astroins_upd_info">
                        <p class="left">{sprintf($LNG.upgrade_available,$sql_revision,$file_revision)}</p>
                    </div>

                    <div class="astroins_upd_list">
                        {foreach $updates as $file => $content}
                            <div class="astroins_upd_item">
                                <div class="astroins_upd_item_name">{$file}</div>
                                <div class="astroins_upd_item_content">{$content}</div>
                            </div>
                        {/foreach}
                    </div>

                    <div class="astroins_upd_actions">
                        <input type="submit" class="astroins_upd_btn" value="{$LNG.continue}">
                    </div>
                </form>

            {else}
                {* ═══ Caso: no hay updates ═══ *}
                <div class="astroins_upd_info">
                    <p class="left">{sprintf($LNG.upgrade_notavailable,$sql_revision)}</p>
                </div>

                <div class="astroins_upd_actions">
                    <a href="index.php">
                        <button class="astroins_upd_btn astroins_upd_back_btn" style="cursor: pointer;">{$LNG.upgrade_back}</button>
                    </a>
                </div>
            {/if}

        </div>
    </td>
</tr>

{include file="ins_footer.tpl"}