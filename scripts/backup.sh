#!/bin/bash

# ===========================================
# RT-Docker Backup Script
# ===========================================

set -euo pipefail

# Configuración
BACKUP_DIR="${BACKUP_DIR:-./backups}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.yml}"
DB_SERVICE="${DB_SERVICE:-db}"
RT_SERVICE="${RT_SERVICE:-rt}"

# Crear directorio de backups
mkdir -p "$BACKUP_DIR"

# Función de logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Función de backup de base de datos
backup_database() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$BACKUP_DIR/rt_database_$timestamp.sql"
    
    log "Iniciando backup de base de datos..."
    
    if docker-compose -f "$COMPOSE_FILE" exec -T "$DB_SERVICE" mysqldump -u root -p"$MYSQL_ROOT_PASSWORD" rt6 > "$backup_file"; then
        log "Backup de base de datos completado: $backup_file"
        
        # Comprimir backup
        gzip "$backup_file"
        log "Backup comprimido: $backup_file.gz"
    else
        log "ERROR: Falló el backup de base de datos"
        return 1
    fi
}

# Función de backup de archivos RT
backup_rt_data() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$BACKUP_DIR/rt_data_$timestamp.tar.gz"
    
    log "Iniciando backup de datos RT..."
    
    if docker run --rm \
        -v "$(docker-compose -f "$COMPOSE_FILE" config --volumes | grep rt-data):/data:ro" \
        -v "$(pwd)/$BACKUP_DIR:/backup" \
        ubuntu:24.04 \
        tar -czf "/backup/rt_data_$timestamp.tar.gz" -C /data .; then
        log "Backup de datos RT completado: $backup_file"
    else
        log "ERROR: Falló el backup de datos RT"
        return 1
    fi
}

# Función de limpieza de backups antiguos
cleanup_old_backups() {
    log "Limpiando backups antiguos (más de $RETENTION_DAYS días)..."
    
    find "$BACKUP_DIR" -name "rt_*.gz" -type f -mtime +$RETENTION_DAYS -delete
    find "$BACKUP_DIR" -name "rt_*.tar.gz" -type f -mtime +$RETENTION_DAYS -delete
    
    log "Limpieza completada"
}

# Función principal
main() {
    log "=== Iniciando proceso de backup RT-Docker ==="
    
    # Verificar que los servicios estén ejecutándose
    if ! docker-compose -f "$COMPOSE_FILE" ps | grep -q "Up"; then
        log "ERROR: Los servicios no están ejecutándose"
        exit 1
    fi
    
    # Realizar backups
    backup_database
    backup_rt_data
    
    # Limpiar backups antiguos
    cleanup_old_backups
    
    log "=== Proceso de backup completado ==="
}

# Verificar argumentos
case "${1:-}" in
    "database")
        backup_database
        ;;
    "data")
        backup_rt_data
        ;;
    "cleanup")
        cleanup_old_backups
        ;;
    "")
        main
        ;;
    *)
        echo "Uso: $0 [database|data|cleanup]"
        echo "  database - Solo backup de base de datos"
        echo "  data     - Solo backup de datos RT"
        echo "  cleanup  - Solo limpiar backups antiguos"
        echo "  (sin argumentos) - Backup completo"
        exit 1
        ;;
esac
