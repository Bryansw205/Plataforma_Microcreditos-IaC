const { evaluateCredit, calculateSchedule, getTasasYLimites } = require('../../src/services/creditService');

describe('Credit Service Unit Tests', () => {

  // ── evaluateCredit ──
  describe('evaluateCredit()', () => {
    it('should reject credit if payment capacity is below 200', async () => {
      const result = await evaluateCredit(1000, 900); // capacidad = 100
      expect(result.approved).toBe(false);
      expect(result.amount).toBe(0);
      expect(result.reason).toContain('insuficiente');
    });

    it('should reject credit if ingresos equal gastos', async () => {
      const result = await evaluateCredit(3000, 3000); // capacidad = 0
      expect(result.approved).toBe(false);
    });

    it('should reject credit if gastos exceed ingresos', async () => {
      const result = await evaluateCredit(1000, 2000); // capacidad = -1000
      expect(result.approved).toBe(false);
    });

    it('should approve credit when capacity is exactly 200', async () => {
      const result = await evaluateCredit(1200, 1000); // capacidad = 200
      expect(result.approved).toBe(true);
      expect(result.amount).toBe(600); // 200 * 3
    });

    it('should approve and cap amount at montoMaximo', async () => {
      const result = await evaluateCredit(5000, 1000); // capacidad = 4000, amount = 12000 > 5000
      expect(result.approved).toBe(true);
      expect(result.amount).toBe(5000);
    });

    it('should approve and calculate amount as capacidad * 3', async () => {
      const result = await evaluateCredit(2000, 1500); // capacidad = 500, amount = 1500
      expect(result.approved).toBe(true);
      expect(result.amount).toBe(1500);
    });
  });

  // ── calculateSchedule ──
  describe('calculateSchedule()', () => {
    it('should generate correct number of cuotas', () => {
      const schedule = calculateSchedule(1000, 6, 0.15);
      expect(schedule.length).toBe(6);
    });

    it('should set all cuotas as Pendiente', () => {
      const schedule = calculateSchedule(1000, 3, 0.15);
      schedule.forEach(s => expect(s.status).toBe('Pendiente'));
    });

    it('should number cuotas sequentially from 1', () => {
      const schedule = calculateSchedule(1000, 4, 0.15);
      expect(schedule.map(s => s.cuota)).toEqual([1, 2, 3, 4]);
    });

    it('should calculate consistent monthly amounts (French amortization)', () => {
      const schedule = calculateSchedule(5000, 12, 0.15);
      const firstAmount = schedule[0].amount;
      // All amounts should be the same in French method
      schedule.forEach(s => {
        expect(s.amount).toBe(firstAmount);
      });
    });

    it('should produce amounts that cover principal + interest', () => {
      const monto = 5000;
      const schedule = calculateSchedule(monto, 12, 0.15);
      const totalPaid = schedule.reduce((sum, s) => sum + s.amount, 0);
      // Total paid should be greater than principal (due to interest)
      expect(totalPaid).toBeGreaterThan(monto);
    });

    it('should set due dates one month apart', () => {
      const schedule = calculateSchedule(1000, 3, 0.15);
      expect(schedule[0].dueDate).toBeInstanceOf(Date);
      expect(schedule[1].dueDate).toBeInstanceOf(Date);
      // Second cuota should be ~30 days after first
      const diff = schedule[1].dueDate.getTime() - schedule[0].dueDate.getTime();
      const daysDiff = diff / (1000 * 60 * 60 * 24);
      expect(daysDiff).toBeGreaterThanOrEqual(27);
      expect(daysDiff).toBeLessThanOrEqual(32);
    });

    it('should handle 1-month plazo', () => {
      const schedule = calculateSchedule(1000, 1, 0.15);
      expect(schedule.length).toBe(1);
      expect(schedule[0].cuota).toBe(1);
      // Single payment should be slightly more than principal
      expect(schedule[0].amount).toBeGreaterThan(1000);
    });
  });

  // ── getTasasYLimites ──
  describe('getTasasYLimites()', () => {
    it('should return valid rate and limits', async () => {
      const config = await getTasasYLimites();
      expect(config.tasaInteres).toBeDefined();
      expect(config.plazoMaximo).toBeGreaterThan(0);
      expect(config.montoMinimo).toBeGreaterThan(0);
      expect(config.montoMaximo).toBeGreaterThan(config.montoMinimo);
    });
  });
});
