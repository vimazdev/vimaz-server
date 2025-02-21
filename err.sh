#!/bin/bash

# Variables de configuración
MYSQL_ROOT_PASSWORD="Develop@01"
MYSQL_USER="vimaz"
MYSQL_PASSWORD="8825"
MYSQL_DATABASE="vimazdb"

# Conectar al contenedor MySQL y cambiar el método de autenticación
sudo docker exec -i mysql-server bash <<EOF
mysql -u root -p$MYSQL_ROOT_PASSWORD <<SQL
ALTER USER 'root'@'%' IDENTIFIED WITH 'caching_sha2_password' BY '$MYSQL_ROOT_PASSWORD';
ALTER USER '$MYSQL_USER'@'%' IDENTIFIED WITH 'caching_sha2_password' BY '$MYSQL_PASSWORD';
FLUSH PRIVILEGES;
EXIT;
SQL
EOF

# Crear un archivo de configuración para permitir conexiones remotas
echo "[mysqld]
bind-address = 0.0.0.0" | sudo tee mysql-custom.cnf > /dev/null

# Copiar el archivo de configuración al contenedor
sudo docker cp mysql-custom.cnf mysql-server:/etc/mysql/conf.d/mysql-custom.cnf

# Reiniciar MySQL para aplicar cambios
sudo docker restart mysql-server

# Eliminar el archivo de configuración temporal
rm mysql-custom.cnf

echo "✅ Configuración corregida. MySQL acepta conexiones remotas y usa 'caching_sha2_password'."
