#!/bin/bash
set -e

echo "Esperando a que la base de datos ($RT_DATABASE_HOST) esté disponible..."
while ! mysqladmin ping -h "$RT_DATABASE_HOST" --silent; do
    sleep 1
done
echo "Base de datos disponible."

# Verificar si la base de datos ya existe usando --skip-column-names para evitar la cabecera
DB_EXISTS=$(mysql --skip-column-names -h "$RT_DATABASE_HOST" -u root -p"$RT_ROOT_PASSWORD" -e "SHOW DATABASES LIKE '$RT_DATABASE_NAME';" | grep "$RT_DATABASE_NAME" || true)

if [ "$DB_EXISTS" == "$RT_DATABASE_NAME" ]; then
    echo "La base de datos $RT_DATABASE_NAME ya existe. Omitiendo inicialización."
    touch /opt/rt6/var/.initialized
else
    echo "Inicializando la base de datos de RT..."
    /opt/rt6/sbin/rt-setup-database \
        --action init \
        --dba root \
        --dba-password "$RT_ROOT_PASSWORD" || {
            echo "Error al inicializar la base de datos. Verifica la configuración y vuelve a intentarlo."
            exit 1
        }
    touch /opt/rt6/var/.initialized
    echo "Inicialización completada."
fi

echo "Iniciando Apache..."
exec apache2ctl -D FOREGROUND
