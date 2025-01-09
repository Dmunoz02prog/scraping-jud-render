from __future__ import absolute_import, unicode_literals
import os
from celery import Celery
from celery.signals import beat_init

# Establece el entorno de configuración de Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'datascrap.settings')

app = Celery('datascrap')

app.conf.timezone = 'America/Santiago'
app.conf.enable_utc = True

# Configuración de Celery
app.config_from_object('django.conf:settings', namespace='CELERY')

# Autodiscover para buscar tasks.py en las aplicaciones registradas
app.autodiscover_tasks()

app.conf.beat_scheduler = 'django_celery_beat.schedulers.DatabaseScheduler'

@app.task(bind=True)
def debug_task(self):
    print(f'Request: {self.request!r}')

# Señal para ejecutar la tarea inmediatamente al iniciar beat
@beat_init.connect
def execute_initial_tasks(sender, **kwargs):
    from core.tasks import scrape_to_excel
    scrape_to_excel.apply_async()