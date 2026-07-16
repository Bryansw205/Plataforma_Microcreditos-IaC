const logger = require('./logger');

module.exports = (err, req, res, next) => {
  logger.error('Error global:', err);
  res.status(500).json({ error: 'Ocurrió un error inesperado en el servidor.' });
};
