import { useState } from 'react';
import { API_URL } from './config'; // ?? IMPORTAMOS LA URL DIN¨¢MICA

const Icons = {
  Discord: () => <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M20.317 4.3698a19.7913 19.7913 0 00-4.8851-1.5152.0741.0741 0 00-.0785.0371c-.211.3753-.4447.8648-.6083 1.2495-1.8447-.2762-3.68-.2762-5.4868 0-.1636-.3933-.4058-.8742-.6177-1.2495a.077.077 0 00-.0785-.037 19.7363 19.7363 0 00-4.8852 1.515.0699.0699 0 00-.0321.0277C.5334 9.0458-.319 13.5799.0992 18.0578a.0824.0824 0 00.0312.0561c2.0528 1.5076 4.0413 2.4228 5.9929 3.0294a.0777.0777 0 00.0842-.0276c.4616-.6304.8731-1.2952 1.226-1.9942a.076.076 0 00-.0416-.1057c-.6528-.2476-1.2743-.5495-1.8722-.8923a.077.077 0 01-.0076-.1277c.1258-.0943.2517-.1923.3718-.2914a.0743.0743 0 01.0776-.0105c3.9278 1.7933 8.18 1.7933 12.0614 0a.0739.0739 0 01.0785.0095c.1202.099.246.1981.3728.2924a.077.077 0 01-.0066.1276 12.2986 12.2986 0 01-1.873.8914.0766.0766 0 00-.0407.1067c.3604.698.7719 1.3628 1.225 1.9932a.076.076 0 00.0842.0286c1.961-.6067 3.9495-1.5219 6.0023-3.0294a.077.077 0 00.0313-.0552c.5004-5.177-.8382-9.6739-3.5485-13.6604a.061.061 0 00-.0312-.0286zM8.02 15.3312c-1.1825 0-2.1569-1.0857-2.1569-2.419 0-1.3332.9555-2.4189 2.157-2.4189 1.2108 0 2.1757 1.0952 2.1568 2.419 0 1.3332-.9555 2.4189-2.1569 2.4189zm7.9748 0c-1.1825 0-2.1569-1.0857-2.1569-2.419 0-1.3332.9554-2.4189 2.1569-2.4189 1.2108 0 2.1757 1.0952 2.1568 2.419 0 1.3332-.946 2.4189-2.1568 2.4189Z"/></svg>
};

