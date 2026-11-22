{block name="title" prepend}Referidos{/block}
{block name="content"}

<style>
/* Estilos originales intactos */
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
.rf-wrapper { background: var(--bg-card); backdrop-filter: blur(6px); -webkit-backdrop-filter: blur(6px); color: var(--text-main); font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; padding: 20px; border-radius: 12px; border: 1px solid var(--border-color); box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5); max-width: 1100px; margin: 0 auto; }
.rf-title { color: var(--accent-gold); font-size: 22px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; font-weight: 700; letter-spacing: 0.5px; text-shadow: 0 0 12px rgba(251, 191, 36, 0.4); }
.rf-card { background: var(--bg-card); backdrop-filter: blur(6px); -webkit-backdrop-filter: blur(6px); border: 1px solid var(--border-color); border-radius: 12px; padding: 20px; margin-bottom: 20px; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5); }
.rf-card-title { color: var(--accent-gold); font-size: 15px; margin-bottom: 15px; font-weight: 700; display: flex; align-items: center; gap: 8px; text-shadow: 0 0 8px rgba(251, 191, 36, 0.3); }
.rf-info-box { background: rgba(251, 191, 36, 0.06); backdrop-filter: blur(4px); -webkit-backdrop-filter: blur(4px); border-left: 3px solid var(--accent-gold); padding: 12px 15px; border-radius: 6px; font-size: 13px; color: var(--text-main); line-height: 1.7; }
.rf-info-box strong { color: var(--accent-gold); }
.rf-info-box .gold { color: var(--accent-gold); font-weight: 700; }
.rf-grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px; }
.rf-code-box { display: flex; align-items: center; gap: 10px; background: rgba(0, 0, 0, 0.35); backdrop-filter: blur(4px); -webkit-backdrop-filter: blur(4px); border: 1px solid var(--border-color); border-radius: 8px; padding: 15px 18px; }
.rf-code-label { font-size: 10px; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 10px; display: block; }
.rf-code-value { color: var(--accent-gold); font-family: 'Courier New', monospace; font-size: 26px; font-weight: 700; letter-spacing: 5px; flex: 1; line-height: 1.2; text-shadow: 0 0 12px rgba(251, 191, 36, 0.5); }
.rf-copy-code { background: rgba(251, 191, 36, 0.15); border: 1px solid rgba(251, 191, 36, 0.4); color: var(--accent-gold); padding: 10px 14px; border-radius: 8px; cursor: pointer; font-size: 18px; transition: all 0.25s ease; }
.rf-copy-code:hover { background: rgba(251, 191, 36, 0.3); box-shadow: 0 0 14px rgba(251, 191, 36, 0.4); transform: translateY(-2px); }
.rf-stats-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.rf-stat { background: rgba(0, 0, 0, 0.35); backdrop-filter: blur(4px); -webkit-backdrop-filter: blur(4px); border: 1px solid var(--border-color); border-radius: 8px; padding: 15px; text-align: center; }
.rf-stat-value { color: var(--accent-blue); font-size: 24px; font-weight: 800; font-family: 'Courier New', monospace; }
.rf-stat-value.gold { color: var(--accent-gold); text-shadow: 0 0 12px rgba(251, 191, 36, 0.4); }
.rf-stat-value.green { color: var(--accent-green); }
.rf-stat-label { font-size: 10px; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.5px; margin-top: 5px; }
.rf-referrer { display: flex; align-items: center; gap: 10px; padding: 12px; background: rgba(74, 255, 136, 0.08); backdrop-filter: blur(4px); -webkit-backdrop-filter: blur(4px); border: 1px solid rgba(74, 255, 136, 0.3); border-radius: 8px; color: var(--accent-green); font-size: 13px; }
.rf-referrer-icon { font-size: 20px; }
.rf-referrer strong { color: #aaffcc; }
.rf-list { display: flex; flex-direction: column; gap: 8px; }
.rf-list-item { background: rgba(0, 0, 0, 0.35); backdrop-filter: blur(4px); -webkit-backdrop-filter: blur(4px); border: 1px solid var(--border-color); border-radius: 8px; padding: 12px 15px; display: flex; align-items: center; gap: 12px; transition: all 0.25s ease; }
.rf-list-item:hover { border-color: rgba(251, 191, 36, 0.5); transform: translateX(4px); box-shadow: 0 4px 15px rgba(251, 191, 36, 0.2); }
.rf-list-icon { width: 36px; height: 36px; background: rgba(251, 191, 36, 0.1); border: 1px solid rgba(251, 191, 36, 0.3); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 16px; flex-shrink: 0; }
.rf-list-info { flex: 1; min-width: 0; }
.rf-list-name { color: var(--text-title); font-weight: 600; font-size: 13px; margin-bottom: 4px; }
.rf-list-points { font-size: 11px; color: var(--text-muted); font-family: 'Courier New', monospace; margin-top: 3px; }
.rf-list-date { font-size: 10px; color: var(--text-muted); font-family: 'Courier New', monospace; flex-shrink: 0; }
.rf-empty { text-align: center; padding: 40px 20px; color: var(--text-muted); font-size: 13px; }
.rf-empty-icon { font-size: 48px; opacity: 0.3; margin-bottom: 10px; }

/* ESTILOS DE RECOMPENSAS */
.rf-reward-item { background: rgba(0, 0, 0, 0.35); border: 1px solid var(--border-color); border-radius: 8px; padding: 15px; display: flex; flex-direction: column; gap: 10px; transition: all 0.25s ease; margin-bottom: 10px; }
.rf-reward-item:hover { border-color: rgba(251, 191, 36, 0.5); box-shadow: 0 4px 15px rgba(251, 191, 36, 0.2); }
.rf-reward-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px dashed var(--border-color); padding-bottom: 10px; }
.rf-reward-meta { font-size: 14px; font-weight: 700; color: var(--accent-gold); text-shadow: 0 0 8px rgba(251, 191, 36, 0.3); }
.rf-reward-time { font-size: 11px; color: var(--text-muted); }
.rf-reward-badges { display: flex; flex-wrap: wrap; gap: 8px; }
.rf-badge { background: rgba(251, 191, 36, 0.1); border: 1px solid rgba(251, 191, 36, 0.3); color: var(--text-main); padding: 4px 10px; border-radius: 4px; font-size: 12px; }
.rf-badge strong { color: var(--accent-gold); }

