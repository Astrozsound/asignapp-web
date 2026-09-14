/* ============================================================
   Capa offline.

   El container pierde Wi-Fi. El operario no puede quedarse
   esperando: la salida se registra en la tablet y sube sola
   cuando vuelve la señal.

   Dos almacenes en IndexedDB:
     cache  — productos y obras, para buscar y escanear sin red
     cola   — movimientos hechos sin conexión

   Cada movimiento nace con un client_uuid. El servidor lo usa
   como llave de idempotencia, así que reintentar nunca duplica
   stock, ni aunque la respuesta se pierda a medio camino.
   ============================================================ */
import { enviarMovimiento, mensajeDeError } from './api'
import type { MovimientoPendiente, Obra, Producto } from './tipos'

const BASE = 'asignapp'
const VERSION = 1

function abrir(): Promise<IDBDatabase> {
  return new Promise((res, rej) => {
    const req = indexedDB.open(BASE, VERSION)
    req.onupgradeneeded = () => {
      const db = req.result
      if (!db.objectStoreNames.contains('cache')) db.createObjectStore('cache')
      if (!db.objectStoreNames.contains('cola')) db.createObjectStore('cola', { keyPath: 'client_uuid' })
    }
    req.onsuccess = () => res(req.result)
    req.onerror = () => rej(req.error)
  })
}

async function tx<T>(almacen: string, modo: IDBTransactionMode,
                     fn: (s: IDBObjectStore) => IDBRequest): Promise<T> {
  const db = await abrir()
  return new Promise((res, rej) => {
    const t = db.transaction(almacen, modo)
    const req = fn(t.objectStore(almacen))
    req.onsuccess = () => res(req.result as T)
    req.onerror = () => rej(req.error)
  })
}

/* ---------------- Caché de catálogo ---------------- */

export async function guardarCache(productos: Producto[], obras: Obra[]) {
  await tx('cache', 'readwrite', s => s.put(productos, 'productos'))
  await tx('cache', 'readwrite', s => s.put(obras, 'obras'))
  await tx('cache', 'readwrite', s => s.put(Date.now(), 'actualizado'))
}

export async function leerCache(): Promise<{
  productos: Producto[]; obras: Obra[]; actualizado: number | null
}> {
  const [productos, obras, actualizado] = await Promise.all([
    tx<Producto[]>('cache', 'readonly', s => s.get('productos')),
    tx<Obra[]>('cache', 'readonly', s => s.get('obras')),
    tx<number>('cache', 'readonly', s => s.get('actualizado')),
  ])
  return { productos: productos ?? [], obras: obras ?? [], actualizado: actualizado ?? null }
}

/* ---------------- Cola de movimientos ---------------- */

export async function encolar(m: Omit<MovimientoPendiente, 'client_uuid' | 'creado_en' | 'intentos'>) {
  const pendiente: MovimientoPendiente = {
    ...m, client_uuid: crypto.randomUUID(), creado_en: Date.now(), intentos: 0,
  }
  await tx('cola', 'readwrite', s => s.put(pendiente))
  return pendiente
}

export async function pendientes(): Promise<MovimientoPendiente[]> {
  const todos = await tx<MovimientoPendiente[]>('cola', 'readonly', s => s.getAll())
  return (todos ?? []).sort((a, b) => a.creado_en - b.creado_en)
}

async function quitar(client_uuid: string) {
  await tx('cola', 'readwrite', s => s.delete(client_uuid))
}

async function marcarFallo(m: MovimientoPendiente, error: string) {
  await tx('cola', 'readwrite', s => s.put({ ...m, intentos: m.intentos + 1, error }))
}

export type EstadoSync = 'conectado' | 'desconectado' | 'sincronizando'

type Escucha = (estado: EstadoSync, enCola: number) => void
const escuchas = new Set<Escucha>()
let estadoActual: EstadoSync = navigator.onLine ? 'conectado' : 'desconectado'

export function observarSync(fn: Escucha) {
  escuchas.add(fn)
  pendientes().then(p => fn(estadoActual, p.length))
  return () => { escuchas.delete(fn) }
}

async function avisar(estado: EstadoSync) {
  estadoActual = estado
  const n = (await pendientes()).length
  escuchas.forEach(fn => fn(estado, n))
}

let sincronizando = false

/** Sube todo lo pendiente. Se detiene ante un error de red; un
 *  rechazo del servidor (stock insuficiente, permiso) no bloquea
 *  al resto de la cola, se marca y se sigue. */
export async function sincronizar(): Promise<{ subidos: number; fallidos: number }> {
  if (sincronizando || !navigator.onLine) return { subidos: 0, fallidos: 0 }
  sincronizando = true
  let subidos = 0, fallidos = 0
  try {
    const cola = await pendientes()
    if (cola.length) await avisar('sincronizando')
    for (const m of cola) {
      try {
        await enviarMovimiento(m)
        await quitar(m.client_uuid)
        subidos++
      } catch (e) {
        const msg = mensajeDeError(e)
        if (/Sin conexión/.test(msg)) break
        await marcarFallo(m, msg)
        fallidos++
      }
    }
  } finally {
    sincronizando = false
    await avisar(navigator.onLine ? 'conectado' : 'desconectado')
  }
  return { subidos, fallidos }
}

/** Descarta un movimiento que el servidor rechazó y que el
 *  encargado decidió no reintentar. */
export async function descartar(client_uuid: string) {
  await quitar(client_uuid)
  await avisar(estadoActual)
}

export function arrancarSync() {
  window.addEventListener('online', () => { void sincronizar() })
  window.addEventListener('offline', () => { void avisar('desconectado') })
  setInterval(() => { void sincronizar() }, 20000)
  void sincronizar()
}

/** Aplica el efecto del movimiento sobre la copia local, para que
 *  la pantalla muestre el stock correcto aunque no haya red. */
export function aplicarLocal(productos: Producto[], m: MovimientoPendiente): Producto[] {
  return productos.map(p => {
    if (p.id !== m.producto_id) return p
    const retornable = p.es_retornable
    if (m.tipo === 'ENTRADA') return { ...p, disponible: p.disponible + m.cantidad }
    if (m.tipo === 'SALIDA') {
      return {
        ...p,
        disponible: p.disponible - m.cantidad,
        en_obra: retornable ? p.en_obra + m.cantidad : p.en_obra,
      }
    }
    const vuelveAStock = m.estado_dev === 'BUENO'
    return {
      ...p,
      disponible: vuelveAStock ? p.disponible + m.cantidad : p.disponible,
      en_obra: retornable ? Math.max(p.en_obra - m.cantidad, 0) : p.en_obra,
    }
  })
}
