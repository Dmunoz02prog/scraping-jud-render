# Generated by Django 5.1.3 on 2024-12-05 02:21

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='infoscrap',
            name='documento',
            field=models.FileField(blank=True, null=True, upload_to='excels_judicial/'),
        ),
    ]
