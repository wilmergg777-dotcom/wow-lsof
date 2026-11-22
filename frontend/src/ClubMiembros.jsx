import React from 'react';

const ClubMiembros = ({ onBack }) => (
  <div style={{ backgroundColor: '#0a0a0a', minHeight: '100vh', paddingBottom: '90px' }}>
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px 20px', borderBottom: '1px solid #222' }}>
      <button onClick={onBack} style={{ background: 'none', border: 'none', color: 'white', fontSize: '24px', cursor: 'pointer' }}>‹</button>
      <h2 style={{ margin: 0, fontSize: '18px', color: 'white', fontWeight: 'bold' }}>Miembros del Club</h2>
      <span style={{ fontSize: '20px' }}>👥</span>
    </div>
    <div style={{ padding: '20px', textAlign: 'center', color: '#888' }}>
      <p>Lista de miembros (Próximamente).</p>
    </div>
  </div>
);

export default ClubMiembros;