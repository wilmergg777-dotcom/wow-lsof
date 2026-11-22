{block name="title" prepend}{$LNG.lm_buddylist}{/block}
{block name="content"}

{* ============================================================
   ASTROIO BUDDYLIST REQUEST v3.0 — Estilo Xnova (glassmorphism)
   Prefijo CSS: .astrobudr_
   Acento del módulo: 🟢 Verde (#4aff88)
   FIX v3.0:
     - Patrón fleetDealer aplicado (popup + inputs + botón)
     - Inputs con radius 8px + focus translateY
     - Botón con radius 8px + hover translateY
     - ⚠️ CRÍTICO: content_page_popup + title_popup + content_popup intactos (fancybox)
     - ⚠️ CRÍTICO: form name="buddy" id="buddy" + hidden id + #cntChars + #text intactos
     - ⚠️ CRÍTICO: onkeyup contador + readonly + {$id}/{$username}/{$galaxy} intactos
   ============================================================ *}

<style>
/* ====== Variables globales ====== */
:root {
    --bg-dark:       rgba(11, 16, 30, 0.55);
    --bg-card:       rgba(15, 23, 42, 0.75);
    --bg-card-solid: rgba(15, 23, 42, 0.85);
    --bg-inner:      rgba(0, 0, 0, 0.35);
    --border-color:  #1e293b;
    --text-main:     #cbd5e1;
    --text-muted:    #94a3b8;
    --text-title:    #ffffff;
    --accent-blue:   #3b82f6;
    --accent-cyan:   #00e0ff;
    --accent-purple: #8b5cf6;
    --accent-gold:   #fbbf24;
    --accent-green:  #4aff88;
    --accent-red:    #ef4444;
}

/* ====== Contenedores del popup (fancybox) ====== */
.content_page_popup {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-radius: 12px;
    color: var(--text-main);
    font-family: 'Segoe UI', Tahoma, sans-serif;
    padding: 15px;
    box-sizing: border-box;
}

.title_popup {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-bottom: 1px solid var(--accent-green);
    border-radius: 10px 10px 0 0;
    color: #ffffff;
    font-size: 12.5px;
    font-weight: 700;
    letter-spacing: 1px;
    text-transform: uppercase;
    padding: 10px 14px;
    text-shadow: 0 1px 3px rgba(0, 0, 0, 0.4), 0 0 10px rgba(74, 255, 136, 0.4);
}

.content_popup {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(74, 255, 136, 0.15);
    border-top: none;
    border-radius: 0 0 12px 12px;
    padding: 15px;
}

/* ====== Tabla del popup ====== */
.content_popup table {
    width: 100%;
    border-collapse: collapse;
    font-size: 11px;
}

.content_popup table td {
    padding: 8px 10px;
    color: var(--text-main);
    vertical-align: middle;
}

.content_popup table td:first-child {
    color: var(--text-muted);
    font-weight: 600;
    width: 40%;
}

.content_popup table tr:hover td {
    background: rgba(74, 255, 136, 0.05);
}

/* ====== Inputs ====== */
.content_popup input[type="text"] {
    width: 100%;
    padding: 7px 12px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    color: #ffffff;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    font-size: 11px;
    outline: none;
    transition: 0.25s ease;
    box-sizing: border-box;
}
.content_popup input[type="text"]:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}
.content_popup input[type="text"][readonly] {
    background: rgba(0, 0, 0, 0.35);
    border-color: rgba(30, 41, 59, 0.8);
    color: var(--text-muted);
    cursor: not-allowed;
}
.content_popup input[type="text"][readonly]:focus {
    border-color: rgba(30, 41, 59, 0.8);
    box-shadow: none;
    transform: none;
}

/* ====== Textarea ====== */
.content_popup textarea {
    width: 100%;
    box-sizing: border-box;
    padding: 8px 12px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    color: #ffffff;
    font-family: inherit;
    font-size: 11px;
    line-height: 1.4;
    outline: none;
    transition: 0.25s ease;
    resize: vertical;
}
.content_popup textarea:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}

/* ====== Contador de caracteres ====== */
#cntChars {
    color: #ffaa33 !important;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    font-size: 11px;
    text-shadow: 0 0 6px rgba(255, 170, 51, 0.4);
}

/* ====== Botón submit ====== */
.content_popup input[type="submit"] {
    display: block;
    width: 100%;
    padding: 10px 26px;
    background: linear-gradient(135deg, rgba(34, 136, 51, 0.9), rgba(74, 255, 136, 0.9));
    border: 1px solid #4aff88;
    border-radius: 8px;
    color: #0f1624;
    font-weight: 700;
    font-size: 11.5px;
    cursor: pointer;
    transition: 0.25s ease;
    letter-spacing: 0.5px;
    text-shadow: 0 1px 2px rgba(255, 255, 255, 0.2);
    font-family: inherit;
    text-transform: uppercase;
    box-shadow: 0 3px 10px rgba(34, 136, 51, 0.4);
}
.content_popup input[type="submit"]:hover {
    background: linear-gradient(135deg, rgba(74, 255, 136, 0.95), rgba(140, 255, 180, 0.95));
    box-shadow: 0 0 16px rgba(74, 255, 136, 0.6), 0 3px 10px rgba(34, 136, 51, 0.5);
    transform: translateY(-2px);
}
.content_popup input[type="submit"]:active {
    transform: translateY(0);
}

/* ====== Responsive ====== */
@media (max-width: 480px) {
    .content_page_popup { padding: 10px; }
    .content_popup { padding: 12px; }
    .content_popup table td:first-child { width: 35%; }
    .content_popup table td { padding: 6px 8px; }
}
</style>

<div class="content_page_popup">
    <div class="title_popup">
        {$LNG.bu_request_message}
    </div>

    <div class="content_popup">
        <form name="buddy" id="buddy" action="game.php?page=buddyList&amp;mode=send&amp;ajax=1" method="post">
        <input type="hidden" name="id" value="{$id}">
            <table style="width:100%;">
                <tr style="height:20px;">
                    <td>{$LNG.bu_player}</td>
                    <td><input type="text" value="{$username} [{$galaxy}:{$system}:{$planet}]" size="40" readonly></td>
                </tr>
                <tr>
                    <td>{$LNG.bu_request_text}(<span id="cntChars">0</span> / 5000 {$LNG.bu_characters})</td>
                    <td><textarea style="height: 203px;" name="text" id="text" cols="40" rows="10" size="100" onkeyup="$('#cntChars').text($(this).val().length);"></textarea></td>
                </tr>
                <tr>
                    <td colspan="2"><input type="submit" value="{$LNG.bu_send}"></td>
                </tr>
            </table>
        </form>
    </div>
</div>

{/block}