/* BOTÓN VER MÁS */
.rf-btn-more { display: block; width: 100%; text-align: center; padding: 10px; background: rgba(59, 130, 246, 0.2); border: 1px solid rgba(59, 130, 246, 0.5); color: var(--accent-blue); border-radius: 8px; cursor: pointer; font-weight: bold; font-size: 13px; transition: all 0.2s; margin-top: 10px; }
.rf-btn-more:hover { background: rgba(59, 130, 246, 0.4); color: #fff; box-shadow: 0 0 10px rgba(59, 130, 246, 0.4); }

@media (max-width: 700px) { .rf-grid-2 { grid-template-columns: 1fr; } .rf-code-value { font-size: 20px; letter-spacing: 3px; } }
</style>

<div class="rf-wrapper">

    <div class="rf-title">&#128279; Programa de Referidos</div>

    <!-- CÓMO FUNCIONA -->
    <div class="rf-card">
        <div class="rf-card-title">&#127873; Cómo Funciona</div>
        <div class="rf-info-box">
            Compartí tu <strong class="gold">código de referido</strong> con otros jugadores. Ganás comisiones del 3% en NTX-20 y recompensas exclusivas cuando tus referidos alcancen los puntos requeridos.
        </div>
    </div>

    <!-- METAS DE RECOMPENSAS -->
    <div class="rf-card">
        <div class="rf-card-title">&#127919; Metas de Recompensas</div>
        
        {if !empty($active_rewards)}
            <div class="rf-list">
                {foreach $active_rewards as $reward}
                    <div class="rf-reward-item">
                        <div class="rf-reward-header">
                            <div class="rf-reward-meta">Al alcanzar {$reward.points_required} Puntos</div>
                            <div class="rf-reward-time">
                                {if $reward.is_permanent == 1}
                                    <span style="color: var(--accent-green);">&#9989; Permanente</span>
                                {else}
                                    <span style="color: var(--accent-red);">&#9203; Finaliza: {$reward.end_date}</span>
                                {/if}
                            </div>
                        </div>
                        <div class="rf-reward-badges">
                            {foreach $reward.rewards as $item}
                                <div class="rf-badge">
                                    <strong>{$item.amount}</strong> {$item.type}
                                </div>
                            {/foreach}
                        </div>
                        <!-- ESTADO DE LA RECOMPENSA -->
                        <div style="margin-top: 5px; font-size: 12px; font-weight: bold;">
                            {if $reward.status == 'claimed'}
                                <span style="color: var(--accent-green);">&#9989; Recompensa ya obtenida por uno de tus referidos.</span>
                            {elseif $reward.status == 'ready'}
                                <span style="color: var(--accent-gold);">&#8987; ¡Meta alcanzada! Esperando pago automático (se procesa en minutos)...</span>
                            {else}
                                <span style="color: var(--accent-red);">&#128274; En progreso. Te faltan {$reward.missing_pts} puntos (máximo de tus referidos).</span>
                            {/if}
                        </div>
                    </div>
                {/foreach}
            </div>
        {else}
            <div class="rf-empty">
                <div class="rf-empty-icon">&#128230;</div>
                No hay recompensas por referidos activas en este momento.
            </div>
        {/if}
    </div>

    <!-- CÓDIGO + ESTADÍSTICAS -->
    <div class="rf-grid-2">
        <div class="rf-card">
            <div class="rf-card-title">&#128100; Tu Código de Referido</div>
            <div class="rf-code-box">
                <div style="flex: 1;">
                    <span class="rf-code-label">Código de Referido</span>
                    <div class="rf-code-value">{$ref_code}</div>
                </div>
                <button class="rf-copy-code" onclick="rfCopyCode('{$ref_code}')" title="Copiar código">&#128203;</button>
            </div>
        </div>

        <div class="rf-card">
            <div class="rf-card-title">&#128202; Estadísticas</div>
            <div class="rf-stats-grid">
                <div class="rf-stat">
                    <div class="rf-stat-value">{$total_referrals}</div>
                    <div class="rf-stat-label">Jugadores Referidos</div>
                </div>
                <div class="rf-stat">
                    <div class="rf-stat-value green">{$paid_referrals}</div>
                    <div class="rf-stat-label">Referidos Activos</div>
                </div>
                <div class="rf-stat" style="grid-column: span 2;">
                    <div class="rf-stat-value gold">{$total_earned}</div>
                    <div class="rf-stat-label">Total Ganado (NTX-20)</div>
                </div>
            </div>
        </div>
    </div>

    <!-- QUIÉN TE INVITÓ -->
    <div class="rf-card">
        <div class="rf-card-title">&#128101; ¿Quién te invitó?</div>
        {if $has_referrer}
            <div class="rf-referrer">
                <span class="rf-referrer-icon">&#9989;</span>
                <span>Fuiste referido por <strong>{$referrer_name}</strong></span>
            </div>
        {else}
            <div class="rf-info-box">
                No fuiste referido por nadie. Cuando te registres con el código de otro jugador, aparecerá acá.
            </div>
        {/if}
    </div>

    <!-- LISTAS -->
    <div class="rf-grid-2">
        <!-- JUGADORES REFERIDOS -->
        <div class="rf-card">
            <div class="rf-card-title">&#128101; Jugadores Referidos</div>

            {if count($referrals) > 0}
                <div class="rf-list">
                    {foreach $referrals as $ref}
                        <div class="rf-list-item">
                            <div class="rf-list-icon">&#128100;</div>
                            <div class="rf-list-info">
                                <div class="rf-list-name">{$ref.username}</div>
                                <div class="rf-list-points">{$ref.points} pts</div>
                            </div>
                        </div>
                    {/foreach}
                </div>

                <!-- BOTÓN PARA VER LOS DEMÁS -->
                {if $has_more_refs}
                    <div id="hidden_refs" style="display: none; margin-top: 8px; flex-direction: column; gap: 8px;">
                        {foreach $more_referrals as $ref}
                            <div class="rf-list-item">
                                <div class="rf-list-icon">&#128100;</div>
                                <div class="rf-list-info">
                                    <div class="rf-list-name">{$ref.username}</div>
                                    <div class="rf-list-points">{$ref.points} pts</div>
                                </div>
                            </div>
                        {/foreach}
                    </div>
                    <button class="rf-btn-more" id="btn_more_refs" onclick="toggleMoreRefs()">Ver todos los referidos</button>
                {/if}

            {else}
                <div class="rf-empty">
                    <div class="rf-empty-icon">&#128101;</div>
                    Aún no tenés referidos.
                </div>
            {/if}
        </div>

        <!-- COMISIONES RECIENTES -->
        <div class="rf-card">
            <div class="rf-card-title">&#128176; Comisiones Recientes</div>

            {if count($commissions) > 0}
                <div class="rf-list">
                    {foreach $commissions as $com}
                        <div class="rf-list-item">
                            <div class="rf-list-icon">&#128176;</div>
                            <div class="rf-list-info">
                                <div class="rf-list-name">{$com.username}</div>
                                <div class="rf-list-points">+{$com.amount} NTX-20</div>
                            </div>
                            <div class="rf-list-date">{$com.fecha}</div>
                        </div>
                    {/foreach}
                </div>
            {else}
                <div class="rf-empty">
                    <div class="rf-empty-icon">&#128176;</div>
                    Aún no tenés comisiones.
                </div>
            {/if}
        </div>
    </div>

</div>

<script>
function rfCopyCode(code) {
    if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(code).then(function() {
            alert('C\u00f3digo copiado: ' + code);
        }).catch(function() {
            prompt('Copi\u00e1 el c\u00f3digo manualmente:', code);
        });
    } else {
        prompt('Copi\u00e1 el c\u00f3digo manualmente:', code);
    }
}

function toggleMoreRefs() {
    var hidden = document.getElementById('hidden_refs');
    var btn = document.getElementById('btn_more_refs');
    if (hidden.style.display === 'none') {
        hidden.style.display = 'flex';
        btn.innerText = 'Ocultar referidos';
    } else {
        hidden.style.display = 'none';
        btn.innerText = 'Ver todos los referidos';
    }
}
</script>

{/block}