{block name="title" prepend}{$LNG.siteTitleScreens}{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/login/page.screens.default.tpl === *}



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

.astroscr_wrap { max-width: 900px; margin: 84px auto 40px; padding: 0 12px; box-sizing: border-box; font-family: 'Rajdhani', 'Segoe UI', sans-serif; }
.astroscr_panel {
    background: rgba(0,0,0,.5); backdrop-filter: blur(10px); -webkit-backdrop-filter: blur(10px);
    border: 1px solid var(--nx-border); border-radius: 15px;
    box-shadow: 0 0 40px rgba(0,0,0,.75); overflow: hidden;
}
.astroscr_heading {
    display: block; background: transparent; color: #ffffff;
    font-family: 'Space Mono', monospace; font-size: 13px; font-weight: 700;
    letter-spacing: 2px; text-transform: uppercase;
    padding: 16px 20px; border-bottom: 1px solid var(--nx-border); text-shadow: none;
}
.astroscr_body { padding: 18px 20px; color: #e2e8f0; }
.astroscr_grid {
    display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: 14px; margin-top: 12px;
}
.astroscr_item {
    margin: 0; background: rgba(255,255,255,.03);
    border: 1px solid var(--nx-border); border-radius: 12px;
    overflow: hidden; transition: .2s ease;
}
.astroscr_item:hover { border-color: rgba(255,255,255,.28); transform: translateY(-2px); box-shadow: 0 8px 24px rgba(0,0,0,.5); }
.astroscr_item img { display: block; width: 100%; max-width: 100%; height: auto; border: none; border-radius: 0; }

/* ═══ Móvil ═══ */
@media (max-width: 768px) {
    .astroscr_wrap { margin-top: 70px !important; padding: 0 10px !important; }
    .astroscr_panel { border-radius: 12px; }
    .astroscr_body { padding: 16px 14px !important; }
    .astroscr_actions { text-align: center !important; }
    .astroscr_actions .btn, .astroscr_btn_register, .astroscr_btn_submit { width: 100%; }
}
</style>
{/literal}

<div class="container astroscr_wrap">
    <div class="panel panel-default astroscr_panel">
        <div class="panel-heading astroscr_heading">{$LNG.siteTitleScreens}</div>
        <div class="panel-body astroscr_body">
            <div class="row astroscr_grid">
            {foreach $screenshots as $screenshot}
                <div class="col-lg-4 astroscr_item">
                    <a class="gallery" href="{$screenshot.path}" target="_blank" rel="gallery">
                        <img src="{$screenshot.thumbnail}" alt="" width="120" height="120" class="img-rounded">
                    </a>
                </div>
            {/foreach}
            </div>
        </div>
    </div>
</div>

{/block}
{block name="script"}
<script>
$(function() {
	$(".gallery").fancybox();
});
</script>
{/block}