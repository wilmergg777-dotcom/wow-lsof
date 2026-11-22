import React, { useState, useEffect } from 'react';
import { API_URL } from './config'; // 🔥 IMPORTAMOS LA URL DINÁMICA

// Usamos API_URL como base (funciona automáticamente en localhost y VPS)
const API_BASE = API_URL;

// Función auxiliar para calcular el tiempo restante (para hoy)
const formatTime = (ms) => {
  if (ms < 0) return "Iniciando...";
  const totalSeconds = Math.floor(ms / 1000);
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;
  
  if (hours > 0) return `${hours}h ${minutes}m ${seconds}s`;
  return `${minutes}:${seconds.toString().padStart(2, '0')}`;
};

// 🔥 NUEVA FUNCIÓN: Formatea el tiempo según el día del torneo 🔥
const getDisplayTime = (startTime, timeLeft, now) => {
  if (timeLeft <= 0) {
    if (timeLeft > -10 * 60 * 1000) {
      return `Late Reg: ${formatTime(timeLeft + 10 * 60 * 1000)}`;
    }
    return "En Juego";
  }

  const start = new Date(startTime);
  const today = new Date(now);
  const tomorrow = new Date(now);
  tomorrow.setDate(tomorrow.getDate() + 1);

  // Comprobar si es el mismo día
  const isToday = start.getDate() === today.getDate() && 
                  start.getMonth() === today.getMonth() && 
                  start.getFullYear() === today.getFullYear();

  // Comprobar si es mañana
  const isTomorrow = start.getDate() === tomorrow.getDate() && 
                     start.getMonth() === tomorrow.getMonth() && 
                     start.getFullYear() === tomorrow.getFullYear();

  // Formatear la hora exacta (ej. 10:30 AM)
  let hours = start.getHours();
  const minutes = start.getMinutes().toString().padStart(2, '0');
  const ampm = hours >= 12 ? 'PM' : 'AM';
  hours = hours % 12;
  hours = hours ? hours : 12; 
  const timeString = `${hours}:${minutes} ${ampm}`;

  if (isToday) {
    return `Empieza en ${formatTime(timeLeft)}`;
  } else if (isTomorrow) {
    return `Mañana a las ${timeString}`;
  } else {
    const daysOfWeek = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    const dayName = daysOfWeek[start.getDay()];
    return `${dayName} a las ${timeString}`;
  }
};

