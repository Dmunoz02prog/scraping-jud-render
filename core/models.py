from django.db import models
from django.contrib.auth.models import User

# Create your models here.

class InfoScrap(models.Model):
    # solicitado = models.ForeignKey(User, null=True, blank=True, on_delete=models.DO_NOTHING, related_name='solicitado')
    fecha_guardado = models.DateTimeField(auto_now_add=True)
    documento = models.FileField(null=True, blank=True, upload_to='excels_judicial/')

# class ArchivoInfo(models.Model):
#     info = models.ForeignKey(InfoScrap, on_delete=models.DO_NOTHING, related_name='archivos')
#     archivo = models.FileField(upload_to='archivos_solicitudes/')
#     fecha_subida = models.DateTimeField(auto_now_add=True)