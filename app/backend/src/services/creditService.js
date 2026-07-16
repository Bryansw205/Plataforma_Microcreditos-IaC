const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Simulamos que estos valores vienen de Parameter Store o Redis
const getTasasYLimites = async () => {
  return {
    tasaInteres: 0.15, // 15% efectivo anual simulado
    plazoMaximo: 12,
    montoMinimo: 500,
    montoMaximo: 5000,
  };
};

const evaluateCredit = async (ingresos, gastos) => {
  const { montoMaximo } = await getTasasYLimites();
  
  // Lógica de negocio básica
  const capacidadPago = ingresos - gastos;
  if (capacidadPago < 200) {
    return { approved: false, amount: 0, reason: 'Capacidad de pago insuficiente' };
  }
  
  let amount = capacidadPago * 3;
  if (amount > montoMaximo) amount = montoMaximo;
  
  return { approved: true, amount, reason: 'Pre-aprobado por flujo de caja' };
};

const calculateSchedule = (monto, plazo, tasa) => {
  // Cálculo simplificado de cuota fija (método francés simulado)
  const tasaMensual = tasa / 12;
  const cuota = monto * (tasaMensual * Math.pow(1 + tasaMensual, plazo)) / (Math.pow(1 + tasaMensual, plazo) - 1);
  
  const schedule = [];
  let currentDate = new Date();
  
  for (let i = 1; i <= plazo; i++) {
    currentDate.setMonth(currentDate.getMonth() + 1);
    schedule.push({
      cuota: i,
      amount: parseFloat(cuota.toFixed(2)),
      dueDate: new Date(currentDate),
      status: 'Pendiente'
    });
  }
  
  return schedule;
};

module.exports = {
  getTasasYLimites,
  evaluateCredit,
  calculateSchedule,
  prisma
};
