import React, { useState, useEffect } from 'react';
import { API_URL } from './config';

const ServerConfig = ({ onBack }) => {
  // Estado para controlar qué pestaña está activa
  const [activeTab, setActiveTab] = useState('discord');

  // --- ESTADOS DE DISCORD ---
  const [config, setConfig] = useState({
    discord_client_id: '',
    discord_client_secret: '',
    discord_redirect_uri: ''
  });
  const [loading, setLoading] = useState(false);
  const [mensaje, setMensaje] = useState('');

  // --- ESTADOS DE SMTP (CORREO) ---
  const [smtpConfig, setSmtpConfig] = useState({
    smtp_host: '',
    smtp_port: '587',
    smtp_user: '',
    smtp_pass: '',
    smtp_from_email: '',
    smtp_from_name: 'RoyalBET',
    smtp_secure: false
  });
  const [smtpLoading, setSmtpLoading] = useState(false);
  const [smtpMensaje, setSmtpMensaje] = useState('');
  const [testEmail, setTestEmail] = useState('');
  const [testLoading, setTestLoading] = useState(false);
  const [testMensaje, setTestMensaje] = useState('');

  // --- ESTADOS DE ANUNCIOS GLOBALES ---
  const [announcementData, setAnnouncementData] = useState({
    title: '',
    message: '',
    sendToWeb: true,
    sendToEmail: false
  });
  const [announcementLoading, setAnnouncementLoading] = useState(false);
  const [announcementMsg, setAnnouncementMsg] = useState('');

  // Cargar configuración de Discord
  useEffect(() => {
    const fetchConfig = async () => {
      try {
        const token = localStorage.getItem('token');
        const res = await fetch(`${API_URL}/api/admin/server-config`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (res.ok) {
          const data = await res.json();
          if (data) setConfig(prev => ({ ...prev, ...data }));
        }
      } catch (error) {
        console.error("Error al cargar configuración de Discord");
      }
    };
    fetchConfig();
  }, []);

  // Cargar configuración SMTP
  useEffect(() => {
    const fetchSmtpConfig = async () => {
      try {
        const token = localStorage.getItem('token');
        const res = await fetch(`${API_URL}/api/admin/smtp-config`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (res.ok) {
          const data = await res.json();
          if (data) {
            setSmtpConfig({
              ...data,
              smtp_secure: data.smtp_secure === 1 || data.smtp_secure === true
            });
          }
        }
      } catch (error) {
        console.error("Error al cargar configuración SMTP");
      }
    };
    fetchSmtpConfig();
  }, []);

  // --- MANEJADORES DISCORD ---
  const handleChange = (e) => {
    setConfig({ ...config, [e.target.name]: e.target.value });
  };

  const handleSave = async () => {
    setLoading(true);
    setMensaje('');
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`${API_URL}/api/admin/server-config`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
        body: JSON.stringify(config)
      });
      if (res.ok) {
        setMensaje('✅ Configuración guardada correctamente');
      } else {
        const errorData = await res.json();
        setMensaje(`❌ Error: ${errorData.error || 'No se pudo guardar'}`);
      }
    } catch (error) {
      setMensaje('❌ Error de conexión con el servidor');
    }
    setLoading(false);
  };

  // --- MANEJADORES SMTP ---
  const handleSmtpChange = (e) => {
    const value = e.target.type === 'checkbox' ? e.target.checked : e.target.value;
    setSmtpConfig({ ...smtpConfig, [e.target.name]: value });
  };

  const handleSaveSmtp = async () => {
    setSmtpLoading(true);
    setSmtpMensaje('');
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`${API_URL}/api/admin/smtp-config`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
        body: JSON.stringify(smtpConfig)
      });
      if (res.ok) {
        setSmtpMensaje('✅ Configuración SMTP guardada correctamente');
      } else {
        const errorData = await res.json();
        setSmtpMensaje(`❌ Error: ${errorData.error || 'No se pudo guardar'}`);
      }
    } catch (error) {
      setSmtpMensaje('❌ Error de conexión con el servidor');
    }
    setSmtpLoading(false);
  };

  const handleTestSmtp = async () => {
    if (!testEmail) {
      setTestMensaje('❌ Debes ingresar un correo de destino');
      return;
    }
    setTestLoading(true);
    setTestMensaje('');
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`${API_URL}/api/admin/smtp-test`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
        body: JSON.stringify({ test_email: testEmail })
      });
      const data = await res.json();
      if (res.ok) {
        setTestMensaje('✅ Correo de prueba enviado. Revisa tu bandeja.');
      } else {
        setTestMensaje(`❌ Error: ${data.error || 'No se pudo enviar'}`);
      }
    } catch (error) {
      setTestMensaje('❌ Error de conexión al enviar prueba');
    }
    setTestLoading(false);
  };

  // --- MANEJADOR ANUNCIOS GLOBALES ---
  const handleSendAnnouncement = async () => {
    if (!announcementData.title.trim() || !announcementData.message.trim()) {
      setAnnouncementMsg('❌ El título y el mensaje son obligatorios');
      return;
    }
    if (!announcementData.sendToWeb && !announcementData.sendToEmail) {
      setAnnouncementMsg('❌ Debes seleccionar al menos un método de envío (Web o Correo)');
      return;
    }

    setAnnouncementLoading(true);
    setAnnouncementMsg('');
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`${API_URL}/api/admin/announcements`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
        body: JSON.stringify(announcementData)
      });
      const data = await res.json();
      if (res.ok) {
        setAnnouncementMsg('✅ Anuncio enviado a todos los usuarios correctamente.');
        setAnnouncementData({ title: '', message: '', sendToWeb: true, sendToEmail: false });
      } else {
        setAnnouncementMsg(`❌ Error: ${data.error || 'No se pudo enviar el anuncio'}`);
      }
    } catch (error) {
      setAnnouncementMsg('❌ Error de conexión con el servidor');
    }
    setAnnouncementLoading(false);
  };

  // --- ESTILOS REUTILIZABLES ---
  const inputStyle = {
    width: '100%', padding: '12px', background: '#121212', border: '1px solid #333', borderRadius: '8px', color: 'white', fontSize: '14px'
  };
  
  const labelStyle = {
    color: '#ccc', fontSize: '12px', marginBottom: '5px', display: 'block', fontWeight: 'bold'
  };

  const btnStyle = {
    padding: '12px 24px', background: '#00e676', color: 'black', border: 'none', borderRadius: '8px', fontWeight: 'bold', fontSize: '15px', cursor: 'pointer'
  };

  return (
    <main className="main-area" style={{ backgroundColor: '#0a0a0a', minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
      
      {/* HEADER */}
      <div style={{ display: 'flex', alignItems: 'center', padding: '20px', borderBottom: '1px solid #222' }}>
        <button onClick={onBack} style={{ background: 'none', border: 'none', color: 'white', fontSize: '24px', marginRight: '15px', cursor: 'pointer' }}>←</button>
        <h2 style={{ margin: 0, fontSize: '20px', color: 'white' }}>Configuración del Sistema</h2>
      </div>

      {/* CONTENEDOR PRINCIPAL */}
      <div style={{ display: 'flex', flexDirection: 'column', flex: 1, padding: '20px' }}>
        
        {/* 🔥 PESTAÑAS HORIZONTALES 🔥 */}
        <div style={{ display: 'flex', gap: '5px', borderBottom: '1px solid #2d3748', marginBottom: '1.5rem', overflowX: 'auto' }}>
          {[
            { id: 'discord', label: '🤖 Discord (OAuth2)' },
            { id: 'email', label: '📧 Servidor de Correos' },
            { id: 'announcements', label: '📢 Anuncios Globales' },
            { id: 'payments', label: '💳 Pasarelas de Pago' },
            { id: 'api', label: '🔑 API Keys' }
          ].map(tab => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              style={{
                padding: '12px 20px',
                background: 'transparent',
                border: 'none',
                borderBottom: activeTab === tab.id ? '3px solid #00e676' : '3px solid transparent',
                color: activeTab === tab.id ? '#00e676' : '#a0aec0',
                fontWeight: 'bold',
                cursor: 'pointer',
                fontSize: '0.95rem',
                transition: '0.2s',
                whiteSpace: 'nowrap'
              }}
            >
              {tab.label}
            </button>
          ))}
        </div>

        {/* ÁREA DE CONTENIDO DINÁMICO */}
        <div style={{ backgroundColor: '#1a1a1a', borderRadius: '12px', padding: '25px', minWidth: '300px' }}>
          
          {/* --- MÓDULO: DISCORD --- */}
          {activeTab === 'discord' && (
            <div style={{ animation: 'fadeIn 0.3s' }}>
              <h3 style={{ color: '#00e676', marginTop: 0 }}>🤖 Integración con Discord</h3>
              <p style={{ color: '#a0aec0', fontSize: '14px', marginBottom: '25px', lineHeight: '1.5' }}>
                Estas credenciales permiten que cualquier usuario inicie sesión en RoyalBET usando su cuenta de Discord de forma global.
              </p>

              <div style={{ marginBottom: '15px' }}>
                <label style={labelStyle}>Discord Client ID</label>
                <input type="text" name="discord_client_id" value={config.discord_client_id || ''} onChange={handleChange} placeholder="Ej: 123456789012345678" style={inputStyle} />
              </div>

              <div style={{ marginBottom: '15px' }}>
                <label style={labelStyle}>Discord Client Secret</label>
                <input type="password" name="discord_client_secret" value={config.discord_client_secret || ''} onChange={handleChange} placeholder="••••••••••••••••••••••••••••" style={inputStyle} />
              </div>

              <div style={{ marginBottom: '25px' }}>
                <label style={labelStyle}>Redirect URI (URL de redirección)</label>
                <input type="text" name="discord_redirect_uri" value={config.discord_redirect_uri || ''} onChange={handleChange} placeholder="http://localhost:3000/api/auth/discord/callback" style={inputStyle} />
              </div>

              {mensaje && <p style={{ color: mensaje.includes('✅') ? '#00e676' : '#ef4444', fontSize: '14px', marginBottom: '15px' }}>{mensaje}</p>}

              <button onClick={handleSave} disabled={loading} style={{ ...btnStyle, width: '100%', maxWidth: '300px', cursor: loading ? 'not-allowed' : 'pointer' }}>
                {loading ? 'Guardando...' : 'Guardar Discord'}
              </button>
            </div>
          )}

          {/* --- MÓDULO: CORREOS (SMTP) --- */}
          {activeTab === 'email' && (
            <div style={{ animation: 'fadeIn 0.3s' }}>
              <h3 style={{ color: '#3498db', marginTop: 0 }}>📧 Servidor de Correos (SMTP)</h3>
              <p style={{ color: '#a0aec0', fontSize: '14px', marginBottom: '25px' }}>
                Configura aquí el servidor de correos para enviar códigos de verificación, recuperación de contraseñas y notificaciones.
              </p>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', marginBottom: '15px' }}>
                <div>
                  <label style={labelStyle}>Host SMTP (Servidor)</label>
                  <input type="text" name="smtp_host" value={smtpConfig.smtp_host || ''} onChange={handleSmtpChange} placeholder="Ej: smtp.gmail.com" style={inputStyle} />
                </div>
                <div>
                  <label style={labelStyle}>Puerto SMTP</label>
                  <input type="number" name="smtp_port" value={smtpConfig.smtp_port || ''} onChange={handleSmtpChange} placeholder="587" style={inputStyle} />
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', marginBottom: '15px' }}>
                <div>
                  <label style={labelStyle}>Usuario SMTP (Correo)</label>
                  <input type="text" name="smtp_user" value={smtpConfig.smtp_user || ''} onChange={handleSmtpChange} placeholder="tucorreo@gmail.com" style={inputStyle} />
                </div>
                <div>
                  <label style={labelStyle}>Contraseña SMTP</label>
                  <input type="password" name="smtp_pass" value={smtpConfig.smtp_pass || ''} onChange={handleSmtpChange} placeholder="••••••••••••" style={inputStyle} />
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', marginBottom: '15px' }}>
                <div>
                  <label style={labelStyle}>Correo Remitente (From Email)</label>
                  <input type="text" name="smtp_from_email" value={smtpConfig.smtp_from_email || ''} onChange={handleSmtpChange} placeholder="noreply@royalbet.com" style={inputStyle} />
                </div>
                <div>
                  <label style={labelStyle}>Nombre Remitente (From Name)</label>
                  <input type="text" name="smtp_from_name" value={smtpConfig.smtp_from_name || ''} onChange={handleSmtpChange} placeholder="RoyalBET" style={inputStyle} />
                </div>
              </div>

              <div style={{ marginBottom: '25px', display: 'flex', alignItems: 'center', gap: '10px' }}>
                <input type="checkbox" name="smtp_secure" checked={smtpConfig.smtp_secure || false} onChange={handleSmtpChange} style={{ width: '20px', height: '20px', cursor: 'pointer' }} />
                <label style={{ color: '#ccc', fontSize: '14px', cursor: 'pointer' }}>Usar conexión segura (SSL/TLS)</label>
              </div>

              {smtpMensaje && <p style={{ color: smtpMensaje.includes('✅') ? '#00e676' : '#ef4444', fontSize: '14px', marginBottom: '15px' }}>{smtpMensaje}</p>}

              <button onClick={handleSaveSmtp} disabled={smtpLoading} style={{ ...btnStyle, width: '100%', maxWidth: '300px', marginBottom: '30px', cursor: smtpLoading ? 'not-allowed' : 'pointer' }}>
                {smtpLoading ? 'Guardando...' : 'Guardar Configuración SMTP'}
              </button>

              <hr style={{ borderColor: '#333', marginBottom: '30px' }} />

              <h4 style={{ color: '#fff', marginTop: 0, marginBottom: '15px' }}>Probar Envío de Correo</h4>
              <p style={{ color: '#a0aec0', fontSize: '13px', marginBottom: '15px' }}>Guarda la configuración primero, luego envía un correo de prueba.</p>
              
              <div style={{ display: 'flex', gap: '10px', maxWidth: '500px' }}>
                <input type="email" value={testEmail} onChange={(e) => setTestEmail(e.target.value)} placeholder="Tu correo de prueba" style={inputStyle} />
                <button onClick={handleTestSmtp} disabled={testLoading} style={{ ...btnStyle, background: '#3498db', color: '#fff', whiteSpace: 'nowrap', cursor: testLoading ? 'not-allowed' : 'pointer' }}>
                  {testLoading ? 'Enviando...' : 'Enviar Prueba'}
                </button>
              </div>
              {testMensaje && <p style={{ color: testMensaje.includes('✅') ? '#00e676' : '#ef4444', fontSize: '14px', marginTop: '15px' }}>{testMensaje}</p>}
            </div>
          )}

          {/* --- MÓDULO: ANUNCIOS GLOBALES --- */}
          {activeTab === 'announcements' && (
            <div style={{ animation: 'fadeIn 0.3s' }}>
              <h3 style={{ color: '#f39c12', marginTop: 0 }}>📢 Enviar Anuncio Global</h3>
              <p style={{ color: '#a0aec0', fontSize: '14px', marginBottom: '25px', lineHeight: '1.5' }}>
                Envía un mensaje a todos los usuarios registrados. Puedes elegir que les llegue a su buzón en la web, por correo electrónico, o ambos.
              </p>

              <div style={{ marginBottom: '15px' }}>
                <label style={labelStyle}>Título del Anuncio</label>
                <input 
                  type="text" 
                  value={announcementData.title} 
                  onChange={e => setAnnouncementData({...announcementData, title: e.target.value})} 
                  placeholder="Ej: Mantenimiento programado" 
                  style={inputStyle} 
                />
              </div>

              <div style={{ marginBottom: '15px' }}>
                <label style={labelStyle}>Mensaje del Anuncio</label>
                <textarea 
                  value={announcementData.message} 
                  onChange={e => setAnnouncementData({...announcementData, message: e.target.value})} 
                  placeholder="Escribe aquí el contenido del anuncio..." 
                  rows="5" 
                  style={{...inputStyle, resize: 'vertical'}} 
                />
              </div>

              <div style={{ marginBottom: '25px', display: 'flex', gap: '20px', flexWrap: 'wrap' }}>
                <label style={{ color: '#ccc', fontSize: '14px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <input 
                    type="checkbox" 
                    checked={announcementData.sendToWeb} 
                    onChange={e => setAnnouncementData({...announcementData, sendToWeb: e.target.checked})} 
                    style={{ width: '18px', height: '18px', cursor: 'pointer' }} 
                  />
                  Enviar al Buzón Web
                </label>
                <label style={{ color: '#ccc', fontSize: '14px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <input 
                    type="checkbox" 
                    checked={announcementData.sendToEmail} 
                    onChange={e => setAnnouncementData({...announcementData, sendToEmail: e.target.checked})} 
                    style={{ width: '18px', height: '18px', cursor: 'pointer' }} 
                  />
                  Enviar por Correo Electrónico
                </label>
              </div>

              {announcementMsg && <p style={{ color: announcementMsg.includes('✅') ? '#00e676' : '#ef4444', fontSize: '14px', marginBottom: '15px' }}>{announcementMsg}</p>}

              <button onClick={handleSendAnnouncement} disabled={announcementLoading} style={{ ...btnStyle, background: '#f39c12', width: '100%', maxWidth: '300px', cursor: announcementLoading ? 'not-allowed' : 'pointer' }}>
                {announcementLoading ? 'Enviando...' : 'Enviar Anuncio a Todos'}
              </button>
            </div>
          )}

          {/* --- MÓDULO: PAGOS (Placeholder) --- */}
          {activeTab === 'payments' && (
            <div>
              <h3 style={{ color: '#e2b04a', marginTop: 0 }}>💳 Pasarelas de Pago</h3>
              <p style={{ color: '#a0aec0', fontSize: '14px' }}>Aquí podrás configurar las integraciones con Stripe, PayPal, criptomonedas, etc.</p>
              <div style={{ marginTop: '20px', padding: '20px', border: '1px dashed #444', borderRadius: '8px', textAlign: 'center', color: '#666' }}>
                🚧 En construcción...
              </div>
            </div>
          )}

          {/* --- MÓDULO: API (Placeholder) --- */}
          {activeTab === 'api' && (
            <div>
              <h3 style={{ color: '#e74c3c', marginTop: 0 }}>🔑 API Keys de Seguridad</h3>
              <p style={{ color: '#a0aec0', fontSize: '14px' }}>Genera y gestiona las claves de acceso para servicios externos.</p>
              <div style={{ marginTop: '20px', padding: '20px', border: '1px dashed #444', borderRadius: '8px', textAlign: 'center', color: '#666' }}>
                🚧 En construcción...
              </div>
            </div>
          )}

        </div>
      </div>
    </main>
  );
};

export default ServerConfig;