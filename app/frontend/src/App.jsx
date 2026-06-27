import { useState, useEffect } from 'react';

// API BASE URL - AGNÓSTICO A LA INFRAESTRUCTURA (por defecto local)
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000';

export default function App() {
  const [token, setToken] = useState(localStorage.getItem('token'));
  const [user, setUser] = useState(null);
  const [currentView, setCurrentView] = useState('login'); // login, register, dashboard, operator
  
  // States for flow
  const [dni, setDni] = useState('');
  const [ingresos, setIngresos] = useState('');
  const [gastos, setGastos] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [credit, setCredit] = useState(null);
  const [schedule, setSchedule] = useState(null);

  useEffect(() => {
    if (token) setCurrentView('dashboard');
  }, [token]);

  const apiFetch = async (endpoint, options = {}) => {
    setLoading(true);
    setError(null);
    try {
      const headers = { 'Content-Type': 'application/json' };
      if (token) headers['Authorization'] = `Bearer ${token}`;
      
      const res = await fetch(`${API_URL}${endpoint}`, { ...options, headers });
      const data = await res.json();
      
      if (!res.ok) throw new Error(data.error || 'Error en la petición');
      setLoading(false);
      return data;
    } catch (err) {
      setLoading(false);
      setError(err.message);
      throw err;
    }
  };

  const handleLogin = async (e) => {
    e.preventDefault();
    try {
      const data = await apiFetch('/auth/login', {
        method: 'POST',
        body: JSON.stringify({ dni })
      });
      localStorage.setItem('token', data.token);
      setToken(data.token);
      setCurrentView('dashboard');
    } catch (e) {}
  };

  const handleRegister = async (e) => {
    e.preventDefault();
    try {
      await apiFetch('/auth/register', {
        method: 'POST',
        body: JSON.stringify({ dni, ingresos: Number(ingresos), gastos: Number(gastos) })
      });
      setCurrentView('login');
      alert('Registro exitoso. Ahora inicia sesión.');
    } catch (e) {}
  };

  const logout = () => {
    localStorage.removeItem('token');
    setToken(null);
    setCredit(null);
    setSchedule(null);
    setCurrentView('login');
  };

  const evaluateCredit = async () => {
    try {
      const data = await apiFetch('/credit/evaluate', { method: 'POST' });
      setCredit(data.credit);
    } catch (e) {}
  };

  const signContract = async () => {
    try {
      const data = await apiFetch('/credit/contract', { 
        method: 'POST', 
        body: JSON.stringify({ creditId: credit.id, accepted: true }) 
      });
      setCredit(data.credit);
    } catch (e) {}
  };

  const getSchedule = async () => {
    try {
      const data = await apiFetch(`/credit/schedule?creditId=${credit.id}`);
      setSchedule(data.schedule);
    } catch (e) {}
  };

  const payCuota = async (cuota) => {
    try {
      await apiFetch('/credit/pay', { 
        method: 'POST', 
        body: JSON.stringify({ creditId: credit.id, cuota }) 
      });
      getSchedule(); // Refresh
    } catch (e) {}
  };

  // VISTAS
  if (currentView === 'login') {
    return (
      <div className="min-h-screen flex items-center justify-center p-4">
        <div className="card w-full max-w-md animate-fade-in">
          <h2 className="text-2xl font-bold mb-6 text-center text-brand-500">Microcréditos Flow</h2>
          {error && <div className="bg-red-500/10 border border-red-500 text-red-400 p-3 rounded mb-4 text-sm">{error}</div>}
          
          <form onSubmit={handleLogin} className="space-y-4">
            <div>
              <label className="block text-sm text-gray-400 mb-1">DNI</label>
              <input required type="text" className="input-field" value={dni} onChange={e => setDni(e.target.value)} />
            </div>
            <button disabled={loading} type="submit" className="btn-primary w-full">
              {loading ? 'Ingresando...' : 'Ingresar'}
            </button>
            <div className="text-center mt-4">
              <button type="button" onClick={() => setCurrentView('register')} className="text-brand-500 text-sm hover:underline">
                ¿No tienes cuenta? Regístrate
              </button>
            </div>
          </form>
        </div>
      </div>
    );
  }

  if (currentView === 'register') {
    return (
      <div className="min-h-screen flex items-center justify-center p-4">
        <div className="card w-full max-w-md animate-fade-in">
          <h2 className="text-2xl font-bold mb-6 text-center text-brand-500">Registro</h2>
          {error && <div className="bg-red-500/10 border border-red-500 text-red-400 p-3 rounded mb-4 text-sm">{error}</div>}
          
          <form onSubmit={handleRegister} className="space-y-4">
            <div>
              <label className="block text-sm text-gray-400 mb-1">DNI</label>
              <input required type="text" className="input-field" value={dni} onChange={e => setDni(e.target.value)} />
            </div>
            <div>
              <label className="block text-sm text-gray-400 mb-1">Ingresos Mensuales</label>
              <input required type="number" className="input-field" value={ingresos} onChange={e => setIngresos(e.target.value)} />
            </div>
            <div>
              <label className="block text-sm text-gray-400 mb-1">Gastos Mensuales</label>
              <input required type="number" className="input-field" value={gastos} onChange={e => setGastos(e.target.value)} />
            </div>
            <button disabled={loading} type="submit" className="btn-primary w-full">
              {loading ? 'Registrando...' : 'Registrar'}
            </button>
            <div className="text-center mt-4">
              <button type="button" onClick={() => setCurrentView('login')} className="text-brand-500 text-sm hover:underline">
                Volver al Login
              </button>
            </div>
          </form>
        </div>
      </div>
    );
  }

  if (currentView === 'dashboard') {
    return (
      <div className="min-h-screen p-6 max-w-4xl mx-auto animate-fade-in">
        <div className="flex justify-between items-center mb-8 border-b border-gray-800 pb-4">
          <h1 className="text-3xl font-bold text-white">Mi Panel</h1>
          <div className="flex gap-4">
            <button onClick={() => setCurrentView('operator')} className="text-sm text-brand-500 hover:underline">Vista Operador</button>
            <button onClick={logout} className="text-sm text-gray-400 hover:text-white">Cerrar Sesión</button>
          </div>
        </div>

        {error && <div className="bg-red-500/10 border border-red-500 text-red-400 p-3 rounded mb-6 text-sm">{error}</div>}

        {!credit ? (
          <div className="card text-center py-12">
            <h3 className="text-xl mb-4">¿Necesitas un crédito?</h3>
            <p className="text-gray-400 mb-6 max-w-md mx-auto">Solicita una evaluación al instante. Analizaremos tu perfil de forma segura.</p>
            <button onClick={evaluateCredit} disabled={loading} className="btn-primary px-8 py-3 text-lg">
              {loading ? 'Evaluando...' : 'Evaluar mi Perfil'}
            </button>
          </div>
        ) : (
          <div className="space-y-6">
            <div className="card">
              <h3 className="text-lg font-semibold mb-2">Estado de tu Solicitud</h3>
              <div className="flex justify-between items-center bg-surface p-4 rounded-lg">
                <span className="text-gray-400">ID: #{credit.id}</span>
                <span className={`px-3 py-1 rounded-full text-xs font-medium 
                  ${credit.status.includes('Rechazado') ? 'bg-red-500/20 text-red-400' : 'bg-green-500/20 text-green-400'}`}>
                  {credit.status}
                </span>
              </div>
              
              {credit.status === 'Pre-aprobado' && (
                <div className="mt-6 border-t border-gray-800 pt-4">
                  <h4 className="font-medium text-brand-500 mb-2">Contrato Digital</h4>
                  <p className="text-sm text-gray-400 mb-4">Monto pre-aprobado: S/ {credit.montoAprobado}</p>
                  <button onClick={signContract} disabled={loading} className="btn-primary w-full">Aceptar y Firmar Contrato</button>
                </div>
              )}
            </div>

            {credit.status === 'Desembolsado' && !schedule && (
              <button onClick={getSchedule} disabled={loading} className="btn-secondary w-full">Ver Cronograma de Pagos</button>
            )}

            {schedule && (
              <div className="card">
                <h3 className="text-lg font-semibold mb-4">Cronograma de Pagos</h3>
                <div className="space-y-3">
                  {schedule.map(s => (
                    <div key={s.cuota} className="flex justify-between items-center p-3 bg-surface rounded-lg border border-gray-800">
                      <div>
                        <div className="font-medium">Cuota {s.cuota}</div>
                        <div className="text-sm text-gray-400">S/ {s.amount.toFixed(2)}</div>
                      </div>
                      {s.status === 'Pendiente' ? (
                        <button onClick={() => payCuota(s.cuota)} disabled={loading} className="btn-primary text-sm px-3 py-1">Pagar vía Flow</button>
                      ) : (
                        <span className="text-green-400 text-sm font-medium flex items-center gap-1">
                          ✓ Pagada
                        </span>
                      )}
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    );
  }

  if (currentView === 'operator') {
    return (
      <div className="min-h-screen p-6 max-w-4xl mx-auto animate-fade-in">
        <div className="flex justify-between items-center mb-8 border-b border-gray-800 pb-4">
          <h1 className="text-3xl font-bold text-brand-500">Panel de Operador (Simulado)</h1>
          <button onClick={() => setCurrentView('dashboard')} className="text-sm text-gray-400 hover:text-white">Volver al Usuario</button>
        </div>
        
        <div className="card">
          <p className="text-sm text-gray-400 mb-4">Usa este botón para simular que un operador aprueba el desembolso a Yape de tu crédito (si está en estado "Pendiente Desembolso").</p>
          <button 
            onClick={async () => {
              try {
                await apiFetch('/operator/disburse', { method: 'POST', body: JSON.stringify({ creditId: credit?.id || 1 }) });
                alert('Desembolso exitoso. Vuelve a la vista de usuario.');
              } catch (e) {
                alert('Asegúrate de haber firmado el contrato primero.');
              }
            }} 
            disabled={loading || !credit} 
            className="btn-primary w-full"
          >
            Aprobar Desembolso a Billetera Digital (ID Crédito: {credit?.id || 'Ninguno'})
          </button>
        </div>
      </div>
    );
  }

  return null;
}
