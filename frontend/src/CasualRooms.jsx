import React, { useState, useEffect, useCallback, useMemo } from 'react';
import { API_URL } from './config';

const PLAYERS_PER_MESA = 9; // Cada mesa tiene 9 sillas

const resolveBuyInLimit = (table) => {
  if (table.isPractice) return 'GRATIS (400 Fichas)';
  if (table.minBuyIn != null && table.maxBuyIn != null) {
    return `${table.minBuyIn} - ${table.maxBuyIn}`;
  }
  if (table.buyInLimit) return table.buyInLimit;
  const id = String(table.id || '');
  if (id.includes('2-4') || id.includes('2_4')) return '250 - 500';
  if (id.includes('1-2') || id.includes('1_2')) return '100 - 250';
  return '20 - 100';
};

const resolveBlinds = (table) => {
  if (table.blinds) return table.blinds;
  const id = String(table.id || '');
  if (id.includes('2-4') || id.includes('2_4')) return '2/4';
  if (id.includes('1-2') || id.includes('1_2')) return '1/2';
  return '0.5/1';
};

export default function CasualRooms({ onBack, onJoinTable }) {
  const [tables, setTables] = useState({ real: [], practice: [] });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  // 🔥 CLUBES: torneos públicos de clubes visibles en el lobby (nivel 2/3)
  const [clubTournaments, setClubTournaments] = useState([]);

  const fetchClubTournaments = useCallback(async () => {
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`${API_URL}/api/clubs/public-tournaments`, {
        headers: token ? { Authorization: `Bearer ${token}` } : {},
      });
      if (res.ok) setClubTournaments(await res.json());
    } catch (e) { /* sin torneos de club */ }
  }, []);

  const fetchTables = useCallback(async () => {
    try {
      const response = await fetch(`${API_URL}/api/tables/casual`);
      if (!response.ok) throw new Error('Error al cargar las mesas');
      const data = await response.json();

      const enrich = (t) => ({
        ...t,
        maxPlayers: t.maxPlayers || PLAYERS_PER_MESA,
        players: Array.isArray(t.players) ? t.players : [],
        buyInLimit: resolveBuyInLimit(t),
        blindsResolved: resolveBlinds(t),
        locked: !!t.locked,
      });

      setTables({
        practice: data.filter(t => t.isPractice).map(enrich),
        real: data.filter(t => !t.isPractice).map(enrich),
      });
      setError(null);
    } catch (err) {
      console.error('Error conectando al backend:', err);
      setError('No se pudieron cargar las mesas. Verifica la conexión con el servidor.');
      setTables({ real: [], practice: [] });
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchTables();
    fetchClubTournaments();
    const interval = setInterval(fetchTables, 3000);
    return () => clearInterval(interval);
  }, [fetchTables, fetchClubTournaments]);

  // 🔥 AGRUPACIÓN CORREGIDA: Separa por juego (ej. HOLD'EM) y número de sala.
  const salas = useMemo(() => {
    const real = tables.real || [];
    if (real.length === 0) return [];

    const hasSala = real.some(t => t.sala != null);
    if (!hasSala) return [{ id: 'flat', name: 'General', sala: 1, mesas: real }];

    const map = new Map();
    for (const t of real) {
      const groupId = `${t.baseName || t.name}-${t.sala}`;
      if (!map.has(groupId)) {
        map.set(groupId, {
          id: groupId,
          name: t.baseName || t.name,
          sala: t.sala,
          mesas: []
        });
      }
      map.get(groupId).mesas.push(t);
    }

    return Array.from(map.values())
      .sort((a, b) => {
        if (a.sala !== b.sala) return a.sala - b.sala;
        return a.name.localeCompare(b.name);
      })
      .map(group => ({
        ...group,
        mesas: group.mesas.sort((a, b) => (a.mesa ?? 0) - (b.mesa ?? 0))
      }));
  }, [tables.real]);

  const maxSalaNumber = useMemo(() => {
    return salas.reduce((max, s) => Math.max(max, s.sala ?? 0), 0);
  }, [salas]);

  const TableCard = ({ table }) => {
    const maxPlayers = table.maxPlayers || PLAYERS_PER_MESA;
    const currentPlayers = table.players?.length || 0;
    const isFull = currentPlayers >= maxPlayers;
    const isLocked = !!table.locked && !isFull;
    const isPractice = !!table.isPractice;
    const isJoinable = !isFull && !isLocked;

    const displayName = table.name || (table.mesa != null ? `Mesa ${table.mesa}` : 'Mesa');
    const tableImage = table.image || '/mesa-omaha.png';

    const handleClick = () => {
      if (!isJoinable) return;
      onJoinTable({
        isActive: true,
        tableData: table,
        config: { maxSeats: maxPlayers },
      });
    };

    const statusColor = isLocked ? '#f59e0b' : (isFull ? '#ef4444' : '#00e676');
    const statusLabel = isLocked ? 'ESPERANDO MESA ANTERIOR' : (isFull ? 'MESA LLENA' : 'DISPONIBLE');
    const badgeLabel = isLocked ? 'BLOQUEADA' : (isFull ? 'LLENA' : null);

    return (
      <div
        onClick={handleClick}
        style={{
          background: '#12161f',
          borderRadius: '12px',
          overflow: 'hidden',
          border: isLocked ? '1px solid #f59e0b' : '1px solid #2d3748',
          cursor: isJoinable ? 'pointer' : 'not-allowed',
          transition: 'transform 0.2s, box-shadow 0.2s',
          display: 'flex',
          flexDirection: 'column',
          opacity: isJoinable ? 1 : 0.65,
          position: 'relative',
        }}
        onMouseOver={(e) => {
          if (isJoinable) {
            e.currentTarget.style.transform = 'translateY(-5px)';
            e.currentTarget.style.boxShadow = '0 10px 25px rgba(0, 230, 118, 0.2)';
          }
        }}
        onMouseOut={(e) => {
          e.currentTarget.style.transform = 'translateY(0)';
          e.currentTarget.style.boxShadow = 'none';
        }}
      >
        {badgeLabel && (
          <div style={{
            position: 'absolute', top: '8px', right: '8px',
            background: statusColor, color: '#000',
            padding: '2px 8px', borderRadius: '4px',
            fontSize: '0.65rem', fontWeight: 'bold', zIndex: 5,
          }}>
            {badgeLabel}
          </div>
        )}

        <div style={{
          height: '140px',
          position: 'relative',
          background: `linear-gradient(to bottom, rgba(0,0,0,0.2), rgba(0,0,0,0.9)), url("${tableImage}")`,
          backgroundSize: 'cover',
          backgroundPosition: 'center',
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'space-between',
          padding: '12px',
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <span style={{ color: '#fff', fontWeight: 800, fontSize: '1rem', textShadow: '0 2px 4px #000' }}>
              {displayName}
            </span>
            <span style={{
              background: statusColor,
              color: '#000',
              padding: '2px 6px',
              borderRadius: '4px',
              fontSize: '0.65rem',
              fontWeight: 'bold',
            }}>
              {currentPlayers}/{maxPlayers}
            </span>
          </div>

          <div style={{ textAlign: 'center', marginTop: 'auto', marginBottom: '5px' }}>
            <span style={{ color: '#a0aec0', fontSize: '0.65rem', fontWeight: 'bold', display: 'block', marginBottom: '2px', letterSpacing: '1px' }}>
              {isPractice ? 'MODO PRÁCTICA' : 'LÍMITES DE ENTRADA'}
            </span>
            <div style={{ color: '#fbbf24', fontSize: '1.3rem', fontWeight: 900, textShadow: '0 2px 4px #000' }}>
              {isPractice ? (table.blinds || 'Freeroll') : `${table.buyInLimit} NTX-20`}
            </div>
          </div>
        </div>

        <div style={{ padding: '12px', background: '#1a202c', flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
          <h3 style={{ margin: '0 0 10px 0', color: '#fff', fontSize: '0.95rem', fontWeight: 'bold' }}>
            {table.tableType || 'No Limit Holdem'} - {displayName}
          </h3>

          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '5px' }}>
            <span style={{ color: '#a0aec0', fontSize: '0.75rem' }}>Ciegas</span>
            <div style={{ color: '#fff', fontSize: '0.75rem', fontWeight: 'bold' }}>
              {isPractice ? 'Freeroll' : table.blindsResolved}
            </div>
          </div>

          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span style={{ color: '#a0aec0', fontSize: '0.75rem' }}>Estado</span>
            <div style={{ color: statusColor, fontSize: '0.75rem', fontWeight: 'bold' }}>
              {statusLabel}
            </div>
          </div>
        </div>
      </div>
    );
  };

  const renderContent = () => {
    if (loading) return <p style={{ color: '#00e676' }}>Cargando mesas reales...</p>;
    if (error) return <p style={{ color: '#ef4444' }}>{error}</p>;

    const blocks = [];

    // 🔥 Si estamos en el Lobby (sin onBack), mostramos solo las primeras 4 salas
    const displaySalas = !onBack ? salas.slice(0, 4) : salas;

    if (displaySalas.length > 0) {
      displaySalas.forEach(({ id, name, sala, mesas }) => {
        // 🔥 Ocultar mesas bloqueadas
        const visibleTables = mesas.filter(t => !t.locked);

        // Si por alguna razón todas las mesas de la sala están bloqueadas, no mostrar la sala
        if (visibleTables.length === 0) return;

        const totalPlayers = mesas.reduce((s, m) => s + (m.players?.length || 0), 0);
        const totalCap = mesas.length * PLAYERS_PER_MESA; // 2 mesas * 9 = 18

        const salaFull = totalCap > 0 && totalPlayers >= totalCap;
        const isLastSala = sala === maxSalaNumber;
        const showNextSalaMsg = salaFull && isLastSala;
        const showCompleteMsg = salaFull && !isLastSala;

        blocks.push(
          <div key={id} style={{ marginBottom: '2rem' }}>
            <div style={{
              display: 'flex', justifyContent: 'space-between', alignItems: 'center',
              marginBottom: '1rem', paddingBottom: '0.5rem',
              borderBottom: '1px solid #2d3748',
            }}>
              <h3 style={{ color: '#fff', fontSize: '1.1rem', fontWeight: 'bold', margin: 0 }}>
                Sala {sala} - {name}
              </h3>
              <span style={{
                background: salaFull ? '#ef4444' : '#00e676',
                color: '#000',
                padding: '3px 10px',
                borderRadius: '4px',
                fontSize: '0.75rem',
                fontWeight: 'bold',
              }}>
                {totalPlayers}/{totalCap}
                {showNextSalaMsg ? ' — PRÓXIMA SALA EN CAMINO' : ''}
                {showCompleteMsg ? ' — COMPLETA' : ''}
              </span>
            </div>
            <div className="grid-4-cols">
              {visibleTables.map((t) => (
                <TableCard key={t.id} table={t} />
              ))}
            </div>
          </div>
        );
      });
    } else {
      blocks.push(
        <p key="empty-real" style={{ color: '#a0aec0', marginBottom: '2rem' }}>
          No hay mesas reales disponibles en este momento.
        </p>
      );
    }

    // 🔥 CLUBES: torneos públicos de clubes (lobby del casino, junto a las otras mesas)
    if (clubTournaments.length > 0) {
      blocks.push(
        <div key="club-tournaments" style={{ marginBottom: '2rem' }}>
          <div style={{
            display: 'flex', justifyContent: 'space-between', alignItems: 'center',
            marginBottom: '1rem', paddingBottom: '0.5rem',
            borderBottom: '1px solid #2d3748',
          }}>
            <h3 style={{ color: '#fff', fontSize: '1.1rem', fontWeight: 'bold', margin: 0 }}>
              🏆 Torneos de Clubes
            </h3>
            <span style={{ background: '#00e676', color: '#000', padding: '3px 10px', borderRadius: '4px', fontSize: '0.75rem', fontWeight: 'bold' }}>
              {clubTournaments.length} activo(s)
            </span>
          </div>
          <div className="grid-4-cols">
            {clubTournaments.map(t => (
              <div key={t.id} style={{ background: '#12161f', borderRadius: '12px', overflow: 'hidden', border: '1px solid #2d3748', display: 'flex', flexDirection: 'column' }}>
                <div style={{ height: '90px', background: 'linear-gradient(135deg, #1a2332 0%, #0f172a 100%)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '2.2rem' }}>
                  {t.club_avatar && !String(t.club_avatar).startsWith('http') ? t.club_avatar : '👑'}
                </div>
                <div style={{ padding: '12px', flex: 1 }}>
                  <h4 style={{ margin: '0 0 6px', color: '#fbbf24', fontSize: '0.9rem', fontWeight: 'bold' }}>{t.name}</h4>
                  <p style={{ margin: '0 0 4px', color: '#a0aec0', fontSize: '0.72rem' }}>
                    Club: <span style={{ color: '#00e676' }}>{t.club_name}</span> ({t.club_code})
                  </p>
                  <p style={{ margin: 0, color: '#a0aec0', fontSize: '0.72rem' }}>
                    {t.type} · {t.mode} · <span style={{ color: t.status === 'open' ? '#00e676' : '#fbbf24' }}>{t.status === 'open' ? 'INSCRIPCIONES ABIERTAS' : 'EN JUEGO'}</span>
                  </p>
                </div>
              </div>
            ))}
          </div>
        </div>
      );
    }

    // Sala de práctica aparte (siempre visible y sin agrupar)
    if (tables.practice.length > 0) {
      blocks.push(
        <div key="practice" style={{ marginBottom: '2rem' }}>
          <h3 style={{
            color: '#fff', fontSize: '1.1rem', fontWeight: 'bold',
            marginBottom: '1rem', paddingBottom: '0.5rem',
            borderBottom: '1px solid #2d3748',
          }}>
            Sala de Práctica
          </h3>
          <div className="grid-4-cols">
            {tables.practice.map((t) => <TableCard key={t.id} table={t} />)}
          </div>
        </div>
      );
    }

    return blocks;
  };

  const content = <div>{renderContent()}</div>;
  if (!onBack) return content;

  return (
    <main className="main-area">
      <div className="content-scroll" style={{ padding: '1.5rem' }}>
        <button
          onClick={onBack}
          style={{
            background: 'transparent', border: 'none', color: '#00e676',
            cursor: 'pointer', marginBottom: '1.5rem',
            display: 'flex', alignItems: 'center', gap: '5px',
            fontWeight: 'bold', fontSize: '1rem',
          }}
        >
          ← Volver al Lobby
        </button>

        <div className="section-header" style={{ marginBottom: '2rem' }}>
          <h2 style={{ fontSize: '1.5rem', fontWeight: 800, color: '#fff' }}>Casual Rooms & Práctica</h2>
          <p style={{ color: '#a0aec0', fontSize: '0.9rem', marginTop: '5px' }}>
            Salas de 18 jugadores (2 mesas de 9). Cuando una sala se llena, se abre la siguiente automáticamente.
          </p>
        </div>

        {content}
      </div>
    </main>
  );
}