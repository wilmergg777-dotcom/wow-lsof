import React, { useState, useEffect } from 'react';

const formatTime = (ms) => {
  if (ms < 0) return "Iniciando...";
  const totalSeconds = Math.floor(ms / 1000);
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;
  if (hours > 0) return `${hours}h ${minutes}m ${seconds}s`;
  return `${minutes}:${seconds.toString().padStart(2, '0')}`;
};

export default function TournamentLobby({ tournament, onBack, onEnterTable }) {
  const [now, setNow] = useState(Date.now());
  const [activeTab, setActiveTab] = useState('premios');

  useEffect(() => {
    const timer = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(timer);
  }, []);

  const timeLeft = tournament.startTime - now;
  
  // 🔥 FIX: El torneo empieza exactamente a la hora (timeLeft <= 0)
  const isStarted = timeLeft <= 0;
  // 🔥 Late Reg: 10 minutos después del inicio
  const isLateReg = timeLeft <= 0 && timeLeft > -10 * 60 * 1000;

  // Datos simulados para la tabla de jugadores
  const playersList = tournament.players.map((id, index) => ({
    rank: index + 1,
    name: `Jugador-${id}`, 
    chips: 300,
    prize: 0
  }));

  // Datos simulados para la tabla de premios
  const prizeDistribution = [
    { place: 1, percentage: '21.28%' },
    { place: 2, percentage: '14.89%' },
    { place: 3, percentage: '10.64%' },
    { place: 4, percentage: '8.94%' },
    { place: 5, percentage: '7.02%' },
    { place: 6, percentage: '5.53%' },
  ];

  // Datos simulados para la tabla de ciegas
  const blindStructure = [
    { level: 1, duration: '15s x 3', ante: '-', blinds: '200/400' },
    { level: 2, duration: '15s x 3', ante: '-', blinds: '300/600' },
    { level: 3, duration: '15s x 3', ante: '-', blinds: '400/800' },
    { level: 4, duration: '15s x 3', ante: '-', blinds: '500/1,000' },
    { level: 5, duration: '15s x 3', ante: '-', blinds: '700/1,400' },
    { level: 6, duration: '15s x 3', ante: '-', blinds: '900/1,800' },
  ];

  return (
    <main className="main-area" style={{ background: '#0b0e14', minHeight: '100vh', paddingBottom: '40px' }}>
      
      {/* 🔥 BANNER GIGANTE SUPERIOR 🔥 */}
      <div style={{ 
        position: 'relative',
        height: '380px',
        backgroundImage: `linear-gradient(to bottom, rgba(0,0,0,0.2) 0%, rgba(11,14,20,1) 100%), url("${tournament.image}")`,
        backgroundSize: 'cover',
        backgroundPosition: 'center',
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'center',
        textAlign: 'center',
        padding: '20px'
      }}>
        <button 
          onClick={onBack} 
          style={{ position: 'absolute', top: '20px', left: '20px', background: 'rgba(0,0,0,0.5)', border: '1px solid #4a5568', color: '#fff', padding: '8px 15px', borderRadius: '20px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '5px', fontWeight: 'bold', fontSize: '0.9rem', zIndex: 10 }}
        >
          ← Volver
        </button>

        <h1 style={{ margin: 0, color: '#fff', fontSize: '3.5rem', fontWeight: '900', textShadow: '0 4px 10px #000', letterSpacing: '2px', textTransform: 'uppercase' }}>
          {tournament.title.split('-')[0].trim()}
        </h1>
        <h2 style={{ margin: '5px 0', color: '#e2b04a', fontSize: '1.2rem', fontWeight: 'bold', textShadow: '0 2px 5px #000' }}>
          ★ TOURNAMENT ★
        </h2>
        
        <div style={{ 
          background: 'linear-gradient(90deg, transparent, rgba(0,0,0,0.8), transparent)', 
          padding: '10px 40px', marginTop: '20px', borderRadius: '10px'
        }}>
          <div style={{ color: '#fff', fontSize: '1.2rem', fontWeight: 'bold', textShadow: '0 2px 4px #000' }}>
            Guaranteed Prize
          </div>
          <div style={{ color: '#fbbf24', fontSize: '4rem', fontWeight: '900', textShadow: '0 4px 10px #000', lineHeight: '1' }}>
            {tournament.prize} <span style={{ fontSize: '1.5rem' }}>NTX-20</span>
          </div>
        </div>

        <div style={{ position: 'absolute', bottom: '20px', width: '100%', display: 'flex', justifyContent: 'center', gap: '40px' }}>
          <div style={{ color: '#a0aec0', fontSize: '0.9rem' }}>
            Hora de inicio: {new Date(tournament.startTime).toLocaleTimeString()}
          </div>
          <div style={{ color: isLateReg ? '#fbbf24' : (isStarted ? '#a0aec0' : '#ef4444'), fontWeight: 'bold', fontSize: '1rem' }}>
            {timeLeft > 0 ? `Comienza en: ${formatTime(timeLeft)}` : isLateReg ? `Late Reg: ${formatTime(timeLeft + 10*60*1000)}` : 'En Juego'}
          </div>
        </div>
      </div>

      {/* 🔥 BOTONES DE ACCIÓN Y PESTAÑAS 🔥 */}
      <div style={{ maxWidth: '1100px', margin: '0 auto', padding: '0 20px', marginTop: '-20px', position: 'relative', zIndex: 5 }}>
        
        <div style={{ display: 'flex', gap: '15px', marginBottom: '20px' }}>
          
          {/* 🔥 BOTÓN DE JUGAR (HABILITADO EXACTAMENTE A LA HORA DE INICIO) 🔥 */}
          <button 
            disabled={!isStarted}
            onClick={() => isStarted && onEnterTable && onEnterTable(tournament)}
            style={{ 
              flex: 1, padding: '15px', 
              background: isStarted ? 'linear-gradient(180deg, #00e676 0%, #009956 100%)' : 'rgba(45, 55, 72, 0.3)', 
              color: isStarted ? '#000' : '#718096', 
              border: 'none', borderRadius: '8px', 
              fontWeight: 'bold', fontSize: '1.1rem', 
              cursor: isStarted ? 'pointer' : 'not-allowed', 
              transition: '0.2s' 
            }}
          >
            {isStarted ? 'Ir a la Mesa (Jugar)' : 'Esperando inicio...'}
          </button>
          
          {/* Indicador de Registro Confirmado */}
          <div style={{ 
            flex: 2, padding: '15px', 
            background: 'linear-gradient(180deg, #10b981 0%, #047857 100%)', 
            color: '#fff', border: 'none', borderRadius: '8px', 
            fontWeight: 'bold', fontSize: '1.1rem', 
            display: 'flex', justifyContent: 'center', alignItems: 'center', 
            cursor: 'default', boxShadow: '0 4px 15px rgba(16, 185, 129, 0.3)' 
          }}>
            ✔️ Registro Confirmado ({tournament.entry} NTX-20)
          </div>
        </div>

        {/* Barra de Pestañas */}
        <div style={{ display: 'flex', borderBottom: '1px solid #2d3748', marginBottom: '20px', background: '#1a202c', borderRadius: '8px 8px 0 0', overflow: 'hidden' }}>
          {['info', 'premios', 'ciegas'].map((tab) => (
            <button
              key={tab}
              onClick={() => setActiveTab(tab)}
              style={{
                flex: 1, padding: '12px', background: activeTab === tab ? '#2d3748' : 'transparent',
                color: activeTab === tab ? '#00e676' : '#a0aec0', border: 'none',
                borderBottom: activeTab === tab ? '2px solid #00e676' : 'none',
                fontWeight: 'bold', fontSize: '0.95rem', cursor: 'pointer', transition: '0.2s'
              }}
            >
              {tab === 'info' ? 'Información' : tab === 'premios' ? 'Premio' : 'Apuestas ciegas'}
            </button>
          ))}
        </div>

        {/* 🔥 CONTENIDO DE LAS PESTAÑAS (DIVIDIDO EN 2 COLUMNAS) 🔥 */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px' }}>
          
          {/* COLUMNA IZQUIERDA: CONTENIDO DINÁMICO */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            
            {/* Pestaña Premios */}
            {activeTab === 'premios' && (
              <div style={{ background: '#1a202c', borderRadius: '12px', border: '1px solid #2d3748', padding: '20px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
                  <h3 style={{ color: '#fff', margin: 0, fontSize: '1.1rem' }}>Premios</h3>
                  <span style={{ color: '#00e676', fontSize: '1.2rem', fontWeight: 'bold' }}>{tournament.prize} NTX-20</span>
                </div>
                
                {/* Encabezado de la tabla */}
                <div style={{ display: 'flex', justifyContent: 'space-between', borderBottom: '1px solid #2d3748', paddingBottom: '5px', color: '#a0aec0', fontSize: '0.8rem', fontWeight: 'bold', marginBottom: '10px' }}>
                  <span>Lugar</span>
                  <span>Otorgar</span>
                </div>
                
                {/* Filas de premios */}
                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                  {prizeDistribution.map((item, index) => (
                    <div key={index} style={{ display: 'flex', justifyContent: 'space-between', borderBottom: '1px solid rgba(45, 55, 72, 0.3)', paddingBottom: '5px', fontSize: '0.9rem' }}>
                      <span style={{ color: '#a0aec0' }}>{item.place}</span>
                      <span style={{ color: '#fff', fontWeight: 'bold' }}>{item.percentage}</span>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Pestaña Ciegas */}
            {activeTab === 'ciegas' && (
              <div style={{ background: '#1a202c', borderRadius: '12px', border: '1px solid #2d3748', padding: '20px' }}>
                <h3 style={{ color: '#fff', margin: '0 0 15px 0', fontSize: '1.1rem' }}>Apuestas ciegas</h3>
                
                {/* Encabezado de la tabla */}
                <div style={{ display: 'grid', gridTemplateColumns: '50px 1fr 60px 1fr', gap: '10px', borderBottom: '1px solid #2d3748', paddingBottom: '5px', color: '#a0aec0', fontSize: '0.8rem', fontWeight: 'bold', marginBottom: '10px' }}>
                  <span>Nivel</span>
                  <span>Duración</span>
                  <span>Ante</span>
                  <span style={{ textAlign: 'right' }}>Ciegas</span>
                </div>
                
                {/* Filas de ciegas */}
                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                  {blindStructure.map((item, index) => (
                    <div key={index} style={{ display: 'grid', gridTemplateColumns: '50px 1fr 60px 1fr', gap: '10px', borderBottom: '1px solid rgba(45, 55, 72, 0.3)', paddingBottom: '5px', fontSize: '0.9rem', alignItems: 'center' }}>
                      <span style={{ color: '#fff' }}>{item.level}</span>
                      <span style={{ color: '#a0aec0' }}>{item.duration}</span>
                      <span style={{ color: '#a0aec0' }}>{item.ante}</span>
                      <span style={{ color: '#fff', textAlign: 'right', fontWeight: 'bold' }}>{item.blinds}</span>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Pestaña Información (Placeholder) */}
            {activeTab === 'info' && (
              <div style={{ background: '#1a202c', borderRadius: '12px', border: '1px solid #2d3748', padding: '20px', textAlign: 'center', color: '#718096' }}>
                <p>Información general del torneo (Próximamente).</p>
              </div>
            )}

          </div>

          {/* COLUMNA DERECHA: TABLA DE JUGADORES */}
          <div style={{ background: '#1a202c', borderRadius: '12px', border: '1px solid #2d3748', padding: '20px', display: 'flex', flexDirection: 'column' }}>
            <h3 style={{ color: '#fff', margin: '0 0 15px 0', fontSize: '1.1rem', borderBottom: '1px solid #2d3748', paddingBottom: '10px' }}>
              Jugadores ({tournament.players.length})
            </h3>
            
            {/* Cabecera de la Tabla de Jugadores */}
            <div style={{ display: 'grid', gridTemplateColumns: '40px 1fr 80px 80px', gap: '10px', paddingBottom: '10px', borderBottom: '1px solid #2d3748', color: '#a0aec0', fontSize: '0.8rem', fontWeight: 'bold' }}>
              <div>Rank</div>
              <div>Jugador</div>
              <div style={{ textAlign: 'right' }}>Fichas</div>
              <div style={{ textAlign: 'right' }}>Premio</div>
            </div>

            {/* Cuerpo de la Tabla de Jugadores */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '5px', marginTop: '10px', overflowY: 'auto', maxHeight: '400px' }}>
              {playersList.length === 0 ? (
                <div style={{ textAlign: 'center', padding: '20px', color: '#718096', fontStyle: 'italic' }}>
                  Esperando más jugadores...
                </div>
              ) : (
                playersList.map((p, i) => (
                  <div key={i} style={{ display: 'grid', gridTemplateColumns: '40px 1fr 80px 80px', gap: '10px', padding: '8px 0', borderBottom: '1px solid rgba(45, 55, 72, 0.5)', alignItems: 'center' }}>
                    <div style={{ color: '#fff', fontSize: '0.9rem' }}>{p.rank}</div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <div style={{ width: '24px', height: '24px', borderRadius: '50%', background: '#4a5568', display: 'flex', justifyContent: 'center', alignItems: 'center', fontSize: '0.8rem', color: '#fff' }}>
                        {p.name.charAt(0)}
                      </div>
                      <span style={{ color: '#fff', fontSize: '0.9rem', fontWeight: '500' }}>{p.name}</span>
                    </div>
                    <div style={{ textAlign: 'right', color: '#00e676', fontSize: '0.9rem', fontWeight: 'bold' }}>{p.chips}</div>
                    <div style={{ textAlign: 'right', color: '#a0aec0', fontSize: '0.9rem' }}>{p.prize > 0 ? p.prize : '-'}</div>
                  </div>
                ))
              )}
            </div>
          </div>

        </div>
      </div>
    </main>
  );
}