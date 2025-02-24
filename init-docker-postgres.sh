#!/bin/bash

# Variables de configuración
PROJECT_DIR="/home/vimaz/v1"  # Ruta donde se almacenará el proyecto
REPO_URL="https://github.com/vimazdev/vimaz-server.git"  # URL del repositorio del backend
BACKEND_DIR="$PROJECT_DIR/backend"  # Carpeta donde se clonará el backend
POSTGRES_USER="vimaz"
POSTGRES_PASSWORD="8825"
POSTGRES_DB="vimazdb"
POSTGRES_PORT="5432"
SCHEMA_FILE="$BACKEND_DIR/db/schema_0.1.0.sql"  # Archivo SQL con la estructura de las tablas

# Verificar si la carpeta del proyecto existe, si no, crearla
if [ ! -d "$PROJECT_DIR" ]; then
    echo "📁 La carpeta del proyecto no existe. Creándola en $PROJECT_DIR..."
    sudo mkdir -p "$PROJECT_DIR"
    sudo chown $USER:$USER "$PROJECT_DIR"
    echo "✅ Carpeta creada."
else
    echo "✅ La carpeta del proyecto ya existe en $PROJECT_DIR."
fi

# Clonar o actualizar el repositorio del backend
if [ ! -d "$BACKEND_DIR/.git" ]; then
    echo "📥 Clonando el repositorio del backend en $BACKEND_DIR..."
    git clone $REPO_URL $PROJECT_DIR
else
    echo "🔄 Actualizando el repositorio del backend..."
    cd $BACKEND_DIR
    git pull origin develop
fi

# Actualizar paquetes e instalar dependencias
sudo apt update && sudo apt upgrade -y
sudo apt install -y docker.io docker-compose

# Iniciar y habilitar Docker
sudo systemctl start docker
sudo systemctl enable docker

# Crear un archivo docker-compose.yml en la carpeta del backend
cat <<EOF > $BACKEND_DIR/docker-compose.yml
version: '3.8'
services:
  postgres:
    image: postgres:latest
    container_name: postgres-server
    restart: unless-stopped
    environment:
      POSTGRES_USER: $POSTGRES_USER
      POSTGRES_PASSWORD: $POSTGRES_PASSWORD
      POSTGRES_DB: $POSTGRES_DB
    ports:
      - "$POSTGRES_PORT:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  backend:
    build: .
    container_name: backend-server
    restart: unless-stopped
    depends_on:
      - postgres
    environment:
      DATABASE_URL: "postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@postgres:5432/$POSTGRES_DB"
    ports:
      - "3000:3000"
    volumes:
      - .:/usr/src/app
    command: ["npm", "start"]

volumes:
  postgres_data:
EOF

# Construir e iniciar los contenedores
cd $BACKEND_DIR
sudo docker-compose up -d --build

# Esperar a que PostgreSQL arranque completamente
sleep 20

# Cargar el esquema de la base de datos si el archivo existe
if [ -f "$SCHEMA_FILE" ]; then
    sudo docker cp "$SCHEMA_FILE" postgres-server:/tmp/schema.sql
    sudo docker exec -i postgres-server psql -U $POSTGRES_USER -d $POSTGRES_DB -f /tmp/schema.sql
    echo "✅ Esquema cargado desde $SCHEMA_FILE"
else
    echo "⚠️ No se encontró el archivo de esquema en $SCHEMA_FILE. La base de datos estará vacía."
fi

# Obtener información de los contenedores
POSTGRES_CONTAINER_IP=$(sudo docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' postgres-server)
BACKEND_CONTAINER_IP=$(sudo docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' backend-server)
DB_CONNECTION_STRING="postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_CONTAINER_IP:$POSTGRES_PORT/$POSTGRES_DB"

# Mensaje final con toda la información relevante
echo "============================================"
echo "✅ Instalación completa"
echo "🔹 PostgreSQL:"
echo "   - Contenedor: postgres-server"
echo "   - IP: $POSTGRES_CONTAINER_IP"
echo "   - Base de Datos: $POSTGRES_DB"
echo "   - Usuario: $POSTGRES_USER"
echo "   - Puerto: $POSTGRES_PORT"
echo "   - String de conexión: $DB_CONNECTION_STRING"
echo "🔹 Backend:"
echo "   - Contenedor: backend-server"
echo "   - IP: $BACKEND_CONTAINER_IP"
echo "   - Expuesto en: http://localhost:3000"
echo "============================================"
