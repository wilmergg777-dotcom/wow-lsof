import React, { useState, useEffect } from 'react';
import { API_URL } from './config'; // 🔥 IMPORTAMOS LA URL DINÁMICA
import './index.css';
// IMPORTACIÓN DE LOS NUEVOS ARCHIVOS
import ClubBandeja from './ClubBandeja';
import ClubMiembros from './ClubMiembros';
import ClubContador from './ClubContador';
import ClubDatos from './ClubDatos';

// ==========================================
// COMPONENTES UI REUTILIZABLES
// ==========================================
const SectionCard = ({ children, style }) => (
  <div style={{ backgroundColor: '#1e1e1e', borderRadius: '12px', padding: '15px', marginBottom: '15px', ...style }}>
    {children}
  </div>
);

const ToggleSwitch = ({ active, onChange }) => (
  <div 
    onClick={onChange}
    style={{
      width: '44px', height: '24px', borderRadius: '12px', cursor: 'pointer',
      backgroundColor: active ? '#00b86b' : '#444',
      position: 'relative', transition: '0.3s', flexShrink: 0
    }}
  >
    <div style={{
      width: '18px', height: '18px', borderRadius: '50%', backgroundColor: 'white',
      position: 'absolute', top: '3px', left: active ? '23px' : '3px', transition: '0.3s'
    }} />
  </div>
);