export default function Login({ onLoginSuccess, referralCode }) {
  const [isLogin, setIsLogin] = useState(true);
  const [loginMethod, setLoginMethod] = useState('username'); 
  const [identifier, setIdentifier] = useState(''); 
  const [usernameExtra, setUsernameExtra] = useState(''); 
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [successMsg, setSuccessMsg] = useState('');
  const [loading, setLoading] = useState(false);

  // Estados para Verificaci¨®n por IP
  const [requiresVerification, setRequiresVerification] = useState(false);
  const [verificationCode, setVerificationCode] = useState('');
  const [verificationEmail, setVerificationEmail] = useState('');
  const [verifyLoading, setVerifyLoading] = useState(false);
  const [verifyError, setVerifyError] = useState('');

  // ?? NUEVOS ESTADOS PARA CORREO OBLIGATORIO
  const [requiresEmail, setRequiresEmail] = useState(false);
  const [emailToSet, setEmailToSet] = useState('');
  const [tempToken, setTempToken] = useState('');
  const [emailLoading, setEmailLoading] = useState(false);
  const [emailError, setEmailError] = useState('');

  // ?? NUEVOS ESTADOS (Paso 4.4): Recuperaci¨®n de contrase?a
  const [forgotStep, setForgotStep] = useState(0); // 0 = no activo, 1 = pedir c¨®digo, 2 = resetear
  const [forgotIdentifier, setForgotIdentifier] = useState('');
  const [forgotCode, setForgotCode] = useState('');
  const [forgotNewPassword, setForgotNewPassword] = useState('');
  const [forgotConfirmPassword, setForgotConfirmPassword] = useState('');
  const [forgotLoading, setForgotLoading] = useState(false);
  const [forgotError, setForgotError] = useState('');
  const [forgotSuccess, setForgotSuccess] = useState('');
  const [forgotMaskedEmail, setForgotMaskedEmail] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccessMsg('');
    setLoading(true);
    
    // ?? USAMOS API_URL DIN¨¢MICA
    let url = isLogin ? `${API_URL}/api/login` : `${API_URL}/api/register`;
    let body = isLogin 
      ? { identifier, password } 
      : { 
          username: loginMethod === 'username' ? identifier : usernameExtra, 
          email: loginMethod === 'email' ? identifier : null, 
          phone: loginMethod === 'phone' ? identifier : null, 
          password, 
          referred_by: referralCode 
        };

    try {
      const response = await fetch(url, { 
        method: 'POST', 
        headers: { 'Content-Type': 'application/json' }, 
        body: JSON.stringify(body) 
      });
      
      const data = await response.json();
      
      // ?? SI EL BACKEND PIDE CORREO OBLIGATORIO
      if (isLogin && data.requires_email) {
        setRequiresEmail(true);
        setTempToken(data.temp_token);
        setSuccessMsg(data.message);
        setLoading(false);
        return;
      }

      // ?? SI EL BACKEND PIDE VERIFICACI¨®N POR IP
      if (isLogin && data.requires_verification) {
        setRequiresVerification(true);
        setVerificationEmail(data.email || 'tu correo electr¨®nico');
        setSuccessMsg(data.message || 'Hemos enviado un c¨®digo de verificaci¨®n a tu correo.');
        setLoading(false);
        return;
      }

      if (!response.ok) throw new Error(data.error || 'Error en el servidor');

      if (isLogin) {
        // LLAMAMOS A LA FUNCION QUE NOS PASA APP.JSX PARA GUARDAR LA SESION
        onLoginSuccess(data.user, data.token);
      } else {
        // ?? MODIFICADO: Se quit¨® el mensaje de las 2000 fichas
        setSuccessMsg('Registrado con exito! Ahora inicia sesion.');
        setIsLogin(true);
        setPassword(''); // Limpiamos la contrasena por seguridad
      }
    } catch (err) { 
      setError(err.message); 
    } finally {
      setLoading(false);
    }
  };

  // ?? FUNCION PARA GUARDAR EL CORREO OBLIGATORIO
  const handleSetEmail = async (e) => {
    e.preventDefault();
    setEmailError('');
    setEmailLoading(true);

    try {
      const response = await fetch(`${API_URL}/api/auth/set-email`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: emailToSet, temp_token: tempToken })
      });

      const data = await response.json();
      if (!response.ok) throw new Error(data.error || 'Error al guardar el correo');

      // Si se guarda bien, entramos directamente
      onLoginSuccess(data.user, data.token);
    } catch (err) {
      setEmailError(err.message);
    } finally {
      setEmailLoading(false);
    }
  };

  // ?? FUNCION PARA VERIFICAR EL C¨®DIGO DE LA IP
  const handleVerifyCode = async (e) => {
    e.preventDefault();
    setVerifyError('');
    setVerifyLoading(true);

    try {
      const response = await fetch(`${API_URL}/api/verify-login-code`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ identifier, code: verificationCode })
      });

      const data = await response.json();
      if (!response.ok) throw new Error(data.error || 'C¨®digo incorrecto');

      // Si el c¨®digo es v¨¢lido, entramos
      onLoginSuccess(data.user, data.token);

    } catch (err) {
      setVerifyError(err.message);
    } finally {
      setVerifyLoading(false);
    }
  };

  // ?? NUEVA (Paso 4.4): Solicitar c¨®digo de recuperaci¨®n
  const handleForgotRequest = async (e) => {
    e.preventDefault();
    setForgotError('');
    setForgotSuccess('');
    setForgotLoading(true);

    try {
      const response = await fetch(`${API_URL}/api/auth/forgot-password`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ identifier: forgotIdentifier })
      });

      const data = await response.json();
      if (!response.ok) throw new Error(data.error || 'Error al enviar el c¨®digo');

      setForgotSuccess(data.message || 'Si el usuario existe, recibir¨¢s un c¨®digo en breve.');
      setForgotMaskedEmail(data.email || '');
      setForgotStep(2);
    } catch (err) {
      setForgotError(err.message);
    } finally {
      setForgotLoading(false);
    }
  };

  // ?? NUEVA (Paso 4.4): Cambiar la contrase?a con el c¨®digo
  const handleForgotReset = async (e) => {
    e.preventDefault();
    setForgotError('');
    setForgotSuccess('');

    if (forgotNewPassword.length < 6) {
      setForgotError('La contrase?a debe tener al menos 6 caracteres');
      return;
    }
    if (forgotNewPassword !== forgotConfirmPassword) {
      setForgotError('Las contrase?as no coinciden');
      return;
    }

    setForgotLoading(true);
    try {
      const response = await fetch(`${API_URL}/api/auth/reset-password`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          identifier: forgotIdentifier,
          code: forgotCode,
          newPassword: forgotNewPassword
        })
      });

      const data = await response.json();
      if (!response.ok) throw new Error(data.error || 'Error al cambiar la contrase?a');

      setForgotSuccess(data.message || 'Contrase?a actualizada. Ya puedes iniciar sesi¨®n.');
      setTimeout(() => {
        setForgotStep(0);
        setForgotIdentifier('');
        setForgotCode('');
        setForgotNewPassword('');
        setForgotConfirmPassword('');
        setForgotError('');
        setForgotSuccess('');
        setForgotMaskedEmail('');
        setPassword('');
      }, 2500);
    } catch (err) {
      setForgotError(err.message);
    } finally {
      setForgotLoading(false);
    }
  };

  const handleCancel = () => {
    setRequiresVerification(false);
    setRequiresEmail(false);
    setVerificationCode('');
    setEmailToSet('');
    setVerifyError('');
    setEmailError('');
    setSuccessMsg('');
    setError('');
  };

  return (
    <div className="app-container">
      <div className="login-card">
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', marginBottom: '1.5rem' }}>
          <img src="/logo.png" alt="Logo" style={{ height: '90px', width: '90px', objectFit: 'cover', borderRadius: '50%', border: '3px solid #00e676', marginBottom: '10px' }} />
          <h2 style={{ color: '#00e676', fontWeight: '800', fontSize: '1.8rem' }}>RoyalBET</h2>
        </div>
        
        {/* ?? RENDERIZADO CONDICIONAL: CORREO OBLIGATORIO, VERIFICACI¨®N, RECUPERACI¨®N O LOGIN NORMAL */}
        {requiresEmail ? (
          <div style={{ animation: 'fadeIn 0.3s' }}>
            <h1 className="login-title">Configura tu Correo</h1>
            <p style={{ color: '#a0aec0', textAlign: 'center', marginBottom: '1.5rem', fontSize: '0.9rem', lineHeight: '1.5' }}>
              Para proteger tu cuenta y permitirte iniciar sesi¨®n si cambias de red (IP), es <b>obligatorio</b> que tengas un correo registrado.
            </p>

            {emailError && <p style={{ color: '#ef4444', textAlign: 'center', marginBottom: '1rem', background: '#2d1b1b', padding: '10px', borderRadius: '6px' }}>{emailError}</p>}
            {successMsg && <p style={{ color: '#00e676', textAlign: 'center', marginBottom: '1rem', background: '#1b2d1b', padding: '10px', borderRadius: '6px', fontSize: '0.9rem' }}>{successMsg}</p>}

            <form onSubmit={handleSetEmail}>
              <div style={{ background: '#0b0e14', padding: '15px', borderRadius: '8px', border: '1px solid #2d3748', marginBottom: '20px' }}>
                <label style={{ color: '#e2b04a', fontSize: '0.85rem', fontWeight: 'bold', display: 'block', textAlign: 'center', marginBottom: '10px' }}>
                  Ingresa tu correo electr¨®nico
                </label>
                <input 
                  type="email" 
                  value={emailToSet} 
                  onChange={e => setEmailToSet(e.target.value)} 
                  required 
                  placeholder="ejemplo@correo.com" 
                  style={{ 
                    width: '100%', padding: '12px', 
                    background: '#121212', border: '1px solid #e2b04a', 
                    color: '#fff', borderRadius: '8px', 
                    fontSize: '1rem'
                  }} 
                />
              </div>

              <div style={{ display: 'flex', gap: '10px' }}>
                <button type="button" onClick={handleCancel} className="btn" style={{ flex: 1, background: '#2d3748', color: '#fff' }}>
                  Cancelar
                </button>
                <button type="submit" className="btn" disabled={emailLoading || !emailToSet} style={{ flex: 1, background: '#00e676', color: '#000' }}>
                  {emailLoading ? 'Guardando...' : 'Guardar Correo'}
                </button>
              </div>
            </form>
          </div>
        ) : requiresVerification ? (
          <div style={{ animation: 'fadeIn 0.3s' }}>
            <h1 className="login-title">Verificaci¨®n de Seguridad</h1>
            <p style={{ color: '#a0aec0', textAlign: 'center', marginBottom: '1.5rem', fontSize: '0.9rem', lineHeight: '1.5' }}>
              Hemos detectado un inicio de sesi¨®n desde una ubicaci¨®n desconocida. <br/>
              Ingresa el c¨®digo enviado a: <br/>
              <strong style={{ color: '#e2b04a' }}>{verificationEmail}</strong>
            </p>

            {verifyError && <p style={{ color: '#ef4444', textAlign: 'center', marginBottom: '1rem', background: '#2d1b1b', padding: '10px', borderRadius: '6px' }}>{verifyError}</p>}
            {successMsg && <p style={{ color: '#00e676', textAlign: 'center', marginBottom: '1rem', background: '#1b2d1b', padding: '10px', borderRadius: '6px', fontSize: '0.9rem' }}>{successMsg}</p>}

            <form onSubmit={handleVerifyCode}>
              <div style={{ background: '#0b0e14', padding: '15px', borderRadius: '8px', border: '1px solid #2d3748', marginBottom: '20px' }}>
                <label style={{ color: '#e2b04a', fontSize: '0.85rem', fontWeight: 'bold', display: 'block', textAlign: 'center', marginBottom: '10px' }}>
                  Ingresa tu c¨®digo de 6 d¨ªgitos
                </label>
                <input 
                  type="text" 
                  value={verificationCode} 
                  onChange={e => setVerificationCode(e.target.value.replace(/\D/g, ''))} 
                  required 
                  placeholder="******" 
                  maxLength="6" 
                  style={{ 
                    width: '100%', padding: '12px', 
                    background: '#121212', border: '1px solid #e2b04a', 
                    color: '#fff', borderRadius: '8px', 
                    textAlign: 'center', letterSpacing: '8px', fontSize: '1.5rem', fontWeight: 'bold'
                  }} 
                />
              </div>

              <div style={{ display: 'flex', gap: '10px' }}>
                <button type="button" onClick={handleCancel} className="btn" style={{ flex: 1, background: '#2d3748', color: '#fff' }}>
                  Cancelar
                </button>
                <button type="submit" className="btn" disabled={verifyLoading || verificationCode.length < 6} style={{ flex: 1, background: '#00e676', color: '#000' }}>
                  {verifyLoading ? 'Verificando...' : 'Verificar C¨®digo'}
                </button>
              </div>
            </form>
          </div>
        ) : forgotStep === 1 ? (
          <div style={{ animation: 'fadeIn 0.3s' }}>
            <h1 className="login-title">Recuperar Contrase?a</h1>
            <p style={{ color: '#a0aec0', textAlign: 'center', marginBottom: '1.5rem', fontSize: '0.9rem', lineHeight: '1.5' }}>
              Ingresa tu usuario o correo y te enviaremos un c¨®digo para restablecer tu contrase?a.
            </p>

            {forgotError && <p style={{ color: '#ef4444', textAlign: 'center', marginBottom: '1rem', background: '#2d1b1b', padding: '10px', borderRadius: '6px' }}>{forgotError}</p>}

            <form onSubmit={handleForgotRequest}>
              <div style={{ background: '#0b0e14', padding: '15px', borderRadius: '8px', border: '1px solid #2d3748', marginBottom: '20px' }}>
                <label style={{ color: '#e2b04a', fontSize: '0.85rem', fontWeight: 'bold', display: 'block', marginBottom: '10px' }}>
                  Usuario o correo registrado
                </label>
                <input 
                  type="text" 
                  value={forgotIdentifier} 
                  onChange={e => setForgotIdentifier(e.target.value)} 
                  required 
                  placeholder="Ej: Alejandro o correo@ejemplo.com" 
                  style={{ 
                    width: '100%', padding: '12px', 
                    background: '#121212', border: '1px solid #e2b04a', 
                    color: '#fff', borderRadius: '8px', fontSize: '1rem'
                  }} 
                />
              </div>

              <div style={{ display: 'flex', gap: '10px' }}>
                <button 
                  type="button" 
                  onClick={() => { setForgotStep(0); setForgotError(''); setForgotIdentifier(''); }} 
                  className="btn" 
                  style={{ flex: 1, background: '#2d3748', color: '#fff' }}
                >
                  Cancelar
                </button>
                <button 
                  type="submit" 
                  className="btn" 
                  disabled={forgotLoading || !forgotIdentifier} 
                  style={{ flex: 1, background: '#00e676', color: '#000' }}
                >
                  {forgotLoading ? 'Enviando...' : 'Enviar C¨®digo'}
                </button>
              </div>
            </form>
          </div>
        ) : forgotStep === 2 ? (
          <div style={{ animation: 'fadeIn 0.3s' }}>
            <h1 className="login-title">Nueva Contrase?a</h1>
            <p style={{ color: '#a0aec0', textAlign: 'center', marginBottom: '1.5rem', fontSize: '0.9rem', lineHeight: '1.5' }}>
              {forgotMaskedEmail ? (
                <>Hemos enviado un c¨®digo a <strong style={{ color: '#e2b04a' }}>{forgotMaskedEmail}</strong>.<br/></>
              ) : null}
              Ingr¨¦salo y define tu nueva contrase?a.
            </p>

            {forgotError && <p style={{ color: '#ef4444', textAlign: 'center', marginBottom: '1rem', background: '#2d1b1b', padding: '10px', borderRadius: '6px' }}>{forgotError}</p>}
            {forgotSuccess && <p style={{ color: '#00e676', textAlign: 'center', marginBottom: '1rem', background: '#1b2d1b', padding: '10px', borderRadius: '6px', fontSize: '0.9rem' }}>{forgotSuccess}</p>}

            <form onSubmit={handleForgotReset}>
              <div style={{ background: '#0b0e14', padding: '15px', borderRadius: '8px', border: '1px solid #2d3748', marginBottom: '15px' }}>
                <label style={{ color: '#e2b04a', fontSize: '0.85rem', fontWeight: 'bold', display: 'block', textAlign: 'center', marginBottom: '10px' }}>
                  C¨®digo de 6 d¨ªgitos
                </label>
                <input 
                  type="text" 
                  value={forgotCode} 
                  onChange={e => setForgotCode(e.target.value.replace(/\D/g, ''))} 
                  required 
                  placeholder="******" 
                  maxLength="6" 
                  style={{ 
                    width: '100%', padding: '12px', 
                    background: '#121212', border: '1px solid #e2b04a', 
                    color: '#fff', borderRadius: '8px', 
                    textAlign: 'center', letterSpacing: '8px', fontSize: '1.5rem', fontWeight: 'bold'
                  }} 
                />
              </div>

              <label style={{ color: '#a0aec0', fontSize: '0.85rem', display: 'block', marginBottom: '5px' }}>Nueva contrase?a</label>
              <input 
                type="password" 
                value={forgotNewPassword} 
                onChange={e => setForgotNewPassword(e.target.value)} 
                required 
                minLength={6}
                placeholder="M¨ªnimo 6 caracteres" 
                style={{ width: '100%', padding: '12px', marginBottom: '12px', background: '#0b0e14', border: '1px solid #2d3748', color: '#fff', borderRadius: '8px', fontSize: '1rem' }} 
              />

              <label style={{ color: '#a0aec0', fontSize: '0.85rem', display: 'block', marginBottom: '5px' }}>Confirmar contrase?a</label>
              <input 
                type="password" 
                value={forgotConfirmPassword} 
                onChange={e => setForgotConfirmPassword(e.target.value)} 
                required 
                minLength={6}
                placeholder="Repite la nueva contrase?a" 
                style={{ width: '100%', padding: '12px', marginBottom: '20px', background: '#0b0e14', border: '1px solid #2d3748', color: '#fff', borderRadius: '8px', fontSize: '1rem' }} 
              />

              <div style={{ display: 'flex', gap: '10px' }}>
                <button 
                  type="button" 
                  onClick={() => { setForgotStep(1); setForgotError(''); setForgotCode(''); setForgotNewPassword(''); setForgotConfirmPassword(''); }} 
                  className="btn" 
                  style={{ flex: 1, background: '#2d3748', color: '#fff' }}
                >
                  Atr¨¢s
                </button>
                <button 
                  type="submit" 
                  className="btn" 
                  disabled={forgotLoading || forgotCode.length < 6} 
                  style={{ flex: 1, background: '#00e676', color: '#000' }}
                >
                  {forgotLoading ? 'Guardando...' : 'Cambiar Contrase?a'}
                </button>
              </div>
            </form>
          </div>
        ) : (
          <div style={{ animation: 'fadeIn 0.3s' }}>
            <h1 className="login-title">{isLogin ? 'Iniciar Sesion' : 'Crear Cuenta'}</h1>
            
            <div className="tabs">
              <button type="button" className={`tab-btn ${loginMethod === 'phone' ? 'active' : ''}`} onClick={() => { setLoginMethod('phone'); setIdentifier(''); }}>Telefono</button>
              <button type="button" className={`tab-btn ${loginMethod === 'email' ? 'active' : ''}`} onClick={() => { setLoginMethod('email'); setIdentifier(''); }}>Correo</button>
              <button type="button" className={`tab-btn ${loginMethod === 'username' ? 'active' : ''}`} onClick={() => { setLoginMethod('username'); setIdentifier(''); }}>Usuario</button>
            </div>
            
            {error && <p style={{ color: '#ef4444', textAlign: 'center', marginBottom: '1rem', background: '#2d1b1b', padding: '10px', borderRadius: '6px' }}>{error}</p>}
            
            {/* MOSTRAR MENSAJE DE EXITO SI EXISTE */}
            {successMsg && <p style={{ color: '#00e676', textAlign: 'center', marginBottom: '1rem', background: '#1b2d1b', padding: '10px', borderRadius: '6px' }}>{successMsg}</p>}

            {!isLogin && referralCode && (<p style={{ color: '#00e676', textAlign: 'center', marginBottom: '1rem', fontSize: '0.9rem' }}>Te han invitado a RoyalBET!</p>)}

            <form onSubmit={handleSubmit}>
              <div className="input-group">
                <input type="text" placeholder="Usuario/Correo/Telefono" value={identifier} onChange={e => setIdentifier(e.target.value)} required />
              </div>
              {!isLogin && loginMethod !== 'username' && (
                <div className="input-group">
                  <input type="text" placeholder="Nombre de usuario" value={usernameExtra} onChange={e => setUsernameExtra(e.target.value)} required />
                </div>
              )}
              <div className="input-group">
                <input type="password" placeholder="Contrasena" value={password} onChange={e => setPassword(e.target.value)} required />
              </div>
              <button type="submit" className="btn" disabled={loading}>
                {loading ? 'Procesando...' : (isLogin ? 'Iniciar Sesion' : 'Registrarse')}
              </button>
            </form>

            {/* ?? NUEVO (Paso 4.4): Enlace de olvid¨¦ mi contrase?a */}
            {isLogin && (
              <p 
                style={{ textAlign: 'center', cursor: 'pointer', color: '#e2b04a', marginTop: '1rem', fontSize: '0.85rem', textDecoration: 'underline' }} 
                onClick={() => {
                  setForgotStep(1);
                  setForgotError('');
                  setForgotSuccess('');
                  setForgotIdentifier('');
                  setForgotCode('');
                  setForgotNewPassword('');
                  setForgotConfirmPassword('');
                  setForgotMaskedEmail('');
                }}
              >
                ?Olvidaste tu contrase?a?
              </p>
            )}
            
            <p style={{ textAlign: 'center', cursor: 'pointer', color: '#a0aec0', marginTop: '1.5rem', fontSize: '0.9rem' }} onClick={() => { setIsLogin(!isLogin); setError(''); setSuccessMsg(''); }}>
              {isLogin ? 'No tienes cuenta? Registrate' : 'Ya tienes cuenta? Inicia sesion'}
            </p>

            <div style={{ marginTop: '20px', borderTop: '1px solid #2d3748', paddingTop: '20px' }}>
              <p style={{ color: '#a0aec0', textAlign: 'center', marginBottom: '15px', fontSize: '0.9rem' }}>O ingresa directamente con tu cuenta</p>
              <button 
                type="button"
                // ?? USAMOS API_URL DIN¨¢MICA PARA DISCORD
                onClick={() => { window.location.href = `${API_URL}/api/auth/discord`; }}
                style={{ width: '100%', padding: '15px', background: '#5865F2', color: 'white', border: 'none', borderRadius: '8px', fontWeight: 'bold', fontSize: '16px', cursor: 'pointer', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '10px', transition: '0.3s' }}
              >
                <Icons.Discord /> Entrar con Discord
              </button>
            </div>
          </div>
        )}

      </div>
    </div>
  );
}