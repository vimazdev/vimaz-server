#!/bin/bash

# Actualizar paquetes y limpiar
sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y && sudo apt clean

# Mensaje de finalización
echo "Actualización del sistema completada. Ejecutando init-docker-mysql.sh..."

# Verificar si next.sh existe y tiene permisos de ejecución
if [ -f "init-docker-postgres.sh" ]; then
    chmod +x init-docker-postgres.sh  # Asegurar permisos de ejecución
    ./next.sh  # Ejecutar el siguiente script
else
    echo "Error: init-docker-postgres.sh no encontrado."
fi
