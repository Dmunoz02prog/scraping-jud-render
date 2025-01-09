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

python
options = webdriver.ChromeOptions()
options.add_argument("--headless")
options.add_argument("--no-sandbox")
options.add_argument("--disable-dev-shm-usage")
driver = webdriver.Chrome(options=options)


best version:
from django.contrib.auth.models import User
from django.core.mail import send_mail
from celery import shared_task
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
import pandas as pd
import time
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from datetime import datetime
from django_celery_results.models import TaskResult
from django_celery_beat.models import PeriodicTask
import openpyxl
from openpyxl.styles import Alignment
from openpyxl import Workbook

@shared_task
def scrape_to_excel():
    from selenium.common.exceptions import TimeoutException, NoSuchElementException

    start_time = datetime.now()
    datos_obtenidos = []
    admin_email = User.objects.filter(is_superuser=True).first().email  # Obtén el correo del admin

    # Conjuntos de datos para las búsquedas
    data_sets = [
        {"rut": "99531960", "dv": "8", "era": "2024", "competencia": "Laboral"},
        {"rut": "79883910", "dv": "1", "era": "2024", "competencia": "Laboral"},
        {"rut": "76409376", "dv": "3", "era": "2024", "competencia": "Laboral"},
    ]

    try:
        # Configura el driver
        driver = webdriver.Chrome()  # Asegúrate de tener `chromedriver` configurado en tu sistema
        
        modal_cerrado = False
        consulta_causas_click = False

        datos_por_rut = {data["rut"]: [] for data in data_sets}
        for data in data_sets:
            try:
                # Navegar a la página principal
                driver.get("https://oficinajudicialvirtual.pjud.cl/indexN.php")
                time.sleep(5)

                # Manejar el modal solo la primera vez
                if not modal_cerrado:
                    try:
                        modal = WebDriverWait(driver, 10).until(
                            EC.visibility_of_element_located((By.ID, "no-disponible"))
                        )
                        boton_cerrar = WebDriverWait(driver, 10).until(
                            EC.element_to_be_clickable((By.CSS_SELECTOR, "#no-disponible button[data-dismiss='modal']"))
                        )
                        boton_cerrar.click()
                        modal_cerrado = True  # Actualizar bandera
                    except TimeoutException:
                        modal_cerrado = True  # Considerar que no aparece el modal

                # Hacer clic en "Consulta causas" solo la primera vez
                if not consulta_causas_click:
                    driver.find_element(By.XPATH, "//button[text()='Consulta causas']").click()
                    consulta_causas_click = True  # Actualizar bandera

                time.sleep(3)

                # Navegar a la sección de búsqueda jurídica
                driver.find_element(By.XPATH, "//a[@href='#BusJuridica']").click()
                time.sleep(3)

                # Rellenar formulario
                driver.find_element(By.ID, "rutJur").send_keys(data["rut"])
                driver.find_element(By.ID, "dvJur").send_keys(data["dv"])
                driver.find_element(By.ID, "eraJur").send_keys(data["era"])
                driver.find_element(By.ID, "jurCompetencia").send_keys(data["competencia"])
                time.sleep(3)

                borrar = [["No se han encontrado resultados con los datos ingresados. Recuerde que las causas reservadas no se muestran en la consulta unificada, y según el tipo de reserva, podrá acceder a ellas ingresando con su usuario y contraseña a la opción “Mis Causas” de la Oficina Judicial Virtual. Para conocer los tipos de reserva, pinchar aquí"]]
                

                rut_actual = data["rut"]
                if rut_actual not in datos_por_rut:
                    datos_por_rut[rut_actual] = []
                # Seleccionar cada tribunal
                for tribunal_index in range(147):  # Intentar con los primeros 30 tribunales
                    try:
                        # Selección de tribunal
                        combobox = driver.find_element(By.ID, "jurTribunal")
                        select = Select(combobox)
                        select.select_by_index(tribunal_index + 2)
                        driver.find_element(By.ID, "btnConConsultaJur").click()
                        time.sleep(6)

                        # Extraer tabla
                        tabla = WebDriverWait(driver, 10).until(
                            EC.presence_of_element_located((By.ID, "dtaTableDetalleJuridica"))
                        )
                        filas = tabla.find_elements(By.TAG_NAME, "tr")

                        for fila in filas:
                            columnas = fila.find_elements(By.TAG_NAME, "td")
                            if len(columnas) > 5:  # Verificar que hay suficientes columnas
                                # Ignorar la primera columna y procesar solo las 5 siguientes
                                datos_fila = [columna.text.strip() for columna in columnas[1:6]]
                                if datos_fila not in borrar:  # Verificar que no sea el mensaje de exclusión
                                    datos_por_rut[rut_actual].append(datos_fila)
                    except Exception as e:
                        print(f"Error procesando tribunal {tribunal_index} para el RUT {rut_actual}: {e}")

            except Exception as e:
                print(f"Error con el conjunto de datos {data}: {e}")
                continue  # Continuar con el siguiente conjunto de datos

    except Exception as e:
        # Enviar correo en caso de error crítico
        error_message = f"La tarea falló. Error: {e}\nFecha y hora: {datetime.now()}"
        send_mail(
            subject="Error en tarea asincrónica: scrape_to_excel",
            message=error_message,
            from_email="diegitocool@gmail.com",
            recipient_list=[admin_email],
            fail_silently=False,
        )
        driver.quit()
        raise e

    finally:
        driver.quit()

    # Crear un libro de trabajo y una hoja
    workbook = Workbook()
    sheet = workbook.active
    sheet.title = "Resultados"

    # Inicializar fila de escritura (comienza después de la fila en blanco inicial)
    current_row = 2  # Dejar la primera fila en blanco

    # Escribir datos por RUT
    for rut, datos in datos_por_rut.items():
        if not datos:
            print(f"Sin datos para el RUT: {rut}")
            continue

        # Escribir el RUT como título
        sheet.merge_cells(start_row=current_row, start_column=2, end_row=current_row, end_column=6)
        cell = sheet.cell(row=current_row, column=2)
        cell.value = f"RUT Consultado: {rut}"
        cell.alignment = Alignment(horizontal="center", vertical="center")
        current_row += 1  # Mover a la siguiente fila

        # Escribir encabezados
        headers = ["Rit", "Tribunal", "Caratulado", "Fecha Ingreso", "Estado Causa"]
        for col_index, header in enumerate(headers, start=2):  # Comienza en la segunda columna
            sheet.cell(row=current_row, column=col_index, value=header)
        current_row += 1  # Mover a la fila siguiente

        # Escribir datos
        for row_data in datos:
            for col_index, cell_data in enumerate(row_data, start=2):  # Comienza en la segunda columna
                sheet.cell(row=current_row, column=col_index, value=cell_data)
            current_row += 1  # Mover a la fila siguiente

        # Agregar una fila en blanco entre tablas
        current_row += 1

    # Guardar el archivo Excel
    workbook.save("Resultados_Buscados.xlsx")
    print("Archivo Excel generado correctamente.")

    # Enviar correo indicando éxito
    success_message = f"La tarea se ejecutó correctamente.\nFecha y hora: {datetime.now()}"
    send_mail(
        subject="Éxito en tarea asincrónica: scrape_to_excel",
        message=success_message,
        from_email="diegitocool@gmail.com",
        recipient_list=[admin_email],
        fail_silently=False,
    )

    return {"message": "Scraping completado y archivo Excel generado.", "start_time": start_time}