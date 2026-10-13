# --- FASE 1: BASE ---
FROM node:26.11.1-alpine3.24 AS base
WORKDIR /app
RUN npm install -g npm@12.2.0

# --- FASE 2: DESARROLLO (dev) ---
FROM base AS dev
CMD ["sh", "-c", "if [ -f package.json ]; then if [ ! -d node_modules ]; then npm install; fi && npm start -- --host 0.0.0.0 --poll 2000; else echo 'Proyecto no inicializado. Manteniendo contenedor vivo...' && tail -f /dev/null; fi"]

# --- FASE 3: CONSTRUCCIÓN (build) ---
FROM base AS build
COPY ./volume/app/src .
RUN if [ -f package.json ]; then \
    npm install && npm run build && \
    INDEX_DIR=$(find dist -name "index.html" -exec dirname {} \; | head -n 1) && \
    if [ -n "$INDEX_DIR" ] && [ "$INDEX_DIR" != "dist" ]; then mkdir -p /app/dist-ready && cp -r "$INDEX_DIR"/. /app/dist-ready/ && rm -rf dist && mv /app/dist-ready dist; fi; \
else \
    mkdir -p dist && printf '<!DOCTYPE html><html><head><title>Plantilla Angular</title></head><body><h1>Plantilla Angular</h1></body></html>' > dist/index.html; \
fi

# --- FASE 4: PRODUCCIÓN (prod) ---
FROM caddy:2-alpine AS prod
COPY --from=build /app/dist /var/www/html
RUN printf ":80 {\n    root * /var/www/html\n    encode gzip zstd\n    try_files {path} /index.html\n    file_server\n}\n" > /etc/caddy/Caddyfile
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile"]