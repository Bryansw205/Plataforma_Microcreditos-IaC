import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Dashboard from './components/Dashboard';
import Login from './components/Login';
import Register from './components/Register';
import Operator from './components/Operator';

export default function App() {
  const [token, setToken] = useState(localStorage.getItem('token'));
  const [role, setRole] = useState(localStorage.getItem('role') || 'cliente');
  
  useEffect(() => {
    if (token) localStorage.setItem('token', token);
    else { 
      localStorage.removeItem('token');
      localStorage.removeItem('role');
      localStorage.removeItem('activeCredit');
    }
  }, [token]);

  useEffect(() => {
    if (role) localStorage.setItem('role', role);
  }, [role]);

  const handleLogin = (newToken, newRole) => {
    setToken(newToken);
    setRole(newRole || 'cliente');
  };

  const handleLogout = () => {
    setToken(null);
    setRole('cliente');
  };

  return (
    <Router>
      <Routes>
        <Route path="/login" element={token ? <Navigate to={role === 'operador' ? '/operator' : '/dashboard'} /> : <Login onLogin={handleLogin} />} />
        <Route path="/register" element={token ? <Navigate to="/dashboard" /> : <Register />} />
        <Route path="/dashboard/*" element={token ? <Dashboard token={token} role={role} onLogout={handleLogout} /> : <Navigate to="/login" />} />
        <Route path="/operator/*" element={token && role === 'operador' ? <Operator token={token} onLogout={handleLogout} /> : <Navigate to="/login" />} />
        <Route path="*" element={<Navigate to={token ? (role === 'operador' ? '/operator' : '/dashboard') : '/login'} />} />
      </Routes>
    </Router>
  );
}
