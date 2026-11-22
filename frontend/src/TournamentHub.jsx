import { useState, useEffect, useRef, useCallback } from 'react';
import { API_URL } from './config';

// ============================================================
// 🏆 TORNEOS MTT — Vista estilo MTT.poker (mobile-first)
// Filtros + cards con countdown, late reg, prize pool,
// registro funcional y entrada a la mesa cuando empieza.
// ============================================================

const LATE_REG_MS = 10 * 60 * 1000;

const formatTime = (ms) => {
  if (ms <= 0) return '00:00';
  const totalSeconds = Math.floor(ms / 1000);
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;
  if (hours > 0) return `${hours}h ${String(minutes).padStart(2, '0')}m`;
  return `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
};

const FILTERS = [
  { id: 'all', label: 'Todos' },
  { id: 'open', label: 'Registro abierto' },
  { id: 'playing', label: 'En juego' },
  { id: 'soon', label: 'Próximas 2h' },
];

function TournamentCard({ game, now, isRegistered, onRegister, onEnter, registering }) {
  const timeLeft = game.startTime - now;
  const lateRegLeft = timeLeft + LATE_REG_MS;
  const isPlaying = game.status === 'PLAYING';
  const isCancelled = game.status === 'CANCELLED';
  const isFinished = game.status === 'FINISHED';
  const isOpen = game.status === 'OPEN' && timeLeft > 0;
  const isLateReg = timeLeft <= 0 && lateRegLeft > 0;

  // Estado tipo MTT en la esquina de la card
  let statusChip = null;
  if (isPlaying) statusChip = { text: '🔴 EN JUEGO', color: '#ef4444' };
  else if (isLateReg) statusChip = { text: `🟠 LATE REG ${formatTime(lateRegLeft)}`, color: '#f59e0b' };
  else if (isOpen) statusChip = { text: `🟢 Empieza en ${formatTime(timeLeft)}`, color: '#00e676' };
  else if (isCancelled) statusChip = { text: '⚪ CANCELADO', color: '#718096' };
  else if (isFinished) statusChip = { text: '🏁 TERMINADO', color: '#718096' };
  else statusChip = { text: '🟢 Próximamente', color: '#00e676' };

  const canRegister = isOpen && !isRegistered;
  const canEnter = isPlaying && isRegistered;

  return (
    <div className="mtt-card">
      <div className="mtt-card-banner" style={{ backgroundImage: `url(${game.image})` }}>
        <div className="mtt-status-chip" style={{ background: statusChip.color }}>{statusChip.text}</div>
        <div className="mtt-card-title-row">
          <span className="mtt-card-name">{game.title.split('-')[0].trim()}</span>
        </div>
        <div className="mtt-register-tag">Inscripción <b>{game.entry} MTT</b></div>
      </div>
      <div className="mtt-card-body">
        <h3 className="mtt-card-h3">{game.title}</h3>
        <div className="mtt-card-meta">
          <div className="mtt-meta-col">
            <span className="mtt-meta-label">Prize Pool</span>
            <span className="mtt-meta-value gold">{game.prize} <small>NTX-20</small></span>
          </div>
          <div className="mtt-meta-col right">
            <span className="mtt-meta-label">Jugadores</span>
            <span className="mtt-meta-value">{game.players.length} / {game.maxPlayers}</span>
          </div>
        </div>
        <div className="mtt-card-actions">
          {canRegister && (
            <button className="mtt-btn-register" disabled={registering} onClick={() => onRegister(game)}>
              {registering ? 'Procesando...' : `Registrar · ${game.entry} NTX-20`}
            </button>
          )}
          {isOpen && isRegistered && <div className="mtt-btn-confirmed">✔ Registro confirmado</div>}
          {canEnter && (
            <button className="mtt-btn-enter" onClick={() => onEnter(game)}>♠ Entrar a la mesa</button>
          )}
          {isPlaying && !isRegistered && <div className="mtt-btn-locked">En juego — registro cerrado</div>}
          {isCancelled && <div className="mtt-btn-locked">Cancelado — entradas reembolsadas</div>}
          {isFinished && <div className="mtt-btn-locked">Torneo finalizado</div>}
        </div>
      </div>
    </div>
  );
}

export default function TournamentHub({ user, onBack, onEnterTournament, showToast }) {
  const [games, setGames] = useState([]);
  const [now, setNow] = useState(Date.now());
  const [filter, setFilter] = useState('all');
  const [loading, setLoading] = useState(true);
  const [registering, setRegistering] = useState(null);
  const [mySeat, setMySeat] = useState(null);
  const [error, setError] = useState('');
  const token = localStorage.getItem('token');
  const pollRef = useRef(null);

  const load = useCallback(async () => {
    try {
      const res = await fetch(`${API_URL}/api/futures-games`);
      const data = await res.json();
      setGames(Array.isArray(data) ? data.sort((a, b) => a.startTime - b.startTime) : []);
    } catch (e) {
      setError('No se pudieron cargar los torneos');
    } finally {
      setLoading(false);
    }
  }, []);

  const loadMySeat = useCallback(async () => {
    if (!token) return;
    try {
      const res = await fetch(`${API_URL}/api/futures-games/my-seat`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      const data = await res.json();
      setMySeat(data?.seated ? data : null);
    } catch (e) { /* silencioso */ }
  }, [token]);

  useEffect(() => {
    load();
    loadMySeat();
    pollRef.current = setInterval(() => {
      setNow(Date.now());
    }, 1000);
    const pollGames = setInterval(() => {
      load();
      loadMySeat();
    }, 15000);
    return () => { clearInterval(pollRef.current); clearInterval(pollGames); };
  }, [load, loadMySeat]);

  const handleRegister = async (game) => {
    if (registering) return;
    setRegistering(game.id);
    setError('');
    try {
      const res = await fetch(`${API_URL}/api/futures-games/register`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
        body: JSON.stringify({ gameId: game.id }),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Error al registrarse');
      showToast?.({ message: `✔ Inscripción pagada: ${game.entry} NTX-20`, type: 'success' });
      await load();
    } catch (e) {
      showToast?.({ message: e.message, type: 'error' });
    } finally {
      setRegistering(null);
    }
  };

  const handleEnter = (game) => {
    onEnterTournament?.({
      isActive: true,
      tableData: {
        id: `mtt-${game.id}`,
        name: game.title.split('-')[0].trim(),
        isTournament: true,
        gameId: game.id,
        blinds: 'MTT',
        maxPlayers: 9,
        startingStack: 3000,
      },
    });
  };

  // ¿Estoy registrado en este torneo?
  const isRegisteredIn = (game) => user && game.players?.includes(user.id);

  const filtered = games.filter((g) => {
    if (filter === 'open') return g.status === 'OPEN';
    if (filter === 'playing') return g.status === 'PLAYING';
    if (filter === 'soon') return g.status === 'OPEN' && (g.startTime - now) < 2 * 60 * 60 * 1000;
    return true;
  });

  return (
    <main className="main-area" style={{ background: '#0b0e14', minHeight: '100vh', paddingBottom: '90px' }}>
      {/* Barra superior sticky estilo app móvil */}
      <div className="mtt-topbar">
        <button className="mtt-back-btn" onClick={onBack}>←</button>
        <div className="mtt-topbar-title">
          <span className="mtt-topbar-main">Torneos</span>
          <span className="mtt-topbar-sub">MTT · SNG · Satélites</span>
        </div>
        <img src="/ntx.png" alt="NTX" className="mtt-topbar-coin" onError={(e) => { e.target.style.display = 'none'; }} />
      </div>

      <div className="mtt-container">
        {/* Mi silla activa (reconexión) */}
        {mySeat && (
          <div className="mtt-myseat-banner" onClick={() => handleEnter({ id: mySeat.gameId, title: mySeat.title || 'Torneo' })}>
            <span>♠ Tienes silla activa en <b>{mySeat.title}</b> ({mySeat.chips} fichas)</span>
            <button className="mtt-myseat-btn">Volver a la mesa →</button>
          </div>
        )}

        {/* Filtros estilo MTT (scroll horizontal en móvil) */}
        <div className="mtt-filters">
          {FILTERS.map((f) => (
            <button
              key={f.id}
              className={`mtt-filter-chip ${filter === f.id ? 'active' : ''}`}
              onClick={() => setFilter(f.id)}
            >
              {f.label}
            </button>
          ))}
        </div>

        {error && <div className="mtt-error">{error}</div>}

        {loading ? (
          <div className="mtt-loading">Cargando torneos...</div>
        ) : filtered.length === 0 ? (
          <div className="mtt-empty">No hay torneos para este filtro. Los torneos se crean automáticamente cada día (10:30, 12:20, 14:10, 16:00).</div>
        ) : (
          <div className="mtt-grid">
            {filtered.map((game) => (
              <TournamentCard
                key={game.id}
                game={game}
                now={now}
                isRegistered={isRegisteredIn(game)}
                onRegister={handleRegister}
                onEnter={handleEnter}
                registering={registering === game.id}
              />
            ))}
          </div>
        )}

        {/* Info de estructura */}
        <div className="mtt-structure-card">
          <h4>📌 Estructura de los torneos MTT</h4>
          <ul>
            <li>Stack inicial: <b>3000 fichas</b> de torneo (sin valor en NTX-20)</li>
            <li>Ciegas: <b>25/50</b> y suben +25% cada 10 minutos</li>
            <li>Premios del prize pool (90% de las entradas): <b>1º 55% · 2º 30% · 3º 15%</b> pagados automáticamente en NTX-20</li>
            <li>Late registration: hasta <b>10 minutos</b> después del inicio</li>
            <li>Si un torneo no llega a 2 jugadores, las entradas se reembolsan</li>
          </ul>
        </div>
      </div>
    </main>
  );
}
