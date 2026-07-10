const PDFDocument = require('pdfkit');
const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const { PassThrough } = require('stream');
const logger = require('../logger');

const s3Client = new S3Client({
  region: process.env.AWS_REGION || 'us-east-1',
  endpoint: process.env.SQS_QUEUE_URL.includes('localhost') ? 'http://local-aws:4566' : undefined,
  forcePathStyle: true,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID || 'test',
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || 'test'
  }
});

const BUCKET_NAME = process.env.DOCUMENTS_BUCKET || 'microcreditos-documents';

const generateAndUploadContract = async (creditData, userData) => {
  return new Promise((resolve, reject) => {
    try {
      const doc = new PDFDocument();
      const pass = new PassThrough();
      
      const fileName = `contrato-${creditData.id}-${userData.dni}.pdf`;
      
      // Upload to S3
      const uploadParams = {
        Bucket: BUCKET_NAME,
        Key: fileName,
        Body: pass,
        ContentType: 'application/pdf'
      };
      
      s3Client.send(new PutObjectCommand(uploadParams))
        .then(() => {
          logger.info(`[S3] Contrato subido exitosamente: ${fileName}`);
          resolve(fileName);
        })
        .catch(err => {
          logger.error(`[S3] Error subiendo contrato: ${err.message}`);
          reject(err);
        });
      
      // Build PDF
      doc.pipe(pass);
      
      doc.fontSize(20).text('CONTRATO DE MICROCRÉDITO', { align: 'center' });
      doc.moveDown();
      doc.fontSize(12).text(`Identificador del Crédito: ${creditData.id}`);
      doc.text(`Prestatario DNI: ${userData.dni}`);
      doc.text(`Monto Aprobado: S/ ${creditData.montoAprobado}`);
      doc.moveDown();
      doc.text('Este documento certifica la aceptación de las condiciones del crédito y el cronograma de pagos acordado.');
      doc.moveDown();
      doc.text(`Generado en: ${new Date().toISOString()}`);
      
      doc.end();
    } catch (error) {
      reject(error);
    }
  });
};

module.exports = {
  generateAndUploadContract
};
