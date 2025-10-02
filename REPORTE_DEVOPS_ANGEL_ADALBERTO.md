# REPORTE: HERRAMIENTAS DE AUTOMATIZACIÓN EN DEVOPS

**Materia**: Herramientas de Automatización en DevOps  
**Profesor**: Froylan Pérez  
**Estudiante**: Angel Adalberto  
**Fecha**: 2025  

---

## RESUMEN EJECUTIVO

Este reporte presenta la implementación completa de herramientas de automatización en DevOps, incluyendo el desarrollo de una aplicación web, contenerización, automatización CI/CD y prácticas de seguridad DevSecOps. El proyecto demuestra la integración de múltiples tecnologías para crear un pipeline de desarrollo y despliegue automatizado.

## 1. DESCRIPCIÓN, CARACTERÍSTICAS Y VENTAJAS DE DEVOPS Y LA AUTOMATIZACIÓN

### 1.1 ¿Qué es DevOps?

DevOps es una metodología que combina el desarrollo de software (Dev) con las operaciones de TI (Ops) para acelerar el ciclo de vida del desarrollo de software y proporcionar entrega continua de alta calidad.

### 1.2 Características Principales

- **Automatización**: Reducción de tareas manuales repetitivas
- **Colaboración**: Integración entre equipos de desarrollo y operaciones
- **Integración Continua**: Integración frecuente de código en un repositorio compartido
- **Despliegue Continuo**: Liberación automática de cambios a producción
- **Monitoreo Continuo**: Supervisión constante del rendimiento y disponibilidad

### 1.3 Ventajas de la Automatización

- **Reducción de Errores**: Eliminación de errores humanos en procesos repetitivos
- **Aceleración del Desarrollo**: Entrega más rápida de funcionalidades
- **Mejor Calidad**: Detección temprana de problemas
- **Eficiencia Operacional**: Optimización de recursos y procesos
- **Escalabilidad**: Capacidad de manejar mayor volumen de trabajo

## 2. SCRIPTS DE CONFIGURACIÓN

### 2.1 Dockerfile

```dockerfile
# Usar imagen base de Python 3.11
FROM python:3.11-slim

# Establecer directorio de trabajo
WORKDIR /app

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copiar archivos de dependencias
COPY requirements.txt .

# Instalar dependencias de Python
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código de la aplicación
COPY . .

# Crear usuario no-root para seguridad
RUN useradd --create-home --shell /bin/bash app && \
    chown -R app:app /app
USER app

# Exponer puerto
EXPOSE 5000

# Variables de entorno
ENV FLASK_APP=app.py
ENV FLASK_ENV=production
ENV ENVIRONMENT=production

# Comando para ejecutar la aplicación
CMD ["python", "app.py"]
```

### 2.2 Docker Compose

```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "5000:5000"
    environment:
      - FLASK_ENV=production
      - ENVIRONMENT=production
    volumes:
      - ./logs:/app/logs
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    networks:
      - devops-network

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - web
    restart: unless-stopped
    networks:
      - devops-network

networks:
  devops-network:
    driver: bridge

volumes:
  logs:
    driver: local
```

### 2.3 Script de Seguridad

```bash
#!/bin/bash
# Script de escaneo de seguridad para el pipeline DevSecOps

set -e

echo "🔒 Iniciando escaneo de seguridad DevSecOps..."

# Crear directorio de reportes
mkdir -p security-reports

# 1. Análisis estático con Bandit
log "Ejecutando análisis estático con Bandit..."
bandit -r . -f json -o security-reports/bandit-report.json

# 2. Verificación de dependencias con Safety
log "Verificando vulnerabilidades en dependencias con Safety..."
safety check --json --output security-reports/safety-report.json

# 3. Escaneo de secretos con GitLeaks
log "Escaneando secretos en el código con GitLeaks..."
gitleaks detect --source . --report-format json --report-path security-reports/gitleaks-report.json

# 4. Análisis de vulnerabilidades en Docker con Trivy
log "Escaneando vulnerabilidades en Docker con Trivy..."
trivy fs . --format json --output security-reports/trivy-fs-report.json

echo "✅ Escaneo de seguridad completado"
```

## 3. CÓDIGO QUE REPRESENTA LA INFRAESTRUCTURA DE LA RED

### 3.1 Configuración Nginx

```nginx
events {
    worker_connections 1024;
}

http {
    upstream flask_app {
        server web:5000;
    }

    server {
        listen 80;
        server_name localhost;

        location / {
            proxy_pass http://flask_app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location /api/ {
            proxy_pass http://flask_app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

### 3.2 Aplicación Flask

```python
from flask import Flask, render_template, jsonify
import os
from datetime import datetime

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/status')
def status():
    return jsonify({
        'status': 'OK',
        'timestamp': datetime.now().isoformat(),
        'environment': os.getenv('ENVIRONMENT', 'development')
    })

