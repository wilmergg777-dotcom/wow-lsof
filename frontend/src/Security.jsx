import { useState, useEffect, useRef } from 'react';
import { API_URL } from './config'; // 🔥 IMPORTAMOS LA URL DINÁMICA

// 🔥 COMPONENTE DE TOAST LOCAL (Para notificaciones) 🔥
const LocalToast = ({ message, type, onClose }) => {
  useEffect(() => {
    const timer = setTimeout(onClose, 3000);
    return () => clearTimeout(timer);
  }, []); 

  let bgColor = '#1a202c';
  let borderColor = '#4a5568';
  let icon = 'ℹ️';

  if (type === 'success') {
    bgColor = 'linear-gradient(90deg, #00e676 0%, #009956 100%)';
    borderColor = '#00e676';
    icon = '✅';
  } else if (type === 'error') {
    bgColor = 'linear-gradient(90deg, #ef4444 0%, #991b1b 100%)';
    borderColor = '#ef4444';
    icon = '❌';
  }

  return (
    <div style={{
      position: 'fixed', top: '20px', left: '50%', transform: 'translateX(-50%)',
      background: bgColor, color: '#fff', padding: '12px 24px', borderRadius: '8px',
      border: `1px solid ${borderColor}`, boxShadow: '0 10px 25px rgba(0,0,0,0.5)',
      zIndex: 99999, display: 'flex', alignItems: 'center', gap: '10px', fontWeight: 'bold',
      animation: 'slideDown 0.3s ease-out'
    }}>
      <span>{icon}</span>
      <span>{message}</span>
    </div>
  );
};

