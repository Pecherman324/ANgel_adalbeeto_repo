#!/bin/bash

# Script para detener el proyecto
# Autor: Angel Adalberto
# Fecha: 2025

set -e

echo "🛑 Deteniendo proyecto DevOps - Herramientas de Automatización"
echo "Estudiante: Angel Adalberto"
echo "Profesor: Froylan Pérez"
echo "=================================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

# Detener servicios Docker
stop_docker_services() {
    log "Deteniendo servicios Docker..."
    
    if [ -f "docker-compose.yml" ]; then
        docker-compose down
        log "✅ Servicios Docker detenidos"
    else
        warn "docker-compose.yml no encontrado"
    fi
}

# Limpiar contenedores huérfanos
cleanup_containers() {
    log "Limpiando contenedores huérfanos..."
    
    # Detener contenedores del proyecto
    docker ps -q --filter "name=proyectoadalberto" | xargs -r docker stop
    docker ps -aq --filter "name=proyectoadalberto" | xargs -r docker rm
    
    # Limpiar imágenes no utilizadas
    docker image prune -f
    
    log "✅ Limpieza completada"
}

# Verificar estado final
check_final_state() {
    log "Verificando estado final..."
    
    # Verificar que no hay contenedores ejecutándose
    RUNNING_CONTAINERS=$(docker ps --filter "name=proyectoadalberto" --format "table {{.Names}}" | wc -l)
    
    if [ "$RUNNING_CONTAINERS" -eq 1 ]; then
        log "✅ No hay contenedores del proyecto ejecutándose"
    else
        warn "Aún hay contenedores ejecutándose"
        docker ps --filter "name=proyectoadalberto"
    fi
}

# Mostrar resumen
show_summary() {
    echo ""
    echo "=================================================="
    echo "🛑 PROYECTO DETENIDO CORRECTAMENTE"
    echo "=================================================="
    echo ""
    echo "📋 Resumen:"
    echo "   • Servicios Docker detenidos"
    echo "   • Contenedores limpiados"
    echo "   • Recursos liberados"
    echo ""
    echo "🔄 Para reiniciar el proyecto:"
    echo "   • Ejecutar: ./scripts/run-project.sh"
    echo "   • O manualmente: docker-compose up --build -d"
    echo ""
    echo "🧹 Para limpieza completa:"
    echo "   • docker system prune -a"
    echo "   • docker volume prune"
    echo ""
    echo "=================================================="
}

# Función principal
main() {
    # Detener servicios
    stop_docker_services
    
    # Limpiar contenedores
    cleanup_containers
    
    # Verificar estado
    check_final_state
    
    # Mostrar resumen
    show_summary
    
    log "🎉 Proyecto detenido correctamente"
}

# Ejecutar función principal
main "$@"
