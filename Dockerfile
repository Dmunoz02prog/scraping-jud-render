FROM python:3.11-slim

# Instalar dependencias del sistema y Chromium
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    gnupg \
    chromium \
    chromium-driver \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxi6 \
    libxtst6 \
    libappindicator3-1 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    xdg-utils



# Configuración de la aplicación
WORKDIR /app
COPY . /app
RUN pip install -r requirements.txt
RUN chmod +x /app/build.sh

# Verificar instalación
RUN chromium --version && chromedriver --version

# Comando de inicio
CMD ["bash", "build.sh"]