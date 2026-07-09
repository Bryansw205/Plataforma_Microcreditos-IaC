/**
 * Integration tests for the Microcréditos API.
 * These tests verify the full request/response cycle including middleware.
 * NOTE: These are designed to run against the actual running API on port 3000.
 *       Run them with the backend container active.
 */

const API_BASE = process.env.API_URL || 'http://127.0.0.1:3000';

// Helper to make API calls
async function apiFetch(path, options = {}) {
  const url = `${API_BASE}${path}`;
  const res = await fetch(url, {
    headers: { 'Content-Type': 'application/json', ...options.headers },
    ...options,
  });
  const data = await res.json();
  return { status: res.status, data };
}

describe('API Integration Tests', () => {
  const testDni = `INT_${Date.now()}`;
  let token;
  let creditId;

  // ── Health Check ──
  it('GET /health should return ok', async () => {
    const { status, data } = await apiFetch('/health');
    expect(status).toBe(200);
    expect(data.status).toBe('ok');
  });

  // ── Auth: Register ──
  it('POST /auth/register should create a user with role', async () => {
    const { status, data } = await apiFetch('/auth/register', {
      method: 'POST',
      body: JSON.stringify({ dni: testDni, ingresos: 5000, gastos: 1500, role: 'cliente' }),
    });
    expect(status).toBe(201);
    expect(data.user.dni).toBe(testDni);
    expect(data.user.role).toBe('cliente');
  });

  it('POST /auth/register should reject duplicate DNI', async () => {
    const { status } = await apiFetch('/auth/register', {
      method: 'POST',
      body: JSON.stringify({ dni: testDni, ingresos: 5000, gastos: 1500 }),
    });
    expect(status).toBe(400);
  });

  // ── Auth: Login ──
  it('POST /auth/login should return token and role', async () => {
    const { status, data } = await apiFetch('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ dni: testDni }),
    });
    expect(status).toBe(200);
    expect(data.token).toBeDefined();
    expect(data.role).toBe('cliente');
    token = data.token;
  });

  it('POST /auth/login should fail for non-existent user', async () => {
    const { status } = await apiFetch('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ dni: 'NONEXISTENT999' }),
    });
    expect(status).toBe(401);
  });

  // ── Credit: Evaluate ──
  it('POST /credit/evaluate should pre-approve credit', async () => {
    const { status, data } = await apiFetch('/credit/evaluate', {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}` },
    });
    expect(status).toBe(200);
    expect(data.credit.status).toBe('Pre-aprobado');
    expect(data.credit.montoAprobado).toBeGreaterThan(0);
    creditId = data.credit.id;
  });

  it('POST /credit/evaluate should fail without auth', async () => {
    const { status } = await apiFetch('/credit/evaluate', { method: 'POST' });
    expect(status).toBe(401);
  });

  // ── Credit: Sign Contract ──
  it('POST /credit/contract should sign contract', async () => {
    const { status, data } = await apiFetch('/credit/contract', {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}` },
      body: JSON.stringify({ creditId, accepted: true }),
    });
    expect(status).toBe(200);
    expect(data.credit.status).toBe('Aprobado - Pendiente Desembolso');
  });

  // ── Operator: List Pending ──
  it('GET /operator/pending should list pending credits', async () => {
    const { status, data } = await apiFetch('/operator/pending', {
      headers: { Authorization: `Bearer ${token}` },
    });
    expect(status).toBe(200);
    expect(Array.isArray(data.credits)).toBe(true);
    const found = data.credits.find(c => c.id === creditId);
    expect(found).toBeDefined();
  });

  // ── Operator: Disburse ──
  it('POST /operator/disburse should disburse credit', async () => {
    const { status, data } = await apiFetch('/operator/disburse', {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}` },
      body: JSON.stringify({ creditId }),
    });
    expect(status).toBe(200);
    expect(data.credit.status).toBe('Desembolsado');
  });

  // ── Credit: Get Schedule ──
  it('GET /credit/schedule should return payment schedule', async () => {
    const { status, data } = await apiFetch(`/credit/schedule?creditId=${creditId}`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    expect(status).toBe(200);
    expect(Array.isArray(data.schedule)).toBe(true);
    expect(data.schedule.length).toBeGreaterThan(0);
    expect(data.schedule[0].cuota).toBe(1);
    expect(data.schedule[0].status).toBe('Pendiente');
  });

  // ── Payment ──
  it('POST /credit/pay should pay a cuota', async () => {
    const { status, data } = await apiFetch('/credit/pay', {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}` },
      body: JSON.stringify({ creditId, cuota: 1, tokenTarjeta: '4111111111111111' }),
    });
    expect(status).toBe(200);
    expect(data.cuota.status).toBe('Pagada');
  });

  it('POST /credit/pay should fail without tokenTarjeta', async () => {
    const { status } = await apiFetch('/credit/pay', {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}` },
      body: JSON.stringify({ creditId, cuota: 2 }),
    });
    expect(status).toBe(400);
  });
});
