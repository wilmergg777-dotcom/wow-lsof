{block name="content"}
{* ============================================================
   ASTROIO v2.6 — ARBOL DE TALENTOS DE RAZA (estilo WoW)
   - 6 talentos por raza en 3 filas: 3 / 2 / 1
   - 11 puntos para repartir (max 3 por talento)
   - Fila 2 desbloquea con {$gate_2} pts en fila 1; fila 3 con {$gate_3} pts en fila 2
   - Cambiar de raza borra TODO el arbol
   ============================================================ *}

{literal}
<style>
/* ============ ASTROIO v2.6 — TALENTOS DE RAZA ============ */
.rtln_wrap { max-width: 1180px; margin: 0 auto; padding: 4px 6px 24px; }

.rtln_nav { display: flex; gap: 9px; margin-bottom: 14px; flex-wrap: wrap; }
.rtln_nav a {
  display: inline-flex; align-items: center; gap: 7px; padding: 8px 15px; border-radius: 10px;
  font-size: 11px; font-weight: 700; color: #00e0ff; text-decoration: none;
  background: rgba(0,224,255,.07); border: 1px solid rgba(0,224,255,.3); transition: .2s ease;
}
.rtln_nav a:hover { background: rgba(0,224,255,.15); color: #fff; box-shadow: 0 0 14px rgba(0,224,255,.3); }

.rtln_msg { padding: 11px 15px; border-radius: 11px; font-size: 11.5px; font-weight: 700; margin-bottom: 14px; display: flex; align-items: center; gap: 9px; }
.rtln_msg_ok { background: rgba(17,136,51,.16); border: 1px solid rgba(102,255,153,.45); color: #8affb4; }
.rtln_msg_err { background: rgba(153,34,51,.16); border: 1px solid rgba(255,102,102,.45); color: #ffb4b4; }

/* HERO */
.rtln_hero {
  position: relative; overflow: hidden;
  background: linear-gradient(135deg, rgba(6,20,38,.92) 0%, rgba(9,32,63,.88) 45%, rgba(4,14,28,.95) 100%);
  border: 1px solid rgba(0,224,255,.22); border-radius: 16px; padding: 18px 22px;
  box-shadow: 0 10px 30px rgba(0,0,0,.45), inset 0 1px 0 rgba(255,255,255,.05);
}
.rtln_hero_row { display: flex; align-items: center; gap: 14px; flex-wrap: wrap; }
.rtln_hero_icon {
  width: 52px; height: 52px; flex: 0 0 52px; border-radius: 14px;
  display: flex; align-items: center; justify-content: center; font-size: 22px; color: #fff;
  background: linear-gradient(145deg, rgba(0,224,255,.16), rgba(0,224,255,.05));
  border: 1px solid rgba(0,224,255,.4); box-shadow: 0 0 18px rgba(0,224,255,.25);
  font-weight: 800; letter-spacing: 1px; font-size: 12px;
}
.rtln_hero_title { flex: 1; min-width: 220px; }
.rtln_hero_title h2 { margin: 0 0 4px; font-size: 18px; color: #fff; letter-spacing: .5px; text-shadow: 0 1px 3px rgba(0,0,0,.6); }
.rtln_hero_title .sub { font-size: 11px; color: #7fb6d9; }
.rtln_hero_title .sub b { color: #00e0ff; }

.rtln_pts { display: flex; gap: 9px; flex-wrap: wrap; margin-top: 14px; }
.rtln_pt {
  flex: 1; min-width: 130px; background: rgba(0,0,0,.4); border: 1px solid rgba(30,41,59,.9);
  border-radius: 12px; padding: 10px 13px; text-align: center;
}
.rtln_pt .lbl { font-size: 9px; text-transform: uppercase; letter-spacing: .8px; color: #8aa5bd; }
.rtln_pt .val { font-size: 17px; font-weight: 800; margin-top: 4px; color: #fff; }

.rtln_warn {
  margin-top: 12px; padding: 9px 13px; border-radius: 10px; font-size: 10.5px;
  background: rgba(239,68,68,.1); border: 1px solid rgba(239,68,68,.4); color: #ffb4b4;
}

/* BOX */
.rtln_box {
  background: linear-gradient(170deg, rgba(11,20,36,.8), rgba(7,13,25,.88));
  border: 1px solid rgba(30,41,59,.95); border-radius: 14px; padding: 16px 18px;
  box-shadow: 0 6px 20px rgba(0,0,0,.35); margin-top: 14px;
}
.rtln_title { font-size: 13px; font-weight: 800; color: #fff; letter-spacing: .5px; margin-bottom: 6px; display: flex; align-items: center; gap: 8px; }
.rtln_title i { color: #fbbf24; }
.rtln_subtitle { font-size: 10.5px; color: #7d95ab; line-height: 1.5; }

/* ARBOL */
.rtln_tree {
  margin-top: 14px; padding: 22px 16px 18px;
  background:
    radial-gradient(circle at 50% 0%, rgba(251,191,36,.06) 0%, transparent 45%),
    radial-gradient(circle at 50% 100%, rgba(0,120,200,.08) 0%, transparent 55%),
    linear-gradient(180deg, rgba(4,10,20,.95), rgba(2,6,12,.98));
  border: 1px solid rgba(30,41,59,.95); border-radius: 14px;
  box-shadow: inset 0 0 60px rgba(0,0,0,.55);
}
.rtln_rowlabel {
  text-align: center; margin: 0 auto 6px; display: inline-flex; align-items: center; gap: 10px;
  padding: 5px 14px; border-radius: 999px; background: rgba(0,0,0,.45);
  border: 1px solid rgba(30,41,59,.95); font-size: 9.5px; color: #8aa5bd;
}
.rtln_rowlabel .rn { font-size: 11px; font-weight: 800; color: #fbbf24; }
.rtln_rowlabel.open { border-color: rgba(102,255,153,.4); }
.rtln_rowlabel.open .st { color: #66ff99; font-weight: 700; }
.rtln_rowlabel.closed .st { color: #ff9966; font-weight: 700; }
.rtln_rowwrap { text-align: center; }

.rtln_nodes { display: flex; justify-content: center; gap: 14px; flex-wrap: nowrap; }
.rtln_node { position: relative; text-align: center; width: 150px; padding-bottom: 6px; }

/* Conector */
.rtln_node .linkdown {
  position: absolute; left: 50%; top: 66px; width: 3px; height: 24px;
  transform: translateX(-50%); border-radius: 2px;
  background: rgba(148,163,184,.22);
}
.rtln_node .linkdown.gold { background: linear-gradient(180deg, #fbbf24, #d99a1b); box-shadow: 0 0 8px rgba(251,191,36,.7); }
.rtln_node .linkdown.half { background: linear-gradient(180deg, #fbbf24, rgba(251,191,36,.25)); }
.rtln_rowwrap.lastrow .rtln_node .linkdown { display: none; }

/* Nodo cuadrado */
.rtln_sq {
  position: relative; width: 58px; height: 58px; margin: 0 auto; border-radius: 12px;
  display: flex; align-items: center; justify-content: center; font-size: 21px;
  background: linear-gradient(160deg, rgba(22,32,50,.95), rgba(10,16,28,.98));
  border: 2px solid #334155; box-shadow: 0 4px 12px rgba(0,0,0,.5);
  transition: transform .15s ease, box-shadow .2s ease, border-color .2s ease;
}
.rtln_node:hover .rtln_sq { transform: translateY(-2px) scale(1.05); }
.rtln_node.selected .rtln_sq {
  border-color: #fbbf24;
  box-shadow: 0 0 18px rgba(251,191,36,.55), inset 0 0 12px rgba(251,191,36,.2);
  background: linear-gradient(160deg, rgba(60,44,8,.95), rgba(26,20,4,.98));
}
.rtln_node.available .rtln_sq {
  border-color: #00e0ff;
  box-shadow: 0 0 16px rgba(0,224,255,.45), inset 0 0 10px rgba(0,224,255,.12);
  animation: rtln_pulse 1.8s ease-in-out infinite;
}
@keyframes rtln_pulse {
  0%, 100% { box-shadow: 0 0 10px rgba(0,224,255,.3), inset 0 0 8px rgba(0,224,255,.1); }
  50%      { box-shadow: 0 0 22px rgba(0,224,255,.6), inset 0 0 14px rgba(0,224,255,.2); }
}
.rtln_node.locked .rtln_sq { filter: grayscale(1) brightness(.55); }
.rtln_node.locked .nname, .rtln_node.locked .nef, .rtln_node.locked .pips { opacity: .45; }

.rtln_sq form { position: absolute; inset: 0; margin: 0; }
.rtln_sq button.pick {
  position: absolute; inset: 0; width: 100%; height: 100%; border-radius: 10px;
  background: transparent; border: none; cursor: pointer; font-size: 21px; color: inherit;
}
.rtln_sq button.pick:hover { background: rgba(0,224,255,.14); }

/* Pips de puntos */
.pips { display: flex; justify-content: center; gap: 4px; margin-top: 6px; height: 9px; }
.pip { width: 9px; height: 9px; border-radius: 50%; background: rgba(148,163,184,.25); border: 1px solid rgba(148,163,184,.4); }
.pip.on { background: linear-gradient(135deg, #d99a1b, #fbbf24); border-color: #fbbf24; box-shadow: 0 0 6px rgba(251,191,36,.6); }

/* Boton quitar */
.rmv {
  display: inline-flex; align-items: center; justify-content: center; gap: 4px;
  margin-top: 5px; padding: 3px 10px; border-radius: 999px; cursor: pointer; font-family: inherit;
  font-size: 8.5px; font-weight: 800; color: #ff9966; text-transform: uppercase; letter-spacing: .4px;
  background: rgba(255,153,102,.08); border: 1px solid rgba(255,153,102,.4); transition: .2s ease;
}
.rmv:hover { background: rgba(255,153,102,.2); color: #fff; }
.rmvghost { visibility: hidden; }

/* Textos */
.nname { font-size: 10.5px; font-weight: 800; color: #e2e8f0; margin-top: 7px; line-height: 1.25; }
.nef { font-size: 9px; color: #8aa5bd; margin-top: 2px; line-height: 1.35; }
.ndesc { font-size: 8.5px; color: #64748b; margin-top: 2px; line-height: 1.35; }
.nstate { font-size: 8.5px; font-weight: 800; text-transform: uppercase; letter-spacing: .4px; margin-top: 4px; }
.nstate.ok { color: #fbbf24; }
.nstate.can { color: #00e0ff; }
.nstate.max { color: #66ff99; }
.nstate.no { color: #5a6a7a; }

/* Tooltip */
.rtln_tip {
  position: absolute; left: 50%; bottom: calc(100% + 10px); transform: translateX(-50%) translateY(4px);
  min-width: 180px; max-width: 240px; padding: 9px 11px; border-radius: 10px;
  background: linear-gradient(170deg, rgba(9,18,34,.98), rgba(5,10,20,.98));
  border: 1px solid rgba(251,191,36,.4); box-shadow: 0 10px 26px rgba(0,0,0,.6);
  font-size: 10px; color: #cbd5e1; text-align: left; line-height: 1.5;
  opacity: 0; pointer-events: none; transition: opacity .18s ease, transform .18s ease;
  z-index: 30;
}
.rtln_tip .tt { font-size: 11px; font-weight: 800; color: #fff; margin-bottom: 3px; }
.rtln_tip .tv { color: #fbbf24; }
.rtln_tip .ts { margin-top: 4px; font-size: 9px; color: #8aa5bd; }
.rtln_node:hover .rtln_tip { opacity: 1; transform: translateX(-50%) translateY(0); }
.rtln_node:first-child .rtln_tip { left: 0; transform: translateX(0) translateY(4px); }
.rtln_node:first-child:hover .rtln_tip { transform: translateX(0) translateY(0); }
.rtln_node:last-child .rtln_tip { left: auto; right: 0; transform: translateX(0) translateY(4px); }
.rtln_node:last-child:hover .rtln_tip { transform: translateX(0) translateY(0); }

/* Leyenda */
.rtln_legend { display: flex; gap: 16px; flex-wrap: wrap; justify-content: center; margin-top: 16px; padding-top: 12px; border-top: 1px dashed rgba(30,41,59,.9); }
.rtln_legend .li { display: inline-flex; align-items: center; gap: 7px; font-size: 9.5px; color: #8aa5bd; }
.rtln_legend .dot { width: 12px; height: 12px; border-radius: 4px; border: 2px solid #334155; background: #10192b; }
.rtln_legend .dot.g { border-color: #fbbf24; background: rgba(251,191,36,.25); box-shadow: 0 0 8px rgba(251,191,36,.5); }
.rtln_legend .dot.c { border-color: #00e0ff; box-shadow: 0 0 8px rgba(0,224,255,.5); }
.rtln_legend .dot.k { filter: grayscale(1) brightness(.55); }

/* Bonus */
.rtln_bonusgrid { display: grid; grid-template-columns: repeat(auto-fit, minmax(170px, 1fr)); gap: 9px; margin-top: 10px; }
.rtln_bonus {
  background: rgba(0,0,0,.4); border: 1px solid rgba(30,41,59,.9); border-radius: 11px;
  padding: 10px 11px; text-align: center;
}
.rtln_bonus .lbl { font-size: 9px; text-transform: uppercase; letter-spacing: .8px; color: #8aa5bd; }
.rtln_bonus .v { font-size: 14px; font-weight: 800; margin-top: 4px; }

@media (max-width: 760px) {
  .rtln_hero { padding: 14px; }
  .rtln_nodes { gap: 4px; }
  .rtln_node { width: 31%; }
  .rtln_sq { width: 46px; height: 46px; font-size: 16px; border-radius: 10px; }
  .rtln_node .linkdown { top: 48px; height: 16px; }
  .nname { font-size: 8px; }
  .nef, .ndesc { display: none; }
  .rtln_tip { display: none; }
  .rtln_rowlabel { font-size: 8px; gap: 6px; }
}
</style>
{/literal}

<div class="rtln_wrap">

    {* ============ NAVEGACION ============ *}
    <div class="rtln_nav">
        <a href="game.php?page=race"><i class="fas fa-space-shuttle"></i> Volver a Razas</a>
        <a href="game.php?page=overview"><i class="fas fa-arrow-left"></i> Base</a>
    </div>

    {* ============ MENSAJES ============ *}
    {if $message}
        <div class="rtln_msg {if $msgType == 'ok'}rtln_msg_ok{else}rtln_msg_err{/if}">
            <i class="fas {if $msgType == 'ok'}fa-check-circle{else}fa-exclamation-circle{/if}"></i>
            <span>{$message}</span>
        </div>
    {/if}

    {* ============ HERO ============ *}
    <div class="rtln_hero">
        <div class="rtln_hero_row">
            <div class="rtln_hero_icon" style="border-color:{$race_color}; color:{$race_color}; background:linear-gradient(145deg, {$race_color}22, {$race_color}08); box-shadow:0 0 18px {$race_color}44;">
                {$race_icon}
            </div>
            <div class="rtln_hero_title">
                <h2>Arbol de Talentos de tu Raza</h2>
                <div class="sub">Raza: <b style="color:{$race_color};">{$race_name}</b> · Cada talento da bonus <u>personales</u> que se suman a tu raza y faccion</div>
            </div>
        </div>

        <div class="rtln_pts">
            <div class="rtln_pt">
                <div class="lbl">Puntos disponibles</div>
                <div class="val" style="color:#66ff99;">{$available} / {$total_points}</div>
            </div>
            <div class="rtln_pt">
                <div class="lbl">Puntos invertidos</div>
                <div class="val" style="color:#ffcc44;">{$spent}</div>
            </div>
            <div class="rtln_pt">
                <div class="lbl">Maximo por talento</div>
                <div class="val">{$max_per}</div>
            </div>
        </div>

        <div class="rtln_warn">
            <i class="fas fa-exclamation-triangle"></i>
            <b>Si cambias de raza pierdes TODOS los puntos y talentos</b> (los talentos son exclusivos de cada raza).
            Con tu misma raza puedes quitar y volver a poner puntos libremente.
        </div>
    </div>

    {* ============ ARBOL ============ *}
    <div class="rtln_box" style="padding-bottom:8px;">
        <div class="rtln_title"><i class="fas fa-tree"></i> Arbol de talentos de la raza {$race_name}</div>
        <div class="rtln_subtitle">
            Click en un nodo para poner 1 punto. Fila 2 se desbloquea con {$gate_2} puntos en la Fila 1;
            la Fila 3 con {$gate_3} puntos en la Fila 2. El camino activo se ilumina en <span style="color:#fbbf24;font-weight:800;">DORADO</span>.
        </div>

        <div class="rtln_tree">
            {foreach from=$rows item=row}
                <div class="rtln_rowwrap{if $row.num == 3} lastrow{/if}">
                    {* Etiqueta de la fila *}
                    {if $row.unlocked}
                        <div class="rtln_rowlabel open">
                            <span class="rn">FILA {$row.num}</span>
                            <span><i class="fas fa-unlock-alt"></i> Desbloqueada</span>
                            <span class="st">{$row.spent} pts</span>
                        </div>
                    {else}
                        <div class="rtln_rowlabel closed">
                            <span class="rn">FILA {$row.num}</span>
                            <span><i class="fas fa-lock"></i> Requiere {$row.gate} pts en la fila anterior</span>
                            <span class="st">tiene {$row.spent_prev}</span>
                        </div>
                    {/if}

                    <div class="rtln_nodes">
                        {foreach from=$row.talents item=t}

                            {* Estado del nodo *}
                            {if !$row.unlocked}
                                {assign var="nstate" value="locked"}
                            {elseif $t.points >= $t.max}
                                {assign var="nstate" value="selected"}
                            {elseif $t.points > 0}
                                {assign var="nstate" value="selected"}
                            {elseif $available > 0}
                                {assign var="nstate" value="available"}
                            {else}
                                {assign var="nstate" value="dim"}
                            {/if}

                            <div class="rtln_node {$nstate}">

                                {* Conector hacia la fila siguiente *}
                                {if $row.num < 3}
                                    {if $t.points > 0 && $rows[$row.num].unlocked}
                                        <span class="linkdown gold"></span>
                                    {elseif $t.points > 0}
                                        <span class="linkdown half"></span>
                                    {else}
                                        <span class="linkdown"></span>
                                    {/if}
                                {else}
                                    <span class="linkdown"></span>
                                {/if}

                                {* Nodo cuadrado *}
                                <div class="rtln_sq" style="color:{$race_color};">
                                    {if $nstate == 'available'}
                                        <form method="post" action="game.php?page=raceTalent&mode=doAdd">
                                            <input type="hidden" name="talent" value="{$t.key}">
                                            <button type="submit" class="pick" title="Poner 1 punto en {$t.name}"><i class="fas {$t.icon}"></i></button>
                                        </form>
                                    {else}
                                        <i class="fas {$t.icon}"></i>
                                        {if $nstate == 'locked'}<span class="lockmark" style="position:absolute; right:-6px; top:-6px; width:18px; height:18px; border-radius:50%; background:rgba(15,23,42,.95); color:#ff9966; border:1px solid rgba(255,153,102,.5); display:flex; align-items:center; justify-content:center; font-size:8px;"><i class="fas fa-lock"></i></span>{/if}
                                    {/if}
                                </div>

                                {* Pips de puntos *}
                                <div class="pips">
                                    {section name=pips start=0 loop=$t.max}
                                        {if $smarty.section.pips.index < $t.points}
                                            <span class="pip on"></span>
                                        {else}
                                            <span class="pip"></span>
                                        {/if}
                                    {/section}
                                </div>

                                {* Tooltip *}
                                <div class="rtln_tip">
                                    <div class="tt" style="color:{$race_color};"><i class="fas {$t.icon}"></i> {$t.name}</div>
                                    {$t.desc}
                                    <br><span class="tv">{$t.bonus_txt}</span>
                                    <div class="ts">Puntos: {$t.points} / {$t.max} · Fila {$row.num}</div>
                                </div>

                                {* Textos *}
                                <div class="nname">{$t.name}</div>
                                <div class="nef">{$t.bonus_txt}</div>
                                <div class="ndesc">{$t.desc}</div>

                                {* Estado y boton quitar *}
                                {if !$row.unlocked}
                                    <div class="nstate no">BLOQUEADO</div>
                                    <span class="rmv rmvghost">-</span>
                                {elseif $t.points >= $t.max}
                                    <div class="nstate max">MAXIMO</div>
                                    {if $t.points > 0}
                                        <form method="post" action="game.php?page=raceTalent&mode=doRemove" style="margin:5px 0 0;">
                                            <input type="hidden" name="talent" value="{$t.key}">
                                            <button type="submit" class="rmv"><i class="fas fa-minus"></i> Quitar</button>
                                        </form>
                                    {/if}
                                {elseif $t.points > 0}
                                    <div class="nstate ok">{$t.points} / {$t.max} PUNTOS</div>
                                    {if $available > 0}
                                        <form method="post" action="game.php?page=raceTalent&mode=doAdd" style="margin:5px 0 0;">
                                            <input type="hidden" name="talent" value="{$t.key}">
                                            <button type="submit" class="rmv" style="color:#00e0ff; border-color:rgba(0,224,255,.4); background:rgba(0,224,255,.08);"><i class="fas fa-plus"></i> +1</button>
                                        </form>
                                    {/if}
                                    <form method="post" action="game.php?page=raceTalent&mode=doRemove" style="margin:4px 0 0;">
                                        <input type="hidden" name="talent" value="{$t.key}">
                                        <button type="submit" class="rmv"><i class="fas fa-minus"></i> Quitar</button>
                                    </form>
                                {elseif $nstate == 'available'}
                                    <div class="nstate can">CLICK: +1 PUNTO</div>
                                    <span class="rmv rmvghost">-</span>
                                {else}
                                    <div class="nstate no">SIN PUNTOS LIBRES</div>
                                    <span class="rmv rmvghost">-</span>
                                {/if}
                            </div>
                        {/foreach}
                    </div>
                </div>
            {/foreach}

            {* Leyenda *}
            <div class="rtln_legend">
                <span class="li"><span class="dot g"></span> Con puntos (camino dorado)</span>
                <span class="li"><span class="dot c"></span> Disponible (+1)</span>
                <span class="li"><span class="dot k"></span> Bloqueado</span>
            </div>
        </div>
    </div>

    {* ============ BONUS ============ *}
    <div class="rtln_box">
        <div class="rtln_title"><i class="fas fa-chart-line"></i> Bonus de tus talentos (personales)</div>

        {if $talent_bonus && $talent_bonus|@count > 0}
            <div class="rtln_bonusgrid">
                {foreach from=$talent_bonus item=b}
                    <div class="rtln_bonus">
                        <div class="lbl">{$b.label}</div>
                        <div class="v" style="color:{if $b.val > 0}#66ff99{else}#ffcc44{/if};">{* v2.4.10: ternario " ? : " no soportado por el compilador Smarty del servidor -> se cambia por {if} *}{if $b.val > 0}+{/if}{$b.val|number_format:0}%</div>
                    </div>
                {/foreach}
            </div>
        {else}
            <div class="rtln_subtitle" style="text-align:center;padding:14px;">
                <i class="fas fa-inbox" style="font-size:20px;opacity:.4;display:block;margin-bottom:6px;"></i>
                Todavia no has puesto puntos. Click en un nodo del arbol para empezar.
            </div>
        {/if}
    </div>

    <div class="rtln_box">
        <div class="rtln_title"><i class="fas fa-space-shuttle"></i> Bonus de tu raza (de base)</div>
        {if $race_bonus && $race_bonus|@count > 0}
            <div class="rtln_bonusgrid">
                {foreach from=$race_bonus item=b}
                    <div class="rtln_bonus">
                        <div class="lbl">{$b.label}</div>
                        <div class="v" style="color:#66ccff;">{$b.val|number_format:0}%</div>
                    </div>
                {/foreach}
            </div>
        {else}
            <div class="rtln_subtitle">Tu raza no tiene bonus base extra.</div>
        {/if}
    </div>

</div>

{/block}
