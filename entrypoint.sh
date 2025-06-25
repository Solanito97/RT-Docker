#!/bin/bash
set -euo pipefail

# Función para logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "Iniciando contenedor RT6..."

# Verificar variables de entorno requeridas
: ${RT_DATABASE_HOST:?RT_DATABASE_HOST no está definido}
: ${RT_DATABASE_NAME:?RT_DATABASE_NAME no está definido}
: ${RT_ROOT_PASSWORD:?RT_ROOT_PASSWORD no está definido}

log "Esperando a que la base de datos ($RT_DATABASE_HOST) esté disponible..."
for i in {1..60}; do
    if mysqladmin ping -h "$RT_DATABASE_HOST" --silent; then
        log "Base de datos disponible."
        break
    fi
    if [ $i -eq 60 ]; then
        log "ERROR: Timeout esperando la base de datos"
        exit 1
    fi
    sleep 2
done

# Crear directorio de logs si no existe
mkdir -p /opt/rt6/var/log
chown -R www-data:www-data /opt/rt6/var

# Verificar si la base de datos ya existe
DB_EXISTS=$(mysql --skip-column-names -h "$RT_DATABASE_HOST" -u root -p"$RT_ROOT_PASSWORD" -e "SHOW DATABASES LIKE '$RT_DATABASE_NAME';" | grep "$RT_DATABASE_NAME" || true)

if [ "$DB_EXISTS" == "$RT_DATABASE_NAME" ]; then
    log "La base de datos $RT_DATABASE_NAME ya existe. Omitiendo inicialización."
    touch /opt/rt6/var/.initialized
else
    log "Inicializando la base de datos de RT..."
    /opt/rt6/sbin/rt-setup-database \
        --action init \
        --dba root \
        --dba-password "$RT_ROOT_PASSWORD" || {
            log "ERROR: Error al inicializar la base de datos. Verifica la configuración."
            exit 1
        }
    touch /opt/rt6/var/.initialized
    log "Inicialización completada."
fi

log "Iniciando Apache..."
exec apache2ctl -D FOREGROUND
