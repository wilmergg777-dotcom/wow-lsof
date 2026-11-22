import { useState, useEffect } from 'react';
import { API_URL } from './config'; // 🔥 Importamos API_URL

// Iconos SVG para la interfaz
const Icons = {
  Back: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>,
  History: () => <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#718096" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>,
  Play: () => <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polygon points="5 3 19 12 5 21 5 3"/></svg>,
  Calendar: () => <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#a0aec0" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>,
  EmptyBox: () => <svg width="80" height="80" viewBox="0 0 24 24" fill="none" stroke="#2d3748" strokeWidth="1" strokeLinecap="round" strokeLinejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
};

export default function ActivityCenter({ user, onBack }) {
  const [activeTables, setActiveTables] = useState([]);
  const [history, setHistory] = useState([]); 
  const [loading, setLoading] = useState(true);
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');
  const [gameType, setGameType] = useState('Toda');

  // 🔥 EFECTO PARA CARGAR LOS DATOS DEL BACKEND
  useEffect(() => {
    const fetchActivity = async () => {
      try {
        const token = localStorage.getItem('token');
        const res = await fetch(`${API_URL}/api/user/activity`, {
          headers: { Authorization: `Bearer ${token}` }
        });
        const data = await res.json();
        
        if (res.ok) {
          setActiveTables(data.activeTables || []);
          setHistory(data.history || []);
        }
      } catch (error) {
        console.error("Error fetching activity:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchActivity();
  }, []);

  const handleReturnToTable = (tableId) => {
    // Aquí deberías actualizar el localStorage con el tableConfig de esa mesa
    // y luego recargar la página para que App.jsx te devuelva a la mesa
    localStorage.setItem('royalbet_in_game', 'true');
    // NOTA: Si guardas el tableConfig en la DB, lo ideal es recuperarlo aquí.
    // Por ahora, recargamos para que App.jsx se encargue.
    window.location.reload(); 
  };

  return (
    <div style={{ minHeight: '100vh', backgroundColor: '#0d0f14', color: '#fff', fontFamily: '"Segoe UI", Roboto, sans-serif', paddingBottom: '50px' }}>
      
      {/* HEADER */}
      <div style={{ display: 'flex', alignItems: 'center', padding: '20px 40px', borderBottom: '1px solid #1a202c', backgroundColor: '#15171e' }}>
        <button onClick={onBack} style={{ background: 'transparent', border: 'none', color: '#fff', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '10px', fontSize: '1rem', fontWeight: 'bold' }}>
          <Icons.Back /> Volver al Vestíbulo
        </button>
        <h1 style={{ margin: '0 auto', fontSize: '1.5rem', fontWeight: '900', color: '#D4AF37' }}>Centro de Actividades</h1>
        <div style={{ width: '150px' }}></div>
      </div>

      <div style={{ maxWidth: '1200px', margin: '0 auto', padding: '0 20px', marginTop: '30px' }}>
        
        {/* 🔥 SECCIÓN 1: PARTIDAS ACTIVAS 🔥 */}
        <div style={{ marginBottom: '40px' }}>
          <h2 style={{ fontSize: '1.2rem', marginBottom: '15px', color: '#e2e8f0' }}>Partidas Activas</h2>
          
          {loading ? (
            <div style={{ color: '#a0aec0', textAlign: 'center', padding: '20px' }}>Cargando partidas...</div>
          ) : activeTables.length === 0 ? (
            <div style={{ backgroundColor: '#15171e', border: '1px solid #2d3748', borderRadius: '12px', padding: '40px', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', color: '#718096' }}>
              <Icons.EmptyBox />
              <p style={{ marginTop: '15px', fontSize: '1rem' }}>Sin datos</p>
              <button onClick={onBack} style={{ marginTop: '15px', padding: '8px 20px', background: '#00e676', color: '#000', border: 'none', borderRadius: '6px', fontWeight: 'bold', cursor: 'pointer' }}>
                Jugar
              </button>
            </div>
          ) : (
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: '15px' }}>
              {activeTables.map(table => (
                <div key={table.table_id} style={{ background: 'linear-gradient(135deg, #1a202c, #15171e)', border: '1px solid #00e676', borderRadius: '12px', padding: '20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <div>
                    <h3 style={{ margin: 0, color: '#fff', fontSize: '1.1rem' }}>{table.table_id}</h3>
                    <p style={{ margin: '5px 0 0 0', color: '#a0aec0', fontSize: '0.85rem' }}>
                      {table.server_type === 'practice' ? 'Práctica' : 'Dinero Real'}
                    </p>
                  </div>
                  <button onClick={() => handleReturnToTable(table.table_id)} style={{ display: 'flex', alignItems: 'center', gap: '5px', padding: '10px 15px', background: '#00e676', color: '#000', border: 'none', borderRadius: '8px', fontWeight: 'bold', cursor: 'pointer' }}>
                    <Icons.Play /> Volver a la mesa
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* 🔥 SECCIÓN 2: RECORDS DEL PARTIDO (HISTORIAL) 🔥 */}
        <div>
          <h2 style={{ fontSize: '1.2rem', marginBottom: '15px', color: '#e2e8f0' }}>Records del partido</h2>
          
          {/* Filtros Corregidos */}
          <div style={{ display: 'flex', gap: '15px', marginBottom: '20px', flexWrap: 'wrap' }}>
            
            {/* Filtro de Fechas */}
            <div style={{ display: 'flex', alignItems: 'center', background: '#15171e', border: '1px solid #2d3748', borderRadius: '8px', padding: '0 15px', height: '45px' }}>
              <Icons.Calendar />
              <input 
                type="date" 
                value={startDate} 
                onChange={(e) => setStartDate(e.target.value)} 
                style={{ background: 'transparent', border: 'none', color: '#a0aec0', outline: 'none', marginLeft: '10px', colorScheme: 'dark', cursor: 'pointer' }} 
              />
              <span style={{ margin: '0 10px', color: '#718096' }}>-</span>
              <input 
                type="date" 
                value={endDate} 
                onChange={(e) => setEndDate(e.target.value)} 
                style={{ background: 'transparent', border: 'none', color: '#a0aec0', outline: 'none', colorScheme: 'dark', cursor: 'pointer' }} 
              />
            </div>
            
            {/* Selector de Tipo de Juego */}
            <select 
              value={gameType} 
              onChange={(e) => setGameType(e.target.value)} 
              style={{ background: '#15171e', border: '1px solid #2d3748', borderRadius: '8px', color: '#fff', padding: '0 20px', height: '45px', outline: 'none', cursor: 'pointer' }}
            >
              <option value="Toda">Toda</option>
              <option value="Casual">Casual Rooms</option>
              <option value="Torneo">Torneos</option>
              <option value="Futures">Futures Games</option>
            </select>
          </div>

          {/* Tabla / Lista de Historial */}
          <div style={{ backgroundColor: '#15171e', border: '1px solid #2d3748', borderRadius: '12px', overflow: 'hidden' }}>
            {loading ? (
              <div style={{ padding: '50px', textAlign: 'center', color: '#a0aec0' }}>Cargando historial...</div>
            ) : history.length === 0 ? (
              <div style={{ padding: '50px', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', color: '#718096' }}>
                <Icons.History />
                <p style={{ marginTop: '15px', fontSize: '1rem' }}>Sin datos</p>
              </div>
            ) : (
              <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
                <thead style={{ background: '#1a202c', color: '#a0aec0', fontSize: '0.85rem', textTransform: 'uppercase' }}>
                  <tr>
                    <th style={{ padding: '15px 20px' }}>Fecha</th>
                    <th style={{ padding: '15px 20px' }}>Mesa / Torneo</th>
                    <th style={{ padding: '15px 20px' }}>Resultado</th>
                    <th style={{ padding: '15px 20px' }}>Ganancia / Pérdida</th>
                  </tr>
                </thead>
                <tbody>
                  {history.map((item, idx) => (
                    <tr key={idx} style={{ borderBottom: '1px solid #2d3748' }}>
                      <td style={{ padding: '15px 20px', color: '#a0aec0' }}>{new Date(item.played_at).toLocaleDateString()}</td>
                      <td style={{ padding: '15px 20px', fontWeight: 'bold' }}>{item.table_id}</td>
                      <td style={{ padding: '15px 20px', color: item.amount_won >= 0 ? '#00e676' : '#ef4444' }}>
                        {item.amount_won >= 0 ? 'Victoria' : 'Derrota'}
                      </td>
                      <td style={{ padding: '15px 20px', fontWeight: 'bold', color: item.amount_won >= 0 ? '#00e676' : '#ef4444' }}>
                        {item.amount_won >= 0 ? `+${item.amount_won} NTX` : `${item.amount_won} NTX`}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </div>

      </div>
    </div>
  );
}