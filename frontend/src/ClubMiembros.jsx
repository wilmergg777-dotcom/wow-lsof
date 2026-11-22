import React, { useState, useEffect, useCallback } from 'react';
import { API_URL } from './config';

// 🔥 CLUBES: gestión real de miembros — lista con roles, fichas de club,
// expulsar (dueño/moderador), nombrar moderador (dueño) e invitar jugadores.
const ClubMiembros = ({ onBack }) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [inviteQuery, setInviteQuery] = useState('');
  const [busy, setBusy] = useState(false);
  const [toast, setToast] = useState(null);

  const showToast = (msg) => { setToast({ msg }); setTimeout(() => setToast(null), 3000); };

  const load = useCallback(async () => {
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`${API_URL}/api/clubs/members`, { headers: { Authorization: `Bearer ${token}` } });
      if (!res.ok) throw new Error((await res.json()).error || 'Error al cargar miembros');
      setData(await res.json());
    } catch (e) {
      showToast(e.message);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { load(); }, [load]);

  const post = async (url, body) => {
    setBusy(true);
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`${API_URL}/api${url}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
        body: JSON.stringify(body),
      });
      const d = await res.json();
      if (!res.ok) throw new Error(d.error || 'Error');
      showToast(d.message || 'Hecho');
      await load();
    } catch (e) {
      showToast(e.message);
    } finally {
      setBusy(false);
    }
  };

  const canManage = data && (data.my_role === 'owner' || data.my_role === 'moderator');
  const roleLabel = { owner: '👑 Dueño', moderator: '🛡️ Moderador', player: 'Jugador', member: 'Jugador' };

  return (
    <div style={{ backgroundColor: '#0a0a0a', minHeight: '100vh', paddingBottom: '90px', color: 'white' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px 20px', borderBottom: '1px solid #222' }}>
        <button onClick={onBack} style={{ background: 'none', border: 'none', color: 'white', fontSize: '24px', cursor: 'pointer' }}>‹</button>
        <h2 style={{ margin: 0, fontSize: '18px', fontWeight: 'bold' }}>Miembros del Club</h2>
        <span style={{ fontSize: '20px' }}>👥</span>
      </div>

      {canManage && (
        <div style={{ padding: '15px 20px' }}>
          <div style={{ background: '#1e1e1e', borderRadius: '10px', padding: '12px', display: 'flex', gap: '8px' }}>
            <input
              value={inviteQuery}
              onChange={(e) => setInviteQuery(e.target.value)}
              placeholder="Usuario o ID único a invitar"
              style={{ flex: 1, background: '#121212', border: '1px solid #333', borderRadius: '8px', padding: '10px', color: 'white', fontSize: '14px' }}
            />
            <button
              onClick={() => { if (inviteQuery.trim()) { post('/clubs/invite', { query: inviteQuery.trim() }); setInviteQuery(''); } }}
              disabled={busy || !inviteQuery.trim()}
              style={{ background: '#00b86b', color: 'white', border: 'none', borderRadius: '8px', padding: '10px 16px', fontWeight: 'bold', cursor: 'pointer' }}
            >
              Invitar
            </button>
          </div>
        </div>
      )}

      <div style={{ padding: '0 20px' }}>
        {loading ? (
          <p style={{ textAlign: 'center', color: '#888', padding: '30px' }}>Cargando miembros...</p>
        ) : !data ? (
          <p style={{ textAlign: 'center', color: '#888', padding: '30px' }}>No se pudieron cargar los miembros.</p>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            <div style={{ color: '#888', fontSize: '12px', marginBottom: '5px' }}>
              {data.members.length} / {data.max_players} jugadores · Nivel {data.tier}
            </div>
            {data.members.map(m => (
              <div key={m.user_id} style={{ background: '#1e1e1e', border: '1px solid #333', borderRadius: '10px', padding: '12px 15px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div>
                  <div style={{ fontWeight: 'bold', fontSize: '15px' }}>
                    {m.username} <span style={{ fontSize: '11px', color: '#aaa' }}>@{m.unique_id || '—'}</span>
                  </div>
                  <div style={{ fontSize: '12px', color: '#00b86b', marginTop: '3px' }}>
                    {roleLabel[m.role] || 'Jugador'} · 💿 {Number(m.club_chips || 0)} fichas de club
                  </div>
                </div>
                {canManage && m.role !== 'owner' && (
                  <div style={{ display: 'flex', gap: '6px' }}>
                    {data.my_role === 'owner' && m.role !== 'moderator' && (
                      <button
                        onClick={() => post('/clubs/moderator', { userId: m.user_id })}
                        disabled={busy}
                        title="Nombrar moderador"
                        style={{ background: '#2a2a2a', color: '#e2b04a', border: '1px solid #e2b04a', padding: '7px 10px', borderRadius: '6px', cursor: 'pointer', fontSize: '12px' }}
                      >
                        🛡️
                      </button>
                    )}
                    {!(data.my_role === 'moderator' && m.role === 'moderator') && (
                      <button
                        onClick={() => { if (window.confirm(`¿Expulsar a ${m.username} del club?`)) post('/clubs/kick', { userId: m.user_id }); }}
                        disabled={busy}
                        title="Expulsar"
                        style={{ background: '#ef4444', color: 'white', border: 'none', padding: '7px 10px', borderRadius: '6px', cursor: 'pointer', fontSize: '12px' }}
                      >
                        Expulsar
                      </button>
                    )}
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      {toast && (
        <div style={{ position: 'fixed', bottom: '30px', left: '50%', transform: 'translateX(-50%)', background: '#00b86b', color: 'white', padding: '12px 22px', borderRadius: '25px', fontWeight: 'bold', fontSize: '14px', zIndex: 999 }}>
          {toast.msg}
        </div>
      )}
    </div>
  );
};

export default ClubMiembros;
