#!/bin/bash

# Script para ejecutar el proyecto completo
# Autor: Angel Adalberto
# Fecha: 2025

set -e

echo "🚀 Iniciando proyecto DevOps - Herramientas de Automatización"
echo "Estudiante: Angel Adalberto"
echo "Profesor: Froylan Pérez"
echo "=================================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

# Verificar prerrequisitos
check_prerequisites() {
    log "Verificando prerrequisitos..."
    
    # Verificar Python
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
        info "Python encontrado: $PYTHON_VERSION"
    else
        error "Python 3 no está instalado"
        exit 1
    fi
    
    # Verificar Docker
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        info "Docker encontrado: $DOCKER_VERSION"
    else
        error "Docker no está instalado"
        exit 1
    fi
    
    # Verificar Docker Compose
    if command -v docker-compose &> /dev/null; then
        COMPOSE_VERSION=$(docker-compose --version | cut -d' ' -f3 | cut -d',' -f1)
        info "Docker Compose encontrado: $COMPOSE_VERSION"
    else
        error "Docker Compose no está instalado"
        exit 1
    fi
    
    log "✅ Todos los prerrequisitos están instalados"
}

# Instalar dependencias Python
install_python_deps() {
    log "Instalando dependencias de Python..."
    
    if [ -f "requirements.txt" ]; then
        pip3 install -r requirements.txt
        log "✅ Dependencias de Python instaladas"
    else
        warn "requirements.txt no encontrado"
    fi
}

# Ejecutar tests
run_tests() {
    log "Ejecutando tests unitarios..."
    
    if [ -f "test_app.py" ]; then
        python3 -m pytest test_app.py -v
        log "✅ Tests ejecutados correctamente"
    else
        warn "test_app.py no encontrado"
    fi
}

# Construir y ejecutar con Docker
run_docker() {
    log "Construyendo y ejecutando con Docker Compose..."
    
    # Detener contenedores existentes
    docker-compose down 2>/dev/null || true
    
    # Construir y ejecutar
    docker-compose up --build -d
    
    # Esperar a que los servicios estén listos
    log "Esperando a que los servicios estén listos..."
    sleep 10
    
    # Verificar estado
    docker-compose ps
    
    log "✅ Servicios Docker ejecutándose"
}

# Verificar conectividad
check_connectivity() {
    log "Verificando conectividad..."
    
    # Verificar puerto 5000 (Flask)
    if curl -f http://localhost:5000/api/health > /dev/null 2>&1; then
        log "✅ Aplicación Flask funcionando en puerto 5000"
    else
        warn "Aplicación Flask no responde en puerto 5000"
    fi
    
    # Verificar puerto 80 (Nginx)
    if curl -f http://localhost:80/ > /dev/null 2>&1; then
        log "✅ Nginx funcionando en puerto 80"
    else
        warn "Nginx no responde en puerto 80"
    fi
}

# Mostrar información del proyecto
show_project_info() {
    echo ""
    echo "=================================================="
    echo "🎉 PROYECTO EJECUTÁNDOSE CORRECTAMENTE"
    echo "=================================================="
    echo ""
    echo "📋 Información del Proyecto:"
    echo "   • Materia: Herramientas de Automatización en DevOps"
    echo "   • Profesor: Froylan Pérez"
    echo "   • Estudiante: Angel Adalberto"
    echo "   • Fecha: 2025"
    echo ""
    echo "🌐 URLs de Acceso:"
    echo "   • Aplicación Flask: http://localhost:5000"
    echo "   • Nginx (Proxy): http://localhost:80"
    echo "   • API Status: http://localhost:5000/api/status"
    echo "   • API Health: http://localhost:5000/api/health"
    echo ""
    echo "📊 Comandos Útiles:"
    echo "   • Ver logs: docker-compose logs -f"
    echo "   • Ver estado: docker-compose ps"
    echo "   • Detener: docker-compose down"
    echo "   • Reiniciar: docker-compose restart"
    echo ""
    echo "🔒 Seguridad:"
    echo "   • Ejecutar escaneo: ./security-scripts/security-scan.sh"
    echo "   • Ver reportes: ls security-reports/"
    echo ""
    echo "=================================================="
}

# Función principal
main() {
    echo "Iniciando proceso de ejecución del proyecto..."
    
    # Verificar prerrequisitos
    check_prerequisites
    
    # Instalar dependencias
    install_python_deps
    
    # Ejecutar tests
    run_tests
    
    # Ejecutar con Docker
    run_docker
    
    # Verificar conectividad
    check_connectivity
    
    # Mostrar información
    show_project_info
    
    log "🎉 Proyecto ejecutándose correctamente"
    log "Presiona Ctrl+C para detener los servicios"
    
    # Mantener el script ejecutándose
    while true; do
        sleep 30
        # Verificar que los servicios sigan funcionando
        if ! docker-compose ps | grep -q "Up"; then
            error "Algunos servicios se han detenido"
            break
        fi
    done
}

# Manejar interrupciones
trap 'echo ""; log "Deteniendo servicios..."; docker-compose down; log "Servicios detenidos. ¡Hasta luego!"; exit 0' INT

# Ejecutar función principal
main "$@"
