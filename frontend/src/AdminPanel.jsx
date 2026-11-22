import { useState, useEffect } from 'react';
import { API_URL } from './config';

// COMPONENTE DE NOTIFICACION LOCAL
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

export default function AdminPanel({ user, onBack }) {
  // ESTADO: Controla la pestaña activa
  const [activeTab, setActiveTab] = useState('solicitudes');

  const [data, setData] = useState({ deposits: [], withdrawals: [], reserves: { balance_ntx: 0, referral_fund: 0 } });
  const [myTaken, setMyTaken] = useState({ deposits: [], withdrawals: [] });
  const [auditLog, setAuditLog] = useState([]); 
  const [hasBankData, setHasBankData] = useState(null);
  const [formData, setFormData] = useState({ card_number: '', phone: '', holder_name: '', bank_name: '' });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [editingBankData, setEditingBankData] = useState(false);
  const [toast, setToast] = useState(null);

  // ESTADOS: Para el modal "Agregar Fondo" y la pestaña de Jugadores
  const [showFundModal, setShowFundModal] = useState(false);
  const [fundForm, setFundForm] = useState({ admin_id: '', amount: '' });
  const [players, setPlayers] = useState([]);
  const [loadingPlayers, setLoadingPlayers] = useState(false);

  // ESTADO: Para el botón de liquidar el Rake
  const [liquidatingRake, setLiquidatingRake] = useState(false);

  const showToast = (message, type = 'success') => {
    setToast({ message, type });
  };

  // ESTADO: Para los Switches y configuración de Ajustes
  const [systemStatus, setSystemStatus] = useState({
    retiros_activos: true,
    inversiones_activas: true,
    bonus_porcentaje: 0,
    bonus_limite_total: 0,
    bonus_usado: 0
  });

  // ESTADO: Para los datos del Banco Global
  const [bankData, setBankData] = useState({
    total_disponible: 0,
    total_saldo: 0,
    total_fondo: 0,
    total_recibido: 0,
    total_retirado: 0,
    admins: []
  });

  // Verificar que sea superadmin
  if (user && user.role !== 'superadmin') {
    return (
      <main className="main-area" style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '80vh' }}>
        <div style={{ textAlign: 'center', color: '#ef4444' }}>
          <h2>Acceso Denegado</h2>
          <p style={{ color: '#a0aec0' }}>Solo el administrador puede acceder a este panel.</p>
          <button onClick={onBack} className="btn" style={{ marginTop: '20px', width: 'auto', padding: '10px 30px' }}>Volver al Lobby</button>
        </div>
      </main>
    );
  }

  // 1. Verificar si el admin ya tiene datos bancarios
  const fetchBankData = async () => {
    try {
      const res = await fetch(`${API_URL}/api/user/bank-data`, {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      if (res.ok) {
        const d = await res.json();
        setFormData(d);
        setHasBankData(true);
        setEditingBankData(false);
      } else {
        setHasBankData(false);
        setEditingBankData(true);
      }
    } catch (err) { 
      setHasBankData(false); 
      setEditingBankData(true);
    }
  };

  // 2. Obtener solicitudes pendientes
  const fetchAdminData = async () => {
    setLoading(true);
    try {
      const res = await fetch(`${API_URL}/api/admin/pending`, {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      const result = await res.json();
      if (res.ok) {
        setData({
          ...result,
          reserves: {
            balance_ntx: result.reserves?.balance_ntx || 0,
            referral_fund: result.reserves?.referral_fund || 0
          }
        });
      } else {
        setError(result.error || 'Error al cargar datos');
      }
    } catch (err) { 
      setError('Error de conexión con el servidor');
    } finally { 
      setLoading(false); 
    }
  };

  // 3. Obtener las solicitudes tomadas
  const fetchMyTaken = async () => {
    try {
      const res = await fetch(`${API_URL}/api/admin/my-taken`, {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      if (res.ok) {
        const result = await res.json();
        setMyTaken(result);
      }
    } catch (err) {
      console.error("Error cargando mis solicitudes", err);
    }
  };

  // 4. Obtener el historial de auditoría
  const fetchAuditLog = async () => {
    try {
      const res = await fetch(`${API_URL}/api/admin/audit-log`, {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      if (res.ok) {
        const logs = await res.json();
        setAuditLog(logs);
      }
    } catch (err) {
      console.error("Error cargando auditoría", err);
    }
  };

  // 5. Obtener estado de los Switches y Bonos
  const fetchSystemStatus = async () => {
    try {
      const res = await fetch(`${API_URL}/api/admin/settings`, {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      if (res.ok) {
        const statusData = await res.json();
        setSystemStatus(prev => ({ ...prev, ...statusData }));
      }
    } catch (err) {
      console.error("Error cargando ajustes", err);
    }
  };

  // 6. Obtener datos del Banco Global
  const fetchBankSystemData = async () => {
    try {
      const res = await fetch(`${API_URL}/api/admin/bank`, {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      if (res.ok) {
        const bankResult = await res.json();
        setBankData(bankResult);
      }
    } catch (err) {
      console.error("Error cargando banco", err);
    }
  };

  // 7. Obtener lista de jugadores
  const fetchPlayers = async () => {
    setLoadingPlayers(true);
    try {
      const res = await fetch(`${API_URL}/api/admin/users`, {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      if (res.ok) {
        setPlayers(await res.json());
      }
    } catch (err) {
      console.error("Error cargando jugadores", err);
    } finally {
      setLoadingPlayers(false);
    }
  };

  // Handler para liquidar el Rake (Poner en 0)
  const handleLiquidateRake = async () => {
    if (!window.confirm('¿Estás SEGURO de liquidar el Fondo del Proyecto? Esto lo dejará en 0 NTX.')) return;
    
    setLiquidatingRake(true);
    try {
      const res = await fetch(`${API_URL}/api/admin/bank/liquidate-rake`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      const result = await res.json();
      if (res.ok) {
        showToast('Fondo del Proyecto liquidado a 0 correctamente', 'success');
        fetchAdminData(); // Refrescar el saldo en pantalla
      } else {
        showToast(result.error || 'Error al liquidar el fondo', 'error');
      }
    } catch (err) {
      showToast('Error de conexión', 'error');
    } finally {
      setLiquidatingRake(false);
    }
  };

  // Handlers para modal de agregar fondo
  const handleAddFund = async () => {
    if (!fundForm.admin_id || !fundForm.amount || Number(fundForm.amount) <= 0) {
      showToast('Selecciona un admin y un monto válido', 'error');
      return;
    }
    try {
      const res = await fetch(`${API_URL}/api/admin/bank/fund`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${localStorage.getItem('token')}` },
        body: JSON.stringify({ admin_id: Number(fundForm.admin_id), amount: Number(fundForm.amount) })
      });
      const result = await res.json();
      if (res.ok) {
        showToast(result.message || 'Fondo agregado correctamente', 'success');
        setShowFundModal(false);
        setFundForm({ admin_id: '', amount: '' });
        fetchBankSystemData();
      } else {
        showToast(result.error || 'Error al agregar fondo', 'error');
      }
    } catch (err) {
      showToast('Error de conexión', 'error');
    }
  };

  // Handler para bloquear/desbloquear jugador
  const handleToggleBlock = async (id) => {
    if (!window.confirm('¿Estás seguro de cambiar el estado de esta cuenta?')) return;
    try {
      const res = await fetch(`${API_URL}/api/admin/users/${id}/toggle-block`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      const result = await res.json();
      if (res.ok) {
        showToast(result.message, 'success');
        fetchPlayers();
      } else {
        showToast(result.error, 'error');
      }
    } catch (err) {
      showToast('Error de conexión', 'error');
    }
  };

  // Handler para eliminar jugador
  const handleDeletePlayer = async (id) => {
    if (!window.confirm('¿Estás SEGURO de eliminar esta cuenta permanentemente? Esta acción no se puede deshacer.')) return;
    try {
      const res = await fetch(`${API_URL}/api/admin/users/${id}`, {
        method: 'DELETE',
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      const result = await res.json();
      if (res.ok) {
        showToast(result.message, 'success');
        fetchPlayers();
      } else {
        showToast(result.error, 'error');
      }
    } catch (err) {
      showToast('Error de conexión', 'error');
    }
  };

  useEffect(() => { 
    fetchBankData(); 
    fetchAuditLog(); 
    fetchSystemStatus();
    fetchBankSystemData();
  }, []);

  useEffect(() => { 
    if (hasBankData && !editingBankData) {
      fetchAdminData(); 
      fetchMyTaken();
    }
  }, [hasBankData, editingBankData]);

  useEffect(() => {
    if (activeTab === 'jugadores') {
      fetchPlayers();
    }
  }, [activeTab]);

  useEffect(() => {
    if (hasBankData && !editingBankData) {
      const interval = setInterval(() => {
        fetchAdminData();
        fetchMyTaken();
      }, 15000);
      return () => clearInterval(interval);
    }
  }, [hasBankData, editingBankData]);

  const handleSaveBankData = async (e) => {
    e.preventDefault();
    setError(''); setSuccess('');
    try {
      const res = await fetch(`${API_URL}/api/user/bank-data`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${localStorage.getItem('token')}` },
        body: JSON.stringify(formData)
      });
      if (res.ok) { 
        setSuccess('Datos bancarios guardados correctamente.');
        setHasBankData(true); 
        setEditingBankData(false);
        setTimeout(() => setSuccess(''), 3000);
      } else { 
        setError('Error al guardar los datos'); 
      }
    } catch (err) { 
      setError('Error de conexión'); 
    }
  };

  // ==========================================
  // TOMAR SOLICITUDES
  // ==========================================
  const takeDeposit = async (id) => {
    if (!window.confirm('¿Tomar esta solicitud de depósito? Se te asignará a ti.')) return;
    setError(''); setSuccess('');
    try {
      const res = await fetch(`${API_URL}/api/admin/deposits/take`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${localStorage.getItem('token')}` },
        body: JSON.stringify({ request_id: id })
      });
      const result = await res.json();
      if (res.ok) {
        showToast('Solicitud tomada correctamente', 'success');
        setActiveTab('mis-solicitudes');
        fetchAdminData();
        fetchMyTaken();
      } else {
        setError(result.error || 'Error al tomar la solicitud');
      }
    } catch (err) {
      setError('Error de conexión');
    }
  };

  const takeWithdrawal = async (id) => {
    if (!window.confirm('¿Tomar esta solicitud de retiro? Se te asignará a ti.')) return;
    setError(''); setSuccess('');
    try {
      const res = await fetch(`${API_URL}/api/admin/withdrawals/take`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${localStorage.getItem('token')}` },
        body: JSON.stringify({ request_id: id })
      });
      const result = await res.json();
      if (res.ok) {
        showToast('Solicitud tomada correctamente', 'success');
        setActiveTab('mis-solicitudes');
        fetchAdminData();
        fetchMyTaken();
      } else {
        setError(result.error || 'Error al tomar la solicitud');
      }
    } catch (err) {
      setError('Error de conexión');
    }
  };

  // ==========================================
  // APROBAR / RECHAZAR
  // ==========================================
  const handleDeposit = async (id) => {
    if (!window.confirm('¿Aprobar este depósito? Se acreditará el saldo al jugador 1:1.')) return;
    setError(''); setSuccess('');
    try {
      const res = await fetch(`${API_URL}/api/admin/deposits/approve`, {
        method: 'POST', 
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${localStorage.getItem('token')}` },
        body: JSON.stringify({ request_id: id })
      });
      if (res.ok) {
        showToast('Depósito aprobado exitosamente', 'success');
        fetchAdminData(); fetchMyTaken(); fetchAuditLog(); fetchBankSystemData();
      } else {
        const d = await res.json();
        setError(d.error || 'Error al aprobar');
      }
    } catch (err) {
      setError('Error de conexión');
    }
  };

  const handleWithdraw = async (id, action) => {
    const msg = action === 'approve' 
      ? '¿Confirmas que ya transferiste el dinero real al jugador?' 
      : '¿Rechazar retiro y devolver el saldo al jugador?';
      
    if (!window.confirm(msg)) return;
    setError(''); setSuccess('');
    
    try {
      const res = await fetch(`${API_URL}/api/admin/withdrawals/${action}`, {
        method: 'POST', 
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${localStorage.getItem('token')}` },
        body: JSON.stringify({ request_id: id })
      });
      if (res.ok) {
        showToast(action === 'approve' ? 'Retiro completado' : 'Retiro rechazado', 'success');
        fetchAdminData(); fetchMyTaken(); fetchAuditLog(); fetchBankSystemData();
      } else {
        const d = await res.json();
        setError(d.error || 'Error al procesar retiro');
      }
    } catch (err) {
      setError('Error de conexión');
    }
  };

  // ==========================================
  // TOGGLE SWITCHES Y GUARDAR BONO
  // ==========================================
  const handleToggleSetting = async (settingKey) => {
    const newValue = !systemStatus[settingKey];
    setSystemStatus(prev => ({ ...prev, [settingKey]: newValue }));
    
    try {
      await fetch(`${API_URL}/api/admin/settings/toggle`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${localStorage.getItem('token')}` },
        body: JSON.stringify({ setting: settingKey, value: newValue })
      });
      showToast('Ajuste guardado correctamente', 'success');
    } catch (err) {
      setError('Error al guardar ajuste');
      setSystemStatus(prev => ({ ...prev, [settingKey]: !newValue }));
    }
  };

  const handleBonusInputChange = (e) => {
    const { name, value } = e.target;
    setSystemStatus(prev => ({ ...prev, [name]: Number(value) }));
  };

  const handleSaveBonus = async () => {
    try {
      // Guardar Porcentaje
      await fetch(`${API_URL}/api/admin/settings/toggle`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${localStorage.getItem('token')}` },
        body: JSON.stringify({ setting: 'bonus_porcentaje', value: systemStatus.bonus_porcentaje })
      });
      // Guardar Límite
      await fetch(`${API_URL}/api/admin/settings/toggle`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${localStorage.getItem('token')}` },
        body: JSON.stringify({ setting: 'bonus_limite_total', value: systemStatus.bonus_limite_total })
      });
      showToast('Configuración de bono guardada', 'success');
      fetchSystemStatus();
    } catch (err) {
      showToast('Error al guardar configuración de bono', 'error');
    }
  };


  // --- VISTA DE EDICIÓN DE DATOS BANCARIOS ---
  if (editingBankData) {
    return (
      <main className="main-area" style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '80vh', padding: '1rem' }}>
        {toast && <LocalToast message={toast.message} type={toast.type} onClose={() => setToast(null)} />}
        <div style={{ background: '#171b24', padding: '30px', borderRadius: '12px', width: '100%', maxWidth: '500px', border: '1px solid #2d3748', boxShadow: '0 10px 30px rgba(0,0,0,0.5)' }}>
          <h2 style={{ color: '#e2b04a', marginBottom: '10px', textAlign: 'center', fontSize: '1.5rem' }}>Configuración Bancaria (Admin)</h2>
          <p style={{ color: '#a0aec0', marginBottom: '25px', fontSize: '0.9rem', textAlign: 'center' }}>
            Estos son los datos que los jugadores verán cuando quieran depositar.
          </p>
          {error && <p style={{ color: '#ef4444', marginBottom: '15px', background: '#2d1b1b', padding: '10px', borderRadius: '6px', textAlign: 'center', fontSize: '0.9rem' }}>{error}</p>}
          {success && <p style={{ color: '#00e676', marginBottom: '15px', background: '#1b2d1b', padding: '10px', borderRadius: '6px', textAlign: 'center', fontSize: '0.9rem' }}>{success}</p>}
          
          <form onSubmit={handleSaveBankData}>
            <label style={{ color: '#a0aec0', fontSize: '0.8rem', fontWeight: 'bold' }}>Número de Tarjeta Magnética</label>
            <input type="text" value={formData.card_number} onChange={e => setFormData({...formData, card_number: e.target.value})} required placeholder="Ej: 9200 1234 5678 9012" style={{ width: '100%', padding: '10px', marginBottom: '15px', background: '#0b0e14', border: '1px solid #2d3748', color: '#fff', borderRadius: '6px', fontSize: '0.95rem' }} />
            
            <label style={{ color: '#a0aec0', fontSize: '0.8rem', fontWeight: 'bold' }}>Número de Teléfono</label>
            <input type="text" value={formData.phone} onChange={e => setFormData({...formData, phone: e.target.value})} required placeholder="Ej: +53 5555 5555" style={{ width: '100%', padding: '10px', marginBottom: '15px', background: '#0b0e14', border: '1px solid #2d3748', color: '#fff', borderRadius: '6px', fontSize: '0.95rem' }} />
            
            <label style={{ color: '#a0aec0', fontSize: '0.8rem', fontWeight: 'bold' }}>Propietario de la Tarjeta</label>
            <input type="text" value={formData.holder_name} onChange={e => setFormData({...formData, holder_name: e.target.value})} required placeholder="Ej: Juan Pérez" style={{ width: '100%', padding: '10px', marginBottom: '15px', background: '#0b0e14', border: '1px solid #2d3748', color: '#fff', borderRadius: '6px', fontSize: '0.95rem' }} />
            
            <label style={{ color: '#a0aec0', fontSize: '0.8rem', fontWeight: 'bold' }}>Banco al que pertenece</label>
            <input type="text" value={formData.bank_name} onChange={e => setFormData({...formData, bank_name: e.target.value})} required placeholder="Ej: Banco Metropolitano" style={{ width: '100%', padding: '10px', marginBottom: '25px', background: '#0b0e14', border: '1px solid #2d3748', color: '#fff', borderRadius: '6px', fontSize: '0.95rem' }} />
            
            <button type="submit" className="btn" style={{ width: '100%', background: '#e2b04a', color: '#000', fontWeight: 'bold', padding: '12px', fontSize: '1rem' }}>Guardar Datos Bancarios</button>
          </form>
          
          <div style={{ textAlign: 'center', marginTop: '20px' }}>
            <button onClick={onBack} style={{ background: 'transparent', color: '#a0aec0', border: 'none', cursor: 'pointer', fontSize: '0.9rem' }}>
              &lt;- Volver al Lobby
            </button>
          </div>
        </div>
      </main>
    );
  }


  // --- VISTA PRINCIPAL (CON PESTAÑAS) ---
  return (
    <main className="main-area" style={{ width: '100%', display: 'flex', justifyContent: 'center', padding: '2rem 1rem' }}>
      {toast && <LocalToast message={toast.message} type={toast.type} onClose={() => setToast(null)} />}
      
      <div style={{ width: '100%', maxWidth: '1100px' }}>
        
        {/* Cabecera */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
          <div>
            <button onClick={onBack} style={{ background: 'transparent', color: '#a0aec0', border: 'none', cursor: 'pointer', marginBottom: '5px', display: 'flex', alignItems: 'center', gap: '5px', fontSize: '0.9rem' }}>
              &lt;- Volver al Lobby
            </button>
            <h1 style={{ fontSize: '1.8rem', fontWeight: '800', margin: 0 }}>Billetera de Administración</h1>
          </div>
          <button onClick={() => setEditingBankData(true)} style={{ background: '#2d3748', color: '#fff', border: '1px solid #4a5568', padding: '8px 15px', borderRadius: '6px', cursor: 'pointer', fontWeight: 'bold', fontSize: '0.9rem', display: 'flex', alignItems: 'center', gap: '6px' }}>
            Editar Mis Datos
          </button>
        </div>

        {error && <p style={{ color: '#ef4444', marginBottom: '1rem', background: '#2d1b1b', padding: '10px', borderRadius: '6px', fontSize: '0.9rem' }}>{error}</p>}
        {success && <p style={{ color: '#00e676', marginBottom: '1rem', background: '#1b2d1b', padding: '10px', borderRadius: '6px', fontSize: '0.9rem' }}>{success}</p>}

        {/* SISTEMA DE PESTAÑAS */}
        <div style={{ display: 'flex', gap: '5px', borderBottom: '1px solid #2d3748', marginBottom: '1.5rem', overflowX: 'auto' }}>
          {[
            { id: 'solicitudes', label: `Solicitudes (${(data.deposits?.length || 0) + (data.withdrawals?.length || 0)})` },
            { id: 'mis-solicitudes', label: `Mis Solicitudes (${(myTaken.deposits?.length || 0) + (myTaken.withdrawals?.length || 0)})` },
            { id: 'banco', label: 'Banco Global' },
            { id: 'jugadores', label: 'Jugadores' },
            { id: 'ajustes', label: 'Ajustes' }
          ].map(tab => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              style={{
                padding: '12px 20px',
                background: 'transparent',
                border: 'none',
                borderBottom: activeTab === tab.id ? '3px solid #e2b04a' : '3px solid transparent',
                color: activeTab === tab.id ? '#e2b04a' : '#a0aec0',
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

        {/* ================= PESTAÑA 1: SOLICITUDES PENDIENTES ================= */}
        {activeTab === 'solicitudes' && (
          <>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '15px', marginBottom: '1.5rem' }}>
              
              {/* TARJETA DEL FONDO DEL PROYECTO (RAKE) CON BOTÓN DE LIQUIDAR */}
              <div style={{ background: '#171b24', padding: '15px', borderRadius: '8px', border: '1px solid #2d3748', borderLeft: '4px solid #00e676', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div>
                  <p style={{ color: '#a0aec0', margin: '0 0 5px 0', fontSize: '0.85rem', fontWeight: 'bold' }}>Fondo del Proyecto (Rake)</p>
                  <h2 style={{ fontSize: '1.8rem', margin: 0, color: '#00e676' }}>{Number(data.reserves.balance_ntx || 0).toFixed(2)} NTX</h2>
                </div>
                {Number(data.reserves.balance_ntx) > 0 && (
                  <button 
                    onClick={handleLiquidateRake} 
                    disabled={liquidatingRake}
                    style={{ 
                      background: '#ef4444', color: '#fff', border: 'none', padding: '8px 12px', 
                      borderRadius: '6px', cursor: liquidatingRake ? 'not-allowed' : 'pointer', 
                      fontWeight: 'bold', fontSize: '0.8rem', display: 'flex', alignItems: 'center', gap: '5px'
                    }}
                  >
                    {liquidatingRake ? '...' : 'Liquidar'}
                  </button>
                )}
              </div>

              {/* TARJETA DE FONDO DE REFERIDOS */}
              <div style={{ background: '#171b24', padding: '15px', borderRadius: '8px', border: '1px solid #2d3748', borderLeft: '4px solid #3b82f6' }}>
                <p style={{ color: '#a0aec0', margin: '0 0 5px 0', fontSize: '0.85rem', fontWeight: 'bold' }}>Fondo de Referidos</p>
                <h2 style={{ fontSize: '1.8rem', margin: 0, color: '#3b82f6' }}>{Number(data.reserves.referral_fund || 0).toFixed(2)} NTX</h2>
              </div>
              
              <div style={{ background: '#171b24', padding: '15px', borderRadius: '8px', border: '1px solid #2d3748' }}>
                <p style={{ color: '#a0aec0', margin: '0 0 5px 0', fontSize: '0.85rem' }}>Depósitos Pendientes</p>
                <h2 style={{ fontSize: '1.8rem', margin: 0, color: '#e2b04a' }}>{data.deposits.length}</h2>
              </div>
              <div style={{ background: '#171b24', padding: '15px', borderRadius: '8px', border: '1px solid #2d3748' }}>
                <p style={{ color: '#a0aec0', margin: '0 0 5px 0', fontSize: '0.85rem' }}>Retiros Pendientes</p>
                <h2 style={{ fontSize: '1.8rem', margin: 0, color: '#e2b04a' }}>{data.withdrawals.length}</h2>
              </div>
            </div>

            {loading ? (
              <div style={{ textAlign: 'center', padding: '40px' }}>
                <p style={{ color: '#a0aec0', fontSize: '1.1rem' }}>Cargando solicitudes...</p>
              </div>
            ) : (
              <>
                {/* TABLA DEPOSITOS */}
                <div style={{ background: '#171b24', borderRadius: '8px', border: '1px solid #2d3748', overflow: 'hidden', marginBottom: '1.5rem' }}>
                  <div style={{ padding: '12px 15px', borderBottom: '1px solid #2d3748', background: '#1a202c' }}>
                    <h3 style={{ margin: 0, fontSize: '1.1rem' }}>Depósitos por Verificar</h3>
                  </div>
                  <div style={{ overflowX: 'auto' }}>
                    <table style={{ width: '100%', textAlign: 'left', borderCollapse: 'collapse', minWidth: '600px' }}>
                      <thead>
                        <tr style={{ background: '#0b0e14', color: '#a0aec0', fontSize: '0.8rem' }}>
                          <th style={{ padding: '10px 15px' }}>ID</th>
                          <th style={{ padding: '10px 15px' }}>Jugador</th>
                          <th style={{ padding: '10px 15px' }}>Monto (CUP)</th>
                          <th style={{ padding: '10px 15px' }}>ID Transf.</th>
                          <th style={{ padding: '10px 15px' }}>Acción</th>
                        </tr>
                      </thead>
                      <tbody>
                        {data.deposits.length === 0 ? (
                          <tr><td colSpan="5" style={{ padding: '20px', textAlign: 'center', color: '#718096', fontSize: '0.9rem' }}>No hay depósitos pendientes</td></tr>
                        ) : data.deposits.map(d => (
                          <tr key={d.id} style={{ borderBottom: '1px solid #2d3748' }}>
                            <td style={{ padding: '10px 15px', color: '#a0aec0', fontSize: '0.9rem' }}>#{d.id}</td>
                            <td style={{ padding: '10px 15px', fontWeight: 'bold', fontSize: '0.9rem' }}>{d.username}</td>
                            <td style={{ padding: '10px 15px', color: '#00e676', fontWeight: 'bold', fontSize: '0.9rem' }}>{d.amount_cup}</td>
                            <td style={{ padding: '10px 15px', color: '#a0aec0', fontSize: '0.9rem' }}>{d.transaction_id}</td>
                            <td style={{ padding: '10px 15px' }}>
                              <button onClick={() => takeDeposit(d.id)} style={{ background: '#00e676', color: '#000', border: 'none', padding: '6px 12px', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold', fontSize: '0.8rem' }}>Tomar</button>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>

                {/* TABLA RETIROS */}
                <div style={{ background: '#171b24', borderRadius: '8px', border: '1px solid #2d3748', overflow: 'hidden', marginBottom: '1.5rem' }}>
                  <div style={{ padding: '12px 15px', borderBottom: '1px solid #2d3748', background: '#1a202c' }}>
                    <h3 style={{ margin: 0, fontSize: '1.1rem' }}>Retiros Pendientes</h3>
                  </div>
                  <div style={{ overflowX: 'auto' }}>
                    <table style={{ width: '100%', textAlign: 'left', borderCollapse: 'collapse', minWidth: '700px' }}>
                      <thead>
                        <tr style={{ background: '#0b0e14', color: '#a0aec0', fontSize: '0.8rem' }}>
                          <th style={{ padding: '10px 15px' }}>ID</th>
                          <th style={{ padding: '10px 15px' }}>Jugador</th>
                          <th style={{ padding: '10px 15px' }}>Monto (NTX)</th>
                          <th style={{ padding: '10px 15px' }}>Datos Bancarios</th>
                          <th style={{ padding: '10px 15px' }}>Acción</th>
                        </tr>
                      </thead>
                      <tbody>
                        {data.withdrawals.length === 0 ? (
                          <tr><td colSpan="5" style={{ padding: '20px', textAlign: 'center', color: '#718096', fontSize: '0.9rem' }}>No hay retiros pendientes</td></tr>
                        ) : data.withdrawals.map(w => (
                          <tr key={w.id} style={{ borderBottom: '1px solid #2d3748' }}>
                            <td style={{ padding: '10px 15px', color: '#a0aec0', fontSize: '0.9rem' }}>#{w.id}</td>
                            <td style={{ padding: '10px 15px', fontWeight: 'bold', fontSize: '0.9rem' }}>{w.username}</td>
                            <td style={{ padding: '10px 15px', color: '#e2b04a', fontWeight: 'bold', fontSize: '0.9rem' }}>{w.amount_ntx}</td>
                            <td style={{ padding: '10px 15px', fontSize: '0.8rem', color: '#a0aec0', lineHeight: '1.4' }}>
                              <strong>Tarjeta:</strong> {w.card_number}<br/>
                              <strong>Titular:</strong> {w.holder_name}<br/>
                              <strong>Banco:</strong> {w.bank_name}
                            </td>
                            <td style={{ padding: '10px 15px' }}>
                              <button onClick={() => takeWithdrawal(w.id)} style={{ background: '#e2b04a', color: '#000', border: 'none', padding: '6px 12px', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold', fontSize: '0.8rem' }}>Tomar</button>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              </>
            )}
          </>
        )}

        {/* ================= PESTAÑA 2: MIS SOLICITUDES ================= */}
        {activeTab === 'mis-solicitudes' && (
          <>
            <div style={{ background: '#171b24', borderRadius: '8px', border: '1px solid #2d3748', overflow: 'hidden', marginBottom: '1.5rem' }}>
              <div style={{ padding: '12px 15px', borderBottom: '1px solid #2d3748', background: '#1a202c' }}>
                <h3 style={{ margin: 0, fontSize: '1.1rem' }}>Depósitos que he tomado</h3>
              </div>
              <div style={{ overflowX: 'auto' }}>
                <table style={{ width: '100%', textAlign: 'left', borderCollapse: 'collapse', minWidth: '600px' }}>
                  <thead>
                    <tr style={{ background: '#0b0e14', color: '#a0aec0', fontSize: '0.8rem' }}>
                      <th style={{ padding: '10px 15px' }}>ID</th>
                      <th style={{ padding: '10px 15px' }}>Jugador</th>
                      <th style={{ padding: '10px 15px' }}>Monto (CUP)</th>
                      <th style={{ padding: '10px 15px' }}>ID Transf.</th>
                      <th style={{ padding: '10px 15px' }}>Acción</th>
                    </tr>
                  </thead>
                  <tbody>
                    {myTaken.deposits?.length === 0 ? (
                      <tr><td colSpan="5" style={{ padding: '20px', textAlign: 'center', color: '#718096', fontSize: '0.9rem' }}>No has tomado ningún depósito</td></tr>
                    ) : myTaken.deposits?.map(d => (
                      <tr key={d.id} style={{ borderBottom: '1px solid #2d3748' }}>
                        <td style={{ padding: '10px 15px', color: '#a0aec0', fontSize: '0.9rem' }}>#{d.id}</td>
                        <td style={{ padding: '10px 15px', fontWeight: 'bold', fontSize: '0.9rem' }}>{d.username}</td>
                        <td style={{ padding: '10px 15px', color: '#00e676', fontWeight: 'bold', fontSize: '0.9rem' }}>{d.amount_cup}</td>
                        <td style={{ padding: '10px 15px', color: '#a0aec0', fontSize: '0.9rem' }}>{d.transaction_id}</td>
                        <td style={{ padding: '10px 15px', display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
                          <button onClick={() => handleDeposit(d.id)} style={{ background: '#00e676', color: '#000', border: 'none', padding: '6px 12px', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold', fontSize: '0.8rem' }}>Aprobar</button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>

            <div style={{ background: '#171b24', borderRadius: '8px', border: '1px solid #2d3748', overflow: 'hidden', marginBottom: '1.5rem' }}>
              <div style={{ padding: '12px 15px', borderBottom: '1px solid #2d3748', background: '#1a202c' }}>
                <h3 style={{ margin: 0, fontSize: '1.1rem' }}>Retiros que he tomado</h3>
              </div>
              <div style={{ overflowX: 'auto' }}>
                <table style={{ width: '100%', textAlign: 'left', borderCollapse: 'collapse', minWidth: '700px' }}>
                  <thead>
                    <tr style={{ background: '#0b0e14', color: '#a0aec0', fontSize: '0.8rem' }}>
                      <th style={{ padding: '10px 15px' }}>ID</th>
                      <th style={{ padding: '10px 15px' }}>Jugador</th>
                      <th style={{ padding: '10px 15px' }}>Monto (NTX)</th>
                      <th style={{ padding: '10px 15px' }}>Datos Bancarios</th>
                      <th style={{ padding: '10px 15px' }}>Acción</th>
                    </tr>
                  </thead>
                  <tbody>
                    {myTaken.withdrawals?.length === 0 ? (
                      <tr><td colSpan="5" style={{ padding: '20px', textAlign: 'center', color: '#718096', fontSize: '0.9rem' }}>No has tomado ningún retiro</td></tr>
                    ) : myTaken.withdrawals?.map(w => (
                      <tr key={w.id} style={{ borderBottom: '1px solid #2d3748' }}>
                        <td style={{ padding: '10px 15px', color: '#a0aec0', fontSize: '0.9rem' }}>#{w.id}</td>
                        <td style={{ padding: '10px 15px', fontWeight: 'bold', fontSize: '0.9rem' }}>{w.username}</td>
                        <td style={{ padding: '10px 15px', color: '#e2b04a', fontWeight: 'bold', fontSize: '0.9rem' }}>{w.amount_ntx}</td>
                        <td style={{ padding: '10px 15px', fontSize: '0.8rem', color: '#a0aec0', lineHeight: '1.4' }}>
                          <strong>Tarjeta:</strong> {w.card_number}<br/>
                          <strong>Titular:</strong> {w.holder_name}<br/>
                          <strong>Banco:</strong> {w.bank_name}
                        </td>
                        <td style={{ padding: '10px 15px', display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
                          <button onClick={() => handleWithdraw(w.id, 'approve')} style={{ background: '#00e676', color: '#000', border: 'none', padding: '6px 12px', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold', fontSize: '0.8rem' }}>Ya pagué</button>
                          <button onClick={() => handleWithdraw(w.id, 'reject')} style={{ background: '#ef4444', color: '#fff', border: 'none', padding: '6px 12px', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold', fontSize: '0.8rem' }}>Rechazar</button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </>
        )}

        {/* ================= PESTAÑA 3: BANCO GLOBAL ================= */}
        {activeTab === 'banco' && (
          <div>
            <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: '1rem' }}>
              <button
                onClick={() => setShowFundModal(true)}
                style={{ background: '#00e676', color: '#000', border: 'none', padding: '10px 20px', borderRadius: '8px', cursor: 'pointer', fontWeight: 'bold', fontSize: '0.95rem', display: 'flex', alignItems: 'center', gap: '8px', boxShadow: '0 4px 12px rgba(0,230,118,0.3)' }}
              >
                Agregar Fondo
              </button>
            </div>

            <div style={{ background: 'linear-gradient(145deg, #171b24 0%, #12161f 100%)', padding: '30px', borderRadius: '12px', border: '1px solid #2d3748', marginBottom: '2rem' }}>
              <h2 style={{ fontSize: '1.2rem', color: '#a0aec0', marginBottom: '20px', fontWeight: 'normal' }}>Resumen Global del Banco</h2>
              
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '20px' }}>
                <div>
                  <p style={{ margin: 0, color: '#718096', fontSize: '0.9rem', marginBottom: '5px' }}>Total Disponible</p>
                  <h1 style={{ margin: 0, color: '#00e676', fontSize: '2.2rem' }}>{bankData.total_disponible.toLocaleString()} <span style={{ fontSize: '1rem' }}>fichas</span></h1>
                </div>
                <div>
                  <p style={{ margin: 0, color: '#718096', fontSize: '0.9rem', marginBottom: '5px' }}>Saldo Real</p>
                  <h2 style={{ margin: 0, color: '#fff', fontSize: '1.8rem' }}>{bankData.total_saldo.toLocaleString()}</h2>
                </div>
                <div>
                  <p style={{ margin: 0, color: '#718096', fontSize: '0.9rem', marginBottom: '5px' }}>Fondo Real</p>
                  <h2 style={{ margin: 0, color: '#e2b04a', fontSize: '1.8rem' }}>{bankData.total_fondo.toLocaleString()}</h2>
                </div>
              </div>

              <div style={{ display: 'flex', gap: '30px', marginTop: '20px', borderTop: '1px solid #2d3748', paddingTop: '20px' }}>
                <div>
                  <p style={{ margin: 0, color: '#718096', fontSize: '0.9rem', marginBottom: '5px' }}>Total Recibido</p>
                  <h3 style={{ margin: 0, color: '#fff', fontSize: '1.2rem' }}>{bankData.total_recibido.toLocaleString()}</h3>
                </div>
                <div>
                  <p style={{ margin: 0, color: '#718096', fontSize: '0.9rem', marginBottom: '5px' }}>Total Retirado</p>
                  <h3 style={{ margin: 0, color: '#ef4444', fontSize: '1.2rem' }}>{bankData.total_retirado.toLocaleString()}</h3>
                </div>
              </div>
            </div>

            <h3 style={{ fontSize: '1.2rem', marginBottom: '15px' }}>Desglose por Administrador</h3>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '15px' }}>
              {bankData.admins.map((admin, idx) => {
                const porcentaje = bankData.total_disponible > 0 
                  ? ((admin.disponible / bankData.total_disponible) * 100).toFixed(1) 
                  : 0;

                return (
                  <div key={idx} style={{ background: '#171b24', padding: '20px', borderRadius: '8px', border: '1px solid #2d3748', position: 'relative', overflow: 'hidden' }}>
                    <div style={{ position: 'absolute', top: 0, left: 0, height: '4px', background: '#00e676', width: `${porcentaje}%`, transition: 'width 0.5s ease' }}></div>

                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px', borderBottom: '1px solid #2d3748', paddingBottom: '10px' }}>
                      <h4 style={{ margin: 0, color: '#fff', fontSize: '1.1rem' }}>{admin.nombre}</h4>
                      <span style={{ background: 'rgba(0, 230, 118, 0.1)', color: '#00e676', padding: '4px 8px', borderRadius: '4px', fontSize: '0.8rem', fontWeight: 'bold' }}>
                        {porcentaje}% del Banco
                      </span>
                    </div>

                    <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '10px' }}>
                      <span style={{ color: '#a0aec0', fontSize: '0.9rem' }}>Disponible:</span>
                      <strong style={{ color: '#00e676', fontSize: '1rem' }}>{admin.disponible.toLocaleString()} $</strong>
                    </div>
                    
                    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px', marginBottom: '15px' }}>
                      <div style={{ background: '#0b0e14', padding: '8px', borderRadius: '6px' }}>
                        <span style={{ display: 'block', color: '#718096', fontSize: '0.75rem', marginBottom: '2px' }}>Saldo</span>
                        <span style={{ color: '#fff', fontSize: '0.9rem', fontWeight: 'bold' }}>{admin.saldo.toLocaleString()}</span>
                      </div>
                      <div style={{ background: '#0b0e14', padding: '8px', borderRadius: '6px' }}>
                        <span style={{ display: 'block', color: '#718096', fontSize: '0.75rem', marginBottom: '2px' }}>Fondo</span>
                        <span style={{ color: '#e2b04a', fontSize: '0.9rem', fontWeight: 'bold' }}>{admin.fondo.toLocaleString()}</span>
                      </div>
                    </div>

                    <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.8rem', color: '#718096', borderTop: '1px dashed #2d3748', paddingTop: '10px' }}>
                      <span>Recibido: <strong style={{ color: '#fff' }}>{admin.recibido.toLocaleString()}</strong></span>
                      <span>Retirado: <strong style={{ color: '#ef4444' }}>{admin.retirado.toLocaleString()}</strong></span>
                    </div>
                  </div>
                );
              })}
            </div>

            {/* TABLA DE AUDITORÍA */}
            <div style={{ background: '#171b24', borderRadius: '8px', border: '1px solid #2d3748', overflow: 'hidden', marginTop: '2rem' }}>
              <div style={{ padding: '12px 15px', borderBottom: '1px solid #2d3748', background: '#1a202c', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <h3 style={{ margin: 0, fontSize: '1.1rem' }}>Registro de Auditoría (Historial)</h3>
                <span style={{ fontSize: '0.75rem', color: '#718096' }}>Registro inmutable de movimientos</span>
              </div>
              <div style={{ overflowX: 'auto' }}>
                <table style={{ width: '100%', textAlign: 'left', borderCollapse: 'collapse', minWidth: '800px' }}>
                  <thead>
                    <tr style={{ background: '#0b0e14', color: '#a0aec0', fontSize: '0.8rem' }}>
                      <th style={{ padding: '10px 15px' }}>Fecha</th>
                      <th style={{ padding: '10px 15px' }}>Jugador</th>
                      <th style={{ padding: '10px 15px' }}>Tipo</th>
                      <th style={{ padding: '10px 15px' }}>Monto</th>
                      <th style={{ padding: '10px 15px' }}>Estado</th>
                      <th style={{ padding: '10px 15px' }}>Gestor</th>
                    </tr>
                  </thead>
                  <tbody>
                    {auditLog.length === 0 ? (
                      <tr><td colSpan="6" style={{ padding: '20px', textAlign: 'center', color: '#718096', fontSize: '0.9rem' }}>No hay registros de auditoría aún.</td></tr>
                    ) : auditLog.map(log => (
                      <tr key={log.id} style={{ borderBottom: '1px solid #2d3748' }}>
                        <td style={{ padding: '10px 15px', color: '#a0aec0', fontSize: '0.85rem' }}>{log.date}</td>
                        <td style={{ padding: '10px 15px', fontWeight: 'bold', fontSize: '0.85rem' }}>{log.username}</td>
                        <td style={{ padding: '10px 15px', fontSize: '0.85rem' }}>
                          <span style={{ 
                            background: log.type === 'Depósito' ? 'rgba(0, 230, 118, 0.2)' : 'rgba(226, 176, 74, 0.2)', 
                            color: log.type === 'Depósito' ? '#00e676' : '#e2b04a',
                            padding: '2px 8px', borderRadius: '4px', fontWeight: 'bold'
                          }}>
                            {log.type}
                          </span>
                        </td>
                        <td style={{ padding: '10px 15px', fontWeight: 'bold', fontSize: '0.85rem', color: '#fff' }}>{log.amount}</td>
                        <td style={{ padding: '10px 15px', fontSize: '0.85rem' }}>
                          <span style={{ color: log.status === 'Aprobado' ? '#00e676' : log.status === 'Rechazado' ? '#ef4444' : '#a0aec0', fontWeight: 'bold' }}>
                            {log.status}
                          </span>
                        </td>
                        <td style={{ padding: '10px 15px', color: '#718096', fontSize: '0.85rem' }}>{log.admin}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        )}

        {/* ================= PESTAÑA 4: JUGADORES ================= */}
        {activeTab === 'jugadores' && (
          <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
              <h2 style={{ fontSize: '1.3rem', margin: 0 }}>Lista de Jugadores</h2>
              <button onClick={fetchPlayers} style={{ background: '#2d3748', color: '#fff', border: 'none', padding: '8px 15px', borderRadius: '6px', cursor: 'pointer', fontWeight: 'bold' }}>Actualizar</button>
            </div>

            {loadingPlayers ? (
              <p style={{ color: '#a0aec0', textAlign: 'center' }}>Cargando jugadores...</p>
            ) : (
              <div style={{ background: '#171b24', borderRadius: '8px', border: '1px solid #2d3748', overflow: 'hidden' }}>
                <div style={{ overflowX: 'auto' }}>
                  <table style={{ width: '100%', textAlign: 'left', borderCollapse: 'collapse', minWidth: '800px' }}>
                    <thead>
                      <tr style={{ background: '#0b0e14', color: '#a0aec0', fontSize: '0.8rem' }}>
                        <th style={{ padding: '15px' }}>ID</th>
                        <th style={{ padding: '15px' }}>Usuario</th>
                        <th style={{ padding: '15px' }}>Contacto</th>
                        <th style={{ padding: '15px' }}>Saldo (NTX)</th>
                        <th style={{ padding: '15px' }}>Estado</th>
                        <th style={{ padding: '15px' }}>Acciones</th>
                      </tr>
                    </thead>
                    <tbody>
                      {players.length === 0 ? (
                        <tr><td colSpan="6" style={{ padding: '20px', textAlign: 'center', color: '#718096' }}>No hay jugadores registrados</td></tr>
                      ) : players.map(p => (
                        <tr key={p.id} style={{ borderBottom: '1px solid #2d3748', background: p.is_blocked ? 'rgba(239,68,68,0.05)' : 'transparent' }}>
                          <td style={{ padding: '15px', color: '#a0aec0' }}>#{p.id}</td>
                          <td style={{ padding: '15px', fontWeight: 'bold' }}>{p.username}</td>
                          <td style={{ padding: '15px', fontSize: '0.85rem', color: '#a0aec0' }}>
                            {p.email || 'Sin correo'}<br/>
                            <span style={{ fontSize: '0.75rem' }}>{p.phone || 'Sin teléfono'}</span>
                          </td>
                          <td style={{ padding: '15px', color: '#00e676', fontWeight: 'bold' }}>{Number(p.balance).toFixed(2)}</td>
                          <td style={{ padding: '15px' }}>
                            <span style={{ 
                              background: p.is_blocked ? 'rgba(239,68,68,0.2)' : 'rgba(0,230,118,0.2)', 
                              color: p.is_blocked ? '#ef4444' : '#00e676',
                              padding: '4px 10px', borderRadius: '12px', fontSize: '0.8rem', fontWeight: 'bold'
                            }}>
                              {p.is_blocked ? 'Bloqueado' : 'Activo'}
                            </span>
                          </td>
                          <td style={{ padding: '15px', display: 'flex', gap: '10px' }}>
                            <button 
                              onClick={() => handleToggleBlock(p.id)} 
                              style={{ background: p.is_blocked ? '#00e676' : '#e2b04a', color: '#000', border: 'none', padding: '6px 12px', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold', fontSize: '0.75rem' }}
                            >
                              {p.is_blocked ? 'Desbloquear' : 'Bloquear'}
                            </button>
                            <button 
                              onClick={() => handleDeletePlayer(p.id)} 
                              style={{ background: 'transparent', border: '1px solid #ef4444', color: '#ef4444', padding: '6px 12px', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold', fontSize: '0.75rem' }}
                            >
                              Eliminar
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            )}
          </div>
        )}

        {/* ================= PESTAÑA 5: AJUSTES (SWITCHES Y BONO) ================= */}
        {activeTab === 'ajustes' && (
          <div style={{ background: '#171b24', borderRadius: '12px', border: '1px solid #2d3748', padding: '30px', maxWidth: '700px', margin: '0 auto' }}>
            <h2 style={{ fontSize: '1.3rem', margin: '0 0 10px 0' }}>Ajustes de la Billetera</h2>
            <p style={{ color: '#a0aec0', fontSize: '0.9rem', marginBottom: '30px' }}>Activa o desactiva los sistemas para los jugadores.</p>
            
            {/* SWITCH 1: RETIROS */}
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '20px 0', borderBottom: '1px solid #2d3748' }}>
              <div>
                <h4 style={{ margin: '0 0 5px 0', fontSize: '1.1rem', color: '#fff' }}>Sistema de Retiros</h4>
                <p style={{ margin: 0, color: '#718096', fontSize: '0.85rem' }}>Permite a los jugadores solicitar retiros de sus ganancias.</p>
              </div>
              
              <div 
                onClick={() => handleToggleSetting('retiros_activos')}
                style={{ 
                  width: '56px', height: '30px', borderRadius: '20px', cursor: 'pointer',
                  background: systemStatus.retiros_activos ? '#00e676' : '#4a5568',
                  position: 'relative', transition: 'background 0.3s',
                  boxShadow: systemStatus.retiros_activos ? '0 0 10px rgba(0, 230, 118, 0.4)' : 'none'
                }}
              >
                <div style={{
                  width: '24px', height: '24px', borderRadius: '50%', background: '#fff',
                  position: 'absolute', top: '3px', left: systemStatus.retiros_activos ? '29px' : '3px',
                  transition: 'left 0.3s', boxShadow: '0 2px 4px rgba(0,0,0,0.2)'
                }} />
              </div>
            </div>

            {/* SWITCH 2: INVERSIONES */}
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '20px 0', borderBottom: '1px solid #2d3748' }}>
              <div>
                <h4 style={{ margin: '0 0 5px 0', fontSize: '1.1rem', color: '#fff' }}>Sistema de Inversiones / Depósitos</h4>
                <p style={{ margin: 0, color: '#718096', fontSize: '0.85rem' }}>Permite a los jugadores depositar dinero para comprar fichas.</p>
              </div>
              
              <div 
                onClick={() => handleToggleSetting('inversiones_activas')}
                style={{ 
                  width: '56px', height: '30px', borderRadius: '20px', cursor: 'pointer',
                  background: systemStatus.inversiones_activas ? '#00e676' : '#4a5568',
                  position: 'relative', transition: 'background 0.3s',
                  boxShadow: systemStatus.inversiones_activas ? '0 0 10px rgba(0, 230, 118, 0.4)' : 'none'
                }}
              >
                <div style={{
                  width: '24px', height: '24px', borderRadius: '50%', background: '#fff',
                  position: 'absolute', top: '3px', left: systemStatus.inversiones_activas ? '29px' : '3px',
                  transition: 'left 0.3s', boxShadow: '0 2px 4px rgba(0,0,0,0.2)'
                }} />
              </div>
            </div>

            {/* SECCIÓN: BONO DE INVERSIÓN */}
            <div style={{ marginTop: '30px', paddingTop: '20px', borderTop: '1px solid #2d3748' }}>
              <h4 style={{ margin: '0 0 5px 0', fontSize: '1.1rem', color: '#00e676' }}>
                Bono de Inversión
              </h4>
              <p style={{ margin: '0 0 20px 0', color: '#718096', fontSize: '0.85rem' }}>
                Configura el porcentaje extra que recibirán los jugadores al depositar. Cuando la bolsa se agote, el bono se desactivará automáticamente.
              </p>
              
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', marginBottom: '15px' }}>
                <div>
                  <label style={{ display: 'block', color: '#a0aec0', fontSize: '0.85rem', marginBottom: '5px' }}>Porcentaje de Bono (%)</label>
                  <input 
                    type="number" 
                    name="bonus_porcentaje"
                    value={systemStatus.bonus_porcentaje} 
                    onChange={handleBonusInputChange} 
                    min="0" 
                    max="100" 
                    style={{ width: '100%', padding: '10px', background: '#0b0e14', border: '1px solid #2d3748', color: '#fff', borderRadius: '6px' }} 
                  />
                </div>
                <div>
                  <label style={{ display: 'block', color: '#a0aec0', fontSize: '0.85rem', marginBottom: '5px' }}>Límite Total de la Bolsa (NTX)</label>
                  <input 
                    type="number" 
                    name="bonus_limite_total"
                    value={systemStatus.bonus_limite_total} 
                    onChange={handleBonusInputChange} 
                    min="0" 
                    style={{ width: '100%', padding: '10px', background: '#0b0e14', border: '1px solid #2d3748', color: '#fff', borderRadius: '6px' }} 
                  />
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', marginBottom: '15px' }}>
                <div style={{ background: '#0b0e14', padding: '12px', borderRadius: '6px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <span style={{ color: '#a0aec0', fontSize: '0.85rem' }}>Bolsa Usada:</span>
                  <strong style={{ color: '#ef4444', fontSize: '1rem' }}>{systemStatus.bonus_usado.toFixed(2)} NTX</strong>
                </div>
                <div style={{ background: '#0b0e14', padding: '12px', borderRadius: '6px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <span style={{ color: '#a0aec0', fontSize: '0.85rem' }}>Bolsa Restante:</span>
                  <strong style={{ color: '#00e676', fontSize: '1rem' }}>{(systemStatus.bonus_limite_total - systemStatus.bonus_usado).toFixed(2)} NTX</strong>
                </div>
              </div>

              <button 
                onClick={handleSaveBonus} 
                style={{ width: '100%', padding: '12px', background: '#00e676', color: '#000', border: 'none', borderRadius: '6px', fontWeight: 'bold', cursor: 'pointer', fontSize: '0.95rem' }}
              >
                Guardar Configuración de Bono
              </button>
            </div>

          </div>
        )}

      </div>

      {/* MODAL AGREGAR FONDO */}
      {showFundModal && (
        <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', background: 'rgba(0,0,0,0.85)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 10000, backdropFilter: 'blur(5px)' }}>
          <div style={{ background: '#171b24', padding: '30px', borderRadius: '12px', width: '100%', maxWidth: '420px', border: '1px solid #2d3748', boxShadow: '0 20px 50px rgba(0,0,0,0.9)', position: 'relative' }}>
            <button
              onClick={() => { setShowFundModal(false); setFundForm({ admin_id: '', amount: '' }); }}
              style={{ position: 'absolute', top: '15px', right: '15px', background: 'transparent', border: 'none', color: '#a0aec0', fontSize: '1.5rem', cursor: 'pointer' }}
            >
              X
            </button>

            <h2 style={{ color: '#00e676', marginBottom: '10px', fontSize: '1.4rem' }}>Agregar Fondo</h2>
            <p style={{ color: '#a0aec0', marginBottom: '25px', fontSize: '0.85rem' }}>
              Inyecta NTX al fondo de un administrador. Este saldo no afecta el balance de los jugadores.
            </p>

            <label style={{ color: '#a0aec0', fontSize: '0.8rem', fontWeight: 'bold' }}>Administrador destino</label>
            <select
              value={fundForm.admin_id}
              onChange={e => setFundForm({ ...fundForm, admin_id: e.target.value })}
              style={{ width: '100%', padding: '10px', marginBottom: '15px', background: '#0b0e14', border: '1px solid #2d3748', color: '#fff', borderRadius: '6px', fontSize: '0.95rem' }}
            >
              <option value="">-- Selecciona un admin --</option>
              {bankData.admins.map(a => (
                <option key={a.id} value={a.id}>{a.nombre}</option>
              ))}
            </select>

            <label style={{ color: '#a0aec0', fontSize: '0.8rem', fontWeight: 'bold' }}>Monto (NTX)</label>
            <input
              type="number"
              value={fundForm.amount}
              onChange={e => setFundForm({ ...fundForm, amount: e.target.value })}
              placeholder="Ej: 500"
              min="1"
              step="0.01"
              style={{ width: '100%', padding: '10px', marginBottom: '25px', background: '#0b0e14', border: '1px solid #2d3748', color: '#fff', borderRadius: '6px', fontSize: '0.95rem' }}
            />

            <div style={{ display: 'flex', gap: '10px' }}>
              <button
                onClick={() => { setShowFundModal(false); setFundForm({ admin_id: '', amount: '' }); }}
                style={{ flex: 1, padding: '12px', background: '#2d3748', color: '#fff', border: 'none', borderRadius: '8px', fontWeight: 'bold', cursor: 'pointer' }}
              >
                Cancelar
              </button>
              <button
                onClick={handleAddFund}
                style={{ flex: 1, padding: '12px', background: '#00e676', color: '#000', border: 'none', borderRadius: '8px', fontWeight: 'bold', cursor: 'pointer' }}
              >
                Confirmar
              </button>
            </div>
          </div>
        </div>
      )}

    </main>
  );
}