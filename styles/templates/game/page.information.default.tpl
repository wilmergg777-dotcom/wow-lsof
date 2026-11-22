{block name="title" prepend}{$LNG.lm_info}{/block}
{block name="content"}

{* ==========================================================
   ASTROIO — Information Popup v4.0 (Flexbox Edition)
   FIX v4.0:
     - Se eliminaron las tablas de layout (causaban que el texto desapareciera).
     - Se usó Flexbox para forzar Imagen + Texto lado a lado.
     - El texto ahora ocupa todo el espacio disponible a la derecha.
   ========================================================== *}

<style>
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

/* ─── RESET GLOBAL ─── */
.astroinfopop_wrap,
.astroinfopop_wrap *,
.astroinfopop_wrap *::before,
.astroinfopop_wrap *::after {
    box-sizing: border-box;
}

.astroinfopop_wrap {
    display: flex;
    justify-content: center;
    padding: 20px 15px;
    font-family: 'Segoe UI', Arial, sans-serif;
}

/* ─── BOX PRINCIPAL ─── */
.astroinfopop_box {
    max-width: 720px;
    width: 100%;
    background: var(--bg-card);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    border: 2px solid rgba(0, 224, 255, 0.4);
    border-radius: 14px;
    box-shadow:
        0 8px 30px rgba(0, 0, 0, 0.6),
        0 0 40px rgba(0, 224, 255, 0.08),
        inset 0 0 20px rgba(0, 224, 255, 0.03);
    overflow: hidden;
}

/* ─── Cabecera ─── */
.astroinfopop_header {
    background: linear-gradient(135deg, #0a5a8c 0%, #00a8e0 100%);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-bottom: 1px solid var(--accent-cyan);
    padding: 12px 18px;
}
.astroinfopop_title {
    color: #ffffff;
    font-size: 13px;
    font-weight: 700;
    letter-spacing: 1.5px;
    text-transform: uppercase;
    text-shadow: 0 1px 3px rgba(0, 0, 0, 0.5), 0 0 10px rgba(0, 224, 255, 0.4);
}

/* ─── Contenido ─── */
.astroinfopop_content {
    padding: 16px;
    color: var(--text-main);
    font-size: 12px;
    line-height: 1.5;
}

/* ─── FLEXBOX: Imagen + Descripción lado a lado ─── */
.astroinfopop_top_flex {
    display: flex;
    gap: 15px;
    align-items: flex-start;
    margin-bottom: 15px;
}
.astroinfopop_img_box {
    flex-shrink: 0;
    width: 120px;
}
.astroinfopop_img {
    width: 120px;
    height: 120px;
    border: 1px solid rgba(0, 204, 255, 0.3);
    border-radius: 8px;
    background: rgba(0, 0, 0, 0.3);
    padding: 4px;
    transition: all 0.25s ease;
    display: block;
}
.astroinfopop_img:hover {
    border-color: var(--accent-cyan);
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.5);
    transform: translateY(-2px);
}
.astroinfopop_desc_box {
    flex-grow: 1;
    display: flex;
    flex-direction: column;
    gap: 10px;
}
.astroinfopop_desc {
    margin: 0;
    color: var(--text-main);
    line-height: 1.6;
    text-align: justify;
    font-size: 13px;
}

/* ─── Bonus ─── */
.astroinfopop_bonus {
    margin: 0;
    padding: 8px 10px;
    background: rgba(0, 224, 255, 0.06);
    border-left: 3px solid var(--accent-cyan);
    border-radius: 6px;
    color: var(--text-main);
    font-size: 12px;
    line-height: 1.6;
}
.astroinfopop_bonus_title {
    color: var(--accent-cyan);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-size: 11px;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.4);
}

/* ─── Fuego rápido ─── */
.astroinfopop_rapidfire {
    margin: 0;
    padding: 8px 10px;
    background: rgba(251, 191, 36, 0.05);
    border-left: 3px solid var(--accent-gold);
    border-radius: 6px;
    color: var(--text-main);
    font-size: 11.5px;
    line-height: 1.6;
}
.astroinfopop_rf_to {
    color: var(--accent-green);
    font-weight: bold;
    font-family: 'Courier New', monospace;
}
.astroinfopop_rf_from {
    color: var(--accent-red);
    font-weight: bold;
    font-family: 'Courier New', monospace;
}

