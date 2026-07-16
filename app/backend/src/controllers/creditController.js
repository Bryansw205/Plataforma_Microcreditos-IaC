const { prisma, evaluateCredit, calculateSchedule, getTasasYLimites } = require('../services/creditService');
const { enqueueContractGeneration } = require('../services/sqsService');
const logger = require('../logger');

exports.evaluate = async (req, res) => {
  try {
    const user = await prisma.user.findUnique({ where: { id: req.user.id } });
    if (!user) return res.status(404).json({ error: 'Usuario no encontrado' });

    const evaluation = await evaluateCredit(user.ingresos, user.gastos);
    
    // Calcular plazo y tasa predeterminados
    const { tasaInteres, plazoMaximo } = await getTasasYLimites();
    
    const credit = await prisma.credit.create({
      data: {
        userId: user.id,
        montoSolicitado: evaluation.amount,
        plazoMeses: plazoMaximo,
        tasaInteres: tasaInteres,
        montoAprobado: evaluation.amount,
        status: evaluation.approved ? 'Pre-aprobado' : 'Rechazado'
      }
    });

    logger.info(`Evaluación para ${user.dni}: ${credit.status}`);
    res.json({ credit });
  } catch (error) {
    logger.error('Error evaluando crédito:', error);
    res.status(500).json({ error: 'Error interno' });
  }
};

exports.signContract = async (req, res) => {
  const { creditId, accepted } = req.body;
  if (!accepted) return res.status(400).json({ error: 'Debe aceptar los términos.' });

  try {
    const credit = await prisma.credit.findFirst({
      where: { id: creditId, userId: req.user.id, status: 'Pre-aprobado' }
    });

    if (!credit) return res.status(404).json({ error: 'Crédito no encontrado o no está en estado Pre-aprobado' });

    // Actualizar estado
    const updatedCredit = await prisma.credit.update({
      where: { id: credit.id },
      data: { status: 'Aprobado - Pendiente Desembolso' }
    });

    // Enviar a SQS para generar PDF asíncronamente
    await enqueueContractGeneration(credit.id, req.user.id);

    logger.info(`Contrato firmado para crédito ${credit.id}`);
    res.json({ message: 'Contrato firmado digitalmente. Documento en generación.', credit: updatedCredit });
  } catch (error) {
    logger.error('Error firmando contrato:', error);
    res.status(500).json({ error: 'Error interno' });
  }
};

exports.getSchedule = async (req, res) => {
  const creditId = parseInt(req.query.creditId);
  try {
    const credit = await prisma.credit.findFirst({
      where: { id: creditId, userId: req.user.id },
      include: { schedules: true }
    });

    if (!credit) return res.status(404).json({ error: 'Crédito no encontrado' });

    res.json({ schedule: credit.schedules });
  } catch (error) {
    logger.error('Error obteniendo cronograma:', error);
    res.status(500).json({ error: 'Error interno' });
  }
};
