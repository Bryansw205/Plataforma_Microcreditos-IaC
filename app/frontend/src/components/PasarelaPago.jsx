import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import apiFetch from '../services/apiClient';

function downloadCSV(schedule, creditId) {
  const header = 'Cuota,Monto (S/),Fecha Vencimiento,Estado\n';
  const rows = schedule.map(s => 
    `${s.cuota},${s.amount},${new Date(s.dueDate).toLocaleDateString('es-PE')},${s.status}`
  ).join('\n');
  
  const blob = new Blob([header + rows], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = `cronograma_credito_${creditId}.csv`;
  link.click();
  URL.revokeObjectURL(url);
}

export default function PasarelaPago({ creditId }) {
  const [schedule, setSchedule] = useState([]);
  const [loading, setLoading] = useState(false);
  const [cardNumber, setCardNumber] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [selectedCuota, setSelectedCuota] = useState(null);
  const [successMsg, setSuccessMsg] = useState(null);
  const navigate = useNavigate();

  const loadSchedule = async () => {
    try {
      const data = await apiFetch(`/credit/schedule?creditId=${creditId}`);
      setSchedule(data.schedule);
    } catch (e) {}
  };

  useEffect(() => {
    if (creditId) loadSchedule();
  }, [creditId]);

  const handlePay = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      await apiFetch('/credit/pay', {
        method: 'POST',
        body: JSON.stringify({ creditId, cuota: selectedCuota.cuota, tokenTarjeta: cardNumber })
      });
      setSuccessMsg(`Cuota ${selectedCuota.cuota} pagada exitosamente`);
      setShowModal(false);
      setCardNumber('');
      loadSchedule();
      setTimeout(() => setSuccessMsg(null), 3000);
    } catch (err) {
      alert(err.message);
    } finally {
      setLoading(false);
    }
  };

  const paid = schedule.filter(s => s.status === 'Pagada').length;
  const total = schedule.length;
  const totalAmount = schedule.reduce((sum, s) => sum + s.amount, 0);
  const paidAmount = schedule.filter(s => s.status === 'Pagada').reduce((sum, s) => sum + s.amount, 0);

  return (
    <div className="animate-fade-in">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold text-white">📋 Cronograma de Pagos</h2>
        <div className="flex gap-3">
          <button onClick={() => downloadCSV(schedule, creditId)} className="btn-secondary text-sm">
            📥 Descargar CSV
          </button>
          <button onClick={() => navigate('/dashboard')} className="btn-secondary text-sm">
            ← Volver
          </button>
        </div>
      </div>

      {successMsg && <div className="alert-success mb-4">✅ {successMsg}</div>}

      {/* Summary Stats */}
      {schedule.length > 0 && (
        <div className="grid grid-cols-3 gap-4 mb-6">
          <div className="stat-card">
            <div className="stat-label">Cuotas Pagadas</div>
            <div className="stat-value" style={{ color: 'var(--success)' }}>{paid}/{total}</div>
          </div>
          <div className="stat-card">
            <div className="stat-label">Monto Pagado</div>
            <div className="stat-value">S/ {paidAmount.toFixed(2)}</div>
          </div>
          <div className="stat-card">
            <div className="stat-label">Saldo Pendiente</div>
            <div className="stat-value" style={{ color: 'var(--warning)' }}>S/ {(totalAmount - paidAmount).toFixed(2)}</div>
          </div>
        </div>
      )}

      {/* Progress */}
      {total > 0 && (
        <div className="card mb-6" style={{ padding: '1rem 1.5rem' }}>
          <div className="flex justify-between text-sm mb-2">
            <span className="text-gray-400">Progreso de pago</span>
            <span className="text-white font-medium">{((paid / total) * 100).toFixed(0)}%</span>
          </div>
          <div style={{ height: '8px', borderRadius: '4px', background: 'var(--surface)', overflow: 'hidden' }}>
            <div style={{ 
              height: '100%', 
              width: `${(paid / total) * 100}%`, 
              background: 'linear-gradient(90deg, var(--brand-600), var(--success))',
              borderRadius: '4px',
              transition: 'width 0.5s ease'
            }}></div>
          </div>
        </div>
      )}

      {/* Schedule Table */}
      {!schedule.length ? (
        <div className="card text-center" style={{ padding: '3rem' }}>
          <div style={{ fontSize: '2.5rem', marginBottom: '1rem' }}>📭</div>
          <p className="text-gray-400">No se encontró el cronograma.</p>
        </div>
      ) : (
        <div className="table-container">
          <table>
            <thead>
              <tr>
                <th>Cuota</th>
                <th>Monto</th>
                <th>Vencimiento</th>
                <th>Estado</th>
                <th style={{ textAlign: 'right' }}>Acción</th>
              </tr>
            </thead>
            <tbody>
              {schedule.map(s => (
                <tr key={s.id}>
                  <td className="font-medium text-white">#{s.cuota}</td>
                  <td>S/ {s.amount.toFixed(2)}</td>
                  <td>{new Date(s.dueDate).toLocaleDateString('es-PE')}</td>
                  <td>
                    <span className={`badge ${s.status === 'Pagada' ? 'badge-success' : 'badge-warning'}`}>
                      {s.status === 'Pagada' ? '✓ Pagada' : '⏳ Pendiente'}
                    </span>
                  </td>
                  <td style={{ textAlign: 'right' }}>
                    {s.status === 'Pendiente' ? (
                      <button 
                        onClick={() => { setSelectedCuota(s); setShowModal(true); }}
                        className="btn-primary text-sm"
                        style={{ padding: '0.375rem 1rem' }}
                      >
                        💳 Pagar
                      </button>
                    ) : (
                      <span className="text-gray-600">—</span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Payment Modal */}
      {showModal && (
        <div className="modal-overlay">
          <div className="modal-content">
            <div className="text-center mb-6">
              <div style={{ fontSize: '2rem', marginBottom: '0.5rem' }}>💳</div>
              <h3 className="text-lg font-bold text-white">Pasarela de Pago</h3>
              <p className="text-sm text-gray-500">Simulación Flow</p>
            </div>

            <div className="card mb-4" style={{ background: 'var(--surface)', padding: '1rem' }}>
              <div className="flex justify-between text-sm">
                <span className="text-gray-400">Cuota</span>
                <span className="text-white font-medium">#{selectedCuota.cuota}</span>
              </div>
              <div className="flex justify-between text-sm mt-2">
                <span className="text-gray-400">Monto</span>
                <span className="text-white font-bold">S/ {selectedCuota.amount.toFixed(2)}</span>
              </div>
            </div>
            
            <form onSubmit={handlePay} className="space-y-4">
              <div>
                <label className="block text-sm text-gray-400 mb-1">Número de Tarjeta</label>
                <input 
                  required 
                  type="text" 
                  placeholder="4111 1111 1111 1111"
                  className="input-field" 
                  value={cardNumber} 
                  onChange={e => setCardNumber(e.target.value)} 
                />
              </div>
              <div className="flex gap-3">
                <button type="button" onClick={() => setShowModal(false)} className="btn-secondary flex-1">Cancelar</button>
                <button type="submit" disabled={loading} className="btn-primary flex-1">
                  {loading ? <><span className="spinner"></span></> : '✅ Confirmar Pago'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
