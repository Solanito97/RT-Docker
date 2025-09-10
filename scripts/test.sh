#!/bin/bash

# ===========================================
# RT-Docker Test Suite
# ===========================================

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuración
RT_URL="${RT_URL:-http://localhost:3001}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-3306}"
TIMEOUT="${TIMEOUT:-30}"

# Función de logging
log() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Test 1: Verificar que los contenedores estén ejecutándose
test_containers_running() {
    log "Test 1: Verificando estado de contenedores..."
    
    if docker-compose ps | grep -q "Up"; then
        success "Los contenedores están ejecutándose"
        return 0
    else
        error "Los contenedores no están ejecutándose"
        return 1
    fi
}

# Test 2: Verificar conectividad a RT
test_rt_connectivity() {
    log "Test 2: Verificando conectividad a RT..."
    
    if curl -s -f --max-time $TIMEOUT "$RT_URL" > /dev/null; then
        success "RT está respondiendo en $RT_URL"
        return 0
    else
        error "RT no está respondiendo en $RT_URL"
        return 1
    fi
}

# Test 3: Verificar contenido de la página RT
test_rt_content() {
    log "Test 3: Verificando contenido de RT..."
    
    local response=$(curl -s --max-time $TIMEOUT "$RT_URL" || echo "")
    
    if echo "$response" | grep -q "Request Tracker"; then
        success "La página de RT se carga correctamente"
        return 0
    else
        error "La página de RT no contiene el contenido esperado"
        return 1
    fi
}

# Test 4: Verificar conectividad a base de datos
test_database_connectivity() {
    log "Test 4: Verificando conectividad a base de datos..."
    
    if docker-compose exec db mysqladmin ping -h localhost --silent; then
        success "Base de datos MySQL está respondiendo"
        return 0
    else
        error "Base de datos MySQL no está respondiendo"
        return 1
    fi
}

# Test 5: Verificar logs de Apache
test_apache_logs() {
    log "Test 5: Verificando logs de Apache..."
    
    local log_count=$(docker-compose logs rt | grep -c "apache2" || echo "0")
    
    if [ "$log_count" -gt 0 ]; then
        success "Logs de Apache están siendo generados"
        return 0
    else
        warning "No se encontraron logs de Apache recientes"
        return 1
    fi
}

# Test 6: Verificar volúmenes persistentes
test_persistent_volumes() {
    log "Test 6: Verificando volúmenes persistentes..."
    
    local rt_volume=$(docker volume ls | grep rt-data | wc -l)
    local db_volume=$(docker volume ls | grep db-data | wc -l)
    
    if [ "$rt_volume" -gt 0 ] && [ "$db_volume" -gt 0 ]; then
        success "Volúmenes persistentes están configurados"
        return 0
    else
        error "Volúmenes persistentes no están configurados correctamente"
        return 1
    fi
}

# Test 7: Verificar health checks
test_health_checks() {
    log "Test 7: Verificando health checks..."
    
    local healthy_containers=$(docker-compose ps --format "table {{.Service}}\t{{.Status}}" | grep -c "healthy" || echo "0")
    
    if [ "$healthy_containers" -gt 0 ]; then
        success "Health checks están funcionando"
        return 0
    else
        warning "Health checks no están reportando estado saludable"
        return 1
    fi
}

# Test 8: Verificar configuración RT
test_rt_configuration() {
    log "Test 8: Verificando configuración de RT..."
    
    if docker-compose exec rt test -f /opt/rt6/etc/RT_SiteConfig.pm; then
        success "Archivo de configuración RT existe"
        return 0
    else
        error "Archivo de configuración RT no encontrado"
        return 1
    fi
}

# Test 9: Verificar permisos de archivos
test_file_permissions() {
    log "Test 9: Verificando permisos de archivos..."
    
    local perm_check=$(docker-compose exec rt find /opt/rt6/var -not -user www-data | wc -l)
    
    if [ "$perm_check" -eq 0 ]; then
        success "Permisos de archivos están configurados correctamente"
        return 0
    else
        warning "Algunos archivos no tienen los permisos correctos"
        return 1
    fi
}

# Test 10: Test de carga básico
test_load_basic() {
    log "Test 10: Test de carga básico..."
    
    local success_count=0
    local total_requests=10
    
    for i in $(seq 1 $total_requests); do
        if curl -s -f --max-time 5 "$RT_URL" > /dev/null; then
            ((success_count++))
        fi
    done
    
    local success_rate=$(echo "scale=2; $success_count * 100 / $total_requests" | bc -l)
    
    if [ "$success_count" -eq "$total_requests" ]; then
        success "Test de carga completado: 100% éxito ($success_count/$total_requests)"
        return 0
    elif [ "$success_count" -gt 7 ]; then
        warning "Test de carga completado: ${success_rate}% éxito ($success_count/$total_requests)"
        return 0
    else
        error "Test de carga falló: ${success_rate}% éxito ($success_count/$total_requests)"
        return 1
    fi
}

# Función principal
run_all_tests() {
    log "=== Iniciando RT-Docker Test Suite ==="
    
    local tests=(
        "test_containers_running"
        "test_rt_connectivity"
        "test_rt_content"
        "test_database_connectivity"
        "test_apache_logs"
        "test_persistent_volumes"
        "test_health_checks"
        "test_rt_configuration"
        "test_file_permissions"
        "test_load_basic"
    )
    
    local passed=0
    local failed=0
    local warnings=0
    
    for test in "${tests[@]}"; do
        if $test; then
            ((passed++))
        else
            case $? in
                1) ((failed++));;
                *) ((warnings++));;
            esac
        fi
        echo ""
    done
    
    log "=== Resumen de Tests ==="
    success "Tests exitosos: $passed"
    if [ $warnings -gt 0 ]; then
        warning "Tests con advertencias: $warnings"
    fi
    if [ $failed -gt 0 ]; then
        error "Tests fallidos: $failed"
    fi
    
    if [ $failed -eq 0 ]; then
        success "¡Todos los tests críticos pasaron!"
        return 0
    else
        error "Algunos tests críticos fallaron"
        return 1
    fi
}

# Función de ayuda
show_help() {
    echo "RT-Docker Test Suite"
    echo ""
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos:"
    echo "  all       - Ejecutar todos los tests (por defecto)"
    echo "  quick     - Ejecutar solo tests básicos"
    echo "  rt        - Solo tests de RT"
    echo "  db        - Solo tests de base de datos"
    echo "  help      - Mostrar esta ayuda"
    echo ""
    echo "Variables de entorno:"
    echo "  RT_URL    - URL de RT (default: http://localhost:3001)"
    echo "  TIMEOUT   - Timeout para requests (default: 30)"
    echo ""
}

# Ejecutar tests según argumentos
case "${1:-all}" in
    "all")
        run_all_tests
        ;;
    "quick")
        test_containers_running && test_rt_connectivity && test_database_connectivity
        ;;
    "rt")
        test_rt_connectivity && test_rt_content && test_rt_configuration
        ;;
    "db")
        test_database_connectivity && test_persistent_volumes
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo "Comando desconocido: $1"
        show_help
        exit 1
        ;;
esac
