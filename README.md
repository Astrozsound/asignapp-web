# ASIGNAPP — Inventario de bodega

App para las tres tablets de Constructora HYCE. Una sola base de código: la interfaz
cambia según el rol de quien entra.

Compila en verde (`npm run build`). El proyecto Android está generado y listo en
`android/`; para obtener el APK, ver `GUIA_APK.md` — este entorno no puede compilarlo
porque tiene bloqueados los repositorios de Android.

## Qué hace

**Tablet 1 (bodega, ADMIN o SUPERVISOR).** Panel con productos activos, unidades,
stock bajo, agotados, unidades en obra, salidas y devoluciones del día, y conteos por
aprobar. Inventario buscable con la ficha de cada producto, desactivación y borrado —
con la regla de que un producto con historial no se puede borrar, solo desactivar.
Registro de entradas, aprobación de conteos, alta de obras, alta rápida de productos
e historial completo con quién, cuándo, desde qué tablet y el stock antes y después.

**Tablets 2 y 3 (operarios).** Una pantalla, cinco botones grandes. Sacar (escanear →
cantidad → obra → confirmar), devolver (con estado: bueno, dañado o requiere
mantenimiento), contar, buscar y ver lo que registró. Nada de crear, borrar ni
modificar stock a mano.

## Decisiones que vale la pena conocer

**Funciona sin red.** El container pierde Wi-Fi, así que la app guarda el catálogo en
IndexedDB y encola los movimientos que se hagan sin conexión. Cada movimiento nace con
un identificador propio que el servidor usa como llave de idempotencia: reintentar
nunca duplica stock, ni aunque la respuesta se pierda a medio camino. La barra superior
dice siempre en cuál de los tres estados está: en línea, sin red, o sincronizando.

**La tablet no decide el stock.** Toda escritura pasa por la función
`registrar_movimiento` del servidor, que bloquea la fila de inventario. Dos tablets
sacando a la vez se serializan; es imposible que una pise a la otra.

**El rol vive en el servidor.** La interfaz esconde lo que un operario no debe usar,
pero eso es comodidad, no seguridad: el backend rechaza igual la operación.

**Sin fuentes descargadas.** La app usa la tipografía del sistema Android. Una app que
tiene que abrir sin red no puede depender de que baje una fuente.

## Ejecutar en desarrollo

```bash
npm install
cp .env.example .env.local     # rellena URL y clave anon de Supabase
npm run dev                    # http://localhost:5173
```

Para probar desde una tablet en la misma red, `npm run dev` ya escucha en toda la red
local; usa la IP de tu máquina. El escáner necesita HTTPS o `localhost`, así que en
red local conviene `npm run build && npm run preview` detrás de un túnel HTTPS.

## Estructura

```
src/
  lib/api.ts          Cliente de Supabase y llamadas al servidor
  lib/offline.ts      Caché en IndexedDB, cola de movimientos y sincronización
  lib/tipos.ts        Tipos que reflejan el esquema de la base
  state/sesion.tsx    Sesión, rol, dispositivo y estado de conexión
  components/ui.tsx   Barra, escáner, teclado numérico, buscador
  screens/Acceso.tsx  Entrar y elegir cuál tablet es
  screens/admin/      Interfaz de la Tablet 1
  screens/operario/   Interfaz de las Tablets 2 y 3
public/               Manifiesto PWA, service worker e iconos
android/              Proyecto Capacitor (permisos de cámara ya configurados)
.github/workflows/    CI que compila el APK
```

## Lo que falta para cerrar el MVP

- Editar la ficha de un producto ya creado (hoy se crea y se desactiva; para corregir
  nombre o categoría todavía hay que ir a la base).
- Gestión de operarios desde la Tablet 1 (hoy se crean en Supabase Auth).
- Conteo de varios productos en una sola sesión; ahora va de uno en uno.
- Firma de entrega y foto de la herramienta al salir — estaba en fase futura y ahí sigue.
