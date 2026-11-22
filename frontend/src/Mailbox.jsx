import { useState, useEffect } from 'react';
import { API_URL } from './config';

const Icons = {
  Mail: () => <svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>,
  Check: () => <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="20 6 9 17 4 12"/></svg>,
  CheckAll: () => <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="18 7 7 18 2 13"/><polyline points="22 7 11 18"/></svg>,
  Trash: () => <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>,
  Back: () => <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>,
};

const getTypeStyle = (type) => {
  switch (type) {
    case 'success':
    case 'deposit_approved':
    case 'withdraw_approved':
      return { color: '#00e676', bg: 'rgba(0,230,118,0.1)', border: '#00e676' };
    case 'warning':
    case 'login_new_ip':
      return { color: '#e2b04a', bg: 'rgba(226,176,74,0.1)', border: '#e2b04a' };
    case 'error':
    case 'withdraw_rejected':
      return { color: '#ef4444', bg: 'rgba(239,68,68,0.1)', border: '#ef4444' };
    case 'transfer_received':
      return { color: '#3b82f6', bg: 'rgba(59,130,246,0.1)', border: '#3b82f6' };
    default:
      return { color: '#a0aec0', bg: 'rgba(160,174,192,0.1)', border: '#4a5568' };
  }
};

export default function Mailbox({ user, onBack }) {
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all');

  const token = localStorage.getItem('token');

  const fetchNotifications = async () => {
    setLoading(true);
    try {
      const res = await fetch(`${API_URL}/api/user/notifications`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      const data = await res.json();
      if (res.ok) setNotifications(Array.isArray(data) ? data : []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchNotifications();
  }, []);

  const handleMarkRead = async (id) => {
    try {
      await fetch(`${API_URL}/api/user/notifications/${id}/read`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}` }
      });
      setNotifications(prev => prev.map(n => n.id === id ? { ...n, is_read: 1 } : n));
    } catch (err) { console.error(err); }
  };

  const handleMarkAllRead = async () => {
    try {
      await fetch(`${API_URL}/api/user/notifications/read-all`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}` }
      });
      setNotifications(prev => prev.map(n => ({ ...n, is_read: 1 })));
    } catch (err) { console.error(err); }
  };

  const handleDelete = async (id) => {
    try {
      await fetch(`${API_URL}/api/user/notifications/${id}`, {
        method: 'DELETE',
        headers: { Authorization: `Bearer ${token}` }
      });
      setNotifications(prev => prev.filter(n => n.id !== id));
    } catch (err) { console.error(err); }
  };

  const filtered = filter === 'unread'
    ? notifications.filter(n => !n.is_read)
    : notifications;

  const unreadCount = notifications.filter(n => !n.is_read).length;

  return (
    <main className="main-area">
      <div className="content-scroll" style={{ display: 'flex', justifyContent: 'center', padding: '2rem' }}>
        <div style={{ width: '100%', maxWidth: '900px' }}>

          <button onClick={onBack} style={{ background: 'transparent', color: '#a0aec0', border: 'none', cursor: 'pointer', fontSize: '0.9rem', marginBottom: '1.5rem', display: 'flex', alignItems: 'center', gap: '5px' }}>
            <Icons.Back /> Volver al Lobby
          </button>

          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.5rem', flexWrap: 'wrap', gap: '15px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
              <div style={{ width: '50px', height: '50px', borderRadius: '12px', background: 'linear-gradient(135deg, #00e676 0%, #009956 100%)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#000' }}>
                <Icons.Mail />
              </div>
              <div>
                <h1 style={{ fontSize: '1.8rem', fontWeight: '800', margin: 0 }}>Buzón de Mensajes</h1>
                <p style={{ margin: 0, fontSize: '0.85rem', color: '#a0aec0' }}>
                  {unreadCount > 0 ? `${unreadCount} sin leer` : 'Todo al día'}
                </p>
              </div>
            </div>

            {unreadCount > 0 && (
              <button
                onClick={handleMarkAllRead}
                style={{ padding: '10px 16px', background: '#1a202c', border: '1px solid #2d3748', borderRadius: '8px', color: '#00e676', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '6px', fontSize: '0.85rem', fontWeight: 'bold' }}
              >
                <Icons.CheckAll /> Marcar todo como leído
              </button>
            )}
          </div>

          <div style={{ display: 'flex', gap: '8px', marginBottom: '1.5rem' }}>
            <button
              onClick={() => setFilter('all')}
              style={{ padding: '8px 16px', background: filter === 'all' ? '#00e676' : '#1a202c', color: filter === 'all' ? '#000' : '#a0aec0', border: '1px solid #2d3748', borderRadius: '8px', cursor: 'pointer', fontSize: '0.85rem', fontWeight: 'bold' }}
            >
              Todas ({notifications.length})
            </button>
            <button
              onClick={() => setFilter('unread')}
              style={{ padding: '8px 16px', background: filter === 'unread' ? '#00e676' : '#1a202c', color: filter === 'unread' ? '#000' : '#a0aec0', border: '1px solid #2d3748', borderRadius: '8px', cursor: 'pointer', fontSize: '0.85rem', fontWeight: 'bold' }}
            >
              Sin leer ({unreadCount})
            </button>
          </div>

          {loading ? (
            <p style={{ textAlign: 'center', padding: '40px', color: '#a0aec0' }}>Cargando mensajes...</p>
          ) : filtered.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '60px 20px', color: '#718096', background: '#171b24', borderRadius: '12px', border: '1px solid #2d3748' }}>
              <div style={{ fontSize: '3rem', marginBottom: '15px' }}>📭</div>
              <h3 style={{ color: '#fff', margin: '0 0 8px 0' }}>Sin mensajes</h3>
              <p style={{ margin: 0, fontSize: '0.9rem' }}>
                {filter === 'unread' ? 'No tienes mensajes sin leer.' : 'Cuando ocurra algo importante, aparecerá aquí.'}
              </p>
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
              {filtered.map(n => {
                const style = getTypeStyle(n.type);
                return (
                  <div
                    key={n.id}
                    style={{
                      padding: '16px 20px',
                      background: n.is_read ? '#171b24' : '#1a202c',
                      borderRadius: '12px',
                      border: `1px solid ${n.is_read ? '#2d3748' : style.border}`,
                      display: 'flex',
                      gap: '15px',
                      alignItems: 'flex-start',
                      opacity: n.is_read ? 0.75 : 1,
                      transition: '0.2s'
                    }}
                  >
                    <div style={{ width: '40px', height: '40px', borderRadius: '50%', background: style.bg, border: `1px solid ${style.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', color: style.color, flexShrink: 0 }}>
                      <Icons.Mail />
                    </div>

                    <div style={{ flex: 1, minWidth: 0 }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: '10px', flexWrap: 'wrap' }}>
                        <h4 style={{ margin: 0, color: '#fff', fontSize: '1rem', fontWeight: n.is_read ? '500' : '700' }}>
                          {n.title}
                          {!n.is_read && <span style={{ marginLeft: '8px', display: 'inline-block', width: '8px', height: '8px', borderRadius: '50%', background: '#00e676' }}></span>}
                        </h4>
                        <span style={{ fontSize: '0.75rem', color: '#718096', whiteSpace: 'nowrap' }}>
                          {new Date(n.created_at).toLocaleString('es-ES', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' })}
                        </span>
                      </div>
                      <p style={{ margin: '6px 0 12px 0', color: '#a0aec0', fontSize: '0.9rem', lineHeight: '1.5' }}>
                        {n.message}
                      </p>
                      <div style={{ display: 'flex', gap: '8px' }}>
                        {!n.is_read && (
                          <button onClick={() => handleMarkRead(n.id)} style={{ padding: '6px 12px', background: '#2d3748', border: 'none', borderRadius: '6px', color: '#00e676', cursor: 'pointer', fontSize: '0.75rem', display: 'flex', alignItems: 'center', gap: '4px' }}>
                            <Icons.Check /> Marcar leído
                          </button>
                        )}
                        <button onClick={() => handleDelete(n.id)} style={{ padding: '6px 12px', background: 'transparent', border: '1px solid #2d3748', borderRadius: '6px', color: '#ef4444', cursor: 'pointer', fontSize: '0.75rem', display: 'flex', alignItems: 'center', gap: '4px' }}>
                          <Icons.Trash /> Eliminar
                        </button>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}

        </div>
      </div>
    </main>
  );
}