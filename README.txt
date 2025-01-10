Comando para instalar todos los paquetes del requirements:
pip install -r requirements.txt

para ativar celery descargar:
https://github.com/microsoftarchive/redis/releases (Redis-x64-3.0.504.zip)

Luego habrir el cmd y ejecutar en la carpeta del zip(Redis-x64-3.0.504)
este comando:
redis-server.exe redis.windows.conf

para confirmar habra otra cmd en la misma carpeta y ejecuta:
redis-cli.exe

luego escribe 'ping' y te respondera con 'PONG' significara que esta funcionnado correctamete


para hacer uso del puerto de redis se debe instarlar docker (https://docs.docker.com/desktop/setup/install/windows-install/)
luego en el cmd ejecutar este comando (Esto instalar el puerto en docker para luego hacer uso de el, solo debe hacerse una ves este paso):
docker run --name redis -p 6379:6379 -d redis

y luego para activarlo:
docker exec -it redis redis-cli

y para activar el celery dentro del proyecto se debe ejecuta:
celery -A datascrap worker --pool=solo --loglevel=info

para que se ejecuten la funciones se debe ejecutar el comando:
celery -A datascrap beat --loglevel=info








to te future:
Manejar dependencias de Selenium en servidores
Si planeas ejecutar esta tarea en un servidor, es importante instalar un navegador sin interfaz gráfica (como headless Chrome) para evitar problemas. Puedes modificar el webdriver.Chrome() para usar un navegador sin interfaz:


Uso de variables de entorno (opcional, pero recomendado):

Es una buena práctica no hardcodear las credenciales de la base de datos directamente en el archivo settings.py, especialmente si estás desplegando en producción. Puedes usar variables de entorno para manejar las credenciales de manera más segura.

Primero, instala la biblioteca python-decouple:

bash
Copiar código
pip install python-decouple
Luego, modifica tu settings.py para usar las variables de entorno:

python
Copiar código
from decouple import config

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': config('DB_NAME', default='scrap_backend_database'),
        'USER': config('DB_USER', default='root'),
        'PASSWORD': config('DB_PASSWORD', default='hccfok5fKtcAaP8B2sm1frmresHYMgvu'),
        'HOST': config('DB_HOST', default='dpg-cu039623esus73aef0cg-a.oregon-postgres.render.com'),
        'PORT': config('DB_PORT', default='5432'),
    }
}
Ahora, crea un archivo .env en la raíz de tu proyecto (si aún no lo tienes) y agrega las variables de entorno:

makefile
Copiar código
DB_NAME=scrap_backend_database
DB_USER=root
DB_PASSWORD=hccfok5fKtcAaP8B2sm1frmresHYMgvu
DB_HOST=dpg-cu039623esus73aef0cg-a.oregon-postgres.render.com
DB_PORT=5432
Migrar la base de datos:

Después de configurar la base de datos, asegúrate de ejecutar las migraciones para configurar las tablas en la base de datos PostgreSQL:

bash
Copiar código
python manage.py migrate
Comprobar la conexión:

Para verificar que todo está funcionando correctamente, inicia tu servidor de desarrollo de Django:

bash
Copiar código
python manage.py runserver
Y asegúrate de que tu aplicación pueda conectarse correctamente a la base de datos PostgreSQL.

Con estos cambios, tu aplicación Django debería estar conectada a la base de datos PostgreSQL proporcionada por Render.