const Stepper = ({ value, onIncrease, onDecrease }) => (
  <div style={{ display: 'flex', alignItems: 'center', backgroundColor: '#121212', borderRadius: '8px', padding: '5px 10px', gap: '15px' }}>
    <button onClick={onDecrease} style={{ background: 'none', border: '1px solid #444', borderRadius: '50%', width: '24px', height: '24px', color: '#ccc', cursor: 'pointer', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>−</button>
    <span style={{ color: 'white', fontSize: '14px', minWidth: '80px', textAlign: 'center' }}>{value}</span>
    <button onClick={onIncrease} style={{ background: 'none', border: '1px solid #444', borderRadius: '50%', width: '24px', height: '24px', color: '#ccc', cursor: 'pointer', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>+</button>
  </div>
);

const SegmentedControl = ({ options, selected, onSelect }) => (
  <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
    {options.map(opt => (
      <button 
        key={opt}
        onClick={() => onSelect(opt)}
        style={{
          flex: 1, padding: '10px 0', borderRadius: '8px', border: selected === opt ? '1px solid #fff' : '1px solid transparent',
          backgroundColor: selected === opt ? '#333' : '#2a2a2a', color: selected === opt ? '#fff' : '#888',
          fontSize: '13px', cursor: 'pointer', minWidth: '60px'
        }}
      >
        {opt}
      </button>
    ))}
  </div>
);

// ==========================================
// 1. PANTALLA DE ENTRADA
// ==========================================
const ClubGateway = ({ onCreateClub, onJoinClub, onBack }) => {
  const [clubName, setClubName] = useState('');
  const [joinCode, setJoinCode] = useState('');
  const [isCreating, setIsCreating] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleCreateSubmit = async () => {
    if (!clubName.trim()) return alert('Escribe un nombre');
    setLoading(true);
    await onCreateClub(clubName);
    setLoading(false);
  };

  const handleJoinSubmit = async () => {
    if (!joinCode.trim()) return alert('Escribe un código');
    setLoading(true);
    await onJoinClub(joinCode);
    setLoading(false);
  };

  return (
    <div style={{ padding: '20px', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', minHeight: '80vh' }}>
      <button onClick={onBack} style={{ alignSelf: 'flex-start', background: 'none', border: 'none', color: 'white', fontSize: '20px', cursor: 'pointer', marginBottom: '20px' }}>← Volver</button>
      <div style={{ fontSize: '4rem', marginBottom: '20px' }}>🃏</div>
      <h2 style={{ color: 'white', marginBottom: '10px' }}>Bienvenido a Clubes</h2>
      
      <div style={{ width: '100%', maxWidth: '400px', display: 'flex', flexDirection: 'column', gap: '15px', marginTop: '20px' }}>
        {!isCreating ? (
          <button onClick={() => setIsCreating(true)} style={{ padding: '15px', background: '#00b86b', color: 'white', border: 'none', borderRadius: '8px', fontWeight: 'bold', fontSize: '16px', cursor: 'pointer' }}>
            + Crear mi propio Club
          </button>
        ) : (
          <div style={{ background: '#1e1e1e', padding: '15px', borderRadius: '8px', border: '1px solid #333' }}>
            <p style={{ color: 'white', marginTop: 0, marginBottom: '10px' }}>Nombre de tu club:</p>
            <input type="text" placeholder="Ej: RoyalBet" value={clubName} onChange={(e) => setClubName(e.target.value)} style={{ width: '100%', padding: '12px', background: '#121212', border: '1px solid #444', color: 'white', borderRadius: '5px', marginBottom: '10px', boxSizing: 'border-box' }} />
            <div style={{ display: 'flex', gap: '10px' }}>
              <button onClick={() => setIsCreating(false)} style={{ flex: 1, padding: '10px', background: 'transparent', color: '#aaa', border: '1px solid #444', borderRadius: '5px', cursor: 'pointer' }}>Cancelar</button>
              <button onClick={handleCreateSubmit} disabled={loading} style={{ flex: 1, padding: '10px', background: '#00b86b', color: 'white', border: 'none', borderRadius: '5px', fontWeight: 'bold', cursor: loading ? 'not-allowed' : 'pointer' }}>
                {loading ? 'Creando...' : 'Crear'}
              </button>
            </div>
          </div>
        )}

        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', margin: '10px 0' }}>
          <div style={{ flex: 1, height: '1px', background: '#333' }}></div>
          <span style={{ color: '#666', fontSize: '12px' }}>O</span>
          <div style={{ flex: 1, height: '1px', background: '#333' }}></div>
        </div>

        <input type="text" placeholder="Código de invitación (Ej: CLUB1234)" value={joinCode} onChange={(e) => setJoinCode(e.target.value)} style={{ padding: '15px', background: '#1e1e1e', border: '1px solid #444', color: 'white', borderRadius: '8px' }} />
        <button onClick={handleJoinSubmit} disabled={loading} style={{ padding: '15px', background: 'transparent', color: '#00b86b', border: '2px solid #00b86b', borderRadius: '8px', fontWeight: 'bold', cursor: loading ? 'not-allowed' : 'pointer' }}>
          {loading ? 'Buscando...' : 'Unirse a un Club'}
        </button>
      </div>
    </div>
  );
};

// ==========================================
// MODAL PARA EDITAR EL CLUB
// ==========================================
const EditClubModal = ({ club, onClose, onSave }) => {
  const [name, setName] = useState(club.name);
  const [description, setDescription] = useState(club.description || '');
  const [avatar, setAvatar] = useState(club.avatar_url || '👑');
  const [loading, setLoading] = useState(false);

  const handleSave = async () => {
    setLoading(true);
    const exito = await onSave({ name, description, avatar_url: avatar });
    setLoading(false);
    if (exito) {
      onClose();
    }
  };

  return (
    <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.8)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 100 }}>
      <div style={{ background: '#1e1e1e', padding: '20px', borderRadius: '12px', width: '90%', maxWidth: '400px', border: '1px solid #333' }}>
        <h3 style={{ color: 'white', marginTop: 0 }}>Editar Club</h3>
        
        <label style={{ color: '#aaa', fontSize: '12px' }}>Nombre</label>
        <input type="text" value={name} onChange={e => setName(e.target.value)} style={{ width: '100%', padding: '10px', background: '#121212', border: '1px solid #444', color: 'white', borderRadius: '5px', marginBottom: '10px', boxSizing: 'border-box' }} />
        
        <label style={{ color: '#aaa', fontSize: '12px' }}>Foto (Emoji o URL)</label>
        <input type="text" value={avatar} onChange={e => setAvatar(e.target.value)} style={{ width: '100%', padding: '10px', background: '#121212', border: '1px solid #444', color: 'white', borderRadius: '5px', marginBottom: '10px', boxSizing: 'border-box' }} />
        
        <label style={{ color: '#aaa', fontSize: '12px' }}>Aviso / Dirección</label>
        <textarea value={description} onChange={e => setDescription(e.target.value)} style={{ width: '100%', padding: '10px', background: '#121212', border: '1px solid #444', color: 'white', borderRadius: '5px', marginBottom: '15px', minHeight: '60px', boxSizing: 'border-box' }} />

        <div style={{ display: 'flex', gap: '10px' }}>
          <button onClick={onClose} style={{ flex: 1, padding: '10px', background: 'transparent', color: '#aaa', border: '1px solid #444', borderRadius: '5px', cursor: 'pointer' }}>Cancelar</button>
          <button onClick={handleSave} disabled={loading} style={{ flex: 1, padding: '10px', background: '#00b86b', color: 'white', border: 'none', borderRadius: '5px', fontWeight: 'bold', cursor: loading ? 'not-allowed' : 'pointer' }}>
            {loading ? 'Guardando...' : 'Guardar'}
          </button>
        </div>
      </div>
    </div>
  );
};

// ==========================================
// 2. LOBBY DEL CLUB
// ==========================================
const ClubLobby = ({ club, isAdmin, onBack, onCreateTable, onOpenAdmin, onUpdateClub, activeTables, onDeleteTable, onEditTable, onOpenTab }) => {
  const [showBottomBar, setShowBottomBar] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);

  const handleUpdate = async (newData) => {
    try {
      const token = localStorage.getItem('token');
      // 🔥 USAMOS API_URL DINÁMICA
      const res = await fetch(`${API_URL}/api/clubs/update`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
        body: JSON.stringify(newData)
      });
      
      if (!res.ok) {
        const errorData = await res.json();
        throw new Error(errorData.error || "Error desconocido del servidor");
      }

      onUpdateClub(newData);
      return true; 
    } catch (error) {
      alert("Fallo al guardar: " + error.message);
      return false; 
    }
  };

  return (
    <div style={{ backgroundColor: '#0a0a0a', minHeight: '100vh', paddingBottom: '90px' }}>
      
      {showEditModal && <EditClubModal club={club} onClose={() => setShowEditModal(false)} onSave={handleUpdate} />}

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px 20px', borderBottom: '1px solid #222' }}>
        <button onClick={onBack} style={{ background: 'none', border: 'none', color: 'white', fontSize: '24px', cursor: 'pointer' }}>‹</button>
        <h2 style={{ margin: 0, fontSize: '18px', color: 'white', fontWeight: 'bold' }}>Club</h2>
        <span style={{ fontSize: '20px', cursor: 'pointer' }}>🔔</span>
      </div>

      <div style={{ padding: '15px 20px' }}>
        <div style={{ display: 'flex', gap: '15px' }}>
          <div style={{ position: 'relative' }}>
            <div style={{ width: '70px', height: '70px', borderRadius: '12px', backgroundColor: '#222', display: 'flex', justifyContent: 'center', alignItems: 'center', fontSize: '30px', overflow: 'hidden', border: '1px solid #444' }}>
              {club.avatar_url || '👑'}
            </div>
            <div style={{ position: 'absolute', top: -5, right: -5, background: '#00b86b', borderRadius: '50%', width: '20px', height: '20px', display: 'flex', justifyContent: 'center', alignItems: 'center', fontSize: '12px', border: '2px solid #0a0a0a' }}>✓</div>
          </div>
          
          <div style={{ flex: 1 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <h3 style={{ margin: 0, color: 'white', fontSize: '18px' }}>{club.name}</h3>
              {isAdmin && (
                <span onClick={() => setShowEditModal(true)} style={{ cursor: 'pointer', fontSize: '14px', color: '#00b86b' }}>✎</span>
              )}
              <span style={{ fontSize: '14px', color: '#888' }}>🔗</span>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '5px', marginTop: '5px' }}>
              <span style={{ background: '#333', color: '#aaa', fontSize: '10px', padding: '2px 6px', borderRadius: '4px' }}>CÓDIGO</span>
              <span style={{ color: '#00b86b', fontWeight: 'bold', fontSize: '12px' }}>{club.code}</span>
            </div>
            <div style={{ display: 'flex', gap: '15px', marginTop: '8px', fontSize: '12px', color: '#ccc' }}>
              <span><strong style={{ color: 'white' }}>1</strong> Jugadores</span>
              <span><strong style={{ color: 'white' }}>{activeTables.length}</strong> Mesas</span>
            </div>
          </div>
        </div>

        <div style={{ display: 'flex', gap: '10px', marginTop: '15px' }}>
          <div style={{ background: '#222', borderRadius: '20px', padding: '5px 12px', fontSize: '12px', color: '#ccc', display: 'flex', alignItems: 'center', gap: '5px' }}>
            <span style={{ color: '#aaa' }}>⬡</span> Nivel Gratis
          </div>
        </div>
      </div>

      <div style={{ padding: '0 20px', marginBottom: '15px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '5px', marginBottom: '8px' }}>
          <span style={{ color: '#00b86b', fontSize: '14px' }}>✎</span>
          <span style={{ color: 'white', fontSize: '14px' }}>Aviso / Información</span>
        </div>
        <div style={{ background: '#1a1a1a', borderRadius: '8px', padding: '15px', color: '#ccc', fontSize: '14px', minHeight: '60px', border: '1px solid #222' }}>
          {club.description || 'Escribe sobre el club.'}
        </div>
      </div>

      <div style={{ display: 'flex', overflowX: 'auto', borderBottom: '1px solid #222', padding: '0 20px', gap: '20px', scrollbarWidth: 'none' }}>
        {['Todos', 'NLH', 'PLO', 'AoF', '6+', 'SNG', 'MTT'].map((tab, i) => (
          <div key={tab} style={{ paddingBottom: '10px', color: i === 0 ? 'white' : '#888', fontSize: '14px', fontWeight: i === 0 ? 'bold' : 'normal', borderBottom: i === 0 ? '2px solid #00b86b' : 'none', cursor: 'pointer', whiteSpace: 'nowrap' }}>
            {tab}
          </div>
        ))}
      </div>

      {isAdmin && (
        <div style={{ padding: '20px' }}>
          <button onClick={onCreateTable} style={{ width: '100%', padding: '15px', background: 'transparent', border: '2px solid #00b86b', color: '#00b86b', borderRadius: '8px', fontWeight: 'bold', fontSize: '16px', cursor: 'pointer' }}>
            Crear Mesa Nueva
          </button>
        </div>
      )}

      <div style={{ padding: '0 20px' }}>
        {activeTables.length === 0 ? (
          <div style={{ textAlign: 'center', color: '#555', marginTop: '30px', fontSize: '14px' }}>
            No hay mesas creadas aún.
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '15px', marginTop: '10px' }}>
            {activeTables.map((table, index) => (
              <div key={table.id || index} style={{ backgroundColor: '#121212', border: '1px solid #333', borderRadius: '10px', padding: '15px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div>
                  <h4 style={{ margin: 0, color: '#e2b04a', fontSize: '16px' }}>{table.title || 'Mesa sin nombre'}</h4>
                  <p style={{ margin: '5px 0 0 0', color: '#888', fontSize: '12px' }}>{table.type} - {table.mode}</p>
                </div>
                <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
                  {isAdmin && (
                    <>
                      <button onClick={() => onEditTable(table)} style={{ background: '#2a2a2a', color: 'white', border: 'none', padding: '8px 12px', borderRadius: '5px', cursor: 'pointer', fontSize: '14px' }}>✏️</button>
                      <button onClick={() => onDeleteTable(table.id)} style={{ background: '#ef4444', color: 'white', border: 'none', padding: '8px 12px', borderRadius: '5px', cursor: 'pointer', fontSize: '14px' }}>🗑️</button>
                    </>
                  )}
                  <button style={{ background: '#00b86b', color: 'white', border: 'none', padding: '8px 15px', borderRadius: '5px', fontWeight: 'bold', cursor: 'pointer' }}>
                    Jugar
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      <div 
        onClick={() => setShowBottomBar(!showBottomBar)}
        style={{ position: 'fixed', bottom: '20px', right: '20px', width: '55px', height: '55px', backgroundColor: '#00b86b', borderRadius: '50%', display: 'flex', justifyContent: 'center', alignItems: 'center', fontSize: '24px', color: 'white', boxShadow: '0 4px 10px rgba(0,0,0,0.5)', cursor: 'pointer', zIndex: 20 }}
      >
        {showBottomBar ? '✕' : '☰'}
      </div>

      {showBottomBar && (
        <div style={{ position: 'fixed', bottom: '15px', left: '15px', right: '90px', background: '#00b86b', borderRadius: '25px', display: 'flex', justifyContent: 'space-around', padding: '10px 0', alignItems: 'center', boxShadow: '0 4px 15px rgba(0,0,0,0.5)', zIndex: 15 }}>
          <div onClick={() => onOpenTab('bandeja')} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', color: 'white', fontSize: '10px', gap: '4px', cursor: 'pointer' }}><span style={{ fontSize: '18px' }}>📥</span> Bandeja</div>
          <div onClick={() => onOpenTab('miembros')} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', color: 'white', fontSize: '10px', gap: '4px', cursor: 'pointer' }}><span style={{ fontSize: '18px' }}>👥</span> Miembros</div>
          <div onClick={() => onOpenTab('contador')} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', color: 'white', fontSize: '10px', gap: '4px', cursor: 'pointer' }}><span style={{ fontSize: '18px' }}>🌐</span> Contador</div>
          <div onClick={() => onOpenTab('datos')} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', color: 'white', fontSize: '10px', gap: '4px', cursor: 'pointer' }}><span style={{ fontSize: '18px' }}>📊</span> Datos</div>
          {isAdmin && (
            <div onClick={onOpenAdmin} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', color: 'white', fontSize: '10px', gap: '4px', cursor: 'pointer' }}>
              <span style={{ fontSize: '18px' }}>⚙️</span> Admin
            </div>
          )}
        </div>
      )}
    </div>
  );
};

// ==========================================
// 3. SELECCIÓN DE JUEGO
// ==========================================
const SelectGameTypeUI = ({ onBack, onSelectGame, onSelectTemplate, onDeleteTemplate, templates }) => {
  const [activeTab, setActiveTab] = useState('Personalizado');

  return (
    <div style={{ backgroundColor: '#0a0a0a', minHeight: '100vh', padding: '20px', paddingBottom: '80px' }}>
      <div style={{ display: 'flex', alignItems: 'center', marginBottom: '20px' }}>
        <button onClick={onBack} style={{ background: 'none', border: 'none', color: 'white', fontSize: '24px', marginRight: '15px', cursor: 'pointer' }}>‹</button>
        <h2 style={{ margin: 0, fontSize: '18px', color: 'white', flex: 1, textAlign: 'center', paddingRight: '30px' }}>Crear Mesa Nueva</h2>
      </div>

      <div style={{ display: 'flex', borderBottom: '1px solid #222', marginBottom: '20px' }}>
        <div 
          onClick={() => setActiveTab('Personalizado')} 
          style={{ flex: 1, textAlign: 'center', paddingBottom: '10px', color: activeTab === 'Personalizado' ? 'white' : '#888', fontWeight: activeTab === 'Personalizado' ? 'bold' : 'normal', borderBottom: activeTab === 'Personalizado' ? '2px solid #00b86b' : 'none', cursor: 'pointer' }}
        >
          Personalizado
        </div>
        <div 
          onClick={() => setActiveTab('Plantilla')} 
          style={{ flex: 1, textAlign: 'center', paddingBottom: '10px', color: activeTab === 'Plantilla' ? 'white' : '#888', fontWeight: activeTab === 'Plantilla' ? 'bold' : 'normal', borderBottom: activeTab === 'Plantilla' ? '2px solid #00b86b' : 'none', cursor: 'pointer' }}
        >
          Plantilla
        </div>
      </div>

      {activeTab === 'Personalizado' && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
          <div onClick={() => onSelectGame('NLH')} style={{ background: 'linear-gradient(135deg, #007a4d 0%, #00b86b 100%)', borderRadius: '15px', padding: '20px', position: 'relative', overflow: 'hidden', cursor: 'pointer', height: '110px', display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
            <div>
              <h1 style={{ margin: 0, fontSize: '28px', color: 'white', fontWeight: '900', letterSpacing: '1px' }}>NLH</h1>
              <p style={{ margin: '2px 0 0 0', color: 'rgba(255,255,255,0.9)', fontSize: '13px' }}>No Limit Hold'em</p>
            </div>
            <div style={{ width: '25px', height: '25px', borderRadius: '50%', border: '1px solid white', display: 'flex', justifyContent: 'center', alignItems: 'center', color: 'white', fontSize: '16px' }}>›</div>
            <div style={{ position: 'absolute', right: '10px', bottom: '-10px', fontSize: '70px', opacity: 0.9, textShadow: '0 4px 10px rgba(0,0,0,0.3)' }}>🂡🂱</div>
          </div>

          <div onClick={() => onSelectGame('PLO')} style={{ background: 'linear-gradient(135deg, #003a8c 0%, #0066cc 100%)', borderRadius: '15px', padding: '20px', position: 'relative', overflow: 'hidden', cursor: 'pointer', height: '110px', display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
            <div>
              <h1 style={{ margin: 0, fontSize: '28px', color: 'white', fontWeight: '900', letterSpacing: '1px' }}>PLO</h1>
              <p style={{ margin: '2px 0 0 0', color: 'rgba(255,255,255,0.9)', fontSize: '13px' }}>Pot Limit Omaha</p>
            </div>
            <div style={{ width: '25px', height: '25px', borderRadius: '50%', border: '1px solid white', display: 'flex', justifyContent: 'center', alignItems: 'center', color: 'white', fontSize: '16px' }}>›</div>
            <div style={{ position: 'absolute', right: '0px', bottom: '-10px', fontSize: '70px', opacity: 0.9, textShadow: '0 4px 10px rgba(0,0,0,0.3)' }}>🂮🂾🂡🂱</div>
          </div>

          <div onClick={() => onSelectGame('6+')} style={{ background: 'linear-gradient(135deg, #8c1c00 0%, #d93800 100%)', borderRadius: '15px', padding: '20px', position: 'relative', overflow: 'hidden', cursor: 'pointer', height: '110px', display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
            <div>
              <h1 style={{ margin: 0, fontSize: '28px', color: 'white', fontWeight: '900', letterSpacing: '1px' }}>6+</h1>
              <p style={{ margin: '2px 0 0 0', color: 'rgba(255,255,255,0.9)', fontSize: '13px' }}>Short Deck Hold'em</p>
            </div>
            <div style={{ width: '25px', height: '25px', borderRadius: '50%', border: '1px solid white', display: 'flex', justifyContent: 'center', alignItems: 'center', color: 'white', fontSize: '16px' }}>›</div>
            <div style={{ position: 'absolute', right: '15px', bottom: '10px', fontSize: '50px', fontWeight: 'bold', color: '#ffcc00', textShadow: '0 4px 10px rgba(0,0,0,0.5)', transform: 'rotate(10deg)' }}>6+</div>
          </div>
        </div>
      )}

      {activeTab === 'Plantilla' && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
          {templates.length === 0 ? (
            <div style={{ textAlign: 'center', color: '#666', marginTop: '50px' }}>
              <div style={{ fontSize: '3rem', marginBottom: '20px', opacity: 0.5 }}>📄</div>
              <p>No tienes plantillas guardadas aún.</p>
              <p style={{ fontSize: '12px' }}>Crea una mesa personalizada y presiona "Guardar Plantilla" para verla aquí.</p>
            </div>
          ) : (
            templates.map((tpl, index) => (
              <div key={tpl.id || index} style={{ background: '#1e1e1e', padding: '15px', borderRadius: '10px', border: '1px solid #333', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div onClick={() => onSelectTemplate(tpl)} style={{ flex: 1, cursor: 'pointer' }}>
                  <h4 style={{ margin: 0, color: 'white', fontSize: '16px' }}>{tpl.title || 'Plantilla sin nombre'}</h4>
                  <p style={{ margin: '5px 0 0 0', color: '#888', fontSize: '12px' }}>Juego: {tpl.type} | Modo: {tpl.mode}</p>
                </div>
                <button onClick={() => onDeleteTemplate(tpl.id)} style={{ background: 'transparent', border: 'none', color: '#ef4444', fontSize: '18px', cursor: 'pointer', padding: '5px' }}>🗑️</button>
              </div>
            ))
          )}
        </div>
      )}

      <div style={{ position: 'fixed', bottom: '20px', left: '20px', right: '20px' }}>
        <button 
          onClick={() => alert('La gestión recurrente estará disponible próximamente para programar mesas automáticas.')} 
          style={{ width: '100%', padding: '15px', background: '#1a1a1a', color: 'white', border: '1px solid #00b86b', borderRadius: '10px', fontWeight: 'bold', fontSize: '16px', cursor: 'pointer' }}
        >
          Gestión Recurrente
        </button>
      </div>
    </div>
  );
};

// ==========================================
// 4. CREADOR DE MESAS
// ==========================================
const CreateTableUI = ({ gameType, initialData, onBack, onSaveTemplate, onCreateTable }) => {
  const [activeTab, setActiveTab] = useState(initialData?.mode || 'CASH'); 
  const [showAdvanced, setShowAdvanced] = useState(false);
  const [showPolicies, setShowPolicies] = useState(false);

  const [tableData, setTableData] = useState({
    title: initialData?.title || '',
    type: gameType,
    mode: initialData?.mode || 'CASH',
  });

  const [toggles, setToggles] = useState(() => {
    const baseToggles = {
      jackpot: false, straddle: false, runItTwice: false, seguroAllIn: false, cobroEV: false, fijarTop: false, privada: false, recurrente: false,
      vpip: false, callTime: false, madriguera: false, turnoShow: false, authBuyIn: false, bancoTiempo: true,
      premioGarantizado: false, recompensaKO: false, reentradas: false, madrugador: false, acuerdoMesa: false, tiempoDescanso: false, authRegistro: false, restriccionChat: false
    };
    return initialData?.settings ? { ...baseToggles, ...initialData.settings } : baseToggles;
  });

  const toggle = (key) => setToggles(prev => ({ ...prev, [key]: !prev[key] }));

  const handleSave = () => {
    const finalData = { 
        title: tableData.title, 
        type: gameType, 
        mode: activeTab, 
        settings: toggles 
    };
    onSaveTemplate(finalData);
  };

  const handleCreate = () => {
    const finalData = { 
        title: tableData.title, 
        type: gameType, 
        mode: activeTab, 
        settings: toggles 
    };
    onCreateTable(finalData);
  };

  return (
    <div style={{ backgroundColor: '#0a0a0a', minHeight: '100vh', paddingBottom: '80px' }}>
      
      <div style={{ display: 'flex', alignItems: 'center', padding: '15px 20px', borderBottom: '1px solid #222' }}>
        <button onClick={onBack} style={{ background: 'none', border: 'none', color: 'white', fontSize: '24px', marginRight: '15px', cursor: 'pointer' }}>‹</button>
        <h2 style={{ margin: 0, fontSize: '18px', color: 'white', flex: 1, textAlign: 'center', paddingRight: '30px' }}>Crear Mesa Nueva - <span style={{ color: '#00b86b' }}>{gameType}</span></h2>
      </div>

      <div style={{ display: 'flex', borderBottom: '1px solid #333', padding: '0 20px' }}>
        {['CASH', 'SNG', 'MTT'].map(t => (
          <div key={t} onClick={() => {setActiveTab(t); setTableData({...tableData, mode: t})}} style={{ flex: 1, textAlign: 'center', padding: '15px 0', cursor: 'pointer', color: activeTab === t ? 'white' : '#888', borderBottom: activeTab === t ? '2px solid #00b86b' : 'none', fontWeight: 'bold', fontSize: '14px' }}>
            {t === 'CASH' ? 'Partida con dinero real' : t === 'SNG' ? 'SNG' : 'Torneo'}
          </div>
        ))}
      </div>

      <div style={{ padding: '20px' }}>
        
        {activeTab === 'CASH' && (
          <>
            <SectionCard>
              <p style={{ color: '#ccc', fontSize: '14px', margin: '0 0 10px 0' }}>Título</p>
              <input 
                type="text" 
                placeholder="Introducir nombre de mesa" 
                value={tableData.title}
                onChange={(e) => setTableData({...tableData, title: e.target.value})}
                style={{ width: '100%', padding: '12px', background: '#121212', border: '1px solid #333', borderRadius: '8px', color: 'white', boxSizing: 'border-box' }} 
              />
            </SectionCard>

            <SectionCard>
              <p style={{ color: '#ccc', fontSize: '14px', margin: '0 0 10px 0', display: 'flex', alignItems: 'center', gap: '5px' }}>Modo de Juego <span style={{ color: '#00b86b', fontSize: '12px' }}>ⓘ</span></p>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px' }}>
                <button style={{ padding: '12px', background: '#2a2a2a', color: 'white', border: '1px solid #fff', borderRadius: '8px', fontWeight: 'bold' }}>Normal</button>
                <button style={{ padding: '12px', background: '#1a1a1a', color: '#888', border: 'none', borderRadius: '8px' }}>All-In o Fold</button>
                <button style={{ padding: '12px', background: '#1a1a1a', color: '#888', border: 'none', borderRadius: '8px' }}>Bote Bomba</button>
                <button style={{ padding: '12px', background: '#1a1a1a', color: '#888', border: 'none', borderRadius: '8px' }}>Juego del Calamar</button>
                <button style={{ padding: '12px', background: '#1a1a1a', color: '#888', border: 'none', borderRadius: '8px' }}>Cucurucho <span style={{ fontSize: '10px', color: '#00b86b' }}>NEW</span></button>
              </div>
            </SectionCard>

            <SectionCard>
              <p style={{ color: '#ccc', fontSize: '14px', margin: '0 0 10px 0' }}>Tableros</p>
              <p style={{ color: '#666', fontSize: '12px', margin: '0 0 10px 0' }}>Todas las manos</p>
              <SegmentedControl options={['Simple', 'Doble']} selected="Simple" onSelect={() => {}} />
            </SectionCard>

            <SectionCard>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '15px' }}>
                <span style={{ color: '#ccc', fontSize: '14px' }}>Ciegas</span>
                <span style={{ color: '#00b86b', fontSize: '14px', fontWeight: 'bold' }}>0.01 / 0.02</span>
              </div>
              <div style={{ display: 'flex', gap: '10px', marginBottom: '15px' }}>
                {['Micro', 'Bajos', 'Medios', 'Altos'].map((b, i) => (
                  <button key={b} style={{ flex: 1, padding: '10px 0', background: i === 0 ? 'transparent' : '#1a1a1a', border: i === 0 ? '1px solid #fff' : 'none', color: i === 0 ? 'white' : '#888', borderRadius: '8px', fontSize: '13px' }}>{b}</button>
                ))}
              </div>
              <input type="range" style={{ width: '100%', accentColor: '#00b86b' }} />
            </SectionCard>

            <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ color: '#ccc', fontSize: '14px' }}>Ante</span>
              <Stepper value="Ninguno" onIncrease={() => {}} onDecrease={() => {}} />
            </SectionCard>

            <SectionCard>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '15px' }}>
                <span style={{ color: '#ccc', fontSize: '14px' }}>Buy-in</span>
                <span style={{ color: '#00b86b', fontSize: '14px', fontWeight: 'bold' }}>20 BB / 100 BB (0.40 ~ 2)</span>
              </div>
              <input type="range" style={{ width: '100%', accentColor: '#00b86b' }} />
            </SectionCard>

            <SectionCard>
              <p style={{ color: '#ccc', fontSize: '14px', margin: '0 0 10px 0' }}>Comisión (límite)</p>
              <div style={{ display: 'flex', gap: '10px' }}>
                <div style={{ flex: 1 }}>
                  <p style={{ color: '#666', fontSize: '12px', margin: '0 0 5px 0' }}>Cargo</p>
                  <select style={{ width: '100%', padding: '12px', background: '#2a2a2a', border: 'none', color: 'white', borderRadius: '8px' }}><option>3%</option></select>
                </div>
                <div style={{ flex: 1 }}>
                  <p style={{ color: '#666', fontSize: '12px', margin: '0 0 5px 0' }}>Límite</p>
                  <select style={{ width: '100%', padding: '12px', background: '#2a2a2a', border: 'none', color: 'white', borderRadius: '8px' }}><option>Sin límite</option></select>
                </div>
              </div>
            </SectionCard>

            <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ color: '#ccc', fontSize: '14px' }}>Tamaño de la mesa</span>
              <Stepper value="6 Mesas máx." onIncrease={() => {}} onDecrease={() => {}} />
            </SectionCard>

            <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ color: '#ccc', fontSize: '14px' }}>Inicio automático</span>
              <Stepper value="2 Jugadores" onIncrease={() => {}} onDecrease={() => {}} />
            </SectionCard>

            <SectionCard>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '15px' }}>
                <span style={{ color: '#ccc', fontSize: '14px' }}>Duración De La Partida</span>
                <span style={{ color: '#00b86b', fontSize: '14px', fontWeight: 'bold' }}>12 hora(s)</span>
              </div>
              <input type="range" style={{ width: '100%', accentColor: '#00b86b' }} />
            </SectionCard>

            <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ color: '#ccc', fontSize: '14px' }}>Extensión automática</span>
              <Stepper value="No" onIncrease={() => {}} onDecrease={() => {}} />
            </SectionCard>

            <SectionCard>
              <p style={{ color: '#ccc', fontSize: '14px', margin: '0 0 10px 0' }}>Tiempo de acción</p>
              <SegmentedControl options={['13 Seg', '15 Seg', '18 Seg', '20 Seg', '25 Seg']} selected="15 Seg" onSelect={() => {}} />
            </SectionCard>

            <SectionCard>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
                <span style={{ color: '#ccc', fontSize: '14px' }}>Banco de tiempo</span>
                <ToggleSwitch active={toggles.bancoTiempo} onChange={() => toggle('bancoTiempo')} />
              </div>
              <p style={{ color: '#666', fontSize: '12px', margin: '0 0 5px 0' }}>Iniciar Banco de tiempo</p>
              <select style={{ width: '100%', padding: '12px', background: '#2a2a2a', border: 'none', color: 'white', borderRadius: '8px', marginBottom: '15px' }}><option>30 Seg</option></select>
              
              <p style={{ color: '#666', fontSize: '12px', margin: '0 0 5px 0' }}>Banco de tiempo adicional tras</p>
              <div style={{ display: 'flex', gap: '10px' }}>
                <select style={{ flex: 1, padding: '12px', background: '#2a2a2a', border: 'none', color: 'white', borderRadius: '8px' }}><option>30 manos</option></select>
                <select style={{ flex: 1, padding: '12px', background: '#2a2a2a', border: 'none', color: 'white', borderRadius: '8px' }}><option>30 Seg</option></select>
              </div>
            </SectionCard>

            <div style={{ borderTop: '1px solid #333', paddingTop: '15px', marginTop: '10px' }}>
              <div onClick={() => setShowAdvanced(!showAdvanced)} style={{ display: 'flex', alignItems: 'center', gap: '10px', cursor: 'pointer', marginBottom: '15px' }}>
                <span style={{ color: 'white' }}>{showAdvanced ? '⌄' : '›'}</span>
                <span style={{ color: 'white', fontWeight: 'bold' }}>Opciones Avanzadas</span>
              </div>
              {showAdvanced && (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Jackpot Bad Beat <span style={{ color: '#3498db' }}>ⓘ</span></span> <ToggleSwitch active={toggles.jackpot} onChange={() => toggle('jackpot')} /></SectionCard>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Straddle <span style={{ color: '#3498db' }}>ⓘ</span></span> <ToggleSwitch active={toggles.straddle} onChange={() => toggle('straddle')} /></SectionCard>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Run it Multi Time</span> <ToggleSwitch active={toggles.runItTwice} onChange={() => toggle('runItTwice')} /></SectionCard>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Seguro All-In</span> <ToggleSwitch active={toggles.seguroAllIn} onChange={() => toggle('seguroAllIn')} /></SectionCard>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Cobro EV <span style={{ color: '#3498db' }}>ⓘ</span></span> <ToggleSwitch active={toggles.cobroEV} onChange={() => toggle('cobroEV')} /></SectionCard>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Fijar en la parte superior</span> <ToggleSwitch active={toggles.fijarTop} onChange={() => toggle('fijarTop')} /></SectionCard>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Partida privada</span> <ToggleSwitch active={toggles.privada} onChange={() => toggle('privada')} /></SectionCard>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Tabla recurrente <span style={{ color: '#3498db' }}>ⓘ</span></span> <ToggleSwitch active={toggles.recurrente} onChange={() => toggle('recurrente')} /></SectionCard>
                </div>
              )}
            </div>

            <div style={{ borderTop: '1px solid #333', paddingTop: '15px', marginTop: '10px', marginBottom: '20px' }}>
              <div onClick={() => setShowPolicies(!showPolicies)} style={{ display: 'flex', alignItems: 'center', gap: '10px', cursor: 'pointer', marginBottom: '15px' }}>
                <span style={{ color: 'white' }}>{showPolicies ? '⌄' : '›'}</span>
                <span style={{ color: 'white', fontWeight: 'bold' }}>Políticas de Mesa</span>
              </div>
              {showPolicies && (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>VPIP obligatorio</span> <ToggleSwitch active={toggles.vpip} onChange={() => toggle('vpip')} /></SectionCard>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>CallTime <span style={{ color: '#3498db' }}>ⓘ</span></span> <ToggleSwitch active={toggles.callTime} onChange={() => toggle('callTime')} /></SectionCard>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Sin madriguera <span style={{ color: '#3498db' }}>ⓘ</span></span> <ToggleSwitch active={toggles.madriguera} onChange={() => toggle('madriguera')} /></SectionCard>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Sin Turno Sin Show <span style={{ color: '#3498db' }}>ⓘ</span></span> <ToggleSwitch active={toggles.turnoShow} onChange={() => toggle('turnoShow')} /></SectionCard>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Autorización de buy-in</span> <ToggleSwitch active={toggles.authBuyIn} onChange={() => toggle('authBuyIn')} /></SectionCard>
                  
                  <SectionCard>
                    <p style={{ color: '#ccc', fontSize: '14px', margin: '0 0 10px 0' }}>Restricción de la partida</p>
                    <div style={{ display: 'flex', gap: '10px' }}>
                      {['IP', 'GPS', 'Dispositivo', 'Chateando'].map(r => (
                        <button key={r} style={{ flex: 1, padding: '10px 0', background: '#2a2a2a', color: '#888', border: 'none', borderRadius: '8px', fontSize: '12px' }}>{r}</button>
                      ))}
                    </div>
                  </SectionCard>
                </div>
              )}
            </div>
          </>
        )}

        {activeTab === 'SNG' && (
          <>
            <SectionCard>
              <p style={{ color: '#ccc', fontSize: '14px', margin: '0 0 10px 0' }}>Título</p>
              <input 
                type="text" 
                placeholder="Introducir nombre de mesa" 
                value={tableData.title}
                onChange={(e) => setTableData({...tableData, title: e.target.value})}
                style={{ width: '100%', padding: '12px', background: '#121212', border: '1px solid #333', borderRadius: '8px', color: 'white', boxSizing: 'border-box' }} 
              />
            </SectionCard>

            <SectionCard>
              <p style={{ color: '#ccc', fontSize: '14px', margin: '0 0 10px 0', display: 'flex', alignItems: 'center', gap: '5px' }}>Modo de Juego <span style={{ color: '#00b86b', fontSize: '12px' }}>ⓘ</span></p>
              <SegmentedControl options={['Normal', 'Spin & Gold', 'Satélite']} selected="Normal" onSelect={() => {}} />
            </SectionCard>

            <SectionCard>
              <p style={{ color: '#ccc', fontSize: '14px', margin: '0 0 10px 0' }}>Total Buy-in</p>
              <div style={{ background: '#121212', padding: '15px', borderRadius: '8px', textAlign: 'right', fontSize: '18px', color: 'white', marginBottom: '10px' }}>100</div>
              <p style={{ color: '#666', fontSize: '12px', margin: '0 0 10px 0' }}>(Premio + tarifa)</p>
              <div style={{ display: 'flex', gap: '10px' }}>
                <div style={{ flex: 1, background: '#2a2a2a', padding: '15px', borderRadius: '8px', color: '#aaa', display: 'flex', justifyContent: 'flex-end' }}><span style={{ color: '#e2b04a' }}>90</span></div>
                <div style={{ display: 'flex', alignItems: 'center', color: '#666' }}>+</div>
                <div style={{ flex: 1, background: '#2a2a2a', padding: '15px', borderRadius: '8px', color: '#aaa', display: 'flex', justifyContent: 'flex-end' }}><span style={{ color: 'white' }}>10</span></div>
              </div>
            </SectionCard>

            <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ color: '#ccc', fontSize: '14px' }}>Tamaño de la mesa</span>
              <Stepper value="9 Mesas máx." onIncrease={() => {}} onDecrease={() => {}} />
            </SectionCard>

            <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ color: '#ccc', fontSize: '14px' }}>Número de mesas</span>
              <Stepper value="1 Mesa" onIncrease={() => {}} onDecrease={() => {}} />
            </SectionCard>

            <SectionCard>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '15px' }}>
                <span style={{ color: '#ccc', fontSize: '14px' }}>Fichas iniciales</span>
                <span style={{ color: '#00b86b', fontSize: '14px', fontWeight: 'bold' }}>1,000</span>
              </div>
              <input type="range" style={{ width: '100%', accentColor: '#00b86b' }} />
            </SectionCard>

            <SectionCard>
              <p style={{ color: '#ccc', fontSize: '14px', margin: '0 0 10px 0', display: 'flex', alignItems: 'center', gap: '5px' }}>Estructura de ciegas <span style={{ color: '#00b86b', fontSize: '12px' }}>ⓘ</span></p>
              <SegmentedControl options={['Lento', 'Estándar', 'Turbo', 'Hyper Turbo']} selected="Estándar" onSelect={() => {}} />
            </SectionCard>

            <SectionCard>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '15px' }}>
                <span style={{ color: '#ccc', fontSize: '14px' }}>Ciega de subida de nivel</span>
                <span style={{ color: '#00b86b', fontSize: '14px', fontWeight: 'bold' }}>10 Min</span>
              </div>
              <input type="range" style={{ width: '100%', accentColor: '#00b86b' }} />
            </SectionCard>

            <SectionCard>
              <p style={{ color: '#ccc', fontSize: '14px', margin: '0 0 10px 0', display: 'flex', alignItems: 'center', gap: '5px' }}>Estructura de pagos <span style={{ color: '#00b86b', fontSize: '12px' }}>ⓘ</span></p>
              <SegmentedControl options={['Tipo 1', 'Tipo 2', 'Tipo 3', 'Tipo 4']} selected="Tipo 1" onSelect={() => {}} />
            </SectionCard>

            <SectionCard>
              <p style={{ color: '#ccc', fontSize: '14px', margin: '0 0 10px 0' }}>Tiempo de acción</p>
              <SegmentedControl options={['13 Seg', '15 Seg', '18 Seg', '20 Seg', '25 Seg']} selected="15 Seg" onSelect={() => {}} />
            </SectionCard>

            <SectionCard>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
                <span style={{ color: '#ccc', fontSize: '14px' }}>Banco de tiempo</span>
                <ToggleSwitch active={toggles.bancoTiempo} onChange={() => toggle('bancoTiempo')} />
              </div>
              <p style={{ color: '#666', fontSize: '12px', margin: '0 0 5px 0' }}>Iniciar Banco de tiempo</p>
              <select style={{ width: '100%', padding: '12px', background: '#2a2a2a', border: 'none', color: 'white', borderRadius: '8px', marginBottom: '15px' }}><option>30 Seg</option></select>
              
              <p style={{ color: '#666', fontSize: '12px', margin: '0 0 5px 0' }}>Banco de tiempo adicional tras</p>
              <div style={{ display: 'flex', gap: '10px' }}>
                <select style={{ flex: 1, padding: '12px', background: '#2a2a2a', border: 'none', color: 'white', borderRadius: '8px' }}><option>30 manos</option></select>
                <select style={{ flex: 1, padding: '12px', background: '#2a2a2a', border: 'none', color: 'white', borderRadius: '8px' }}><option>30 Seg</option></select>
              </div>
            </SectionCard>

            <div style={{ borderTop: '1px solid #333', paddingTop: '15px', marginTop: '10px', marginBottom: '20px' }}>
              <div onClick={() => setShowAdvanced(!showAdvanced)} style={{ display: 'flex', alignItems: 'center', gap: '10px', cursor: 'pointer', marginBottom: '15px' }}>
                <span style={{ color: 'white' }}>{showAdvanced ? '⌄' : '›'}</span>
                <span style={{ color: 'white', fontWeight: 'bold' }}>Opciones Avanzadas</span>
              </div>
              {showAdvanced && (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Fijar en la parte superior</span> <ToggleSwitch active={toggles.fijarTop} onChange={() => toggle('fijarTop')} /></SectionCard>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Descripción</span> <ToggleSwitch active={toggles.privada} onChange={() => toggle('privada')} /></SectionCard>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Partida privada</span> <ToggleSwitch active={toggles.privada} onChange={() => toggle('privada')} /></SectionCard>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Tabla recurrente <span style={{ color: '#3498db' }}>ⓘ</span></span> <ToggleSwitch active={toggles.recurrente} onChange={() => toggle('recurrente')} /></SectionCard>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Autorización del registro</span> <ToggleSwitch active={toggles.authRegistro} onChange={() => toggle('authRegistro')} /></SectionCard>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Restricción de chat</span> <ToggleSwitch active={toggles.restriccionChat} onChange={() => toggle('restriccionChat')} /></SectionCard>
                </div>
              )}
            </div>
          </>
        )}

        {activeTab === 'MTT' && (
          <>
            <SectionCard>
              <p style={{ color: '#ccc', fontSize: '14px', margin: '0 0 10px 0' }}>Título</p>
              <input 
                type="text" 
                placeholder="Introducir nombre de mesa" 
                value={tableData.title}
                onChange={(e) => setTableData({...tableData, title: e.target.value})}
                style={{ width: '100%', padding: '12px', background: '#121212', border: '1px solid #333', borderRadius: '8px', color: 'white', boxSizing: 'border-box' }} 
              />
            </SectionCard>

            <SectionCard>
              <p style={{ color: '#ccc', fontSize: '14px', margin: '0 0 10px 0', display: 'flex', alignItems: 'center', gap: '5px' }}>Modo de Juego <span style={{ color: '#00b86b', fontSize: '12px' }}>ⓘ</span></p>
              <SegmentedControl options={['Normal', 'Satélite', 'Multidía']} selected="Normal" onSelect={() => {}} />
            </SectionCard>

            <SectionCard>
              <p style={{ color: '#ccc', fontSize: '14px', margin: '0 0 10px 0' }}>Total Buy-in</p>
              <div style={{ background: '#121212', padding: '15px', borderRadius: '8px', textAlign: 'right', fontSize: '18px', color: 'white', marginBottom: '10px' }}>100</div>
              <p style={{ color: '#666', fontSize: '12px', margin: '0 0 10px 0' }}>(Premio + tarifa)</p>
              <div style={{ display: 'flex', gap: '10px' }}>
                <div style={{ flex: 1, background: '#2a2a2a', padding: '15px', borderRadius: '8px', color: '#aaa', display: 'flex', justifyContent: 'flex-end' }}><span style={{ color: '#e2b04a' }}>90</span></div>
                <div style={{ display: 'flex', alignItems: 'center', color: '#666' }}>+</div>
                <div style={{ flex: 1, background: '#2a2a2a', padding: '15px', borderRadius: '8px', color: '#aaa', display: 'flex', justifyContent: 'flex-end' }}><span style={{ color: 'white' }}>10</span></div>
              </div>
            </SectionCard>

            <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ color: '#ccc', fontSize: '14px' }}>Tamaño de la mesa</span>
              <Stepper value="9 Mesas máx." onIncrease={() => {}} onDecrease={() => {}} />
            </SectionCard>

            <SectionCard>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '15px' }}>
                <span style={{ color: '#ccc', fontSize: '14px' }}>Jugadores mín. ~ máx.</span>
                <span style={{ color: '#00b86b', fontSize: '14px', fontWeight: 'bold' }}>5 ~ 1,000</span>
              </div>
              <input type="range" style={{ width: '100%', accentColor: '#00b86b' }} />
            </SectionCard>

            <SectionCard>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '15px' }}>
                <span style={{ color: '#ccc', fontSize: '14px' }}>Fichas iniciales</span>
                <span style={{ color: '#00b86b', fontSize: '14px', fontWeight: 'bold' }}>1,000</span>
              </div>
              <input type="range" style={{ width: '100%', accentColor: '#00b86b' }} />
            </SectionCard>

            <SectionCard>
              <p style={{ color: '#ccc', fontSize: '14px', margin: '0 0 10px 0', display: 'flex', alignItems: 'center', gap: '5px' }}>Estructura de ciegas <span style={{ color: '#00b86b', fontSize: '12px' }}>ⓘ</span></p>
              <SegmentedControl options={['Lento', 'Estándar', 'Turbo', 'Hyper Turbo']} selected="Estándar" onSelect={() => {}} />
            </SectionCard>

            <SectionCard>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '15px' }}>
                <span style={{ color: '#ccc', fontSize: '14px' }}>Ciega de subida de nivel</span>
                <span style={{ color: '#00b86b', fontSize: '14px', fontWeight: 'bold' }}>10 Min</span>
              </div>
              <input type="range" style={{ width: '100%', accentColor: '#00b86b' }} />
            </SectionCard>

            <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ color: '#ccc', fontSize: '14px' }}>Premio garantizado</span>
              <ToggleSwitch active={toggles.premioGarantizado} onChange={() => toggle('premioGarantizado')} />
            </SectionCard>

            <SectionCard>
              <p style={{ color: '#ccc', fontSize: '14px', margin: '0 0 10px 0', display: 'flex', alignItems: 'center', gap: '5px' }}>Estructura de pagos <span style={{ color: '#00b86b', fontSize: '12px' }}>ⓘ</span></p>
              <SegmentedControl options={['10%', '12%', '15%', '20%']} selected="15%" onSelect={() => {}} />
            </SectionCard>

            <SectionCard>
              <p style={{ color: '#666', fontSize: '12px', margin: '0 0 5px 0' }}>Hora de inicio</p>
              <select style={{ width: '100%', padding: '12px', background: '#2a2a2a', border: 'none', color: 'white', borderRadius: '8px', marginBottom: '15px' }}><option>Seleccionar hora</option></select>
              
              <p style={{ color: '#666', fontSize: '12px', margin: '0 0 5px 0' }}>Plazo de apertura del registro</p>
              <select style={{ width: '100%', padding: '12px', background: '#2a2a2a', border: 'none', color: 'white', borderRadius: '8px' }}><option>Seleccionar hora</option></select>
            </SectionCard>

            <SectionCard>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '15px' }}>
                <span style={{ color: '#ccc', fontSize: '14px' }}>Registro tardío</span>
                <span style={{ color: '#00b86b', fontSize: '14px', fontWeight: 'bold' }}>No</span>
              </div>
              <input type="range" style={{ width: '100%', accentColor: '#00b86b' }} />
            </SectionCard>

            <SectionCard>
              <p style={{ color: '#ccc', fontSize: '14px', margin: '0 0 10px 0' }}>Tiempo de acción</p>
              <SegmentedControl options={['13 Seg', '15 Seg', '18 Seg', '20 Seg', '25 Seg']} selected="15 Seg" onSelect={() => {}} />
            </SectionCard>

            <SectionCard>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
                <span style={{ color: '#ccc', fontSize: '14px' }}>Banco de tiempo</span>
                <ToggleSwitch active={toggles.bancoTiempo} onChange={() => toggle('bancoTiempo')} />
              </div>
              <p style={{ color: '#666', fontSize: '12px', margin: '0 0 5px 0' }}>Iniciar Banco de tiempo</p>
              <select style={{ width: '100%', padding: '12px', background: '#2a2a2a', border: 'none', color: 'white', borderRadius: '8px', marginBottom: '15px' }}><option>30 Seg</option></select>
              
              <p style={{ color: '#666', fontSize: '12px', margin: '0 0 5px 0' }}>Banco de tiempo adicional tras</p>
              <div style={{ display: 'flex', gap: '10px' }}>
                <select style={{ flex: 1, padding: '12px', background: '#2a2a2a', border: 'none', color: 'white', borderRadius: '8px' }}><option>30 manos</option></select>
                <select style={{ flex: 1, padding: '12px', background: '#2a2a2a', border: 'none', color: 'white', borderRadius: '8px' }}><option>30 Seg</option></select>
              </div>
            </SectionCard>

            <div style={{ borderTop: '1px solid #333', paddingTop: '15px', marginTop: '10px', marginBottom: '20px' }}>
              <div onClick={() => setShowAdvanced(!showAdvanced)} style={{ display: 'flex', alignItems: 'center', gap: '10px', cursor: 'pointer', marginBottom: '15px' }}>
                <span style={{ color: 'white' }}>{showAdvanced ? '⌄' : '›'}</span>
                <span style={{ color: 'white', fontWeight: 'bold' }}>Opciones Avanzadas</span>
              </div>
              {showAdvanced && (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Recompensa KO <span style={{ color: '#3498db' }}>ⓘ</span></span> <ToggleSwitch active={toggles.recompensaKO} onChange={() => toggle('recompensaKO')} /></SectionCard>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Reentradas</span> <ToggleSwitch active={toggles.reentradas} onChange={() => toggle('reentradas')} /></SectionCard>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Madrugador <span style={{ color: '#3498db' }}>ⓘ</span></span> <ToggleSwitch active={toggles.madrugador} onChange={() => toggle('madrugador')} /></SectionCard>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Acuerdo de Mesa Final <span style={{ color: '#3498db' }}>ⓘ</span></span> <ToggleSwitch active={toggles.acuerdoMesa} onChange={() => toggle('acuerdoMesa')} /></SectionCard>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Tiempo de descanso (5 min cada 55 min)</span> <ToggleSwitch active={toggles.tiempoDescanso} onChange={() => toggle('tiempoDescanso')} /></SectionCard>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Fijar en la parte superior</span> <ToggleSwitch active={toggles.fijarTop} onChange={() => toggle('fijarTop')} /></SectionCard>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Descripción</span> <ToggleSwitch active={toggles.privada} onChange={() => toggle('privada')} /></SectionCard>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Partida privada</span> <ToggleSwitch active={toggles.privada} onChange={() => toggle('privada')} /></SectionCard>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Tabla recurrente <span style={{ color: '#3498db' }}>ⓘ</span></span> <ToggleSwitch active={toggles.recurrente} onChange={() => toggle('recurrente')} /></SectionCard>
                  <SectionCard style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px' }}><span style={{ color: '#ccc', fontSize: '14px' }}>Autorización del registro</span> <ToggleSwitch active={toggles.authRegistro} onChange={() => toggle('authRegistro')} /></SectionCard>
                </div>
              )}
            </div>
          </>
        )}

      </div>

      <div style={{ position: 'fixed', bottom: 0, left: 0, width: '100%', padding: '15px', background: '#0a0a0a', borderTop: '1px solid #333', display: 'flex', gap: '10px', boxSizing: 'border-box', zIndex: 20 }}>
        <button onClick={handleSave} style={{ flex: 1, padding: '15px', background: 'transparent', color: '#00b86b', border: '2px solid #00b86b', borderRadius: '8px', fontWeight: 'bold', fontSize: '16px', cursor: 'pointer' }}>Guardar Plantilla</button>
        <button onClick={handleCreate} style={{ flex: 1, padding: '15px', background: '#00b86b', color: 'white', border: 'none', borderRadius: '8px', fontWeight: 'bold', fontSize: '16px', cursor: 'pointer' }}>Crear</button>
      </div>
    </div>
  );
};

