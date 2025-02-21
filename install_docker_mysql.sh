#!/bin/bash

# Variables de configuración
MYSQL_ROOT_PASSWORD="Develop@01"
MYSQL_USER="vimaz"
MYSQL_PASSWORD="8825"
MYSQL_DATABASE="vimazdb"

# Actualizar paquetes e instalar dependencias
sudo apt update && sudo apt upgrade -y
sudo apt install -y docker.io

# Iniciar y habilitar Docker
sudo systemctl start docker
sudo systemctl enable docker

# Descargar la imagen de MySQL y ejecutarla con configuración predefinida
sudo docker run --name mysql-server -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
  -e MYSQL_DATABASE=$MYSQL_DATABASE -e MYSQL_USER=$MYSQL_USER -e MYSQL_PASSWORD=$MYSQL_PASSWORD \
  -p 3306:3306 --restart unless-stopped -d mysql:latest

# Esperar a que MySQL arranque completamente
sleep 20

# Crear un contenedor temporal para modificar la configuración de MySQL
sudo docker exec -i mysql-server bash <<EOF
mysql -u root -p$MYSQL_ROOT_PASSWORD <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY '$MYSQL_ROOT_PASSWORD';
ALTER USER '$MYSQL_USER'@'%' IDENTIFIED WITH 'mysql_native_password' BY '$MYSQL_PASSWORD';
FLUSH PRIVILEGES;
EXIT;
SQL
EOF

# Configurar MySQL para aceptar conexiones remotas
sudo docker exec -i mysql-server bash <<EOF
sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
EOF

# Reiniciar el servicio MySQL dentro del contenedor
sudo docker restart mysql-server

# Mensaje final
echo "✅ Instalación completa. MySQL está corriendo en el puerto 3306 con usuario: $MYSQL_USER"
