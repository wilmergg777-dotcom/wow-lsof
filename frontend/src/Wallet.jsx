import { useState, useEffect } from 'react';
import { API_URL } from './config'; // ?? IMPORTAMOS LA URL DIN¨¢MICA

// COMPONENTE DE NOTIFICACION LOCAL (Corregido)
const LocalToast = ({ message, type, onClose }) => {
  useEffect(() => {
    const timer = setTimeout(onClose, 3000);
    return () => clearTimeout(timer);
  }, []); 

  let bgColor = '#1a202c';
  let borderColor = '#4a5568';
  let icon = 'INFO';

  if (type === 'success') {
    bgColor = 'linear-gradient(90deg, #00e676 0%, #009956 100%)';
    borderColor = '#00e676';
    icon = 'OK';
  } else if (type === 'error') {
    bgColor = 'linear-gradient(90deg, #ef4444 0%, #991b1b 100%)';
    borderColor = '#ef4444';
    icon = 'X';
  }

  return (
    <div style={{
      position: 'fixed', top: '20px', left: '50%', transform: 'translateX(-50%)',
      background: bgColor, color: '#fff', padding: '12px 24px', borderRadius: '8px',
      border: `1px solid ${borderColor}`, boxShadow: '0 10px 25px rgba(0,0,0,0.5)',
      zIndex: 9999, display: 'flex', alignItems: 'center', gap: '10px', fontWeight: 'bold',
      animation: 'slideDown 0.3s ease-out'
    }}>
      <span>{icon}</span>
      <span>{message}</span>
    </div>
  );
};

const Icons = {
  Receive: () => <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3"/></svg>,
  Send: () => <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M17 8l-5-5-5 5M12 3v12"/></svg>,
  Transfer: () => <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M17 1l4 4-4 4"/><path d="M3 11V9a4 4 0 0 1 4-4h14"/><path d="M7 23l-4-4 4-4"/><path d="M21 13v2a4 4 0 0 1-4 4H3"/></svg>,
  History: () => <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>,
  Globe: () => <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="#00e676" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>,
  ChevronDown: () => <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="#a0aec0" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="6 9 12 15 18 9"/></svg>,
  Search: () => <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="#718096" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
};

