import { useState, useEffect } from 'react';
import { changelogData } from './changelogData'; 
import PokerTable from './PokerTable';
import TournamentDetails from './TournamentDetails';
import Wallet from './Wallet';
import AdminPanel from './AdminPanel';
import InviteFriends from './InviteFriends';
import Security from './Security';
import Settings from './Settings';
import Club from './Club';
import ServerConfig from './ServerConfig'; 
import CasualRooms from './CasualRooms'; 
import FuturesGames from './FuturesGames'; 
import TournamentLobby from './TournamentLobby';
import TournamentHub from './TournamentHub';
import Login from './Login'; 
import Profile from './Profile';
import Mailbox from './Mailbox';
import ActivityCenter from './ActivityCenter';
import { API_URL } from './config'; 

const SHOW_CLUB_MODULE = false;

// COMPONENTE DE TOAST (Notificaciones flotantes)
const Toast = ({ message, type, onClose }) => {
  useEffect(() => {
    const timer = setTimeout(() => onClose(), 3000);
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

// COMPONENTE DE CONFIRMACION
const ConfirmDialog = ({ isOpen, title, message, onConfirm, onCancel }) => {
  if (!isOpen) return null;
  return (
    <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', background: 'rgba(0,0,0,0.85)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 10000, backdropFilter: 'blur(5px)' }}>
      <div style={{ background: '#171b24', padding: '30px', borderRadius: '12px', width: '420px', border: '1px solid #2d3748', textAlign: 'center', boxShadow: '0 20px 50px rgba(0,0,0,0.9)', maxWidth: '90%' }}>
        <div style={{ width: '50px', height: '50px', background: '#fbbf24', borderRadius: '50%', display: 'flex', justifyContent: 'center', alignItems: 'center', margin: '0 auto 15px auto', fontSize: '1.8rem', color: '#000', fontWeight: 'bold' }}>
          !
        </div>
        <h3 style={{ color: '#fff', margin: '0 0 10px 0', fontSize: '1.1rem', fontWeight: 'bold', lineHeight: '1.4' }}>{title}</h3>
        <p style={{ color: '#a0aec0', marginBottom: '25px', fontSize: '0.85rem', lineHeight: '1.5' }}>{message}</p>
        <div style={{ display: 'flex', gap: '15px' }}>
          <button onClick={onCancel} style={{ flex: 1, padding: '12px', background: '#2d3748', color: '#fff', border: 'none', borderRadius: '8px', fontWeight: 'bold', cursor: 'pointer', fontSize: '0.95rem' }}>Cancelar</button>
          <button onClick={onConfirm} style={{ flex: 1, padding: '12px', background: '#10b981', color: '#fff', border: 'none', borderRadius: '8px', fontWeight: 'bold', cursor: 'pointer', fontSize: '0.95rem' }}>Confirmar</button>
        </div>
      </div>
    </div>
  );
};

// MODAL DE SESION EXPIRADA
const SessionExpiredModal = ({ isOpen, onAccept }) => {
  if (!isOpen) return null;
  return (
    <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', background: 'rgba(0,0,0,0.9)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 100000, backdropFilter: 'blur(8px)' }}>
      <div style={{ background: '#171b24', padding: '30px', borderRadius: '12px', width: '400px', border: '1px solid #2d3748', textAlign: 'center', boxShadow: '0 20px 50px rgba(0,0,0,0.9)', maxWidth: '90%' }}>
        <div style={{ width: '50px', height: '50px', background: '#ef4444', borderRadius: '50%', display: 'flex', justifyContent: 'center', alignItems: 'center', margin: '0 auto 15px auto', fontSize: '1.8rem', color: '#fff', fontWeight: 'bold' }}>
          !
        </div>
        <h3 style={{ color: '#fff', margin: '0 0 10px 0', fontSize: '1.2rem', fontWeight: 'bold' }}>Sesion Expirada</h3>
        <p style={{ color: '#a0aec0', marginBottom: '25px', fontSize: '0.9rem', lineHeight: '1.5' }}>
          Has iniciado sesion en otro dispositivo o navegador. Por motivos de seguridad, tu sesion en este dispositivo ha sido cerrada.
        </p>
        <button onClick={onAccept} style={{ width: '100%', padding: '12px', background: '#ef4444', color: '#fff', border: 'none', borderRadius: '8px', fontWeight: 'bold', cursor: 'pointer', fontSize: '1rem' }}>
          Aceptar y Volver al Login
        </button>
      </div>
    </div>
  );
};

