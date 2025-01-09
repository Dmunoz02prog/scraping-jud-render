#!/usr/bin/env bash

set -o errexit

pip install -r requirements.txt

python manage.py collectstatic --noinput
python manage.py migrate

python manage.py shell <<EOF
from django.contrib.auth.models import User
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'password123')
EOF

# echo "Verificando instalaciones existentes de Google Chrome y chromedriver..."
# google-chrome --version  echo "Google Chrome no está instalado"
# chromedriver --version  echo "Chromedriver no está instalado"


echo "Iniciando Celery beat..."
nohup celery -A datascrap worker --pool=solo --loglevel=info & 

nohup celery -A datascrap beat --loglevel=info &

