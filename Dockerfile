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
