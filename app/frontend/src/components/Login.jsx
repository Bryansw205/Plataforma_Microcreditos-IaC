import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import apiFetch from '../services/apiClient';

export default function Login({ onLogin }) {
  const [dni, setDni] = useState('');
  const [role, setRole] = useState('cliente');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    try {
      const data = await apiFetch('/auth/login', {
        method: 'POST',
        body: JSON.stringify({ dni })
      });
      onLogin(data.token, data.role || role);
      navigate(data.role === 'operador' ? '/operator' : '/dashboard');
    } catch (err) {
      setError(err.message);
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-4">
      <div className="card w-full max-w-md animate-fade-in" style={{ padding: '2.5rem' }}>
        
        {/* Logo */}
        <div className="text-center mb-8">
          <div style={{ fontSize: '2.5rem', marginBottom: '0.5rem' }}>💳</div>
          <h1 className="text-2xl font-bold text-white" style={{ marginBottom: '0.25rem' }}>Microcréditos Flow</h1>
          <p className="text-sm text-gray-500">Plataforma de gestión de microcréditos</p>
        </div>

        {error && <div className="alert-error mb-4">{error}</div>}

        {/* Role Selector */}
        <div className="role-selector">
          <button 
            type="button"
            className={`role-option ${role === 'cliente' ? 'selected' : ''}`}
            onClick={() => setRole('cliente')}
          >
            👤 Cliente
          </button>
          <button 
            type="button"
            className={`role-option ${role === 'operador' ? 'selected' : ''}`}
            onClick={() => setRole('operador')}
          >
            🔧 Operador
          </button>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm text-gray-400 mb-1">DNI</label>
            <input 
              required 
              type="text" 
              className="input-field" 
              placeholder="Ingresa tu DNI"
              value={dni} 
              onChange={e => setDni(e.target.value)} 
            />
          </div>
          <button disabled={loading} type="submit" className="btn-primary w-full" style={{ padding: '0.75rem' }}>
            {loading ? <><span className="spinner"></span> Ingresando...</> : 'Ingresar'}
          </button>
          <div className="text-center mt-4">
            <button type="button" onClick={() => navigate('/register')} className="nav-link" style={{ color: 'var(--brand-400)' }}>
              ¿No tienes cuenta? Regístrate
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
