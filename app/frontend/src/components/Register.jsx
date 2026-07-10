import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import apiFetch from '../services/apiClient';

export default function Register() {
  const [dni, setDni] = useState('');
  const [ingresos, setIngresos] = useState('');
  const [gastos, setGastos] = useState('');
  const [role, setRole] = useState('cliente');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    try {
      await apiFetch('/auth/register', {
        method: 'POST',
        body: JSON.stringify({ dni, ingresos: Number(ingresos), gastos: Number(gastos), role })
      });
      setSuccess(true);
      setTimeout(() => navigate('/login'), 2000);
    } catch (err) {
      setError(err.message);
      setLoading(false);
    }
  };

  if (success) {
    return (
      <div className="min-h-screen flex items-center justify-center p-4">
        <div className="card w-full max-w-md animate-fade-in text-center" style={{ padding: '3rem' }}>
          <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>✅</div>
          <h2 className="text-xl font-bold text-white mb-2">¡Registro exitoso!</h2>
          <p className="text-gray-400">Redirigiendo al login...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center p-4">
      <div className="card w-full max-w-md animate-fade-in" style={{ padding: '2.5rem' }}>
        
        <div className="text-center mb-6">
          <div style={{ fontSize: '2rem', marginBottom: '0.5rem' }}>📝</div>
          <h2 className="text-2xl font-bold text-white">Crear Cuenta</h2>
          <p className="text-sm text-gray-500 mt-2">Registra tus datos para acceder a la plataforma</p>
        </div>

        {error && <div className="alert-error mb-4">{error}</div>}

        {/* Role Selector */}
        <div className="role-selector">
          <button type="button" className={`role-option ${role === 'cliente' ? 'selected' : ''}`} onClick={() => setRole('cliente')}>
            👤 Cliente
          </button>
          <button type="button" className={`role-option ${role === 'operador' ? 'selected' : ''}`} onClick={() => setRole('operador')}>
            🔧 Operador
          </button>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm text-gray-400 mb-1">DNI</label>
            <input required type="text" className="input-field" placeholder="12345678" value={dni} onChange={e => setDni(e.target.value)} />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm text-gray-400 mb-1">Ingresos (S/)</label>
              <input required type="number" className="input-field" placeholder="5000" value={ingresos} onChange={e => setIngresos(e.target.value)} />
            </div>
            <div>
              <label className="block text-sm text-gray-400 mb-1">Gastos (S/)</label>
              <input required type="number" className="input-field" placeholder="2000" value={gastos} onChange={e => setGastos(e.target.value)} />
            </div>
          </div>
          <button disabled={loading} type="submit" className="btn-primary w-full" style={{ padding: '0.75rem' }}>
            {loading ? <><span className="spinner"></span> Registrando...</> : 'Registrar'}
          </button>
          <div className="text-center mt-4">
            <button type="button" onClick={() => navigate('/login')} className="nav-link" style={{ color: 'var(--brand-400)' }}>
              ¿Ya tienes cuenta? Inicia sesión
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
