# VERSION CORTA 
# Etapa 1: Construcción
#FROM node:20-alpine AS build
#WORKDIR /app
#COPY package*.json ./
#RUN npm install
#COPY . .

# Etapa 2: Imagen final
#FROM node:20-alpine
#ORKDIR /app
#COPY --from=build /app .
#EXPOSE 3000
#CMD ["node", "index.js"]


# Dockerfile optimizado para una aplicación Node.js
# Utiliza multi-stage builds para reducir el tamaño de la imagen final
# Etapa 1: Build
FROM node:20-alpine AS build

# Establecer directorio de trabajo
WORKDIR /app

# Copiar y fijar dependencias (aprovecha caché)
COPY package*.json ./

# Instalar dependencias de producción y desarrollo
RUN npm ci

# Copiar el resto del código
COPY . .

# Etapa 2: Imagen final
FROM node:20-alpine

WORKDIR /app

# Crear usuario no-root por seguridad
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copiar solo lo necesario desde la etapa build
COPY --from=build /app .

# Instalar solo dependencias de producción
RUN npm ci --omit=dev

# Cambiar propietario de la carpeta
RUN chown -R appuser:appgroup /app

# Ejecutar como usuario no-root
USER appuser

# Exponer el puerto
EXPOSE 3000

# Agregar chequeo de salud (opcional pero recomendado)
HEALTHCHECK --interval=30s --timeout=5s \
  CMD wget --quiet --tries=1 --spider http://localhost:3000/ || exit 1

# Comando de inicio
CMD ["node", "index.js"]