// ==========================================
// 5. PANEL DEL ADMINISTRADOR
// ==========================================
const ClubAdminPanel = ({ onBack, onCreateTable }) => (
  <div style={{ padding: '20px', paddingBottom: '80px', backgroundColor: '#0a0a0a', minHeight: '100vh' }}>
    <div style={{ display: 'flex', alignItems: 'center', marginBottom: '20px' }}>
      <button onClick={onBack} style={{ background: 'none', border: 'none', color: 'white', fontSize: '20px', marginRight: '15px', cursor: 'pointer' }}>←</button>
      <h2 style={{ margin: 0, fontSize: '18px', color: 'white' }}>Administración</h2>
    </div>

    <div style={{ display: 'flex', gap: '15px', marginBottom: '20px' }}>
      <div style={{ flex: 1, background: '#1e1e1e', padding: '15px', borderRadius: '10px', borderLeft: '4px solid #00b86b' }}>
        <p style={{ color: '#a0aec0', fontSize: '12px', margin: 0 }}>Rake Acumulado (24h)</p>
        <h3 style={{ color: '#00b86b', margin: '5px 0' }}>0 NTX</h3>
        <p style={{ color: '#888', fontSize: '11px', margin: 0 }}>Tu 40%: 0 NTX</p>
      </div>
      <div style={{ flex: 1, background: '#1e1e1e', padding: '15px', borderRadius: '10px', borderLeft: '4px solid #e2b04a' }}>
        <p style={{ color: '#a0aec0', fontSize: '12px', margin: 0 }}>Miembros</p>
        <h3 style={{ color: 'white', margin: '5px 0' }}>1 / 10</h3>
        <button style={{ background: 'transparent', border: '1px solid #e2b04a', color: '#e2b04a', fontSize: '10px', padding: '3px 8px', borderRadius: '4px', cursor: 'pointer' }}>Ampliar (+10)</button>
      </div>
    </div>

    <button onClick={onCreateTable} style={{ width: '100%', padding: '15px', background: '#00b86b', color: 'white', border: 'none', borderRadius: '10px', fontWeight: 'bold', fontSize: '16px', cursor: 'pointer', marginBottom: '20px' }}>
      + Crear Nueva Mesa / Torneo
    </button>

    <h3 style={{ color: 'white', marginBottom: '15px' }}>Gestión de Jugadores</h3>
    <div style={{ background: '#121212', borderRadius: '10px', padding: '10px' }}>
      <p style={{ color: '#888', textAlign: 'center', padding: '20px' }}>Aún no hay otros jugadores en tu club.</p>
    </div>
  </div>
);

