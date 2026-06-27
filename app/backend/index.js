require('dotenv').config();
const express = require('express');
const cors = require('cors');
const logger = require('./logger');
const errorMiddleware = require('./errorMiddleware');
const routes = require('./routes');

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Request logging middleware
app.use((req, res, next) => {
  logger.info(`Incoming request: ${req.method} ${req.url}`);
  next();
});

// Routes
app.use('/', routes);

// Error handling middleware
app.use(errorMiddleware);

app.listen(port, () => {
  logger.info(`Server is running on port ${port}`);
});
