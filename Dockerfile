FROM python:3.11-slim

Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    gnupg

Instalar Google Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg -i google-chrome-stable_current_amd64.deb || apt-get -fy install && \
    rm google-chrome-stable_current_amd64.deb

Instalar chromedriver
RUN wget https://chromedriver.storage.googleapis.com/$(curl -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE)/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip -d /usr/local/bin && \
    rm chromedriver_linux64.zip

Configurar el entorno de trabajo
WORKDIR /app
COPY . /app
RUN pip install -r requirements.txt

Comando de inicio
CMD ["bash", "build.sh"]
