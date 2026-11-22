// pokerGame.js — Motor de mesa Texas Hold'em
const { determineWinners } = require('./pokerEngine');

// 🔥 FIX: URL configurable del backend (para el VPS)
const BACKEND_URL = process.env.BACKEND_URL || 'http://localhost:3000';

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
  constructor(io, { smallBlind = 5, bigBlind = 10, maxPlayers = 6 } = {}) {
    this.io = io;
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
    
    // 🔥 NUEVO: Historial de la última mano
    this.lastHandHistory = null;

    this.nextHandTimeout = null;
    this.turnTimeout = null;
  }

  startBlindTimer() {
    if (this.blindTimer) clearInterval(this.blindTimer);
    // 🔥 Las ciegas suben cada 5 minutos (5 * 60 * 1000 = 300000 ms)
    this.blindTimer = setInterval(() => {
      // Solo marcamos la subida si hay al menos 2 jugadores en la mesa
      if (this.seats.filter(p => p !== null && p.chips > 0).length >= 2) {
        this.pendingBlindIncrease = true;
        console.log(`[Poker] Subida de ciegas pendiente. Se aplicará al terminar la mano actual.`);
        this.io.emit('blindIncreasePending', { message: 'Las ciegas subirán al terminar esta mano.' });
      }
    }, 5 * 60 * 1000);
  }

  getActing() { return this.seats.filter(p => p !== null && p.status === 'playing'); }
  getInHand() { return this.seats.filter(p => p !== null && (p.status === 'playing' || p.status === 'all-in')); }

  seat(socketId, userId, username, chips, seatIndex) {
    if (seatIndex < 0 || seatIndex >= this.maxPlayers) return { ok: false, error: 'Asiento inválido' };
    if (this.seats[seatIndex] !== null) return { ok: false, error: 'Ese asiento ya está ocupado' };
    
    const alreadySeated = this.seats.find(p => p !== null && p.userId === userId);
    if (alreadySeated) return { ok: false, error: 'Ya estás sentado en esta mesa' };

    this.seats[seatIndex] = {
      socketId, userId, username, chips: chips || 1000,
      cards: [], status: 'waiting', currentBet: 0, totalBet: 0, hasActed: false, handsPlayed: 0
    };
    
    this.broadcast();
    
    if (this.phase === 'waiting' && this.seats.filter(p => p !== null && p.chips > 0).length >= 2) {
      this.startHand();
    }

    return { ok: true };
  }

  reconnectPlayer(newSocketId, userId) {
    const player = this.seats.find(p => p !== null && p.userId === userId);
    if (!player) return { ok: false, error: 'Jugador no está en la mesa' };

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
  addChips(userId, amount) {
    const player = this.seats.find(p => p !== null && p.userId === userId);
    if (!player) return { ok: false, error: 'Jugador no encontrado en la mesa' };

    player.chips += amount;
    
    if (player.status === 'waiting') {
      player.status = 'waiting'; 
    }
    
    this.broadcast();
    console.log(`[Poker] Jugador ${player.username} agregó ${amount} fichas. Total: ${player.chips}`);

    // 🔥 FIX: Si la mesa estaba esperando y ahora hay 2+ jugadores con fichas, forzamos el inicio de la mano
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

  leave(socketId, isDisconnect = false) {
    const index = this.seats.findIndex(p => p !== null && p.socketId === socketId);
    if (index === -1) return { ok: false, error: 'No estás en la mesa' };

    const player = this.seats[index];

    if (!isDisconnect && player.chips > 0 && player.handsPlayed < 5) {
      return { ok: false, error: `Debes jugar al menos 5 manos para retirarte. Llevas ${player.handsPlayed}.` };
    }

    if (player.chips > 0) {
      fetch(`${BACKEND_URL}/api/poker/cash-out`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ userId: player.userId, amount: player.chips })
      }).catch(err => console.error("Error en cash-out:", err));
    }

    this.seats[index] = null;
    
    if (this.currentTurn === socketId && this.turnTimeout) {
      clearTimeout(this.turnTimeout);
      this.turnTimeout = null;
    }

    if (this.getInHand().length < 2 && this.phase !== 'waiting' && this.phase !== 'showdown') {
      this.resetAfterHand();
    } else {
      this.broadcast();
    }
    
    return { ok: true };
  }

  startHand() {
    if (this.nextHandTimeout) clearTimeout(this.nextHandTimeout);

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

  action(socketId, action, amount = 0) {
    if (this.currentTurn !== socketId) return { ok: false, error: 'No es tu turno' };
    if (!['preflop', 'flop', 'turn', 'river'].includes(this.phase)) return { ok: false, error: 'Fase inválida' };

    const p = this.seats.find(p => p !== null && p.socketId === socketId);
    if (!p || p.status !== 'playing') return { ok: false, error: 'No puedes actuar' };

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
      
      const potRake = Math.floor(pot.amount * 0.05);
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

    if (active.length > 0 && totalRake > 0) {
      const winnerData = this.seats.find(p => p !== null && p.socketId === active[0].socketId);
      if (winnerData) {
        fetch(`${BACKEND_URL}/api/poker/process-rake`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ rakeAmount: totalRake, playerId: winnerData.userId })
        }).catch(err => console.error("Error enviando rake:", err));
      }
    }

    this.io.emit('showdownResult', {
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

    const rake = Math.floor(this.pot * 0.05);
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

    if (winnerIds.length > 0) {
      const winnerData = this.seats.find(p => p !== null && p.socketId === winnerIds[0]);
      if (winnerData && rake > 0) {
        fetch(`${BACKEND_URL}/api/poker/process-rake`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ rakeAmount: rake, playerId: winnerData.userId })
        }).catch(err => console.error("Error enviando rake:", err));
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

    this.io.emit('handWon', {
      winners: winnerIds.map(id => this.seats.find(p => p !== null && p.socketId === id)?.username),
      pot: this.pot, rake, share: share + remainder
    });

    this.phase = 'showdown';
    this.broadcast();

    setTimeout(() => {
      this.resetAfterHand();
    }, 5000);
  }

  resetAfterHand() {
    if (this.turnTimeout) {
      clearTimeout(this.turnTimeout);
      this.turnTimeout = null;
    }

    if (this.pendingBlindIncrease) {
      this.blindLevel++;
      this.smallBlind = Number((this.smallBlind * 2).toFixed(2));
      this.bigBlind = Number((this.bigBlind * 2).toFixed(2));
      this.pendingBlindIncrease = false;
      
      console.log(`[Poker] Ciegas subidas a Nivel ${this.blindLevel}: ${this.smallBlind}/${this.bigBlind}`);
      this.io.emit('blindLevelUp', { level: this.blindLevel, smallBlind: this.smallBlind, bigBlind: this.bigBlind });
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

    if (this.seats.filter(p => p !== null && p.chips > 0).length >= 2) {
      this.nextHandTimeout = setTimeout(() => {
        if (this.phase === 'waiting' && this.seats.filter(p => p !== null && p.chips > 0).length >= 2) {
          this.startHand();
        }
      }, 3000);
    }
  }

  broadcast() {
    this.io.emit('tableUpdate', this.publicState());
    
    this.seats.forEach(p => {
      if (p) {
        this.io.to(p.socketId).emit('yourCards', {
          cards: p.cards,
          status: p.status
        });
      }
    });
  }

  publicState() {
    const cleanSeats = this.seats.map(p => {
      if (!p) return null;
      return {
        socketId: p.socketId, userId: p.userId, username: p.username,
        chips: p.chips, status: p.status, currentBet: p.currentBet, hasActed: p.hasActed, handsPlayed: p.handsPlayed
      };
    });

    return {
      seats: cleanSeats, pot: this.pot, communityCards: this.communityCards,
      phase: this.phase, currentTurn: this.currentTurn,
      currentBet: this.currentBet, minRaise: this.minRaise,
      dealerIndex: this.dealerIndex, smallBlind: this.smallBlind, bigBlind: this.bigBlind,
      blindLevel: this.blindLevel, pendingBlindIncrease: this.pendingBlindIncrease,
      lastHandHistory: this.lastHandHistory // 🔥 ENVIAMOS EL HISTORIAL AL FRONTEND
    };
  }
}

module.exports = PokerTable;