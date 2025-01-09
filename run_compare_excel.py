import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'ourproyect.settings')
django.setup()

from core.tasks import compare_excel

compare_excel()
