{block name="title" prepend}{$LNG.lm_buildings}{/block}
{block name="content"}

{* ============================================================
   ASTROIO BUILDINGS v5.1 — CLON EXACTO NEXUS LEGACY
   FIX: Arreglado el error "Undefined array key PLANET" 
   en la cabecera.
   ============================================================ *}

<style>
/* ====== Variables Nexus Legacy ====== */
:root {
    --nexus-bg:      #0d1117; /* Fondo general */
    --nexus-card:    #161b22; /* Fondo tarjeta */
    --nexus-border:  #30363d; /* Bordes */
    --nexus-text:    #c9d1d9; /* Texto normal */
    --nexus-muted:   #8b949e; /* Texto gris */
    --nexus-title:   #ffffff; /* Títulos */
    --nexus-blue:    #1f6feb; /* Botón azul */
    --nexus-blue-h:  #388bfd; /* Botón azul hover */
    --nexus-red:     #f85149; /* Botón rojo */
    --nexus-orange:  #d29922; /* Etiqueta resource */
}

/* ====== Ocultar barra antigua si existiera ====== */
.astrobd_panel_header { display: none; }

/* ====== Contenedor principal ====== */
.nexus-wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
    background-color: transparent;
}

/* ====== Cabecera estilo Nexus (slots + queue) ====== */
.nexus-header {
    background: var(--nexus-card);
    border: 1px solid var(--nexus-border);
    border-radius: 8px;
    padding: 20px;
    margin-bottom: 20px;
    display: flex;
    flex-direction: column;
    gap: 15px;
}
.nexus-header-top {
    display: flex;
    justify-content: space-between;
    align-items: center;
}
.nexus-title {
    font-size: 22px;
    font-weight: 600;
    color: var(--nexus-title);
    margin: 0;
}
.nexus-subtitle {
    font-size: 14px;
    color: var(--nexus-muted);
}
.nexus-stats-bar {
    display: flex;
    gap: 20px;
    font-size: 13px;
    color: var(--nexus-text);
    border-top: 1px solid var(--nexus-border);
    padding-top: 15px;
}
.nexus-stat-item { display: flex; align-items: center; gap: 6px; }
.nexus-stat-item.red { color: var(--nexus-red); font-weight: 600; }

/* ====== Barra de Filtros (Visual) ====== */
.nexus-filters {
    display: flex;
    gap: 10px;
    margin-bottom: 20px;
    flex-wrap: wrap;
}
.nexus-filter-btn {
    background: var(--nexus-card);
    border: 1px solid var(--nexus-border);
    border-radius: 6px;
    padding: 6px 12px;
    color: var(--nexus-muted);
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 6px;
}
.nexus-filter-btn.active {
    background: rgba(31, 111, 235, 0.15);
    border-color: var(--nexus-blue);
    color: var(--nexus-blue);
}

/* ====== Grid de Tarjetas (5 columnas) ====== */
.nexus-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
    gap: 15px;
    width: 100%;
}

/* ====== Tarjeta Individual ====== */
.nexus-card {
    background: var(--nexus-card);
    border: 1px solid var(--nexus-border);
    border-radius: 8px;
    overflow: hidden;
    display: flex;
    flex-direction: column;
    transition: border-color 0.2s;
}
.nexus-card:hover {
    border-color: var(--nexus-blue);
}

/* Imagen de la tarjeta */
.nexus-card-img {
    height: 180px;
    background-size: cover;
    background-position: center;
    background-color: #010409;
    position: relative;
    border-bottom: 1px solid var(--nexus-border);
    cursor: pointer;
}

/* Nivel arriba a la derecha */
.nexus-level {
    position: absolute;
    top: 10px;
    right: 10px;
    font-size: 12px;
    font-weight: 600;
    color: var(--nexus-title);
    background: rgba(0, 0, 0, 0.7);
    padding: 2px 6px;
    border-radius: 4px;
}

/* Contenido de la tarjeta */
.nexus-content {
    padding: 12px;
    display: flex;
    flex-direction: column;
    flex-grow: 1;
    gap: 8px;
}

