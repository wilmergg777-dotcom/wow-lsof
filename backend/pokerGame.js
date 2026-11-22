// pokerGame.js — Motor de mesa Texas Hold'em
const { determineWinners } = require('./pokerEngine');

// 🔥 FIX: URL configurable del backend (para el VPS)
const BACKEND_URL = process.env.BACKEND_URL || 'http://localhost:3000';

// 🔥 FONDOS: porcentaje de rake configurable desde wallet_settings (caché 60s)
// y token interno para los endpoints de dinero.
const { getFundConfig, CONFIG_DEFAULTS } = require('./services/funds');
const INTERNAL_API_TOKEN = process.env.INTERNAL_API_TOKEN || 'royalbet-internal-default';
let CACHED_RAKE_PERCENT = CONFIG_DEFAULTS.rake_percent / 100;
function refreshRakePercent() {
    getFundConfig().then(cfg => {
        CACHED_RAKE_PERCENT = (cfg.rake_percent || 5) / 100;
    }).catch(() => { /* sin BD: se mantiene el valor en caché */ });
}
refreshRakePercent();
setInterval(refreshRakePercent, 60 * 1000).unref?.();

// 🔥 SEGURIDAD: helper para llamadas internas motor→API con token interno
function internalPost(path, payload) {
    return fetch(`${BACKEND_URL}${path}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-Internal-Token': INTERNAL_API_TOKEN,
        },
        body: JSON.stringify(payload),
    }).catch(err => console.error(`[Poker] Error en llamada interna ${path}:`, err));
}

const SUITS = ['♠', '♥', '♦', '♣'];
const VALUES = ['2','3','4','5','6','7','8','9','10','J','Q','K','A'];

function createDeck() {
  const deck = [];
  for (const s of SUITS) for (const v of VALUES) deck.push(v + s);
  for (let i = deck.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [deck[i], deck[j]] = [deck[j], deck[i]];
  }
  return deck;
}

class PokerTable {
  // 🔥 FIX #1: aceptar tableId opcional. Si viene, todos los emits van al room de la mesa
  // en lugar de broadcast global (io.emit). Sin este fix, con 2+ mesas todos los clientes
  // reciben el state de todas las mesas.
  // 🔥 FIX #12: aceptar isPractice para no cobrar rake ni hacer cash-out en la práctica.
  // 🔥 MTT: aceptar isTournament + startingStack + onTournamentEnd para torneos reales.
  constructor(io, { smallBlind = 5, bigBlind = 10, maxPlayers = 6, tableId = null, isPractice = false, isTournament = false, tournamentId = null, startingStack = 3000, blindUpPercent = 1.25, onTournamentEnd = null, autoStart = true } = {}) {
    this.io = io;
    this.tableId = tableId;
    this.isPractice = isPractice; // 🔥 NUEVO: Bandera de práctica
    this.isTournament = isTournament; // 🔥 MTT: bandera de torneo
    this.tournamentId = tournamentId;
    this.startingStack = startingStack;
    this.blindUpPercent = blindUpPercent;
    this.onTournamentEnd = onTournamentEnd; // callback async para pagar premios
    this.autoStart = autoStart; // 🔥 MTT: false = no arrancar mano al sentarse (esperar al seeding completo)
    this.baseSmallBlind = smallBlind;
    this.baseBigBlind = bigBlind;

    this.smallBlind = smallBlind;
    this.bigBlind = bigBlind;
    this.maxPlayers = maxPlayers;

    this.blindLevel = 1;
    this.pendingBlindIncrease = false;
    this.blindTimer = null;
    this.startBlindTimer();

    this.seats = Array(this.maxPlayers).fill(null);

    this.pot = 0;
    this.communityCards = [];
    this.deck = [];
    this.dealerIndex = -1;
    this.currentTurn = null;
    this.currentBet = 0;
    this.minRaise = bigBlind;
    this.phase = 'waiting';
    this.handNumber = 0;

    // 🔥 Historial de la última mano
    this.lastHandHistory = null;

    // 🔥 NUEVO: Orden de eliminación para el podio del torneo de práctica
    this.eliminationOrder = [];

    this.nextHandTimeout = null;
    this.turnTimeout = null;
  }

  // 🔥 FIX #1 (cont.): helper central de emisión. Si la mesa tiene tableId,
  // emite al room; si no, fallback a broadcast (compat con código viejo).
  emitToTable(event, payload) {
    if (this.tableId) {
      this.io.to(this.tableId).emit(event, payload);
    } else {
      this.io.emit(event, payload);
    }
  }

  startBlindTimer() {
    if (this.blindTimer) clearInterval(this.blindTimer);
    // 🔥 CAMBIO 1: Las ciegas suben cada 10 minutos (10 * 60 * 1000 = 600000 ms)
    this.blindTimer = setInterval(() => {
      // Solo marcamos la subida si hay al menos 2 jugadores en la mesa
      if (this.seats.filter(p => p !== null && p.chips > 0).length >= 2) {
        this.pendingBlindIncrease = true;
        console.log(`[Poker] Subida de ciegas pendiente. Se aplicará al terminar la mano actual.`);
        // 🔥 FIX #1: solo a los jugadores de ESTA mesa
        this.emitToTable('blindIncreasePending', { message: 'Las ciegas subirán al terminar esta mano.' });
      }
    }, 10 * 60 * 1000);
  }

  getActing() { return this.seats.filter(p => p !== null && p.status === 'playing'); }
  getInHand() { return this.seats.filter(p => p !== null && (p.status === 'playing' || p.status === 'all-in')); }

  // 🔥 FIX #2: auto-asignar silla si seatIndex no viene (antes fallaba con
  // "Ese asiento ya está ocupado" porque this.seats[undefined] !== null).
  // 🔥 FIX #3: validar que chips sea número positivo.
  // 🔥 FIX AVATAR: Recibimos avatar_url como 6to parámetro.
  // 🔥 FIX RE-BUY: Si el jugador ya está sentado pero con chips === 0 (modo espectador),
  // permitir que se le añadan fichas a su asiento existente (re-buy).
  seat(socketId, userId, username, chips, seatIndex, avatar_url = null) {
    // 🔥 FIX RE-BUY: comprobar PRIMERO si el jugador ya está sentado
    const alreadySeated = this.seats.find(p => p !== null && p.userId === userId);
    if (alreadySeated) {
      // Si tiene 0 fichas, es un re-buy: añadir fichas a su asiento existente
      if (alreadySeated.chips === 0) {
        const chipsValue = Number(chips);
        if (!Number.isFinite(chipsValue) || chipsValue <= 0) {
          return { ok: false, error: 'Cantidad de fichas inválida' };
        }
        alreadySeated.chips = chipsValue;
        // Actualizar socketId y avatar por si cambiaron
        alreadySeated.socketId = socketId;
        alreadySeated.username = username;
        alreadySeated.avatar_url = avatar_url;
        alreadySeated.status = 'waiting';
        this.broadcast();
        console.log(`[Poker] Re-buy: ${username} recargó ${chipsValue} fichas en su asiento existente.`);
        // Si la mesa estaba esperando y ahora hay 2+ jugadores con fichas, forzar inicio
        if (this.phase === 'waiting' && this.seats.filter(p => p !== null && p.chips > 0).length >= 2) {
          if (this.nextHandTimeout) clearTimeout(this.nextHandTimeout);
          this.nextHandTimeout = setTimeout(() => {
            if (this.phase === 'waiting' && this.seats.filter(p => p !== null && p.chips > 0).length >= 2) {
              this.startHand();
            }
          }, 1000);
        }
        return { ok: true, rebuy: true };
      }
      return { ok: false, error: 'Ya estás sentado en esta mesa' };
    }

    if (seatIndex == null) {
      seatIndex = this.seats.findIndex(s => s === null);
      if (seatIndex === -1) return { ok: false, error: 'Mesa llena' };
    }
    if (!Number.isInteger(seatIndex) || seatIndex < 0 || seatIndex >= this.maxPlayers) {
      return { ok: false, error: 'Asiento inválido' };
    }
    if (this.seats[seatIndex] !== null) return { ok: false, error: 'Ese asiento ya está ocupado' };

    const chipsValue = Number(chips);
    if (!Number.isFinite(chipsValue) || chipsValue <= 0) {
      return { ok: false, error: 'Cantidad de fichas inválida' };
    }

    // 🔥 FIX AVATAR: Guardamos el avatar_url en el asiento
    this.seats[seatIndex] = {
      socketId, userId, username, avatar_url, chips: chipsValue,
      cards: [], status: 'waiting', currentBet: 0, totalBet: 0, hasActed: false, handsPlayed: 0
    };

    this.broadcast();

    // 🔥 AUTO-START solo si la mesa no está en modo seeding (MTT)
    if (this.autoStart && this.phase === 'waiting' && this.seats.filter(p => p !== null && p.chips > 0).length >= 2) {
      this.startHand();
    }

    return { ok: true };
  }

  // 🔥 FIX #4: si el socket nuevo ya estaba sentado en otro userId (raro pero posible),
  // no permitir reconnect hasta limpiar.
  reconnectPlayer(newSocketId, userId) {
    const player = this.seats.find(p => p !== null && p.userId === userId);
    if (!player) return { ok: false, error: 'Jugador no está en la mesa' };

    const conflict = this.seats.find(p => p !== null && p.socketId === newSocketId && p.userId !== userId);
    if (conflict) return { ok: false, error: 'Socket ya asignado a otro jugador' };

    const oldSocketId = player.socketId;
    player.socketId = newSocketId;

    if (this.currentTurn === oldSocketId) {
      this.currentTurn = newSocketId;
      this.startTurnTimer();
    }

    this.broadcast();

    if (player.cards && player.cards.length > 0) {
      this.io.to(newSocketId).emit('yourCards', {
        cards: player.cards,
        status: player.status
      });
    }

    console.log(`[Poker] Jugador ${player.username} reconectado. Socket: ${newSocketId}`);
    return { ok: true };
  }

  // 🔥 FUNCIÓN PARA AGREGAR FICHAS (REBUY) 🔥
  // 🔥 FIX #5: eliminar el if no-op (player.status === 'waiting' → 'waiting').
  // 🔥 FIX #6: validar amount numérico positivo.
  addChips(userId, amount) {
    const player = this.seats.find(p => p !== null && p.userId === userId);
    if (!player) return { ok: false, error: 'Jugador no encontrado en la mesa' };

    const amountValue = Number(amount);
    if (!Number.isFinite(amountValue) || amountValue <= 0) {
      return { ok: false, error: 'Cantidad de fichas inválida' };
    }

    player.chips += amountValue;

    this.broadcast();
    console.log(`[Poker] Jugador ${player.username} agregó ${amountValue} fichas. Total: ${player.chips}`);

    // 🔥 Si la mesa estaba esperando y ahora hay 2+ jugadores con fichas, forzamos el inicio de la mano
    if (this.phase === 'waiting' && this.seats.filter(p => p !== null && p.chips > 0).length >= 2) {
      if (this.nextHandTimeout) clearTimeout(this.nextHandTimeout);
      this.nextHandTimeout = setTimeout(() => {
        if (this.phase === 'waiting' && this.seats.filter(p => p !== null && p.chips > 0).length >= 2) {
          this.startHand();
        }
      }, 1000); // Pequeño retraso para que el frontend se actualice
    }

    return { ok: true };
  }

  // 🔥 FIX #7: si el jugador que se va era el currentTurn, mover el turno al siguiente
  // jugador activo. Antes la mano quedaba colgada.
  // 🔥 FIX AUTH: aceptar authToken para hacer el cash-out con Authorization header.
  leave(socketId, isDisconnect = false, authToken = null) {
    const index = this.seats.findIndex(p => p !== null && p.socketId === socketId);
    if (index === -1) return { ok: false, error: 'No estás en la mesa' };

    const player = this.seats[index];

    if (!isDisconnect && player.chips > 0 && player.handsPlayed < 5) {
      return { ok: false, error: `Debes jugar al menos 5 manos para retirarte. Llevas ${player.handsPlayed}.` };
    }

    // 🔥 FIX #12: No hacer cash-out si es mesa de práctica (las fichas son falsas)
    // 🔥 MTT: tampoco en torneo (el premio lo paga el payout automático al final)
    // 🔥 FIX SEGURIDAD: el cash-out del motor ahora usa el endpoint INTERNO con
    // X-Internal-Token. El endpoint público /poker/cash-out ya NO acredita dinero
    // libremente (solo reembolsos de buy-in fallidos), así que un usuario no puede
    // imprimir fichas llamándolo directamente.
    if (player.chips > 0 && !this.isPractice && !this.isTournament) {
      internalPost('/api/poker/internal/cash-out', { userId: player.userId, amount: player.chips });
    }

    this.seats[index] = null;

    const wasCurrentTurn = this.currentTurn === socketId;
    if (wasCurrentTurn && this.turnTimeout) {
      clearTimeout(this.turnTimeout);
      this.turnTimeout = null;
    }

    if (this.getInHand().length < 2 && this.phase !== 'waiting' && this.phase !== 'showdown') {
      this.resetAfterHand();
      return { ok: true };
    }

    // Si era su turno y quedan 2+ jugadores en mano, pasamos el turno al siguiente activo
    if (wasCurrentTurn && ['preflop', 'flop', 'turn', 'river'].includes(this.phase)) {
      this.currentTurn = null;
      const next = this.seats.find(p => p !== null && p.status === 'playing');
      if (next) {
        this.currentTurn = next.socketId;
        this.broadcast();
        this.startTurnTimer();
        this.checkTournamentEnd(); // 🔥 NUEVO
        return { ok: true };
      }
    }

    this.broadcast();
    this.checkTournamentEnd(); // 🔥 NUEVO
    return { ok: true };
  }

  startHand() {
    if (this.nextHandTimeout) clearTimeout(this.nextHandTimeout);

    // 🔥 GUARD: no permitir iniciar una mano sobre otra EN CURSO
    // (evita corrupción de estado si alguien fuerza startHand durante preflop/flop/etc.)
    if (!['waiting', 'showdown'].includes(this.phase)) {
      return { ok: false, error: 'Ya hay una mano en curso' };
    }

    const seatedPlayers = this.seats.filter(p => p !== null && p.chips > 0);
    if (seatedPlayers.length < 2) return { ok: false, error: 'Se necesitan 2+ jugadores con fichas' };

    this.handNumber++;
    this.pot = 0;
    this.communityCards = [];
    this.deck = createDeck();
    this.phase = 'preflop';
    this.currentBet = this.bigBlind;
    this.minRaise = this.bigBlind;

    this.seats.forEach(p => {
      if (p) {
        if (p.chips > 0) {
          p.cards = [this.deck.pop(), this.deck.pop()];
          p.status = 'playing';
          p.currentBet = 0;
          p.totalBet = 0;
          p.hasActed = false;
          p.handsPlayed += 1;
        } else {
          p.cards = [];
          p.status = 'waiting';
          p.currentBet = 0;
          p.totalBet = 0;
          p.hasActed = false;
        }
      }
    });

    for (let i = 1; i <= this.maxPlayers; i++) {
      let checkIdx = (this.dealerIndex + i) % this.maxPlayers;
      if (this.seats[checkIdx] !== null && this.seats[checkIdx].chips > 0) {
        this.dealerIndex = checkIdx;
        break;
      }
    }

    let sbIndex = -1, bbIndex = -1;
    let count = 0;
    for (let i = 1; i <= this.maxPlayers; i++) {
      let checkIdx = (this.dealerIndex + i) % this.maxPlayers;
      if (this.seats[checkIdx] !== null && this.seats[checkIdx].chips > 0) {
        if (count === 0) sbIndex = checkIdx;
        if (count === 1) { bbIndex = checkIdx; break; }
        count++;
      }
    }

    if (seatedPlayers.length === 2) {
      sbIndex = this.dealerIndex;
      let nextIdx = (this.dealerIndex + 1) % this.maxPlayers;
      while (this.seats[nextIdx] === null || this.seats[nextIdx].chips === 0) nextIdx = (nextIdx + 1) % this.maxPlayers;
      bbIndex = nextIdx;
    }

    this.postBlind(sbIndex, this.smallBlind);
    this.postBlind(bbIndex, this.bigBlind);

    let nextTurn = (bbIndex + 1) % this.maxPlayers;
    while (this.seats[nextTurn] === null || this.seats[nextTurn].status !== 'playing') {
      nextTurn = (nextTurn + 1) % this.maxPlayers;
    }
    this.currentTurn = this.seats[nextTurn].socketId;

    this.broadcast();
    this.startTurnTimer();
    return { ok: true };
  }

  postBlind(seatIndex, amount) {
    const p = this.seats[seatIndex];
    if (!p) return;
    const actual = Math.min(amount, p.chips);
    p.chips -= actual;
    p.currentBet = actual;
    p.totalBet += actual;
    this.pot += actual;
    if (p.chips === 0) p.status = 'all-in';
  }

  // 🔥 FIX #8: validar amount cuando es raise. Antes con amount = NaN se corrompía el state.
  action(socketId, action, amount = 0) {
    if (this.currentTurn !== socketId) return { ok: false, error: 'No es tu turno' };
    if (!['preflop', 'flop', 'turn', 'river'].includes(this.phase)) return { ok: false, error: 'Fase inválida' };

    const p = this.seats.find(p => p !== null && p.socketId === socketId);
    if (!p || p.status !== 'playing') return { ok: false, error: 'No puedes actuar' };

    // 🔥 Salvaguarda: si el jugador tiene 0 fichas, no puede actuar
    if (p.chips === 0) return { ok: false, error: 'No tienes fichas para actuar' };

    if (this.turnTimeout) {
      clearTimeout(this.turnTimeout);
      this.turnTimeout = null;
    }

    const toCall = this.currentBet - p.currentBet;

    if (action === 'fold') {
      p.status = 'folded';
      p.hasActed = true;
    } else if (action === 'check') {
      if (toCall > 0) return { ok: false, error: `Debes igualar ${toCall}` };
      p.hasActed = true;
    } else if (action === 'call') {
      if (toCall <= 0) return { ok: false, error: 'Nada que igualar, usa check' };
      const pay = Math.min(toCall, p.chips);
      p.chips -= pay;
      p.currentBet += pay;
      p.totalBet += pay;
      this.pot += pay;
      p.hasActed = true;
      if (p.chips === 0) p.status = 'all-in';
    } else if (action === 'raise') {
      if (typeof amount !== 'number' || !Number.isFinite(amount) || amount <= 0) {
        return { ok: false, error: 'Monto de subida inválido' };
      }
      const oldBet = this.currentBet;
      if (amount < oldBet + this.minRaise) return { ok: false, error: `Subida mínima: ${oldBet + this.minRaise}` };
      const cost = amount - p.currentBet;
      if (cost > p.chips) return { ok: false, error: 'Fichas insuficientes' };

      p.chips -= cost;
      p.currentBet = amount;
      p.totalBet += cost;
      this.pot += cost;
      this.currentBet = amount;
      this.minRaise = amount - oldBet;
      p.hasActed = true;
      if (p.chips === 0) p.status = 'all-in';

      this.seats.forEach(other => {
        if (other && other.socketId !== socketId && other.status === 'playing') {
          other.hasActed = false;
        }
      });
    } else {
      return { ok: false, error: 'Acción inválida' };
    }

    this.advance();
    return { ok: true };
  }

  advance() {
    const inHand = this.getInHand();
    if (inHand.length <= 1) {
      if (inHand.length === 1) this.awardPot([inHand[0].socketId]);
      else { this.resetAfterHand(); this.broadcast(); }
      return;
    }

    const acting = this.getActing();
    if (acting.length === 0) { this.runOutBoard(); return; }

    const allActed = acting.every(p => p.hasActed);
    const allMatched = acting.every(p => p.currentBet === this.currentBet);

    if (allActed && allMatched) { this.nextPhase(); return; }

    let curIdx = this.seats.findIndex(p => p !== null && p.socketId === this.currentTurn);

    for (let i = 1; i <= this.maxPlayers; i++) {
      let nextIdx = (curIdx + i) % this.maxPlayers;
      let nextP = this.seats[nextIdx];
      if (nextP && nextP.status === 'playing' && (!nextP.hasActed || nextP.currentBet < this.currentBet)) {
        this.currentTurn = nextP.socketId;
        this.broadcast();
        this.startTurnTimer();
        return;
      }
    }

    this.nextPhase();
  }

  nextPhase() {
    this.seats.forEach(p => {
      if (p) {
        p.currentBet = 0;
        p.hasActed = false;
      }
    });
    this.currentBet = 0;
    this.minRaise = this.bigBlind;

    if (this.phase === 'preflop') {
      this.communityCards = [this.deck.pop(), this.deck.pop(), this.deck.pop()];
      this.phase = 'flop';
    } else if (this.phase === 'flop') {
      this.communityCards.push(this.deck.pop());
      this.phase = 'turn';
    } else if (this.phase === 'turn') {
      this.communityCards.push(this.deck.pop());
      this.phase = 'river';
    } else if (this.phase === 'river') {
      this.showdown();
      return;
    }

    for (let i = 1; i <= this.maxPlayers; i++) {
      let checkIdx = (this.dealerIndex + i) % this.maxPlayers;
      let p = this.seats[checkIdx];
      if (p && p.status === 'playing') {
        this.currentTurn = p.socketId;
        break;
      }
    }

    this.broadcast();
    this.startTurnTimer();
  }

  startTurnTimer() {
    if (this.turnTimeout) clearTimeout(this.turnTimeout);
    if (!this.currentTurn) return;

    const currentTurnId = this.currentTurn;

    this.turnTimeout = setTimeout(() => {
      if (this.currentTurn === currentTurnId) {
        const p = this.seats.find(s => s && s.socketId === currentTurnId);
        if (p && p.status === 'playing') {
          const toCall = this.currentBet - p.currentBet;
          const forcedAction = toCall > 0 ? 'fold' : 'check';
          console.log(`[Timeout] ${p.username} no actuó en 50s. Auto-${forcedAction}.`);
          this.action(currentTurnId, forcedAction);
        }
      }
    }, 50000);
  }

  runOutBoard() {
    while (this.communityCards.length < 5) this.communityCards.push(this.deck.pop());
    this.showdown();
  }

  showdown() {
    if (this.turnTimeout) clearTimeout(this.turnTimeout);

    const active = this.getInHand();
    if (active.length === 0) { this.resetAfterHand(); return; }

    const allContributors = this.seats.filter(p => p !== null && p.totalBet > 0);
    allContributors.sort((a, b) => a.totalBet - b.totalBet);

    let tempContributors = allContributors.map(p => ({ socketId: p.socketId, tempBet: p.totalBet }));
    let sidePots = [];

    while (tempContributors.length > 0) {
      const minBet = tempContributors[0].tempBet;
      const potSize = minBet * tempContributors.length;

      const eligibleAll = tempContributors.map(p => p.socketId);
      const eligibleActive = active.filter(p => eligibleAll.includes(p.socketId)).map(p => p.socketId);

      if (potSize > 0 && eligibleActive.length > 0) {
        sidePots.push({
          amount: potSize,
          eligible: eligibleActive
        });
      }

      tempContributors.forEach(p => p.tempBet -= minBet);
      tempContributors = tempContributors.filter(p => p.tempBet > 0);
    }

    let totalRake = 0;
    const allResults = [];
    const winnerResults = [];

    for (const pot of sidePots) {
      const eligiblePlayers = active.filter(p => pot.eligible.includes(p.socketId));
      const evalPlayers = eligiblePlayers.map(p => ({
        socketId: p.socketId, username: p.username,
        cards: p.cards, communityCard: this.communityCards, communityCards: this.communityCards
      }));

      const { winners, all } = determineWinners(evalPlayers);

      // 🔥 FIX #12: Si es práctica, no se cobra rake
      // 🔥 MTT: los torneos tampoco pagan rake por bote (su comisión es la
      //         comisión de la entrada, ya repartida al registrar).
      // 🔥 FONDOS: porcentaje leído de wallet_settings (caché), antes 0.05 fijo.
      const potRake = (this.isPractice || this.isTournament) ? 0 : Math.floor(pot.amount * CACHED_RAKE_PERCENT);
      totalRake += potRake;
      const netPot = pot.amount - potRake;

      let share = Math.floor(netPot / winners.length);
      let remainder = netPot % winners.length;

      for (const w of winners) {
        const playerInTable = this.seats.find(p => p !== null && p.socketId === w.socketId);
        if (playerInTable) {
          playerInTable.chips += share;
          const existingWinner = winnerResults.find(x => x.socketId === w.socketId);
          if (existingWinner) {
            existingWinner.amountWon = (existingWinner.amountWon || 0) + share;
          } else {
            // 🔥 FIX: Enviamos también las 5 cartas exactas de la jugada (w.hand.cards)
            winnerResults.push({ socketId: w.socketId, username: w.username, hand: w.hand.name, cards: w.cards, handCards: w.hand.cards, amountWon: share });
          }
        }
      }

      if (remainder > 0 && winners.length > 0) {
        const firstWinner = this.seats.find(p => p !== null && p.socketId === winners[0].socketId);
        if (firstWinner) {
          firstWinner.chips += remainder;
          const wRes = winnerResults.find(x => x.socketId === winners[0].socketId);
          if (wRes) wRes.amountWon += remainder;
        }
      }

      for (const a of all) {
        if (!allResults.find(x => x.socketId === a.socketId)) {
          allResults.push({ socketId: a.socketId, username: a.username, hand: a.hand.name, cards: a.cards });
        }
      }
    }

    // 🔥 GUARDAMOS EL HISTORIAL ANTES DE REINICIAR
    this.lastHandHistory = {
      winners: winnerResults,
      all: allResults,
      communityCards: [...this.communityCards]
    };

    // 🔥 FIX #9: para el rake, usar el PRIMER GANADOR (antes usaba active[0],
    // que podía no ser ganador → su referrer cobraba el 25% por error).
    // 🔥 FIX #12: Solo enviar rake al backend si NO es mesa de práctica
    if (active.length > 0 && totalRake > 0 && !this.isPractice && !this.isTournament) {
      const rakeSourceSocketId = winnerResults.length > 0 ? winnerResults[0].socketId : active[0].socketId;
      const winnerData = this.seats.find(p => p !== null && p.socketId === rakeSourceSocketId);
      if (winnerData) {
        // 🔥 SEGURIDAD: endpoint interno con X-Internal-Token (antes público y sin auth)
        internalPost('/api/poker/internal/process-rake', {
          rakeAmount: totalRake,
          playerId: winnerData.userId,
          tableId: this.tableId,
          handNumber: this.handNumber,
        });
      }
    }

    // 🔥 FIX #1: solo a los jugadores de esta mesa
    this.emitToTable('showdownResult', {
      winners: winnerResults,
      all: allResults,
      pot: this.pot, rake: totalRake
    });

    this.phase = 'showdown';
    this.broadcast();

    setTimeout(() => {
      this.resetAfterHand();
    }, 5000);
  }

  awardPot(winnerIds) {
    if (this.turnTimeout) clearTimeout(this.turnTimeout);

    // 🔥 FIX #12: Si es práctica, no se cobra rake
    // 🔥 MTT: torneos sin rake por bote (la comisión va en la entrada)
    // 🔥 FONDOS: porcentaje configurable desde wallet_settings
    const rake = (this.isPractice || this.isTournament) ? 0 : Math.floor(this.pot * CACHED_RAKE_PERCENT);
    const potAfterRake = this.pot - rake;

    let share = Math.floor(potAfterRake / winnerIds.length);
    let remainder = potAfterRake % winnerIds.length;

    for (const id of winnerIds) {
      const p = this.seats.find(p => p !== null && p.socketId === id);
      if (p) p.chips += share;
    }

    if (remainder > 0 && winnerIds.length > 0) {
      const firstWinner = this.seats.find(p => p !== null && p.socketId === winnerIds[0]);
      if (firstWinner) firstWinner.chips += remainder;
    }

    // 🔥 FIX #12: Solo enviar rake al backend si NO es mesa de práctica ni torneo
    if (winnerIds.length > 0 && !this.isPractice && !this.isTournament) {
      const winnerData = this.seats.find(p => p !== null && p.socketId === winnerIds[0]);
      if (winnerData && rake > 0) {
        // 🔥 SEGURIDAD: endpoint interno con X-Internal-Token
        internalPost('/api/poker/internal/process-rake', {
          rakeAmount: rake,
          playerId: winnerData.userId,
          tableId: this.tableId,
          handNumber: this.handNumber,
        });
      }
    }

    // 🔥 GUARDAMOS EL HISTORIAL PARA CUANDO GANAN POR RETIRADA
    this.lastHandHistory = {
      winners: winnerIds.map(id => {
        const p = this.seats.find(s => s && s.socketId === id);
        return { username: p?.username, cards: p?.cards, handCards: [], amountWon: share + remainder };
      }),
      all: [],
      communityCards: [...this.communityCards]
    };

    // 🔥 FIX #1: solo a los jugadores de esta mesa
    this.emitToTable('handWon', {
      winners: winnerIds.map(id => this.seats.find(p => p !== null && p.socketId === id)?.username),
      pot: this.pot, rake, share: share + remainder
    });

    this.phase = 'showdown';
    this.broadcast();

    setTimeout(() => {
      this.resetAfterHand();
    }, 5000);
  }

  // 🔥 NUEVO: Trackear jugadores que acaban de ser eliminados (chips === 0)
  trackEliminations() {
    this.seats.forEach(p => {
      if (p && p.chips === 0 && !this.eliminationOrder.find(e => e.userId === p.userId)) {
        this.eliminationOrder.push({ userId: p.userId, username: p.username });
      }
    });
  }

  // 🔥 NUEVO: Detectar si el torneo terminó (solo 1 jugador con fichas)
  // y emitir el podio con los primeros lugares.
  // 🔥 MTT: aplica tanto a práctica como a torneos reales (isTournament).
  checkTournamentEnd() {
    if (!this.isPractice && !this.isTournament) return;
    const playersWithChips = this.seats.filter(p => p !== null && p.chips > 0);
    if (playersWithChips.length === 1 && this.eliminationOrder.length >= 1) {
      const winner = playersWithChips[0];
      const podium = [
        { userId: winner.userId, username: winner.username, chips: winner.chips, position: 1 }
      ];
      // Los eliminados se registraron en orden: el ÚLTIMO eliminado queda en 2º lugar
      const ordered = [...this.eliminationOrder].reverse();
      ordered.forEach((e) => {
        podium.push({ userId: e.userId, username: e.username, chips: 0, position: podium.length + 1 });
      });
      console.log(`[Poker] Torneo terminado en ${this.tableId}. Ganador: ${winner.username}`);
      this.emitToTable('tournamentEnd', podium);
      if (this.isTournament && typeof this.onTournamentEnd === 'function') {
        const cb = this.onTournamentEnd;
        this.onTournamentEnd = null; // evita doble pago
        Promise.resolve().then(() => cb(podium)).catch(err =>
          console.error(`[MTT] Error en payout de ${this.tableId}:`, err));
      }
      this.eliminationOrder = [];
    }
  }

  resetAfterHand() {
    if (this.turnTimeout) {
      clearTimeout(this.turnTimeout);
      this.turnTimeout = null;
    }

    // 🔥 NUEVO: trackear eliminados ANTES de resetear el estado
    this.trackEliminations();

    // 🔥 MTT: en torneo, el eliminado (0 fichas) LIBERA su silla.
    // En cash/práctica se queda como espectador (comportamiento original).
    if (this.isTournament) {
      this.seats.forEach((p, i) => {
        if (p && p.chips === 0) this.seats[i] = null;
      });
    }

    if (this.pendingBlindIncrease) {
      this.blindLevel++;
      // 🔥 CAMBIO 2: Subida configurable (MTT usa blindUpPercent, por defecto 1.25)
      this.smallBlind = Number((this.smallBlind * this.blindUpPercent).toFixed(2));
      this.bigBlind = Number((this.bigBlind * this.blindUpPercent).toFixed(2));
      this.pendingBlindIncrease = false;

      console.log(`[Poker] Ciegas subidas a Nivel ${this.blindLevel}: ${this.smallBlind}/${this.bigBlind}`);
      // 🔥 FIX #1: solo a los jugadores de esta mesa
      this.emitToTable('blindLevelUp', { level: this.blindLevel, smallBlind: this.smallBlind, bigBlind: this.bigBlind });
    }

    this.pot = 0;
    this.phase = 'waiting';
    this.currentTurn = null;
    this.communityCards = [];
    this.currentBet = 0;
    this.minRaise = this.bigBlind;

    this.seats.forEach(p => {
      if (p) {
        p.cards = [];
        p.status = 'waiting';
        p.currentBet = 0;
        p.totalBet = 0;
        p.hasActed = false;
      }
    });

    this.broadcast();

    // 🔥 NUEVO: comprobar si el torneo terminó
    this.checkTournamentEnd();

    if (this.seats.filter(p => p !== null && p.chips > 0).length >= 2) {
      this.nextHandTimeout = setTimeout(() => {
        if (this.phase === 'waiting' && this.seats.filter(p => p !== null && p.chips > 0).length >= 2) {
          this.startHand();
        }
      }, 3000);
    }
  }

  // 🔥 FIX #1: usar emitToTable en lugar de io.emit
  broadcast() {
    this.emitToTable('tableUpdate', this.publicState());

    this.seats.forEach(p => {
      if (p) {
        this.io.to(p.socketId).emit('yourCards', {
          cards: p.cards,
          status: p.status
        });
      }
    });
  }

  // 🔥 FIX #10: incluir tableId en publicState para que el frontend sepa
  // de qué mesa es el update (útil si el socket escucha múltiples salas).
  publicState() {
    const cleanSeats = this.seats.map(p => {
      if (!p) return null;
      return {
        socketId: p.socketId, userId: p.userId, username: p.username,
        avatar_url: p.avatar_url, // 🔥 FIX AVATAR: Enviamos el avatar al frontend
        chips: p.chips, status: p.status, currentBet: p.currentBet, hasActed: p.hasActed, handsPlayed: p.handsPlayed
      };
    });

    return {
      tableId: this.tableId,
      isTournament: this.isTournament,
      tournamentId: this.tournamentId,
      seats: cleanSeats, pot: this.pot, communityCards: this.communityCards,
      phase: this.phase, currentTurn: this.currentTurn,
      currentBet: this.currentBet, minRaise: this.minRaise,
      dealerIndex: this.dealerIndex, smallBlind: this.smallBlind, bigBlind: this.bigBlind,
      blindLevel: this.blindLevel, pendingBlindIncrease: this.pendingBlindIncrease,
      lastHandHistory: this.lastHandHistory
    };
  }
}

module.exports = PokerTable;