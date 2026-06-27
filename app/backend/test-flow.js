// Mock de lógica de negocio pura para probar el flujo sin depender de Express/npm
const logger = { info: console.log, error: console.error };

const users = [];
const credits = [];

function simulateFlow() {
  logger.info("=== INICIANDO PRUEBA DE FLUJO NORMAL DE USUARIO ===");

  // 1. Registro
  const dni = '12345678';
  const user = { id: 1, dni, ingresos: 1500, gastos: 500 };
  users.push(user);
  logger.info(`[Paso 1] Usuario registrado exitosamente. DNI: ${user.dni}, Ingresos: S/${user.ingresos}`);

  // 2. Evaluación Crediticia
  logger.info(`[Paso 2] Evaluando crédito para usuario ID: ${user.id}... (Simulando retraso)`);
  let approved = user.ingresos > 1000;
  const credit = {
    id: credits.length + 1,
    userId: user.id,
    status: approved ? 'Pre-aprobado' : 'Rechazado',
    montoAprobado: approved ? (user.ingresos * 2) : 0
  };
  credits.push(credit);
  logger.info(`Resultado Evaluación: Estado -> ${credit.status}, Monto -> S/${credit.montoAprobado}`);

  // 3. Contrato Digital
  if (credit.status === 'Pre-aprobado') {
    logger.info(`[Paso 3] Firmando contrato digital...`);
    credit.status = 'Aprobado - Pendiente Desembolso';
    logger.info(`Contrato firmado. Nuevo estado del crédito: ${credit.status}`);
  }

  // 4. Desembolso por Operador
  logger.info(`[Paso 4] Operador aprueba desembolso...`);
  credit.status = 'Desembolsado';
  logger.info(`Desembolso a Yape completado. Estado: ${credit.status}`);

  // 5. Generación de Cronograma
  logger.info(`[Paso 5] Generando cronograma de pagos...`);
  const cuotaAmount = (credit.montoAprobado * 1.1) / 3;
  const schedule = [
    { cuota: 1, amount: cuotaAmount, status: 'Pendiente' },
    { cuota: 2, amount: cuotaAmount, status: 'Pendiente' },
    { cuota: 3, amount: cuotaAmount, status: 'Pendiente' },
  ];
  credit.schedule = schedule;
  logger.info(`Cronograma generado: 3 cuotas de S/${cuotaAmount.toFixed(2)} cada una.`);

  // 6. Pago de Cuota
  logger.info(`[Paso 6] Simulación de pago de la Cuota 1 vía pasarela Flow...`);
  const targetCuota = credit.schedule.find(s => s.cuota === 1);
  targetCuota.status = 'Pagada';
  logger.info(`Pago recibido correctamente. Estado de Cuota 1: ${targetCuota.status}`);
  logger.info(`Estado de Cuota 2: ${credit.schedule[1].status}`);

  logger.info("=== PRUEBA DE FLUJO FINALIZADA CON ÉXITO ===");
}

simulateFlow();
