import { useState, useEffect } from 'react';
import { useNavigate, Routes, Route } from 'react-router-dom';
import apiFetch from '../services/apiClient';
import Simulador from './Simulador';
import PasarelaPago from './PasarelaPago';

const STEPS = [
  { label: 'Solicitud', key: 'solicitud' },
  { label: 'Evaluación', key: 'evaluacion' },
  { label: 'Contrato', key: 'contrato' },
  { label: 'Desembolso', key: 'desembolso' },
  { label: 'Pagos', key: 'pagos' },
];

function getStepIndex(status) {
  if (!status) return 0;
  if (status === 'Rechazado') return 1;
  if (status === 'Pre-aprobado') return 2;
  if (status === 'Aprobado - Pendiente Desembolso') return 3;
  if (status === 'Desembolsado') return 4;
  return 0;
}

export default function Dashboard({ token, role, onLogout }) {
  const [credit, setCredit] = useState(() => {
    const saved = localStorage.getItem('activeCredit');
    return saved ? JSON.parse(saved) : null;
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    if (credit) localStorage.setItem('activeCredit', JSON.stringify(credit));
    else localStorage.removeItem('activeCredit');
  }, [credit]);

  // Auto-refresh credit status
  useEffect(() => {
    const checkStatus = async () => {
      if (credit && credit.id) {
        try {
          const { schedule } = await apiFetch(`/credit/schedule?creditId=${credit.id}`);
          if (schedule && schedule.length > 0 && credit.status !== 'Desembolsado') {
            setCredit(prev => ({ ...prev, status: 'Desembolsado' }));
          }
        } catch (e) {}
      }
    };
    checkStatus();
  }, []);

  const evaluateCredit = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await apiFetch('/credit/evaluate', { method: 'POST' });
      setCredit(data.credit);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const signContract = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await apiFetch('/credit/contract', { 
        method: 'POST', 
        body: JSON.stringify({ creditId: credit.id, accepted: true }) 
      });
      setCredit(data.credit);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const stepIndex = getStepIndex(credit?.status);

  return (
    <div className="min-h-screen">
      {/* Navbar */}
      <nav className="navbar">
        <div className="navbar-brand">
          <span className="logo-icon">💳</span>
          Microcréditos Flow
        </div>
        <div className="navbar-links">
          <button onClick={() => navigate('/dashboard')} className="nav-link active">📊 Mi Panel</button>
          <button onClick={onLogout} className="nav-link">Cerrar Sesión</button>
        </div>
      </nav>

      <div style={{ maxWidth: '56rem', margin: '0 auto', padding: '2rem 1.5rem' }}>
        {error && <div className="alert-error mb-6">{error}</div>}

        <Routes>
          <Route path="/" element={
            <div className="animate-fade-in">
              {/* Progress Bar */}
              {credit && (
                <div className="progress-bar mb-8">
                  {STEPS.map((step, i) => (
                    <div key={step.key} className={`progress-step ${i < stepIndex ? 'completed' : ''} ${i === stepIndex ? 'active' : ''}`}>
                      <div className="step-circle">
                        {i < stepIndex ? '✓' : i + 1}
                      </div>
                      {i < STEPS.length - 1 && <div className="step-line"></div>}
                    </div>
                  ))}
                </div>
              )}

              {!credit ? (
                <Simulador evaluateCredit={evaluateCredit} loading={loading} />
              ) : (
                <div className="space-y-6">
                  {/* Credit Summary Card */}
                  <div className="card-glow">
                    <div className="flex justify-between items-center mb-4">
                      <h3 className="text-lg font-bold text-white">Estado de tu Solicitud</h3>
                      <span className={`badge ${credit.status.includes('Rechazado') ? 'badge-danger' : credit.status === 'Desembolsado' ? 'badge-success' : 'badge-brand'}`}>
                        {credit.status}
                      </span>
                    </div>

                    {/* Stats */}
                    <div className="grid grid-cols-3 gap-4 mb-4">
                      <div className="stat-card">
                        <div className="stat-label">Monto Aprobado</div>
                        <div className="stat-value" style={{ color: 'var(--success)' }}>S/ {credit.montoAprobado?.toLocaleString()}</div>
                      </div>
                      <div className="stat-card">
                        <div className="stat-label">Tasa (TEA)</div>
                        <div className="stat-value">{((credit.tasaInteres || 0.15) * 100).toFixed(0)}%</div>
                      </div>
                      <div className="stat-card">
                        <div className="stat-label">Plazo</div>
                        <div className="stat-value">{credit.plazoMeses} meses</div>
                      </div>
                    </div>

                    <div style={{ fontSize: '0.75rem', color: 'var(--gray-500)' }}>
                      ID del Crédito: <strong style={{ color: 'var(--gray-300)' }}>#{credit.id}</strong>
                    </div>
                  </div>

                  {/* Actions based on status */}
                  {credit.status === 'Pre-aprobado' && (
                    <div className="card">
                      <h4 className="font-semibold text-brand-400 mb-2">📄 Contrato Digital</h4>
                      <p className="text-sm text-gray-400 mb-4">
                        Tu crédito ha sido pre-aprobado. Revisa las condiciones y firma digitalmente para proceder.
                      </p>
                      <button onClick={signContract} disabled={loading} className="btn-primary w-full">
                        {loading ? <><span className="spinner"></span> Firmando...</> : '✍️ Aceptar y Firmar Contrato'}
                      </button>
                    </div>
                  )}

                  {credit.status === 'Aprobado - Pendiente Desembolso' && (
                    <div className="card" style={{ borderColor: 'rgba(245, 158, 11, 0.2)' }}>
                      <div className="flex items-center gap-3">
                        <div style={{ fontSize: '1.5rem' }}>⏳</div>
                        <div>
                          <h4 className="font-semibold text-white">Pendiente de Desembolso</h4>
                          <p className="text-sm text-gray-400">
                            Tu contrato ha sido firmado. Un operador procesará el desembolso a tu billetera digital pronto.
                          </p>
                        </div>
                      </div>
                    </div>
                  )}

                  {credit.status === 'Desembolsado' && (
                    <div className="card">
                      <div className="flex items-center gap-3 mb-4">
                        <div style={{ fontSize: '1.5rem' }}>🎉</div>
                        <div>
                          <h4 className="font-semibold text-white">¡Crédito Desembolsado!</h4>
                          <p className="text-sm text-gray-400">Los fondos han sido transferidos. Puedes consultar tu cronograma de pagos.</p>
                        </div>
                      </div>
                      <button onClick={() => navigate('/dashboard/pagos')} className="btn-success w-full">
                        📋 Ver Cronograma y Pagar
                      </button>
                    </div>
                  )}

                  {credit.status === 'Rechazado' && (
                    <div className="card" style={{ borderColor: 'rgba(239, 68, 68, 0.2)' }}>
                      <div className="flex items-center gap-3">
                        <div style={{ fontSize: '1.5rem' }}>❌</div>
                        <div>
                          <h4 className="font-semibold text-white">Solicitud Rechazada</h4>
                          <p className="text-sm text-gray-400">Tu capacidad de pago no cumple los requisitos mínimos.</p>
                        </div>
                      </div>
                    </div>
                  )}
                </div>
              )}
            </div>
          } />
          <Route path="/pagos" element={<PasarelaPago creditId={credit?.id} />} />
        </Routes>
      </div>
    </div>
  );
}