/* Título y nivel (texto) */
.nexus-card-title {
    font-size: 15px;
    font-weight: 600;
    color: var(--nexus-title);
    margin: 0;
    cursor: pointer;
}
.nexus-card-title:hover { text-decoration: underline; }

/* Etiqueta (Tag) */
.nexus-tag {
    display: inline-block;
    font-size: 10px;
    font-weight: 700;
    padding: 2px 6px;
    border-radius: 4px;
    text-transform: uppercase;
    width: fit-content;
    border: 1px solid;
}
.tag-resource { background: rgba(210, 153, 34, 0.1); color: var(--nexus-orange); border-color: rgba(210, 153, 34, 0.3); }
.tag-energy   { background: rgba(0, 224, 255, 0.1); color: #00e0ff; border-color: rgba(0, 224, 255, 0.3); }
.tag-utility  { background: rgba(139, 148, 158, 0.1); color: var(--nexus-muted); border-color: rgba(139, 148, 158, 0.3); }
.tag-military { background: rgba(248, 81, 73, 0.1); color: var(--nexus-red); border-color: rgba(248, 81, 73, 0.3); }

/* Descripción */
.nexus-desc {
    font-size: 12px;
    color: var(--nexus-muted);
    line-height: 1.4;
    margin: 0;
    flex-grow: 1;
    display: -webkit-box;
    -webkit-line-clamp: 3; /* Corta el texto a 3 líneas */
    -webkit-box-orient: vertical;
    overflow: hidden;
}

/* Costos */
.nexus-costs {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-top: 5px;
}
.nexus-cost-item {
    display: flex;
    align-items: center;
    gap: 4px;
    font-size: 12px;
    color: var(--nexus-text);
    font-family: monospace;
}
.nexus-cost-item.no { color: var(--nexus-red); }

/* Tiempo */
.nexus-time {
    display: flex;
    justify-content: space-between;
    font-size: 12px;
    color: var(--nexus-muted);
    margin-top: 5px;
}

/* ====== Botones ====== */
.nexus-actions {
    display: flex;
    flex-direction: column;
    gap: 6px;
    margin-top: 10px;
}
.nexus-btn-upgrade {
    display: block;
    width: 100%;
    padding: 8px;
    background: var(--nexus-blue);
    color: #ffffff;
    text-align: center;
    border-radius: 6px;
    font-size: 12px;
    font-weight: 600;
    text-decoration: none;
    border: none;
    cursor: pointer;
    transition: background 0.2s;
}
.nexus-btn-upgrade:hover { background: var(--nexus-blue-h); }
.nexus-btn-upgrade.disabled { background: var(--nexus-border); color: var(--nexus-muted); cursor: not-allowed; }

.nexus-btn-demolish {
    display: block;
    width: 100%;
    padding: 8px;
    background: #21262d;
    color: var(--nexus-red);
    text-align: center;
    border-radius: 6px;
    font-size: 12px;
    font-weight: 600;
    text-decoration: none;
    border: 1px solid #30363d;
    cursor: pointer;
    transition: background 0.2s;
}
.nexus-btn-demolish:hover { background: #30363d; }
.nexus-btn-demolish.disabled { opacity: 0.5; cursor: not-allowed; }

/* ====== Cola de Producción (Queue) ====== */
.nexus-queue {
    background: var(--nexus-card);
    border: 1px solid var(--nexus-border);
    border-radius: 8px;
    padding: 15px;
    margin-bottom: 20px;
}
.nexus-queue h4 { margin: 0 0 10px 0; color: var(--nexus-title); font-size: 14px; }
.nexus-queue table { width: 100%; border-collapse: collapse; }
.nexus-queue td { padding: 8px; border-bottom: 1px solid var(--nexus-border); color: var(--nexus-text); font-size: 13px; }
#progressbar { background: var(--nexus-border) !important; height: 6px !important; border-radius: 3px !important; margin-top: 5px !important; }
#progressbar > div { background: var(--nexus-blue) !important; border-radius: 3px !important; }

</style>

<div class="nexus-wrap">

    {* ================== COLA DE PRODUCCIÓN ================== *}
    {if !empty($Queue)}
    <div class="nexus-queue">
        <h4>⏳ Cola de Construcción</h4>
        <table>
            {foreach $Queue as $List}
            {$ID = $List.element}
            <tr>
                <td style="width:70%;">
                    <b>{$List@iteration}. {$LNG.tech.{$ID}} {$List.level}</b>
                    {if $List@first}
                    <div id="progressbar" data-time="{$List.resttime}"></div>
                    {/if}
                </td>
                <td style="text-align:right;">
                    {if $List@first}
                    <span id="time" data-time="{$List.time}" style="color:var(--nexus-blue); font-weight:bold;"></span>
                    <form action="game.php?page=buildings" method="post" style="display:inline; margin-left:10px;">
                        <input type="hidden" name="cmd" value="cancel">
                        <button type="submit" class="nexus-btn-demolish" style="display:inline-block; width:auto; padding:4px 10px;">{$LNG.bd_cancel}</button>
                    </form>
                    {else}
                    <form action="game.php?page=buildings" method="post" style="display:inline;">
                        <input type="hidden" name="cmd" value="remove">
                        <input type="hidden" name="listid" value="{$List@iteration}">
                        <button type="submit" class="nexus-btn-demolish" style="display:inline-block; width:auto; padding:4px 10px;">{$LNG.bd_cancel}</button>
                    </form>
                    {/if}
                </td>
            </tr>
            {/foreach}
        </table>
    </div>
    {/if}

    {* ================== CABECERA SUPERIOR ================== *}
    <div class="nexus-header">
        <div class="nexus-header-top">
            <div>
                <h2 class="nexus-title">Buildings</h2>
                <span class="nexus-subtitle">AstroIO Homeworld</span>
            </div>
            <a href="game.php?page=planet" class="nexus-filter-btn" style="text-decoration:none;">🪐 Planetario</a>
        </div>
        
        {* FIX: Usando variables que SÍ existen en el template *}
        <div class="nexus-stats-bar">
            <div class="nexus-stat-item">
                <span>⏳ {count($Queue)} en cola</span>
            </div>
            {if !$RoomIsOk}
            <div class="nexus-stat-item red">
                <span>(FULL - UPGRADE EXISTING BUILDINGS)</span>
            </div>
            {/if}
        </div>
    </div>

    {* ================== BARRA DE FILTROS (VISUAL) ================== *}
    <div class="nexus-filters">
        <div class="nexus-filter-btn active">▦ All</div>
        <div class="nexus-filter-btn">⛏️ Resource</div>
        <div class="nexus-filter-btn">⚡ Energy</div>
        <div class="nexus-filter-btn">🔧 Utility</div>
        <div class="nexus-filter-btn">⚔️ Military</div>
        <div class="nexus-filter-btn">🛡️ Defense</div>
    </div>

    {* ================== GRID DE TARJETAS ================== *}
    <div class="nexus-grid">
        {foreach $BuildInfoList as $ID => $Element}
        
        {* Lógica para determinar el tag *}
        {assign var="tagClass" value="tag-utility"}
        {assign var="tagText" value="UTILITY"}
        {if $ID == 1 || $ID == 2 || $ID == 3}
            {assign var="tagClass" value="tag-resource"}
            {assign var="tagText" value="RESOURCE"}
        {elseif $ID == 4 || $ID == 12}
            {assign var="tagClass" value="tag-energy"}
            {assign var="tagText" value="ENERGY"}
        {elseif $ID == 14 || $ID == 21 || $ID == 15 || $ID == 31}
            {assign var="tagClass" value="tag-utility"}
            {assign var="tagText" value="MILITARY"}
        {elseif $ID == 44}
            {assign var="tagClass" value="tag-military"}
            {assign var="tagText" value="DEFENSE"}
        {/if}

        <div class="nexus-card">
            {* Imagen *}
            <div class="nexus-card-img" style="background-image:url('{$dpath}gebaeude/{$ID}.gif');" onclick="return Dialog.info({$ID})">
                {if $Element.level > 0}
                <div class="nexus-level">Lv. {$Element.level}{if $Element.maxLevel != 255} &rarr; {$Element.maxLevel}{/if}</div>
                {else}
                <div class="nexus-level">Lv. 0 &rarr; 1</div>
                {/if}
            </div>

            {* Contenido *}
            <div class="nexus-content">
                <h3 class="nexus-card-title" onclick="return Dialog.info({$ID})">{$LNG.tech.{$ID}}</h3>
                <span class="nexus-tag {$tagClass}">{$tagText}</span>
                
                {* Descripción corta *}
                <p class="nexus-desc">{$LNG.shortDescription.{$ID}|replace:'&quot;':''}</p>

                {* Producción (Energía) *}
                {if !empty($Element.infoEnergy)}
                <div style="font-size:12px; color:var(--nexus-muted); margin-top:5px;">
                    {$Element.infoEnergy}
                </div>
                {/if}

                {* Costos *}
                <div class="nexus-costs">
                    {foreach $Element.costResources as $RessID => $RessAmount}
                    <div class="nexus-cost-item {if $Element.costOverflow[$RessID] > 0}no{/if}" title="{$LNG.tech.{$RessID}}">
                        <span>{if $RessID == 901}🔩{elseif $RessID == 902}💎{elseif $RessID == 903}⚗️{elseif $RessID == 911}⚡{elseif $RessID == 921}🌌{elseif $RessID == 922}💰{else}▪️{/if}</span>
                        <span>{shortly_number($RessAmount)}</span>
                    </div>
                    {/foreach}
                </div>

                {* Tiempo *}
                <div class="nexus-time">
                    <span>⏱ {$LNG.fgf_time}:</span>
                    <span>
                        {assign var="totalSecs" value=$Element.elementTime}
                        {math equation="floor(s/86400)" s=$totalSecs assign="tDays"}
                        {math equation="floor((s%86400)/3600)" s=$totalSecs assign="tHours"}
                        {math equation="floor((s%3600)/60)" s=$totalSecs assign="tMinutes"}
                        {math equation="floor(s%60)" s=$totalSecs assign="tSecs"}
                        {if $tDays > 0}{$tDays}d {/if}{$tHours|string_format:"%02d"}h {$tMinutes|string_format:"%02d"}m {$tSecs|string_format:"%02d"}s
                    </span>
                </div>

                {* Botones de Acción *}
                <div class="nexus-actions">
                    {* Botón de Mejorar *}
                    {if $Element.maxLevel == $Element.levelToBuild}
                        <button class="nexus-btn-upgrade disabled">Max Level</button>
                    {elseif ($isBusy.research && ($ID == 6 || $ID == 31)) || ($isBusy.shipyard && ($ID == 15 || $ID == 21))}
                        <button class="nexus-btn-upgrade disabled">Working...</button>
                    {elseif !$RoomIsOk}
                        <button class="nexus-btn-upgrade disabled">No Fields</button>
                    {elseif $CanBuildElement && $Element.buyable}
                        <form action="game.php?page=buildings" method="post" style="margin:0;">
                            <input type="hidden" name="cmd" value="insert">
                            <input type="hidden" name="building" value="{$ID}">
                            <button type="submit" class="nexus-btn-upgrade">
                                &uarr; {if $Element.level == 0}Upgrade to Lv. 1{else}Upgrade to Lv. {$Element.levelToBuild + 1}{/if}
                            </button>
                        </form>
                    {else}
                        <button class="nexus-btn-upgrade disabled">
                            &uarr; {if $Element.level == 0}Upgrade to Lv. 1{else}Upgrade to Lv. {$Element.levelToBuild + 1}{/if}
                        </button>
                    {/if}

                    {* Botón de Demoler *}
                    {if $Element.level > 0 && $ID != 43 && ($ID != 44 || $HaveMissiles)}
                        <button class="nexus-btn-demolish" onclick="return Dialog.info({$ID}, true);">
                            &darr; Demolish Lv. {$Element.level}
                        </button>
                    {/if}
                </div>
            </div>
        </div>
        {/foreach}
    </div>
</div>

{/block}