#!/bin/bash

# Script de utilidades para RT-Docker
# Ejecutar desde el directorio raíz del proyecto

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funciones de utilidad
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que Docker esté ejecutándose
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker no está ejecutándose. Por favor inicia Docker primero."
        exit 1
    fi
}

# Función para iniciar RT
start_rt() {
    log_info "Iniciando Request Tracker..."
    check_docker
    docker-compose up -d --build
    log_info "RT iniciado. Accede en http://localhost"
}

# Función para detener RT
stop_rt() {
    log_info "Deteniendo Request Tracker..."
    docker-compose down
    log_info "RT detenido."
}

# Función para reiniciar RT
restart_rt() {
    log_info "Reiniciando Request Tracker..."
    docker-compose restart
    log_info "RT reiniciado."
}

# Función para ver logs
show_logs() {
    if [ "$1" = "rt" ]; then
        docker-compose logs -f rt
    elif [ "$1" = "mysql" ]; then
        docker-compose logs -f mysql
    else
        docker-compose logs -f
    fi
}

# Función para backup
backup_db() {
    local backup_file="backup_rt_$(date +%Y%m%d_%H%M%S).sql"
    log_info "Creando backup en $backup_file..."
    docker-compose exec mysql mysqldump -u rt_user -prt_password rt6 > "$backup_file"
    log_info "Backup creado: $backup_file"
}

# Función para restaurar backup
restore_db() {
    if [ -z "$1" ]; then
        log_error "Especifica el archivo de backup a restaurar"
        echo "Uso: $0 restore <archivo.sql>"
        exit 1
    fi
    
    if [ ! -f "$1" ]; then
        log_error "El archivo $1 no existe"
        exit 1
    fi
    
    log_warn "¿Estás seguro de que quieres restaurar $1? Esto sobrescribirá la base de datos actual."
    read -p "Escribe 'yes' para continuar: " confirm
    if [ "$confirm" = "yes" ]; then
        log_info "Restaurando backup desde $1..."
        docker-compose exec -T mysql mysql -u rt_user -prt_password rt6 < "$1"
        log_info "Backup restaurado exitosamente"
    else
        log_info "Operación cancelada"
    fi
}

# Función para mostrar estado
status_rt() {
    log_info "Estado de los contenedores:"
    docker-compose ps
    
    log_info "Verificando conectividad..."
    if curl -s http://localhost > /dev/null; then
        log_info "RT está accesible en http://localhost"
    else
        log_warn "RT no está accesible en http://localhost"
    fi
}

# Función para limpiar todo
clean_all() {
    log_warn "¿Estás seguro de que quieres eliminar todos los contenedores y volúmenes?"
    log_warn "Esto eliminará TODOS los datos de RT y MySQL."
    read -p "Escribe 'DELETE' para continuar: " confirm
    if [ "$confirm" = "DELETE" ]; then
        log_info "Eliminando contenedores y volúmenes..."
        docker-compose down -v --remove-orphans
        docker-compose rm -f
        log_info "Limpieza completada"
    else
        log_info "Operación cancelada"
    fi
}

# Función para actualizar RT
update_rt() {
    log_info "Actualizando Request Tracker..."
    docker-compose pull
    docker-compose up -d --build
    log_info "Actualización completada"
}

# Función de ayuda
show_help() {
    echo "RT-Docker - Utilidades para Request Tracker"
    echo ""
    echo "Uso: $0 <comando> [argumentos]"
    echo ""
    echo "Comandos disponibles:"
    echo "  start         Iniciar RT y MySQL"
    echo "  stop          Detener RT y MySQL"
    echo "  restart       Reiniciar RT"
    echo "  status        Mostrar estado de los servicios"
    echo "  logs [rt|mysql] Mostrar logs (todos o de un servicio específico)"
    echo "  backup        Crear backup de la base de datos"
    echo "  restore <file> Restaurar backup de la base de datos"
    echo "  update        Actualizar RT a la última versión"
    echo "  clean         Eliminar todos los contenedores y datos"
    echo "  help          Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0 start"
    echo "  $0 logs rt"
    echo "  $0 backup"
    echo "  $0 restore backup_rt_20241005_120000.sql"
}

# Lógica principal
case "$1" in
    start)
        start_rt
        ;;
    stop)
        stop_rt
        ;;
    restart)
        restart_rt
        ;;
    status)
        status_rt
        ;;
    logs)
        show_logs "$2"
        ;;
    backup)
        backup_db
        ;;
    restore)
        restore_db "$2"
        ;;
    update)
        update_rt
        ;;
    clean)
        clean_all
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        if [ -z "$1" ]; then
            show_help
        else
            log_error "Comando desconocido: $1"
            show_help
            exit 1
        fi
        ;;
esac