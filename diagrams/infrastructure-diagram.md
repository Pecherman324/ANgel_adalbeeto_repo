# Diagrama de Infraestructura como Código

## Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────────┐
│                    INFRAESTRUCTURA COMO CÓDIGO                  │
│                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │   GITHUB    │    │   DOCKER    │    │  KUBERNETES │         │
│  │             │    │             │    │             │         │
│  │ • Repositorio│    │ • Imágenes  │    │ • Clúster   │         │
│  │ • Actions   │    │ • Registry  │    │ • Pods      │         │
│  │ • Secrets   │    │ • Compose   │    │ • Services  │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
│         │                   │                   │               │
│         │                   │                   │               │
│         ▼                   ▼                   ▼               │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │   CI/CD     │    │  CONTAINERS │    │  PRODUCTION │         │
│  │             │    │             │    │             │         │
│  │ • Build     │    │ • Flask App │    │ • Load      │         │
│  │ • Test      │    │ • Nginx     │    │   Balancer  │         │
│  │ • Deploy    │    │ • Database  │    │ • Monitoring│         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
└─────────────────────────────────────────────────────────────────┘
```

## Componentes de la Infraestructura

### 1. Capa de Aplicación
```
┌─────────────────────────────────────────────────────────────────┐
│                        APLICACIÓN FLASK                         │
│                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │   ROUTES    │    │  TEMPLATES  │    │   STATIC    │         │
│  │             │    │             │    │             │         │
│  │ • /         │    │ • index.html│    │ • CSS       │         │
│  │ • /api/     │    │ • Layout    │    │ • JS        │         │
│  │ • /health   │    │ • Components│    │ • Images    │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
└─────────────────────────────────────────────────────────────────┘
```

### 2. Capa de Contenedores
```
┌─────────────────────────────────────────────────────────────────┐
│                        DOCKER CONTAINERS                        │
│                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │   FLASK     │    │   NGINX     │    │   DATABASE  │         │
│  │   CONTAINER │    │   CONTAINER │    │   CONTAINER │         │
│  │             │    │             │    │             │         │
│  │ • Python    │    │ • Reverse   │    │ • PostgreSQL│         │
│  │ • Flask     │    │   Proxy     │    │ • Redis     │         │
│  │ • Port 5000 │    │ • Port 80   │    │ • Port 5432 │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
└─────────────────────────────────────────────────────────────────┘
```

### 3. Capa de Orquestación
```
┌─────────────────────────────────────────────────────────────────┐
│                      KUBERNETES CLUSTER                        │
│                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │    NODES    │    │    PODS     │    │  SERVICES   │         │
│  │             │    │             │    │             │         │
│  │ • Master    │    │ • Web Pods  │    │ • ClusterIP │         │
│  │ • Workers   │    │ • DB Pods   │    │ • NodePort  │         │
│  │ • Storage   │    │ • Cache     │    │ • LoadBalancer│       │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
└─────────────────────────────────────────────────────────────────┘
```

## Configuración de Red

### Docker Compose Network
```yaml
networks:
  devops-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

### Kubernetes Network
```yaml
apiVersion: v1
kind: Service
metadata:
  name: flask-service
spec:
  selector:
    app: flask
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5000
  type: LoadBalancer
```

## Scripts de Configuración

### 1. Script de Inicialización
```bash
#!/bin/bash
# init-infrastructure.sh

echo "🚀 Inicializando infraestructura como código..."

# Crear red Docker
docker network create devops-network

# Construir imágenes
docker-compose build

# Ejecutar servicios
docker-compose up -d

# Verificar estado
docker-compose ps

echo "✅ Infraestructura inicializada correctamente"
```

### 2. Script de Despliegue
```bash
#!/bin/bash
# deploy.sh

echo "🚀 Desplegando aplicación..."

# Construir nueva imagen
docker build -t flask-app:latest .

# Etiquetar para registry
docker tag flask-app:latest ghcr.io/username/flask-app:latest

# Subir a registry
docker push ghcr.io/username/flask-app:latest

# Desplegar en Kubernetes
kubectl apply -f k8s/

# Verificar despliegue
kubectl get pods
kubectl get services

echo "✅ Aplicación desplegada correctamente"
```

### 3. Script de Monitoreo
```bash
#!/bin/bash
# monitor.sh

echo "📊 Monitoreando infraestructura..."

# Verificar estado de contenedores
docker-compose ps

# Verificar logs
docker-compose logs --tail=50

# Verificar recursos
docker stats --no-stream

# Verificar conectividad
curl -f http://localhost/api/health

echo "✅ Monitoreo completado"
```

## Verificación de Infraestructura

### 1. Pruebas de Conectividad
```bash
# Verificar puertos
netstat -tulpn | grep :5000
netstat -tulpn | grep :80

# Verificar DNS
nslookup flask-service
nslookup nginx-service

# Verificar balanceador
curl -I http://localhost
curl -I http://localhost/api/status
```

### 2. Pruebas de Rendimiento
```bash
# Prueba de carga
ab -n 1000 -c 10 http://localhost/

# Prueba de estrés
stress-ng --cpu 4 --timeout 60s

# Monitoreo de recursos
htop
iostat -x 1
```

### 3. Pruebas de Seguridad
```bash
# Escaneo de puertos
nmap -sS -O localhost

# Verificación de SSL
openssl s_client -connect localhost:443

# Análisis de vulnerabilidades
trivy image flask-app:latest
```

## Métricas de Infraestructura

### Disponibilidad
- **Uptime**: > 99.9%
- **MTTR**: < 30 minutos
- **MTBF**: > 720 horas

### Rendimiento
- **Latencia**: < 100ms
- **Throughput**: > 1000 req/s
- **CPU Usage**: < 70%
- **Memory Usage**: < 80%

### Seguridad
- **Vulnerabilidades**: 0 críticas
- **Parches**: Actualizados
- **Certificados**: Válidos
- **Accesos**: Auditados
