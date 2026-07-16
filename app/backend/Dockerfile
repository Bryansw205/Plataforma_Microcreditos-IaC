# checkov:skip=CKV_DOCKER_3: No es necesario crear usuario en este entorno de desarrollo.
# checkov:skip=CKV_DOCKER_2: No se requiere healthcheck para este contenedor.
FROM node:18-alpine

WORKDIR /app

# Copiamos primero los archivos de dependencias para aprovechar el caché de Docker
COPY package*.json ./
RUN npm install --no-audit

# Copiamos el resto del código
COPY . .

# Generamos el cliente de Prisma
RUN npx prisma generate
# Exponemos el puerto de la API
EXPOSE 3000

# Por defecto, la imagen arranca la API. 
# Si el contenedor se usa para el Worker, ECS debe sobreescribir el comando.
CMD ["npm", "run", "start:api"]