export default function Wallet({ balance, user, fetchBalance, onBack }) {
  const [modal, setModal] = useState(null);
  const [showNetworkDropdown, setShowNetworkDropdown] = useState(false);
  
  const [toast, setToast] = useState(null);

  const showToast = (message, type = 'success') => {
    setToast({ message, type });
  };

  // ?? NUEVO ESTADO: Controla si los botones se ven o no
  const [systemStatus, setSystemStatus] = useState({ 
    retiros_activos: true, 
    inversiones_activas: true 
  });

  const [amount, setAmount] = useState('');
  const [recipient, setRecipient] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const [receiveStep, setReceiveStep] = useState(1);
  const [adminDetails, setAdminDetails] = useState(null);
  const [depositAmount, setDepositAmount] = useState('');
  const [transactionId, setTransactionId] = useState('');

  const [withdrawAmount, setWithdrawAmount] = useState('');
  const [pinInput, setPinInput] = useState('');

  // ?? NUEVOS ESTADOS: Doble Verificaci¨®n de Retiros (PIN + C¨®digo por correo)
  const [withdrawStep, setWithdrawStep] = useState('form'); // 'form' | 'verify_code'
  const [withdrawCode, setWithdrawCode] = useState('');
  const [withdrawPayload, setWithdrawPayload] = useState(null);

  // ?? NUEVOS ESTADOS: Flujo de Transferencia de 3 Pasos (ID ¡ú Monto+PIN ¡ú C¨®digo Correo)
  const [transferStep, setTransferStep] = useState(1); // 1: Buscar ID, 2: Monto y PIN, 3: C¨®digo Correo
  const [searchId, setSearchId] = useState('');
  const [transferTarget, setTransferTarget] = useState(null); // { username, avatar_url, unique_id }
  const [transferAmount, setTransferAmount] = useState('');
  const [transferPin, setTransferPin] = useState('');
  const [transferCode, setTransferCode] = useState('');
  const [isSearching, setIsSearching] = useState(false);

  const [userBankData, setUserBankData] = useState(null);
  const [bankForm, setBankForm] = useState({ card_number: '', phone: '', holder_name: '', bank_name: '' });

  const [history, setHistory] = useState([]);
  const [historyLoading, setHistoryLoading] = useState(false);
  const [historyFilter, setHistoryFilter] = useState('');

  // ?? NUEVO useEffect: Consultar si el admin apag¨® los sistemas
  useEffect(() => {
    const fetchSystemStatus = async () => {
      try {
        const res = await fetch(`${API_URL}/api/wallet/system-status`, {
          headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
        });
        if (res.ok) {
          const data = await res.json();
          setSystemStatus(data);
        }
      } catch (err) {
        console.error("Error al obtener el estado de los sistemas", err);
      }
    };
    fetchSystemStatus();
  }, []);

  useEffect(() => {
    // ?? USAMOS API_URL DIN¨¢MICA
    fetch(`${API_URL}/api/user/bank-data`, {
      headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
    })
    .then(res => {
      if (res.ok) return res.json();
      return null;
    })
    .then(data => {
      if (data) {
        setUserBankData(data);
        setBankForm(data);
      } else {
        setModal('register_bank_data');
      }
    })
    .catch(err => console.error(err));
  }, []);

  useEffect(() => {
    if (modal === 'recibir') {
      // ?? USAMOS API_URL DIN¨¢MICA
      fetch(`${API_URL}/api/wallet/admin-details`, {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      })
      .then(res => res.json())
      .then(data => setAdminDetails(data))
      .catch(err => console.error(err));
    } else if (modal === 'historial') {
      setHistoryLoading(true);
      // ?? USAMOS API_URL DIN¨¢MICA
      fetch(`${API_URL}/api/wallet/history`, {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      })
      .then(res => res.json())
      .then(data => {
        if (Array.isArray(data)) setHistory(data);
        setHistoryLoading(false);
      })
      .catch(err => {
        console.error(err);
        setHistoryLoading(false);
      });
    } else {
      if (modal !== 'register_bank_data') {
        setReceiveStep(1);
        setDepositAmount('');
        setTransactionId('');
        setWithdrawAmount('');
        setPinInput('');
        setError('');
        setSuccess('');
        setHistoryFilter('');
        // ?? RESET del flujo de doble verificaci¨®n de retiros
        setWithdrawStep('form');
        setWithdrawCode('');
        setWithdrawPayload(null);
        // ?? RESET del flujo de transferencia de 3 pasos
        setTransferStep(1);
        setSearchId('');
        setTransferTarget(null);
        setTransferAmount('');
        setTransferPin('');
        setTransferCode('');
        setIsSearching(false);
        // Reset del flujo viejo (por compatibilidad)
        setAmount('');
        setRecipient('');
      }
    }
  }, [modal]);

  const handleSaveBankData = async (e) => {
    e.preventDefault();
    setError('');
    try {
      // ?? USAMOS API_URL DIN¨¢MICA
      const res = await fetch(`${API_URL}/api/user/bank-data`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${localStorage.getItem('token')}` },
        body: JSON.stringify(bankForm)
      });
      if (res.ok) {
        setUserBankData(bankForm);
        setModal(null);
        showToast('Datos bancarios guardados correctamente.', 'success');
      } else {
        setError('Error al guardar los datos');
      }
    } catch (err) { setError('Error de conexion'); }
  };

  // ¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T
  // ?? FLUJO NUEVO DE TRANSFERENCIA (3 PASOS)
  // ¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T

  // PASO 1: Buscar jugador por ID ¨²nico (@123456)
  const handleSearchTarget = async (e) => {
    e.preventDefault();
    setError(''); setSuccess('');

    if (!searchId.trim()) {
      return setError('Ingresa un ID v¨¢lido.');
    }

    setIsSearching(true);
    try {
      // Aceptamos tanto "123456" como "@123456" ¡ª el backend limpia el @
      const cleanId = searchId.replace('@', '').trim();
      const res = await fetch(`${API_URL}/api/user/find/${cleanId}`, {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      const data = await res.json();

      if (res.ok) {
        setTransferTarget(data);
        setTransferStep(2); // Pasa al paso de monto + PIN
      } else {
        setError(data.error || 'Jugador no encontrado con ese ID.');
      }
    } catch (err) {
      setError('Error de conexi¨®n');
    } finally {
      setIsSearching(false);
    }
  };

  // PASO 2: Validar monto + PIN localmente y pedir c¨®digo al backend
  const handleTransferRequest = async (e) => {
    e.preventDefault();
    setError(''); setSuccess('');

    if (!transferTarget) {
      return setError('Debes buscar un jugador primero.');
    }
    if (Number(transferAmount) <= 0 || Number(transferAmount) > balance) {
      return setError('Monto inv¨¢lido o saldo insuficiente.');
    }
    if (!transferPin || transferPin.length < 4) {
      return setError('Debes ingresar tu PIN de pago.');
    }

    try {
      const res = await fetch(`${API_URL}/api/wallet/transfer/request`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${localStorage.getItem('token')}` },
        body: JSON.stringify({
          receiverUniqueId: transferTarget.unique_id,
          amount: Number(transferAmount),
          pin: transferPin
        })
      });
      const data = await res.json();

      if (res.ok) {
        setTransferStep(3); // Pasa al paso de c¨®digo de correo
        setSuccess('Hemos enviado un c¨®digo de verificaci¨®n a tu correo.');
      } else {
        setError(data.error || 'No se pudo iniciar la transferencia.');
      }
    } catch (err) {
      setError('Error de conexi¨®n');
    }
  };

  // PASO 3: Validar c¨®digo de correo y ejecutar la transferencia
  const handleTransferVerify = async (e) => {
    e.preventDefault();
    setError(''); setSuccess('');

    if (!transferCode || transferCode.length !== 6) {
      return setError('El c¨®digo debe tener 6 d¨ªgitos.');
    }
    if (!transferTarget) {
      return setError('Sesi¨®n expirada. Vuelve a empezar.');
    }

    try {
      const res = await fetch(`${API_URL}/api/wallet/transfer/verify`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${localStorage.getItem('token')}` },
        body: JSON.stringify({
          receiverUniqueId: transferTarget.unique_id,
          amount: Number(transferAmount),
          code: transferCode
        })
      });
      const data = await res.json();

      if (res.ok) {
        setSuccess('?Transferencia exitosa!');
        fetchBalance(localStorage.getItem('token'));
        setTimeout(() => {
          setModal(null);
          setSuccess('');
        }, 2500);
      } else {
        setError(data.error || 'C¨®digo incorrecto o expirado.');
      }
    } catch (err) {
      setError('Error de conexi¨®n');
    }
  };

  // ¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T
  // FLUJO VIEJO DE TRANSFERENCIA (mantenido por compatibilidad,
  // pero ya NO se usa desde el modal ¡ª el modal usa el flujo nuevo)
  // ¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T
  const handleTransfer = async (e) => {
    e.preventDefault();
    setError(''); setSuccess('');
    if (Number(amount) <= 0 || Number(amount) > balance) {
      return setError('Monto invalido o saldo insuficiente.');
    }

    try {
      const res = await fetch(`${API_URL}/api/wallet/transfer`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${localStorage.getItem('token')}` },
        body: JSON.stringify({ receiverUsername: recipient, amount: Number(amount) })
      });
      const data = await res.json();
      
      if (res.ok) {
        setSuccess('Transferencia exitosa!');
        setAmount(''); setRecipient('');
        fetchBalance(localStorage.getItem('token'));
        setTimeout(() => { setModal(null); setSuccess(''); }, 2000);
      } else {
        setError(data.error);
      }
    } catch (err) {
      setError('Error de conexion');
    }
  };

  const handleDepositSubmit = async (e) => {
    e.preventDefault();
    setError('');
    try {
      const res = await fetch(`${API_URL}/api/wallet/deposit`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${localStorage.getItem('token')}` },
        body: JSON.stringify({ amount_cup: depositAmount, transaction_id: transactionId })
      });
      const data = await res.json();
      if (res.ok) {
        setReceiveStep(4);
      } else {
        setError(data.error);
      }
    } catch (err) {
      setError('Error de conexion');
    }
  };

  // ?? PASO 1 del retiro: valida PIN + monto y pide el c¨®digo al backend
  const handleWithdrawSubmit = async (e) => {
    e.preventDefault();
    setError(''); setSuccess('');
    
    if (Number(withdrawAmount) <= 0 || Number(withdrawAmount) > balance) {
      return setError('Monto invalido o saldo insuficiente.');
    }
    if (!userBankData) {
      return setError('No tienes datos bancarios registrados. Recarga la pagina.');
    }
    if (!pinInput || pinInput.length < 4) {
      return setError('Debes ingresar tu PIN de pago para confirmar.');
    }

    const payload = {
      amount_ntx: Number(withdrawAmount),
      card_number: userBankData.card_number,
      holder_name: userBankData.holder_name,
      bank_name: userBankData.bank_name,
      pin: pinInput
    };

    try {
      const res = await fetch(`${API_URL}/api/wallet/withdraw`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${localStorage.getItem('token')}` },
        body: JSON.stringify(payload)
      });
      const data = await res.json();
      
      if (res.ok) {
        // ?? Backend NUEVO: requiere c¨®digo enviado por correo
        if (data.requires_verification) {
          setWithdrawPayload(payload);
          setWithdrawStep('verify_code');
          setWithdrawCode('');
          setSuccess(data.message || 'Hemos enviado un c¨®digo a tu correo electr¨®nico.');
          return;
        }
        // ?? Backend VIEJO: retiro procesado directo (comportamiento anterior)
        setSuccess('Retiro solicitado. Espera la transferencia.');
        setWithdrawAmount('');
        setPinInput('');
        fetchBalance(localStorage.getItem('token'));
        setTimeout(() => { setModal(null); setSuccess(''); }, 3000);
      } else {
        setError(data.error);
      }
    } catch (err) {
      setError('Error de conexion');
    }
  };

  // ?? PASO 2 del retiro: valida el c¨®digo de 6 d¨ªgitos con el backend y procesa el retiro
  const handleWithdrawVerify = async (e) => {
    e.preventDefault();
    setError(''); setSuccess('');

    if (!withdrawCode || withdrawCode.length !== 6) {
      return setError('El c¨®digo debe tener 6 d¨ªgitos.');
    }
    if (!withdrawPayload) {
      return setError('Sesi¨®n de retiro expirada. Vuelve a empezar.');
    }

    try {
      const res = await fetch(`${API_URL}/api/wallet/withdraw/verify`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${localStorage.getItem('token')}` },
        body: JSON.stringify({ code: withdrawCode, ...withdrawPayload })
      });
      const data = await res.json();

      if (res.ok) {
        setSuccess('Retiro solicitado. Espera la transferencia.');
        setWithdrawAmount('');
        setPinInput('');
        setWithdrawCode('');
        setWithdrawPayload(null);
        fetchBalance(localStorage.getItem('token'));
        setTimeout(() => { setModal(null); setSuccess(''); }, 3000);
      } else {
        setError(data.error);
      }
    } catch (err) {
      setError('Error de conexion');
    }
  };

  const handleOpenWithdraw = () => {
    // ?? DOBLE SEGURIDAD: Si por alguna raz¨®n el bot¨®n se muestra, esto evita que abran el modal
    if (!systemStatus.retiros_activos) {
      showToast('?? El sistema de retiros est¨¢ en mantenimiento.', 'error');
      return;
    }

    if (!user.has_pin) {
      showToast('Por seguridad, debes configurar un PIN de pago en la seccion de Seguridad antes de poder retirar.', 'error');
      return; 
    }
    setModal('retirar');
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'approved': return '#00e676';
      case 'pending': return '#e2b04a';
      case 'rejected': return '#ef4444';
      default: return '#a0aec0';
    }
  };

  const getStatusText = (status) => {
    switch (status) {
      case 'approved': return 'Completado';
      case 'pending': return 'Pendiente';
      case 'rejected': return 'Rechazado';
      default: return status;
    }
  };

  const getTypeText = (type) => {
    switch (type) {
      case 'deposit': return 'Deposito';
      case 'withdraw': return 'Retiro';
      case 'transfer_in': return 'Transferencia Recibida';
      case 'transfer_out': return 'Transferencia Enviada';
      case 'tournament_entry': return 'Entrada Torneo';
      case 'refund': return 'Reembolso Torneo';
      default: return type;
    }
  };

  const filteredHistory = history.filter(item => 
    getTypeText(item.type).toLowerCase().includes(historyFilter.toLowerCase()) || 
    getStatusText(item.status).toLowerCase().includes(historyFilter.toLowerCase())
  );

  return (
    <main className="main-area">
      {toast && <LocalToast message={toast.message} type={toast.type} onClose={() => setToast(null)} />}

      <div className="content-scroll" style={{ display: 'flex', justifyContent: 'center', padding: '2rem' }}>
        
        <div style={{ width: '100%', maxWidth: '1000px' }}>
          
          <button onClick={onBack} style={{ background: 'transparent', color: '#a0aec0', border: 'none', cursor: 'pointer', fontSize: '0.9rem', marginBottom: '1.5rem', display: 'flex', alignItems: 'center', gap: '5px' }}>
            &lt;- Volver al Lobby
          </button>

          <div style={{ display: 'flex', alignItems: 'center', gap: '15px', marginBottom: '2rem' }}>
            <h1 style={{ fontSize: '2rem', fontWeight: '800', margin: 0 }}>Billetera</h1>
          </div>

          <div className="wallet-main-card" style={{ padding: '2rem', borderRadius: '12px', background: 'linear-gradient(145deg, #171b24 0%, #12161f 100%)', border: '1px solid #2d3748', boxShadow: '0 10px 30px rgba(0,0,0,0.5)', position: 'relative' }}>
            
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
              
              <div style={{ position: 'relative' }}>
                <div 
                  onClick={() => setShowNetworkDropdown(!showNetworkDropdown)}
                  style={{ background: '#2d3748', padding: '6px 12px', borderRadius: '20px', display: 'inline-flex', alignItems: 'center', gap: '8px', color: '#f8fafc', cursor: 'pointer', fontSize: '0.85rem', fontWeight: 'bold', transition: '0.2s' }}
                >
                  <Icons.Globe /> All Network <Icons.ChevronDown />
                </div>

                {showNetworkDropdown && (
                  <div style={{ position: 'absolute', top: '100%', left: 0, marginTop: '10px', background: '#1a202c', border: '1px solid #2d3748', borderRadius: '8px', padding: '5px', zIndex: 10, width: '200px', boxShadow: '0 10px 20px rgba(0,0,0,0.5)' }}>
                    <div 
                      onClick={() => setShowNetworkDropdown(false)}
                      style={{ padding: '10px', borderRadius: '6px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '10px', background: '#2d3748' }}
                    >
                      <div style={{ width: '20px', height: '20px', borderRadius: '50%', background: '#00e676', color: '#000', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '10px', fontWeight: 'bold' }}>N</div>
                      <span style={{ fontSize: '0.9rem', color: '#fff' }}>NTX Network</span>
                    </div>
                  </div>
                )}
              </div>
            </div>

            <h2 style={{ fontSize: '3.5rem', fontWeight: '700', display: 'flex', alignItems: 'baseline', gap: '10px', margin: '20px 0', letterSpacing: '-1px' }}>
              {balance} <span style={{ fontSize: '1.5rem', color: '#a0aec0', fontWeight: '500' }}>NTX</span>
            </h2>
            
            <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap' }}>
              
              {/* ?? BOT¨®N RECIBIR (Oculto si inversiones_activas es false) ?? */}
              {systemStatus.inversiones_activas && (
                <button className="wallet-action-btn" style={{ padding: '8px 16px', fontSize: '0.85rem', background: '#1a202c', border: '1px solid #2d3748', borderRadius: '8px', color: '#fff', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '6px' }} onClick={() => setModal('recibir')}>
                  <Icons.Receive /> Recibir
                </button>
              )}
              
              {/* ?? BOT¨®N RETIRAR (Oculto si retiros_activos es false) ?? */}
              {systemStatus.retiros_activos && (
                <button className="wallet-action-btn" style={{ padding: '8px 16px', fontSize: '0.85rem', background: '#1a202c', border: '1px solid #2d3748', borderRadius: '8px', color: '#fff', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '6px' }} onClick={handleOpenWithdraw}>
                  <Icons.Send /> Retirar
                </button>
              )}
              
              {/* ESTOS BOTONES SIEMPRE SE MUESTRAN */}
              <button className="wallet-action-btn" style={{ padding: '8px 16px', fontSize: '0.85rem', background: '#1a202c', border: '1px solid #2d3748', borderRadius: '8px', color: '#fff', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '6px' }} onClick={() => setModal('transferir')}>
                <Icons.Transfer /> Transferir
              </button>
              
              <button className="wallet-action-btn" style={{ padding: '8px 16px', fontSize: '0.85rem', background: '#1a202c', border: '1px solid #2d3748', borderRadius: '8px', color: '#fff', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '6px' }} onClick={() => setModal('historial')}>
                <Icons.History /> Historia
              </button>
            </div>
          </div>

          <div style={{ marginTop: '3rem' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
              <h2 style={{ fontSize: '1.5rem', margin: 0, fontWeight: 'bold' }}>Activo</h2>
            </div>
            
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: '15px' }}>
              <div style={{ padding: '1.2rem', display: 'flex', alignItems: 'center', gap: '15px', background: '#171b24', borderRadius: '12px', border: '1px solid #2d3748', cursor: 'pointer', transition: '0.2s' }}>
                
                <img 
                  src="/ntx.png" 
                  alt="NTX" 
                  style={{ width: '45px', height: '45px', borderRadius: '50%', objectFit: 'cover' }} 
                  onError={(e) => { 
                    e.target.style.display = 'none'; 
                    e.target.nextSibling.style.display = 'flex'; 
                  }} 
                />
                <div style={{ display: 'none', width: '45px', height: '45px', borderRadius: '50%', background: '#00e676', color: '#000', justifyContent: 'center', alignItems: 'center', fontWeight: 'bold', fontSize: '1.2rem' }}>N</div>

                <div style={{ flex: 1 }}>
                  <h4 style={{ fontSize: '1.1rem', margin: '0 0 2px 0', color: '#fff' }}>NTX-20</h4>
                  <p style={{ fontSize: '0.8rem', margin: 0, color: '#718096' }}>RoyalBET Network</p>
                </div>
                <div style={{ fontSize: '1.3rem', fontWeight: 'bold', color: '#fff' }}>{balance}</div>
              </div>
            </div>
          </div>

          {/* MODALES FLOTANTES */}
          {modal && (
            <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', background: 'rgba(0,0,0,0.85)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 1000 }}>
              
              {modal === 'historial' ? (
                <div style={{ background: '#171b24', borderRadius: '12px', width: '90%', maxWidth: '1000px', border: '1px solid #2d3748', position: 'relative', display: 'flex', flexDirection: 'column', maxHeight: '90vh' }}>
                  
                  <div style={{ padding: '20px', borderBottom: '1px solid #2d3748', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <h2 style={{ margin: 0, fontSize: '1.5rem', fontWeight: 'bold' }}>Historial de Transacciones</h2>
                    <button onClick={() => { setModal(null); setError(''); setSuccess(''); }} style={{ background: 'transparent', border: 'none', color: '#a0aec0', fontSize: '1.5rem', cursor: 'pointer' }}>X</button>
                  </div>

                  <div style={{ padding: '15px 20px', display: 'flex', gap: '15px', borderBottom: '1px solid #2d3748', flexWrap: 'wrap' }}>
                    <div style={{ flex: 1, display: 'flex', alignItems: 'center', background: '#0b0e14', borderRadius: '8px', padding: '0 10px', border: '1px solid #2d3748' }}>
                      <Icons.Search />
                      <input 
                        type="text" 
                        placeholder="Introduzca la palabra clave (Ej: Reembolso, Deposito)" 
                        value={historyFilter}
                        onChange={(e) => setHistoryFilter(e.target.value)}
                        style={{ width: '100%', background: 'transparent', border: 'none', color: '#fff', padding: '10px', outline: 'none' }} 
                      />
                    </div>
                  </div>

                  <div style={{ overflowY: 'auto', flex: 1 }}>
                    {historyLoading ? (
                      <p style={{ textAlign: 'center', padding: '40px', color: '#a0aec0' }}>Cargando historial...</p>
                    ) : filteredHistory.length === 0 ? (
                      <div style={{ textAlign: 'center', padding: '50px', color: '#718096' }}>
                        <div style={{ fontSize: '3rem', marginBottom: '10px' }}>!</div>
                        <p>No hay transacciones recientes.</p>
                      </div>
                    ) : (
                      <table style={{ width: '100%', textAlign: 'left', borderCollapse: 'collapse' }}>
                        <thead>
                          <tr style={{ background: '#0b0e14', color: '#a0aec0', fontSize: '0.85rem' }}>
                            <th style={{ padding: '15px 20px' }}>Activo</th>
                            <th style={{ padding: '15px 20px' }}>Total</th>
                            <th style={{ padding: '15px 20px' }}>Tipo</th>
                            <th style={{ padding: '15px 20px' }}>Estado</th>
                            <th style={{ padding: '15px 20px' }}>Tiempo</th>
                          </tr>
                        </thead>
                        <tbody>
                          {filteredHistory.map((item) => {
                            const isPositive = ['deposit', 'transfer_in', 'refund', 'win'].includes(item.type);
                            
                            return (
                              <tr key={item.id} style={{ borderBottom: '1px solid #2d3748' }}>
                                <td style={{ padding: '15px 20px', display: 'flex', alignItems: 'center', gap: '10px' }}>
                                  <div style={{ background: '#00e676', color: '#000', borderRadius: '4px', padding: '2px 6px', fontSize: '0.75rem', fontWeight: 'bold' }}>NTX-20</div>
                                  <span style={{ color: '#fff', fontWeight: '500' }}>RoyalBET</span>
                                </td>
                                <td style={{ padding: '15px 20px', color: '#fff', fontWeight: 'bold' }}>
                                  <span style={{color: isPositive ? '#00e676' : '#ef4444'}}>
                                    {isPositive ? '+' : '-'}{item.amount}
                                  </span>
                                </td>
                                <td style={{ padding: '15px 20px', color: '#a0aec0' }}>{getTypeText(item.type)}</td>
                                <td style={{ padding: '15px 20px', color: getStatusColor(item.status), fontWeight: 'bold' }}>
                                  {getStatusText(item.status)}
                                </td>
                                <td style={{ padding: '15px 20px', color: '#a0aec0' }}>
                                  {new Date(item.created_at).toLocaleString('es-ES', { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' })}
                                </td>
                              </tr>
                            );
                          })}
                        </tbody>
                      </table>
                    )}
                  </div>
                </div>
              ) : (
                <div style={{ background: '#1a202c', padding: '30px', borderRadius: '12px', width: '450px', border: '1px solid #2d3748', position: 'relative' }}>
                  
                  {/* BOTON DE CERRAR (X) CORREGIDO */}
                  {modal !== 'register_bank_data' && (
                    <button 
                      type="button"
                      onClick={() => { setModal(null); setError(''); setSuccess(''); }} 
                      style={{ position: 'absolute', top: '15px', right: '15px', background: 'transparent', border: 'none', color: '#a0aec0', fontSize: '1.5rem', cursor: 'pointer', zIndex: 10 }}
                    >
                      X
                    </button>
                  )}

                  {modal === 'register_bank_data' && (
                    <form onSubmit={handleSaveBankData}>
                      <h2 style={{ marginBottom: '10px', color: '#e2b04a' }}>Registrar Datos Bancarios</h2>
                      <p style={{ color: '#a0aec0', marginBottom: '20px', fontSize: '0.85rem' }}>Necesitamos estos datos para procesar tus retiros en el futuro. No podras cerrar esta ventana sin completarlos.</p>
                      {error && <p style={{ color: '#ef4444', fontSize: '0.9rem', marginBottom: '10px' }}>{error}</p>}
                      
                      <label style={{ color: '#a0aec0', fontSize: '0.85rem' }}>Numero de Tarjeta Magnetica</label>
                      <input type="text" value={bankForm.card_number} onChange={e => setBankForm({...bankForm, card_number: e.target.value})} required placeholder="Ej: 9200 1234 5678 9012" style={{ width: '100%', padding: '12px', marginBottom: '15px', background: '#0b0e14', border: '1px solid #2d3748', color: '#fff', borderRadius: '8px' }} />
                      
                      <label style={{ color: '#a0aec0', fontSize: '0.85rem' }}>Numero de Telefono</label>
                      <input type="text" value={bankForm.phone} onChange={e => setBankForm({...bankForm, phone: e.target.value})} required placeholder="Ej: +53 5555 5555" style={{ width: '100%', padding: '12px', marginBottom: '15px', background: '#0b0e14', border: '1px solid #2d3748', color: '#fff', borderRadius: '8px' }} />
                      
                      <label style={{ color: '#a0aec0', fontSize: '0.85rem' }}>Propietario de la Tarjeta</label>
                      <input type="text" value={bankForm.holder_name} onChange={e => setBankForm({...bankForm, holder_name: e.target.value})} required placeholder="Ej: Juan Perez" style={{ width: '100%', padding: '12px', marginBottom: '15px', background: '#0b0e14', border: '1px solid #2d3748', color: '#fff', borderRadius: '8px' }} />
                      
                      <label style={{ color: '#a0aec0', fontSize: '0.85rem' }}>Banco al que pertenece</label>
                      <input type="text" value={bankForm.bank_name} onChange={e => setBankForm({...bankForm, bank_name: e.target.value})} required placeholder="Ej: Banco Metropolitano" style={{ width: '100%', padding: '12px', marginBottom: '20px', background: '#0b0e14', border: '1px solid #2d3748', color: '#fff', borderRadius: '8px' }} />
                      
                      <button type="submit" className="btn" style={{ width: '100%', background: '#00e676', color: '#000' }}>Guardar Datos Bancarios</button>
                    </form>
                  )}

                  {modal === 'recibir' && (
                    <div>
                      {receiveStep === 1 && (
                        <div>
                          <h2 style={{ marginBottom: '20px' }}>Seleccionar Moneda</h2>
                          <p style={{ color: '#a0aec0', marginBottom: '15px', fontSize: '0.9rem' }}>Por favor, seleccione la moneda para la transferencia.</p>
                          <select style={{ width: '100%', padding: '12px', background: '#0b0e14', border: '1px solid #2d3748', color: '#fff', borderRadius: '8px', marginBottom: '20px' }}>
                            <option value="NTX-20">NTX-20 (Nacional)</option>
                          </select>
                          
                          <div style={{ display: 'flex', gap: '10px' }}>
                            <button type="button" onClick={() => setModal(null)} className="btn" style={{ flex: 1, background: '#2d3748', color: '#fff' }}>Cancelar</button>
                            <button onClick={() => setReceiveStep(2)} className="btn" style={{ flex: 1, background: '#00e676', color: '#000' }}>Siguiente</button>
                          </div>
                        </div>
                      )}

                      {receiveStep === 2 && (
                        <div>
                          <h2 style={{ marginBottom: '20px' }}>Datos de Transferencia</h2>
                          <p style={{ color: '#a0aec0', marginBottom: '15px', fontSize: '0.9rem' }}>Por favor, realice la transferencia a los siguientes datos:</p>
                          {adminDetails ? (
                            <div style={{ background: '#0b0e14', padding: '15px', borderRadius: '8px', border: '1px solid #2d3748', marginBottom: '20px' }}>
                              <p style={{ margin: '0 0 5px 0', color: '#a0aec0', fontSize: '0.8rem' }}>Banco:</p>
                              <p style={{ margin: '0 0 10px 0', fontWeight: 'bold' }}>{adminDetails.bank_name}</p>
                              <p style={{ margin: '0 0 5px 0', color: '#a0aec0', fontSize: '0.8rem' }}>Titular:</p>
                              <p style={{ margin: '0 0 10px 0', fontWeight: 'bold' }}>{adminDetails.holder_name}</p>
                              <p style={{ margin: '0 0 5px 0', color: '#a0aec0', fontSize: '0.8rem' }}>Numero de Tarjeta:</p>
                              <p style={{ margin: 0, fontWeight: 'bold', fontSize: '1.2rem', letterSpacing: '1px', color: '#00e676' }}>{adminDetails.card_number}</p>
                            </div>
                          ) : <p>Cargando datos...</p>}
                          <div style={{ display: 'flex', gap: '10px' }}>
                            <button onClick={() => setReceiveStep(1)} className="btn" style={{ flex: 1, background: '#2d3748', color: '#fff' }}>Atras</button>
                            <button onClick={() => setReceiveStep(3)} className="btn" style={{ flex: 1, background: '#00e676', color: '#000' }}>Siguiente</button>
                          </div>
                        </div>
                      )}

                      {receiveStep === 3 && (
                        <form onSubmit={handleDepositSubmit}>
                          <h2 style={{ marginBottom: '20px' }}>Confirmar Deposito</h2>
                          {error && <p style={{ color: '#ef4444', fontSize: '0.9rem', marginBottom: '10px' }}>{error}</p>}
                          
                          <label style={{ color: '#a0aec0', fontSize: '0.85rem' }}>Monto transferido (CUP)</label>
                          <input type="number" value={depositAmount} onChange={e => setDepositAmount(e.target.value)} required placeholder="Ej: 500" style={{ width: '100%', padding: '12px', marginBottom: '15px', background: '#0b0e14', border: '1px solid #2d3748', color: '#fff', borderRadius: '8px' }} />
                          
                          <label style={{ color: '#a0aec0', fontSize: '0.85rem' }}>ID de la Transferencia</label>
                          <input type="text" value={transactionId} onChange={e => setTransactionId(e.target.value)} required placeholder="Ej: 12345678" style={{ width: '100%', padding: '12px', marginBottom: '20px', background: '#0b0e14', border: '1px solid #2d3748', color: '#fff', borderRadius: '8px' }} />
                          
                          <div style={{ display: 'flex', gap: '10px' }}>
                            <button type="button" onClick={() => setModal(null)} className="btn" style={{ flex: 1, background: '#2d3748', color: '#fff' }}>Cancelar</button>
                            <button type="submit" className="btn" style={{ flex: 1, background: '#00e676', color: '#000' }}>Enviar Solicitud</button>
                          </div>
                        </form>
                      )}

                      {receiveStep === 4 && (
                        <div style={{ textAlign: 'center', padding: '20px 0' }}>
                          <div style={{ fontSize: '4rem', marginBottom: '15px' }}>!</div>
                          <h2 style={{ color: '#00e676', marginBottom: '10px' }}>Solicitud Enviada!</h2>
                          <p style={{ color: '#a0aec0', lineHeight: '1.5' }}>Su transferencia esta siendo revisada.<br/>Debe cuadrar con el admin. Una vez confirmada, se acreditara el saldo automaticamente.</p>
                          <button onClick={() => setModal(null)} className="btn" style={{ width: '100%', background: '#2d3748', color: '#fff', marginTop: '20px' }}>Cerrar</button>
                        </div>
                      )}
                    </div>
                  )}

                  {modal === 'retirar' && (
                    <>
                      {/* PASO 1: Formulario de monto + PIN */}
                      {withdrawStep === 'form' && (
                        <form onSubmit={handleWithdrawSubmit}>
                          <h2 style={{ marginBottom: '20px' }}>Solicitar Retiro</h2>
                          {error && <p style={{ color: '#ef4444', fontSize: '0.9rem', marginBottom: '10px' }}>{error}</p>}
                          {success && <p style={{ color: '#00e676', fontSize: '0.9rem', marginBottom: '10px' }}>{success}</p>}
                          
                          <div style={{ background: '#0b0e14', padding: '15px', borderRadius: '8px', border: '1px solid #2d3748', marginBottom: '20px' }}>
                            <p style={{ margin: '0 0 5px 0', color: '#a0aec0', fontSize: '0.8rem' }}>Se transferira a tu tarjeta registrada:</p>
                            <p style={{ margin: 0, fontWeight: 'bold', color: '#fff' }}>{userBankData?.bank_name} - {userBankData?.card_number}</p>
                          </div>

                          <label style={{ color: '#a0aec0', fontSize: '0.85rem' }}>Monto a retirar (NTX-20)</label>
                          <input type="number" value={withdrawAmount} onChange={e => setWithdrawAmount(e.target.value)} required placeholder="Ej: 100" style={{ width: '100%', padding: '12px', marginBottom: '15px', background: '#0b0e14', border: '1px solid #2d3748', color: '#fff', borderRadius: '8px' }} />
                          
                          <label style={{ color: '#e2b04a', fontSize: '0.85rem', fontWeight: 'bold' }}>Ingresa tu PIN de 6 digitos</label>
                          <input type="password" value={pinInput} onChange={e => setPinInput(e.target.value)} required placeholder="******" maxLength="6" style={{ width: '100%', padding: '12px', marginBottom: '20px', background: '#0b0e14', border: '1px solid #e2b04a', color: '#fff', borderRadius: '8px', textAlign: 'center', letterSpacing: '5px', fontSize: '1.2rem' }} />
                          
                          <div style={{ display: 'flex', gap: '10px' }}>
                            <button type="button" onClick={() => { setModal(null); setError(''); setSuccess(''); }} className="btn" style={{ flex: 1, background: '#2d3748', color: '#fff' }}>Cancelar</button>
                            <button type="submit" className="btn" style={{ flex: 1, background: '#e2b04a', color: '#000' }}>Confirmar Retiro</button>
                          </div>
                        </form>
                      )}

                      {/* PASO 2: C¨®digo de verificaci¨®n enviado por correo */}
                      {withdrawStep === 'verify_code' && (
                        <form onSubmit={handleWithdrawVerify}>
                          <h2 style={{ marginBottom: '10px', color: '#e2b04a' }}>Verificaci¨®n por Correo</h2>
                          <p style={{ color: '#a0aec0', marginBottom: '20px', fontSize: '0.85rem', lineHeight: '1.5' }}>
                            Hemos enviado un c¨®digo de 6 d¨ªgitos a tu correo electr¨®nico. Ingr¨¦salo para completar tu retiro de <strong style={{ color: '#fff' }}>{withdrawPayload?.amount_ntx} NTX</strong>.
                          </p>
                          {error && <p style={{ color: '#ef4444', fontSize: '0.9rem', marginBottom: '10px' }}>{error}</p>}
                          {success && <p style={{ color: '#00e676', fontSize: '0.9rem', marginBottom: '10px' }}>{success}</p>}

                          <label style={{ color: '#e2b04a', fontSize: '0.85rem', fontWeight: 'bold' }}>C¨®digo de verificaci¨®n</label>
                          <input
                            type="text"
                            value={withdrawCode}
                            onChange={e => setWithdrawCode(e.target.value.replace(/\D/g, '').slice(0, 6))}
                            required
                            placeholder="------"
                            maxLength="6"
                            style={{ width: '100%', padding: '12px', marginBottom: '20px', background: '#0b0e14', border: '1px solid #e2b04a', color: '#fff', borderRadius: '8px', textAlign: 'center', letterSpacing: '8px', fontSize: '1.4rem', fontWeight: 'bold' }}
                          />

                          <div style={{ display: 'flex', gap: '10px' }}>
                            <button type="button" onClick={() => { setWithdrawStep('form'); setError(''); setSuccess(''); setWithdrawCode(''); }} className="btn" style={{ flex: 1, background: '#2d3748', color: '#fff' }}>Atr¨¢s</button>
                            <button type="submit" className="btn" style={{ flex: 1, background: '#e2b04a', color: '#000' }}>Confirmar c¨®digo</button>
                          </div>
                        </form>
                      )}
                    </>
                  )}

                  {/* ?? NUEVO MODAL DE TRANSFERIR (FLUJO DE 3 PASOS) ?? */}
                  {modal === 'transferir' && (
                    <>
                      {/* PASO 1: BUSCAR ID DEL DESTINATARIO */}
                      {transferStep === 1 && (
                        <form onSubmit={handleSearchTarget}>
                          <h2 style={{ marginBottom: '20px' }}>Transferir a Jugador</h2>
                          <p style={{ color: '#a0aec0', marginBottom: '15px', fontSize: '0.9rem' }}>
                            Ingresa el ID ¨²nico del jugador al que quieres enviarle dinero. Podr¨¢s confirmar su nombre y avatar antes de continuar.
                          </p>
                          {error && <p style={{ color: '#ef4444', fontSize: '0.9rem', marginBottom: '10px' }}>{error}</p>}
                          
                          <label style={{ color: '#a0aec0', fontSize: '0.85rem' }}>ID del Destinatario</label>
                          <div style={{ position: 'relative', marginBottom: '20px' }}>
                            <span style={{ position: 'absolute', left: '12px', top: '12px', color: '#a0aec0', fontWeight: 'bold' }}>@</span>
                            <input 
                              type="text" 
                              value={searchId} 
                              onChange={e => setSearchId(e.target.value)} 
                              required 
                              placeholder="123456" 
                              style={{ width: '100%', padding: '12px 12px 12px 30px', background: '#0b0e14', border: '1px solid #2d3748', color: '#fff', borderRadius: '8px' }} 
                            />
                          </div>
                          
                          <div style={{ display: 'flex', gap: '10px' }}>
                            <button type="button" onClick={() => { setModal(null); setError(''); setSuccess(''); }} className="btn" style={{ flex: 1, background: '#2d3748', color: '#fff' }}>Cancelar</button>
                            <button type="submit" disabled={isSearching} className="btn" style={{ flex: 1, background: '#00e676', color: '#000' }}>
                              {isSearching ? 'Buscando...' : 'Buscar Jugador'}
                            </button>
                          </div>
                        </form>
                      )}

                      {/* PASO 2: CONFIRMAR DESTINATARIO + MONTO + PIN */}
                      {transferStep === 2 && transferTarget && (
                        <form onSubmit={handleTransferRequest}>
                          <h2 style={{ marginBottom: '20px' }}>Confirmar Datos</h2>
                          
                          {/* Tarjeta del destinatario con avatar y nombre */}
                          <div style={{ display: 'flex', alignItems: 'center', gap: '15px', background: '#0b0e14', padding: '15px', borderRadius: '8px', border: '1px solid #00e676', marginBottom: '20px' }}>
                            <img 
                              src={transferTarget.avatar_url || `https://api.dicebear.com/7.x/adventurer/svg?seed=${transferTarget.username}`} 
                              alt="Avatar" 
                              style={{ width: '50px', height: '50px', borderRadius: '50%', background: '#1a202c' }} 
                            />
                            <div>
                              <h4 style={{ margin: 0, color: '#fff' }}>{transferTarget.username}</h4>
                              <p style={{ margin: 0, color: '#00e676', fontSize: '0.85rem' }}>@{transferTarget.unique_id}</p>
                            </div>
                          </div>

                          {error && <p style={{ color: '#ef4444', fontSize: '0.9rem', marginBottom: '10px' }}>{error}</p>}
                          {success && <p style={{ color: '#00e676', fontSize: '0.9rem', marginBottom: '10px' }}>{success}</p>}
                          
                          <label style={{ color: '#a0aec0', fontSize: '0.85rem' }}>Monto a transferir (NTX)</label>
                          <input 
                            type="number" 
                            value={transferAmount} 
                            onChange={e => setTransferAmount(e.target.value)} 
                            required 
                            placeholder="Ej: 100" 
                            style={{ width: '100%', padding: '12px', marginBottom: '15px', background: '#0b0e14', border: '1px solid #2d3748', color: '#fff', borderRadius: '8px' }} 
                          />
                          
                          <label style={{ color: '#e2b04a', fontSize: '0.85rem', fontWeight: 'bold' }}>Ingresa tu PIN de pago</label>
                          <input 
                            type="password" 
                            value={transferPin} 
                            onChange={e => setTransferPin(e.target.value)} 
                            required 
                            placeholder="******" 
                            maxLength="6" 
                            style={{ width: '100%', padding: '12px', marginBottom: '20px', background: '#0b0e14', border: '1px solid #e2b04a', color: '#fff', borderRadius: '8px', textAlign: 'center', letterSpacing: '5px', fontSize: '1.2rem' }} 
                          />
                          
                          <div style={{ display: 'flex', gap: '10px' }}>
                            <button type="button" onClick={() => { setTransferStep(1); setError(''); setTransferPin(''); }} className="btn" style={{ flex: 1, background: '#2d3748', color: '#fff' }}>Atr¨¢s</button>
                            <button type="submit" className="btn" style={{ flex: 1, background: '#00e676', color: '#000' }}>Continuar</button>
                          </div>
                        </form>
                      )}

                      {/* PASO 3: C¨®DIGO DE VERIFICACI¨®N POR CORREO */}
                      {transferStep === 3 && transferTarget && (
                        <form onSubmit={handleTransferVerify}>
                          <h2 style={{ marginBottom: '10px', color: '#e2b04a' }}>Verificaci¨®n por Correo</h2>
                          <p style={{ color: '#a0aec0', marginBottom: '20px', fontSize: '0.85rem', lineHeight: '1.5' }}>
                            Hemos enviado un c¨®digo de 6 d¨ªgitos a tu correo para confirmar la transferencia de <strong style={{ color: '#fff' }}>{transferAmount} NTX</strong> a <strong style={{ color: '#00e676' }}>{transferTarget.username}</strong>.
                          </p>
                          {error && <p style={{ color: '#ef4444', fontSize: '0.9rem', marginBottom: '10px' }}>{error}</p>}
                          {success && <p style={{ color: '#00e676', fontSize: '0.9rem', marginBottom: '10px' }}>{success}</p>}

                          <label style={{ color: '#e2b04a', fontSize: '0.85rem', fontWeight: 'bold' }}>C¨®digo de verificaci¨®n</label>
                          <input 
                            type="text" 
                            value={transferCode} 
                            onChange={e => setTransferCode(e.target.value.replace(/\D/g, '').slice(0, 6))} 
                            required 
                            placeholder="------" 
                            maxLength="6" 
                            style={{ width: '100%', padding: '12px', marginBottom: '20px', background: '#0b0e14', border: '1px solid #e2b04a', color: '#fff', borderRadius: '8px', textAlign: 'center', letterSpacing: '8px', fontSize: '1.4rem', fontWeight: 'bold' }} 
                          />

                          <div style={{ display: 'flex', gap: '10px' }}>
                            <button type="button" onClick={() => { setTransferStep(2); setError(''); setSuccess(''); setTransferCode(''); }} className="btn" style={{ flex: 1, background: '#2d3748', color: '#fff' }}>Atr¨¢s</button>
                            <button type="submit" className="btn" style={{ flex: 1, background: '#00e676', color: '#000' }}>Confirmar Transferencia</button>
                          </div>
                        </form>
                      )}
                    </>
                  )}

                </div>
              )}
            </div>
          )}

        </div>
      </div>
    </main>
  );
}