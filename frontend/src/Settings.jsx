import { useState, useEffect } from 'react';
import { setSoundPref } from './soundPrefs';

const Toggle = ({ active, onClick }) => (
  <div className={`toggle-switch ${active ? 'active' : ''}`} onClick={onClick}>
    <div className="toggle-circle"></div>
  </div>
);

export default function Settings({ settingsTab, setSettingsTab, settings, handleSettingChange, handleSaveSettings }) {
  // ============================================================
  // 🎵 VOLUMEN Y ANIMACIONES COMPARTIDOS CON PokerTable.jsx
  // (mismas claves localStorage: poker_volume y poker_animations)
  // ============================================================
  const [volume, setVolume] = useState(() => {
    try {
      const v = localStorage.getItem('poker_volume');
      return v !== null ? Number(v) : 0.7;
    } catch { return 0.7; }
  });

  const [animations, setAnimations] = useState(() => {
    try {
      const v = localStorage.getItem('poker_animations');
      return v !== null ? v === 'true' : true;
    } catch { return true; }
  });

  // 💾 Persistencia inmediata + aviso a las mesas abiertas (PokerTable se sincroniza al instante)
  useEffect(() => {
    setSoundPref('volume', volume);
  }, [volume]);

  useEffect(() => {
    try { localStorage.setItem('poker_animations', String(animations)); } catch {}
  }, [animations]);

  // 🎵 Reproducir sonido de prueba con el volumen actual
  const playTestSound = () => {
    try {
      const AC = window.AudioContext || window.webkitAudioContext;
      const ctx = new AC();
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'sine';
      osc.frequency.value = 880;
      gain.gain.setValueAtTime(0.0001, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(Math.max(volume * 0.1, 0.0001), ctx.currentTime + 0.02);
      gain.gain.exponentialRampToValueAtTime(0.0001, ctx.currentTime + 0.25);
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start();
      osc.stop(ctx.currentTime + 0.3);
      setTimeout(() => { try { ctx.close(); } catch {} }, 400);
    } catch {}
  };

  return (
    <main className="main-area">
      <div className="settings-container">
        <h1 className="settings-title">Ajustes</h1>
        <div className="settings-tabs">
          <span className={`settings-tab ${settingsTab === 'sonido' ? 'active' : ''}`} onClick={() => setSettingsTab('sonido')}>Sonido</span>
          <span className={`settings-tab ${settingsTab === 'anexo' ? 'active' : ''}`} onClick={() => setSettingsTab('anexo')}>Anexo</span>
          <span className={`settings-tab ${settingsTab === 'notificaciones' ? 'active' : ''}`} onClick={() => setSettingsTab('notificaciones')}>Notificaciones</span>
          <span className={`settings-tab ${settingsTab === 'tema' ? 'active' : ''}`} onClick={() => setSettingsTab('tema')}>Tema</span>
          <span className={`settings-tab ${settingsTab === 'bet' ? 'active' : ''}`} onClick={() => setSettingsTab('bet')}>Bet</span>
          <span className={`settings-tab ${settingsTab === 'teclas' ? 'active' : ''}`} onClick={() => setSettingsTab('teclas')}>Tecla de acceso rápido</span>
        </div>
        
        {settingsTab === 'sonido' && (
          <div className="settings-panel">
            <div className="setting-item">
              <div className="setting-item-label">Efectos sonoros</div>
              <Toggle active={settings.efectosSonoros} onClick={() => handleSettingChange('efectosSonoros', !settings.efectosSonoros)} />
            </div>

            {/* 🔥 NUEVO: Slider de volumen compartido con la mesa */}
            <div className="setting-item" style={{ flexDirection: 'column', alignItems: 'flex-start', opacity: settings.efectosSonoros ? 1 : 0.4, transition: 'opacity 0.2s' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', width: '100%', marginBottom: '0.8rem' }}>
                <div className="setting-item-label">🔉 Volumen de efectos</div>
                <span style={{ color: '#D4AF37', fontWeight: 'bold', fontSize: '0.95rem' }}>{Math.round(volume * 100)}%</span>
              </div>
              <div style={{ display: 'flex', gap: '10px', width: '100%', alignItems: 'center' }}>
                <input
                  type="range"
                  min={0}
                  max={1}
                  step={0.05}
                  value={volume}
                  disabled={!settings.efectosSonoros}
                  onChange={e => setVolume(Number(e.target.value))}
                  style={{ flex: 1, accentColor: '#D4AF37' }}
                />
                <button
                  onClick={playTestSound}
                  disabled={!settings.efectosSonoros}
                  style={{
                    padding: '6px 14px',
                    background: settings.efectosSonoros ? '#2d3748' : '#1a202c',
                    color: settings.efectosSonoros ? '#fff' : '#555',
                    border: 'none',
                    borderRadius: '6px',
                    cursor: settings.efectosSonoros ? 'pointer' : 'not-allowed',
                    fontSize: '0.8rem',
                    fontWeight: 'bold'
                  }}
                >
                  ▶ Probar
                </button>
              </div>
            </div>

            {/* 🔥 NUEVO: Toggle de animaciones compartido con la mesa */}
            <div className="setting-item">
              <div className="setting-item-label">✨ Animaciones de mesa</div>
              <Toggle active={animations} onClick={() => setAnimations(!animations)} />
            </div>

            <div className="setting-item"><div className="setting-item-label">Música de fondo</div><Toggle active={settings.musicaFondo} onClick={() => handleSettingChange('musicaFondo', !settings.musicaFondo)} /></div>
            <div className="setting-item"><div className="setting-item-label">Alertas multimesa</div><Toggle active={settings.alertasMultimesa} onClick={() => handleSettingChange('alertasMultimesa', !settings.alertasMultimesa)} /></div>
            <div className="setting-item"><div className="setting-item-label">Escuche solo la voz predeterminada</div><Toggle active={settings.escucharVoz} onClick={() => handleSettingChange('escucharVoz', !settings.escucharVoz)} /></div>
            <div className="setting-item" style={{ flexDirection: 'column', alignItems: 'flex-start' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', width: '100%', marginBottom: '1rem' }}><div className="setting-item-label">Voz</div><Toggle active={settings.voz} onClick={() => handleSettingChange('voz', !settings.voz)} /></div>
              {settings.voz && <div style={{ display: 'flex', gap: '10px' }}><div style={{ width: '80px', height: '100px', background: '#2d3748', borderRadius: '8px', border: '2px solid #00e676', position: 'relative', display: 'flex', alignItems: 'flex-end', justifyContent: 'center', paddingBottom: '10px' }}><span style={{ fontSize: '0.7rem', color: '#fff', fontWeight: 'bold' }}>Por Defecto</span><div style={{ position: 'absolute', top: '5px', left: '5px', background: '#00e676', color: '#000', borderRadius: '50%', width: '16px', height: '16px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '10px', fontWeight: 'bold' }}>✓</div></div></div>}
            </div>
            <div className="setting-item" style={{ borderTop: '1px solid #2d3748', marginTop: '1rem' }}><div className="setting-item-label">Choque <span>ⓘ</span></div><Toggle active={settings.choque} onClick={() => handleSettingChange('choque', !settings.choque)} /></div>
          </div>
        )}
        
        {settingsTab === 'anexo' && (
          <div className="settings-panel">
            <div className="setting-item"><div className="setting-item-label">Las manos más grandes están a la izquierda.</div><Toggle active={settings.manosIzquierda} onClick={() => handleSettingChange('manosIzquierda', !settings.manosIzquierda)} /></div>
            <div className="setting-item"><div className="setting-item-label">Localización De Instrucciones De Funcionamiento</div><Toggle active={settings.instrucciones} onClick={() => handleSettingChange('instrucciones', !settings.instrucciones)} /></div>
            <div className="setting-item"><div className="setting-item-label">Charla de espectadores <span>ⓘ</span></div><Toggle active={settings.charlaEspectadores} onClick={() => handleSettingChange('charlaEspectadores', !settings.charlaEspectadores)} /></div>
            <div className="setting-item"><div className="setting-item-label">FPS & Lag <span>ⓘ</span></div><Toggle active={settings.fpsLag} onClick={() => handleSettingChange('fpsLag', !settings.fpsLag)} /></div>
            <div className="setting-item"><div className="setting-item-label">Muestra de BB <span>ⓘ</span></div><Toggle active={settings.muestraBB} onClick={() => handleSettingChange('muestraBB', !settings.muestraBB)} /></div>
            <div className="setting-item" style={{ borderTop: '1px solid #2d3748', marginTop: '1rem' }}><div className="setting-item-label">Saludo automático <span>ⓘ</span></div><Toggle active={settings.saludoAuto} onClick={() => handleSettingChange('saludoAuto', !settings.saludoAuto)} /></div>
            <div className="setting-item"><div className="setting-item-label">Efectos de regalo</div><Toggle active={settings.efectosRegalo} onClick={() => handleSettingChange('efectosRegalo', !settings.efectosRegalo)} /></div>
            <div className="setting-item"><div className="setting-item-label">Accesorios interactivos y efectos especiales.</div><Toggle active={settings.accesorios} onClick={() => handleSettingChange('accesorios', !settings.accesorios)} /></div>
            <div className="setting-item" style={{ borderTop: '1px solid #2d3748', marginTop: '1rem', background: '#12161f', padding: '1rem', borderRadius: '8px', margin: '1rem' }}>
              <div className="setting-item-label">Idioma del sistema</div>
              <select className="settings-select" value={settings.idioma} onChange={e => handleSettingChange('idioma', e.target.value)}><option>Español</option><option>English</option><option>Português</option></select>
            </div>
          </div>
        )}
        
        {settingsTab === 'notificaciones' && (<div className="settings-panel"><div className="setting-item"><div className="setting-item-label">Notificaciones del navegador</div><Toggle active={settings.notificacionesNavegador} onClick={() => handleSettingChange('notificacionesNavegador', !settings.notificacionesNavegador)} /></div></div>)}
        
        {settingsTab === 'tema' && (
          <div className="settings-panel">
            <div className="theme-preview-grid">
              <div className="theme-preview-card"><p>Mesa de cartas</p><div className="theme-options"><div className="theme-circle" style={{ background: '#2d6a4f' }}></div><div className="theme-circle active" style={{ background: '#1a4731' }}></div><div className="theme-circle" style={{ background: '#4a3b2c' }}></div><div className="theme-circle" style={{ background: '#6b2d2d' }}></div><div className="theme-circle" style={{ background: '#4b5563' }}></div><div className="theme-circle" style={{ background: '#831843' }}></div></div></div>
              <div className="theme-preview-card" style={{ marginTop: '1rem' }}><p>Botón</p><div className="theme-options"><div className="theme-circle" style={{ background: '#ef4444', borderRadius: '8px' }}></div><div className="theme-circle" style={{ background: '#3b82f6', borderRadius: '8px' }}></div><div className="theme-circle" style={{ background: '#10b981', borderRadius: '8px' }}></div><div className="theme-circle" style={{ background: '#f59e0b', borderRadius: '8px' }}></div><div className="theme-circle active" style={{ background: '#e2e8f0', borderRadius: '8px', color: '#000', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '10px', fontWeight: 'bold' }}>Button</div></div></div>
              <div className="theme-preview-card" style={{ marginTop: '1rem' }}><p>Jugando a las cartas</p><div className="theme-options"><div className="theme-circle" style={{ background: '#fff', color: 'red', borderRadius: '4px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>♥</div><div className="theme-circle active" style={{ background: '#fff', color: 'black', borderRadius: '4px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>♠</div><div className="theme-circle" style={{ background: '#fff', color: 'blue', borderRadius: '4px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>♦</div><div className="theme-circle" style={{ background: '#1e3a8a', color: 'white', borderRadius: '4px', display: 'flex', alignItems: 'center', justifyContent: 'center', border: '2px solid #00e676' }}>BET</div></div></div>
            </div>
          </div>
        )}
        
        {settingsTab === 'bet' && (
          <>
            <div className="settings-panel" style={{ padding: '1.5rem' }}>
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(6, 1fr)', gap: '10px', marginBottom: '1.5rem' }}>{[1, 2, 3, 4, 5, 6].map(num => (<button key={num} style={{ background: '#2d3748', color: '#fff', border: '1px solid #4a5568', padding: '0.8rem', borderRadius: '8px', fontWeight: 'bold', cursor: 'pointer' }}>Btn {num}</button>))}</div>
              <div className="settings-slider-container" style={{ padding: 0 }}><button className="slider-btn">-</button><input type="range" min="0" max="100000" value={settings.betAmount} onChange={e => handleSettingChange('betAmount', e.target.value)} className="settings-slider" /><button className="slider-btn">+</button><input type="number" value={settings.betAmount} onChange={e => handleSettingChange('betAmount', e.target.value)} className="slider-input" /></div>
              <div className="setting-item" style={{ padding: '1rem 0', borderBottom: 'none', marginTop: '1rem' }}><div className="setting-item-label">Preferencia de apuesta de apertura <span>ⓘ</span></div><div style={{ display: 'flex', gap: '10px' }}>{['All in', '6BB', '5BB', '4BB', '3BB', 'All in'].map((opt, i) => (<select key={i} className="settings-select" style={{ minWidth: '70px' }}><option>{opt}</option></select>))}</div></div>
              <div className="setting-item" style={{ padding: '1rem 0', borderBottom: 'none' }}><div className="setting-item-label">Preferencia de apuesta estándar <span>ⓘ</span></div><div style={{ display: 'flex', gap: '10px' }}>{['All in', '33%', '50%', '75%', '80%', 'All in'].map((opt, i) => (<select key={i} className="settings-select" style={{ minWidth: '70px' }}><option>{opt}</option></select>))}</div></div>
            </div>
            <div className="settings-panel" style={{ padding: '1rem 1.5rem' }}><div className="setting-item" style={{ padding: 0, borderBottom: 'none' }}><div className="setting-item-label">No redondee al Blind más cercano</div><Toggle active={settings.noRedondear} onClick={() => handleSettingChange('noRedondear', !settings.noRedondear)} /></div></div>
          </>
        )}
        
        {settingsTab === 'teclas' && (
          <>
            <div className="settings-panel">
              <div className="setting-item"><div className="setting-item-label">Ratón</div><Toggle active={settings.usarRaton} onClick={() => handleSettingChange('usarRaton', !settings.usarRaton)} /></div>
              <div className="setting-item"><div className="setting-item-label">Teclado</div><Toggle active={settings.usarTeclado} onClick={() => handleSettingChange('usarTeclado', !settings.usarTeclado)} /></div>
              <div className="setting-item" style={{ padding: '1rem 1.5rem' }}><div className="setting-item-label">Preguntar al usar "Enter" para apostar</div><div style={{ display: 'flex', gap: '20px' }}><label style={{ display: 'flex', alignItems: 'center', gap: '8px', color: '#e2e8f0', fontSize: '0.9rem', cursor: 'pointer' }}><input type="radio" checked={settings.confirmarEnter} onChange={() => handleSettingChange('confirmarEnter', true)} /> Confirmar siempre</label><label style={{ display: 'flex', alignItems: 'center', gap: '8px', color: '#e2e8f0', fontSize: '0.9rem', cursor: 'pointer' }}><input type="radio" checked={!settings.confirmarEnter} onChange={() => handleSettingChange('confirmarEnter', false)} /> No confirmar nunca</label></div></div>
            </div>
            <div className="settings-panel" style={{ padding: '1.5rem' }}>
              <div style={{ display: 'grid', gridTemplateColumns: '200px 1fr', gap: '15px', alignItems: 'center' }}>
                <div style={{ color: '#a0aec0', fontSize: '0.9rem' }}>Botón de preajuste (izquierda)</div><input type="text" className="settings-input" placeholder="Tecla de acceso rápido..." />
                <div style={{ color: '#a0aec0', fontSize: '0.9rem' }}>Botón de preajuste (derecha)</div><input type="text" className="settings-input" placeholder="Tecla de acceso rápido..." />
                <div style={{ color: '#a0aec0', fontSize: '0.9rem' }}>Botón de acción (izquierda)</div><div style={{ display: 'flex', gap: '5px' }}><span style={{ background: '#0b0e14', border: '1px solid #232836', color: '#fff', padding: '5px 15px', borderRadius: '6px' }}>F1</span><button className="slider-btn" style={{ width: '32px', height: '32px' }}>x</button></div>
                <div style={{ color: '#a0aec0', fontSize: '0.9rem' }}>Botón de acción (centro)</div><div style={{ display: 'flex', gap: '5px' }}><span style={{ background: '#0b0e14', border: '1px solid #232836', color: '#fff', padding: '5px 15px', borderRadius: '6px' }}>F2</span><button className="slider-btn" style={{ width: '32px', height: '32px' }}>x</button></div>
                <div style={{ color: '#a0aec0', fontSize: '0.9rem' }}>Botón de acción (derecha)</div><div style={{ display: 'flex', gap: '5px' }}><span style={{ background: '#0b0e14', border: '1px solid #232836', color: '#fff', padding: '5px 15px', borderRadius: '6px' }}>F3</span><button className="slider-btn" style={{ width: '32px', height: '32px' }}>x</button></div>
                <div style={{ color: '#a0aec0', fontSize: '0.9rem' }}>setting_ChooseAmount1</div><div style={{ display: 'flex', gap: '5px' }}><span style={{ background: '#0b0e14', border: '1px solid #232836', color: '#fff', padding: '5px 15px', borderRadius: '6px' }}>Control + 1</span><button className="slider-btn" style={{ width: '32px', height: '32px' }}>x</button></div>
                <div style={{ color: '#a0aec0', fontSize: '0.9rem' }}>Seleccione el monto de la apuesta (izquierda 2)</div><div style={{ display: 'flex', gap: '5px' }}><span style={{ background: '#0b0e14', border: '1px solid #232836', color: '#fff', padding: '5px 15px', borderRadius: '6px' }}>Control + 2</span><button className="slider-btn" style={{ width: '32px', height: '32px' }}>x</button></div>
                <div style={{ color: '#a0aec0', fontSize: '0.9rem' }}>Seleccione el monto de la apuesta (derecha 2)</div><div style={{ display: 'flex', gap: '5px' }}><span style={{ background: '#0b0e14', border: '1px solid #232836', color: '#fff', padding: '5px 15px', borderRadius: '6px' }}>Control + 3</span><button className="slider-btn" style={{ width: '32px', height: '32px' }}>x</button></div>
                <div style={{ color: '#a0aec0', fontSize: '0.9rem' }}>Seleccione el monto de la apuesta (derecha 1)</div><div style={{ display: 'flex', gap: '5px' }}><span style={{ background: '#0b0e14', border: '1px solid #232836', color: '#fff', padding: '5px 15px', borderRadius: '6px' }}>Control + 4</span><button className="slider-btn" style={{ width: '32px', height: '32px' }}>x</button></div>
              </div>
            </div>
            <div className="settings-panel" style={{ padding: '1rem 1.5rem' }}><div className="setting-item" style={{ padding: 0, borderBottom: 'none' }}><div className="setting-item-label">Funciones</div><Toggle active={settings.funciones} onClick={() => handleSettingChange('funciones', !settings.funciones)} /></div></div>
          </>
        )}
        
        <div className="settings-actions">
          <button className="btn-reset" onClick={() => { if(window.confirm('¿Restablecer todos los ajustes?')) { localStorage.removeItem('royalbet_settings'); localStorage.removeItem('poker_volume'); localStorage.removeItem('poker_animations'); window.location.reload(); } }}>Reajustar</button>
          <button className="btn-save" onClick={handleSaveSettings}>Ahorrar</button>
        </div>
      </div>
    </main>
  );
}