require('dotenv').config();
const express = require('express');
const cors = require('cors');
const logger = require('./logger');
const errorMiddleware = require('./errorMiddleware');
const authController = require('./controllers/authController');
const creditController = require('./controllers/creditController');
const paymentController = require('./controllers/paymentController');
const operatorController = require('./controllers/operatorController');
const authMiddleware = require('./authMiddleware');
const { connectRedis } = require('./services/redisService');

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use((req, res, next) => {
  logger.info(`Incoming request: ${req.method} ${req.url}`);
  next();
});

// Health check
app.get('/health', (req, res) => res.json({ status: 'ok' }));

// Auth routes
app.post('/auth/register', authController.register);
app.post('/auth/login', authController.login);

// Protected routes
app.use('/credit', authMiddleware);
app.post('/credit/evaluate', creditController.evaluate);
app.post('/credit/contract', creditController.signContract);
app.get('/credit/schedule', creditController.getSchedule);
app.post('/credit/pay', paymentController.payCuota);

// Operator routes
app.use('/operator', authMiddleware);
app.get('/operator/pending', operatorController.getPending);
app.post('/operator/disburse', operatorController.disburse);

// Error middleware
app.use(errorMiddleware);

const startServer = async () => {
  try {
    await connectRedis();
    app.listen(port, () => {
      logger.info(`API Server is running on port ${port}`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
};

startServer();
