const express = require('express');
const jwt = require('jsonwebtoken');
const authMiddleware = require('./authMiddleware');
const logger = require('./logger');

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET || 'secret_mock_key';

// Mock DB en memoria para esta prueba (para evitar bloqueos sin prisma init completo)
const users = [];
const credits = [];

// Health Check
router.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Registro
router.post('/auth/register', (req, res) => {
  const { dni, ingresos, gastos } = req.body;
  if (!dni || ingresos == null || gastos == null) {
    return res.status(400).json({ error: 'Faltan datos requeridos (dni, ingresos, gastos).' });
  }
  const user = { id: users.length + 1, dni, ingresos, gastos };
  users.push(user);
  logger.info(`Usuario registrado: ${dni}`);
  res.status(201).json({ message: 'Usuario registrado con éxito', user });
});

// Login
router.post('/auth/login', (req, res) => {
  const { dni } = req.body;
  const user = users.find(u => u.dni === dni);
  if (!user) {
    return res.status(401).json({ error: 'Credenciales inválidas.' });
  }
  // Token expira en 15 minutos
  const token = jwt.sign({ id: user.id, dni: user.dni }, JWT_SECRET, { expiresIn: '15m' });
  logger.info(`Login exitoso para: ${dni}`);
  res.json({ token, message: 'Login exitoso' });
});

// A partir de aquí protegemos con JWT
router.use('/credit', authMiddleware);
router.use('/operator', authMiddleware);

// Evaluación crediticia simulada
router.post('/credit/evaluate', (req, res) => {
  const user = users.find(u => u.id === req.user.id);
  if (!user) return res.status(404).json({ error: 'Usuario no encontrado' });

  // Simular retraso de 200ms
  setTimeout(() => {
    let approved = user.ingresos > 1000;
    const credit = {
      id: credits.length + 1,
      userId: user.id,
      status: approved ? 'Pre-aprobado' : 'Rechazado',
      montoAprobado: approved ? (user.ingresos * 2) : 0
    };
    credits.push(credit);
    
    logger.info(`Evaluación para ${user.dni}: ${credit.status}`);
    res.json({ credit });
  }, 200);
});

// Contrato Digital
router.post('/credit/contract', (req, res) => {
  const { creditId, accepted } = req.body;
  const credit = credits.find(c => c.id === creditId && c.userId === req.user.id);
  
  if (!credit) return res.status(404).json({ error: 'Crédito no encontrado' });
  if (!accepted) return res.status(400).json({ error: 'Debe aceptar los términos.' });
  
  credit.status = 'Aprobado - Pendiente Desembolso';
  logger.info(`Contrato firmado para crédito ${credit.id}`);
  res.json({ message: 'Contrato firmado digitalmente.', credit });
});

// Desembolso (Operador)
router.post('/operator/disburse', (req, res) => {
  const { creditId } = req.body;
  const credit = credits.find(c => c.id === creditId);
  
  if (!credit) return res.status(404).json({ error: 'Crédito no encontrado' });
  
  credit.status = 'Desembolsado';
  logger.info(`Desembolso realizado a Yape para crédito ${credit.id}`);
  res.json({ message: 'Desembolso exitoso a billetera digital.', credit });
});

// Cronograma de Pagos
router.get('/credit/schedule', (req, res) => {
  const creditId = parseInt(req.query.creditId);
  const credit = credits.find(c => c.id === creditId && c.userId === req.user.id);
  
  if (!credit) return res.status(404).json({ error: 'Crédito no encontrado' });
  
  const cuotaAmount = (credit.montoAprobado * 1.1) / 3; // Interés 10%
  const schedule = [
    { cuota: 1, amount: cuotaAmount, status: 'Pendiente' },
    { cuota: 2, amount: cuotaAmount, status: 'Pendiente' },
    { cuota: 3, amount: cuotaAmount, status: 'Pendiente' },
  ];
  credit.schedule = schedule;
  
  res.json({ schedule });
});

// Pagar Cuota
router.post('/credit/pay', (req, res) => {
  const { creditId, cuota } = req.body;
  const credit = credits.find(c => c.id === creditId && c.userId === req.user.id);
  
  if (!credit || !credit.schedule) return res.status(404).json({ error: 'Crédito/Cronograma no encontrado' });
  
  const targetCuota = credit.schedule.find(s => s.cuota === cuota);
  if (!targetCuota) return res.status(404).json({ error: 'Cuota no encontrada' });
  
  targetCuota.status = 'Pagada';
  logger.info(`Pago recibido para crédito ${credit.id}, cuota ${cuota} vía Flow`);
  res.json({ message: 'Pago simulado correctamente vía Flow.', cuota: targetCuota });
});

// Forzar un error 500 para probar el middleware
router.get('/force-error', (req, res) => {
  throw new Error('Este es un error simulado');
});

module.exports = router;
