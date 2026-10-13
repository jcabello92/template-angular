# Plantilla Docker - Angular (Frontend Web)

Plantilla Docker para Frontend Web optimizada para **Angular + TypeScript + Tailwind CSS**.

## Arquitectura

* **Desarrollo**:
  * **app**: Node.js 26 (Alpine) ejecutando Angular CLI Dev Server (`--host 0.0.0.0:4200`) con soporte de live-reload (`--poll 2000`).
  * **caddy**: Proxy inverso local escuchando en el puerto 80 y reenviando el tráfico hacia `app:4200`.
* **Producción**:
  * Multi-stage build que compila los estáticos (`npm run build`), resuelve automáticamente el directorio de salida (compatible con Angular moderno) y sirve los bundles a través de Caddy con compresión (`gzip`, `zstd`) y fallback SPA (`try_files {path} /index.html`).

## Requisitos previos

Crear la red externa de Docker definida en `.env` (si aún no existe):

```bash
docker network create template-network
```

## Uso en desarrollo

1. Iniciar los contenedores:

   ```bash
   docker compose up -d
   ```

2. Inicializar el proyecto de Angular en `./volume/app/src/`:

   ```bash
   docker compose exec app npx @angular/cli new app --directory . --style css --routing true --ssr false
   ```

3. Instalar Tailwind CSS:

   ```bash
   docker compose exec app npm install tailwindcss @tailwindcss/postcss postcss
   ```

   * Configurar el plugin de Tailwind en tu configuración de estilos (e.g. `@import "tailwindcss";` en `src/styles.css`).

4. Instalar dependencias e iniciar:

   ```bash
   docker compose exec app npm install
   ```

   El contenedor detectará `package.json` y levantará el servidor de desarrollo en `app:4200` automáticamente.

## Uso en producción

Construir y levantar la imagen de producción (Caddy sirviendo la build estática):

```bash
docker compose -f docker-compose.prod.yml up -d --build
```
