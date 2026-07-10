export default function Simulador({ evaluateCredit, loading }) {
  return (
    <div className="animate-fade-in">
      {/* Hero Section */}
      <div className="card text-center" style={{ padding: '3rem 2rem' }}>
        <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>🏦</div>
        <h2 className="text-2xl font-bold text-white mb-2">Simulador de Crédito</h2>
        <p className="text-gray-400 mb-8" style={{ maxWidth: '400px', margin: '0 auto 2rem' }}>
          Solicita una evaluación al instante. Analizaremos tu perfil de forma segura 
          basándonos en tus ingresos y gastos registrados.
        </p>

        {/* Conditions Grid */}
        <div className="grid grid-cols-3 gap-4 mb-8" style={{ maxWidth: '500px', margin: '0 auto 2rem' }}>
          <div className="stat-card text-center">
            <div className="stat-icon">💰</div>
            <div className="stat-label">Monto Máx.</div>
            <div className="stat-value" style={{ fontSize: '1.125rem' }}>S/ 5,000</div>
          </div>
          <div className="stat-card text-center">
            <div className="stat-icon">📅</div>
            <div className="stat-label">Plazo Máx.</div>
            <div className="stat-value" style={{ fontSize: '1.125rem' }}>12 meses</div>
          </div>
          <div className="stat-card text-center">
            <div className="stat-icon">📊</div>
            <div className="stat-label">TEA</div>
            <div className="stat-value" style={{ fontSize: '1.125rem' }}>15%</div>
          </div>
        </div>

        <button 
          onClick={evaluateCredit} 
          disabled={loading} 
          className="btn-primary" 
          style={{ padding: '0.875rem 2.5rem', fontSize: '1rem' }}
        >
          {loading ? <><span className="spinner"></span> Evaluando perfil...</> : '🔍 Evaluar mi Perfil'}
        </button>
      </div>
    </div>
  );
}
