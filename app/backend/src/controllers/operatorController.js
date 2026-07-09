const { prisma, calculateSchedule } = require('../services/creditService');
const logger = require('../logger');

exports.getPending = async (req, res) => {
  try {
    const credits = await prisma.credit.findMany({
      where: { status: 'Aprobado - Pendiente Desembolso' },
      include: { user: { select: { dni: true } } },
      orderBy: { createdAt: 'desc' }
    });

    res.json({ credits });
  } catch (error) {
    logger.error('Error obteniendo créditos pendientes:', error);
    res.status(500).json({ error: 'Error interno' });
  }
};

exports.disburse = async (req, res) => {
  const { creditId } = req.body;
  
  try {
    const credit = await prisma.credit.findUnique({ where: { id: creditId } });
    if (!credit) return res.status(404).json({ error: 'Crédito no encontrado' });
    
    if (credit.status !== 'Aprobado - Pendiente Desembolso') {
      return res.status(400).json({ error: 'El crédito no está listo para desembolso.' });
    }

    // Generar cronograma
    const scheduleData = calculateSchedule(credit.montoAprobado, credit.plazoMeses, credit.tasaInteres);
    
    const updatedCredit = await prisma.credit.update({
      where: { id: credit.id },
      data: { 
        status: 'Desembolsado',
        schedules: {
          create: scheduleData
        }
      }
    });

    logger.info(`Desembolso realizado a Yape para crédito ${credit.id}`);
    res.json({ message: 'Desembolso exitoso a billetera digital.', credit: updatedCredit });
  } catch (error) {
    logger.error('Error desembolsando crédito:', error);
    res.status(500).json({ error: 'Error interno' });
  }
};
