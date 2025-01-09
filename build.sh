#!/usr/bin/env bash

set -o errexit

Instalar dependencias del proyecto
pip install -r requirements.txt

Configurar Django
python manage.py collectstatic --noinput
python manage.py migrate

Crear superusuario si no existe
python manage.py shell <<EOF
from django.contrib.auth.models import User
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'password123')
EOF

Instalar Google Chrome y chromedriver
echo "Instalando Google Chrome y chromedriver..."
apt-get update && apt-get install -y wget unzip
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i google-chrome-stable_current_amd64.deb || apt-get -fy install
wget https://chromedriver.storage.googleapis.com/$(curl -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE)/chromedriver_linux64.zip
unzip chromedriver_linux64.zip -d /usr/local/bin
rm google-chrome-stable_current_amd64.deb chromedriver_linux64.zip

Confirmar instalación de Chrome y chromedriver
google-chrome --version
chromedriver --version

Iniciar Celery worker
echo "Iniciando Celery beat..."
nohup celery -A datascrap worker --pool=solo --loglevel=info & 

nohup celery -A datascrap beat --loglevel=info &

