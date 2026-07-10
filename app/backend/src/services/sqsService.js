const { SQSClient, SendMessageCommand, ReceiveMessageCommand, DeleteMessageCommand } = require('@aws-sdk/client-sqs');

const sqsClient = new SQSClient({
  region: process.env.AWS_REGION || 'us-east-1',
  endpoint: process.env.SQS_QUEUE_URL.includes('localhost') ? 'http://local-aws:4566' : undefined,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID || 'test',
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || 'test'
  }
});

const QUEUE_URL = process.env.SQS_QUEUE_URL;

const enqueueContractGeneration = async (creditId, userId) => {
  const params = {
    QueueUrl: QUEUE_URL,
    MessageBody: JSON.stringify({ type: 'GENERATE_CONTRACT', payload: { creditId, userId } })
  };
  
  try {
    await sqsClient.send(new SendMessageCommand(params));
    console.log(`[SQS] Mensaje enviado para generar contrato: Crédito ${creditId}`);
  } catch (err) {
    console.error('[SQS] Error al encolar mensaje:', err);
  }
};

module.exports = {
  sqsClient,
  enqueueContractGeneration,
  QUEUE_URL
};
