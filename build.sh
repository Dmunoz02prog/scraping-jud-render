#!/usr/bin/env bash

echo "INICIO###########..."
set -o errexit

# Instalación de dependencias (si es necesario)
# pip install -r requirements.txt

# Recolección de archivos estáticos
echo "Recolectando archivos estáticos..."
python manage.py collectstatic --noinput
echo "Archivos estáticos recolectados."

# Migración de base de datos
echo "Ejecutando migraciones..."
python manage.py migrate
echo "Migraciones ejecutadas."

# Verifica la instalación de chromedriver
echo "Verificando instalaciones existentes de Google Chrome y chromedriver..."
if chromedriver --version; then
    echo "Chromedriver está instalado."
else
    echo "Chromedriver no está instalado. Verifica tu entorno."
fi

# Inicia Celery Worker
echo "Iniciando Celery Worker..."
nohup celery -A datascrap worker --pool=solo --loglevel=info &
echo "Celery Worker iniciado."

# Inicia Celery Beat
echo "Iniciando Celery Beat..."
nohup celery -A datascrap beat --loglevel=info &
echo "Celery Beat iniciado."

# Mantiene el contenedor activo
echo "Manteniendo el contenedor activo..."

python manage.py runserver 0.0.0.0:$PORT