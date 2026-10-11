# --- FASE 1: BASE ---
FROM node:26.11.1-alpine3.24 AS base
WORKDIR /app
RUN npm install -g npm@12.2.0

# --- FASE 2: DESARROLLO (dev) ---
FROM base AS dev
CMD ["sh", "-c", "if [ -f package.json ]; then npm start -- --host 0.0.0.0; else echo 'Proyecto no inicializado. Manteniendo contenedor vivo...' && tail -f /dev/null; fi"]

# --- FASE 3: CONSTRUCCIÓN (build) ---
FROM base AS build
COPY ./volume/app/src .
RUN npm install
RUN npm run build

# --- FASE 4: PRODUCCIÓN (prod) ---
FROM caddy:2-alpine AS prod
COPY --from=build /app/dist /var/www/html
RUN echo -e ":80 {\n\troot * /var/www/html\n\ttry_files {path} /index.html\n\tfile_server\n}" > /etc/caddy/Caddyfile
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile"]