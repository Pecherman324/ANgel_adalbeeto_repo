# DevOps - Herramientas de Automatización

## Información del Proyecto

- **Materia**: Herramientas de Automatización en DevOps
- **Profesor**: Froylan Pérez
- **Estudiante**: Angel Adalberto
- **Fecha**: 2025

## Descripción

Este proyecto demuestra la implementación de herramientas de automatización en DevOps, incluyendo desarrollo de aplicaciones, contenerización, automatización CI/CD y prácticas de seguridad DevSecOps.

## Características del Proyecto

### 1. Aplicación Web Flask
- **Framework**: Flask 2.3.3
- **Diseño**: Blanco y negro (según especificaciones del profesor)
- **Funcionalidades**:
  - Página principal con información del proyecto
  - API de estado y salud
  - Diseño responsivo
  - Monitoreo en tiempo real

### 2. Contenerización
- **Docker**: Imagen optimizada con Python 3.11
- **Docker Compose**: Orquestación de servicios
- **Nginx**: Proxy reverso y balanceador de carga
- **Seguridad**: Usuario no-root, health checks

### 3. Automatización CI/CD
- **GitHub Actions**: Pipeline completo de integración y despliegue
- **Tests**: Unitarios, linting, cobertura
- **Seguridad**: Escaneo de vulnerabilidades
- **Despliegue**: Automático a staging y producción

### 4. DevSecOps
- **SAST**: Análisis estático con Bandit
- **DAST**: Pruebas dinámicas con OWASP ZAP
- **Dependency Scanning**: Verificación con Safety
- **Secret Detection**: GitLeaks
- **Container Security**: Trivy

## Estructura del Proyecto

```
ProyectoAdalberto/
├── app.py                          # Aplicación Flask principal
├── requirements.txt                # Dependencias Python
├── Dockerfile                      # Configuración Docker
├── docker-compose.yml              # Orquestación de servicios
├── nginx.conf                      # Configuración Nginx
├── test_app.py                     # Tests unitarios
├── .github/
│   └── workflows/
│       └── ci.yml                  # Pipeline CI/CD
├── templates/
│   └── index.html                  # Template principal
├── static/                         # Archivos estáticos
├── security-scripts/
│   ├── bandit-config.yaml         # Configuración Bandit
│   └── security-scan.sh           # Script de escaneo
├── diagrams/
│   ├── cicd-flow.md               # Diagrama CI/CD
│   └── infrastructure-diagram.md  # Diagrama de infraestructura
├── devsecops-pipeline.md          # Documentación DevSecOps
└── README.md                      # Este archivo
```

## Instalación y Uso

### Prerrequisitos
- Python 3.11+
- Docker y Docker Compose
- Git

### Instalación Local
```bash
# Clonar repositorio
git clone <repository-url>
cd ProyectoAdalberto

# Instalar dependencias
pip install -r requirements.txt

# Ejecutar aplicación
python app.py
```

### Instalación con Docker
```bash
# Construir y ejecutar con Docker Compose
docker-compose up --build

# Verificar estado
docker-compose ps

# Ver logs
docker-compose logs -f
```

### Acceso a la Aplicación
- **Aplicación**: http://localhost:5000
- **Nginx**: http://localhost:80
- **API Status**: http://localhost:5000/api/status
- **API Health**: http://localhost:5000/api/health

## Pipeline CI/CD

### Fases del Pipeline
1. **Test**: Ejecución de tests unitarios y linting
2. **Security Scan**: Escaneo de vulnerabilidades
3. **Build**: Construcción de imagen Docker
4. **Deploy**: Despliegue automático
5. **Rollback**: Recuperación automática en caso de fallo

### Herramientas Utilizadas
- **Testing**: pytest, flake8
- **Security**: Trivy, Bandit, Safety
- **Build**: Docker Buildx
- **Deploy**: GitHub Actions
- **Monitoring**: Health checks, logs

## Seguridad DevSecOps

### Pipeline de Seguridad
1. **Desarrollo**: Git hooks, IDE plugins, SAST
2. **CI**: Dependency scanning, code analysis
3. **CD**: DAST, container security
4. **Monitoreo**: Runtime security, log analysis

### Herramientas de Seguridad
- **SAST**: Bandit, Semgrep
- **DAST**: OWASP ZAP
- **Dependency**: Safety, Trivy
- **Secrets**: GitLeaks
- **Runtime**: Falco, Sysdig

## Scripts de Configuración

### Script de Seguridad
```bash
# Ejecutar escaneo completo
./security-scripts/security-scan.sh
```

### Script de Despliegue
```bash
# Desplegar aplicación
docker-compose up --build -d
```

### Script de Monitoreo
```bash
# Verificar estado
docker-compose ps
docker-compose logs -f
```

## Verificación de Infraestructura

### Pruebas de Conectividad
```bash
# Verificar puertos
netstat -tulpn | grep :5000
netstat -tulpn | grep :80

# Verificar API
curl http://localhost:5000/api/status
curl http://localhost:5000/api/health
```

### Pruebas de Rendimiento
```bash
# Prueba de carga
ab -n 1000 -c 10 http://localhost/

# Monitoreo de recursos
docker stats
```

## Métricas y KPIs

### Calidad
- **Cobertura de tests**: > 80%
- **Tiempo de build**: < 5 minutos
- **Tiempo de despliegue**: < 10 minutos

### Seguridad
- **Vulnerabilidades críticas**: 0
- **Tiempo de detección**: < 5 minutos
- **Tiempo de respuesta**: < 30 minutos

### Operaciones
- **Disponibilidad**: > 99.9%
- **MTTR**: < 30 minutos
- **Frecuencia de despliegue**: Diaria

## Contribución

1. Fork el proyecto
2. Crear rama de feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

## Licencia

Este proyecto es parte de un trabajo académico para la materia de Herramientas de Automatización en DevOps.

## Contacto

- **Estudiante**: Angel Adalberto
- **Profesor**: Froylan Pérez
- **Materia**: Herramientas de Automatización en DevOps

---

*Proyecto desarrollado como parte del curso de DevOps - 2025*
