import React, { useState } from 'react';

export default function Profile({
  user,
  balance,
  profileData,
  setProfileData,
  isEditingProfile,
  setIsEditingProfile,
  handleSaveProfile,
  profileTab,
  setProfileTab,
  Icons
}) {
  // 🔥 Lógica para el avatar por defecto (DiceBear) si no hay uno personalizado
  const defaultAvatar = `https://api.dicebear.com/7.x/adventurer/svg?seed=${user?.username || 'player'}`;
  const avatarToShow = profileData.avatar_url ? profileData.avatar_url : defaultAvatar;

  // 🔥 Simulación de Nivel de Crecimiento (5 Niveles)
  // Usamos el balance como simulación de experiencia (XP)
  const xp = balance;
  let levelName = 'Novato';
  let levelColor = '#a0aec0';
  let levelProgress = 0;
  let nextLevelXp = 100;

  if (xp >= 10000) { levelName = 'Leyenda'; levelColor = '#e2b04a'; levelProgress = 100; nextLevelXp = 10000; }
  else if (xp >= 2000) { levelName = 'Maestro'; levelColor = '#ef4444'; levelProgress = ((xp - 2000) / 8000) * 100; nextLevelXp = 10000; }
  else if (xp >= 500) { levelName = 'Profesional'; levelColor = '#00e676'; levelProgress = ((xp - 500) / 1500) * 100; nextLevelXp = 2000; }
  else if (xp >= 100) { levelName = 'Aficionado'; levelColor = '#3b82f6'; levelProgress = ((xp - 100) / 400) * 100; nextLevelXp = 500; }
  else { levelName = 'Novato'; levelColor = '#a0aec0'; levelProgress = (xp / 100) * 100; nextLevelXp = 100; }

  // 🔥 Simulación de Logros
  const [achievementFilter, setAchievementFilter] = useState('Todos');
  
  // Generamos 56 logros simulados (TODOS EMPIEZAN BLOQUEADOS)
  const mockAchievements = Array.from({ length: 56 }).map((_, i) => {
    const isUnlocked = false; // 🔥 FIX: Ahora empiezan todos en 0
    const names = [
      'Primer caldero de oro', '¡TODO A POR TODO!', 'Gana con una casa llena',
      'Consigue 10 logros', 'Círculo de premios diario', 'El primero, el segundo',
      '1er lugar en competencia', '2do lugar en competencia', '3er lugar en la carrera',
      'Alcanzar el nivel primario', 'Alcanzar el nivel intermedio', 'Alcanzar el nivel avanzado'
    ];
    return {
      id: i,
      name: names[i] || `Logro Oculto #${i + 1}`,
      unlocked: isUnlocked,
      date: isUnlocked ? '2026-11-11' : null,
      category: i % 3 === 0 ? 'Integral' : (i % 3 === 1 ? 'Concurso' : 'Casual Rooms'),
      icon: isUnlocked ? '🏆' : '🔒'
    };
  });

  const filteredAchievements = mockAchievements.filter(a => achievementFilter === 'Todos' || a.category === achievementFilter);
  const unlockedCount = mockAchievements.filter(a => a.unlocked).length;

  return (
    <main className="main-area" style={{ backgroundColor: '#0d0f14', minHeight: '100vh', color: '#fff', paddingBottom: '50px' }}>
      
      {/* HEADER DEL PERFIL */}
      <div style={{ position: 'relative', background: 'linear-gradient(180deg, #1a202c 0%, #0d0f14 100%)', padding: '40px 20px 20px 20px', borderBottom: '1px solid #2d3748' }}>
        <div style={{ maxWidth: '1000px', margin: '0 auto', display: 'flex', gap: '30px', alignItems: 'flex-start' }}>
          
          {/* Avatar Grande */}
          <div style={{ width: '120px', height: '120px', borderRadius: '50%', border: '3px solid #D4AF37', overflow: 'hidden', background: '#1a202c', flexShrink: 0, boxShadow: '0 0 20px rgba(212, 175, 55, 0.3)' }}>
            <img src={avatarToShow} alt="Avatar" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
          </div>

          {/* Info del Perfil */}
          <div style={{ flex: 1 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
              <div>
                <h1 style={{ fontSize: '1.8rem', margin: 0, display: 'flex', alignItems: 'center', gap: '10px', fontWeight: '900' }}>
                  {profileData.username} 
                  {/* 🔥 FIX: Ahora muestra el ID único en lugar de @royalbet */}
                  <span style={{ fontSize: '0.9rem', color: '#a0aec0', fontWeight: '400' }}>
                    @{profileData.unique_id || 'royalbet'}
                  </span>
                </h1>
                <p style={{ color: '#a0aec0', fontSize: '0.9rem', marginTop: '5px' }}>Todavía no tengo un perfil</p>
              </div>
              <div style={{ display: 'flex', gap: '10px' }}>
                <button style={{ padding: '8px 16px', background: '#2d3748', color: '#fff', border: 'none', borderRadius: '8px', fontWeight: 'bold', cursor: 'pointer' }}>Compartir</button>
                <button onClick={() => setIsEditingProfile(!isEditingProfile)} style={{ padding: '8px 16px', background: '#00e676', color: '#000', border: 'none', borderRadius: '8px', fontWeight: 'bold', cursor: 'pointer' }}>
                  {isEditingProfile ? 'Cancelar' : 'Editar'}
                </button>
              </div>
            </div>

            {/* Formulario de Edición */}
            {isEditingProfile && (
              <form onSubmit={handleSaveProfile} style={{ marginTop: '1.5rem', background: '#15171e', padding: '1.5rem', borderRadius: '12px', border: '1px solid #2d3748' }}>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
                  <div>
                    <label style={{ color: '#a0aec0', fontSize: '0.8rem', display: 'block', marginBottom: '5px' }}>Nombre de Usuario</label>
                    <input type="text" value={profileData.username} onChange={e => setProfileData({...profileData, username: e.target.value})} required style={{ width: '100%', padding: '10px', background: '#0d0f14', border: '1px solid #2d3748', color: '#fff', borderRadius: '6px' }} />
                  </div>
                  <div>
                    <label style={{ color: '#a0aec0', fontSize: '0.8rem', display: 'block', marginBottom: '5px' }}>URL de tu Foto de Perfil</label>
                    <input type="url" placeholder="https://ejemplo.com/foto.jpg" value={profileData.avatar_url || ''} onChange={e => setProfileData({...profileData, avatar_url: e.target.value})} style={{ width: '100%', padding: '10px', background: '#0d0f14', border: '1px solid #2d3748', color: '#fff', borderRadius: '6px' }} />
                  </div>
                </div>
                <button type="submit" style={{ marginTop: '1.5rem', padding: '10px 24px', background: '#00e676', color: '#000', border: 'none', borderRadius: '8px', fontWeight: 'bold', cursor: 'pointer' }}>Guardar Cambios</button>
              </form>
            )}
          </div>
        </div>
      </div>

      {/* ESTADÍSTICAS (BENEFICIO, CATEGORÍA, NIVEL) */}
      <div style={{ maxWidth: '1000px', margin: '20px auto', padding: '0 20px', display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '15px' }}>
        
        {/* Beneficio Total */}
        <div style={{ background: '#15171e', border: '1px solid #2d3748', borderRadius: '12px', padding: '20px' }}>
          <div style={{ color: '#a0aec0', fontSize: '0.9rem', display: 'flex', alignItems: 'center', gap: '5px' }}>Beneficio Total <span title="Beneficio total generado en torneos y mesas" style={{ cursor: 'help', fontSize: '0.8rem', border: '1px solid #a0aec0', borderRadius: '50%', width: '16px', height: '16px', display: 'inline-flex', alignItems: 'center', justifyContent: 'center' }}>?</span></div>
          <h3 style={{ color: '#00e676', fontSize: '1.5rem', margin: '10px 0 5px 0' }}>+{balance} NTX-20</h3>
          <span style={{ color: '#a0aec0', fontSize: '0.8rem' }}>Más del 10% de los jugadores</span>
        </div>

        {/* Categoría */}
        <div style={{ background: '#15171e', border: '1px solid #2d3748', borderRadius: '12px', padding: '20px' }}>
          <div style={{ color: '#a0aec0', fontSize: '0.9rem' }}>Categoría</div>
          <h3 style={{ fontSize: '1.5rem', margin: '10px 0 5px 0' }}>Novato</h3>
          <span style={{ color: '#a0aec0', fontSize: '0.8rem' }}>Puntos profesionales: 0</span>
        </div>

        {/* Nivel de Crecimiento */}
        <div style={{ background: '#15171e', border: '1px solid #2d3748', borderRadius: '12px', padding: '20px', position: 'relative', overflow: 'hidden' }}>
          <div style={{ color: '#a0aec0', fontSize: '0.9rem', marginBottom: '10px' }}>Nivel de crecimiento</div>
          <h3 style={{ fontSize: '1.5rem', margin: 0, color: levelColor, display: 'flex', alignItems: 'center', gap: '5px' }}>
            {levelName === 'Novato' ? '⭐' : levelName === 'Aficionado' ? '🥉' : levelName === 'Profesional' ? '🥈' : levelName === 'Maestro' ? '🥇' : '👑'} {levelName}
          </h3>
          <span style={{ color: '#a0aec0', fontSize: '0.8rem', display: 'block', marginTop: '5px' }}>Clasificación de experiencia {xp}/{nextLevelXp}</span>
          
          {/* Barra de Progreso */}
          <div style={{ width: '100%', height: '6px', background: '#2d3748', borderRadius: '3px', marginTop: '10px', overflow: 'hidden' }}>
            <div style={{ width: `${levelProgress}%`, height: '100%', background: levelColor, transition: 'width 0.5s ease-out' }} />
          </div>
        </div>
      </div>

      {/* PESTAÑAS (Torneo, Álbum, Logros) */}
      <div style={{ maxWidth: '1000px', margin: '0 auto', padding: '0 20px' }}>
        <div style={{ display: 'flex', gap: '30px', borderBottom: '1px solid #2d3748', marginBottom: '20px' }}>
          <span onClick={() => setProfileTab('torneo')} style={{ cursor: 'pointer', paddingBottom: '12px', color: profileTab === 'torneo' ? '#00e676' : '#a0aec0', borderBottom: profileTab === 'torneo' ? '2px solid #00e676' : '2px solid transparent', fontWeight: 'bold' }}>Torneo</span>
          <span onClick={() => setProfileTab('album')} style={{ cursor: 'pointer', paddingBottom: '12px', color: profileTab === 'album' ? '#00e676' : '#a0aec0', borderBottom: profileTab === 'album' ? '2px solid #00e676' : '2px solid transparent', fontWeight: 'bold' }}>Álbum de fotos</span>
          <span onClick={() => setProfileTab('logro')} style={{ cursor: 'pointer', paddingBottom: '12px', color: profileTab === 'logro' ? '#00e676' : '#a0aec0', borderBottom: profileTab === 'logro' ? '2px solid #00e676' : '2px solid transparent', fontWeight: 'bold' }}>Logro</span>
        </div>

        {/* CONTENIDO: TORNEO (ESTADÍSTICAS) */}
        {profileTab === 'torneo' && (
          <div>
            <div style={{ background: '#15171e', border: '1px solid #2d3748', borderRadius: '12px', padding: '20px', marginBottom: '20px' }}>
              <h3 style={{ margin: '0 0 5px 0', fontSize: '1.1rem' }}>Ganancias Y Pérdidas De Eventos</h3>
              <p style={{ color: '#a0aec0', fontSize: '0.85rem', marginBottom: '20px' }}>Gráfico de ganancias y pérdidas de los últimos 600 Torneos(excluidos los Minería, Satélites, torneos de tickets, etc.), con importes convertidos a MTT.</p>
              
              {/* Gráfico Simulado SVG */}
              <div style={{ height: '180px', width: '100%', position: 'relative' }}>
                <svg width="100%" height="100%" viewBox="0 0 1000 200" preserveAspectRatio="none">
                  <defs>
                    <linearGradient id="chartGradient" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor="#D4AF37" stopOpacity="0.3" />
                      <stop offset="100%" stopColor="#D4AF37" stopOpacity="0" />
                    </linearGradient>
                  </defs>
                  {/* Líneas de fondo */}
                  <line x1="0" y1="50" x2="1000" y2="50" stroke="#2d3748" strokeWidth="1" strokeDasharray="5,5" />
                  <line x1="0" y1="100" x2="1000" y2="100" stroke="#2d3748" strokeWidth="1" strokeDasharray="5,5" />
                  <line x1="0" y1="150" x2="1000" y2="150" stroke="#2d3748" strokeWidth="1" strokeDasharray="5,5" />
                  
                  {/* Área del gráfico */}
                  <path d="M 0 180 Q 200 160 400 170 T 800 120 T 1000 100 L 1000 200 L 0 200 Z" fill="url(#chartGradient)" />
                  <path d="M 0 180 Q 200 160 400 170 T 800 120 T 1000 100" fill="none" stroke="#D4AF37" strokeWidth="3" />
                </svg>
              </div>
            </div>

            <div style={{ background: '#15171e', border: '1px solid #2d3748', borderRadius: '12px', padding: '40px', textAlign: 'center', color: '#a0aec0' }}>
              <div style={{ fontSize: '3rem', marginBottom: '10px', opacity: 0.5 }}>♠️</div>
              <h3 style={{ margin: 0 }}>No Tournament Yet</h3>
              <p style={{ fontSize: '0.9rem' }}>Tus 10 mejores actuaciones durante 52 semanas determinan tu clasificación profesional.</p>
            </div>
          </div>
        )}

        {/* CONTENIDO: ÁLBUM */}
        {profileTab === 'album' && (
          <div style={{ background: '#15171e', border: '1px solid #2d3748', borderRadius: '12px', padding: '50px', textAlign: 'center', color: '#a0aec0' }}>
            <div style={{ fontSize: '3rem', marginBottom: '15px', opacity: 0.5 }}>📸</div>
            <h3 style={{ margin: 0, color: '#fff' }}>Álbum vacío</h3>
            <p style={{ fontSize: '0.9rem', marginBottom: '20px' }}>Comparte tus mejores jugadas o trofeos con la comunidad.</p>
            <button style={{ padding: '10px 24px', background: '#00e676', color: '#000', border: 'none', borderRadius: '8px', fontWeight: 'bold', cursor: 'pointer' }}>Subir Foto</button>
          </div>
        )}

        {/* CONTENIDO: LOGROS (56 LOGROS) */}
        {profileTab === 'logro' && (
          <div style={{ background: '#15171e', border: '1px solid #2d3748', borderRadius: '12px', padding: '20px' }}>
            
            {/* Resumen de Logros */}
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '25px', background: 'linear-gradient(90deg, #1a202c 0%, #0d0f14 100%)', padding: '20px', borderRadius: '12px', border: '1px solid #2d3748' }}>
              <div>
                <h3 style={{ margin: 0, fontSize: '1.3rem' }}>Mis logros</h3>
                <p style={{ margin: '5px 0 0 0', color: '#00e676', fontSize: '1.8rem', fontWeight: 'bold' }}>{unlockedCount}/56</p>
                <p style={{ margin: '5px 0 0 0', color: '#a0aec0', fontSize: '0.85rem' }}>Has completado el {((unlockedCount/56)*100).toFixed(1)}% de todos los logros.</p>
              </div>
              <div style={{ fontSize: '4rem' }}>🏅</div>
            </div>

            {/* Filtros */}
            <div style={{ display: 'flex', gap: '10px', marginBottom: '20px' }}>
              {['Todos', 'Integral', 'Concurso', 'Casual Rooms'].map(filter => (
                <button 
                  key={filter}
                  onClick={() => setAchievementFilter(filter)}
                  style={{ padding: '6px 16px', background: achievementFilter === filter ? '#2d3748' : 'transparent', color: achievementFilter === filter ? '#fff' : '#a0aec0', border: '1px solid #2d3748', borderRadius: '20px', fontSize: '0.85rem', cursor: 'pointer', transition: 'all 0.2s' }}
                >
                  {filter} {filter === 'Todos' ? `${unlockedCount}/56` : ''}
                </button>
              ))}
            </div>

            {/* Cuadrícula de Logros */}
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(160px, 1fr))', gap: '15px' }}>
              {filteredAchievements.map((ach) => (
                <div key={ach.id} style={{ 
                  background: ach.unlocked ? '#1a202c' : '#0d0f14', 
                  border: `1px solid ${ach.unlocked ? '#D4AF37' : '#2d3748'}`, 
                  borderRadius: '10px', 
                  padding: '15px', 
                  textAlign: 'center',
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  opacity: ach.unlocked ? 1 : 0.6,
                  position: 'relative'
                }}>
                  {/* Icono del logro */}
                  <div style={{ 
                    width: '60px', height: '60px', borderRadius: '50%', 
                    background: ach.unlocked ? 'radial-gradient(circle, rgba(212,175,55,0.2) 0%, transparent 70%)' : 'transparent',
                    display: 'flex', justifyContent: 'center', alignItems: 'center', fontSize: '2.5rem', marginBottom: '10px'
                  }}>
                    {ach.icon}
                  </div>
                  
                  {/* Nombre */}
                  <h4 style={{ margin: 0, fontSize: '0.85rem', color: ach.unlocked ? '#fff' : '#718096', lineHeight: '1.2' }}>{ach.name}</h4>
                  
                  {/* Fecha o Candado */}
                  <div style={{ marginTop: '10px', fontSize: '0.7rem', color: '#a0aec0' }}>
                    {ach.unlocked ? ach.date : 'Bloqueado'}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </main>
  );
}