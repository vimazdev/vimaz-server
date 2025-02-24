# Usa la imagen oficial de Node.js como base
FROM node:18

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /usr/src/app

# Copia el archivo package.json y package-lock.json
COPY package*.json ./

# Instala las dependencias del proyecto
RUN npm install

# Copia el resto del código del backend al contenedor
COPY . .

# Expone el puerto que usará la aplicación (ajusta según sea necesario)
EXPOSE 3000

# Comando para iniciar la aplicación
CMD ["npm", "start"]
