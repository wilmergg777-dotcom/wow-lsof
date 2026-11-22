import React, { useState, useEffect, useCallback } from 'react';
import { API_URL } from './config';

// 🔥 PREVISUALIZACIÓN de los estilos de cartas (igual que en la mesa)
const STYLE_PREVIEWS = {
  clasico:   { face: 'linear-gradient(135deg, #ffffff 0%, #e0e0e0 100%)', back: 'repeating-linear-gradient(45deg, #1a202c, #1a202c 10px, #2d3748 10px, #2d3748 20px)', border: '#555', color: '#111' },
  neon:      { face: 'linear-gradient(135deg, #0f172a 0%, #1e293b 100%)', back: 'repeating-linear-gradient(45deg, #0f172a, #0f172a 10px, #164e63 10px, #164e63 20px)', border: '#22d3ee', color: '#22d3ee' },
  vintage:   { face: 'linear-gradient(135deg, #f5e6c8 0%, #e3cb9a 100%)', back: 'repeating-linear-gradient(45deg, #4a3728, #4a3728 10px, #6b4f3a 10px, #6b4f3a 20px)', border: '#8b6f47', color: '#111' },
  esmeralda: { face: 'linear-gradient(135deg, #ecfdf5 0%, #a7f3d0 100%)', back: 'repeating-linear-gradient(45deg, #022c22, #022c22 10px, #065f46 10px, #065f46 20px)', border: '#10b981', color: '#065f46' },
  dorado:    { face: 'linear-gradient(135deg, #fffbeb 0%, #fde68a 100%)', back: 'repeating-linear-gradient(45deg, #422006, #422006 10px, #b45309 10px, #b45309 20px)', border: '#f59e0b', color: '#b45309' },
  royal:     { face: 'linear-gradient(135deg, #faf5ff 0%, #e9d5ff 100%)', back: 'repeating-linear-gradient(45deg, #2e1065, #2e1065 10px, #6d28d9 10px, #6d28d9 20px)', border: '#a855f7', color: '#6b21a8' },
};

