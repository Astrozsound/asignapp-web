import { useEffect, useRef, useState, type ReactNode } from 'react'
import { useSesion } from '../state/sesion'
import type { Producto } from '../lib/tipos'

/* ---------------- Barra superior ---------------- */

export function Barra({ titulo, accion }: { titulo?: string; accion?: ReactNode }) {
  const { dispositivoNombre } = useSesion()
  return (
    <>
      <header className="barra">
        <div className="marca">ASIGN<span>APP</span></div>
        {titulo && <h3>{titulo}</h3>}
        <div className="crece" />
        {dispositivoNombre && <span style={{ fontSize: 13, color: 'var(--texto-tenue)' }}>{dispositivoNombre}</span>}
        <Conexion />
        {accion}
      </header>
      <AvisoOffline />
    </>
  )
}

export function Conexion() {
  const { estado, enCola } = useSesion()
  const texto = estado === 'sincronizando'
    ? `Sincronizando ${enCola}`
    : estado === 'desconectado'
      ? (enCola ? `Sin red · ${enCola} en espera` : 'Sin red')
      : 'En línea'
  return (
    <div className={`estado ${estado === 'desconectado' ? 'desconectado' : estado === 'sincronizando' ? 'sincronizando' : ''}`}>
      <i className="punto" />{texto}
    </div>
  )
}

function AvisoOffline() {
  const { estado, enCola } = useSesion()
  if (estado !== 'desconectado') return null
  return (
    <div className="franja aviso-offline">
      <span className="interior">
        Trabajando sin red. {enCola ? `${enCola} movimiento(s) se subirán solos.` : 'Los movimientos se guardan en la tablet.'}
      </span>
    </div>
  )
}

/* ---------------- Mensajes ---------------- */

export function Error_({ children }: { children: ReactNode }) {
  if (!children) return null
  return <div className="mensaje error">{children}</div>
}

export function Exito({ children }: { children: ReactNode }) {
  if (!children) return null
  return <div className="mensaje exito">{children}</div>
}

export function Vacio({ titulo, children }: { titulo: string; children?: ReactNode }) {
  return <div className="vacio"><b>{titulo}</b>{children}</div>
}

/* ---------------- Escáner de código de barras ---------------- */

export function Escaner({ onCodigo, onCerrar }: { onCodigo: (c: string) => void; onCerrar?: () => void }) {
  const video = useRef<HTMLVideoElement>(null)
  const [error, setError] = useState<string | null>(null)
  const [manual, setManual] = useState('')

  useEffect(() => {
    let controles: { stop: () => void } | undefined
    let vivo = true
    // El lector pesa: se descarga solo al abrir la cámara, no al arrancar la app.
    import('@zxing/browser')
      .then(({ BrowserMultiFormatReader }) => {
        if (!vivo) return
        const lector = new BrowserMultiFormatReader()
        return lector.decodeFromVideoDevice(undefined, video.current ?? undefined, (res) => {
          if (res && vivo) { onCodigo(res.getText()); controles?.stop() }
        }).then(c => { controles = c })
      })
      .catch(() => setError('No se pudo abrir la cámara. Escribe el código a mano.'))
    return () => { vivo = false; controles?.stop() }
  }, [onCodigo])

  return (
    <div>
      {error
        ? <div className="mensaje error">{error}</div>
        : (
          <div className="escaner">
            <video ref={video} muted playsInline />
            <div className="mira" />
          </div>
        )}
      <div style={{ display: 'flex', gap: 10, marginTop: 14 }}>
        <input
          className="campo-suelto"
          style={{
            flex: 1, minHeight: 64, padding: '0 14px', background: 'var(--superficie)',
            color: 'var(--texto)', border: '1px solid var(--borde)', borderRadius: 4, fontSize: 18,
          }}
          inputMode="numeric" placeholder="o escribe el código"
          value={manual} onChange={e => setManual(e.target.value)}
        />
        <button className="btn principal" disabled={!manual.trim()} onClick={() => onCodigo(manual.trim())}>
          Buscar
        </button>
      </div>
      {onCerrar && <button className="btn ancho" style={{ marginTop: 10 }} onClick={onCerrar}>Cancelar</button>}
    </div>
  )
}

/* ---------------- Teclado numérico ---------------- */

export function Numerico({ valor, onCambio, etiqueta, maximo }: {
  valor: string; onCambio: (v: string) => void; etiqueta?: string; maximo?: number
}) {
  const pulsar = (t: string) => {
    if (t === '←') return onCambio(valor.slice(0, -1))
    if (t === '.' && valor.includes('.')) return
    const nuevo = valor === '0' && t !== '.' ? t : valor + t
    if (maximo !== undefined && Number(nuevo) > maximo) return
    onCambio(nuevo)
  }
  return (
    <div>
      <div className="lectura">
        {valor || '0'}
        {etiqueta && <small>{etiqueta}</small>}
      </div>
      <div className="numerico">
        {['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', '←'].map(t => (
          <button key={t} className="btn" onClick={() => pulsar(t)}>{t}</button>
        ))}
      </div>
    </div>
  )
}

/* ---------------- Buscador de productos ---------------- */

export function BuscadorProductos({ onElegir, filtro }: {
  onElegir: (p: Producto) => void
  filtro?: (p: Producto) => boolean
}) {
  const { productos } = useSesion()
  const [q, setQ] = useState('')
  const base = filtro ? productos.filter(filtro) : productos
  const norm = (s: string) => s.toLowerCase().normalize('NFD').replace(/\p{Diacritic}/gu, '')
  const lista = q.trim()
    ? base.filter(p => norm(p.nombre).includes(norm(q)) || (p.sku ?? '').toLowerCase().includes(q.toLowerCase()))
    : base

  return (
    <div>
      <label className="campo">
        <input autoFocus placeholder="Buscar por nombre o código" value={q} onChange={e => setQ(e.target.value)} />
      </label>
      {lista.length === 0
        ? <Vacio titulo="Nada con ese nombre">Prueba con una palabra más corta.</Vacio>
        : lista.slice(0, 80).map(p => <FilaProducto key={p.id} p={p} onClick={() => onElegir(p)} />)}
    </div>
  )
}

export function FilaProducto({ p, onClick }: { p: Producto; onClick?: () => void }) {
  const clase = p.disponible <= 0 ? 'agotado' : p.stock_minimo > 0 && p.disponible <= p.stock_minimo ? 'bajo' : ''
  return (
    <button className={`fila-producto ${clase}`} onClick={onClick}>
      <div>
        <div className="nombre">{p.nombre}</div>
        <div className="meta">
          {p.categoria ?? 'Sin categoría'}
          {p.sku ? ` · ${p.sku}` : ''}
          {p.en_obra > 0 ? ` · ${p.en_obra} en obra` : ''}
          {p.requiere_revision ? ' · revisar' : ''}
        </div>
      </div>
      <div className="cifra">
        <b>{p.disponible}</b>
        <div className="meta">{p.unidad ?? 'UND'}</div>
      </div>
    </button>
  )
}
