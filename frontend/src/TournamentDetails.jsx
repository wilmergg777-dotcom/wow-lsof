import { useState } from 'react';

export default function TournamentDetails({ tournament, onBack, onJoin }) {
  const [activeTab, setActiveTab] = useState('info');

  // 🔥 Verificamos si el torneo ya empezó o está en juego
  const isStarted = tournament?.status === 'PLAYING' || (tournament?.startTime && Date.now() > tournament.startTime);
  
  // 🔥 Formateamos la hora de inicio
  const startTimeFormatted = tournament?.startTime 
    ? new Date(tournament.startTime).toLocaleString('es-ES', { hour: '2-digit', minute: '2-digit', day: '2-digit', month: '2-digit' })
    : 'Hoy 12:00';

  return (
    <div style={{ backgroundColor: '#0b0e14', minHeight: '100vh', color: '#fff', fontFamily: 'sans-serif', paddingBottom: '50px' }}>
      
      {/* Botón Volver */}
      <div style={{ padding: '20px', maxWidth: '1200px', margin: '0 auto' }}>
        <button onClick={onBack} style={{ background: 'transparent', color: '#a0aec0', border: 'none', cursor: 'pointer', fontSize: '1rem', display: 'flex', alignItems: 'center', gap: '5px' }}>
          ← Volver al Lobby
        </button>
      </div>

      <div style={{ maxWidth: '1200px', margin: '0 auto', display: 'flex', gap: '20px' }}>
        
        {/* Columna Izquierda (Banner y Detalles) */}
        <div style={{ flex: 2 }}>
          
          {/* Banner Superior */}
          <div style={{ 
            backgroundImage: `linear-gradient(to right, rgba(11,14,20,0.8), rgba(11,14,20,0.2)), url("${tournament?.image || 'https://images.unsplash.com/photo-1596838132731-3301c3fd4317?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'}")`,
            backgroundSize: 'cover', backgroundPosition: 'center', borderRadius: '12px', padding: '40px', position: 'relative', overflow: 'hidden', border: '1px solid #2d3748'
          }}>
            <h1 style={{ fontSize: '3rem', fontWeight: '900', margin: 0, textShadow: '2px 2px 4px #000' }}>
              {tournament?.title?.split('-')[0] || 'ADVANCED'}
            </h1>
            <h2 style={{ fontSize: '1.5rem', margin: '5px 0', color: '#e2b04a', fontWeight: 'bold' }}>★ TOURNAMENT ★</h2>
            <div style={{ fontSize: '3rem', fontWeight: '900', color: '#e2b04a', marginTop: '20px', textShadow: '2px 2px 4px #000' }}>
              {tournament?.prize || '50,000'} NTX-20
            </div>
            <p style={{ color: '#a0aec0', fontSize: '1.2rem', margin: '10px 0' }}>
              Registro: {tournament?.entry || '1,100'} NTX-20
            </p>
            <button 
              onClick={onJoin}
              style={{ 
                background: isStarted ? '#3b82f6' : '#ef4444', 
                color: '#fff', border: 'none', padding: '15px 40px', borderRadius: '8px', 
                fontSize: '1.2rem', fontWeight: 'bold', cursor: 'pointer', marginTop: '20px', 
                boxShadow: isStarted ? '0 4px 15px rgba(59, 130, 246, 0.4)' : '0 4px 15px rgba(239, 68, 68, 0.4)' 
              }}
            >
              {isStarted ? 'Ir a la Mesa' : 'Registrar'}
            </button>
          </div>

          {/* Pestañas */}
          <div style={{ display: 'flex', gap: '20px', borderBottom: '1px solid #2d3748', marginTop: '30px', paddingBottom: '10px' }}>
            <span onClick={() => setActiveTab('info')} style={{ cursor: 'pointer', color: activeTab === 'info' ? '#00e676' : '#a0aec0', borderBottom: activeTab === 'info' ? '2px solid #00e676' : 'none', paddingBottom: '10px', fontWeight: 'bold' }}>Información</span>
            <span onClick={() => setActiveTab('prize')} style={{ cursor: 'pointer', color: activeTab === 'prize' ? '#00e676' : '#a0aec0', borderBottom: activeTab === 'prize' ? '2px solid #00e676' : 'none', paddingBottom: '10px', fontWeight: 'bold' }}>Premio</span>
            <span onClick={() => setActiveTab('blinds')} style={{ cursor: 'pointer', color: activeTab === 'blinds' ? '#00e676' : '#a0aec0', borderBottom: activeTab === 'blinds' ? '2px solid #00e676' : 'none', paddingBottom: '10px', fontWeight: 'bold' }}>Apuestas ciegas</span>
            <span onClick={() => setActiveTab('players')} style={{ cursor: 'pointer', color: activeTab === 'players' ? '#00e676' : '#a0aec0', borderBottom: activeTab === 'players' ? '2px solid #00e676' : 'none', paddingBottom: '10px', fontWeight: 'bold' }}>Jugadores</span>
          </div>

          {/* Contenido de Pestañas */}
          <div style={{ background: '#1a202c', borderRadius: '0 0 12px 12px', padding: '20px', marginTop: '10px', minHeight: '300px' }}>
            {activeTab === 'info' && (
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px' }}>
                <div><p style={{ color: '#a0aec0' }}>Tipo de juego</p><p style={{ fontWeight: 'bold' }}>NL Hold'em</p></div>
                <div><p style={{ color: '#a0aec0' }}>Hora de inicio</p><p style={{ fontWeight: 'bold' }}>{startTimeFormatted}</p></div>
                <div><p style={{ color: '#a0aec0' }}>Fichas iniciales</p><p style={{ fontWeight: 'bold' }}>120,000</p></div>
                <div><p style={{ color: '#a0aec0' }}>Ciegas</p><p style={{ fontWeight: 'bold' }}>0.5 / 1 MTT</p></div>
              </div>
            )}
            {activeTab === 'prize' && (
              <div>
                <h3 style={{ color: '#00e676', marginBottom: '15px' }}>Fondo de premios garantizado</h3>
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '10px', textAlign: 'center' }}>
                  {[1, 2, 3, 4].map(i => (
                    <div key={i} style={{ background: '#12161f', padding: '15px', borderRadius: '8px' }}>
                      <p style={{ color: '#a0aec0', fontSize: '0.8rem' }}>Lugar {i}</p>
                      <p style={{ color: '#e2b04a', fontWeight: 'bold', fontSize: '1.2rem' }}>
                        {((tournament?.prize || 50000) / i).toFixed(2)} NTX
                      </p>
                    </div>
                  ))}
                </div>
              </div>
            )}
            {activeTab === 'blinds' && (
              <table style={{ width: '100%', textAlign: 'left', borderCollapse: 'collapse' }}>
                <thead><tr style={{ borderBottom: '1px solid #2d3748', color: '#a0aec0' }}><th style={{ padding: '10px' }}>Nivel</th><th>Ciegas</th><th>Ante</th></tr></thead>
                <tbody>
                  <tr style={{ borderBottom: '1px solid #2d3748' }}><td style={{ padding: '10px' }}>1</td><td>400 / 800</td><td>80</td></tr>
                  <tr style={{ borderBottom: '1px solid #2d3748' }}><td style={{ padding: '10px' }}>2</td><td>500 / 1,000</td><td>100</td></tr>
                  <tr><td style={{ padding: '10px' }}>3</td><td>750 / 1,500</td><td>150</td></tr>
                </tbody>
              </table>
            )}
            {activeTab === 'players' && (
              <p style={{ color: '#a0aec0', textAlign: 'center', marginTop: '50px' }}>Aún no hay jugadores registrados.</p>
            )}
          </div>
        </div>

        {/* Columna Derecha (Satélites) */}
        <div style={{ flex: 1, background: '#1a202c', borderRadius: '12px', padding: '20px', border: '1px solid #2d3748' }}>
          <h3 style={{ marginBottom: '20px', fontSize: '1.2rem' }}>Satélites</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {[1, 2, 3].map((sat, i) => (
              <div key={i} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', background: '#12161f', padding: '15px', borderRadius: '8px', border: '1px solid #2d3748' }}>
                <div>
                  <p style={{ color: '#00e676', fontWeight: 'bold', fontSize: '0.9rem' }}>Ticket to {tournament?.entry || 1100} NTX</p>
                  <p style={{ color: '#a0aec0', fontSize: '0.75rem', marginTop: '5px' }}>Hoy 15:00</p>
                </div>
                <button style={{ background: '#00e676', color: '#000', border: 'none', padding: '8px 15px', borderRadius: '5px', fontWeight: 'bold', cursor: 'pointer', fontSize: '0.8rem' }}>Aceptar</button>
              </div>
            ))}
          </div>
        </div>

      </div>
    </div>
  );
}