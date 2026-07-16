const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000';

const apiFetch = async (endpoint, options = {}) => {
  const token = localStorage.getItem('token');
  const headers = { 'Content-Type': 'application/json', ...options.headers };
  
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  // Validamos que el endpoint sea una ruta relativa para evitar inyección de URLs externas
  if (typeof endpoint !== 'string' || endpoint.includes('://') || endpoint.startsWith('//')) {
    throw new Error('URL de endpoint no permitida por seguridad');
  }

  const safeEndpoint = endpoint.startsWith('/') ? endpoint : `/${endpoint}`;

  const response = await fetch(`${API_URL}${safeEndpoint}`, { ...options, headers });
  const data = await response.json();

  if (!response.ok) {
    if (response.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    throw new Error(data.error || 'Error en la petición al servidor');
  }

  return data;
};

export default apiFetch;
