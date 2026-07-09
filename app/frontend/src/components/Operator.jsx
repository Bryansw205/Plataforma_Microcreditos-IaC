import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import apiFetch from '../services/apiClient';

export default function Operator({ token, onLogout }) {
  const [creditId, setCreditId] = useState('');
  const [pendingCredits, setPendingCredits] = useState([]);
  const [loading, setLoading] = useState(false);
  const [loadingList, setLoadingList] = useState(true);
  const [successMsg, setSuccessMsg] = useState(null);
  const navigate = useNavigate();

  const loadPending = async () => {
    setLoadingList(true);
    try {
      const data = await apiFetch('/operator/pending');
      setPendingCredits(data.credits || []);
    } catch (e) {
      console.error(e);
    } finally {
      setLoadingList(false);
    }
  };

  useEffect(() => {
    loadPending();
  }, []);

  const handleDisburse = async (id) => {
    setLoading(true);
    try {
      await apiFetch('/operator/disburse', { 
        method: 'POST', 
        body: JSON.stringify({ creditId: Number(id) }) 
      });
      setSuccessMsg(`Crédito #${id} desembolsado exitosamente.`);
      loadPending();
      setTimeout(() => setSuccessMsg(null), 4000);
    } catch (e) {
      alert(e.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen">
      {/* Navbar */}
      <nav className="navbar">
        <div className="navbar-brand">
          <span className="logo-icon">🔧</span>
          Panel de Operador
        </div>
        <div className="navbar-links">
          <button onClick={onLogout} className="nav-link">Cerrar Sesión</button>
        </div>
      </nav>

      <div style={{ maxWidth: '64rem', margin: '0 auto', padding: '2rem 1.5rem' }}>
        <div className="animate-fade-in">
          
          {successMsg && <div className="alert-success mb-6">✅ {successMsg}</div>}

          {/* Quick Disburse */}
          <div className="card mb-6">
            <h3 className="text-lg font-bold text-white mb-2">⚡ Desembolso Rápido</h3>
            <p className="text-sm text-gray-400 mb-4">Ingresa directamente el ID del crédito para aprobar el desembolso.</p>
            <div className="flex gap-4">
              <input 
                type="number" 
                className="input-field" 
                style={{ maxWidth: '200px' }}
                placeholder="ID del Crédito" 
                value={creditId} 
                onChange={e => setCreditId(e.target.value)} 
              />
              <button 
                onClick={() => handleDisburse(creditId)} 
                disabled={loading || !creditId} 
                className="btn-success"
              >
                {loading ? <><span className="spinner"></span></> : '✅ Aprobar Desembolso'}
              </button>
            </div>
          </div>

          {/* Pending Credits Table */}
          <div className="card">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-bold text-white">📋 Créditos Pendientes de Desembolso</h3>
              <button onClick={loadPending} className="btn-secondary text-sm">🔄 Actualizar</button>
            </div>

            {loadingList ? (
              <div className="text-center p-8">
                <div className="spinner" style={{ width: '2rem', height: '2rem', borderWidth: '3px' }}></div>
                <p className="text-gray-400 mt-4">Cargando...</p>
              </div>
            ) : pendingCredits.length === 0 ? (
              <div className="text-center p-8">
                <div style={{ fontSize: '2.5rem', marginBottom: '1rem' }}>✨</div>
                <p className="text-gray-400">No hay créditos pendientes de desembolso.</p>
              </div>
            ) : (
              <div className="table-container">
                <table>
                  <thead>
                    <tr>
                      <th>ID</th>
                      <th>DNI Cliente</th>
                      <th>Monto</th>
                      <th>Plazo</th>
                      <th>Tasa</th>
                      <th>Estado</th>
                      <th style={{ textAlign: 'right' }}>Acción</th>
                    </tr>
                  </thead>
                  <tbody>
                    {pendingCredits.map(c => (
                      <tr key={c.id}>
                        <td className="font-medium text-white">#{c.id}</td>
                        <td>{c.user?.dni || '—'}</td>
                        <td className="font-medium" style={{ color: 'var(--success)' }}>S/ {c.montoAprobado?.toLocaleString()}</td>
                        <td>{c.plazoMeses} meses</td>
                        <td>{((c.tasaInteres || 0.15) * 100).toFixed(0)}%</td>
                        <td><span className="badge badge-warning">Pendiente</span></td>
                        <td style={{ textAlign: 'right' }}>
                          <button 
                            onClick={() => handleDisburse(c.id)} 
                            disabled={loading}
                            className="btn-success text-sm"
                          >
                            Desembolsar
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
