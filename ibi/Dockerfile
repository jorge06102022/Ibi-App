# ETAPA 1: Entorno de compilación con Flutter
FROM dart:3.12 AS build

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/flutter/flutter.git --branch stable /flutter
ENV PATH="/flutter/bin:$PATH"
RUN flutter config --no-analytics && flutter precache

WORKDIR /app

# Copiar el código fuente y compilar la app para Web
COPY . .

RUN flutter pub get
RUN flutter build web --release

# ETAPA 2: Servidor liviano de producción (Nginx)
FROM nginx:alpine

# Copiar el resultado de la compilación de Flutter al servidor Nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# Exponer el puerto predeterminado
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
