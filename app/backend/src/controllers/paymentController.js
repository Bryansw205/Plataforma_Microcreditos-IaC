const { prisma } = require('../services/creditService');
const logger = require('../logger');

exports.payCuota = async (req, res) => {
  const { creditId, cuota, tokenTarjeta } = req.body; // simulamos tokenTarjeta de Flow
  
  if (!tokenTarjeta) {
    return res.status(400).json({ error: 'Tarjeta inválida o no provista' });
  }

  try {
    const credit = await prisma.credit.findFirst({
      where: { id: creditId, userId: req.user.id }
    });
    
    if (!credit) return res.status(404).json({ error: 'Crédito no encontrado' });

    const schedule = await prisma.schedule.findFirst({
      where: { creditId, cuota, status: 'Pendiente' }
    });

    if (!schedule) return res.status(404).json({ error: 'Cuota no encontrada o ya pagada' });

    // Simulación de delay de pasarela
    setTimeout(async () => {
      const updatedSchedule = await prisma.schedule.update({
        where: { id: schedule.id },
        data: { status: 'Pagada' }
      });

      logger.info(`Pago recibido para crédito ${credit.id}, cuota ${cuota} vía Flow simulado`);
      res.json({ message: 'Pago simulado correctamente vía Flow.', cuota: updatedSchedule });
    }, 500);

  } catch (error) {
    logger.error('Error en pago de cuota:', error);
    res.status(500).json({ error: 'Error interno procesando el pago' });
  }
};
