# Cómo obtener el APK y montar las 3 tablets

**El APK no se pudo compilar aquí.** Este entorno tiene la red restringida y los
repositorios que necesita una compilación Android están bloqueados: `dl.google.com`
(SDK de Android), `maven.google.com` y `repo1.maven.org` (librerías AndroidX),
`services.gradle.org` (Gradle). Todos responden 403.

Lo que sí queda hecho y probado: la app compila (`npm run build` en verde), el
proyecto Android de Capacitor está generado en `android/` con los permisos de
cámara ya configurados, y hay un flujo de CI que produce el APK sin que instales
nada. Faltan solo los minutos de máquina que este entorno no puede dar.

Tres caminos, de menos a más trabajo.

---

## Camino 1 — GitHub Actions (recomendado, no instalas nada)

1. Sube esta carpeta a un repositorio de GitHub.
2. En **Settings → Secrets and variables → Actions**, crea dos secretos:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
3. Entra en la pestaña **Actions**, elige «APK de ASIGNAPP» y pulsa **Run workflow**.
4. A los ~5 minutos, descarga `asignapp-debug-apk` desde los *Artifacts* de esa ejecución.

El flujo ya está escrito en `.github/workflows/apk.yml`.

## Camino 2 — Tu MacBook con Android Studio

```bash
npm install
cp .env.example .env.local     # y rellena las dos variables
npm run cap:sync               # compila la web y la copia al proyecto Android
npm run apk:debug              # el APK sale en android/app/build/outputs/apk/debug/
```

Necesitas Android Studio (o el SDK de línea de comandos) y JDK 21. La primera
compilación descarga Gradle y las librerías; las siguientes son rápidas.

## Camino 3 — Sin APK: instalar la PWA en las tablets

Para tres tablets esto es lo más práctico, y es lo que recomiendo para arrancar.

1. Publica la web (`npm run build` y sube `dist/` a Vercel, Netlify o el hosting que uses).
2. En cada tablet, abre la URL en Chrome.
3. Menú ⋮ → **Añadir a pantalla de inicio**.

Queda un icono en el launcher, abre a pantalla completa sin barra del navegador,
funciona sin red y se actualiza sola cuando publicas una versión nueva — sin volver
a instalar nada en las tres tablets. La cámara para escanear funciona igual, siempre
que sirvas la web por HTTPS.

---

## Antes de nada: preparar Supabase

1. Crea un proyecto en supabase.com.
2. En el **SQL Editor**, ejecuta en orden los archivos de la carpeta `db/` del
   entregable anterior: `001_schema.sql`, `002_rpc.sql`, `003_rls.sql`, `004_seed.sql`.
   (No ejecutes el `000`, que solo sirve para pruebas locales.)
3. En **Authentication → Users**, crea los tres usuarios: el de bodega y los dos operarios.
4. En el SQL Editor, dales su rol — el rol vive en el servidor, nunca en la tablet:

```sql
insert into perfiles (id, nombre, rol) values
  ('<uuid-del-usuario-bodega>',   'Encargado de bodega', 'ADMIN'),
  ('<uuid-del-operario-a>',       'Juan',                'OPERARIO'),
  ('<uuid-del-operario-b>',       'Luis',                'OPERARIO');
```

5. Ejecuta `005_import.sql` para cargar los 128 artículos del inventario real.
6. Copia la URL del proyecto y la clave `anon` a `.env.local`.

## Puesta en marcha de cada tablet

Al abrir la app por primera vez, cada tablet pide dos cosas: el usuario y **cuál
tablet es** (DEVICE-001 bodega, DEVICE-002 y DEVICE-003 operarios). Se elige una
sola vez y queda guardada; desde ahí, cada movimiento registra desde qué tablet se
hizo.

La interfaz cambia sola según el rol: el ADMIN ve el panel completo, el OPERARIO ve
la pantalla de botones grandes. Y aunque alguien manipulara la tablet, el servidor
rechaza igual lo que ese rol no puede hacer — eso ya está probado en la suite.

## Qué revisar el primer día

- Escanea tres o cuatro artículos y comprueba que los códigos de barras reales
  coinciden. El cuaderno no traía códigos, así que hay que irlos capturando desde
  «Nuevo producto» o editando cada ficha.
- Corta el Wi-Fi de una tablet a propósito, registra una salida y vuelve a
  conectarla: debe subir sola y el stock no debe descuadrar.
- Revisa los 58 artículos marcados «revisar» con un conteo físico.
