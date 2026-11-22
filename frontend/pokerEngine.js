// pokerEngine.js — Evaluador de manos Texas Hold'em
const VALUE_MAP = {
  '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9,
  '10': 10, 'J': 11, 'Q': 12, 'K': 13, 'A': 14
};

function parseCard(card) {
  const suit = card.slice(-1);
  const valueStr = card.slice(0, -1);
  return { value: VALUE_MAP[valueStr], suit, valueStr };
}

function evaluate5(cards) {
  const values = cards.map(c => c.value).sort((a, b) => b - a);
  const suits = cards.map(c => c.suit);
  const isFlush = suits.every(s => s === suits[0]);

  const uniqueVals = [...new Set(values)];
  let isStraight = false, straightHigh = 0;
  if (uniqueVals.length === 5) {
    if (uniqueVals[0] - uniqueVals[4] === 4) { isStraight = true; straightHigh = uniqueVals[0]; }
    else if (uniqueVals[0] === 14 && uniqueVals[1] === 5 && uniqueVals[4] === 2) { isStraight = true; straightHigh = 5; }
  }

  const counts = {};
  values.forEach(v => (counts[v] = (counts[v] || 0) + 1));
  const groups = Object.entries(counts)
    .map(([v, c]) => ({ v: Number(v), c }))
    .sort((a, b) => b.c - a.c || b.v - a.v);

  if (isFlush && isStraight && straightHigh === 14) return { rank: 10, name: 'Escalera Real', tiebreak: [14] };
  if (isFlush && isStraight) return { rank: 9, name: 'Escalera de Color', tiebreak: [straightHigh] };
  if (groups[0].c === 4) return { rank: 8, name: 'Póker', tiebreak: [groups[0].v, groups[1].v] };
  if (groups[0].c === 3 && groups[1].c === 2) return { rank: 7, name: 'Full House', tiebreak: [groups[0].v, groups[1].v] };
  if (isFlush) return { rank: 6, name: 'Color', tiebreak: values };
  if (isStraight) return { rank: 5, name: 'Escalera', tiebreak: [straightHigh] };
  if (groups[0].c === 3) return { rank: 4, name: 'Trío', tiebreak: [groups[0].v, ...groups.slice(1).map(g => g.v)] };
  if (groups[0].c === 2 && groups[1].c === 2) return { rank: 3, name: 'Doble Pareja', tiebreak: [groups[0].v, groups[1].v, groups[2].v] };
  if (groups[0].c === 2) return { rank: 2, name: 'Pareja', tiebreak: [groups[0].v, ...groups.slice(1).map(g => g.v)] };
  return { rank: 1, name: 'Carta Alta', tiebreak: values };
}

function compareHands(a, b) {
  if (a.rank !== b.rank) return a.rank - b.rank;
  const len = Math.max(a.tiebreak.length, b.tiebreak.length);
  for (let i = 0; i < len; i++) {
    const av = a.tiebreak[i] || 0, bv = b.tiebreak[i] || 0;
    if (av !== bv) return av - bv;
  }
  return 0;
}

function combinations(arr, k) {
  const res = [], combo = [];
  function helper(start) {
    if (combo.length === k) { res.push([...combo]); return; }
    for (let i = start; i < arr.length; i++) { combo.push(arr[i]); helper(i + 1); combo.pop(); }
  }
  helper(0);
  return res;
}

function getBestHand(cards7) {
  const parsed = cards7.map(parseCard);
  let best = null;
  let bestCombo = null;
  for (const c of combinations(parsed, 5)) {
    const e = evaluate5(c);
    if (!best || compareHands(e, best) > 0) {
      best = e;
      bestCombo = c;
    }
  }
  
  // 🔥 FIX: Guardamos las 5 cartas exactas que forman esta jugada
  if (best && bestCombo) {
    best.cards = bestCombo.map(c => c.valueStr + c.suit);
  }
  
  return best;
}

function determineWinners(players) {
  const evaluated = players.map(p => ({
    ...p,
    hand: getBestHand([...p.cards, ...p.communityCards])
  }));
  evaluated.sort((a, b) => compareHands(b.hand, a.hand));
  const best = evaluated[0].hand;
  const winners = evaluated.filter(e => compareHands(e.hand, best) === 0);
  return { winners, all: evaluated };
}

module.exports = { getBestHand, determineWinners, compareHands };