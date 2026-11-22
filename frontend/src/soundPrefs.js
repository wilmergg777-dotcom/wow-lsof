// ============================================================
// 🔊 soundPrefs.js — FUENTE ÚNICA DE VERDAD DEL SONIDO 🔊
// ============================================================
// Ajustes (Settings.jsx), la mesa de póker (PokerTable.jsx) y la
// barra multimesa leen y escriben AQUÍ. Cualquier cambio se
// persiste inmediatamente en localStorage y se avisa a TODOS los
// componentes montados mediante un evento personalizado, así el
// interruptor de "Ajustes → Sonido" funciona al instante incluso
// con mesas abiertas en segundo plano.

const SETTINGS_KEY = 'royalbet_settings';
const EVENT_NAME = 'royalbet_soundprefs_changed';

// Claves de sonido que se guardan dentro de royalbet_settings
export const SOUND_SETTING_KEYS = [
  'efectosSonoros',     // interruptor principal de efectos
  'alertasMultimesa',   // aviso sonoro cuando es mi turno en otra mesa
];

export function readRoyalSettings() {
  try { return JSON.parse(localStorage.getItem(SETTINGS_KEY) || '{}'); }
  catch { return {}; }
}

export function writeRoyalSettings(updates) {
  try {
    const current = readRoyalSettings();
    localStorage.setItem(SETTINGS_KEY, JSON.stringify({ ...current, ...updates }));
  } catch (e) { /* almacenamiento no disponible */ }
  // Avisar a todas las mesas / ajustes montados
  try { window.dispatchEvent(new CustomEvent(EVENT_NAME, { detail: updates || {} })); } catch (e) {}
}

export function getSoundPrefs() {
  const s = readRoyalSettings();
  let volume = 0.7;
  let animations = true;
  try {
    const v = localStorage.getItem('poker_volume');
    if (v !== null) volume = Number(v);
  } catch (e) {}
  try {
    const a = localStorage.getItem('poker_animations');
    if (a !== null) animations = a === 'true';
  } catch (e) {}
  return {
    efectosSonoros: s.efectosSonoros !== false,
    alertasMultimesa: s.alertasMultimesa !== false,
    volume: Number.isFinite(volume) ? volume : 0.7,
    animations,
  };
}

// Cambiar una preferencia y persistir al instante (sin pulsar "Ahorrar")
export function setSoundPref(key, value) {
  if (SOUND_SETTING_KEYS.includes(key)) {
    writeRoyalSettings({ [key]: value });
  } else if (key === 'volume') {
    try { localStorage.setItem('poker_volume', String(value)); } catch (e) {}
    try { window.dispatchEvent(new CustomEvent(EVENT_NAME, { detail: { volume: value } })); } catch (e) {}
  } else if (key === 'animations') {
    try { localStorage.setItem('poker_animations', String(value)); } catch (e) {}
    try { window.dispatchEvent(new CustomEvent(EVENT_NAME, { detail: { animations: value } })); } catch (e) {}
  }
}

// Suscripción a cambios (evento propio + evento storage entre pestañas)
// Devuelve una función para cancelar la suscripción.
export function subscribeSoundPrefs(cb) {
  const handler = () => cb(getSoundPrefs());
  try { window.addEventListener(EVENT_NAME, handler); } catch (e) {}
  try { window.addEventListener('storage', handler); } catch (e) {}
  return () => {
    try { window.removeEventListener(EVENT_NAME, handler); } catch (e) {}
    try { window.removeEventListener('storage', handler); } catch (e) {}
  };
}