export default function FuturesGames({ onBack, limit = 8, onEnterTournament }) {
  const [games, setGames] = useState([]);
  const [now, setNow] = useState(Date.now());
  const [loading, setLoading] = useState(true);
  
  // Estados para el Modal
  const [showModal, setShowModal] = useState(false);
  const [selectedGame, setSelectedGame] = useState(null);
  const [errorMsg, setErrorMsg] = useState('');

  // Obtener usuario actual del localStorage
  let currentUser = null;
  try {
    const savedUser = localStorage.getItem('user');
    if (savedUser) currentUser = JSON.parse(savedUser);
  } catch (e) {}
  
  const currentUserId = currentUser ? Number(currentUser.id) : null;

  // Reloj en tiempo real (se actualiza cada segundo)
  useEffect(() => {
    const timer = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(timer);
  }, []);

  // Cargar datos reales del backend
  const fetchGames = async () => {
    try {
      // 🔥 USAMOS API_BASE (que ahora es API_URL dinámico)
      const res = await fetch(`${API_BASE}/api/futures-games`);
      if (!res.ok) throw new Error('Error al cargar los torneos');
      const data = await res.json();
      
      // 🔥 ORDENAR POR HORA DE INICIO PARA QUE NO SE MEZCLEN 🔥
      data.sort((a, b) => a.startTime - b.startTime);
      setGames(data);
    } catch (err) {
      console.error("Error cargando torneos", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchGames();
    const refreshTimer = setInterval(fetchGames, 15000);
    return () => clearInterval(refreshTimer);
  }, []);

  // Manejar clic en Registrar o Ver Mesa
  const handleRegisterClick = (game) => {
    if (!currentUser) {
      alert('Debes iniciar sesión para registrarte o ver la mesa');
      return;
    }
    
    const timeLeft = game.startTime - now;
    const isRegistered = game.players.map(Number).includes(currentUserId);

    if (timeLeft <= 0 && !isRegistered) {
      onEnterTournament(game);
      return;
    }
    
    if (isRegistered) {
      onEnterTournament(game);
      return;
    }
    
    setSelectedGame(game);
    setErrorMsg('');
    setShowModal(true);
  };

  // Confirmar Pago en el Modal
  const confirmRegister = async () => {
    try {
      const token = localStorage.getItem('token');
      // 🔥 USAMOS API_BASE DINÁMICO
      const res = await fetch(`${API_BASE}/api/futures-games/register`, {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ gameId: selectedGame.id })
      });
      
      const data = await res.json();
      
      if (!res.ok) throw new Error(data.error || 'Error al registrar');
      
      const updatedGame = {
        ...selectedGame,
        players: [...selectedGame.players, currentUserId]
      };

      setShowModal(false);
      fetchGames(); 
      
      onEnterTournament(updatedGame);
      
    } catch (err) {
      setErrorMsg(err.message);
    }
  };

  // FILTRO MÁGICO EN TIEMPO REAL
  const activeGames = games.filter(game => {
    if (game.status === 'CANCELLED' || game.status === 'FINISHED') return false;

    const timeLeft = game.startTime - now;
    const LATE_REG_TIME = 10 * 60 * 1000;
    const TOURNAMENT_DURATION = 2 * 60 * 60 * 1000;

    if (timeLeft < -TOURNAMENT_DURATION) return false;
    if (timeLeft < -LATE_REG_TIME && game.players.length < 2) return false;
    
    return true;
  });

  const visibleGames = activeGames.slice(0, limit);

  const content = (
    <div className="grid-4-cols" style={{ gap: '20px' }}>
      {loading && <p style={{ color: '#00e676', gridColumn: '1 / -1' }}>Cargando torneos reales...</p>}
      {!loading && activeGames.length === 0 && <p style={{ color: '#a0aec0', gridColumn: '1 / -1' }}>No hay torneos disponibles en este momento. Esperando nuevos torneos...</p>}
      
      {visibleGames.map((game) => {
        const timeLeft = game.startTime - now;
        const isLateReg = timeLeft <= 0 && timeLeft > -10 * 60 * 1000; 
        const isPlaying = timeLeft <= -10 * 60 * 1000 && timeLeft > -2 * 60 * 60 * 1000; 
        const isRegistered = currentUserId !== null && game.players.map(Number).includes(currentUserId);
        const currentPlayers = game.players.length;

        // 🔥 CÁLCULO DEL PREMIO DINÁMICO EN PANTALLA 🔥
        const totalRecaudado = game.entry * currentPlayers;
        const dynamicPrizePool = currentPlayers > 0 
          ? Math.floor(totalRecaudado * 0.90) 
          : Math.floor((game.entry * 4) * 0.90);

        let buttonText = 'Registrar';
        let buttonBg = 'linear-gradient(180deg, #00e676 0%, #009956 100%)';
        let buttonColor = '#000';
        
        if (isRegistered) {
          buttonText = timeLeft > 0 ? 'Ir al Lobby' : 'Ver Mesa';
          buttonBg = '#3b82f6'; 
          buttonColor = '#fff';
        } else if (isPlaying || isLateReg) {
          buttonText = 'Ver Mesa'; 
          buttonBg = '#4a5568'; 
          buttonColor = '#fff';
        }

        return (
          <div key={game.id} style={{ background: '#1a202c', borderRadius: '12px', overflow: 'hidden', border: '1px solid #2d3748', display: 'flex', flexDirection: 'column' }}>
            
            {/* BANNER CON IMAGEN Y TIEMPO CORRIENDO */}
            <div style={{ 
              height: '150px', 
              backgroundImage: `linear-gradient(to bottom, rgba(0,0,0,0.1), rgba(0,0,0,0.9)), url("${game.image}")`,
              backgroundSize: 'cover', backgroundPosition: 'center', position: 'relative', padding: '10px'
            }}>
              <div style={{ 
                position: 'absolute', top: '10px', right: '10px', background: 'rgba(0,0,0,0.7)', 
                color: isLateReg ? '#fbbf24' : (isPlaying ? '#00e676' : '#ef4444'), 
                padding: '4px 8px', borderRadius: '4px', fontSize: '0.75rem', fontWeight: 'bold' 
              }}>
                {/* 🔥 AQUÍ USAMOS LA NUEVA FUNCIÓN 🔥 */}
                {getDisplayTime(game.startTime, timeLeft, now)}
              </div>
              <div style={{ position: 'absolute', bottom: '10px', left: '10px', right: '10px' }}>
                <h3 style={{ margin: 0, color: '#fff', fontSize: '1.1rem', fontWeight: 'bold' }}>{game.title}</h3>
                <div style={{ color: '#e2b04a', fontSize: '0.8rem', fontWeight: 'bold' }}>Guaranteed Prize</div>
              </div>
            </div>

            {/* INFORMACIÓN INFERIOR */}
            <div style={{ padding: '15px', background: '#12161f', flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
                <span style={{ color: '#a0aec0', fontSize: '0.8rem' }}>Premios</span>
                <span style={{ color: '#00e676', fontSize: '0.9rem', fontWeight: 'bold' }}>{dynamicPrizePool} NTX-20</span>
              </div>
              
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
                <span style={{ color: '#a0aec0', fontSize: '0.8rem' }}>Registro</span>
                <span style={{ color: '#fff', fontSize: '0.9rem', fontWeight: 'bold' }}>{game.entry} NTX-20</span>
              </div>

              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ color: '#718096', fontSize: '0.75rem' }}>👤 {currentPlayers} / {game.maxPlayers}</span>
                
                <button 
                  onClick={() => handleRegisterClick(game)}
                  style={{ 
                    background: buttonBg, 
                    color: buttonColor, 
                    border: 'none', padding: '6px 15px', borderRadius: '4px', 
                    fontWeight: 'bold', fontSize: '0.8rem', cursor: 'pointer'
                  }}
                >
                  {buttonText}
                </button>
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );

  return (
    <div>
      {!onBack ? (
        content
      ) : (
        <main className="main-area">
          <div className="content-scroll" style={{ padding: '1.5rem' }}>
            <button 
              onClick={onBack} 
              style={{ background: 'transparent', border: 'none', color: '#00e676', cursor: 'pointer', marginBottom: '1.5rem', display: 'flex', alignItems: 'center', gap: '5px', fontWeight: 'bold', fontSize: '1rem' }}
            >
              ← Volver al Lobby
            </button>

            <div className="section-header" style={{ marginBottom: '2rem' }}>
              <h2 style={{ fontSize: '1.8rem', fontWeight: '800', color: '#fff' }}>Futures Games (NTX-20)</h2>
              <p style={{ color: '#a0aec0', fontSize: '0.95rem', marginTop: '5px' }}>Torneos continuos 24/7. 300 fichas por jugador. Premios para el Top 3.</p>
            </div>

            {content}
          </div>
        </main>
      )}

      {/* MODAL DE CONFIRMACIÓN DE PAGO */}
      {showModal && selectedGame && (
        <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.85)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 100, backdropFilter: 'blur(5px)' }}>
          <div style={{ background: 'linear-gradient(180deg, #1a202c 0%, #0b0e14 100%)', padding: '30px', borderRadius: '12px', width: '400px', border: '1px solid #4a5568', textAlign: 'center', boxShadow: '0 20px 50px rgba(0,0,0,0.9)' }}>
            <h3 style={{ color: '#fff', margin: '0 0 15px 0', fontSize: '1.4rem', fontWeight: '900' }}>Confirmar Registro</h3>
            <p style={{ color: '#a0aec0', marginBottom: '20px', fontSize: '0.95rem' }}>
              ¿Seguro que quieres pagar <strong style={{ color: '#e2b04a' }}>{selectedGame.entry} NTX-20</strong> para entrar a este torneo?
            </p>

            {errorMsg && <p style={{ color: '#ef4444', marginBottom: '15px', fontWeight: 'bold', fontSize: '0.9rem' }}>{errorMsg}</p>}

            <div style={{ display: 'flex', gap: '10px' }}>
              <button onClick={() => setShowModal(false)} style={{ flex: 1, padding: '12px', background: '#2d3748', color: '#fff', border: 'none', borderRadius: '8px', fontWeight: 'bold', cursor: 'pointer' }}>
                Cancelar
              </button>
              <button onClick={confirmRegister} style={{ flex: 1, padding: '12px', background: 'linear-gradient(180deg, #00e676 0%, #009956 100%)', color: '#000', border: 'none', borderRadius: '8px', fontWeight: 'bold', cursor: 'pointer' }}>
                Sí, Pagar
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}