const Icons = {
  ChevronRight: () => <svg viewBox="0 0 24 24" width="16" height="16" fill="#718096"><path d="M8.59 16.59L13.17 12 8.59 7.41 10 6l6 6-6 6-1.41-1.41z"/></svg>,
  User: () => <svg viewBox="0 0 24 24"><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg>,
  Wallet: () => <svg viewBox="0 0 24 24"><path d="M21 18v1c0 1.1-.9 2-2 2H5c-1.11 0-2-.9-2-2V5c0-1.1.89-2 2-2h14c1.1 0 2 .9 2 2v1h-9c-1.11 0-2 .9-2 2v8c0 1.1.89 2 2 2h9zm-9-2h10V8H12v8zm4-2.5c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5z"/></svg>,
  Users: () => <svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>,
  Shield: () => <svg viewBox="0 0 24 24"><path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm0 10.99h7c-.53 4.12-3.28 7.79-7 8.94V12H5V6.3l7-3.11v8.8z"/></svg>,
  Settings: () => <svg viewBox="0 0 24 24"><path d="M19.14,12.94c0.04-0.3,0.06-0.61,0.06-0.94c0-0.32-0.02-0.64-0.06-0.94l2.03-1.58c0.18-0.14,0.23-0.41,0.12-0.61 l-1.92-3.32c-0.12-0.22-0.37-0.29-0.59-0.22l-2.39,0.96c-0.5-0.38-1.03-0.7-1.62-0.94L14.4,2.81c-0.04-0.24-0.24-0.41-0.48-0.41 h-3.84c-0.24,0-0.43,0.17-0.47,0.41L9.25,5.35C8.66,5.59,8.12,5.92,7.63,6.29L5.24,5.33c-0.22-0.08-0.47,0-0.59,0.22L2.73,8.87 C2.62,9.08,2.66,9.34,2.86,9.48l2.03,1.58C4.84,11.36,4.8,11.69,4.8,12s0.02,0.64,0.06,0.94l-2.03,1.58 c-0.18,0.14-0.23,0.41-0.12,0.61l1.92,3.32c0.12,0.22,0.37,0.29,0.59,0.22l2.39-0.96c0.5,0.38,1.03,0.7,1.62,0.94l0.36,2.54 c0.05,0.24,0.24,0.41,0.48,0.41h3.84c0.24,0,0.44-0.17,0.47-0.41l0.36-2.54c0.59-0.24,1.13-0.56,1.62-0.94l2.39,0.96 c0.22,0.08,0.47,0,0.59-0.22l1.92-3.32c0.12-0.22,0.07-0.49-0.12-0.61L19.14,12.94z M12,15.6c-1.98,0-3.6-1.62-3.6-3.6 s1.62-3.6,3.6-3.6s3.6,1.62,3.6,3.6S13.98,15.6,12,15.6z"/></svg>,
  Logout: () => <svg viewBox="0 0 24 24"><path d="M17 7l-1.41 1.41L18.17 11H8v2h10.17l-2.58 2.58L17 17l5-5zM4 5h8V3H4c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h8v-2H4V5z"/></svg>,
  Grid: () => <svg viewBox="0 0 24 24" width="24" height="24" fill="currentColor"><path d="M4 4h4v4H4V4zm6 0h4v4h-4V4zm6 0h4v4h-4V4zM4 10h4v4H4v-4zm6 0h4v4h-4v-4zm6 0h4v4h-4v-4zM4 16h4v4H4v-4zm6 0h4v4h-4v-4zm6 0h4v4h-4v-4z"/></svg>,
  Home: () => <svg viewBox="0 0 24 24"><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/></svg>,
  Cards: () => <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 14l-5-5 1.41-1.41L12 14.17l4.59-4.58L18 11l-7 6z"/></svg>,
  Trophy: () => <svg viewBox="0 0 24 24"><path d="M19 5h-2V3H7v2H5c-1.1 0-2 .9-2 2v1c0 2.55 1.92 4.63 4.39 4.94.63 1.5 1.98 2.63 3.61 2.96V19H7v2h10v-2h-4v-3.1c1.63-.33 2.98-1.46 3.61-2.96C19.08 12.63 21 10.55 21 8V7c0-1.1-.9-2-2-2zM5 8V7h2v3.82C5.84 10.4 5 9.3 5 8zm14 0c0 1.3-.84 2.4-2 2.82V7h2v1z"/></svg>,
  News: () => <svg viewBox="0 0 24 24"><path d="M20 2H4c-1.1 0-1.99.9-1.99 2L2 22l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zM8 14H6v-2h2v2zm0-3H6V9h2v2zm0-3H6V6h2v2zm7 6h-5v-2h5v2zm3-3h-8V9h8v2zm0-3h-8V6h8v2z"/></svg>,
  Club: () => <svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>,
  ChangeLog: () => <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/></svg>,
  Star: () => <svg viewBox="0 0 24 24"><path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/></svg>,
  Gamepad: () => <svg viewBox="0 0 24 24"><path d="M21.58 16.09l-1.09-7.66C20.21 6.46 18.52 5 16.53 5H7.47C5.48 5 3.79 6.46 3.51 8.43l-1.09 7.66C2.2 17.63 3.39 19 4.94 19c.68 0 1.32-.27 1.8-.75L9 16h6l2.25 2.25c.48.48 1.13.75 1.8.75 1.56 0 2.75-1.37 2.53-2.91zM11 11H9v2H8v-2H6v-1h2V8h1v2h2v1zm4-1c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1zm2 3c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1z"/></svg>,
  Receive: () => <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3"/></svg>,
  Send: () => <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M17 8l-5-5-5 5M12 3v12"/></svg>,
  Transfer: () => <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M17 1l4 4-4 4"/><path d="M3 11V9a4 4 0 0 1 4-4h14"/><path d="M7 23l-4-4 4-4"/><path d="M21 13v2a4 4 0 0 1-4 4H3"/></svg>,
  History: () => <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>,
  Copy: () => <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>,
  Globe: () => <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="#00e676" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>,
  Lock: () => <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="#e2e8f0" strokeWidth="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>,
  Fingerprint: () => <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="#e2e8f0" strokeWidth="2"><path d="M12 2a10 10 0 0 1 10 10c0 5-2 10-10 10S2 17 2 12 7 2 12 2z"/><path d="M12 12a3 3 0 0 1 3 3v4"/><path d="M9 12a3 3 0 0 0-3 3v4"/><path d="M12 9a6 6 0 0 0-6 6v4"/><path d="M15 12a3 3 0 0 1 3 3v4"/></svg>,
  MailIcon: () => <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="#e2e8f0" strokeWidth="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>,
  Key: () => <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="#e2e8f0" strokeWidth="2"><path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 1 1-7.778 7.778 5.5 5.5 0 0 1 7.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"/></svg>,
  CheckCircle: () => <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="#e2e8f0" strokeWidth="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>,
  Discord: () => <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M20.317 4.3698a19.7913 19.7913 0 00-4.8851-1.5152.0741.0741 0 00-.0785.0371c-.211.3753-.4447.8648-.6083 1.2495-1.8447-.2762-3.68-.2762-5.4868 0-.1636-.3933-.4058-.8742-.6177-1.2495a.077.077 0 00-.0785-.037 19.7363 19.7363 0 00-4.8852 1.515.0699.0699 0 00-.0321.0277C.5334 9.0458-.319 13.5799.0992 18.0578a.0824.0824 0 00.0312.0561c2.0528 1.5076 4.0413 2.4228 5.9929 3.0294a.0777.0777 0 00.0842-.0276c.4616-.6304.8731-1.2952 1.226-1.9942a.076.076 0 00-.0416-.1057c-.6528-.2476-1.2743-.5495-1.8722-.8923a.077.077 0 01-.0076-.1277c.1258-.0943.2517-.1923.3718-.2914a.0743.0743 0 01.0776-.0105c3.9278 1.7933 8.18 1.7933 12.0614 0a.0739.0739 0 01.0785.0095c.1202.099.246.1981.3728.2924a.077.077 0 01-.0066.1276 12.2986 12.2986 0 01-1.873.8914.0766.0766 0 00-.0407.1067c.3604.698.7719 1.3628 1.225 1.9932a.076.076 0 00.0842.0286c1.961-.6067 3.9495-1.5219 6.0023-3.0294a.077.077 0 00.0313-.0552c.5004-5.177-.8382-9.6739-3.5485-13.6604a.061.061 0 00-.0312-.0286zM8.02 15.3312c-1.1825 0-2.1569-1.0857-2.1569-2.419 0-1.3332.9555-2.4189 2.157-2.4189 1.2108 0 2.1757 1.0952 2.1568 2.419 0 1.3332-.9555 2.4189-2.1569 2.4189zm7.9748 0c-1.1825 0-2.1569-1.0857-2.1569-2.419 0-1.3332.9554-2.4189 2.1569-2.4189 1.2108 0 2.1757 1.0952 2.1568 2.419 0 1.3332-.946 2.4189-2.1568 2.4189Z"/></svg>,
  Activity: () => <svg viewBox="0 0 24 24" width="24" height="24" fill="currentColor"><path d="M22 10V6c0-1.1-.9-2-2-2H4c-1.1 0-2 .9-2 2v4c1.1 0 2 .9 2 2s-.9 2-2 2v4c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2v-4c-1.1 0-2-.9-2-2s.9-2 2-2zm-8 5l-3-3 1.4-1.4 1.6 1.6 4.6-4.6 1.4 1.4-6 6z"/></svg>
};

