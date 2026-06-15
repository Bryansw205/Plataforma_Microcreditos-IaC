# Módulo de Autenticación - AWS Cognito

Módulo para gestionar autenticación y autorización usando AWS Cognito.

##  Descripción

Crea y configura:
- **Pool de Usuarios Cognito:** Almacenamiento de usuarios con MFA obligatorio
- **Dominio Alojado:** URL pública para inicio de sesión (interfaz alojada)
- **Clientes del Pool de Usuarios:** 
  - Cliente SPA (sin secreto, para frontend)
  - Cliente Backend (con secreto, para API)
- **Grupos de Usuarios:** RBAC para autorización (administrador, usuario)

##  Archivos

| Archivo | Propósito |
|---------|-----------|
| `versions.tf` | Versiones requeridas de Terraform y proveedores |
| `locals.tf` | Variables locales (etiquetas comunes) |
| `user_pool.tf` | Pool de usuarios y dominio alojado |
| `user_pool_clients.tf` | Clientes SPA y Backend con OAuth2 |
| `user_groups.tf` | Grupos para RBAC |
| `variables.tf` | Variables de entrada |
| `outputs.tf` | Valores exportados |
| `README.md` | Este archivo |


##  Configuración de Seguridad

### MFA Obligatorio
```hcl
mfa_configuration = "ON"
software_token_mfa_configuration {
  enabled = true
}
```
- Todos los usuarios deben configurar autenticación de 2 factores (TOTP)

### Política de Contraseña
- Mínimo 12 caracteres
- Requiere mayúsculas, minúsculas, números, símbolos
- Cumple con regulaciones RNF_17

### Seguridad Avanzada
```hcl
user_pool_add_ons {
  advanced_security_mode = "ENFORCED"
}
```
- Detección de fraude
- Análisis de riesgo
- Bloqueo de direcciones IP sospechosas


##  Usuarios y Grupos

### Crear Usuario

```bash
aws cognito-idp admin-create-user \
  --user-pool-id us-east-1_xxxxxxxxxxxxx \
  --username usuario@ejemplo.com \
  --temporary-password ContraseñaTemporal123! \
  --message-action SUPPRESS
```

### Asignar a Grupo

```bash
aws cognito-idp admin-add-user-to-group \
  --user-pool-id us-east-1_xxxxxxxxxxxxx \
  --username usuario@ejemplo.com \
  --group-name admin
```

### Verificar Grupos

```bash
# Listar todos los grupos
aws cognito-idp list-groups --user-pool-id us-east-1_xxxxxxxxxxxxx

# Listar usuarios en grupo
aws cognito-idp get-group \
  --group-name admin \
  --user-pool-id us-east-1_xxxxxxxxxxxxx
```

##  Uso en Aplicación

### Frontend (React)

```javascript
import { CognitoAuth } from 'aws-amplify/auth';

const auth = new CognitoAuth({
  userPoolId: 'us-east-1_xxxxxxxxxxxxx',
  clientId: 'xxxxxxxxxxxxxxxxxxxxxxxx',
  redirectUrl: 'https://microcreditos.com/callback'
});
Iniciar sesión
const result = await auth.signIn(correo, contraseña);


const token = result.signInUserSession.idToken.jwtToken;


const grupos = result.signInUserSession.idToken.payload['cognito:groups'];
```

### Backend (Node.js)

```javascript
const jwt = require('jsonwebtoken');
const axios = require('axios');


async function validarToken(token) {
  const userPoolId = 'us-east-1_xxxxxxxxxxxxx';
  const region = 'us-east-1';
  
  const jwksUrl = `https://cognito-idp.${region}.amazonaws.com/${userPoolId}/.well-known/jwks.json`;
  const response = await axios.get(jwksUrl);
  
  return jwt.verify(token, response.data.keys[0].n, {
    algorithms: ['RS256']
  });
}

app.get('/admin', async (req, res) => {
  const token = req.headers.authorization.split(' ')[1];
  const decoded = await validarToken(token);
  
  if (!decoded['cognito:groups']?.includes('admin')) {
    return res.status(403).json({ error: 'Se requiere acceso de administrador' });
  }
  
  res.json({ message: '¡Bienvenido administrador
  res.json({ message: 'Welcome admin!' });
});
```