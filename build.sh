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

gunicorn --bind 0.0.0.0:10000 datascrap.wsgi:application &

echo "Iniciando Celery beat..."
nohup celery -A datascrap worker --pool=solo --loglevel=info & 

nohup celery -A datascrap beat --loglevel=info &