const LEVEL_DATA = [];
const ACHIEVEMENT_DATA = [];
const bannersData = [
  { id: 1, image: '/banner1.png', alt: 'Banner 1' }, 
  { id: 2, image: '/banner2.png', alt: 'Banner 2' },
];

const PlaceholderPage = ({ title, icon, onBack }) => (
  <main className="main-area" style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '80vh' }}>
    <div style={{ textAlign: 'center', color: '#a0aec0' }}>
      <div style={{ fontSize: '5rem', marginBottom: '1rem', opacity: 0.5 }}>{icon}</div>
      <h2 style={{ color: '#fff', fontSize: '2rem', marginBottom: '10px' }}>{title}</h2>
      <p>Esta seccion esta en construccion. Pronto estara disponible!</p>
      <button className="btn" onClick={onBack} style={{ marginTop: '20px', width: 'auto', padding: '10px 30px' }}>Volver al Lobby</button>
    </div>
  </main>
);

function App() {
  const [user, setUser] = useState(null);
  const [balance, setBalance] = useState(0);
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [currentPage, setCurrentPage] = useState(() => {
    return localStorage.getItem('royalbet_currentPage') || 'lobby';
  });
  const [loading, setLoading] = useState(true);
  
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const [inGame, setInGame] = useState(() => {
    const saved = localStorage.getItem('royalbet_in_game');
    return saved ? JSON.parse(saved) : false;
  });
  const [tableConfig, setTableConfig] = useState(() => {
    const saved = localStorage.getItem('royalbet_table_config');
    return saved ? JSON.parse(saved) : null;
  });

  const [isMinimized, setIsMinimized] = useState(false);
  
  const [selectedTable, setSelectedTable] = useState(null);
  const [activeTournament, setActiveTournament] = useState(null);
  const [currentBannerIndex, setCurrentBannerIndex] = useState(0);

  const [profileData, setProfileData] = useState({ username: '', email: '', phone: '', avatar_url: '' });
  const [isEditingProfile, setIsEditingProfile] = useState(false);
  const [profileTab, setProfileTab] = useState('torneo');

  const [referralCode, setReferralCode] = useState(null);
  const [referralStats, setReferralStats] = useState({ total_referrals: 0, referrals: [] });

  const [hasPin, setHasPin] = useState(false);
  const [pinEnabled, setPinEnabled] = useState(false);
  const [showPasswordForm, setShowPasswordForm] = useState(false);
  const [showPinForm, setShowPinForm] = useState(false);
  const [oldPassword, setOldPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [newPin, setNewPin] = useState('');

  const [toast, setToast] = useState(null);
  const [confirmDialog, setConfirmDialog] = useState({ isOpen: false, title: '', message: '', onConfirm: null });
  const [sessionExpired, setSessionExpired] = useState(false);

  const defaultAvatar = `https://api.dicebear.com/7.x/adventurer/svg?seed=${user?.username || 'player'}`;
  const avatarToShow = user?.avatar_url ? user.avatar_url : defaultAvatar;

  const showToast = (message, type = 'success') => {
    setToast({ message, type });
  };

  const showConfirm = (title, message, onConfirm) => {
    setConfirmDialog({ isOpen: true, title, message, onConfirm });
  };

  const [settingsTab, setSettingsTab] = useState('sonido');
  const [settings, setSettings] = useState(() => {
    const saved = localStorage.getItem('royalbet_settings');
    return saved ? JSON.parse(saved) : {
      efectosSonoros: true, musicaFondo: true, alertasMultimesa: true, escucharVoz: false, voz: true, choque: true,
      manosIzquierda: true, instrucciones: true, charlaEspectadores: true, fpsLag: false, muestraBB: false, saludoAuto: true, efectosRegalo: true, accesorios: true, idioma: 'Espanol',
      notificacionesNavegador: true,
      mesaColor: '#2d3748', botonColor: '#ef4444', cartasColor: '#fff',
      betAmount: 40000, preferenciaApertura: 'All in', preferenciaEstandar: 'All in', noRedondear: true,
      usarRaton: false, usarTeclado: true, confirmarEnter: true, funciones: false
    };
  });

  const handleSettingChange = (key, value) => setSettings(prev => ({ ...prev, [key]: value }));
  const handleSaveSettings = () => { 
    localStorage.setItem('royalbet_settings', JSON.stringify(settings)); 
    showToast('Ajustes guardados correctamente', 'success'); 
  };

  const fetchBalance = async (token) => {
    try {
      const res = await fetch(`${API_URL}/api/wallet`, { headers: { Authorization: `Bearer ${token}` } });
      const data = await res.json();
      setBalance(data?.balance_ntx || 0);
    } catch (error) {
      console.error("Error fetching balance:", error);
      setBalance(0);
    }
  };

  const parseJwt = (token) => {
    try { return JSON.parse(atob(token.split('.')[1])); } catch (e) { return null; }
  };

  const handleLoginSuccess = (userData, token) => {
    if (!userData || !token) {
      showToast('Error: Datos de inicio de sesion incompletos.', 'error');
      return;
    }
    localStorage.setItem('token', token);
    localStorage.setItem('user', JSON.stringify(userData));
    localStorage.removeItem('royalbet_in_game');
    localStorage.removeItem('royalbet_table_config');
    setInGame(false);
    setIsMinimized(false);
    setTableConfig(null);
    setUser(userData);
    setHasPin(userData.has_pin || false);
    setPinEnabled(userData.pin_enabled || false);
    fetchBalance(token);
    setCurrentPage('lobby');
  };

  useEffect(() => {
    let sessionInterval;
    if (user && localStorage.getItem('token')) {
      sessionInterval = setInterval(async () => {
        try {
          const res = await fetch(`${API_URL}/api/verify-session`, {
            headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
          });
          if (res.status === 401) {
            const data = await res.json();
            if (data.error === 'SESSION_EXPIRED' || data.error === 'Token invalido' || data.error === 'Token requerido') {
              setSessionExpired(true);
              localStorage.removeItem('token');
              localStorage.removeItem('user');
              localStorage.removeItem('royalbet_in_game');
              localStorage.removeItem('royalbet_table_config');
              setInGame(false);
              setIsMinimized(false);
              setTableConfig(null);
              setUser(null);
              setCurrentPage('lobby');
            }
          }
        } catch (error) { console.error("Error checking session:", error); }
      }, 10000); 
    }
    return () => { if (sessionInterval) clearInterval(sessionInterval); };
  }, [user]);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const discordToken = params.get('discord_token');

    if (discordToken) {
      localStorage.setItem('token', discordToken);
      const decodedUser = parseJwt(discordToken);
      if (decodedUser) {
        const fullUser = { id: decodedUser.id, username: decodedUser.username || 'DiscordUser', role: decodedUser.role || 'user', has_pin: false, pin_enabled: false };
        localStorage.setItem('user', JSON.stringify(fullUser));
        setUser(fullUser);
        fetchBalance(discordToken);
      }
      const url = new URL(window.location.href);
      url.searchParams.delete('discord_token');
      window.history.replaceState({}, document.title, url.pathname + url.search + url.hash);
    }
  }, []);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    if (params.get('discord_linked') !== 'true') return;
    if (!user) return;

    let cancelled = false;

    (async () => {
      try {
        const res = await fetch(`${API_URL}/api/user/profile`, {
          headers: { Authorization: `Bearer ${localStorage.getItem('token')}` },
        });
        if (!res.ok) throw new Error(`HTTP ${res.status}`);

        const data = await res.json();
        if (cancelled) return;

        setUser(prev => {
          const updatedUser = { ...prev, ...data };
          localStorage.setItem('user', JSON.stringify(updatedUser));
          return updatedUser;
        });
        showToast('¡Discord vinculado correctamente!', 'success');

        const url = new URL(window.location.href);
        url.searchParams.delete('discord_linked');
        window.history.replaceState({}, document.title, url.pathname + url.search + url.hash);
      } catch (e) {
        console.error(e);
        showToast('No se pudo verificar la vinculacion de Discord', 'error');
      }
    })();

    return () => { cancelled = true; };
  }, [user?.id]);

  useEffect(() => { localStorage.setItem('royalbet_currentPage', currentPage); }, [currentPage]);
  useEffect(() => { if (!SHOW_CLUB_MODULE && currentPage === 'club') setCurrentPage('lobby'); }, [currentPage]);

  useEffect(() => {
    const savedUser = localStorage.getItem('user');
    const savedToken = localStorage.getItem('token');
    
    if (savedUser && savedToken) {
      try {
        const parsedUser = JSON.parse(savedUser);
        if (parsedUser && parsedUser.username) {
          setUser(parsedUser);
          setHasPin(parsedUser.has_pin || false);
          setPinEnabled(parsedUser.pin_enabled || false);
          fetchBalance(savedToken); 
        } else {
          throw new Error("Usuario invalido");
        }
      } catch (e) {
        console.error("Datos corruptos, limpiando localStorage", e);
        localStorage.removeItem('user');
        localStorage.removeItem('token');
      }
    }
    setLoading(false);
  }, []);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const ref = params.get('ref');
    if (ref) setReferralCode(ref);
  }, []);

  useEffect(() => {
    if (currentPage === 'profile' && user) fetchProfile();
    if (currentPage === 'invite' && user) fetchReferralStats();
  }, [currentPage]);

  const fetchProfile = async () => {
    const token = localStorage.getItem('token');
    const res = await fetch(`${API_URL}/api/user/profile`, { headers: { Authorization: `Bearer ${token}` } });
    const data = await res.json();
    if (res.ok) setProfileData(data);
  };

  const fetchReferralStats = async () => {
    const token = localStorage.getItem('token');
    const res = await fetch(`${API_URL}/api/user/referrals`, { headers: { Authorization: `Bearer ${token}` } });
    const data = await res.json();
    if (res.ok) setReferralStats(data);
  };

  const handleChangePassword = async (e) => {
    e.preventDefault();
    const res = await fetch(`${API_URL}/api/user/password`, { method: 'PUT', headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${localStorage.getItem('token')}` }, body: JSON.stringify({ oldPassword, newPassword }) });
    const data = await res.json();
    if (res.ok) { 
      showToast('Contrasena cambiada correctamente', 'success'); 
      setShowPasswordForm(false); 
      setOldPassword(''); 
      setNewPassword(''); 
      return true;
    } else { 
      showToast(data.error, 'error'); 
      return false;
    }
  };

  const handleSavePin = async (e) => {
    e.preventDefault();
    const res = await fetch(`${API_URL}/api/user/paypin`, { method: 'PUT', headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${localStorage.getItem('token')}` }, body: JSON.stringify({ pin: newPin }) });
    const data = await res.json();
    if (res.ok) { 
      setHasPin(true); 
      setPinEnabled(true); 
      setShowPinForm(false); 
      setNewPin(''); 
      
      setUser(prev => {
        const updatedUser = { ...prev, has_pin: true, pin_enabled: true };
        localStorage.setItem('user', JSON.stringify(updatedUser));
        return updatedUser;
      });
      
      showToast('PIN configurado correctamente', 'success'); 
      return true;
    } else { 
      showToast(data.error, 'error'); 
      return false;
    }
  };

  const handleTogglePin = async () => {
    if (!hasPin && !pinEnabled) { setShowPinForm(true); return; }
    const newState = !pinEnabled;
    const res = await fetch(`${API_URL}/api/user/paypin/toggle`, { method: 'PUT', headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${localStorage.getItem('token')}` }, body: JSON.stringify({ enabled: newState }) });
    if (res.ok) {
      setPinEnabled(newState);
      setUser(prev => {
        const updatedUser = { ...prev, pin_enabled: newState };
        localStorage.setItem('user', JSON.stringify(updatedUser));
        return updatedUser;
      });
    }
  };

  const handleSaveProfile = async (e) => {
    e.preventDefault();
    const res = await fetch(`${API_URL}/api/user/profile`, { method: 'PUT', headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${localStorage.getItem('token')}` }, body: JSON.stringify(profileData) });
    const data = await res.json();
    if (res.ok) { 
      showToast('Perfil actualizado correctamente', 'success'); 
      setIsEditingProfile(false); 
      
      setUser(prev => {
        const updatedUser = { 
          ...prev, 
          username: profileData.username, 
          email: profileData.email, 
          phone: profileData.phone, 
          avatar_url: profileData.avatar_url 
        };
        localStorage.setItem('user', JSON.stringify(updatedUser));
        return updatedUser;
      });
      return true;
    } else { 
      showToast(data.error, 'error'); 
      return false;
    }
  };

  const handleLogout = () => {
    localStorage.clear(); 
    setUser(null); 
    setBalance(0); 
    setIsMenuOpen(false); 
    setIsSidebarOpen(false); 
    setCurrentPage('lobby'); 
    setInGame(false); 
    setIsMinimized(false);
    setTableConfig(null); 
    setSelectedTable(null); 
    setActiveTournament(null);
    setLoading(false);
    setSessionExpired(false);
  };

  const joinTable = (config) => {
    setTableConfig(config);
    setInGame(true);
    setIsMinimized(false); 
    localStorage.setItem('royalbet_in_game', 'true');
    localStorage.setItem('royalbet_table_config', JSON.stringify(config));
  };

  const handleExitGame = () => {
    setInGame(false);
    setIsMinimized(false);
    setTableConfig(null);
    localStorage.removeItem('royalbet_in_game');
    localStorage.removeItem('royalbet_table_config');
  };

  if (loading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh', background: '#0b0e14', color: '#00e676', flexDirection: 'column' }}>
        <img src="/logo.png" alt="RoyalBET" style={{ width: '120px', height: '120px', marginBottom: '20px', animation: 'pulse 1.5s infinite' }} />
        <h1 style={{ fontSize: '2.5rem', fontWeight: '900', marginBottom: '30px', letterSpacing: '2px', textShadow: '0 0 10px rgba(0, 230, 118, 0.5)' }}>RoyalBET</h1>
        <div style={{ display: 'flex', gap: '10px' }}>
          <div style={{ width: '15px', height: '15px', background: '#00e676', animation: 'spin 1s infinite alternate' }}></div>
          <div style={{ width: '15px', height: '15px', background: '#00e676', animation: 'spin 1s infinite alternate 0.2s' }}></div>
          <div style={{ width: '15px', height: '15px', background: '#00e676', animation: 'spin 1s infinite alternate 0.4s' }}></div>
          <div style={{ width: '15px', height: '15px', background: '#00e676', animation: 'spin 1s infinite alternate 0.6s' }}></div>
        </div>
        <style>
          {`
            @keyframes pulse { 0% { transform: scale(1); } 50% { transform: scale(1.1); } 100% { transform: scale(1); } }
            @keyframes spin { 0% { transform: rotate(0deg); opacity: 0.3; } 100% { transform: rotate(180deg); opacity: 1; } }
          `}
        </style>
      </div>
    );
  }

  const renderSessionModal = () => (
    <SessionExpiredModal isOpen={sessionExpired} onAccept={() => setSessionExpired(false)} />
  );

  const renderPokerTable = () => {
    if (!inGame || !user) return null;
    return (
      <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', zIndex: 99999, display: isMinimized ? 'none' : 'block' }}>
        <PokerTable 
          user={user} 
          tableConfig={tableConfig} 
          onExit={handleExitGame} 
          onMinimize={() => setIsMinimized(true)} 
        />
      </div>
    );
  };

  if (selectedTable && user) {
    return (
      <>
        {renderSessionModal()}
        {renderPokerTable()}
        <TournamentDetails tournament={selectedTable} onBack={() => setSelectedTable(null)} onJoin={() => { setSelectedTable(null); joinTable({ isActive: true, tableData: { name: "Torneo", blinds: "10/20", maxPlayers: 9 } }); }} />
      </>
    );
  }

  if (activeTournament && user) {
    return (
      <>
        {renderSessionModal()}
        {renderPokerTable()}
        <TournamentLobby tournament={activeTournament} onBack={() => setActiveTournament(null)} />
      </>
    );
  }

  if (!user) {
    return (
      <>
        {renderSessionModal()}
        <Login onLoginSuccess={handleLoginSuccess} referralCode={referralCode} />
      </>
    );
  }

  return (
    <div className="lobby-layout" style={{ position: 'relative' }}>
      {/* 🔥 ESTILOS RESPONSIVOS PARA MÓVILES 🔥 */}
      <style>{`
        @media (max-width: 768px) {
          .nav-center { display: none !important; }
          .nav-left img { width: 30px !important; height: 30px !important; }
          .nav-left span { display: none; }
          .nav-right .balance-pill { font-size: 0.75rem !important; padding: 4px 8px !important; }
          .nav-right .user-profile span { display: none; }
          .nav-right .user-profile { padding: 0 10px !important; }
          .dropdown-menu { right: 10px !important; left: auto !important; width: 250px !important; }
          .sidebar-dropdown-menu { left: 0 !important; width: 100vw !important; border-radius: 0 !important; }
          .lobby-categories { display: flex; flex-wrap: wrap; justify-content: center; gap: 10px; }
          .category-icon { width: 30%; text-align: center; }
        }
      `}</style>

      {renderSessionModal()}
      {renderPokerTable()}
      
      {toast && <Toast message={toast.message} type={toast.type} onClose={() => setToast(null)} />}
      <ConfirmDialog 
        isOpen={confirmDialog.isOpen} 
        title={confirmDialog.title} 
        message={confirmDialog.message} 
        onConfirm={() => {
          if (confirmDialog.onConfirm) confirmDialog.onConfirm();
          setConfirmDialog({ ...confirmDialog, isOpen: false });
        }} 
        onCancel={() => setConfirmDialog({ ...confirmDialog, isOpen: false })} 
      />

      <header className="top-nav">
        <div className="nav-left">
          <button className="grid-btn" onClick={() => setIsSidebarOpen(!isSidebarOpen)}>
            <Icons.Grid />
          </button>
          
          {isSidebarOpen && (
            <div className="sidebar-dropdown-menu">
              <div className="sidebar-item" onClick={() => { setCurrentPage('lobby'); setIsSidebarOpen(false); }}><Icons.Home /> Inicio</div>
              <div className="sidebar-item" onClick={() => { setCurrentPage('casual'); setIsSidebarOpen(false); }}><Icons.Cards /> Casual Rooms</div>
              <div className="sidebar-item" onClick={() => { setCurrentPage('tournaments'); setIsSidebarOpen(false); }}><Icons.Trophy /> Torneos</div>
              <div className="sidebar-item" onClick={() => { setCurrentPage('mail'); setIsSidebarOpen(false); }}><Icons.News /> Noticias / Mail</div>
              {SHOW_CLUB_MODULE && (
                <div className="sidebar-item" onClick={() => { setCurrentPage('club'); setIsSidebarOpen(false); }}><Icons.Club /> Club</div>
              )}
              <div className="sidebar-item" onClick={() => { setCurrentPage('changelog'); setIsSidebarOpen(false); }}><Icons.ChangeLog /> Registro de cambio</div>
            </div>
          )}

          <div onClick={() => setCurrentPage('lobby')} style={{ cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '15px' }}>
            <img src="/logo.png" alt="Logo" />
            <span>RoyalBET</span>
          </div>
        </div>

        <div className="nav-center">
          <span onClick={() => setCurrentPage('lobby')} style={{ cursor: 'pointer' }}>Inicio</span>
          <span onClick={() => setCurrentPage('casual')} style={{ cursor: 'pointer' }}>Casual Rooms</span>
          <span onClick={() => setCurrentPage('tournaments')} style={{ cursor: 'pointer' }}>Torneos</span>
          <span onClick={() => setCurrentPage('futures')} style={{ cursor: 'pointer' }}>Futures Games</span>
          <span onClick={() => setCurrentPage('slots')} style={{ cursor: 'pointer' }}>Tragamonedas</span>
          <span onClick={() => setCurrentPage('minigames')} style={{ cursor: 'pointer' }}>Minijuego</span>
        </div>
        
        <div className="nav-right">
          <div className="balance-pill" style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <img src="/ntx.png" alt="NTX" style={{ width: '20px', height: '20px', borderRadius: '50%', objectFit: 'cover' }} onError={(e) => { e.target.style.display = 'none'; }} />
            {balance.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2})} NTX-20
          </div>
          <div className="user-profile" onClick={() => setIsMenuOpen(!isMenuOpen)}>
            
            <div className="user-avatar" style={{ overflow: 'hidden', display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'transparent' }}>
              <img src={avatarToShow} alt="avatar" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
            </div>
            <span style={{ fontWeight: '600', fontSize: '0.9rem' }}>{user?.username || 'Jugador'}</span>
            
            {isMenuOpen && (
              <div className="dropdown-menu">
                <div className="dropdown-header">
                  <div className="dropdown-header-left">
                    
                    <div className="user-avatar" style={{ width: '40px', height: '40px', fontSize: '1.2rem', overflow: 'hidden', display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'transparent' }}>
                      <img src={avatarToShow} alt="avatar" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                    </div>
                    <div><h4>{user?.username || 'Jugador'}</h4><p>@{user?.unique_id || 'royalbet'}</p></div>
                  </div>
                  <Icons.ChevronRight />
                </div>
                <div className="dropdown-item" onClick={() => { setCurrentPage('profile'); setIsMenuOpen(false); }}><Icons.User /> Perfil</div>
                <div className="dropdown-item" onClick={() => { setCurrentPage('wallet'); setIsMenuOpen(false); }}><Icons.Wallet /> Billetera</div>
                
                <div className="dropdown-item" onClick={() => { setCurrentPage('activity'); setIsMenuOpen(false); }}><Icons.Activity /> Mi partido</div>

                {user?.role === 'superadmin' && (
                  <div className="dropdown-item" onClick={() => { setCurrentPage('admin-billetera'); setIsMenuOpen(false); }} style={{ color: '#e2b04a' }}>
                    <Icons.Shield /> Admin Billetera
                  </div>
                )}

                <div className="dropdown-divider"></div>
                <div className="dropdown-item" onClick={() => { setCurrentPage('invite'); setIsMenuOpen(false); }}><Icons.Users /> Invite Friends</div>
                <div className="dropdown-divider"></div>
                <div className="dropdown-item" onClick={() => { setCurrentPage('security'); setIsMenuOpen(false); }}><Icons.Shield /> Seguridad</div>
                
                {user?.role === 'superadmin' && (
                  <div className="dropdown-item" onClick={() => { setCurrentPage('server-config'); setIsMenuOpen(false); }} style={{ color: '#00e676' }}>
                    <Icons.Settings /> Config Servidor
                  </div>
                )}

                <div className="dropdown-item" onClick={() => { setCurrentPage('settings'); setIsMenuOpen(false); }}><Icons.Settings /> Ajustes</div>
                <div className="dropdown-item logout" onClick={handleLogout}><Icons.Logout /> Finalizar la sesion</div>
              </div>
            )}
          </div>
        </div>
      </header>

      {currentPage === 'lobby' && (
        <main className="main-area">
          <div className="content-scroll" style={{ padding: '1.5rem' }}>
            
            <div style={{ position: 'relative', width: '100%', aspectRatio: '1248 / 490', borderRadius: '12px', overflow: 'hidden', marginBottom: '1.5rem', border: '1px solid #2d3748', backgroundColor: '#1a202c' }}>
              <div style={{ display: 'flex', transition: 'transform 0.5s ease-in-out', transform: `translateX(-${currentBannerIndex * 100}%)`, height: '100%' }}>
                {bannersData.map((banner, index) => (
                  <div key={banner.id} style={{ minWidth: '100%', height: '100%' }}>
                    <img src={banner.image} alt={banner.alt} style={{ width: '100%', height: '100%', objectFit: 'cover', display: 'block' }} onError={(e) => { e.target.style.display='none'; }} />
                  </div>
                ))}
              </div>
              
              {bannersData.length > 1 && (
                <div style={{ position: 'absolute', bottom: '15px', left: '50%', transform: 'translateX(-50%)', display: 'flex', gap: '8px' }}>
                  {bannersData.map((_, index) => (
                    <div 
                      key={index} 
                      onClick={() => setCurrentBannerIndex(index)}
                      style={{
                        width: '10px', height: '10px', borderRadius: '50%', cursor: 'pointer',
                        backgroundColor: index === currentBannerIndex ? '#00e676' : 'rgba(255,255,255,0.4)',
                        transition: 'background-color 0.3s'
                      }}
                    />
                  ))}
                </div>
              )}
            </div>

            <div className="lobby-categories">
              <div className="category-icon" onClick={() => setCurrentPage('casual')} style={{ cursor: 'pointer' }}><div className="icon-circle"><Icons.Cards /></div><span>Casual Rooms</span></div>
              <div className="category-icon" onClick={() => setCurrentPage('tournaments')} style={{ cursor: 'pointer' }}><div className="icon-circle"><Icons.Trophy /></div><span>Torneos</span></div>
              <div className="category-icon" onClick={() => setCurrentPage('minigames')} style={{ cursor: 'pointer' }}><div className="icon-circle"><Icons.Star /></div><span>Minijuego</span></div>
              <div className="category-icon" onClick={() => setCurrentPage('slots')} style={{ cursor: 'pointer' }}><div className="icon-circle"><Icons.Gamepad /></div><span>Tragamonedas</span></div>
              <div className="category-icon" onClick={() => setCurrentPage('mail')} style={{ cursor: 'pointer' }}><div className="icon-circle"><Icons.MailIcon /></div><span>Mail</span></div>
              <div className="category-icon" onClick={() => setCurrentPage('market')} style={{ cursor: 'pointer' }}><div className="icon-circle"><Icons.Wallet /></div><span>Mercado</span></div>
            </div>

            <div style={{ marginBottom: '2rem' }}>
              <div className="section-header" style={{ marginBottom: '1rem' }}>
                <h2 style={{ fontSize: '1.1rem' }}>Casual Rooms <span style={{fontSize: '0.8rem', color: '#a0aec0', fontWeight: '400'}}>24 | 114</span> <span style={{color: '#00e676', fontSize: '0.8rem'}}>Vestibulo</span></h2>
              </div>
              <CasualRooms onJoinTable={joinTable} />
            </div>

            <div style={{ marginBottom: '2rem' }}>
              <div className="section-header" style={{ marginBottom: '1rem' }}>
                <h2 style={{ fontSize: '1.1rem' }}>Futures Games <span style={{fontSize: '0.8rem', color: '#a0aec0', fontWeight: '400'}}>8 | 8</span> <span style={{color: '#00e676', fontSize: '0.8rem'}}>En Vivo</span></h2>
              </div>
              <FuturesGames limit={4} onEnterTournament={setActiveTournament} />
            </div>

          </div>
        </main>
      )}

      {currentPage === 'casual' && <CasualRooms onBack={() => setCurrentPage('lobby')} onJoinTable={joinTable} />}
      {currentPage === 'tournaments' && (
        <TournamentHub
          user={user}
          onBack={() => setCurrentPage('lobby')}
          onEnterTournament={joinTable}
          showToast={setToast}
        />
      )}
      {currentPage === 'futures' && <FuturesGames onBack={() => setCurrentPage('lobby')} onEnterTournament={setActiveTournament} />}
      {currentPage === 'slots' && <PlaceholderPage title="Tragamonedas" icon="Slot" onBack={() => setCurrentPage('lobby')} />}
      {currentPage === 'minigames' && <PlaceholderPage title="Minijuegos" icon="Gamepad" onBack={() => setCurrentPage('lobby')} />}
      {currentPage === 'mail' && <Mailbox user={user} onBack={() => setCurrentPage('lobby')} />}
      {currentPage === 'market' && <PlaceholderPage title="Mercado de Fichas" icon="Market" onBack={() => setCurrentPage('lobby')} />}
      
      {currentPage === 'activity' && <ActivityCenter user={user} onBack={() => setCurrentPage('lobby')} />}

      {SHOW_CLUB_MODULE && currentPage === 'club' && <Club user={user} onBack={() => setCurrentPage('lobby')} />}

      {currentPage === 'changelog' && (
        <main className="main-area">
          <div className="changelog-container">
            <h1 className="changelog-title">Registro de cambios</h1>
            {changelogData.map((item, index) => (
              <div key={index} className="changelog-item">
                <div className="changelog-version">{item.version}</div>
                <div className="changelog-date">Updated time {item.date}</div>
                <ol className="changelog-list">
                  {item.changes.map((change, i) => (
                    <li key={i}><strong>{change.title}:</strong> {change.desc}</li>
                  ))}
                </ol>
              </div>
            ))}
          </div>
        </main>
      )}

      {currentPage === 'wallet' && <Wallet balance={balance} user={user} fetchBalance={fetchBalance} onBack={() => setCurrentPage('lobby')} />}
      {currentPage === 'admin-billetera' && <AdminPanel user={user} onBack={() => setCurrentPage('lobby')} />}
      {currentPage === 'invite' && <InviteFriends user={user} referralStats={referralStats} />}

      {currentPage === 'security' && (
        <Security
          user={user}
          setUser={setUser} // 🔥 AGREGADO AQUÍ: Para que Security pueda actualizar el teléfono
          hasPin={hasPin}
          pinEnabled={pinEnabled}
          showPasswordForm={showPasswordForm}
          showPinForm={showPinForm}
          oldPassword={oldPassword}
          newPassword={newPassword}
          newPin={newPin}
          setOldPassword={setOldPassword}
          setNewPassword={setNewPassword}
          setNewPin={setNewPin}
          setShowPasswordForm={setShowPasswordForm}
          setShowPinForm={setShowPinForm}
          handleChangePassword={handleChangePassword}
          handleSavePin={handleSavePin}
          handleTogglePin={handleTogglePin}
          setCurrentPage={setCurrentPage}
          setIsEditingProfile={setIsEditingProfile}
          Icons={Icons}
        />
      )}

      {currentPage === 'server-config' && <ServerConfig onBack={() => setCurrentPage('lobby')} />}

      {currentPage === 'settings' && (
        <Settings
          settingsTab={settingsTab}
          setSettingsTab={setSettingsTab}
          settings={settings}
          handleSettingChange={handleSettingChange}
          handleSaveSettings={handleSaveSettings}
        />
      )}

      {currentPage === 'profile' && (
        <Profile
          user={user}
          balance={balance}
          profileData={profileData}
          setProfileData={setProfileData}
          isEditingProfile={isEditingProfile}
          setIsEditingProfile={setIsEditingProfile}
          handleSaveProfile={handleSaveProfile}
          profileTab={profileTab}
          setProfileTab={setProfileTab}
          Icons={Icons}
        />
      )}

      {/* 🔥 BARRA DE NAVEGACIÓN INFERIOR (SOLO MÓVIL) 🔥 */}
      <nav className="mobile-bottom-nav">
        <div className={`mbn-item ${currentPage === 'lobby' ? 'active' : ''}`} onClick={() => setCurrentPage('lobby')}>
          <Icons.Home /><span>Inicio</span>
        </div>
        <div className={`mbn-item ${currentPage === 'tournaments' ? 'active' : ''}`} onClick={() => setCurrentPage('tournaments')}>
          <Icons.Trophy /><span>Torneos</span>
        </div>
        <div className={`mbn-item ${currentPage === 'casual' ? 'active' : ''}`} onClick={() => setCurrentPage('casual')}>
          <Icons.Cards /><span>Mesas</span>
        </div>
        <div className={`mbn-item ${currentPage === 'mail' ? 'active' : ''}`} onClick={() => setCurrentPage('mail')}>
          <Icons.News /><span>Mail</span>
        </div>
        <div className={`mbn-item ${currentPage === 'profile' ? 'active' : ''}`} onClick={() => setCurrentPage('profile')}>
          <Icons.User /><span>Perfil</span>
        </div>
      </nav>

    </div>
  );
}

export default App;