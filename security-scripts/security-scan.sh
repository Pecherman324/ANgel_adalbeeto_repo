#!/bin/bash

# Script de escaneo de seguridad para el pipeline DevSecOps
# Autor: Angel Adalberto
# Fecha: 2025

set -e

echo "🔒 Iniciando escaneo de seguridad DevSecOps..."

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

# Crear directorio de reportes
mkdir -p security-reports

# 1. Análisis estático con Bandit
log "Ejecutando análisis estático con Bandit..."
if command -v bandit &> /dev/null; then
    bandit -r . -f json -o security-reports/bandit-report.json -c security-scripts/bandit-config.yaml
    bandit -r . -f txt -o security-reports/bandit-report.txt -c security-scripts/bandit-config.yaml
    log "Reporte de Bandit generado en security-reports/bandit-report.json"
else
    warn "Bandit no está instalado. Instalando..."
    pip install bandit
    bandit -r . -f json -o security-reports/bandit-report.json -c security-scripts/bandit-config.yaml
fi

# 2. Verificación de dependencias con Safety
log "Verificando vulnerabilidades en dependencias con Safety..."
if command -v safety &> /dev/null; then
    safety check --json --output security-reports/safety-report.json
    safety check --output security-reports/safety-report.txt
    log "Reporte de Safety generado en security-reports/safety-report.json"
else
    warn "Safety no está instalado. Instalando..."
    pip install safety
    safety check --json --output security-reports/safety-report.json
fi

# 3. Escaneo de secretos con GitLeaks
log "Escaneando secretos en el código con GitLeaks..."
if command -v gitleaks &> /dev/null; then
    gitleaks detect --source . --report-format json --report-path security-reports/gitleaks-report.json
    gitleaks detect --source . --report-format sarif --report-path security-reports/gitleaks-report.sarif
    log "Reporte de GitLeaks generado en security-reports/gitleaks-report.json"
else
    warn "GitLeaks no está instalado. Saltando escaneo de secretos..."
fi

# 4. Análisis de vulnerabilidades en Docker con Trivy
log "Escaneando vulnerabilidades en Docker con Trivy..."
if command -v trivy &> /dev/null; then
    trivy fs . --format json --output security-reports/trivy-fs-report.json
    trivy fs . --format table --output security-reports/trivy-fs-report.txt
    log "Reporte de Trivy generado en security-reports/trivy-fs-report.json"
else
    warn "Trivy no está instalado. Saltando escaneo de Docker..."
fi

# 5. Análisis con Semgrep
log "Ejecutando análisis con Semgrep..."
if command -v semgrep &> /dev/null; then
    semgrep --config=auto --json --output=security-reports/semgrep-report.json .
    semgrep --config=auto --output=security-reports/semgrep-report.txt .
    log "Reporte de Semgrep generado en security-reports/semgrep-report.json"
else
    warn "Semgrep no está instalado. Saltando análisis con Semgrep..."
fi

# 6. Generar reporte consolidado
log "Generando reporte consolidado de seguridad..."
cat > security-reports/security-summary.md << EOF
# Reporte de Seguridad DevSecOps

**Fecha:** $(date)
**Proyecto:** DevOps - Herramientas de Automatización
**Estudiante:** Angel Adalberto
**Profesor:** Froylan Pérez

## Resumen de Escaneos

### 1. Análisis Estático (Bandit)
- **Archivo:** bandit-report.json
- **Estado:** Completado
- **Vulnerabilidades encontradas:** Ver reporte detallado

### 2. Dependencias (Safety)
- **Archivo:** safety-report.json
- **Estado:** Completado
- **Vulnerabilidades encontradas:** Ver reporte detallado

### 3. Secretos (GitLeaks)
- **Archivo:** gitleaks-report.json
- **Estado:** Completado
- **Secretos encontrados:** Ver reporte detallado

### 4. Docker (Trivy)
- **Archivo:** trivy-fs-report.json
- **Estado:** Completado
- **Vulnerabilidades encontradas:** Ver reporte detallado

### 5. Análisis Avanzado (Semgrep)
- **Archivo:** semgrep-report.json
- **Estado:** Completado
- **Problemas encontrados:** Ver reporte detallado

## Recomendaciones

1. Revisar todos los reportes generados
2. Corregir vulnerabilidades de alta y media severidad
3. Actualizar dependencias vulnerables
4. Implementar medidas de mitigación para riesgos identificados

## Próximos Pasos

1. Integrar estos escaneos en el pipeline CI/CD
2. Configurar alertas automáticas para nuevas vulnerabilidades
3. Implementar monitoreo continuo de seguridad
4. Capacitar al equipo en prácticas de seguridad

---
*Reporte generado automáticamente por el pipeline de seguridad DevSecOps*
EOF

log "Reporte consolidado generado en security-reports/security-summary.md"

# 7. Verificar si hay vulnerabilidades críticas
log "Verificando vulnerabilidades críticas..."

CRITICAL_ISSUES=0

# Verificar Bandit
if [ -f "security-reports/bandit-report.json" ]; then
    BANDIT_ISSUES=$(jq '.results | length' security-reports/bandit-report.json 2>/dev/null || echo "0")
    if [ "$BANDIT_ISSUES" -gt 0 ]; then
        warn "Bandit encontró $BANDIT_ISSUES problemas de seguridad"
        CRITICAL_ISSUES=$((CRITICAL_ISSUES + BANDIT_ISSUES))
    fi
fi

# Verificar Safety
if [ -f "security-reports/safety-report.json" ]; then
    SAFETY_ISSUES=$(jq '.vulnerabilities | length' security-reports/safety-report.json 2>/dev/null || echo "0")
    if [ "$SAFETY_ISSUES" -gt 0 ]; then
        warn "Safety encontró $SAFETY_ISSUES vulnerabilidades en dependencias"
        CRITICAL_ISSUES=$((CRITICAL_ISSUES + SAFETY_ISSUES))
    fi
fi

# Resultado final
if [ $CRITICAL_ISSUES -eq 0 ]; then
    log "✅ Escaneo de seguridad completado sin problemas críticos"
    exit 0
else
    error "❌ Se encontraron $CRITICAL_ISSUES problemas de seguridad críticos"
    error "Por favor, revisa los reportes en security-reports/ y corrige los problemas"
    exit 1
fi
