const { prisma } = require('../services/creditService');
const jwt = require('jsonwebtoken');
const logger = require('../logger');

const JWT_SECRET = process.env.JWT_SECRET || 'secret_mock_key';

exports.register = async (req, res) => {
  const { dni, ingresos, gastos, role } = req.body;
  if (!dni || ingresos == null || gastos == null) {
    return res.status(400).json({ error: 'Faltan datos requeridos (dni, ingresos, gastos).' });
  }

  const validRoles = ['cliente', 'operador'];
  const userRole = validRoles.includes(role) ? role : 'cliente';

  try {
    let user = await prisma.user.findUnique({ where: { dni } });
    if (user) {
      return res.status(400).json({ error: 'El DNI ya está registrado.' });
    }

    user = await prisma.user.create({
      data: { dni, role: userRole, ingresos: parseFloat(ingresos), gastos: parseFloat(gastos) }
    });

    logger.info(`Usuario registrado: ${dni} (role: ${userRole})`);
    res.status(201).json({ message: 'Usuario registrado con éxito', user });
  } catch (error) {
    logger.error('Error registrando usuario:', error);
    res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

exports.login = async (req, res) => {
  const { dni } = req.body;
  
  try {
    const user = await prisma.user.findUnique({ where: { dni } });
    if (!user) {
      return res.status(401).json({ error: 'Credenciales inválidas.' });
    }

    const token = jwt.sign(
      { id: user.id, dni: user.dni, role: user.role },
      JWT_SECRET,
      { expiresIn: '15m' }
    );
    logger.info(`Login exitoso para: ${dni} (role: ${user.role})`);
    res.json({ token, role: user.role, message: 'Login exitoso' });
  } catch (error) {
    logger.error('Error login usuario:', error);
    res.status(500).json({ error: 'Error interno del servidor.' });
  }
};