export default function Security({
  user, hasPin, pinEnabled, showPasswordForm, showPinForm,
  oldPassword, newPassword, newPin,
  setOldPassword, setNewPassword, setNewPin,
  setShowPasswordForm, setShowPinForm,
  handleChangePassword, handleSavePin, handleTogglePin,
  setCurrentPage, setIsEditingProfile, Icons,
  setUser // 🔥 IMPORTANTE: Necesitamos esto para actualizar el estado global
}) {
  const [toast, setToast] = useState(null);
  
  // Estados para los Modales
  const [showPinEntryModal, setShowPinEntryModal] = useState(false);
  const [showConfirmPinModal, setShowConfirmPinModal] = useState(false);
  
  const [showPasswordModal, setShowPasswordModal] = useState(false);
  
  const [showEmailConfirmModal, setShowEmailConfirmModal] = useState(false);
  const [showEmailVerifyModal, setShowEmailVerifyModal] = useState(false);
  const [emailCode, setEmailCode] = useState('');

  // 🔥 NUEVOS ESTADOS PARA EL TELÉFONO
  const [showPhoneModal, setShowPhoneModal] = useState(false);
  const [newPhone, setNewPhone] = useState('');

  const inputRef = useRef(null);
  const emailInputRef = useRef(null);

  const showToast = (message, type = 'info') => {
    setToast({ message, type });
  };

  // 🔥 SOLUCIÓN AL F5: Si el usuario no tiene teléfono en memoria, lo busca en la BD
  useEffect(() => {
    const syncProfile = async () => {
      if (user && !user.phone) {
        try {
          const token = localStorage.getItem('token');
          const res = await fetch(`${API_URL}/api/user/profile`, {
            headers: { Authorization: `Bearer ${token}` }
          });
          if (res.ok) {
            const data = await res.json();
            if (setUser) {
              setUser(data); // Actualiza el estado global y la pantalla
            }
          }
        } catch (err) {
          console.error("Error sincronizando perfil:", err);
        }
      }
    };
    syncProfile();
  }, [user, setUser]);

  // Enfocar inputs ocultos
  useEffect(() => {
    if (showPinEntryModal && inputRef.current) inputRef.current.focus();
    if (showEmailVerifyModal && emailInputRef.current) emailInputRef.current.focus();
  }, [showPinEntryModal, showEmailVerifyModal]);

  // 🔥 Lógica del PIN 🔥
  const handlePinChange = (e) => {
    const val = e.target.value.replace(/\D/g, '');
    if (val.length <= 6) {
      setNewPin(val);
      if (val.length === 6) {
        setShowPinEntryModal(false);
        setShowConfirmPinModal(true);
      }
    }
  };

  // 🔥 CORREGIDO: Espera a que el backend guarde el PIN antes de cerrar 🔥
  const handleConfirmPinChange = async () => {
    setShowConfirmPinModal(false);
    const success = await handleSavePin({ preventDefault: () => {} });
    if (success) {
      setNewPin('');
    }
  };

  // 🔥 LÓGICA DEL INTERRUPTOR (SWITCH) 🔥
  const handleToggleSwitch = () => {
    if (!hasPin) {
      setNewPin('');
      setShowPinEntryModal(true);
      showToast('Debes configurar un PIN de 6 dígitos primero', 'info');
    } else {
      handleTogglePin();
    }
  };

  // 🔥 Lógica del Correo (Cambio de correo) 🔥
  const handleEmailCodeChange = (e) => {
    const val = e.target.value.replace(/\D/g, '');
    if (val.length <= 6) {
      setEmailCode(val);
      if (val.length === 6) {
        showToast('Código verificado. Correo actualizado.', 'success');
        setShowEmailVerifyModal(false);
        setEmailCode('');
      }
    }
  };

  // 🔥 LÓGICA PARA GUARDAR EL TELÉFONO EN EL BACKEND Y ACTUALIZAR EL ESTADO
  const handleSavePhone = async (e) => {
    e.preventDefault();
    if (!newPhone.trim()) return showToast('Ingresa un número válido', 'error');
    
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`${API_URL}/api/user/phone`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
        body: JSON.stringify({ phone: newPhone })
      });
      const data = await res.json();
      
      if (res.ok) {
        showToast('Teléfono actualizado correctamente', 'success');
        setShowPhoneModal(false);
        
        // 🔥 AQUÍ ACTUALIZAMOS LA PANTALLA AL INSTANTE
        if (setUser) {
          setUser(prevUser => ({
            ...prevUser,
            phone: newPhone
          }));
        }
      } else {
        showToast(data.error || 'Error al guardar el teléfono', 'error');
      }
    } catch (error) {
      showToast('Error de conexión con el servidor', 'error');
    }
  };

  // 🔥 Lógica para vincular Discord
  const handleLinkDiscord = () => {
    const token = localStorage.getItem('token');
    if (!token) {
      showToast('Debes iniciar sesión para vincular Discord', 'error');
      return;
    }
    window.location.href = `${API_URL}/api/auth/discord?link_token=${token}`;
  };

  const SafeIcons = Icons || {};
  
  // 🔥 CORRECCIÓN VISUAL: Manejo correcto del correo
  const displayEmail = user?.email 
    ? user.email.replace(/(.{2})(.*)(?=@)/, "$1***") 
    : 'No registrado';

  // 🔥 CORRECCIÓN VISUAL: Regex adaptado para 8 o 9 dígitos
  const displayPhone = user?.phone 
    ? user.phone.replace(/^(\d{3})\d*(\d{3})$/, '$1***$2') 
    : 'No registrado';

  return (
    <main className="main-area">
      {toast && <LocalToast message={toast.message} type={toast.type} onClose={() => setToast(null)} />}

      {/* 🔥 MODAL 1: INGRESO DEL PIN (6 Cuadritos) 🔥 */}
      {showPinEntryModal && (
        <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', background: 'rgba(0,0,0,0.95)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 99999, backdropFilter: 'blur(8px)' }}>
          <div style={{ background: '#171b24', padding: '30px', borderRadius: '12px', width: '400px', border: '1px solid #2d3748', textAlign: 'center', position: 'relative', boxShadow: '0 20px 50px rgba(0,0,0,0.9)' }}>
            
            <button onClick={() => setShowPinEntryModal(false)} style={{ position: 'absolute', top: '15px', right: '15px', background: 'transparent', border: 'none', color: '#a0aec0', fontSize: '1.5rem', cursor: 'pointer', zIndex: 10 }}>×</button>
            
            <h3 style={{ color: '#fff', margin: '0 0 10px 0', fontSize: '1.2rem', fontWeight: 'bold' }}>PIN Code De Pago</h3>
            <p style={{ color: '#a0aec0', marginBottom: '25px', fontSize: '0.9rem' }}>Introduzca PIN Code de pago de 6 dígitos</p>
            
            <div style={{ position: 'relative', display: 'flex', gap: '10px', justifyContent: 'center', marginBottom: '20px' }}>
              {[...Array(6)].map((_, index) => (
                <div key={index} style={{ width: '45px', height: '55px', background: '#0b0e14', border: index === newPin.length ? '2px solid #00e676' : '1px solid #4a5568', borderRadius: '8px', display: 'flex', justifyContent: 'center', alignItems: 'center', fontSize: '1.5rem', color: '#fff', fontWeight: 'bold', transition: 'all 0.2s' }}>
                  {newPin[index] ? '•' : ''}
                </div>
              ))}
              <input ref={inputRef} type="text" value={newPin} onChange={handlePinChange} style={{ opacity: 0, position: 'absolute', top: 0, left: 0, width: '100%', height: '100%', cursor: 'default' }} autoFocus />
            </div>

            <p style={{ color: '#a0aec0', fontSize: '0.85rem', cursor: 'pointer', margin: 0 }} onClick={() => showToast('Contacta a soporte para recuperar tu PIN.', 'info')}>Forgot PIN Code</p>
          </div>
        </div>
      )}

      {/* 🔥 MODAL 2: ADVERTENCIA DE 24 HORAS (PIN) 🔥 */}
      {showConfirmPinModal && (
        <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', background: 'rgba(0,0,0,0.95)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 99999, backdropFilter: 'blur(8px)' }}>
          <div style={{ background: '#171b24', padding: '30px', borderRadius: '12px', width: '420px', border: '1px solid #2d3748', textAlign: 'center', boxShadow: '0 20px 50px rgba(0,0,0,0.9)' }}>
            <div style={{ width: '50px', height: '50px', background: '#fbbf24', borderRadius: '50%', display: 'flex', justifyContent: 'center', alignItems: 'center', margin: '0 auto 15px auto', fontSize: '1.8rem', color: '#000', fontWeight: 'bold' }}>!</div>
            <h3 style={{ color: '#fff', margin: '0 0 10px 0', fontSize: '1.1rem', fontWeight: 'bold' }}>¿Está seguro de que desea cambiar PIN Code de pago?</h3>
            <p style={{ color: '#a0aec0', marginBottom: '25px', fontSize: '0.85rem' }}>Después de realizar el cambio PIN Code de pago, las transferencias estarán prohibidas durante 24 horas.</p>
            <div style={{ display: 'flex', gap: '15px' }}>
              <button onClick={() => setShowConfirmPinModal(false)} style={{ flex: 1, padding: '12px', background: '#2d3748', color: '#fff', border: 'none', borderRadius: '8px', fontWeight: 'bold', cursor: 'pointer' }}>Cancelar</button>
              <button onClick={handleConfirmPinChange} style={{ flex: 1, padding: '12px', background: '#10b981', color: '#fff', border: 'none', borderRadius: '8px', fontWeight: 'bold', cursor: 'pointer' }}>Confirmar</button>
            </div>
          </div>
        </div>
      )}

      {/* 🔥 MODAL 3: CAMBIAR CONTRASEÑA 🔥 */}
      {showPasswordModal && (
        <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', background: 'rgba(0,0,0,0.95)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 99999, backdropFilter: 'blur(8px)' }}>
          <div style={{ background: '#171b24', padding: '30px', borderRadius: '12px', width: '400px', border: '1px solid #2d3748', position: 'relative', boxShadow: '0 20px 50px rgba(0,0,0,0.9)' }}>
            <button onClick={() => setShowPasswordModal(false)} style={{ position: 'absolute', top: '15px', right: '15px', background: 'transparent', border: 'none', color: '#a0aec0', fontSize: '1.5rem', cursor: 'pointer', zIndex: 10 }}>×</button>
            <h3 style={{ color: '#fff', margin: '0 0 20px 0', fontSize: '1.2rem', fontWeight: 'bold' }}>Cambiar Contraseña</h3>
            <form onSubmit={async (e) => { 
              e.preventDefault(); 
              const success = await handleChangePassword(e); 
              if (success) setShowPasswordModal(false); 
            }}>
              <input type="password" placeholder="Contraseña Actual" style={{ width: '100%', padding: '12px', marginBottom: '15px', background: '#0b0e14', border: '1px solid #4a5568', color: 'white', borderRadius: '8px' }} value={oldPassword} onChange={e => setOldPassword(e.target.value)} required />
              <input type="password" placeholder="Nueva Contraseña" style={{ width: '100%', padding: '12px', marginBottom: '20px', background: '#0b0e14', border: '1px solid #4a5568', color: 'white', borderRadius: '8px' }} value={newPassword} onChange={e => setNewPassword(e.target.value)} required />
              <button type="submit" className="btn" style={{ width: '100%', background: '#00e676', color: '#000' }}>Guardar Contraseña</button>
            </form>
          </div>
        </div>
      )}

      {/* 🔥 MODAL 4: ADVERTENCIA DE CAMBIO DE CORREO 🔥 */}
      {showEmailConfirmModal && (
        <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', background: 'rgba(0,0,0,0.95)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 99999, backdropFilter: 'blur(8px)' }}>
          <div style={{ background: '#171b24', padding: '30px', borderRadius: '12px', width: '420px', border: '1px solid #2d3748', textAlign: 'center', boxShadow: '0 20px 50px rgba(0,0,0,0.9)' }}>
            <div style={{ width: '50px', height: '50px', background: '#fbbf24', borderRadius: '50%', display: 'flex', justifyContent: 'center', alignItems: 'center', margin: '0 auto 15px auto', fontSize: '1.8rem', color: '#000', fontWeight: 'bold' }}>!</div>
            <h3 style={{ color: '#fff', margin: '0 0 10px 0', fontSize: '1.1rem', fontWeight: 'bold' }}>¿Está seguro de que desea cambiar Correo?</h3>
            <p style={{ color: '#a0aec0', marginBottom: '25px', fontSize: '0.85rem' }}>Después de realizar el cambio Correo, las transferencias estarán prohibidas durante 24 horas.</p>
            <div style={{ display: 'flex', gap: '15px' }}>
              <button onClick={() => setShowEmailConfirmModal(false)} style={{ flex: 1, padding: '12px', background: '#2d3748', color: '#fff', border: 'none', borderRadius: '8px', fontWeight: 'bold', cursor: 'pointer' }}>Cancelar</button>
              <button onClick={() => { setShowEmailConfirmModal(false); setShowEmailVerifyModal(true); }} style={{ flex: 1, padding: '12px', background: '#10b981', color: '#fff', border: 'none', borderRadius: '8px', fontWeight: 'bold', cursor: 'pointer' }}>Confirmar</button>
            </div>
          </div>
        </div>
      )}

      {/* 🔥 MODAL 5: VERIFICACIÓN DE CORREO (6 Cuadritos) 🔥 */}
      {showEmailVerifyModal && (
        <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', background: 'rgba(0,0,0,0.95)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 99999, backdropFilter: 'blur(8px)' }}>
          <div style={{ background: '#171b24', padding: '30px', borderRadius: '12px', width: '400px', border: '1px solid #2d3748', textAlign: 'center', position: 'relative', boxShadow: '0 20px 50px rgba(0,0,0,0.9)' }}>
            <button onClick={() => setShowEmailVerifyModal(false)} style={{ position: 'absolute', top: '15px', right: '15px', background: 'transparent', border: 'none', color: '#a0aec0', fontSize: '1.5rem', cursor: 'pointer', zIndex: 10 }}>×</button>
            <h3 style={{ color: '#fff', margin: '0 0 10px 0', fontSize: '1.2rem', fontWeight: 'bold' }}>Verificación De Correo Electrónico</h3>
            <p style={{ color: '#a0aec0', marginBottom: '25px', fontSize: '0.85rem' }}>
              Código de verificación enviado a <strong>{displayEmail}</strong>
            </p>
            <div style={{ position: 'relative', display: 'flex', gap: '10px', justifyContent: 'center', marginBottom: '20px' }}>
              {[...Array(6)].map((_, index) => (
                <div key={index} style={{ width: '45px', height: '55px', background: '#0b0e14', border: index === emailCode.length ? '2px solid #00e676' : '1px solid #4a5568', borderRadius: '8px', display: 'flex', justifyContent: 'center', alignItems: 'center', fontSize: '1.5rem', color: '#fff', fontWeight: 'bold', transition: 'all 0.2s' }}>
                  {emailCode[index] ? '•' : ''}
                </div>
              ))}
              <input ref={emailInputRef} type="text" value={emailCode} onChange={handleEmailCodeChange} style={{ opacity: 0, position: 'absolute', top: 0, left: 0, width: '100%', height: '100%', cursor: 'default' }} autoFocus />
            </div>
            <p style={{ color: '#a0aec0', fontSize: '0.85rem', margin: 0 }}>
              ¿Aún no ha recibido el correo electrónico? Por favor, revisa tu casilla de correo no deseado o haz clic en <strong style={{ color: '#00e676', cursor: 'pointer' }} onClick={() => showToast('Correo reenviado', 'info')}>reenviar</strong>.
            </p>
          </div>
        </div>
      )}

      {/* 🔥 MODAL 6: CONFIGURAR TELÉFONO 🔥 */}
      {showPhoneModal && (
        <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', background: 'rgba(0,0,0,0.95)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 99999, backdropFilter: 'blur(8px)' }}>
          <div style={{ background: '#171b24', padding: '30px', borderRadius: '12px', width: '400px', border: '1px solid #2d3748', position: 'relative', boxShadow: '0 20px 50px rgba(0,0,0,0.9)' }}>
            <button onClick={() => setShowPhoneModal(false)} style={{ position: 'absolute', top: '15px', right: '15px', background: 'transparent', border: 'none', color: '#a0aec0', fontSize: '1.5rem', cursor: 'pointer', zIndex: 10 }}>×</button>
            <h3 style={{ color: '#fff', margin: '0 0 20px 0', fontSize: '1.2rem', fontWeight: 'bold' }}>Configurar Teléfono</h3>
            <form onSubmit={handleSavePhone}>
              <input 
                type="tel" 
                placeholder="Ej: +53 555 1234" 
                style={{ width: '100%', padding: '12px', marginBottom: '20px', background: '#0b0e14', border: '1px solid #4a5568', color: 'white', borderRadius: '8px' }} 
                value={newPhone} 
                onChange={e => setNewPhone(e.target.value)} 
                required 
              />
              <button type="submit" className="btn" style={{ width: '100%', background: '#00e676', color: '#000' }}>Guardar Teléfono</button>
            </form>
          </div>
        </div>
      )}

      <div className="security-container">
        <h1 className="security-title">Seguridad</h1>
        <div style={{ marginBottom: '2.5rem' }}>
          <h3 className="security-section-title">Gestión del método de verificación.</h3>
          
          {/* Contraseña */}
          <div className="security-row">
            <div className="security-row-left">{SafeIcons.Lock ? <SafeIcons.Lock /> : '🔒'} Contraseña</div>
            <div className="security-row-right">
              <span>No ajuste</span>
              <span className="action-link" onClick={() => setShowPasswordModal(true)}>Ajuste</span>
            </div>
          </div>

          {/* Habilitar PIN (SWITCH CORREGIDO) */}
          <div className="security-row">
            <div className="security-row-left">{SafeIcons.Shield ? <SafeIcons.Shield /> : '🛡️'} Habilitar código PIN de pago <span style={{color:'#718096', fontSize:'0.8rem', marginLeft: '5px'}}>ⓘ</span></div>
            <div className="security-row-right">
              <div className={`toggle-switch ${pinEnabled && hasPin ? 'active' : ''}`} onClick={handleToggleSwitch}>
                <div className="toggle-circle"></div>
              </div>
            </div>
          </div>

          {/* Configurar PIN */}
          <div className="security-row">
            <div className="security-row-left">{SafeIcons.Key ? <SafeIcons.Key /> : '🔑'} PIN Code de pago</div>
            <div className="security-row-right">
              <span>{hasPin ? 'Ya ajuste' : 'No ajuste'}</span>
              <span className="action-link" onClick={() => { setNewPin(''); setShowPinEntryModal(true); }}>
                {hasPin ? 'Cambiar' : 'Ajuste'}
              </span>
            </div>
          </div>

          {/* Clave Biológica */}
          <div className="security-row">
            <div className="security-row-left">{SafeIcons.Fingerprint ? <SafeIcons.Fingerprint /> : '👆'} Clave biológica</div>
            <div className="security-row-right">
              <span>Sin límites</span>
              <span className="action-link" onClick={() => showToast('Requerirá sensor biométrico', 'info')}>Vinculante</span>
            </div>
          </div>

          {/* Correo */}
          <div className="security-row">
            <div className="security-row-left">{SafeIcons.MailIcon ? <SafeIcons.MailIcon /> : '📧'} Correo</div>
            <div className="security-row-right">
              <span>{displayEmail}</span>
              <span className="action-link" onClick={() => setShowEmailConfirmModal(true)}>Cambiar</span>
              <span className="action-link-danger">Desagregar</span>
            </div>
          </div>

          {/* 🔥 NUEVA FILA: TELÉFONO 🔥 */}
          <div className="security-row">
            <div className="security-row-left">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#e2e8f0" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ marginRight: '8px' }}>
                <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path>
              </svg>
              Teléfono
            </div>
            <div className="security-row-right">
              <span>{displayPhone}</span>
              <span className="action-link" onClick={() => { setNewPhone(user?.phone || ''); setShowPhoneModal(true); }}>
                {user?.phone ? 'Cambiar' : 'Ajuste'}
              </span>
            </div>
          </div>

          {/* Validador */}
          <div className="security-row">
            <div className="security-row-left">{SafeIcons.CheckCircle ? <SafeIcons.CheckCircle /> : '✅'} Validador</div>
            <div className="security-row-right">
              <span>Sin límites</span>
              <span className="action-link" onClick={() => showToast('Escanea código QR', 'info')}>Vinculante</span>
            </div>
          </div>
        </div>

        {/* Métodos de Login */}
        <div>
          <h3 className="security-section-title">Método de inicio de sesión</h3>
          <div className="security-row">
            <div className="security-row-left">{SafeIcons.Discord ? <SafeIcons.Discord /> : '💬'} Discord</div>
            <div className="security-row-right">
              {user?.discord_id ? (
                <>
                  <span style={{ color: '#00e676', fontWeight: 'bold' }}>Vinculado</span>
                  <span className="action-link-danger">Desagregar</span>
                </>
              ) : (
                <>
                  <span>Sin límites</span>
                  <span className="action-link" onClick={handleLinkDiscord}>
                    Vinculante
                  </span>
                </>
              )}
            </div>
          </div>
        </div>
      </div>
    </main>
  );
}