@app.route('/api/health')
def health():
    return jsonify({
        'health': 'healthy',
        'version': '1.0.0',
        'uptime': 'running'
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
```

### 3.3 Workflow CI/CD

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, master, develop ]
  pull_request:
    branches: [ main, master ]

jobs:
  test:
    runs-on: ubuntu-latest
    name: Test Application
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
        
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        pip install pytest pytest-cov flake8
        
    - name: Lint with flake8
      run: |
        flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
        
    - name: Test with pytest
      run: |
        pytest --cov=app --cov-report=xml --cov-report=html

  security-scan:
    runs-on: ubuntu-latest
    name: Security Scan
    needs: test
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        scan-ref: '.'
        format: 'sarif'
        output: 'trivy-results.sarif'

  build:
    runs-on: ubuntu-latest
    name: Build Docker Image
    needs: [test, security-scan]
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
      
    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
        cache-from: type=gha
        cache-to: type=gha,mode=max
```

## 4. DESCRIPCIÓN DE LA PRUEBA DE VERIFICACIÓN DE LA INFRAESTRUCTURA COMO CÓDIGO

### 4.1 Aplicaciones y Herramientas Utilizadas

#### 4.1.1 Herramientas de Desarrollo
- **Flask**: Framework web para Python
- **Python 3.11**: Lenguaje de programación
- **Git**: Control de versiones
- **GitHub**: Repositorio y CI/CD

#### 4.1.2 Herramientas de Contenerización
- **Docker**: Contenedores de aplicación
- **Docker Compose**: Orquestación de servicios
- **Nginx**: Proxy reverso y balanceador

#### 4.1.3 Herramientas de CI/CD
- **GitHub Actions**: Automatización de pipeline
- **pytest**: Framework de testing
- **flake8**: Linting de código
- **Trivy**: Escaneo de vulnerabilidades

#### 4.1.4 Herramientas de Seguridad
- **Bandit**: Análisis estático de seguridad
- **Safety**: Verificación de dependencias
- **GitLeaks**: Detección de secretos
- **OWASP ZAP**: Pruebas de seguridad dinámicas

### 4.2 Scripts de Verificación

#### 4.2.1 Script de Pruebas Unitarias

```python
import unittest
import json
from app import app

class TestApp(unittest.TestCase):
    
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True
        
    def test_index_page(self):
        """Test that the index page loads correctly"""
        response = self.app.get('/')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'DevOps', response.data)
        
    def test_status_endpoint(self):
        """Test the status API endpoint"""
        response = self.app.get('/api/status')
        self.assertEqual(response.status_code, 200)
        
        data = json.loads(response.data)
        self.assertEqual(data['status'], 'OK')
        self.assertIn('timestamp', data)
        
    def test_health_endpoint(self):
        """Test the health API endpoint"""
        response = self.app.get('/api/health')
        self.assertEqual(response.status_code, 200)
        
        data = json.loads(response.data)
        self.assertEqual(data['health'], 'healthy')
        self.assertEqual(data['version'], '1.0.0')
```

#### 4.2.2 Script de Verificación de Infraestructura

```bash
#!/bin/bash
# Script de verificación de infraestructura

echo "🔍 Verificando infraestructura como código..."

# Verificar Docker
echo "Verificando Docker..."
docker --version
docker-compose --version

# Verificar contenedores
echo "Verificando contenedores..."
docker-compose ps

# Verificar conectividad
echo "Verificando conectividad..."
curl -f http://localhost:5000/api/health
curl -f http://localhost:80/

# Verificar logs
echo "Verificando logs..."
docker-compose logs --tail=20

# Verificar recursos
echo "Verificando recursos..."
docker stats --no-stream

echo "✅ Verificación completada"
```

#### 4.2.3 Script de Monitoreo

```bash
#!/bin/bash
# Script de monitoreo continuo

echo "📊 Iniciando monitoreo de infraestructura..."

while true; do
    # Verificar estado de la aplicación
    if curl -f http://localhost:5000/api/health > /dev/null 2>&1; then
        echo "$(date): ✅ Aplicación funcionando correctamente"
    else
        echo "$(date): ❌ Aplicación no responde"
    fi
    
    # Verificar recursos del sistema
    CPU_USAGE=$(docker stats --no-stream --format "table {{.CPUPerc}}" | tail -n +2 | head -1)
    MEMORY_USAGE=$(docker stats --no-stream --format "table {{.MemUsage}}" | tail -n +2 | head -1)
    
    echo "$(date): CPU: $CPU_USAGE, Memoria: $MEMORY_USAGE"
    
    # Esperar 30 segundos
    sleep 30
done
```

### 4.3 Comandos de Verificación

#### 4.3.1 Comandos Docker

```bash
# Construir imagen
docker build -t flask-app:latest .

# Ejecutar contenedor
docker run -d -p 5000:5000 --name flask-app flask-app:latest

# Verificar estado
docker ps
docker logs flask-app

# Ejecutar con Docker Compose
docker-compose up --build -d

# Verificar servicios
docker-compose ps
docker-compose logs -f
```

#### 4.3.2 Comandos de Testing

```bash
# Ejecutar tests unitarios
python -m pytest test_app.py -v

# Ejecutar con cobertura
python -m pytest --cov=app --cov-report=html

# Linting
flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
```

#### 4.3.3 Comandos de Seguridad

```bash
# Análisis estático
bandit -r . -f json -o bandit-report.json

# Verificación de dependencias
safety check --json --output safety-report.json

# Escaneo de vulnerabilidades
trivy fs . --format json --output trivy-report.json

# Detección de secretos
gitleaks detect --source . --report-format json
```

## 5. PIPELINE DE SEGURIDAD DEVSECOPS

### 5.1 Fases del Pipeline

#### 5.1.1 Fase de Desarrollo (Shift Left Security)
- **Git Hooks**: Validación de código antes del commit
- **IDE Plugins**: Extensiones de seguridad para el editor
- **SAST Tools**: Análisis estático de código

#### 5.1.2 Fase de Integración Continua
- **Dependency Scanning**: Verificación de vulnerabilidades
- **Code Analysis**: Análisis de patrones inseguros
- **Secret Detection**: Detección de credenciales expuestas

#### 5.1.3 Fase de Despliegue
- **DAST**: Pruebas de seguridad dinámicas
- **Container Security**: Escaneo de imágenes Docker
- **Network Scanning**: Verificación de vulnerabilidades de red

#### 5.1.4 Fase de Monitoreo
- **Runtime Security**: Detección de comportamiento anómalo
- **Log Analysis**: Análisis de logs de seguridad
- **Incident Response**: Respuesta automática a incidentes

### 5.2 Herramientas por Fase

| Fase | Herramientas | Propósito |
|------|-------------|-----------|
| Desarrollo | Git Hooks, IDE Plugins, Bandit | Validación temprana |
| CI | Safety, Trivy, GitLeaks | Escaneo automático |
| CD | OWASP ZAP, Nessus | Pruebas dinámicas |
| Monitoreo | Falco, Sysdig, ELK | Seguridad en tiempo real |

### 5.3 Matriz de Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
| Vulnerabilidades en dependencias | Alta | Medio | Escaneo automático |
| Credenciales expuestas | Media | Alto | Detección de secretos |
| Ataques de inyección | Media | Alto | Análisis estático |
| Vulnerabilidades de red | Baja | Alto | Escaneo de red |
| Comportamiento anómalo | Baja | Medio | Monitoreo continuo |

## 6. DIAGRAMA DEL FLUJO CI/CD

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   DESARROLLO    │    │   INTEGRACIÓN   │    │   DESPLIEGUE    │
│                 │    │   CONTINUA      │    │   CONTINUO      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ 1. Código Local │    │ 2. GitHub Push  │    │ 3. Build Docker │
│                 │    │                 │    │                 │
│ • app.py        │    │ • Trigger CI    │    │ • Dockerfile    │
│ • templates/    │    │ • GitHub Actions│    │ • docker-compose│
│ • static/       │    │ • Workflow      │    │ • Imagen        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Git Commit      │    │ Tests & Quality │    │ Security Scan   │
│                 │    │                 │    │                 │
│ • Pre-commit    │    │ • Unit Tests    │    │ • Trivy         │
│ • Hooks         │    │ • Linting       │    │ • Bandit        │
│ • Validation    │    │ • Coverage      │    │ • Safety        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Push to GitHub  │    │ Build & Package │    │ Deploy to Env   │
│                 │    │                 │    │                 │
│ • main branch   │    │ • Docker Build  │    │ • Staging       │
│ • Pull Request  │    │ • Registry Push │    │ • Production    │
│ • Merge         │    │ • Artifacts     │    │ • Rollback      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 7. REFLEXIÓN SOBRE SEGURIDAD

### 7.1 Importancia de la Seguridad en DevOps

La seguridad en DevOps (DevSecOps) es fundamental para garantizar la integridad y confidencialidad de las aplicaciones y datos. La integración de prácticas de seguridad desde las primeras fases del desarrollo permite:

- **Detección Temprana**: Identificación de vulnerabilidades antes de que lleguen a producción
- **Reducción de Riesgos**: Minimización de la superficie de ataque
- **Cumplimiento**: Adherencia a estándares y regulaciones de seguridad
- **Confianza**: Mayor confianza en la calidad y seguridad del software

### 7.2 Desafíos y Soluciones

#### 7.2.1 Desafíos
- **Complejidad**: Integración de múltiples herramientas de seguridad
- **Rendimiento**: Impacto en la velocidad de desarrollo
- **Costo**: Inversión en herramientas y capacitación
- **Resistencia al Cambio**: Adaptación de equipos a nuevas prácticas

#### 7.2.2 Soluciones
- **Automatización**: Reducción de tareas manuales
- **Integración**: Herramientas que se integran naturalmente
- **Capacitación**: Formación continua del equipo
- **Cultura**: Fomento de una cultura de seguridad

### 7.3 Mejores Prácticas

1. **Shift Left Security**: Integrar seguridad desde el desarrollo
2. **Automatización**: Automatizar todas las verificaciones de seguridad
3. **Monitoreo Continuo**: Supervisión constante en producción
4. **Respuesta a Incidentes**: Plan de respuesta rápida y efectiva
5. **Capacitación**: Formación continua en seguridad

## 8. CONCLUSIÓN

### 8.1 Logros del Proyecto

Este proyecto ha demostrado exitosamente la implementación de un pipeline completo de DevOps que incluye:

- **Desarrollo de Aplicación**: Aplicación Flask funcional con diseño profesional
- **Contenerización**: Configuración Docker optimizada y segura
- **Automatización CI/CD**: Pipeline completo con GitHub Actions
- **Seguridad DevSecOps**: Integración de prácticas de seguridad
- **Infraestructura como Código**: Gestión automatizada de infraestructura

### 8.2 Impacto y Beneficios

- **Eficiencia**: Reducción del tiempo de desarrollo y despliegue
- **Calidad**: Mejora en la calidad del código y la aplicación
- **Seguridad**: Protección integral contra vulnerabilidades
- **Escalabilidad**: Capacidad de manejar mayor volumen de trabajo
- **Colaboración**: Mejor integración entre equipos

### 8.3 Aprendizajes

- **Importancia de la Automatización**: La automatización es clave para la eficiencia
- **Seguridad Integrada**: La seguridad debe ser parte integral del proceso
- **Herramientas Especializadas**: Cada herramienta tiene su propósito específico
- **Monitoreo Continuo**: El monitoreo es esencial para la operación
- **Cultura de Equipo**: La colaboración es fundamental para el éxito

### 8.4 Recomendaciones Futuras

1. **Expansión del Pipeline**: Incorporar más fases y herramientas
2. **Mejora de Seguridad**: Implementar herramientas avanzadas de seguridad
3. **Monitoreo Avanzado**: Integrar sistemas de monitoreo más sofisticados
4. **Capacitación**: Continuar con la formación en nuevas tecnologías
5. **Innovación**: Explorar nuevas herramientas y metodologías

### 8.5 Reflexión Final

Este proyecto ha sido una experiencia enriquecedora que ha permitido comprender la importancia y complejidad de las herramientas de automatización en DevOps. La implementación de un pipeline completo, desde el desarrollo hasta la producción, ha demostrado cómo la automatización puede transformar los procesos de desarrollo de software, mejorando la eficiencia, calidad y seguridad.

La integración de prácticas de seguridad DevSecOps ha sido particularmente valiosa, mostrando cómo la seguridad puede ser parte integral del proceso de desarrollo sin comprometer la velocidad de entrega. El uso de herramientas especializadas para cada fase del pipeline ha permitido crear un sistema robusto y confiable.

En conclusión, este proyecto ha cumplido exitosamente con todos los objetivos planteados, demostrando las capacidades y beneficios de las herramientas de automatización en DevOps, y proporcionando una base sólida para futuros desarrollos y mejoras.

---

**Estudiante**: Angel Adalberto  
**Profesor**: Froylan Pérez  
**Materia**: Herramientas de Automatización en DevOps  
**Fecha**: 2025  

*Este reporte representa el trabajo completo realizado para la materia de Herramientas de Automatización en DevOps, incluyendo la implementación práctica de todas las tecnologías y metodologías estudiadas.*
