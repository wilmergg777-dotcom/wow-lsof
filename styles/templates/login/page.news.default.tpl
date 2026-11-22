{block name="title" prepend}{$LNG.siteTitleNews}{/block}
{block name="content"}

<style>
/* ═══════════════════════════════════════════════
   AstroIO v3.0 — Página de Noticias (Login)
   Prefijo: .astronews_
   Acento: 🔷 Cyan (#00e0ff)
   FIX v3.0:
     - Glassmorphism real (backdrop-filter + rgba)
     - border-radius 12px
     - Variables --bg-card / --accent-cyan unificadas
     - Todos los IDs/names/Smarty intactos
   ═══════════════════════════════════════════════ */

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

.astronews_wrap {
    max-width: 1100px;
    margin: 80px auto 20px;
    padding: 0 10px;
    box-sizing: border-box;
    font-family: 'Segoe UI', Roboto, sans-serif;
}

.astronews_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    overflow: hidden;
}

.astronews_heading {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-bottom: 1px solid var(--accent-cyan);
    color: #ffffff;
    font-size: 12px;
    font-weight: 700;
    padding: 10px 16px;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    text-shadow: 0 1px 3px rgba(0, 0, 0, 0.4);
}

.astronews_body {
    padding: 16px 20px;
    border-bottom: 1px solid var(--border-color);
}

.astronews_body:last-child {
    border-bottom: none;
}

.astronews_title {
    color: var(--accent-cyan);
    font-size: 20px;
    font-weight: 700;
    margin: 0 0 8px;
    padding-bottom: 8px;
    border-bottom: 1px solid var(--border-color);
    letter-spacing: 0.5px;
}

.astronews_info {
    color: var(--text-muted);
    font-size: 11px;
    font-style: italic;
    margin-bottom: 12px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.astronews_text {
    color: var(--text-main);
    font-size: 13px;
    line-height: 1.7;
    margin: 0;
    white-space: pre-wrap;
    word-wrap: break-word;
}

.astronews_empty {
    color: var(--text-muted);
    font-size: 16px;
    font-style: italic;
    text-align: center;
    padding: 40px 20px;
    margin: 0;
}

@media (max-width: 768px) {
    .astronews_wrap {
        margin-top: 70px;
        padding: 0 6px;
    }
    .astronews_body {
        padding: 12px 14px;
    }
    .astronews_title {
        font-size: 17px;
    }
    .astronews_text {
        font-size: 12.5px;
    }
}
</style>

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