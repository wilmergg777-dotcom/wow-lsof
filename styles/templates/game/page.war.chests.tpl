{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.war.chests.tpl === *}
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

{* ============================================ *}
{* ⚔️ TAB: MIS COFRES DE GUERRA                 *}
{* ============================================ *}

<div class="astrowar_section">🎁 Mis Cofres de Guerra</div>

{* ============================================ *}
{* INFO TOTAL                                    *}
{* ============================================ *}
<div class="astrowar_chest_info">
    {if $war_chests_total > 0}
        Tienes un total de <b>{$war_chests_total}</b> cofre{if $war_chests_total != 1}s{/if} acumulado{if $war_chests_total != 1}s{/if}.
    {else}
        Todavía no has ganado ningún cofre.
    {/if}
</div>

{* ============================================ *}
{* GRID DE COFRES                                *}
{* ============================================ *}
<div class="astrowar_chest_grid">
    {foreach $war_chests as $c}
        <div class="astrowar_chest_card astrowar_chest_tier-{$c.tipo} {if $c.total == 0}astrowar_chest_empty{/if}">

            {* Icono del cofre *}
            <div class="astrowar_chest_img">
                {if $c.tipo == 'I'}📦
                {elseif $c.tipo == 'II'}📦
                {elseif $c.tipo == 'III'}📦
                {elseif $c.tipo == 'IV'}🎁
                {elseif $c.tipo == 'V'}🎁
                {elseif $c.tipo == 'VI'}💎
                {elseif $c.tipo == 'VII'}👑
                {else}📦
                {/if}
            </div>

            {* Nombre *}
            <div class="astrowar_chest_name">
                Cofre {$c.tipo}
                {if $c.rarro}
                    <span class="astrowar_chest_rare" title="¡Contiene al menos 1 cofre raro!">⭐</span>
                {/if}
            </div>

            {* Rareza visual *}
            <div class="astrowar_chest_tier">
                {if $c.tipo == 'I'}Común
                {elseif $c.tipo == 'II'}Común
                {elseif $c.tipo == 'III'}Común
                {elseif $c.tipo == 'IV'}Poco común
                {elseif $c.tipo == 'V'}Raro
                {elseif $c.tipo == 'VI'}Épico
                {elseif $c.tipo == 'VII'}Legendario
                {else}—
                {/if}
            </div>

            {* Cantidad *}
            <div class="astrowar_chest_count">
                {if $c.total > 0}
                    x{$c.total}
                {else}
                    <span style="color:#556677;">x0</span>
                {/if}
            </div>

            {* Botón abrir (deshabilitado v1) *}
            <div class="astrowar_chest_action">
                {if $c.total > 0}
                    <button type="button"
                            class="astrowar_chest_btn"
                            disabled
                            title="Próximamente podrás abrir tus cofres">
                        🔒 ABRIR
                    </button>
                {else}
                    <span class="astrowar_chest_none">—</span>
                {/if}
            </div>

        </div>
    {/foreach}
</div>

{* ============================================ *}
{* AVISO — Próximamente abrir cofres             *}
{* ============================================ *}
<div class="astrowar_warn" style="margin-top:14px;text-align:center;">
    🔧 <b>Función de abrir cofres próximamente.</b><br>
    <span style="font-size:10.5px;">
        Los cofres se acumulan por ahora y se podrán abrir en una próxima actualización.
        Contendrán recursos según su tier.
    </span>
</div>

{* ============================================ *}
{* TABLA DE CONTENIDO POR TIER (informativo)    *}
{* ============================================ *}
<div class="astrowar_section" style="margin-top:16px;">📋 Contenido estimado por tier</div>

<table class="astrowar_table astrowar_chest_table">
    <thead>
        <tr>
            <th style="width:70px;">Cofre</th>
            <th style="width:100px;">Rareza</th>
            <th>Metal</th>
            <th>Cristal</th>
            <th>Deuterio</th>
        </tr>
    </thead>
    <tbody>
        <tr><td><b>Cofre I</b></td>   <td>Común</td>      <td>10K</td>    <td>5K</td>     <td>1K</td></tr>
        <tr><td><b>Cofre II</b></td>  <td>Común</td>      <td>50K</td>    <td>25K</td>    <td>5K</td></tr>
        <tr><td><b>Cofre III</b></td> <td>Común</td>      <td>200K</td>   <td>100K</td>   <td>20K</td></tr>
        <tr><td><b>Cofre IV</b></td>  <td>Poco común</td> <td>1M</td>     <td>500K</td>   <td>100K</td></tr>
        <tr><td><b>Cofre V</b></td>   <td>Raro</td>       <td>5M</td>     <td>2.5M</td>   <td>500K</td></tr>
        <tr><td><b>Cofre VI</b></td>  <td>Épico</td>      <td>25M</td>    <td>12M</td>    <td>2.5M</td></tr>
        <tr><td><b>Cofre VII</b></td> <td>Legendario</td> <td>100M</td>   <td>50M</td>    <td>10M</td></tr>
    </tbody>
</table>

<div class="astrowar_empty" style="margin-top:10px;font-size:10px;">
    💡 Los valores son estimados. El contenido final puede variar.
</div>

<style>
/* ============================================
   COFRES
   ============================================ */

.astrowar_chest_info {
    padding: 8px 14px;
    margin: 8px 0;
    background: rgba(0, 0, 0, 0.25);
    border-radius: 6px;
    text-align: center;
    font-size: 11px;
    color: #8899aa;
}
.astrowar_chest_info b { color: #ffaa33; font-size: 13px; }

/* ============ GRID ============ */
.astrowar_chest_grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 10px;
    margin: 10px 0;
}

