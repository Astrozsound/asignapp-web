/* ASIGNAPP — service worker.
   Cachea el armazón de la app para que abra sin red en el container.
   Las llamadas al servidor nunca se cachean: el stock siempre se pide
   en vivo, y si no hay red la app usa su copia en IndexedDB.
   El HTML (el "cascarón") se pide en vivo primero para enterarse de
   una versión nueva de inmediato; solo cae al caché si no hay red.
   Los archivos con hash (JS/CSS) sí son cache-first: su nombre cambia
   solo cuando cambia su contenido, así que nunca quedan viejos. */
const CACHE = 'asignapp-v2'
const RAIZ = self.registration.scope

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll([
    RAIZ, RAIZ + 'index.html', RAIZ + 'manifest.webmanifest', RAIZ + 'icono.svg',
  ])))
  self.skipWaiting()
})

self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))))
  self.clients.claim()
})

self.addEventListener('fetch', e => {
  const url = new URL(e.request.url)
  if (e.request.method !== 'GET') return
  if (url.pathname.startsWith('/rest/') || url.pathname.startsWith('/auth/')) return
  if (url.origin !== self.location.origin) return

  if (e.request.mode === 'navigate') {
    e.respondWith(
      fetch(e.request).then(res => {
        const copia = res.clone()
        caches.open(CACHE).then(c => c.put(e.request, copia))
        return res
      }).catch(() => caches.match(e.request).then(hit => hit || caches.match(RAIZ + 'index.html')))
    )
    return
  }

  e.respondWith(
    caches.match(e.request).then(hit =>
      hit || fetch(e.request).then(res => {
        const copia = res.clone()
        caches.open(CACHE).then(c => c.put(e.request, copia))
        return res
      }).catch(() => caches.match(RAIZ + 'index.html'))
    )
  )
})
