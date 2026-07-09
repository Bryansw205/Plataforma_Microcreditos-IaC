require('dotenv').config();
const { sqsClient, QUEUE_URL } = require('./services/sqsService');
const { ReceiveMessageCommand, DeleteMessageCommand } = require('@aws-sdk/client-sqs');
const { generateAndUploadContract } = require('./services/pdfService');
const { prisma } = require('./services/creditService');
const logger = require('./logger');

const processMessage = async (message) => {
  try {
    const body = JSON.parse(message.Body);
    
    if (body.type === 'GENERATE_CONTRACT') {
      const { creditId, userId } = body.payload;
      
      const user = await prisma.user.findUnique({ where: { id: userId } });
      const credit = await prisma.credit.findUnique({ where: { id: creditId } });
      
      if (user && credit) {
        logger.info(`[WORKER] Iniciando generación de PDF para crédito ${creditId}...`);
        const fileName = await generateAndUploadContract(credit, user);
        logger.info(`[WORKER] Contrato ${fileName} generado y subido a S3 con éxito.`);
      } else {
        logger.warn(`[WORKER] Crédito o usuario no encontrado para evento GENERATE_CONTRACT`);
      }
    }
    
    return true;
  } catch (error) {
    logger.error('[WORKER] Error procesando mensaje:', error);
    return false;
  }
};

const pollQueue = async () => {
  logger.info('[WORKER] Escuchando mensajes en SQS...');
  
  while (true) {
    try {
      const response = await sqsClient.send(new ReceiveMessageCommand({
        QueueUrl: QUEUE_URL,
        MaxNumberOfMessages: 1,
        WaitTimeSeconds: 20 // Long polling
      }));

      if (response.Messages && response.Messages.length > 0) {
        for (const message of response.Messages) {
          const success = await processMessage(message);
          
          if (success) {
            await sqsClient.send(new DeleteMessageCommand({
              QueueUrl: QUEUE_URL,
              ReceiptHandle: message.ReceiptHandle
            }));
            logger.info('[WORKER] Mensaje procesado y eliminado de SQS');
          }
        }
      }
    } catch (error) {
      logger.error('[WORKER] Error en polling:', error);
      await new Promise(res => setTimeout(res, 5000)); // wait before retry
    }
  }
};

pollQueue();