/* ============ CARD ============ */
.astrowar_chest_card {
    padding: 10px 8px;
    background: linear-gradient(180deg, #1a2332, #0f1624);
    border: 2px solid;
    border-radius: 10px;
    text-align: center;
    transition: 0.2s ease;
    position: relative;
    overflow: hidden;
}
.astrowar_chest_card:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.5);
}
.astrowar_chest_card.astrowar_chest_empty {
    opacity: 0.4;
    border-color: #556677 !important;
}
.astrowar_chest_card.astrowar_chest_empty:hover {
    transform: none;
    box-shadow: none;
}

/* ============ TIER COLORS ============ */
.astrowar_chest_tier-I    { border-color: #8899aa; } /* Gris - Común */
.astrowar_chest_tier-II   { border-color: #8899aa; }
.astrowar_chest_tier-III  { border-color: #66ccff; } /* Cyan - Común */
.astrowar_chest_tier-IV   { border-color: #00ff88; } /* Verde - Poco común */
.astrowar_chest_tier-V    { border-color: #aa44ff; } /* Púrpura - Raro */
.astrowar_chest_tier-VI   { border-color: #ff8800; } /* Naranja - Épico */
.astrowar_chest_tier-VII  { border-color: #ffdd44; } /* Dorado - Legendario */

.astrowar_chest_tier-V:hover    { box-shadow: 0 0 16px rgba(170, 68, 255, 0.4); }
.astrowar_chest_tier-VI:hover   { box-shadow: 0 0 16px rgba(255, 136, 0, 0.4); }
.astrowar_chest_tier-VII:hover  { box-shadow: 0 0 20px rgba(255, 221, 68, 0.5); }

/* ============ ICONO ============ */
.astrowar_chest_img {
    font-size: 32px;
    line-height: 1;
    margin-bottom: 4px;
    filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.5));
}
.astrowar_chest_tier-VII .astrowar_chest_img {
    filter: drop-shadow(0 0 12px rgba(255, 221, 68, 0.8));
    animation: astrowar_chest_glow 2s infinite;
}
@keyframes astrowar_chest_glow {
    0%, 100% { filter: drop-shadow(0 0 8px rgba(255, 221, 68, 0.7)); }
    50%      { filter: drop-shadow(0 0 16px rgba(255, 221, 68, 1)); }
}

/* ============ NOMBRE ============ */
.astrowar_chest_name {
    font-size: 12px;
    font-weight: 700;
    color: #fff;
    margin-bottom: 2px;
}
.astrowar_chest_rare {
    font-size: 11px;
    margin-left: 2px;
    animation: astrowar_rare_pulse 1.5s infinite;
    display: inline-block;
}
@keyframes astrowar_rare_pulse {
    0%, 100% { opacity: 1; transform: scale(1); }
    50%      { opacity: 0.6; transform: scale(1.15); }
}

/* ============ RAREZA ============ */
.astrowar_chest_tier {
    font-size: 9.5px;
    color: #8899aa;
    text-transform: uppercase;
    letter-spacing: 0.3px;
    margin-bottom: 6px;
}
.astrowar_chest_tier-IV   .astrowar_chest_tier { color: #00ff88; }
.astrowar_chest_tier-V    .astrowar_chest_tier { color: #aa44ff; }
.astrowar_chest_tier-VI   .astrowar_chest_tier { color: #ff8800; }
.astrowar_chest_tier-VII  .astrowar_chest_tier { color: #ffdd44; }

/* ============ CANTIDAD ============ */
.astrowar_chest_count {
    font-size: 18px;
    font-weight: 900;
    color: #ffaa33;
    font-family: 'Courier New', monospace;
    margin: 4px 0 6px;
    text-shadow: 0 2px 6px rgba(255, 170, 51, 0.3);
}

/* ============ BOTÓN ABRIR ============ */
.astrowar_chest_action {
    margin-top: 4px;
}
.astrowar_chest_btn {
    display: inline-block;
    padding: 5px 12px;
    background: #333a44;
    border: 1px solid #556677;
    border-radius: 5px;
    color: #8899aa;
    font-size: 9.5px;
    font-weight: 700;
    cursor: not-allowed;
    letter-spacing: 0.5px;
    text-transform: uppercase;
}
.astrowar_chest_none {
    color: #556677;
    font-size: 12px;
}

/* ============ TABLA ============ */
.astrowar_chest_table {
    font-size: 11px;
}
.astrowar_chest_table th {
    background: linear-gradient(180deg, #004488, #0077cc);
    color: #fff;
    padding: 6px;
    text-align: center;
    font-size: 10.5px;
    text-transform: uppercase;
    letter-spacing: 0.3px;
    border-bottom: 1px solid #00ccff;
}
.astrowar_chest_table td {
    padding: 5px 6px;
    border-bottom: 1px solid rgba(0, 224, 255, 0.08);
    color: #c8d6e5;
    text-align: center;
    font-family: 'Courier New', monospace;
}
.astrowar_chest_table td:first-child {
    text-align: left;
    font-family: inherit;
}
.astrowar_chest_table td:nth-child(2) {
    text-align: left;
    font-family: inherit;
    font-size: 10.5px;
    color: #8899aa;
}
.astrowar_chest_table tr:hover td {
    background: rgba(0, 224, 255, 0.05);
}

/* ============ RESPONSIVE ============ */
@media (max-width: 720px) {
    .astrowar_chest_grid {
        grid-template-columns: repeat(2, 1fr);
    }
}
</style>