// ==========================================
// COMPONENTE PRINCIPAL
// ==========================================
const Club = ({ user, onBack }) => {
  const [view, setView] = useState('loading'); 
  const [clubData, setClubData] = useState(null);
  const [isAdmin, setIsAdmin] = useState(false);
  const [selectedGameType, setSelectedGameType] = useState('NLH');
  const [templateToLoad, setTemplateToLoad] = useState(null);

  const [savedTemplates, setSavedTemplates] = useState([]);
  const [activeTables, setActiveTables] = useState([]);

  const fetchTemplates = async () => {
    try {
      const token = localStorage.getItem('token');
      // 🔥 USAMOS API_URL DINÁMICA
      const res = await fetch(`${API_URL}/api/clubs/templates`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.ok) {
        const data = await res.json();
        setSavedTemplates(data);
      }
    } catch (error) { console.error("Error cargando plantillas"); }
  };

  const fetchTables = async () => {
    try {
      const token = localStorage.getItem('token');
      // 🔥 USAMOS API_URL DINÁMICA
      const res = await fetch(`${API_URL}/api/clubs/tables`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.ok) {
        const data = await res.json();
        setActiveTables(data);
      }
    } catch (error) { console.error("Error cargando mesas"); }
  };

  useEffect(() => {
    const checkMyClub = async () => {
      try {
        const token = localStorage.getItem('token');
        // 🔥 USAMOS API_URL DINÁMICA
        const res = await fetch(`${API_URL}/api/clubs/my-club`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        
        if (res.ok) {
          const data = await res.json();
          setClubData(data.club);
          setIsAdmin(data.role === 'owner');
          setView('lobby');
          fetchTemplates();
          fetchTables();
        } else {
          setView('gateway'); 
        }
      } catch (error) {
        setView('gateway');
      }
    };
    checkMyClub();
  }, []);

  const handleCreateClub = async (name) => {
    try {
      const token = localStorage.getItem('token');
      // 🔥 USAMOS API_URL DINÁMICA
      const res = await fetch(`${API_URL}/api/clubs/create`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
        body: JSON.stringify({ name })
      });
      const contentType = res.headers.get("content-type");
      if (!contentType || !contentType.includes("application/json")) {
        throw new Error("Error del servidor. Revisa que el backend esté encendido.");
      }
      const data = await res.json();
      if (!res.ok) throw new Error(data.error);

      setClubData(data.club);
      setIsAdmin(true);
      setView('lobby');
      fetchTemplates();
      fetchTables();
    } catch (error) {
      alert(error.message);
    }
  };

  const handleJoinClub = async (code) => {
    try {
      const token = localStorage.getItem('token');
      // 🔥 USAMOS API_URL DINÁMICA
      const res = await fetch(`${API_URL}/api/clubs/join`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
        body: JSON.stringify({ code })
      });
      const contentType = res.headers.get("content-type");
      if (!contentType || !contentType.includes("application/json")) {
        throw new Error("Error del servidor. Revisa que el backend esté encendido.");
      }
      const data = await res.json();
      if (!res.ok) throw new Error(data.error);

      setClubData(data.club);
      setIsAdmin(false);
      setView('lobby');
      fetchTemplates();
      fetchTables();
    } catch (error) {
      alert(error.message);
    }
  };

  const handleUpdateClubState = (newData) => {
    setClubData({ ...clubData, ...newData });
  };

  const handleGameSelection = (type) => {
    setSelectedGameType(type);
    setTemplateToLoad(null);
    setView('create_table');
  };

  const handleLoadTemplate = (template) => {
    setSelectedGameType(template.type);
    const formattedTemplate = {
        ...template,
        settings: typeof template.settings === 'string' ? JSON.parse(template.settings) : template.settings
    };
    setTemplateToLoad(formattedTemplate);
    setView('create_table');
  };

  const handleDeleteTemplate = async (templateId) => {
    if(window.confirm('¿Estás seguro de que quieres eliminar esta plantilla?')) {
      try {
        const token = localStorage.getItem('token');
        // 🔥 USAMOS API_URL DINÁMICA
        const res = await fetch(`${API_URL}/api/clubs/templates/${templateId}`, {
          method: 'DELETE',
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (res.ok) {
          fetchTemplates();
        } else {
            alert('Error al eliminar la plantilla');
        }
      } catch (error) {
        alert('Error de conexión');
      }
    }
  };

  const handleDeleteTable = async (tableId) => {
    if(window.confirm('¿Estás seguro de que quieres eliminar esta mesa? Los jugadores ya no podrán unirse.')) {
      try {
        const token = localStorage.getItem('token');
        // 🔥 USAMOS API_URL DINÁMICA
        const res = await fetch(`${API_URL}/api/clubs/tables/${tableId}`, {
          method: 'DELETE',
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (res.ok) {
          fetchTables();
        } else {
            alert('Error al eliminar la mesa');
        }
      } catch (error) {
        alert('Error de conexión');
      }
    }
  };

  const handleEditTable = async (table) => {
    const confirmEdit = window.confirm('Se editará la mesa. La mesa actual se eliminará y tendrás que volver a crearla al finalizar. ¿Continuar?');
    if(confirmEdit) {
      try {
        const token = localStorage.getItem('token');
        // 🔥 USAMOS API_URL DINÁMICA
        await fetch(`${API_URL}/api/clubs/tables/${table.id}`, {
          method: 'DELETE',
          headers: { 'Authorization': `Bearer ${token}` }
        });
      } catch (error) {}
      
      const formattedTable = {
        ...table,
        settings: typeof table.settings === 'string' ? JSON.parse(table.settings) : table.settings
      };
      setSelectedGameType(table.type);
      setTemplateToLoad(formattedTable);
      setView('create_table');
    }
  };

  const handleSaveTemplate = async (data) => {
    try {
        const token = localStorage.getItem('token');
        // 🔥 USAMOS API_URL DINÁMICA
        const res = await fetch(`${API_URL}/api/clubs/save-template`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
            body: JSON.stringify(data)
        });
        if (res.ok) {
            alert('¡Plantilla guardada con éxito!');
            fetchTemplates();
            setView('select_game');
        } else {
            alert('Error al guardar la plantilla');
        }
    } catch (error) {
        alert('Error de conexión');
    }
  };

  const handleCreateTable = async (data) => {
    try {
        const token = localStorage.getItem('token');
        // 🔥 USAMOS API_URL DINÁMICA
        const res = await fetch(`${API_URL}/api/clubs/tables`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
            body: JSON.stringify(data)
        });
        if (res.ok) {
            alert('¡Mesa creada y publicada en el lobby!');
            fetchTables();
            setView('lobby');
        } else {
            alert('Error al crear la mesa');
        }
    } catch (error) {
        alert('Error de conexión');
    }
  };

  if (view === 'loading') {
    return <div style={{ backgroundColor: '#0a0a0a', minHeight: '100vh', display: 'flex', justifyContent: 'center', alignItems: 'center', color: '#00b86b' }}>Cargando club...</div>;
  }

  return (
    <div style={{ backgroundColor: '#0a0a0a', minHeight: '100vh', color: 'white' }}>
      {view === 'gateway' && <ClubGateway onBack={onBack} onCreateClub={handleCreateClub} onJoinClub={handleJoinClub} />}
      
      {view === 'lobby' && clubData && (
        <ClubLobby 
          club={clubData} 
          isAdmin={isAdmin} 
          onBack={onBack} 
          onCreateTable={() => setView('select_game')} 
          onOpenAdmin={() => setView('admin')}
          onUpdateClub={handleUpdateClubState}
          activeTables={activeTables}
          onDeleteTable={handleDeleteTable}
          onEditTable={handleEditTable}
          onOpenTab={(tab) => setView(tab)} 
        />
      )}

      {view === 'select_game' && (
        <SelectGameTypeUI 
          onBack={() => setView('lobby')} 
          onSelectGame={handleGameSelection}
          onSelectTemplate={handleLoadTemplate}
          onDeleteTemplate={handleDeleteTemplate}
          templates={savedTemplates}
        />
      )}

      {view === 'create_table' && (
        <CreateTableUI 
          gameType={selectedGameType}
          initialData={templateToLoad} 
          onBack={() => setView('select_game')} 
          onSaveTemplate={handleSaveTemplate} 
          onCreateTable={handleCreateTable}
        />
      )}

      {view === 'admin' && clubData && (
        <ClubAdminPanel onBack={() => setView('lobby')} onCreateTable={() => setView('select_game')} />
      )}

      {view === 'bandeja' && <ClubBandeja onBack={() => setView('lobby')} />}
      {view === 'miembros' && <ClubMiembros isAdmin={isAdmin} onBack={() => setView('lobby')} />}
      {view === 'contador' && <ClubContador onBack={() => setView('lobby')} />}
      {view === 'datos' && <ClubDatos onBack={() => setView('lobby')} />}
    </div>
  );
};

export default Club;