const MiniCard = ({ styleKey }) => {
  const skin = STYLE_PREVIEWS[styleKey] || STYLE_PREVIEWS.clasico;
  return (
    <div style={{ width: '46px', height: '64px', borderRadius: '6px', background: skin.face, border: `1px solid ${skin.border}`, boxShadow: '0 4px 10px rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: skin.color, fontWeight: '900', fontSize: '1.05rem' }}>
      ♠
    </div>
  );
};

const PriceTag = ({ price }) => (
  <div style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
    <img src="/ntx.png" alt="NTX" style={{ width: '16px', height: '16px', borderRadius: '50%' }} onError={(e) => { e.target.style.display = 'none'; }} />
    <span style={{ color: '#e2b04a', fontWeight: 'bold', fontSize: '13px' }}>
      {Number(price) === 0 ? 'Gratis' : `${Number(price).toFixed(0)} NTX-20`}
    </span>
  </div>
);

const Tienda = ({ user, onBack, fetchBalance }) => {
  const [tab, setTab] = useState('emotes');
  const [items, setItems] = useState({ emotes: [], cardStyles: [] });
  const [loading, setLoading] = useState(true);
  const [busyId, setBusyId] = useState(null);
  const [toast, setToast] = useState(null);

  const showToast = (msg, type = 'ok') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const loadShop = useCallback(async () => {
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`${API_URL}/api/shop/items`, { headers: { Authorization: `Bearer ${token}` } });
      if (!res.ok) throw new Error('No se pudo cargar la tienda');
      setItems(await res.json());
    } catch (e) {
      showToast(e.message, 'error');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { loadShop(); }, [loadShop]);

  const buyItem = async (item) => {
    if (!window.confirm(`¿Comprar "${item.name}" por ${Number(item.price_ntx).toFixed(0)} NTX-20?`)) return;
    setBusyId(item.id);
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`${API_URL}/api/shop/purchase`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
        body: JSON.stringify({ itemId: item.id }),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Error al comprar');
      showToast(`¡Compraste ${item.name}!`);
      if (fetchBalance) fetchBalance();
      await loadShop();
    } catch (e) {
      showToast(e.message, 'error');
    } finally {
      setBusyId(null);
    }
  };

  const equipStyle = async (item) => {
    setBusyId(item.id);
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`${API_URL}/api/shop/equip`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
        body: JSON.stringify({ itemId: item.id }),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Error al equipar');
      showToast(`Estilo "${item.name}" equipado`);
      await loadShop();
    } catch (e) {
      showToast(e.message, 'error');
    } finally {
      setBusyId(null);
    }
  };

  const list = tab === 'emotes' ? items.emotes : items.cardStyles;

  return (
    <div style={{ backgroundColor: '#0a0a0a', minHeight: '100vh', color: 'white', paddingBottom: '40px' }}>
      {/* Cabecera */}
      <div style={{ display: 'flex', alignItems: 'center', padding: '15px 20px', borderBottom: '1px solid #222', position: 'sticky', top: 0, backgroundColor: '#0a0a0a', zIndex: 10 }}>
        <button onClick={onBack} style={{ background: 'none', border: 'none', color: 'white', fontSize: '24px', cursor: 'pointer', marginRight: '15px' }}>‹</button>
        <h2 style={{ margin: 0, fontSize: '18px', flex: 1 }}>Tienda</h2>
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px', background: '#1e1e1e', padding: '6px 12px', borderRadius: '20px' }}>
          <img src="/ntx.png" alt="NTX" style={{ width: '16px', height: '16px', borderRadius: '50%' }} onError={(e) => { e.target.style.display = 'none'; }} />
          <span style={{ color: '#e2b04a', fontWeight: 'bold', fontSize: '13px' }}>NTX-20</span>
        </div>
      </div>

      {/* Aviso */}
      <div style={{ margin: '15px 20px 0', background: '#141414', border: '1px solid #222', borderRadius: '10px', padding: '12px 15px', color: '#aaa', fontSize: '13px' }}>
        🛍️ Compra <strong style={{ color: '#00b86b' }}>emojis</strong> para usar en las mesas mientras juegas y <strong style={{ color: '#e2b04a' }}>estilos de cartas</strong> para personalizar tu visual. Lo pagado se suma al Fondo del Proyecto.
      </div>

      {/* Pestañas */}
      <div style={{ display: 'flex', gap: '10px', padding: '15px 20px' }}>
        {[['emotes', '😀 Emojis'], ['cardStyles', '🂡 Estilos de cartas']].map(([key, label]) => (
          <button
            key={key}
            onClick={() => setTab(key)}
            style={{
              flex: 1, padding: '12px', borderRadius: '10px', cursor: 'pointer', fontWeight: 'bold', fontSize: '14px',
              background: tab === key ? '#00b86b' : '#1e1e1e',
              color: tab === key ? 'white' : '#888',
              border: tab === key ? 'none' : '1px solid #333',
            }}
          >
            {label}
          </button>
        ))}
      </div>

      {/* Contenido */}
      <div style={{ padding: '0 20px' }}>
        {loading ? (
          <div style={{ textAlign: 'center', color: '#666', padding: '40px' }}>Cargando tienda...</div>
        ) : (
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(150px, 1fr))', gap: '12px' }}>
            {list.map(item => (
              <div key={item.id} style={{ background: '#1e1e1e', borderRadius: '12px', padding: '15px', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '10px', border: item.equipped ? '2px solid #00b86b' : '1px solid #333' }}>
                {tab === 'emotes' ? (
                  <div style={{ fontSize: '2.6rem', lineHeight: 1 }}>{item.value}</div>
                ) : (
                  <MiniCard styleKey={item.value} />
                )}
                <div style={{ color: 'white', fontSize: '14px', fontWeight: 'bold' }}>{item.name}</div>
                <PriceTag price={item.price_ntx} />

                {tab === 'emotes' ? (
                  item.owned ? (
                    <div style={{ color: '#00b86b', fontSize: '12px', fontWeight: 'bold', padding: '8px 0' }}>✓ Comprado</div>
                  ) : (
                    <button
                      onClick={() => buyItem(item)}
                      disabled={busyId === item.id}
                      style={{ width: '100%', padding: '9px', background: '#00b86b', color: 'white', border: 'none', borderRadius: '8px', fontWeight: 'bold', cursor: busyId === item.id ? 'wait' : 'pointer', fontSize: '13px' }}
                    >
                      {busyId === item.id ? '...' : 'Comprar'}
                    </button>
                  )
                ) : (
                  Number(item.price_ntx) === 0 || item.owned ? (
                    item.equipped ? (
                      <div style={{ color: '#00b86b', fontSize: '12px', fontWeight: 'bold', padding: '8px 0' }}>✓ Equipado</div>
                    ) : (
                      <button
                        onClick={() => equipStyle(item)}
                        disabled={busyId === item.id}
                        style={{ width: '100%', padding: '9px', background: 'transparent', color: '#00b86b', border: '2px solid #00b86b', borderRadius: '8px', fontWeight: 'bold', cursor: 'pointer', fontSize: '13px' }}
                      >
                        Equipar
                      </button>
                    )
                  ) : (
                    <button
                      onClick={() => buyItem(item)}
                      disabled={busyId === item.id}
                      style={{ width: '100%', padding: '9px', background: '#00b86b', color: 'white', border: 'none', borderRadius: '8px', fontWeight: 'bold', cursor: busyId === item.id ? 'wait' : 'pointer', fontSize: '13px' }}
                    >
                      {busyId === item.id ? '...' : 'Comprar'}
                    </button>
                  )
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Toast */}
      {toast && (
        <div style={{
          position: 'fixed', bottom: '30px', left: '50%', transform: 'translateX(-50%)',
          background: toast.type === 'error' ? '#ef4444' : '#00b86b',
          color: 'white', padding: '12px 22px', borderRadius: '25px', fontWeight: 'bold', fontSize: '14px',
          zIndex: 999, boxShadow: '0 6px 20px rgba(0,0,0,0.5)',
        }}>
          {toast.msg}
        </div>
      )}
    </div>
  );
};

export default Tienda;