/* ─── Override para las tablas compartidas ─── */
.astroinfopop_content table {
    background: rgba(15, 22, 36, 0.6) !important;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border-collapse: collapse;
    border: 1px solid rgba(0, 224, 255, 0.2) !important;
    border-radius: 8px;
    margin-top: 10px;
    width: 100%;
    overflow: hidden;
}
.astroinfopop_content table th,
.astroinfopop_content table thead th {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85)) !important;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    color: #ffffff !important;
    border-bottom: 1px solid var(--accent-cyan) !important;
    padding: 7px 10px !important;
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astroinfopop_content table td {
    color: var(--text-main) !important;
    border-bottom: 1px solid rgba(0, 224, 255, 0.1) !important;
    padding: 6px 10px !important;
    font-size: 11.5px;
}
.astroinfopop_content table tr:hover td {
    background: rgba(0, 224, 255, 0.05) !important;
}

/* ─── RESPONSIVE ─── */
@media (max-width: 720px) {
    .astroinfopop_top_flex {
        flex-direction: column; /* En móviles se pone uno encima de otro */
        align-items: center;
        text-align: center;
    }
    .astroinfopop_img_box {
        width: 100px;
    }
    .astroinfopop_img {
        width: 100px;
        height: 100px;
        margin: 0 auto;
    }
    .astroinfopop_content table th,
    .astroinfopop_content table td {
        padding: 5px 6px !important;
        font-size: 10.5px;
    }
}
</style>

<div class="astroinfopop_wrap">
    <div class="astroinfopop_box">

        {* ─── Cabecera ─── *}
        <div class="astroinfopop_header">
            <div class="astroinfopop_title">{$LNG.tech.$elementID}</div>
        </div>

        {* ─── Contenido principal ─── *}
        <div class="astroinfopop_content">

            {* ─── FLEXBOX: Imagen y Texto ─── *}
            <div class="astroinfopop_top_flex">
                
                {* Columna Izquierda: Imagen *}
                <div class="astroinfopop_img_box">
                    <img class="astroinfopop_img"
                         src="{$dpath}gebaeude/{$elementID}.{if $elementID >=600 && $elementID <= 699}jpg{else}gif{/if}"
                         alt="">
                </div>

                {* Columna Derecha: Textos y Bonus *}
                <div class="astroinfopop_desc_box">
                    <p class="astroinfopop_desc">{$LNG.longDescription.$elementID}</p>

                    {if !empty($Bonus)}
                    <div class="astroinfopop_bonus">
                        <b class="astroinfopop_bonus_title">{$LNG.in_bonus}</b><br>
                        {foreach $Bonus as $BonusName => $elementBouns}
                            {if $elementBouns[0] < 0}-{else}+{/if}{if $elementBouns[1] == 0}{abs($elementBouns[0] * 100)}%{else}{floatval($elementBouns[0])}{/if} {$LNG.bonus.$BonusName}<br>
                        {/foreach}
                    </div>
                    {/if}

                    {if !empty($FleetInfo)}
                        {if !empty($FleetInfo.rapidfire.to)}
                        <div class="astroinfopop_rapidfire">
                            {foreach $FleetInfo.rapidfire.to as $rapidfireID => $shoots}
                                {$LNG.in_rf_again} {$LNG.tech.$rapidfireID}: <span class="astroinfopop_rf_to">{$shoots|number}</span><br>
                            {/foreach}
                        </div>
                        {/if}
                        {if !empty($FleetInfo.rapidfire.from)}
                        <div class="astroinfopop_rapidfire">
                            {foreach $FleetInfo.rapidfire.from as $rapidfireID => $shoots}
                                {$LNG.in_rf_from} {$LNG.tech.$rapidfireID}: <span class="astroinfopop_rf_from">{$shoots|number}</span><br>
                            {/foreach}
                        </div>
                        {/if}
                    {/if}
                </div>

            </div>

            {* ─── Tablas compartidas (Producción, Almacenamiento, etc.) ─── *}
            {if !empty($productionTable.production)}
            {include file="shared.information.production.tpl"}
            {/if}
            {if !empty($productionTable.storage)}
            {include file="shared.information.storage.tpl"}
            {/if}
            {if !empty($FleetInfo)}
            {include file="shared.information.shipInfo.tpl"}
            {/if}
            {if !empty($gateData)}
            {include file="shared.information.gate.tpl"}
            {/if}
            {if !empty($MissileList)}
            {include file="shared.information.missiles.tpl"}
            {/if}

        </div>
    </div>
</div>

{/block}