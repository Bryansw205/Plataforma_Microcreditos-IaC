const logger = require('./logger');

const errorMiddleware = (err, req, res, next) => {
  logger.error(err.message, { stack: err.stack });

  // Siempre devolver un mensaje genérico JSON con status 500 para errores no controlados
  res.status(500).json({
    status: 'error',
    message: 'Error interno del servidor',
  });
};

module.exports = errorMiddleware;
