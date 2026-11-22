import { useState, useEffect } from 'react';
import { API_URL } from './config';

const UserIcon = () => (
  <svg viewBox="0 0 24 24" width="40" height="40" fill="#00e676">
    <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
  </svg>
);

const EmptyChart = () => (
  <div style={{ height: '150px', display: 'flex', flexDirection: 'column', justifyContent: 'flex-end', padding: '10px' }}>
    <div style={{ borderBottom: '1px solid #4a5568', borderLeft: '1px solid #4a5568', height: '100%', position: 'relative', display: 'flex', alignItems: 'flex-end' }}>
      <div style={{ width: '100%', height: '1px', background: '#00e676', position: 'absolute', bottom: 0 }}></div>
    </div>
    <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '5px', color: '#718096', fontSize: '0.7rem' }}>
      <span>11-03</span><span>11-04</span><span>11-05</span><span>11-06</span><span>11-07</span><span>11-08</span><span>11-09</span>
    </div>
  </div>
);

export default function InviteFriends({ user, referralStats }) {
  const [activeTab, setActiveTab] = useState('inicio');
  const [copied, setCopied] = useState(false);

  // 🔥 ESTADOS PARA LAS GANANCIAS REALES DEL RAKE 🔥
  const [earningsData, setEarningsData] = useState({ total_pending: 0, details: [] });
  const [loadingEarnings, setLoadingEarnings] = useState(true);
  const [claiming, setClaiming] = useState(false);

  // 🔥 ESTADO PARA EL LÍMITE DE 24 HORAS 🔥
  // Asumimos que el backend puede enviar "next_claim_time" (timestamp de cuándo puede volver a reclamar)
  const [nextClaimTime, setNextClaimTime] = useState(null);
  const [timeRemaining, setTimeRemaining] = useState(0);

  // 🔥 URL DINÁMICA DEL FRONTEND (para el link de invitación) 🔥
  const referralLink = `${window.location.origin}/?ref=${user.id}`;

  const handleCopyLink = () => {
    navigator.clipboard.writeText(referralLink);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  // 🔥 CARGAR LAS GANANCIAS DEL BACKEND 🔥
  const fetchEarnings = async () => {
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`${API_URL}/api/user/referral-earnings`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      const data = await res.json();
      if (res.ok) {
        setEarningsData(data);
        // Si el backend nos envía la fecha del próximo reclamo, la guardamos
        if (data.next_claim_time) {
            setNextClaimTime(new Date(data.next_claim_time).getTime());
        } else {
            setNextClaimTime(null);
        }
      }
    } catch (err) {
      console.error("Error al cargar ganancias:", err);
    } finally {
      setLoadingEarnings(false);
    }
  };

  // 🔥 CARGAR AL INICIO Y ACTUALIZAR CADA 60 SEGUNDOS 🔥
  useEffect(() => {
    fetchEarnings();
    const interval = setInterval(fetchEarnings, 60000); // Se actualiza solo cada minuto
    return () => clearInterval(interval);
  }, []);

  // 🔥 TEMPORIZADOR PARA LA CUENTA ATRÁS DE LAS 24 HORAS 🔥
  useEffect(() => {
    if (!nextClaimTime) return;
    
    const interval = setInterval(() => {
      const now = new Date().getTime();
      const distance = nextClaimTime - now;
      
      if (distance < 0) {
        setTimeRemaining(0);
        setNextClaimTime(null); // Se terminó el tiempo de espera
        clearInterval(interval);
      } else {
        setTimeRemaining(distance);
      }
    }, 1000);

    return () => clearInterval(interval);
  }, [nextClaimTime]);

  // Formatear el tiempo restante para mostrarlo (ej: "23h 59m")
  const formatTime = (ms) => {
      if (ms <= 0) return '';
      const hours = Math.floor((ms / (1000 * 60 * 60)) % 24);
      const minutes = Math.floor((ms / (1000 * 60)) % 60);
      return `${hours}h ${minutes}m`;
  };

  // 🔥 RECLAMAR EL DINERO 🔥
  const handleClaim = async () => {
    if (earningsData.total_pending < 5) {
      alert('El mínimo para reclamar es de 5 NTX');
      return;
    }

    if (timeRemaining > 0) {
        alert('Debes esperar a que pase el tiempo de 24 horas para volver a reclamar.');
        return;
    }

    setClaiming(true);
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`${API_URL}/api/user/referral-earnings/claim`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}` }
      });
      
      const data = await res.json();
      
      if (res.ok) {
        alert(`¡Has reclamado ${data.amount} NTX con éxito! Ya están en tu billetera.`);
        fetchEarnings(); // Refrescamos el saldo de la pantalla
      } else {
        // Si el backend rechaza por las 24 horas, mostramos su error
        alert(data.error || "Error al procesar el reclamo");
      }
    } catch (err) {
      alert("Error al procesar el reclamo");
    } finally {
      setClaiming(false);
    }
  };

  // Determinar si el botón está bloqueado
  const isButtonDisabled = claiming || earningsData.total_pending < 5 || timeRemaining > 0;

  return (
    <main className="main-area">
      <div className="content-scroll" style={{ padding: '1.5rem 2rem' }}>
        
        {/* Cabecera y Pestañas */}
        <div style={{ marginBottom: '1.5rem' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '1rem' }}>
            <h1 style={{ fontSize: '1.8rem', fontWeight: '800', margin: 0 }}>Promoción</h1>
            <span style={{ fontSize: '0.9rem', color: '#00e676', fontWeight: '400' }}>factura</span>
          </div>
          
          <div style={{ display: 'flex', gap: '2rem', borderBottom: '1px solid #2d3748', paddingBottom: '10px' }}>
            <span onClick={() => setActiveTab('inicio')} style={{ color: activeTab === 'inicio' ? '#00e676' : '#a0aec0', cursor: 'pointer', fontWeight: '600', borderBottom: activeTab === 'inicio' ? '2px solid #00e676' : 'none', paddingBottom: '10px' }}>Inicio</span>
            <span onClick={() => setActiveTab('ingreso')} style={{ color: activeTab === 'ingreso' ? '#00e676' : '#a0aec0', cursor: 'pointer', fontWeight: '600', borderBottom: activeTab === 'ingreso' ? '2px solid #00e676' : 'none', paddingBottom: '10px' }}>Ingreso</span>
            <span onClick={() => setActiveTab('usuario')} style={{ color: activeTab === 'usuario' ? '#00e676' : '#a0aec0', cursor: 'pointer', fontWeight: '600', borderBottom: activeTab === 'usuario' ? '2px solid #00e676' : 'none', paddingBottom: '10px' }}>Usuario</span>
          </div>
        </div>

        {/* --- CONTENIDO PESTAÑA INICIO --- */}
        {activeTab === 'inicio' && (
          <>
            <div style={{ background: 'linear-gradient(90deg, #3b2b12 0%, #1a202c 100%)', border: '1px solid #5c4a24', borderRadius: '12px', padding: '1.2rem', display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
              <div>
                <p style={{ color: '#e2b04a', fontSize: '0.9rem', marginBottom: '5px' }}>Recompensas Disponibles (Rake 25%)</p>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <img src="/ntx.png" alt="NTX" style={{ width: '24px', height: '24px', borderRadius: '50%' }} onError={(e) => e.target.style.display = 'none'} />
                  <h2 style={{ fontSize: '2rem', margin: 0 }}>
                    {loadingEarnings ? '...' : Number(earningsData.total_pending).toFixed(2)}
                  </h2>
                </div>
              </div>
              <button 
                className="btn" 
                onClick={handleClaim}
                disabled={isButtonDisabled}
                style={{ 
                  width: 'auto', 
                  padding: '0.5rem 1.5rem', 
                  background: !isButtonDisabled ? '#00e676' : '#5c4a24', 
                  color: !isButtonDisabled ? '#000' : '#e2b04a',
                  cursor: !isButtonDisabled ? 'pointer' : 'not-allowed'
                }}
              >
                {claiming ? 'Procesando...' : (timeRemaining > 0 ? `Espera ${formatTime(timeRemaining)}` : 'Recibir')}
              </button>
            </div>
            
            <div style={{ background: '#1a202c', border: '1px solid #2d3748', borderRadius: '12px', padding: '1.5rem', marginBottom: '2rem' }}>
              <p style={{ color: '#a0aec0', fontSize: '0.9rem', marginBottom: '1rem' }}>Comparte tu enlace y gana el 25% del Rake de tus amigos.</p>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px', background: '#12161f', padding: '10px', borderRadius: '8px', border: '1px solid #2d3748' }}>
                <span style={{ fontSize: '1.5rem' }}>🎁</span>
                <div style={{ flex: 1 }}>
                  <h4 style={{ color: '#f8fafc', fontSize: '0.95rem', margin: 0 }}>Comparte una vez y gana durante cuatro años</h4>
                </div>
                <div style={{ background: '#0b0e14', padding: '0.5rem 1rem', borderRadius: '6px', border: '1px solid #2d3748', color: '#a0aec0', fontSize: '0.9rem', width: '300px', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                  <span>{referralLink}</span>
                </div>
                <button className="btn" onClick={handleCopyLink} style={{ width: 'auto', padding: '0.5rem 1rem', background: copied ? '#10b981' : '#2d3748', color: 'white' }}>{copied ? '¡Copiado!' : 'Copiar Enlace'}</button>
              </div>
            </div>
            
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1.5rem' }}>
              <div style={{ background: '#1a202c', border: '1px solid #2d3748', borderRadius: '12px', padding: '1.5rem' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1rem' }}><h3 style={{ fontSize: '1.1rem', margin: 0 }}>Resumen de datos</h3><span style={{ color: '#00e676', fontSize: '0.85rem' }}>Detalles</span></div>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem', marginBottom: '1.5rem' }}>
                  <div style={{ background: '#12161f', padding: '1rem', borderRadius: '8px' }}>
                    <p style={{ color: '#718096', fontSize: '0.8rem' }}>Ingresos totales</p>
                    <h2 style={{ fontSize: '1.8rem', color: '#e2b04a', margin: 0 }}>
                      {loadingEarnings ? '...' : Number(earningsData.total_pending).toFixed(2)}
                    </h2>
                  </div>
                  <div style={{ background: '#12161f', padding: '1rem', borderRadius: '8px' }}>
                    <p style={{ color: '#718096', fontSize: '0.8rem' }}>Usuarios total</p>
                    <h2 style={{ fontSize: '1.8rem', color: '#00e676', margin: 0 }}>{referralStats.total_referrals}</h2>
                  </div>
                </div>
              </div>
              <div style={{ background: '#1a202c', border: '1px solid #2d3748', borderRadius: '12px', padding: '1.5rem' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1rem' }}><h3 style={{ fontSize: '1.1rem', margin: 0 }}>mi invitación</h3></div>
                <div style={{ height: '200px', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', color: '#4a5568' }}>
                  {referralStats.total_referrals === 0 ? (
                    <><div style={{ fontSize: '3rem', marginBottom: '1rem' }}>📄</div><p>Sin datos, invitar ahora</p></>
                  ) : (
                    <div style={{ width: '100%', height: '100%', overflowY: 'auto' }}>
                      {referralStats.referrals.map(r => (
                        <div key={r.id} style={{ display: 'flex', justifyContent: 'space-between', padding: '0.5rem', borderBottom: '1px solid #2d3748' }}>
                          <span>{r.username}</span>
                          <span style={{ color: '#718096', fontSize: '0.8rem' }}>{new Date(r.created_at).toLocaleDateString()}</span>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            </div>
          </>
        )}

        {/* --- CONTENIDO PESTAÑA INGRESO --- */}
        {activeTab === 'ingreso' && (
          <>
            <div style={{ background: '#1a202c', border: '1px solid #2d3748', borderRadius: '12px', padding: '1.5rem', marginBottom: '1.5rem' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
                <div>
                  <h3 style={{ fontSize: '1.1rem', margin: '0 0 5px 0' }}>Ingresos totales (Pendientes por reclamar)</h3>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    <img src="/ntx.png" alt="NTX" style={{ width: '30px', height: '30px', borderRadius: '50%' }} onError={(e) => e.target.style.display = 'none'} />
                    <h2 style={{ fontSize: '2.5rem', margin: 0, color: '#e2b04a' }}>
                      {loadingEarnings ? '...' : Number(earningsData.total_pending).toFixed(2)}
                    </h2>
                  </div>
                </div>
                <div style={{ display: 'flex', gap: '2rem', textAlign: 'center' }}>
                  <div><p style={{ color: '#718096', fontSize: '0.8rem', marginBottom: '5px' }}>Ayer</p><span style={{ fontSize: '1.1rem', fontWeight: 'bold' }}>0</span></div>
                  <div><p style={{ color: '#718096', fontSize: '0.8rem', marginBottom: '5px' }}>Últimos 7 días</p><span style={{ fontSize: '1.1rem', fontWeight: 'bold' }}>0</span></div>
                  <div><p style={{ color: '#718096', fontSize: '0.8rem', marginBottom: '5px' }}>Casi 30 días</p><span style={{ fontSize: '1.1rem', fontWeight: 'bold' }}>0</span></div>
                </div>
              </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1.5rem' }}>
              <div style={{ background: '#1a202c', border: '1px solid #2d3748', borderRadius: '12px', padding: '1.5rem' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1rem' }}>
                  <h3 style={{ fontSize: '1rem', margin: 0 }}>Cambios de ingresos</h3>
                  <select style={{ background: '#12161f', color: '#fff', border: '1px solid #2d3748', padding: '2px 10px', borderRadius: '4px', fontSize: '0.8rem' }}><option>últimos 7 días</option></select>
                </div>
                <EmptyChart />
              </div>
              <div style={{ background: '#1a202c', border: '1px solid #2d3748', borderRadius: '12px', padding: '1.5rem' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1rem' }}>
                  <h3 style={{ fontSize: '1rem', margin: 0 }}>Fuente (Desglose)</h3>
                </div>
                <div style={{ height: '150px', display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', color: '#4a5568' }}>
                  {earningsData.details.length === 0 ? (
                    <><div style={{ fontSize: '2.5rem', marginBottom: '10px' }}>📄</div><p style={{ margin: 0 }}>Sin datos</p></>
                  ) : (
                    <div style={{ width: '100%', height: '100%', overflowY: 'auto' }}>
                      {earningsData.details.map((d, i) => (
                        <div key={i} style={{ display: 'flex', justifyContent: 'space-between', padding: '5px', borderBottom: '1px solid #2d3748' }}>
                          <span style={{ color: '#00e676' }}>+{Number(d.amount).toFixed(2)} NTX</span>
                          <span style={{ color: '#a0aec0', fontSize: '0.85rem' }}>{d.username}</span>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            </div>
          </>
        )}

        {/* --- CONTENIDO PESTAÑA USUARIO --- */}
        {activeTab === 'usuario' && (
          <>
            <div style={{ background: '#1a202c', border: '1px solid #2d3748', borderRadius: '12px', padding: '1.5rem', marginBottom: '1.5rem' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
                <div>
                  <h3 style={{ fontSize: '1.1rem', margin: '0 0 5px 0' }}>Usuarios total</h3>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    <h2 style={{ fontSize: '2.5rem', margin: 0, color: '#00e676' }}>{referralStats.total_referrals}</h2>
                  </div>
                </div>
                <div style={{ display: 'flex', gap: '2rem', textAlign: 'center' }}>
                  <div><p style={{ color: '#718096', fontSize: '0.8rem', marginBottom: '5px' }}>Ayer</p><span style={{ fontSize: '1.1rem', fontWeight: 'bold' }}>0</span></div>
                  <div><p style={{ color: '#718096', fontSize: '0.8rem', marginBottom: '5px' }}>Últimos 7 días</p><span style={{ fontSize: '1.1rem', fontWeight: 'bold' }}>0</span></div>
                  <div><p style={{ color: '#718096', fontSize: '0.8rem', marginBottom: '5px' }}>Casi 30 días</p><span style={{ fontSize: '1.1rem', fontWeight: 'bold' }}>0</span></div>
                </div>
                <div style={{ width: '60px', height: '60px', borderRadius: '50%', background: '#0b0e14', display: 'flex', justifyContent: 'center', alignItems: 'center', border: '1px solid #2d3748' }}>
                  <UserIcon />
                </div>
              </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1.5rem' }}>
              <div style={{ background: '#1a202c', border: '1px solid #2d3748', borderRadius: '12px', padding: '1.5rem' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1rem' }}>
                  <h3 style={{ fontSize: '1rem', margin: 0 }}>Cambios de usuario</h3>
                  <select style={{ background: '#12161f', color: '#fff', border: '1px solid #2d3748', padding: '2px 10px', borderRadius: '4px', fontSize: '0.8rem' }}><option>últimos 7 días</option></select>
                </div>
                <EmptyChart />
              </div>
              <div style={{ background: '#1a202c', border: '1px solid #2d3748', borderRadius: '12px', padding: '1.5rem' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1rem' }}>
                  <h3 style={{ fontSize: '1rem', margin: 0 }}>Fuente</h3>
                  <select style={{ background: '#12161f', color: '#fff', border: '1px solid #2d3748', padding: '2px 10px', borderRadius: '4px', fontSize: '0.8rem' }}><option>últimos 7 días</option></select>
                </div>
                <div style={{ height: '150px', display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', color: '#4a5568' }}>
                  <div style={{ fontSize: '2.5rem', marginBottom: '10px' }}>📄</div>
                  <p style={{ margin: 0 }}>Sin datos</p>
                </div>
              </div>
            </div>
          </>
        )}

      </div>
    </main>
  );
}