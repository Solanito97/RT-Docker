#!/bin/bash

set -e

echo "Iniciando Request Tracker 6.0..."

# Esperar a que MySQL esté disponible
echo "Esperando conexión a MySQL..."
while ! mysqladmin ping -h"$RT_DATABASE_HOST" -u"$RT_DATABASE_USER" -p"$RT_DATABASE_PASSWORD" --silent; do
    echo "MySQL no está disponible aún - esperando..."
    sleep 2
done

echo "MySQL está disponible!"

# Verificar si la base de datos ya está inicializada
if ! mysql -h"$RT_DATABASE_HOST" -u"$RT_DATABASE_USER" -p"$RT_DATABASE_PASSWORD" -e "USE $RT_DATABASE_NAME; SELECT COUNT(*) FROM Users;" 2>/dev/null; then
    echo "Inicializando base de datos RT..."
    
    # Inicializar esquema de base de datos
    /opt/rt6/sbin/rt-setup-database --action init --skip-create
    
    echo "Base de datos inicializada!"
else
    echo "Base de datos RT ya está inicializada."
fi

# Actualizar permisos
chown -R rt:rt /opt/rt6/var
chgrp -R www-data /opt/rt6/var
chmod -R g+w /opt/rt6/var

# Iniciar Apache en primer plano
echo "Iniciando servidor web Apache..."
exec apache2ctl -D FOREGROUND