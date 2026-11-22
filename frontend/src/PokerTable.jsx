import { useState, useEffect, useRef, useMemo } from 'react';
import { io } from 'socket.io-client';
import { API_URL, SOCKET_PRACTICE_URL, SOCKET_REAL_URL } from './config';
import { getSoundPrefs, setSoundPref, subscribeSoundPrefs } from './soundPrefs';

// ============================================================
// 🔥 EVALUADOR DE MANOS PARA EL FRONTEND 🔥
// ============================================================
const VALUE_MAP = { '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9, '10': 10, 'J': 11, 'Q': 12, 'K': 13, 'A': 14 };
const parseCard = (card) => { const suit = card.slice(-1); const valueStr = card.slice(0, -1); return { value: VALUE_MAP[valueStr], suit, valueStr }; };
const evaluate5 = (cards) => {
  const values = cards.map(c => c.value).sort((a, b) => b - a);
  const suits = cards.map(c => c.suit);
  const isFlush = suits.every(s => s === suits[0]);
  const uniqueVals = [...new Set(values)];
  let isStraight = false, straightHigh = 0;
  if (uniqueVals.length === 5) {
    if (uniqueVals[0] - uniqueVals[4] === 4) { isStraight = true; straightHigh = uniqueVals[0]; }
    else if (uniqueVals[0] === 14 && uniqueVals[1] === 5 && uniqueVals[4] === 2) { isStraight = true; straightHigh = 5; }
  }
  const counts = {}; values.forEach(v => (counts[v] = (counts[v] || 0) + 1));
  const groups = Object.entries(counts).map(([v, c]) => ({ v: Number(v), c })).sort((a, b) => b.c - a.c || b.v - a.v);
  if (isFlush && isStraight && straightHigh === 14) return { rank: 10, tiebreak: [14] };
  if (isFlush && isStraight) return { rank: 9, tiebreak: [straightHigh] };
  if (groups[0].c === 4) return { rank: 8, tiebreak: [groups[0].v, groups[1].v] };
  if (groups[0].c === 3 && groups[1].c === 2) return { rank: 7, tiebreak: [groups[0].v, groups[1].v] };
  if (isFlush) return { rank: 6, tiebreak: values };
  if (isStraight) return { rank: 5, tiebreak: [straightHigh] };
  if (groups[0].c === 3) return { rank: 4, tiebreak: [groups[0].v, ...groups.slice(1).map(g => g.v)] };
  if (groups[0].c === 2 && groups[1].c === 2) return { rank: 3, tiebreak: [groups[0].v, groups[1].v, groups[2].v] };
  if (groups[0].c === 2) return { rank: 2, tiebreak: [groups[0].v, ...groups.slice(1).map(g => g.v)] };
  return { rank: 1, tiebreak: values };
};
const compareHands = (a, b) => {
  if (a.rank !== b.rank) return a.rank - b.rank;
  const len = Math.max(a.tiebreak.length, b.tiebreak.length);
  for (let i = 0; i < len; i++) {
    const av = a.tiebreak[i] || 0, bv = b.tiebreak[i] || 0;
    if (av !== bv) return av - bv;
  }
  return 0;
};
const combinations = (arr, k) => {
  const res = [], combo = [];
  const helper = (start) => {
    if (combo.length === k) { res.push([...combo]); return; }
    for (let i = start; i < arr.length; i++) { combo.push(arr[i]); helper(i + 1); combo.pop(); }
  };
  helper(0);
  return res;
};
const getBestHandFrontend = (holeCards, communityCards) => {
  if (!holeCards || holeCards.length === 0) return null;
  const allCards = [...holeCards, ...communityCards];
  if (allCards.length < 5) return null;
  const parsed = allCards.map(parseCard);
  let best = null; let bestCombo = null;
  for (const c of combinations(parsed, 5)) {
    const e = evaluate5(c);
    if (!best || compareHands(e, best) > 0) { best = e; bestCombo = c; }
  }
  return bestCombo ? bestCombo.map(c => c.valueStr + c.suit) : null;
};

// ============================================================
// 🔥 MOTOR DE SONIDO SINTETIZADO (Web Audio API) 🔥
// ============================================================
const createSoundEngine = () => {
  let ctx = null;
  let masterVolume = 1;
  const getCtx = () => {
    if (!ctx) {
      const AC = window.AudioContext || window.webkitAudioContext;
      if (!AC) return null;
      ctx = new AC();
    }
    if (ctx.state === 'suspended') ctx.resume().catch(() => {});
    return ctx;
  };
  const tone = (freq, dur, type = 'sine', vol = 0.08, delay = 0) => {
    const c = getCtx(); if (!c) return;
    try {
      const osc = c.createOscillator();
      const gain = c.createGain();
      osc.type = type;
      osc.frequency.value = freq;
      const t0 = c.currentTime + delay;
      gain.gain.setValueAtTime(0.0001, t0);
      gain.gain.exponentialRampToValueAtTime(Math.max(vol * masterVolume, 0.0001), t0 + 0.01);
      gain.gain.exponentialRampToValueAtTime(0.0001, t0 + dur);
      osc.connect(gain); gain.connect(c.destination);
      osc.start(t0); osc.stop(t0 + dur + 0.05);
    } catch (e) {}
  };
  const noise = (dur = 0.12, vol = 0.12) => {
    const c = getCtx(); if (!c) return;
    try {
      const size = Math.floor(c.sampleRate * dur);
      const buffer = c.createBuffer(1, size, c.sampleRate);
      const data = buffer.getChannelData(0);
      for (let i = 0; i < size; i++) data[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / size, 2);
      const src = c.createBufferSource(); src.buffer = buffer;
      const filter = c.createBiquadFilter();
      filter.type = 'highpass'; filter.frequency.value = 800;
      const gain = c.createGain(); gain.gain.value = vol * masterVolume;
      src.connect(filter); filter.connect(gain); gain.connect(c.destination);
      src.start();
    } catch (e) {}
  };
  return {
    setVolume: (v) => { masterVolume = Math.max(0, Math.min(1, v)); },
    cardDeal:   () => { noise(0.15, 0.15); tone(1200, 0.05, 'triangle', 0.05); },
    chipBet:    () => { tone(2200, 0.04, 'square', 0.05); tone(2600, 0.04, 'square', 0.05, 0.05); tone(2400, 0.05, 'square', 0.04, 0.10); },
    turnAlert:  () => { tone(880, 0.15, 'sine', 0.10); tone(1320, 0.20, 'sine', 0.08, 0.18); },
    win:        () => { [523.25, 659.25, 783.99, 1046.5].forEach((f, i) => tone(f, 0.35, 'triangle', 0.10, i * 0.10)); },
    lose:       () => { tone(392, 0.25, 'sine', 0.07); tone(261.63, 0.4, 'sine', 0.07, 0.22); },
    fold:       () => { noise(0.08, 0.10); },
    check:      () => { tone(600, 0.08, 'sine', 0.06); },
    call:       () => { tone(900, 0.07, 'sine', 0.07); tone(700, 0.08, 'sine', 0.05, 0.07); },
    click:      () => { tone(1000, 0.04, 'square', 0.04); },
    allIn:      () => { [400, 500, 600, 700, 800, 900].forEach((f, i) => tone(f, 0.12, 'sawtooth', 0.07, i * 0.04)); },
    levelUp:    () => { [659.25, 783.99, 987.77].forEach((f, i) => tone(f, 0.22, 'triangle', 0.09, i * 0.12)); },
    timeWarn:   () => { tone(1400, 0.06, 'square', 0.07); },
    eliminated: () => { [440, 349.23, 261.63].forEach((f, i) => tone(f, 0.3, 'sawtooth', 0.08, i * 0.16)); },
  };
};

// ============================================================
// 💾 HELPERS DE PERSISTENCIA (COMPATIBLES CON Settings.jsx) 💾
// ============================================================
const readRoyalSettings = () => {
  try { return JSON.parse(localStorage.getItem('royalbet_settings') || '{}'); }
  catch { return {}; }
};
const writeRoyalSettings = (updates) => {
  try {
    const current = readRoyalSettings();
    localStorage.setItem('royalbet_settings', JSON.stringify({ ...current, ...updates }));
  } catch {}
};

// ============================================================
// 🎉 COMPONENTE CONFETTI (para cuando ganas el showdown) 🎉
// ============================================================
const Confetti = () => {
  const pieces = useMemo(() => Array.from({ length: 50 }).map((_, i) => ({
    id: i,
    left: Math.random() * 100,
    delay: Math.random() * 0.6,
    duration: 1.6 + Math.random() * 1.6,
    color: ['#fbbf24', '#ef4444', '#00e676', '#3b82f6', '#ec4899', '#f97316'][i % 6],
    rotate: Math.random() * 360,
    size: 6 + Math.random() * 8,
  })), []);
  return (
    <div style={{ position: 'fixed', inset: 0, pointerEvents: 'none', zIndex: 99998, overflow: 'hidden' }}>
      {pieces.map(p => (
        <div
          key={p.id}
          style={{
            position: 'absolute',
            left: `${p.left}%`,
            top: '-20px',
            width: `${p.size}px`,
            height: `${p.size}px`,
            background: p.color,
            borderRadius: '2px',
            animation: `confettiFall ${p.duration}s ease-in ${p.delay}s forwards`,
            transform: `rotate(${p.rotate}deg)`,
          }}
        />
      ))}
    </div>
  );
};

// ============================================================
// 🔥 COMPONENTE PARA DIBUJAR LAS CARTAS CON ANIMACIÓN 3D 🔥
// ============================================================
const PlayingCard = ({ cardString, width = '100px', height = '140px', style = {}, hidden = false, animate = false, reveal = false }) => {
  if (!cardString && !hidden) return null;

  const isMini = width === '14px';
  const isSmall = width === '22px' || width === '30px' || width === '35px' || width === '45px';
  const radius = isMini ? '2px' : '6px';

  let suit = '', rank = '', color = '#111';
  if (cardString) {
    suit = cardString.slice(-1);
    rank = cardString.slice(0, -1);
    if (suit === 's') suit = '♠';
    if (suit === 'h') suit = '♥';
    if (suit === 'd') suit = '♦';
    if (suit === 'c') suit = '♣';
    const isRed = suit === '♥' || suit === '♦';
    color = isRed ? '#d32f2f' : '#111';
  }

  const fontSizeRank = isMini ? '0.45rem' : (isSmall ? '0.8rem' : '1.4rem');
  const fontSizeSuit = isMini ? '0.4rem' : (isSmall ? '0.7rem' : '1.2rem');
  const padding = isMini ? '1px' : (isSmall ? '3px' : '6px 8px');

  const backFaceStyle = {
    position: 'absolute', width: '100%', height: '100%',
    backfaceVisibility: 'hidden',
    WebkitBackfaceVisibility: 'hidden',
    transform: 'rotateY(0deg)',
    background: 'repeating-linear-gradient(45deg, #1a202c, #1a202c 10px, #2d3748 10px, #2d3748 20px)',
    borderRadius: radius,
    border: '1px solid #555',
    boxShadow: '0 6px 12px rgba(0,0,0,0.8)',
    display: 'flex', justifyContent: 'center', alignItems: 'center',
  };

  const frontFaceStyle = {
    position: 'absolute', width: '100%', height: '100%',
    backfaceVisibility: 'hidden',
    WebkitBackfaceVisibility: 'hidden',
    transform: 'rotateY(180deg)',
    background: 'linear-gradient(135deg, #ffffff 0%, #e0e0e0 100%)',
    borderRadius: radius,
    boxShadow: '0 8px 16px rgba(0,0,0,0.7), inset 0 0 0 1px rgba(0,0,0,0.1)',
    display: 'flex', flexDirection: 'column', justifyContent: 'space-between',
    padding,
    fontFamily: '"Arial", sans-serif',
    color,
    userSelect: 'none',
  };

  const outerStyle = { width, height, ...style };
  const middleStyle = { width: '100%', height: '100%', animation: animate ? 'dealCard 0.4s ease-out forwards' : undefined };
  const flipperStyle = {
    width: '100%', height: '100%',
    position: 'relative',
    transformStyle: 'preserve-3d',
    transform: `perspective(1000px) rotateY(${hidden ? 0 : 180}deg)`,
    animation: reveal ? 'flipReveal 0.6s ease-out both' : undefined,
  };

  return (
    <div style={outerStyle}>
      <div style={middleStyle}>
        <div style={flipperStyle}>
          <div style={backFaceStyle}>
            <div style={{ width: '80%', height: '80%', border: '1px solid rgba(255,255,255,0.1)', borderRadius: '2px' }} />
          </div>
          <div style={frontFaceStyle}>
            {cardString && (
              <>
                <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-start', lineHeight: 1 }}>
                  <span style={{ fontSize: fontSizeRank, fontWeight: '900' }}>{rank}</span>
                  <span style={{ fontSize: fontSizeSuit }}>{suit}</span>
                </div>
                {!isMini && !isSmall && (
                  <div style={{ position: 'absolute', top: '50%', left: '50%', transform: 'translate(-50%, -50%)', fontSize: '3.5rem', opacity: 0.9 }}>{suit}</div>
                )}
                <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', lineHeight: 1, transform: 'rotate(180deg)' }}>
                  <span style={{ fontSize: fontSizeRank, fontWeight: '900' }}>{rank}</span>
                  <span style={{ fontSize: fontSizeSuit }}>{suit}</span>
                </div>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

// ============================================================
// 🔥 COMPONENTE VISUAL PARA LAS FICHAS (ESTILO CASINO REAL) 🔥
// ============================================================
const ChipStack = ({ amount }) => {
  if (amount <= 0) return null;

  const chipCount = Math.min(8, Math.max(1, Math.floor(amount / 10)));
  const colors = ['#e53935', '#1e88e5', '#43a047', '#fdd835'];

  const chips = [];
  for (let i = 0; i < chipCount; i++) {
    chips.push(
      <div key={i} style={{
        width: '26px', height: '26px',
        borderRadius: '50%',
        background: colors[i % colors.length],
        border: '3px dashed #fff',
        boxShadow: '0 4px 8px rgba(0,0,0,0.8), inset 0 0 6px rgba(0,0,0,0.4), 0 0 0 1px rgba(0,0,0,0.3)',
        marginTop: i > 0 ? '-20px' : '0',
        position: 'relative',
        zIndex: i
      }} />
    );
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', pointerEvents: 'none', animation: 'popIn 0.3s ease-out' }}>
      <div style={{ display: 'flex', flexDirection: 'column-reverse', alignItems: 'center' }}>
        {chips}
      </div>
      <div style={{
        background: 'linear-gradient(180deg, rgba(20,20,20,0.95), rgba(0,0,0,0.95))',
        color: '#fdd835',
        padding: '2px 10px',
        borderRadius: '12px',
        fontSize: '0.85rem',
        fontWeight: '900',
        marginTop: '5px',
        border: '1px solid #fdd835',
        boxShadow: '0 2px 6px rgba(0,0,0,0.9), inset 0 1px 0 rgba(255,255,255,0.1)'
      }}>
        {amount}
      </div>
    </div>
  );
};

// ============================================================
// 🔥 ICONOS SVG PARA EL MENÚ 🔥
// ============================================================
const Icons = {
  Back: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>,
  Exit: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>,
  Refresh: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M23 4v6h-6M1 20v-6h6"/><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"/></svg>,
  Fullscreen: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M8 3H5a2 2 0 0 0-2 2v3m18 0V5a2 2 0 0 0-2-2h-3m0 18h3a2 2 0 0 0 2-2v-3M3 16v3a2 2 0 0 0 2 2h3"/></svg>,
  Chip: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#a0aec0" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><circle cx="12" cy="12" r="4"/></svg>,
  Keyboard: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#a0aec0" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="2" y="4" width="20" height="16" rx="2"/><path d="M6 8h.01M10 8h.01M14 8h.01M18 8h.01M6 12h.01M10 12h.01M14 12h.01M18 12h.01M6 16h.01M10 16h.01M14 16h.01M18 16h.01"/></svg>,
  Document: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#a0aec0" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>,
  Share: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#a0aec0" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"/><polyline points="16 6 12 2 8 6"/><line x1="12" y1="2" x2="12" y2="15"/></svg>,
  Sound: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#a0aec0" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/><path d="M19.07 4.93a10 10 0 0 1 0 14.14M15.54 8.46a5 5 0 0 1 0 7.07"/></svg>,
  Settings: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#a0aec0" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>,
  ChevronRight: () => <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#718096" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
};

// ============================================================
// 🔥 CONFIGURACIÓN DE ASIENTOS: 9-max 🔥
// ============================================================
const SEAT_COUNT = 9;

const seatPositions = [
  { bottom: '-10%', left: '50%', transform: 'translateX(-50%)' },
  { bottom: '0%',   right: '20%' },
  { bottom: '20%',  right: '0%' },
  { top: '20%',     right: '0%' },
  { top: '0%',      right: '20%' },
  { top: '-10%',    left: '50%', transform: 'translateX(-50%)' },
  { top: '0%',      left: '20%' },
  { top: '20%',     left: '0%' },
  { bottom: '20%',  left: '0%' },
];

const betPositions = [
  { bottom: '12%', left: '50%', transform: 'translateX(-50%)' },
  { bottom: '20%', right: '28%' },
  { bottom: '35%', right: '12%' },
  { top: '35%',    right: '12%' },
  { top: '20%',    right: '28%' },
  { top: '12%',    left: '50%', transform: 'translateX(-50%)' },
  { top: '20%',    left: '28%' },
  { top: '35%',    left: '12%' },
  { bottom: '35%', left: '12%' },
];

// ============================================================
// 🎯 COMPONENTE PRINCIPAL
// ============================================================
// 🔥 MULTIMESA: isFocused = esta mesa es la visible (sonido completo).
// Las mesas en segundo plano NO reproducen efectos, solo aviso de turno
// si "Alertas multimesa" está activado (Ajustes → Sonido).
export default function PokerTable({ user, onExit, tableConfig, onMinimize, isFocused = true, onTurnStatus }) {
  const socketRef = useRef(null);
  const table = tableConfig?.tableData ?? tableConfig ?? {};
  const isPractice = table.isPractice === true;
  // 🔥 MTT: soporte de mesas de torneo (multimesa)
  const isTournament = table.isTournament === true || table.isTournament === 1;
  const tournamentGameId = table.gameId || null;
  const tableName = table.name || "OMAHA";
  const tableId = table.id || 'omaha-05-1';
  const onExitRef = useRef(onExit);
  useEffect(() => { onExitRef.current = onExit; }, [onExit]);
  const isFocusedRef = useRef(isFocused);
  useEffect(() => { isFocusedRef.current = isFocused; }, [isFocused]);
  const onTurnStatusRef = useRef(onTurnStatus);
  useEffect(() => { onTurnStatusRef.current = onTurnStatus; }, [onTurnStatus]);

  // 🔥 MÓVIL: detección responsive para rediseñar la mesa en pantallas pequeñas
  const [isMobile, setIsMobile] = useState(() =>
    typeof window !== 'undefined' && window.matchMedia('(max-width: 820px)').matches
  );
  useEffect(() => {
    const mq = window.matchMedia('(max-width: 820px)');
    const onChange = (e) => setIsMobile(e.matches);
    if (mq.addEventListener) mq.addEventListener('change', onChange);
    else mq.addListener(onChange);
    return () => {
      if (mq.removeEventListener) mq.removeEventListener('change', onChange);
      else mq.removeListener(onChange);
    };
  }, []);

  // ============================================================
  // 🎵 ESTADOS DE SONIDO Y EFECTOS (paso 1)
  // ============================================================
  const soundEngineRef = useRef(null);
  const soundStateRef = useRef({ communityCount: 0, currentTurn: null, totalBets: 0, phase: 'waiting' });
  const [isSettingsOpen, setIsSettingsOpen] = useState(false);

  // 🔊 SONIDO: estado inicial desde la fuente única (soundPrefs)
  const [soundPrefs, setSoundPrefs] = useState(() => getSoundPrefs());
  const { efectosSonoros: soundEnabled, volume, alertasMultimesa } = soundPrefs;
  const [animationsEnabled, setAnimationsEnabled] = useState(() => getSoundPrefs().animations);
  const soundEnabledRef = useRef(soundEnabled);
  useEffect(() => { soundEnabledRef.current = soundEnabled; }, [soundEnabled]);
  const alertasMultimesaRef = useRef(alertasMultimesa);
  useEffect(() => { alertasMultimesaRef.current = alertasMultimesa; }, [alertasMultimesa]);

  const [state, setState] = useState({
    seats: Array(SEAT_COUNT).fill(null),
    communityCards: [], pot: 0, phase: 'waiting', currentTurn: null,
    currentBet: 0, minRaise: 10, smallBlind: 0.25, bigBlind: 0.5,
  });
  const [myCards, setMyCards] = useState([]);
  const [mySocketId, setMySocketId] = useState(null);
  const [error, setError] = useState('');
  const [winnerMsg, setWinnerMsg] = useState('');
  const [blindMsg, setBlindMsg] = useState('');
  const [raiseAmount, setRaiseAmount] = useState(0.5);
  const [showManualBet, setShowManualBet] = useState(false);
  const [userBalance, setUserBalance] = useState(0);
  const [turnTime, setTurnTime] = useState(50);
  const [showdownData, setShowdownData] = useState(null);
  const [isChatOpen, setIsChatOpen] = useState(true);
  const [isHistoryOpen, setIsHistoryOpen] = useState(false);
  const [chatMessages, setChatMessages] = useState([{ user: 'Sistema', text: 'Bienvenido a RoyalBET.', type: 'system' }]);
  const [chatInput, setChatInput] = useState('');
  const [handHistory, setHandHistory] = useState(null);
  const chatEndRef = useRef(null);
  const [showBuyInModal, setShowBuyInModal] = useState(false);
  const [selectedSeat, setSelectedSeat] = useState(null);
  const [buyInAmount, setBuyInAmount] = useState(0);

  const [isBuyingIn, setIsBuyingIn] = useState(false);

  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const [showExitConfirm, setShowExitConfirm] = useState(false);

  const [showBustModal, setShowBustModal] = useState(false);
  const [isSpectatorMode, setIsSpectatorMode] = useState(false);
  // 🔥 MTT: podio final del torneo
  const [tournamentFinished, setTournamentFinished] = useState(null);
  const [mttInfo, setMttInfo] = useState({ blindLevel: 1, smallBlind: 25, bigBlind: 50 });

  const buyInLimits = table?.buyInLimit?.split(' - ') || ['20', '100'];
  const minBuyIn = isPractice ? 0 : Number(buyInLimits[0]);
  const maxBuyIn = isPractice ? 400 : Number(buyInLimits[1]);

  // ============================================================
  // 🎵 INICIALIZACIÓN DEL MOTOR DE SONIDO + DESBLOQUEO + PERSISTENCIA
  // ============================================================
  useEffect(() => {
    soundEngineRef.current = createSoundEngine();
  }, []);

  useEffect(() => {
    if (soundEngineRef.current) soundEngineRef.current.setVolume(soundEnabled ? volume : 0);
  }, [volume, soundEnabled]);

  // 🔊 SUSCRIPCIÓN a la fuente única de sonido: los cambios hechos en
  // Ajustes (o en otra mesa) se aplican al instante aquí, sin recargar.
  useEffect(() => {
    const unsub = subscribeSoundPrefs((prefs) => {
      setSoundPrefs(prefs);
      try { localStorage.setItem('poker_animations', String(prefs.animations)); } catch (e) {}
      setAnimationsEnabled(prefs.animations);
    });
    return unsub;
  }, []);

  // Desbloqueo del AudioContext en el primer gesto del usuario
  useEffect(() => {
    const unlock = () => {
      try {
        const AC = window.AudioContext || window.webkitAudioContext;
        if (AC) {
          const c = new AC();
          if (c.state === 'suspended') c.resume();
          c.close();
        }
      } catch (e) {}
      document.removeEventListener('pointerdown', unlock);
      document.removeEventListener('keydown', unlock);
    };
    document.addEventListener('pointerdown', unlock, { once: true });
    document.addEventListener('keydown', unlock, { once: true });
    return () => {
      document.removeEventListener('pointerdown', unlock);
      document.removeEventListener('keydown', unlock);
    };
  }, []);

  // 🎯 Disparadores de sonido basados en cambios de estado
  // 🔥 MULTIMESA: solo la mesa ENFOCADA suena; una mesa en segundo plano
  // únicamente avisa con turnAlert si "Alertas multimesa" está activado.
  useEffect(() => {
    const totalBets = state.seats.reduce((s, p) => s + (p?.currentBet || 0), 0);
    const foldedCount = state.seats.filter(p => p?.status === 'folded').length;
    const allInCount = state.seats.filter(p => p?.status === 'all-in').length;
    const prev = soundStateRef.current;
    const eng = soundEngineRef.current;

    const myTurnStarted = state.currentTurn === mySocketId && prev.currentTurn !== mySocketId && state.currentTurn !== null;

    // Mesa en SEGUNDO PLANO: solo alerta de turno (si el usuario la tiene activada)
    if (!isFocusedRef.current) {
      if (myTurnStarted && soundEnabled && alertasMultimesa && eng) {
        try { eng.turnAlert(); } catch (e) {}
      }
      soundStateRef.current = {
        communityCount: state.communityCards.length,
        currentTurn: state.currentTurn,
        totalBets,
        phase: state.phase,
        foldedCount,
        allInCount,
      };
      return;
    }

    if (soundEnabled && eng) {
      // Cartas comunitarias nuevas
      if (state.communityCards.length > prev.communityCount) {
        const diff = state.communityCards.length - prev.communityCount;
        for (let i = 0; i < diff; i++) setTimeout(() => eng.cardDeal(), i * 120);
      }
      // Fichas apostadas
      if (totalBets > prev.totalBets + 0.01) eng.chipBet();
      // 🔊 NUEVO: alguien pasó (fold)
      if (foldedCount > prev.foldedCount) eng.fold();
      // 🔊 NUEVO: alguien se fue all-in
      if (allInCount > prev.allInCount) eng.allIn();
      // Es mi turno
      if (myTurnStarted) eng.turnAlert();
      // Showdown: fanfarria SI gano, tono descendente si no (🔥 FIX del bug que sonaba igual)
      if (state.phase === 'showdown' && prev.phase !== 'showdown') {
        const winners = showdownData?.winners || [];
        const iWin = winners.some(w => w.username === user.username);
        if (iWin) eng.win();
        else eng.lose();
      }
    }

    soundStateRef.current = {
      communityCount: state.communityCards.length,
      currentTurn: state.currentTurn,
      totalBets,
      phase: state.phase,
      foldedCount,
      allInCount,
    };
  }, [state, mySocketId, soundEnabled, showdownData, user.username]);

  // 🔊 NUEVO: sonido al subir las ciegas
  useEffect(() => {
    if (soundEnabled && state.blindLevel && state.blindLevel > (mttInfo.blindLevel || 1)) {
      soundEngineRef.current?.levelUp();
    }
    setMttInfo(prev => ({
      ...prev,
      blindLevel: state.blindLevel ?? prev.blindLevel,
      smallBlind: state.smallBlind ?? prev.smallBlind,
      bigBlind: state.bigBlind ?? prev.bigBlind,
    }));
  }, [state.blindLevel, state.smallBlind, state.bigBlind]);

  // Toggles y helpers — 🔊 ahora escriben en la fuente única (soundPrefs)
  // para que Ajustes y las demás mesas se sincronicen al instante.
  const toggleSound = () => {
    const next = !soundEnabled;
    setSoundPref('efectosSonoros', next);
    if (next && soundEngineRef.current) setTimeout(() => soundEngineRef.current.turnAlert(), 120);
  };
  const toggleAnimations = () => setSoundPref('animations', !animationsEnabled);
  const handleVolumeChange = (v) => {
    setSoundPref('volume', v);
    if (soundEngineRef.current) soundEngineRef.current.setVolume(soundEnabled ? v : 0);
  };
  const playSound = (key) => {
    if (soundEnabled && soundEngineRef.current && soundEngineRef.current[key]) {
      try { soundEngineRef.current[key](); } catch (e) {}
    }
  };

  // ============================================================
  // ⏱️ TEMPORIZADOR DE TURNO
  // ============================================================
  useEffect(() => {
    if (!state.currentTurn) { setTurnTime(50); return; }
    setTurnTime(50);
    const interval = setInterval(() => {
      setTurnTime(prev => { if (prev <= 1) { clearInterval(interval); return 0; } return prev - 1; });
    }, 1000);
    return () => clearInterval(interval);
  }, [state.currentTurn]);

  const mySeatIndex = state.seats.findIndex(p => p !== null && p.socketId === mySocketId);
  const me = mySeatIndex !== -1 ? state.seats[mySeatIndex] : null;
  const isMyTurn = state.currentTurn === mySocketId && me?.status === 'playing';
  const toCall = me ? Math.max(0, state.currentBet - me.currentBet) : 0;

  // 🔊 MULTIMESA: avisar a la barra multimesa cuando es (o deja de ser) mi turno
  useEffect(() => {
    onTurnStatusRef.current && onTurnStatusRef.current(isMyTurn);
  }, [isMyTurn]);

  const minValidRaise = Math.max(state.currentBet + state.minRaise, state.bigBlind);
  const actualRaiseAmount = Math.max(raiseAmount, minValidRaise);

  useEffect(() => { chatEndRef.current?.scrollIntoView({ behavior: 'smooth' }); }, [chatMessages]);

  useEffect(() => {
    if (isMyTurn) {
      setShowManualBet(false);
      setRaiseAmount(minValidRaise);
    }
  }, [state.currentTurn, isMyTurn, minValidRaise]);

  // 🔊 NUEVO: aviso sonoro cuando quedan pocos segundos en mi turno
  useEffect(() => {
    if (isMyTurn && soundEnabled && turnTime > 0 && turnTime <= 5) {
      soundEngineRef.current?.timeWarn();
    }
  }, [turnTime, isMyTurn, soundEnabled]);

  // ============================================================
  // 🔌 SOCKET
  // ============================================================
  useEffect(() => {
    const isLocal = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';
    // 🔥 MTT: las mesas de torneo viven en el SERVIDOR PRINCIPAL (misma conexión que la práctica)
    let socketUrl = (isPractice || isTournament) ? (isLocal ? 'http://localhost:3000' : '') : (isLocal ? 'http://localhost:3001' : '');
    let socketPath = (isPractice || isTournament) ? '/socket.io' : (isLocal ? '/socket.io' : '/poker/socket.io');

    const token = localStorage.getItem('token');
    const socket = io(socketUrl, {
      path: socketPath,
      auth: { token: token },
      query: { token: token }
    });

    socketRef.current = socket;

    socket.on('connect', () => {
      setMySocketId(socket.id);
      if (isTournament) {
        // 🔥 MTT: conectar a mi mesa de torneo asignada por el servidor
        // 🔥 MULTIMESA: enviamos también tableId para apuntar a la mesa correcta
        socket.emit('join_tournament_table', { gameId: tournamentGameId, tableId });
      } else {
        socket.emit('joinTableRoom', tableId);
        if (isPractice) {
          if (!isSpectatorMode) socket.emit('join_practice_table', { id: user.id, username: user.username, avatar_url: user.avatar_url });
        } else {
          socket.emit('reconnect_player', { userId: user.id, tableId, username: user.username });
        }
      }
    });

    socket.on('tableUpdate', (s) => {
      setState(s);
      if (s.lastHandHistory) setHandHistory(s.lastHandHistory);
      if (s.phase !== 'showdown') setShowdownData(null);

      // 🔥 MTT: detectar si fui ELIMINADO (la mesa ya no tiene mi silla)
      if (isTournament) {
        const stillSeated = s.seats?.some(p => p && p.userId === user.id);
        if (!stillSeated && !isSpectatorMode) {
          setIsSpectatorMode(true);
          setShowBustModal(true);
          if (soundEnabledRef.current && soundEngineRef.current) {
            try { soundEngineRef.current.eliminated(); } catch (e) {}
          }
        }
      }
    });

    socket.on('table_update', (data) => {
      const newSeats = Array(SEAT_COUNT).fill(null);
      data.players.forEach(p => { if (p.seat < SEAT_COUNT) newSeats[p.seat] = { socketId: p.socketId, username: p.username, chips: p.chips, status: 'playing', currentBet: 0 }; });
      setState(prev => ({ ...prev, seats: newSeats, phase: data.status === 'PLAYING' ? 'playing' : 'waiting' }));
    });

    socket.on('chatMessage', (msg) => {
      const normalized = typeof msg === 'string'
        ? { user: 'Jugador', text: msg, type: 'user' }
        : { user: msg.user || 'Jugador', text: msg.text || '', type: msg.type || 'user' };
      setChatMessages(prev => [...prev, normalized]);
    });

    socket.on('yourCards', ({ cards }) => {
      setMyCards(cards || []);
      if (soundEnabledRef.current && soundEngineRef.current) {
        try { soundEngineRef.current.cardDeal(); } catch (e) {}
      }
    });

    socket.on('errorMsg', (msg) => { setError(msg); setTimeout(() => setError(''), 4000); });
    socket.on('blindIncreasePending', (data) => { setBlindMsg(data.message); setTimeout(() => setBlindMsg(''), 5000); });
    socket.on('blindLevelUp', (data) => { setBlindMsg(`¡Nuevo Nivel! Ciegas: ${data.smallBlind}/${data.bigBlind} NTX-20`); setTimeout(() => setBlindMsg(''), 5000); });
    socket.on('showdownResult', (r) => { setWinnerMsg(`🏆 Ganó: ${r.winners.map(x => x.username).join(', ')}`); setShowdownData(r); });
    socket.on('handWon', (r) => setWinnerMsg(`🏆 Ganó: ${r.winners.join(', ')}`));
    socket.on('countdown_start', (msg) => setError(msg));
    socket.on('countdown_cancel', (msg) => setError(msg));
    socket.on('game_started', () => setWinnerMsg('¡EL JUEGO HA COMENZADO!'));
    socket.on('error_mesa', (msg) => setError(msg));
    socket.on('leaveSuccess', () => onExitRef.current && onExitRef.current(tableId));

    // 🔥 MTT: podio final del torneo con premios
    socket.on('tournamentFinished', (data) => {
      setTournamentFinished(data);
      setWinnerMsg('');
    });
    socket.on('tournamentEnd', (podium) => {
      // La práctica emite solo el podio; el MTT emite tournamentFinished con premios
      if (!isTournament && podium) setTournamentFinished({ podium, practice: true });
    });

    if (!isPractice) {
      const fetchBalance = async () => {
        const token = localStorage.getItem('token');
        const apiBase = isLocal ? 'http://localhost:3000' : '';
        const res = await fetch(`${apiBase}/api/wallet`, { headers: { Authorization: `Bearer ${token}` } });
        const data = await res.json();
        if (res.ok) setUserBalance(data.balance_ntx);
      };
      fetchBalance();
    }
    return () => { socket.disconnect(); };
  }, [tableId, isPractice, isTournament, tournamentGameId, user.id, user.username, user.avatar_url]);

  // ============================================================
  // 🎮 ACCIONES
  // ============================================================
  const sendChatMessage = (e) => {
    e.preventDefault();
    if (chatInput.trim() && socketRef.current) {
      socketRef.current.emit('chatMessage', { user: user.username || 'Tú', text: chatInput, type: 'user' });
      setChatInput('');
    }
  };

  const executeLeaveTable = () => {
    setError('');
    setShowExitConfirm(false);
    // 🔥 MTT: salir del torneo = abandono (sin cash-out)
    if (isTournament) {
      socketRef.current?.emit('leave_tournament_table');
      onExitRef.current && onExitRef.current(tableId);
      return;
    }
    if (isPractice) { socketRef.current?.emit('leave_practice_table'); onExitRef.current && onExitRef.current(tableId); return; }
    if (state.phase === 'waiting' || state.phase === 'showdown') { onExitRef.current && onExitRef.current(tableId); return; }
    const seated = state.seats.findIndex(p => p !== null && p.socketId === mySocketId);
    if (seated === -1) onExitRef.current && onExitRef.current(tableId);
    else socketRef.current?.emit('leaveTable', { tableId });
  };

  const handleStandUp = () => {
    socketRef.current?.emit('standUp');
    setIsSpectatorMode(true);
    setWinnerMsg('');
  };

  const handleSpectatorPlus = () => {
    if (mySeatIndex !== -1) return;
    const emptySeatIndex = state.seats.findIndex(p => p === null);
    if (emptySeatIndex === -1) {
      setError('No hay sillas disponibles');
      setTimeout(() => setError(''), 3000);
      return;
    }
    handleSeatClick(emptySeatIndex);
  };

  const handleSeatClick = (index) => {
    if (mySeatIndex !== -1) return;
    if (state.seats[index] !== null) {
      setError('Esa silla ya está ocupada');
      setTimeout(() => setError(''), 3000);
      return;
    }

    if (isPractice) {
      if (socketRef.current && socketRef.current.connected) {
        setIsSpectatorMode(false);
        socketRef.current.emit('join_practice_table', { id: user.id, username: user.username, avatar_url: user.avatar_url });
        setError('Intentando tomar asiento...');
        setTimeout(() => setError(''), 3000);
      }
      return;
    }

    setSelectedSeat(index);
    setBuyInAmount(minBuyIn);
    setShowBuyInModal(true);
  };

  const confirmBuyIn = async () => {
    if (isBuyingIn) return;

    const occupyingPlayer = state.seats[selectedSeat];
    if (occupyingPlayer !== null && occupyingPlayer.socketId !== mySocketId) {
      setError('Esa silla ya está ocupada por otro jugador. Actualizando...');
      setShowBuyInModal(false);
      setSelectedSeat(null);
      setTimeout(() => setError(''), 3000);
      return;
    }

    if (buyInAmount < minBuyIn || buyInAmount > maxBuyIn) return setError(`Límite: ${minBuyIn} a ${maxBuyIn}`);
    if (buyInAmount > userBalance) return setError('¡Saldo insuficiente!');
    if (!socketRef.current || !socketRef.current.connected) return setError('El socket no está conectado.');

    setIsBuyingIn(true);

    try {
      const token = localStorage.getItem('token');
      const isLocal = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';
      const apiBase = isLocal ? 'http://localhost:3000' : '';
      const response = await fetch(`${apiBase}/api/poker/buy-in`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
        body: JSON.stringify({ amount: buyInAmount, tableId }),
      });
      const text = await response.text();
      let data = JSON.parse(text);
      if (!response.ok) throw new Error(data.error || 'Error al procesar el pago');

      const ack = await new Promise((resolve) => {
        const timer = setTimeout(() => resolve({ ok: false, error: 'Timeout al sentarse' }), 3000);
        socketRef.current.emit('sitDown', {
          tableId,
          seatIndex: me ? mySeatIndex : selectedSeat,
          userId: user.id,
          username: user.username,
          avatar_url: user.avatar_url,
          buyInAmount,
        }, (response) => {
          clearTimeout(timer);
          resolve(response || { ok: true });
        });
      });

      if (!ack.ok) {
        await fetch(`${apiBase}/api/poker/cash-out`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
          body: JSON.stringify({ amount: buyInAmount }),
        }).catch(() => {});
        setUserBalance(prev => prev + buyInAmount);
        throw new Error(ack.error || 'No se pudo sentar. Buy-in reembolsado.');
      }

      setUserBalance(data.newBalance);
      setShowBuyInModal(false);
      setIsSpectatorMode(false);
    } catch (err) {
      setError(err.message);
      setTimeout(() => setError(''), 4000);
    } finally {
      setIsBuyingIn(false);
    }
  };

  const handleRebuy = () => {
    if (isTournament) return; // 🔥 MTT: sin recargas en torneo
    socketRef.current?.emit('rebuy_practice');
    setError('Re-entrando con 400 fichas...');
    setTimeout(() => setError(''), 3000);
  };

  const action = (a, amount = 0) => {
    setError(''); setWinnerMsg('');
    setShowManualBet(false);
    socketRef.current?.emit('playerAction', { tableId, action: a, amount });
  };

  const toggleFullScreen = () => {
    if (!document.fullscreenElement) {
      document.documentElement.requestFullscreen().catch((err) => console.log(err.message));
    } else {
      if (document.exitFullscreen) document.exitFullscreen();
    }
    setIsSidebarOpen(false);
  };

  const handleRefresh = () => window.location.reload();

  const isHandInProgress = state.phase !== 'waiting' && state.phase !== 'showdown';
  const isShowdown = state.phase === 'showdown' && showdownData !== null;
  const isBroke = me && me.chips === 0 && !isHandInProgress;
  const isBettingPhase = state.seats.some(p => p !== null && p.currentBet > 0);
  const offset = mySeatIndex !== -1 ? mySeatIndex : 0;
  const iAmWinner = isShowdown && showdownData?.winners?.some(w => w.username === user.username);

  useEffect(() => {
    if (isBroke && mySeatIndex !== -1 && !isSpectatorMode && !showBustModal) {
      setShowBustModal(true);
    }
  }, [isBroke, mySeatIndex, isSpectatorMode, showBustModal]);

  return (
    <div
      className={animationsEnabled ? '' : 'no-animations'}
      style={{ height: '100vh', width: '100vw', backgroundColor: '#0d0f14', display: 'flex', flexDirection: 'column', overflow: 'hidden', fontFamily: '"Segoe UI", Roboto, Helvetica, Arial, sans-serif', position: 'relative', backgroundImage: 'radial-gradient(circle at center, #1a1f2e 0%, #0d0f14 100%)' }}
    >

      {/* 🔥 BARRA DE TIEMPO EN EL BORDE SUPERIOR 🔥 */}
      {isMyTurn && (
        <div style={{
          position: 'fixed', top: 0, left: 0,
          height: '6px',
          width: `${(turnTime / 50) * 100}%`,
          background: turnTime > 15 ? '#00e676' : '#ef4444',
          boxShadow: turnTime > 15 ? '0 0 10px #00e676' : '0 0 10px #ef4444',
          zIndex: 99999,
          transition: 'width 1s linear, background-color 0.3s'
        }} />
      )}

      <style>{`
        @keyframes popIn { 0% { transform: scale(0.5); opacity: 0; } 100% { transform: scale(1); opacity: 1; } }
        @keyframes dealCard { 0% { transform: translateY(-50px) scale(0.5); opacity: 0; } 100% { transform: translateY(0) scale(1); opacity: 1; } }
        @keyframes flipReveal { 0% { transform: perspective(1000px) rotateY(0deg); } 100% { transform: perspective(1000px) rotateY(180deg); } }
        @keyframes pulse-ring { 0% { box-shadow: 0 0 15px #7CFF00, 0 0 30px #7CFF00; } 50% { box-shadow: 0 0 25px #7CFF00, 0 0 50px #7CFF00; } 100% { box-shadow: 0 0 15px #7CFF00, 0 0 30px #7CFF00; } }
        @keyframes confettiFall { 0% { transform: translateY(0) rotate(0deg); opacity: 1; } 100% { transform: translateY(105vh) rotate(720deg); opacity: 0; } }
        @keyframes settingsPop { 0% { transform: scale(0.85); opacity: 0; } 100% { transform: scale(1); opacity: 1; } }

        .no-animations * { animation: none !important; }

        .sidebar-item { display: flex; align-items: center; padding: 12px 20px; color: #e2e8f0; cursor: pointer; transition: background 0.2s; border-bottom: 1px solid rgba(255,255,255,0.05); font-size: 0.95rem; }
        .sidebar-item:hover { background-color: rgba(255,255,255,0.05); }
        .sidebar-item-icon { margin-right: 15px; display: flex; align-items: center; justify-content: center; width: 24px; }

        .sidebar-item-exit { border-bottom: 2px solid rgba(255,255,255,0.1); }
        .sidebar-item-back { border-bottom: 2px solid rgba(255,255,255,0.1); padding: 20px; font-weight: bold; }

        .settings-toggle { width: 50px; height: 28px; border-radius: 14px; position: relative; cursor: pointer; transition: background 0.2s; }
        .settings-toggle-circle { width: 22px; height: 22px; border-radius: 50%; background: #fff; position: absolute; top: 3px; transition: left 0.2s; box-shadow: 0 2px 4px rgba(0,0,0,0.4); }

        /* 🔥 MÓVIL: el panel de acciones queda FIJO al fondo (sin hacks de escala) */
        @media (max-width: 768px) {
          .action-panel {
            position: fixed !important;
            bottom: 0 !important;
            left: 0 !important;
            right: 0 !important;
            width: 100% !important;
          }
        }
      `}</style>

      {/* 🎉 CONFETTI si gano el showdown */}
      {isShowdown && iAmWinner && animationsEnabled && <Confetti />}

      {/* HEADER IZQUIERDO: HAMBURGUESA + MUTE + CHAT (MÓVIL) + BOTÓN ESPECTADOR / SALIR */}
      <div className="top-left-menu" style={{ position: 'absolute', left: isMobile ? '8px' : '15px', top: isMobile ? '8px' : '20px', display: 'flex', alignItems: 'center', gap: '8px', zIndex: 100, maxWidth: 'calc(100vw - 130px)', flexWrap: 'wrap' }}>
        <div
          onClick={() => setIsSidebarOpen(true)}
          style={{ width: isMobile ? '36px' : '40px', height: isMobile ? '36px' : '40px', borderRadius: '50%', background: 'rgba(30,30,30,0.8)', display: 'flex', justifyContent: 'center', alignItems: 'center', cursor: 'pointer', color: '#fff', transition: '0.2s', border: '1px solid #444' }}
        >
          ☰
        </div>

        <button
          onClick={toggleSound}
          title={soundEnabled ? 'Silenciar sonido' : 'Activar sonido'}
          style={{
            width: isMobile ? '36px' : '40px', height: isMobile ? '36px' : '40px', borderRadius: '50%',
            background: soundEnabled ? 'rgba(30,30,30,0.8)' : 'rgba(200,30,30,0.8)',
            display: 'flex', justifyContent: 'center', alignItems: 'center',
            cursor: 'pointer', color: '#fff', fontSize: '1rem',
            border: '1px solid #444', transition: '0.2s'
          }}
        >
          {soundEnabled ? '🔊' : '🔇'}
        </button>

        {/* 🔥 MÓVIL: botón de chat/historial en la barra superior */}
        {isMobile && (
          <button
            onClick={() => setIsChatOpen(!isChatOpen)}
            style={{
              width: '36px', height: '36px', borderRadius: '50%',
              background: isChatOpen ? 'rgba(212,175,55,0.85)' : 'rgba(30,30,30,0.8)',
              display: 'flex', justifyContent: 'center', alignItems: 'center',
              cursor: 'pointer', color: '#fff', fontSize: '0.95rem', border: '1px solid #444'
            }}
          >
            💬
          </button>
        )}

        {mySeatIndex === -1 ? (
          isMobile ? (
            <div onClick={handleSpectatorPlus} style={{ display: 'flex', alignItems: 'center', background: '#E67E22', borderRadius: '18px', padding: '5px 10px', boxShadow: '0 4px 10px rgba(0,0,0,0.5)', cursor: 'pointer' }}>
              <span style={{ color: '#fff', fontWeight: 'bold', fontSize: '0.72rem' }}>👀 +</span>
            </div>
          ) : (
            <div style={{ display: 'flex', alignItems: 'center', background: '#E67E22', borderRadius: '20px', padding: '4px', paddingLeft: '15px', boxShadow: '0 4px 10px rgba(0,0,0,0.5)' }}>
              <span style={{ color: '#fff', fontWeight: 'bold', fontSize: '0.9rem', marginRight: '10px' }}>Espectador</span>
              <div
                onClick={handleSpectatorPlus}
                style={{ width: '28px', height: '28px', borderRadius: '50%', background: '#27AE60', display: 'flex', justifyContent: 'center', alignItems: 'center', cursor: 'pointer', color: '#fff', fontSize: '1.2rem', fontWeight: 'bold', transition: '0.2s' }}
              >
                +
              </div>
            </div>
          )
        ) : (
          !isSpectatorMode && (
            <button onClick={handleStandUp} style={{ background: '#ef4444', color: '#fff', border: 'none', padding: isMobile ? '8px 12px' : '10px 20px', borderRadius: '20px', fontWeight: 'bold', cursor: 'pointer', boxShadow: '0 4px 10px rgba(0,0,0,0.5)', transition: '0.2s', display: 'flex', alignItems: 'center', gap: isMobile ? '4px' : '8px', fontSize: isMobile ? '0.72rem' : '0.9rem' }}>
              <Icons.Exit /> {isMobile ? 'Levantarse' : 'Levantarse (Espectador)'}
            </button>
          )
        )}
      </div>

      {/* MENÚ LATERAL FLOTANTE */}
      {isSidebarOpen && (
        <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.7)', zIndex: 1000, display: 'flex' }} onClick={() => setIsSidebarOpen(false)}>
          <div style={{ width: '280px', height: '100%', background: '#1A1C23', borderRight: '1px solid #333', display: 'flex', flexDirection: 'column' }} onClick={(e) => e.stopPropagation()}>

            <div className="sidebar-item sidebar-item-back" onClick={() => { setIsSidebarOpen(false); if (onMinimize) onMinimize(); }}>
              <span className="sidebar-item-icon"><Icons.Back /></span> Volver al vestíbulo
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', paddingTop: '5px' }}>
              <div className="sidebar-item sidebar-item-exit" onClick={() => { setIsSidebarOpen(false); setShowExitConfirm(true); }}>
                <span className="sidebar-item-icon"><Icons.Exit /></span> Tabla de salida
              </div>
              <div className="sidebar-item" onClick={handleRefresh}>
                <span className="sidebar-item-icon"><Icons.Refresh /></span> Refrescar
              </div>
              <div className="sidebar-item" onClick={toggleFullScreen}>
                <span className="sidebar-item-icon"><Icons.Fullscreen /></span> Pantalla completa
              </div>
              <div className="sidebar-item" onClick={() => { setIsSidebarOpen(false); setIsSettingsOpen(true); }}>
                <span className="sidebar-item-icon"><Icons.Settings /></span> Ajustes de Mesa
              </div>
            </div>

          </div>
        </div>
      )}

      {/* INFO DE LA MESA */}
      <div className="table-info-box" style={{ position: 'absolute', top: isMobile ? '8px' : '20px', right: isMobile ? '8px' : '20px', background: '#0B1220', border: '1px solid #D4AF37', borderRadius: '10px', padding: isMobile ? '5px 10px' : '10px 20px', zIndex: 100, textAlign: 'right' }}>
        <h2 style={{ margin: 0, color: '#D4AF37', fontSize: isMobile ? '0.9rem' : '1.2rem', fontWeight: '900' }}>RoyalBET</h2>
        <div className="blinds" style={{ color: '#fff', fontSize: isMobile ? '0.66rem' : '0.9rem', marginTop: '3px' }}>
          {tableName} <span style={{ color: '#00e676', marginLeft: '6px' }}>
            {isTournament
              ? `Nv.${state.blindLevel || 1} · ${state.smallBlind}/${state.bigBlind}`
              : isPractice ? 'Freeroll' : `${state.smallBlind}/${state.bigBlind} NTX-20`}
          </span>
        </div>
        <div className="players" style={{ color: '#aaa', fontSize: isMobile ? '0.6rem' : '0.8rem', marginTop: '2px' }}>
          {isTournament
            ? `Vivos: ${state.seats.filter(p => p !== null && p.chips > 0).length}`
            : `Jugadores: ${state.seats.filter(p => p).length} / ${state.seats.length}`}
        </div>
        {isMyTurn && (
          <div style={{ color: turnTime > 15 ? '#00e676' : '#ef4444', fontSize: isMobile ? '0.9rem' : '1.2rem', fontWeight: 'bold', marginTop: '3px', animation: turnTime <= 10 ? 'pulse-ring 1s infinite' : 'none' }}>
            ⏱️ {turnTime}s
          </div>
        )}
      </div>

      {/* ALERTAS CENTRALES */}
      <div style={{ position: 'absolute', top: '80px', width: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '5px', zIndex: 50, pointerEvents: 'none' }}>
        {error && <span style={{ color: '#fff', fontWeight: 'bold', background: 'rgba(211, 47, 47, 0.9)', padding: '5px 15px', borderRadius: '15px' }}>{error}</span>}
        {winnerMsg && <span style={{ color: '#000', fontWeight: 'bold', background: 'rgba(0, 230, 118, 0.9)', padding: '5px 15px', borderRadius: '15px' }}>{winnerMsg}</span>}
        {blindMsg && <span style={{ color: '#fff', fontWeight: 'bold', background: 'rgba(59, 130, 246, 0.9)', padding: '5px 15px', borderRadius: '15px' }}>{blindMsg}</span>}
      </div>

      {/* CONTENEDOR PRINCIPAL DE LA MESA */}
      <div style={{ flex: 1, display: 'flex', justifyContent: 'center', alignItems: 'center', position: 'relative', overflow: 'hidden' }}>

        {/* 🔥 MÓVIL: mesa fluida que ocupa la pantalla (sin transform:scale hack) */}
        <div className="table-wrapper" style={{ position: 'relative', ...(isMobile ? { width: '94vw', maxWidth: '520px', height: 'min(54vh, 340px)' } : { width: '1000px', height: '550px' }) }}>

          {/* FONDO DE LA MESA ESTILO CASINO VINTAGE */}
          <div style={{
            position: 'absolute', top: 0, left: 0, right: 0, bottom: 0,
            background: 'linear-gradient(180deg, #5c3a1f 0%, #3a220e 50%, #1e1208 100%)',
            borderRadius: isMobile ? '160px' : '275px',
            border: isMobile ? '5px solid #1a0f04' : '8px solid #1a0f04',
            boxShadow: '0 40px 80px rgba(0,0,0,1), 0 10px 30px rgba(0,0,0,0.8), inset 0 0 20px rgba(0,0,0,0.6)'
          }}>
            <div style={{
              width: '100%', height: '100%',
              background: 'linear-gradient(180deg, #8b5a2b 0%, #6b4520 100%)',
              borderRadius: isMobile ? '154px' : '267px',
              padding: isMobile ? '4px' : '6px',
              boxSizing: 'border-box',
            }}>
              <div style={{
                width: '100%', height: '100%',
                background: 'radial-gradient(ellipse at center, #2e7d32 0%, #1b5e20 40%, #0d3b13 100%)',
                borderRadius: isMobile ? '150px' : '260px',
                boxShadow: 'inset 0 0 100px rgba(0,0,0,0.75), inset 0 0 30px rgba(0,0,0,0.5)',
                border: '2px solid rgba(0,0,0,0.3)',
                position: 'relative',
                overflow: 'hidden'
              }}>
                <div style={{
                  position: 'absolute', top: 0, left: 0, right: 0, bottom: 0,
                  backgroundImage: 'radial-gradient(circle, rgba(0,0,0,0.04) 1px, transparent 1px)',
                  backgroundSize: '4px 4px',
                  opacity: 0.6,
                }} />
                <h1 style={{
                  margin: 0, color: 'rgba(255,255,255,0.05)', fontSize: isMobile ? '2.2rem' : '5rem',
                  fontStyle: 'italic', fontWeight: '900', letterSpacing: isMobile ? '4px' : '10px',
                  position: 'absolute', top: '50%', left: '50%',
                  transform: 'translate(-50%, -50%)', userSelect: 'none', whiteSpace: 'nowrap',
                  textShadow: '0 2px 4px rgba(0,0,0,0.3)'
                }}>RoyalBET</h1>
              </div>
            </div>
          </div>

          {/* CARTEL DE ESPERANDO JUGADORES */}
          {state.phase === 'waiting' && mySeatIndex !== -1 && state.seats.filter(p => p !== null).length < 2 && (
            <div style={{
              position: 'absolute', top: '50%', left: '50%', transform: 'translate(-50%, -50%)',
              background: 'rgba(0,0,0,0.85)', padding: '20px 40px', borderRadius: '15px',
              border: '1px solid #D4AF37', color: '#D4AF37', textAlign: 'center', zIndex: 10,
              boxShadow: '0 10px 30px rgba(0,0,0,0.8)'
            }}>
              <h3 style={{ margin: 0, fontSize: '1.2rem', fontWeight: 'bold' }}>Esperando Jugadores...</h3>
              <p style={{ margin: '5px 0 0 0', color: '#ccc', fontSize: '0.9rem' }}>El juego comenzará cuando haya 2 o más jugadores.</p>
            </div>
          )}

          {/* POT Y CARTAS COMUNITARIAS */}
          <div style={{ position: 'absolute', top: '40%', left: '50%', transform: 'translate(-50%, -50%)', display: 'flex', flexDirection: 'column', alignItems: 'center', zIndex: 5 }}>
            <div style={{ background: '#111', padding: isMobile ? '3px 14px' : '5px 25px', borderRadius: '20px', color: '#F5E663', fontWeight: 'bold', border: '1px solid #333', fontSize: isMobile ? '0.85rem' : '1.2rem', marginBottom: isMobile ? '8px' : '15px', boxShadow: '0 4px 10px rgba(0,0,0,0.8)', whiteSpace: 'nowrap' }}>Pot: {state.pot}</div>
            <div style={{ display: 'flex', gap: isMobile ? '4px' : '8px', minHeight: isMobile ? '62px' : '110px' }}>
              {state.communityCards.map((card, i) => <PlayingCard key={i} cardString={card} width={isMobile ? '44px' : '85px'} height={isMobile ? '60px' : '115px'} animate={true} />)}
            </div>
            {state.pot > 0 && !isBettingPhase && !isMobile && <div style={{ position: 'absolute', bottom: '-80px', zIndex: 5 }}><ChipStack amount={state.pot} /></div>}
          </div>

          {/* JUGADORES */}
          {Array.from({ length: state.seats.length }).map((_, visualIndex) => {
            const totalSeats = state.seats.length;
            const realIndex = (offset + visualIndex) % totalSeats;
            const player = state.seats[realIndex];
            const pos = seatPositions[visualIndex] || {};
            const betPos = betPositions[visualIndex] || {};
            const isTurn = player?.socketId === state.currentTurn;
            const isMe = player?.socketId === mySocketId;
            const showdownPlayer = isShowdown ? showdownData.all.find(p => p.username === player?.username) : null;
            const isWinner = isShowdown ? showdownData.winners.some(w => w.username === player?.username) : false;

            const avatarUrl = player?.avatar_url ? player.avatar_url : `https://api.dicebear.com/7.x/adventurer/svg?seed=${player?.username || 'player'}`;

            const best5Cards = (player && isHandInProgress && state.communityCards.length >= 3)
              ? getBestHandFrontend(player.cards || (isMe ? myCards : []), state.communityCards)
              : null;

            return (
              <div key={visualIndex}>

                {/* ASIENTO */}
                <div style={{ position: 'absolute', ...pos, zIndex: 20, display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
                  {player ? (
                    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', opacity: player.status === 'folded' ? 0.4 : 1, transition: 'all 0.2s' }}>

                      {/* Cartas boca abajo de los rivales */}
                      {(!isMe && isHandInProgress && player.status !== 'folded' && player.chips > 0) && (
                        <div style={{ position: 'absolute', top: isMobile ? '-26px' : '-40px', left: '50%', transform: 'translateX(-50%)', display: 'flex', zIndex: 3 }}>
                          <PlayingCard hidden width={isMobile ? '22px' : '35px'} height={isMobile ? '32px' : '50px'} style={{ transform: 'rotate(-10deg)' }} animate={true} />
                          <PlayingCard hidden width={isMobile ? '22px' : '35px'} height={isMobile ? '32px' : '50px'} style={{ transform: 'rotate(10deg)', marginLeft: isMobile ? '-10px' : '-15px' }} animate={true} />
                        </div>
                      )}

                      {/* Cartas reveladas en el Showdown */}
                      {(isShowdown && showdownPlayer) && (
                        <div style={{ position: 'absolute', top: isMobile ? '-26px' : '-40px', left: '50%', transform: 'translateX(-50%)', display: 'flex', zIndex: 3 }}>
                          {showdownPlayer.cards.map((c, i) => (
                            <PlayingCard key={i} cardString={c} width={isMobile ? '22px' : '35px'} height={isMobile ? '32px' : '50px'} style={{ transform: `rotate(${i === 0 ? -8 : 8}deg)`, marginLeft: i === 1 ? (isMobile ? '-10px' : '-15px') : '0' }} reveal={true} />
                          ))}
                        </div>
                      )}

                      <div style={{ position: 'relative' }}>
                        <div style={{
                          width: isMobile ? '52px' : '80px', height: isMobile ? '52px' : '80px', borderRadius: '50%', background: '#111',
                          border: isWinner ? '3px solid #e2b04a' : (isTurn ? '3px solid #7CFF00' : '3px solid #333'),
                          display: 'flex', justifyContent: 'center', alignItems: 'center',
                          boxShadow: isWinner ? '0 0 25px rgba(226, 176, 74, 0.8)' : (isTurn ? '0 0 20px #7CFF00' : '0 10px 20px rgba(0,0,0,0.9)'),
                          position: 'relative', overflow: 'hidden', zIndex: 2
                        }}>
                          <img src={avatarUrl} alt="avatar" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                        </div>

                        {isTurn && !isShowdown && (
                          <svg style={{ position: 'absolute', top: '-5px', left: '-5px', width: isMobile ? '62px' : '90px', height: isMobile ? '62px' : '90px', transform: 'rotate(-90deg)', zIndex: 3 }}>
                            <circle cx={isMobile ? 31 : 45} cy={isMobile ? 31 : 45} r={isMobile ? 28 : 41} stroke="#7CFF00" strokeWidth="4" fill="none" strokeDasharray={isMobile ? 176 : 257} strokeDashoffset={(isMobile ? 176 : 257) - (turnTime / 50) * (isMobile ? 176 : 257)} style={{ transition: 'stroke-dashoffset 1s linear', filter: 'drop-shadow(0 0 5px #7CFF00)' }} />
                          </svg>
                        )}

                        {realIndex === state.dealerIndex && (
                          <div style={{ position: 'absolute', bottom: '-5px', right: '-5px', background: '#fff', color: '#000', borderRadius: '50%', width: isMobile ? '18px' : '24px', height: isMobile ? '18px' : '24px', fontSize: isMobile ? '0.6rem' : '0.85rem', fontWeight: 'bold', display: 'flex', justifyContent: 'center', alignItems: 'center', border: '2px solid #000', zIndex: 21 }}>D</div>
                        )}

                        {best5Cards && !isMobile && (
                          <div style={{ position: 'absolute', top: '50%', left: visualIndex === 0 ? '105%' : 'auto', right: visualIndex === 0 ? 'auto' : '105%', transform: 'translateY(-50%)', display: 'flex', gap: '1px', zIndex: 30, background: 'rgba(20, 20, 20, 0.95)', padding: '3px', borderRadius: '4px', border: '1px solid rgba(255,215,0,0.5)', boxShadow: '0 4px 8px rgba(0,0,0,0.8)', alignItems: 'center', whiteSpace: 'nowrap' }}>
                            {best5Cards.map((c, i) => <PlayingCard key={i} cardString={c} width="18px" height="25px" />)}
                          </div>
                        )}
                      </div>

                      {/* Caja de Nombre y Fichas */}
                      <div style={{ background: '#0B1220', color: '#fff', fontSize: isMobile ? '0.62rem' : '0.85rem', padding: isMobile ? '2px 6px' : '4px 10px', borderRadius: isMobile ? '6px' : '8px', marginTop: isMobile ? '-8px' : '-10px', width: 'auto', minWidth: isMobile ? '62px' : '90px', textAlign: 'center', border: isTurn ? '1px solid #7CFF00' : '1px solid #333', zIndex: 20, display: 'flex', flexDirection: 'column', alignItems: 'center', boxShadow: '0 4px 8px rgba(0,0,0,0.8)' }}>
                        <span style={{ fontWeight: 'bold', color: '#ccc', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', maxWidth: isMobile ? '58px' : '85px' }}>{player.username}</span>
                        <span style={{ color: '#F5E663', fontWeight: '900', fontSize: isMobile ? '0.72rem' : '1rem' }}>{player.chips}</span>
                      </div>

                      {/* Tus cartas */}
                      {isMe && myCards.length > 0 && !isBroke && !isSpectatorMode && (
                        <div style={{ position: 'absolute', bottom: isMobile ? '-64px' : '-110px', left: '50%', transform: 'translateX(-50%)', display: 'flex', gap: isMobile ? '4px' : '5px', zIndex: 15 }}>
                          {myCards.map((c, i) => (
                            <PlayingCard key={i} cardString={c} width={isMobile ? '46px' : '75px'} height={isMobile ? '64px' : '105px'} style={{ transform: `rotate(${i === 0 ? -3 : 3}deg) translateY(${i === 0 ? 5 : 0}px)` }} animate={true} />
                          ))}
                        </div>
                      )}

                    </div>
                  ) : (
                    <div
                      onClick={() => !isBuyingIn && handleSeatClick(realIndex)}
                      style={{
                        width: isMobile ? '46px' : '80px', height: isMobile ? '46px' : '80px', borderRadius: '50%', background: '#1B1C24',
                        border: '2px dashed #444', display: 'flex', justifyContent: 'center', alignItems: 'center',
                        cursor: (mySeatIndex !== -1 || isBuyingIn) ? 'default' : 'pointer',
                        boxShadow: 'inset 0 4px 10px rgba(0,0,0,0.8)', transition: 'all 0.2s', pointerEvents: 'auto', zIndex: 30
                      }}
                      onMouseOver={(e) => { if (mySeatIndex === -1 && !isBuyingIn) e.currentTarget.style.border = '2px solid #D4AF37'; }}
                      onMouseOut={(e) => { if (mySeatIndex === -1 && !isBuyingIn) e.currentTarget.style.border = '2px dashed #444'; }}
                    >
                      <span style={{ fontSize: isMobile ? '1.2rem' : '2rem', color: '#555', fontWeight: '300', userSelect: 'none' }}>+</span>
                    </div>
                  )}
                </div>

                {player && player.currentBet > 0 && (
                  <div style={{ position: 'absolute', ...betPos, zIndex: 15 }}>
                    <ChipStack amount={player.currentBet} />
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </div>

      {/* ZONA INFERIOR: CHAT + BOTONES (solo escritorio) */}
      {!isMobile && (
      <div style={{ position: 'absolute', bottom: '20px', left: '20px', zIndex: 100, display: 'flex', flexDirection: 'column', gap: '10px' }}>

        <button onClick={() => { setIsHistoryOpen(!isHistoryOpen); setIsChatOpen(false); }} style={{ alignSelf: 'flex-start', background: '#0B1220', color: '#fff', border: '1px solid #333', padding: '6px 12px', borderRadius: '5px', cursor: 'pointer', fontSize: '0.8rem', display: 'flex', alignItems: 'center', gap: '5px' }}>📜 Historial</button>

        {isHistoryOpen && handHistory && (
          <div style={{ width: '300px', background: '#0B1220', border: '1px solid #333', borderRadius: '8px', display: 'flex', flexDirection: 'column', boxShadow: '0 10px 30px rgba(0,0,0,0.9)' }}>
            <div style={{ padding: '10px 15px', borderBottom: '1px solid #333', display: 'flex', justifyContent: 'space-between', alignItems: 'center', background: '#1B1C24', borderTopLeftRadius: '8px', borderTopRightRadius: '8px' }}>
              <h4 style={{ margin: 0, color: '#D4AF37', fontSize: '0.9rem', fontWeight: 'bold' }}>Última Mano</h4>
              <button onClick={() => setIsHistoryOpen(false)} style={{ background: 'transparent', border: 'none', color: '#888', cursor: 'pointer', fontSize: '1.2rem' }}>✕</button>
            </div>
            <div style={{ padding: '10px', maxHeight: '200px', overflowY: 'auto' }}>
              {handHistory.winners && handHistory.winners.map((w, idx) => (
                <div key={idx} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', background: 'rgba(212, 175, 55, 0.1)', padding: '8px', borderRadius: '6px', marginBottom: '5px', border: '1px solid rgba(212, 175, 55, 0.3)' }}>
                  <span style={{ color: '#D4AF37', fontSize: '0.85rem', fontWeight: 'bold' }}>🏆 {w.username}</span>
                  <div style={{ display: 'flex', gap: '4px', background: 'rgba(0,0,0,0.5)', padding: '3px 6px', borderRadius: '4px' }}>
                    {w.cards && w.cards.map((c, i) => <PlayingCard key={i} cardString={c} width="20px" height="28px" />)}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {isChatOpen && (
          <div style={{ width: '260px', height: '160px', background: 'rgba(11, 18, 32, 0.9)', border: '1px solid #333', borderRadius: '8px', display: 'flex', flexDirection: 'column', padding: '10px' }}>
            <div style={{ flex: 1, overflowY: 'auto', color: '#ccc', fontSize: '0.8rem', display: 'flex', flexDirection: 'column', gap: '5px' }}>
              {chatMessages.map((msg, i) => (<div key={i}><span style={{ color: msg.type === 'system' ? '#3b82f6' : '#D4AF37', fontWeight: 'bold' }}>{msg.user}:</span> {msg.text}</div>))}
              <div ref={chatEndRef} />
            </div>
            <form onSubmit={sendChatMessage} style={{ display: 'flex', gap: '5px', marginTop: '5px' }}>
              <input type="text" value={chatInput} onChange={(e) => setChatInput(e.target.value)} placeholder="Di algo..." style={{ flex: 1, background: '#1B1C24', border: '1px solid #333', color: '#fff', padding: '6px', borderRadius: '4px', outline: 'none', fontSize: '0.8rem' }} />
              <button type="submit" style={{ background: '#D4AF37', border: 'none', color: '#000', padding: '0 12px', borderRadius: '4px', fontWeight: 'bold', cursor: 'pointer' }}>➤</button>
            </form>
          </div>
        )}

        {!isChatOpen && <button onClick={() => { setIsChatOpen(true); setIsHistoryOpen(false); }} style={{ alignSelf: 'flex-start', background: '#0B1220', color: '#fff', border: '1px solid #333', padding: '6px 12px', borderRadius: '5px', cursor: 'pointer', fontSize: '0.8rem', display: 'flex', alignItems: 'center', gap: '5px' }}>💬 Chat</button>}
      </div>
      )}

      {/* 🔥 MÓVIL: chat como cajón a pantalla completa desde la izquierda */}
      {isMobile && isChatOpen && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.6)', zIndex: 900 }} onClick={() => setIsChatOpen(false)}>
          <div style={{ position: 'absolute', left: 0, top: 0, bottom: 0, width: '82vw', maxWidth: '340px', background: '#0B1220', borderRight: '1px solid #333', display: 'flex', flexDirection: 'column' }} onClick={(e) => e.stopPropagation()}>
            <div style={{ padding: '12px 14px', borderBottom: '1px solid #333', display: 'flex', justifyContent: 'space-between', alignItems: 'center', background: '#1B1C24' }}>
              <h4 style={{ margin: 0, color: '#D4AF37', fontSize: '0.9rem', fontWeight: 'bold' }}>💬 Chat de la mesa</h4>
              <button onClick={() => setIsChatOpen(false)} style={{ background: 'transparent', border: 'none', color: '#888', cursor: 'pointer', fontSize: '1.2rem' }}>✕</button>
            </div>
            <div style={{ flex: 1, overflowY: 'auto', padding: '10px 14px', color: '#ccc', fontSize: '0.82rem', display: 'flex', flexDirection: 'column', gap: '6px' }}>
              {chatMessages.map((msg, i) => (<div key={i}><span style={{ color: msg.type === 'system' ? '#3b82f6' : '#D4AF37', fontWeight: 'bold' }}>{msg.user}:</span> {msg.text}</div>))}
              <div ref={chatEndRef} />
            </div>
            <form onSubmit={sendChatMessage} style={{ display: 'flex', gap: '6px', padding: '10px', borderTop: '1px solid #333', paddingBottom: 'calc(10px + env(safe-area-inset-bottom))' }}>
              <input type="text" value={chatInput} onChange={(e) => setChatInput(e.target.value)} placeholder="Di algo..." style={{ flex: 1, background: '#1B1C24', border: '1px solid #333', color: '#fff', padding: '10px', borderRadius: '8px', outline: 'none', fontSize: '0.85rem' }} />
              <button type="submit" style={{ background: '#D4AF37', border: 'none', color: '#000', padding: '0 16px', borderRadius: '8px', fontWeight: 'bold', cursor: 'pointer' }}>➤</button>
            </form>
          </div>
        </div>
      )}

      {/* 🔥 MÓVIL: tus cartas fijas sobre el panel de acciones (siempre visibles) */}
      {isMobile && isMyTurn === false && myCards.length > 0 && !isBroke && !isSpectatorMode && mySeatIndex !== -1 && (
        <div style={{ position: 'fixed', bottom: '158px', left: '50%', transform: 'translateX(-50%)', display: 'flex', gap: '4px', zIndex: 60 }}>
          {myCards.map((c, i) => (
            <PlayingCard key={i} cardString={c} width="46px" height="64px" style={{ transform: `rotate(${i === 0 ? -3 : 3}deg)` }} animate={true} />
          ))}
        </div>
      )}

      {/* PANEL DE APUESTAS */}
      <div className="action-panel" style={{ position: 'absolute', bottom: isMobile ? 0 : '20px', right: isMobile ? 0 : '20px', left: isMobile ? 0 : 'auto', zIndex: 100, display: 'flex', flexDirection: 'column', gap: isMobile ? '6px' : '8px', width: isMobile ? '100%' : '360px', padding: isMobile ? '8px 10px calc(8px + env(safe-area-inset-bottom))' : '0', background: isMobile ? '#0B1220' : 'transparent', borderTop: isMobile ? '2px solid #2d3748' : 'none', borderRadius: isMobile ? '14px 14px 0 0' : '0' }}>

        {isHandInProgress && !isBroke && mySeatIndex !== -1 && !isSpectatorMode && (
          <div style={{ display: 'flex', gap: '4px', justifyContent: isMobile ? 'center' : 'flex-end', flexWrap: isMobile ? 'nowrap' : 'wrap' }}>
            <button onClick={() => { setRaiseAmount(Math.max(Math.floor(state.pot * 0.33), minValidRaise)); setShowManualBet(true); }} style={{ flex: 1, padding: isMobile ? '8px 0' : '6px 0', background: '#1B1C24', color: '#aaa', border: '1px solid #333', borderRadius: '5px', cursor: 'pointer', fontSize: isMobile ? '0.7rem' : '0.75rem' }}>33%</button>
            <button onClick={() => { setRaiseAmount(Math.max(Math.floor(state.pot * 0.50), minValidRaise)); setShowManualBet(true); }} style={{ flex: 1, padding: isMobile ? '8px 0' : '6px 0', background: '#1B1C24', color: '#aaa', border: '1px solid #333', borderRadius: '5px', cursor: 'pointer', fontSize: isMobile ? '0.7rem' : '0.75rem' }}>50%</button>
            <button onClick={() => { setRaiseAmount(Math.max(Math.floor(state.pot * 0.75), minValidRaise)); setShowManualBet(true); }} style={{ flex: 1, padding: isMobile ? '8px 0' : '6px 0', background: '#1B1C24', color: '#aaa', border: '1px solid #333', borderRadius: '5px', cursor: 'pointer', fontSize: isMobile ? '0.7rem' : '0.75rem' }}>75%</button>
            <button onClick={() => { setRaiseAmount(me ? me.chips + me.currentBet : 0); setShowManualBet(true); }} style={{ flex: 1, padding: isMobile ? '8px 0' : '6px 0', background: '#1B1C24', color: '#D4AF37', border: '1px solid #D4AF37', borderRadius: '5px', cursor: 'pointer', fontSize: isMobile ? '0.7rem' : '0.75rem', fontWeight: 'bold' }}>All-In</button>
          </div>
        )}

        {isHandInProgress && !isBroke && mySeatIndex !== -1 && !isSpectatorMode && (
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', background: '#0B1220', padding: isMobile ? '6px 8px' : '10px', borderRadius: '8px', border: '1px solid #333' }}>
            <button onClick={() => setRaiseAmount(prev => Math.max(minValidRaise, prev - (state.bigBlind || 1)))} style={{ width: isMobile ? '32px' : '25px', height: isMobile ? '32px' : '25px', background: '#333', color: '#fff', border: 'none', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold' }}>-</button>
            <input type="range" value={raiseAmount} onChange={e => { setRaiseAmount(Number(e.target.value)); setShowManualBet(true); }} min={minValidRaise} step={state.bigBlind || 1} max={me ? me.chips + me.currentBet : 100} disabled={!isMyTurn} style={{ flex: 1, accentColor: '#D4AF37' }} />
            <button onClick={() => setRaiseAmount(prev => Math.min(me ? me.chips + me.currentBet : 100, prev + (state.bigBlind || 1)))} style={{ width: isMobile ? '32px' : '25px', height: isMobile ? '32px' : '25px', background: '#333', color: '#fff', border: 'none', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold' }}>+</button>
            <input type="number" value={raiseAmount} onChange={e => { setRaiseAmount(Number(e.target.value)); setShowManualBet(true); }} style={{ width: isMobile ? '58px' : '60px', background: '#1B1C24', color: '#fff', border: '1px solid #333', padding: '5px', borderRadius: '4px', textAlign: 'center', fontWeight: 'bold' }} />
          </div>
        )}

        <div style={{ display: 'flex', gap: isMobile ? '6px' : '8px' }}>
          {isSpectatorMode ? (
            <span style={{ color: '#D4AF37', fontWeight: 'bold', width: '100%', textAlign: 'center', background: '#0B1220', padding: '15px', borderRadius: '8px', border: '1px solid #D4AF37' }}>Modo Espectador 👁️</span>
          ) : mySeatIndex === -1 ? (
            <span style={{ color: '#888', fontWeight: 'bold', width: '100%', textAlign: 'center', background: '#0B1220', padding: '15px', borderRadius: '8px' }}>Toma asiento para jugar</span>
          ) : isBroke ? (
            <span style={{ color: '#ef4444', fontWeight: 'bold', width: '100%', textAlign: 'center', background: '#0B1220', padding: '15px', borderRadius: '8px' }}>Sin fichas - Eliminado</span>
          ) : !isHandInProgress ? (
            <span style={{ color: '#888', fontWeight: 'bold', width: '100%', textAlign: 'center', background: '#0B1220', padding: '15px', borderRadius: '8px' }}>Esperando nueva mano...</span>
          ) : (
            <>
              <button disabled={!isMyTurn} onClick={() => { playSound('fold'); action('fold'); }} style={{ flex: 1, padding: isMobile ? '16px 0' : '15px 0', background: isMyTurn ? 'linear-gradient(180deg, #d32f2f 0%, #b71c1c 100%)' : '#1a1a1a', color: isMyTurn ? '#fff' : '#444', border: 'none', borderRadius: '8px', fontWeight: 'bold', fontSize: isMobile ? '0.95rem' : '1rem', cursor: isMyTurn ? 'pointer' : 'not-allowed', WebkitTapHighlightColor: 'transparent' }}>Pasar</button>
              <button disabled={!isMyTurn} onClick={() => { playSound(toCall > 0 ? 'call' : 'check'); action(toCall > 0 ? 'call' : 'check'); }} style={{ flex: 1.4, padding: isMobile ? '16px 0' : '15px 0', background: isMyTurn ? 'linear-gradient(180deg, #1976d2 0%, #0d47a1 100%)' : '#1a1a1a', color: isMyTurn ? '#fff' : '#444', border: 'none', borderRadius: '8px', fontWeight: 'bold', fontSize: isMobile ? '0.95rem' : '1rem', cursor: isMyTurn ? 'pointer' : 'not-allowed', WebkitTapHighlightColor: 'transparent' }}>
                {toCall > 0 ? `Igualar ${toCall}` : 'Pasar turno'}
              </button>
              <button disabled={!isMyTurn} onClick={() => { playSound('chipBet'); action('raise', actualRaiseAmount); }} style={{ flex: 1.4, padding: isMobile ? '16px 0' : '15px 0', background: isMyTurn ? 'linear-gradient(180deg, #e2b04a 0%, #b48521 100%)' : '#1a1a1a', color: isMyTurn ? '#000' : '#444', border: 'none', borderRadius: '8px', fontWeight: 'bold', fontSize: isMobile ? '0.95rem' : '1rem', cursor: isMyTurn ? 'pointer' : 'not-allowed', WebkitTapHighlightColor: 'transparent' }}>
                {toCall > 0 ? `Subir a ${actualRaiseAmount}` : `Apostar ${actualRaiseAmount}`}
              </button>
            </>
          )}
        </div>
      </div>

      {/* ⚙️ MODAL DE AJUSTES DE MESA */}
      {isSettingsOpen && (
        <div
          onClick={() => setIsSettingsOpen(false)}
          style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.85)', zIndex: 99999, display: 'flex', justifyContent: 'center', alignItems: 'center', backdropFilter: 'blur(8px)' }}
        >
          <div
            onClick={e => e.stopPropagation()}
            style={{ background: '#171b24', padding: '30px', borderRadius: '14px', width: '440px', maxWidth: '92vw', border: '1px solid #2d3748', boxShadow: '0 20px 50px rgba(0,0,0,0.9)', animation: 'settingsPop 0.25s ease-out' }}
          >
            <h2 style={{ color: '#D4AF37', margin: '0 0 5px 0', fontSize: '1.4rem', textAlign: 'center', fontWeight: '900' }}>
              ⚙️ Ajustes de Mesa
            </h2>
            <p style={{ color: '#718096', fontSize: '0.8rem', textAlign: 'center', margin: '0 0 20px 0' }}>
              Configura sonidos y efectos visuales
            </p>

            {/* 🔊 Sonido */}
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px 0', borderBottom: '1px solid #2d3748' }}>
              <div>
                <div style={{ color: '#fff', fontWeight: 'bold', fontSize: '0.95rem' }}>🔊 Efectos de sonido</div>
                <div style={{ color: '#718096', fontSize: '0.78rem', marginTop: '3px' }}>Cartas, fichas, turnos y victoria</div>
              </div>
              <div
                onClick={toggleSound}
                className="settings-toggle"
                style={{ background: soundEnabled ? '#10b981' : '#4a5568' }}
              >
                <div className="settings-toggle-circle" style={{ left: soundEnabled ? '25px' : '3px' }} />
              </div>
            </div>

            {/* 🔉 Volumen */}
            <div style={{ padding: '15px 0', borderBottom: '1px solid #2d3748', opacity: soundEnabled ? 1 : 0.4 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', color: '#fff', fontWeight: 'bold', marginBottom: '10px', fontSize: '0.95rem' }}>
                <span>🔉 Volumen</span>
                <span style={{ color: '#D4AF37' }}>{Math.round(volume * 100)}%</span>
              </div>
              <input
                type="range" min={0} max={1} step={0.05} value={volume}
                disabled={!soundEnabled}
                onChange={e => handleVolumeChange(Number(e.target.value))}
                style={{ width: '100%', accentColor: '#D4AF37' }}
              />
              <button
                onClick={() => soundEngineRef.current?.turnAlert()}
                disabled={!soundEnabled}
                style={{ marginTop: '10px', padding: '6px 14px', background: '#2d3748', color: '#fff', border: 'none', borderRadius: '6px', cursor: soundEnabled ? 'pointer' : 'not-allowed', fontSize: '0.78rem', fontWeight: 'bold' }}
              >
                ▶ Probar sonido
              </button>
            </div>

            {/* ✨ Animaciones */}
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px 0' }}>
              <div>
                <div style={{ color: '#fff', fontWeight: 'bold', fontSize: '0.95rem' }}>✨ Animaciones y efectos</div>
                <div style={{ color: '#718096', fontSize: '0.78rem', marginTop: '3px' }}>Reparto de cartas, fichas, confetti</div>
              </div>
              <div
                onClick={toggleAnimations}
                className="settings-toggle"
                style={{ background: animationsEnabled ? '#10b981' : '#4a5568' }}
              >
                <div className="settings-toggle-circle" style={{ left: animationsEnabled ? '25px' : '3px' }} />
              </div>
            </div>

            <button
              onClick={() => setIsSettingsOpen(false)}
              style={{ width: '100%', marginTop: '20px', padding: '13px', background: 'linear-gradient(180deg, #D4AF37 0%, #b48521 100%)', color: '#000', border: 'none', borderRadius: '8px', fontWeight: 'bold', fontSize: '1rem', cursor: 'pointer' }}
            >
              Cerrar
            </button>
          </div>
        </div>
      )}

      {/* MODAL DE ELIMINACIÓN / SIN FICHAS */}
      {showBustModal && (
        <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.85)', backdropFilter: 'blur(5px)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 9999 }}>
          <div style={{ background: 'linear-gradient(180deg, #1A1C23 0%, #0d0f14 100%)', border: '1px solid #333', borderRadius: '15px', width: '420px', padding: '30px', textAlign: 'center', boxShadow: '0 20px 50px rgba(0,0,0,0.9)' }}>

            <h2 style={{ color: '#fff', fontSize: '1.4rem', marginBottom: '10px', marginTop: 0, fontWeight: 'bold' }}>
              {isTournament ? '☠️ Eliminado del Torneo' : (isPractice ? 'Liquidación de Fichas' : 'Sin Saldo en Mesa')}
            </h2>
            <p style={{ color: '#aaa', fontSize: '0.9rem', marginBottom: '20px' }}>
              {isTournament
                ? 'Te has quedado sin fichas de torneo. Puedes seguir viendo la mesa como espectador o salir al lobby.'
                : isPractice
                ? 'Te has quedado sin fichas en la Sala de Práctica.'
                : 'Te has quedado sin saldo en esta mesa. Tu saldo actual es de 0 NTX-20.'}
            </p>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>

              {!isPractice && !isTournament && (
                <button
                  onClick={() => {
                    setShowBustModal(false);
                    setSelectedSeat(mySeatIndex);
                    setBuyInAmount(minBuyIn);
                    setShowBuyInModal(true);
                  }}
                  style={{ padding: '15px', background: 'linear-gradient(180deg, #D4AF37 0%, #b48521 100%)', color: '#000', border: 'none', borderRadius: '8px', cursor: 'pointer', fontWeight: 'bold', fontSize: '1rem' }}
                >
                  Comprar más (NTX-20)
                </button>
              )}

              <button
                onClick={() => {
                  setShowBustModal(false);
                  setIsSpectatorMode(true);
                }}
                style={{ padding: '15px', background: '#1B1C24', color: '#fff', border: '1px solid #444', borderRadius: '8px', cursor: 'pointer', fontWeight: 'bold', fontSize: '1rem' }}
              >
                Quedarme de Espectador 👁️
              </button>

              <button
                onClick={() => {
                  setShowBustModal(false);
                  executeLeaveTable();
                }}
                style={{ padding: '15px', background: '#E67E22', color: '#fff', border: 'none', borderRadius: '8px', cursor: 'pointer', fontWeight: 'bold', fontSize: '1rem' }}
              >
                Salir al Lobby 🚪
              </button>

            </div>
          </div>
        </div>
      )}

      {/* MODAL DE CONFIRMACIÓN PARA SALIR */}
      {showExitConfirm && (
        <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.75)', backdropFilter: 'blur(5px)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 9999 }}>
          <div style={{ background: '#1A1C23', border: '1px solid #333', borderRadius: '10px', width: '380px', padding: '30px', textAlign: 'center', boxShadow: '0 20px 50px rgba(0,0,0,0.9)' }}>
            <h2 style={{ color: '#fff', fontSize: '1.3rem', marginBottom: '15px', marginTop: 0, fontWeight: 'bold' }}>Confirmar para salir</h2>
            <p style={{ color: '#ccc', fontSize: '0.95rem', marginBottom: '25px', lineHeight: '1.4' }}>
              {isTournament
                ? '¿Confirmas abandonar el torneo? PERDERÁS todas tus fichas de torneo y ya no podrás volver a entrar.'
                : '¿Confirmas el regreso al vestíbulo? Saldrá de la habitación inmediatamente después de la confirmación.'}
            </p>
            <div style={{ display: 'flex', gap: '15px', justifyContent: 'center' }}>
              <button
                onClick={() => setShowExitConfirm(false)}
                style={{ flex: 1, padding: '12px', background: '#333', color: '#fff', border: 'none', borderRadius: '6px', fontSize: '1rem', fontWeight: 'bold', cursor: 'pointer' }}
              >
                Cancelar
              </button>
              <button
                onClick={executeLeaveTable}
                style={{ flex: 1, padding: '12px', background: '#27AE60', color: '#fff', border: 'none', borderRadius: '6px', fontSize: '1rem', fontWeight: 'bold', cursor: 'pointer' }}
              >
                Seguro
              </button>
            </div>
          </div>
        </div>
      )}

      {/* 🏆 MTT: MODAL DE PODIO FINAL DEL TORNEO */}
      {tournamentFinished && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.88)', backdropFilter: 'blur(6px)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 99999 }}>
          <div style={{ background: 'linear-gradient(180deg, #1A1C23 0%, #0d0f14 100%)', border: '1px solid #D4AF37', borderRadius: '16px', width: '420px', maxWidth: '92vw', padding: '30px', textAlign: 'center', boxShadow: '0 20px 60px rgba(0,0,0,0.9), 0 0 40px rgba(212,175,55,0.15)', animation: 'settingsPop 0.3s ease-out' }}>
            <h2 style={{ color: '#D4AF37', fontSize: '1.5rem', margin: '0 0 5px', fontWeight: '900' }}>
              {tournamentFinished.practice ? '🎉 ¡FIN DEL TORNEO!' : '🏆 TORNEO FINALIZADO'}
            </h2>
            {tournamentFinished.title && <p style={{ color: '#718096', fontSize: '0.85rem', margin: '0 0 18px' }}>{tournamentFinished.title}</p>}
            {tournamentFinished.prizePool > 0 && (
              <p style={{ color: '#00e676', fontWeight: 'bold', margin: '0 0 18px' }}>Prize pool: {tournamentFinished.prizePool} NTX-20</p>
            )}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', marginBottom: '20px' }}>
              {(tournamentFinished.podium || []).map((p) => (
                <div key={p.position} style={{
                  display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                  background: p.position === 1 ? 'rgba(212,175,55,0.12)' : 'rgba(255,255,255,0.04)',
                  border: p.position === 1 ? '1px solid rgba(212,175,55,0.5)' : '1px solid #2d3748',
                  borderRadius: '10px', padding: '12px 16px'
                }}>
                  <span style={{ color: '#fff', fontWeight: 'bold' }}>
                    {p.position === 1 ? '🥇' : p.position === 2 ? '🥈' : '🥉'} {p.position}º · {p.username}
                  </span>
                  {p.prize ? <span style={{ color: '#00e676', fontWeight: 'bold' }}>{p.prize} NTX-20</span> : <span style={{ color: '#718096' }}>-</span>}
                </div>
              ))}
            </div>
            <button
              onClick={() => { setTournamentFinished(null); onExitRef.current && onExitRef.current(); }}
              style={{ width: '100%', padding: '14px', background: 'linear-gradient(180deg, #D4AF37 0%, #b48521 100%)', color: '#000', border: 'none', borderRadius: '8px', fontWeight: 'bold', fontSize: '1rem', cursor: 'pointer' }}
            >
              Volver al lobby
            </button>
          </div>
        </div>
      )}

      {/* MODAL COMPRAR FICHAS */}
      {!isPractice && showBuyInModal && (
        <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.85)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 200, backdropFilter: 'blur(5px)' }}>
          <div style={{ background: '#1a1d24', padding: '25px 35px', borderRadius: '12px', width: '400px', border: '1px solid #333', boxShadow: '0 20px 50px rgba(0,0,0,0.9)' }}>
            <h2 style={{ color: '#fff', margin: '0 0 5px 0', fontSize: '1.5rem', textAlign: 'center' }}>Comprar Fichas</h2>
            <p style={{ color: '#888', margin: '0 0 20px 0', fontSize: '0.9rem', textAlign: 'center' }}>Saldo: {userBalance.toFixed(2)} NTX</p>
            <input type="range" min={minBuyIn} max={maxBuyIn} value={buyInAmount} onChange={(e) => setBuyInAmount(Number(e.target.value))} style={{ width: '100%', accentColor: '#D4AF37' }} />
            <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '10px', color: '#D4AF37', fontWeight: 'bold' }}>
              <span>{minBuyIn}</span><span style={{ fontSize: '1.2rem' }}>{buyInAmount}</span><span>{maxBuyIn}</span>
            </div>
            <div style={{ display: 'flex', gap: '10px', marginTop: '25px' }}>
              <button onClick={() => { setShowBuyInModal(false); setSelectedSeat(null); }} disabled={isBuyingIn} style={{ flex: 1, padding: '12px', background: '#333', color: '#fff', border: 'none', borderRadius: '6px', cursor: isBuyingIn ? 'not-allowed' : 'pointer', fontWeight: 'bold' }}>Cancelar</button>
              <button onClick={confirmBuyIn} disabled={buyInAmount > userBalance || isBuyingIn} style={{ flex: 1, padding: '12px', background: (buyInAmount > userBalance || isBuyingIn) ? '#222' : 'linear-gradient(180deg, #D4AF37 0%, #b48521 100%)', color: (buyInAmount > userBalance || isBuyingIn) ? '#555' : '#000', border: 'none', borderRadius: '6px', fontWeight: 'bold', cursor: (buyInAmount > userBalance || isBuyingIn) ? 'not-allowed' : 'pointer' }}>
                {isBuyingIn ? 'Procesando...' : 'Pagar'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}