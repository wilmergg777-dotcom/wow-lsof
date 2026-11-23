{block name="title" prepend}{$LNG.siteTitleNews}{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/login/page.news.default.tpl === *}



{literal}
<style>
/* ═══ ASTROIO v8.1 — reskin nextgen (tokens del índice v8.0) ═══ */
:root {
    --nx-muted:  #9a9a9a;
    --nx-cyan:   #59d6ff;
    --nx-green:  #35ff8f;
    --nx-red:    #ff5252;
    --nx-purple: #d946ef;
    --nx-gold:   #fbbf24;
    --nx-border: rgba(255, 255, 255, 0.1);
}

/* ═══ Tarjeta nextgen (idéntica a las del índice) ═══ */
.astronews_panel, .panel-default.astronews_panel {
    background: rgba(0, 0, 0, 0.5);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    border: 1px solid var(--nx-border);
    border-radius: 15px;
    box-shadow: 0 0 40px rgba(0, 0, 0, 0.75);
    overflow: hidden;
}
.astronews_section_title, .panel-heading.astronews_heading, .astronews_heading {
    display: block;
    background: transparent;
    color: #ffffff;
    font-family: 'Space Mono', monospace;
    font-size: 13px;
    font-weight: 700;
    letter-spacing: 2px;
    text-transform: uppercase;
    padding: 16px 20px;
    border-bottom: 1px solid var(--nx-border);
    text-shadow: none;
}
.astronews_wrap {
    font-family: 'Rajdhani', 'Segoe UI', sans-serif;
}

.astronews_wrap { max-width: 760px; margin: 84px auto 40px; padding: 0 12px; box-sizing: border-box; }
.astronews_body { padding: 18px 22px; border-bottom: 1px solid var(--nx-border); }
.astronews_body:last-child { border-bottom: none; }
.astronews_title {
    color: #ffffff;
    font-family: 'Rajdhani', sans-serif;
    font-size: 21px;
    font-weight: 700;
    letter-spacing: .5px;
    margin: 0 0 6px;
    padding-bottom: 8px;
    border-bottom: 1px solid rgba(255,255,255,.08);
    text-shadow: none;
}
.astronews_info {
    color: var(--nx-muted);
    font-family: 'Space Mono', monospace;
    font-size: 10px;
    letter-spacing: 1.5px;
    text-transform: uppercase;
    margin-bottom: 12px;
}
.astronews_text {
    color: #e2e8f0;
    font-size: 15px;
    line-height: 1.7;
    margin: 0;
    white-space: pre-wrap;
    word-wrap: break-word;
}
.astronews_empty {
    color: var(--nx-muted);
    font-size: 16px;
    font-style: italic;
    text-align: center;
    padding: 40px 20px;
    margin: 0;
}

/* ═══ Móvil ═══ */
@media (max-width: 768px) {
    .astronews_wrap { margin-top: 70px !important; padding: 0 10px !important; }
    .astronews_panel { border-radius: 12px; }
    .astronews_body { padding: 16px 14px !important; }
    .astronews_actions { text-align: center !important; }
    .astronews_actions .btn, .astronews_btn_register, .astronews_btn_submit { width: 100%; }
}
</style>
{/literal}

<div class="container astronews_wrap">
    <div class="row">
        <div class="col-lg-12">
            <div class="panel panel-default astronews_panel">
                <div class="panel-heading astronews_heading">{$LNG.siteTitleNews}</div>
                {foreach $newsList as $newsRow}
                    <div class="panel-body astronews_body">
                        <h1 class="page-header astronews_title">{$newsRow.title}</h1>
                        <div class="info astronews_info">{$newsRow.from}</div>
                        <p class="astronews_text">{$newsRow.text}</p>
                    </div>
                    {foreachelse}
                    <div class="panel-body astronews_body">
                        <h3 class="page-header astronews_empty">{$LNG.news_does_not_exist}</h3>
                    </div>
                {/foreach}
            </div>
        </div>
    </div>
</div>

{/block}