import { useCallback, useEffect, useState } from 'react'
import { useSesion } from '../../state/sesion'
import {
  Barra, BuscadorProductos, Error_, Escaner, Exito, FilaProducto, Numerico, Vacio,
} from '../../components/ui'
import {
  alertas as pedirAlertas, aprobarConteo, conteosPendientes, crearProducto, desactivarProducto,
  eliminarProducto, historial, listarCatalogos, mensajeDeError, panel as pedirPanel, supabase,
} from '../../lib/api'
import { encolar, sincronizar } from '../../lib/offline'
import type { Alerta, Panel, Producto } from '../../lib/tipos'

type Seccion = 'panel' | 'inventario' | 'entrada' | 'conteos' | 'obras' | 'historial' | 'nuevo'

const SECCIONES: [Seccion, string, string][] = [
  ['panel', 'Panel', 'tile-azul'],
  ['inventario', 'Inventario', 'tile-gris'],
  ['entrada', 'Registrar entrada', 'tile-azul-claro'],
  ['conteos', 'Conteos por aprobar', 'tile-gris-claro'],
  ['obras', 'Obras', 'tile-azul-oscuro'],
  ['historial', 'Historial', 'tile-slate'],
  ['nuevo', 'Nuevo producto', 'tile-verde'],
]

export function AppAdmin() {
  const [seccion, setSeccion] = useState<Seccion>('panel')
  const { salir } = useSesion()

  return (
    <div className="pantalla">
      <Barra accion={<button className="btn" style={{ minHeight: 40, padding: '0 14px' }} onClick={() => void salir()}>Salir</button>} />
      <div className="disposicion">
        <nav className="rail">
          {SECCIONES.map(([s, t, color]) => (
            <a key={s} href="#" className={`${color} ${seccion === s ? 'activo' : ''}`}
               onClick={e => { e.preventDefault(); setSeccion(s) }}>{t}</a>
          ))}
        </nav>
        <div className="cuerpo">
          {seccion === 'panel' && <PanelPrincipal ir={setSeccion} />}
          {seccion === 'inventario' && <Inventario />}
          {seccion === 'entrada' && <Entrada />}
          {seccion === 'conteos' && <Conteos />}
          {seccion === 'obras' && <Obras />}
          {seccion === 'historial' && <Historial />}
          {seccion === 'nuevo' && <NuevoProducto onListo={() => setSeccion('inventario')} />}
        </div>
      </div>
    </div>
  )
}

/* ---------------- Panel ---------------- */

function PanelPrincipal({ ir }: { ir: (s: Seccion) => void }) {
  const [datos, setDatos] = useState<Panel | null>(null)
  const [avisos, setAvisos] = useState<Alerta[]>([])
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    Promise.all([pedirPanel(), pedirAlertas()])
      .then(([p, a]) => { setDatos(p); setAvisos(a) })
      .catch(e => setError(mensajeDeError(e)))
  }, [])

  return (
    <div>
      <h1 style={{ marginBottom: 18 }}>Bodega principal</h1>
      <Error_>{error}</Error_>

      {datos && (
        <>
          <div className="metricas">
            <div className="metrica"><b>{datos.total_productos}</b><span>productos activos</span></div>
            <div className="metrica"><b>{Math.round(datos.total_unidades)}</b><span>unidades en total</span></div>
            <div className={`metrica ${datos.stock_bajo ? 'alerta' : ''}`}><b>{datos.stock_bajo}</b><span>con stock bajo</span></div>
            <div className={`metrica ${datos.agotados ? 'critica' : ''}`}><b>{datos.agotados}</b><span>agotados</span></div>
            <div className="metrica"><b>{Math.round(datos.unidades_en_obra)}</b><span>unidades en obra</span></div>
            <div className="metrica"><b>{datos.salidas_hoy}</b><span>salidas hoy</span></div>
            <div className="metrica"><b>{datos.devoluciones_hoy}</b><span>devoluciones hoy</span></div>
            <div className={`metrica ${datos.conteos_pendientes ? 'alerta' : ''}`}>
              <b>{datos.conteos_pendientes}</b><span>conteos por aprobar</span>
            </div>
          </div>

          <div className="rejilla tres" style={{ marginBottom: 22 }}>
            <button className="btn enorme tile-verde" onClick={() => ir('nuevo')}>Agregar producto</button>
            <button className="btn enorme tile-azul" onClick={() => ir('entrada')}>Registrar entrada</button>
            <button className="btn enorme tile-azul-claro" onClick={() => ir('conteos')}>Revisar conteos</button>
          </div>
        </>
      )}

      <h2 style={{ marginBottom: 10 }}>Alertas</h2>
      {avisos.length === 0
        ? <Vacio titulo="Sin alertas">Todo en orden en la bodega.</Vacio>
        : avisos.slice(0, 40).map((a, i) => (
          <div key={i} className="tarjeta">
            <b>{a.nombre}</b>
            <div style={{ color: 'var(--texto-tenue)', fontSize: 15 }}>
              {a.detalle}{a.tipo === 'REQUIERE_REVISION' && <span className="etiqueta rev" style={{ marginLeft: 8 }}>revisar</span>}
            </div>
          </div>
        ))}
    </div>
  )
}

/* ---------------- Inventario y administración de productos ---------------- */

function Inventario() {
  const { productos, refrescar } = useSesion()
  const [sel, setSel] = useState<Producto | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [ok, setOk] = useState<string | null>(null)

  async function desactivar(p: Producto) {
    setError(null); setOk(null)
    try {
      await desactivarProducto(p.id, 'Desactivado desde la Tablet 1')
      setOk(`${p.nombre} quedó desactivado. Su historial se conserva.`)
      setSel(null); await refrescar()
    } catch (e) { setError(mensajeDeError(e)) }
  }

  async function borrar(p: Producto) {
    setError(null); setOk(null)
    try {
      await eliminarProducto(p.id)
      setOk(`${p.nombre} se eliminó. No tenía movimientos registrados.`)
      setSel(null); await refrescar()
    } catch (e) {
      setError(mensajeDeError(e))
    }
  }

  if (sel) {
    return (
      <div>
        <h1 style={{ marginBottom: 14 }}>{sel.nombre}</h1>
        <Error_>{error}</Error_>
        <div className="tarjeta">
          <table className="tabla">
            <tbody>
              <tr><td>Disponible</td><td className="num"><b>{sel.disponible}</b> {sel.unidad}</td></tr>
              <tr><td>En obra</td><td className="num">{sel.en_obra}</td></tr>
              <tr><td>Stock mínimo</td><td className="num">{sel.stock_minimo}</td></tr>
              <tr><td>Categoría</td><td className="num">{sel.categoria ?? '—'}</td></tr>
              <tr><td>SKU</td><td className="num">{sel.sku ?? '—'}</td></tr>
              <tr><td>Código de barras</td><td className="num">{sel.codigo_barras ?? '—'}</td></tr>
              <tr><td>Ubicación</td><td className="num">{sel.ubicacion ?? '—'}</td></tr>
              <tr><td>Estado</td><td className="num">{sel.estado}</td></tr>
            </tbody>
          </table>
        </div>
        {sel.requiere_revision && (
          <div className="mensaje error" style={{ marginTop: 14 }}>
            Este artículo vino del cuaderno con datos incompletos. Verifica la cantidad y corrígela con un conteo.
          </div>
        )}
        <div style={{ display: 'flex', gap: 10, marginTop: 16, flexWrap: 'wrap' }}>
          <button className="btn" onClick={() => setSel(null)}>Volver</button>
          <button className="btn" onClick={() => void desactivar(sel)}>Desactivar</button>
          <button className="btn peligro" onClick={() => void borrar(sel)}>Eliminar</button>
        </div>
        <p style={{ color: 'var(--texto-tenue)', fontSize: 14 }}>
          Eliminar solo funciona si el producto nunca tuvo movimientos. Si ya tiene historial, el sistema
          lo impide y hay que desactivarlo.
        </p>
      </div>
    )
  }

  return (
    <div>
      <h1 style={{ marginBottom: 14 }}>Inventario</h1>
      <Exito>{ok}</Exito>
      <Error_>{error}</Error_>
      <p style={{ color: 'var(--texto-tenue)', marginTop: 0 }}>
        {productos.length} artículos · {productos.filter(p => p.requiere_revision).length} por revisar
      </p>
      <InventarioPorCategoria productos={productos} onElegir={setSel} />
    </div>
  )
}

const ORDEN_CATEGORIAS = ['Herramientas', 'Equipos', 'Máquinas', 'Materiales', 'Seguridad', 'Consumibles']

function InventarioPorCategoria({ productos, onElegir }: { productos: Producto[]; onElegir: (p: Producto) => void }) {
  const [q, setQ] = useState('')
  const norm = (s: string) => s.toLowerCase().normalize('NFD').replace(/\p{Diacritic}/gu, '')
  const filtrados = q.trim()
    ? productos.filter(p => norm(p.nombre).includes(norm(q)) || (p.sku ?? '').toLowerCase().includes(q.toLowerCase()))
    : productos

  const grupos = new Map<string, Producto[]>()
  for (const p of filtrados) {
    const cat = p.categoria ?? 'Sin categoría'
    if (!grupos.has(cat)) grupos.set(cat, [])
    grupos.get(cat)!.push(p)
  }
  const categorias = [...grupos.keys()].sort((a, b) => {
    const ia = ORDEN_CATEGORIAS.indexOf(a); const ib = ORDEN_CATEGORIAS.indexOf(b)
    if (ia === -1 && ib === -1) return a.localeCompare(b)
    if (ia === -1) return 1
    if (ib === -1) return -1
    return ia - ib
  })

  return (
    <>
      <label className="campo">
        <input placeholder="Buscar por nombre o código" value={q} onChange={e => setQ(e.target.value)} />
      </label>
      {filtrados.length === 0
        ? <Vacio titulo="Nada con ese nombre">Prueba con una palabra más corta.</Vacio>
        : categorias.map(cat => (
          <div key={cat}>
            <div className="cat-cabecera">
              {cat}
              <span className="cuenta">{grupos.get(cat)!.length}</span>
            </div>
            {grupos.get(cat)!.map(p => <FilaProducto key={p.id} p={p} onClick={() => onElegir(p)} />)}
          </div>
        ))}
    </>
  )
}

/* ---------------- Entrada de mercancía ---------------- */

function Entrada() {
  const { dispositivoId, refrescar } = useSesion()
  const [prod, setProd] = useState<Producto | null>(null)
  const [cantidad, setCantidad] = useState('1')
  const [escaneando, setEscaneando] = useState(false)
  const [ok, setOk] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const { productos } = useSesion()

  async function confirmar() {
    if (!prod || !Number(cantidad)) return
    setError(null)
    try {
      await encolar({
        tipo: 'ENTRADA', producto_id: prod.id, producto_nombre: prod.nombre,
        cantidad: Number(cantidad), dispositivo_id: dispositivoId, nota: 'Entrada desde bodega',
      })
      await sincronizar()
      setOk(`${prod.nombre}: ${prod.disponible} → ${prod.disponible + Number(cantidad)}`)
      setProd(null); setCantidad('1')
      await refrescar()
    } catch (e) { setError(mensajeDeError(e)) }
  }

  return (
    <div>
      <h1 style={{ marginBottom: 14 }}>Registrar entrada</h1>
      <Exito>{ok}</Exito>
      <Error_>{error}</Error_>
      {!prod
        ? escaneando
          ? <Escaner
              onCodigo={c => {
                const h = productos.find(p => p.codigo_barras === c || p.sku === c)
                setEscaneando(false)
                if (h) setProd(h)
                else setError(`No hay ningún producto con el código ${c}. Créalo desde "Nuevo producto".`)
              }}
              onCerrar={() => setEscaneando(false)} />
          : (
            <>
              <button className="btn ancho" style={{ marginBottom: 14 }} onClick={() => setEscaneando(true)}>
                Escanear código
              </button>
              <BuscadorProductos onElegir={p => { setProd(p); setOk(null) }} />
            </>
          )
        : (
          <div style={{ maxWidth: 420 }}>
            <FilaProducto p={prod} />
            <div style={{ height: 14 }} />
            <Numerico valor={cantidad} onCambio={setCantidad} etiqueta={`entran · hay ${prod.disponible}`} />
            <div style={{ display: 'flex', gap: 10, marginTop: 16 }}>
              <button className="btn" onClick={() => setProd(null)}>Atrás</button>
              <button className="btn principal ancho" onClick={() => void confirmar()}>Confirmar entrada</button>
            </div>
          </div>
        )}
    </div>
  )
}

/* ---------------- Conteos por aprobar ---------------- */

function Conteos() {
  const { refrescar } = useSesion()
  const [lista, setLista] = useState<Awaited<ReturnType<typeof conteosPendientes>>>([])
  const [error, setError] = useState<string | null>(null)
  const [ok, setOk] = useState<string | null>(null)

  const cargar = useCallback(() => {
    conteosPendientes().then(setLista).catch(e => setError(mensajeDeError(e)))
  }, [])
  useEffect(cargar, [cargar])

  async function aprobar(id: string) {
    setError(null)
    try {
      await aprobarConteo(id)
      setOk('Ajuste aplicado. El movimiento quedó en el historial.')
      cargar(); await refrescar()
    } catch (e) { setError(mensajeDeError(e)) }
  }

  return (
    <div>
      <h1 style={{ marginBottom: 14 }}>Conteos por aprobar</h1>
      <Exito>{ok}</Exito>
      <Error_>{error}</Error_>
      {lista.length === 0
        ? <Vacio titulo="No hay conteos pendientes">Cuando un operario cuente y no cuadre, aparece aquí.</Vacio>
        : lista.map(c => (
          <div key={c.id} className="tarjeta">
            <b>{new Date(c.created_at).toLocaleString('es-PA')}</b>
            <table className="tabla" style={{ marginTop: 10 }}>
              <thead>
                <tr><th>Producto</th><th style={{ textAlign: 'right' }}>Sistema</th>
                    <th style={{ textAlign: 'right' }}>Contado</th><th style={{ textAlign: 'right' }}>Diferencia</th></tr>
              </thead>
              <tbody>
                {c.conteo_items.map(i => (
                  <tr key={i.producto_id}>
                    <td>{i.productos?.nombre ?? i.producto_id}</td>
                    <td className="num">{i.cantidad_sistema}</td>
                    <td className="num">{i.cantidad_contada}</td>
                    <td className="num" style={{ color: i.diferencia === 0 ? 'var(--ok)' : 'var(--aviso)' }}>
                      {i.diferencia > 0 ? '+' : ''}{i.diferencia}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
            <button className="btn principal" style={{ marginTop: 12 }} onClick={() => void aprobar(c.id)}>
              Aprobar ajuste
            </button>
          </div>
        ))}
    </div>
  )
}

/* ---------------- Obras ---------------- */

function Obras() {
  const { obras, refrescar } = useSesion()
  const [nombre, setNombre] = useState('')
  const [codigo, setCodigo] = useState('')
  const [cliente, setCliente] = useState('')
  const [error, setError] = useState<string | null>(null)

  async function crear() {
    setError(null)
    const { error } = await supabase.from('obras').insert({
      nombre: nombre.trim(), codigo: codigo.trim() || null, cliente: cliente.trim() || null,
    })
    if (error) return setError(mensajeDeError(error))
    setNombre(''); setCodigo(''); setCliente('')
    await refrescar()
  }

  return (
    <div style={{ maxWidth: 560 }}>
      <h1 style={{ marginBottom: 14 }}>Obras</h1>
      <Error_>{error}</Error_>
      {obras.map(o => (
        <div key={o.id} className="tarjeta">
          <b>{o.nombre}</b>
          <div style={{ color: 'var(--texto-tenue)', fontSize: 15 }}>
            {[o.codigo, o.cliente].filter(Boolean).join(' · ') || 'Sin código ni cliente'}
          </div>
        </div>
      ))}
      <h2 style={{ margin: '24px 0 12px' }}>Nueva obra</h2>
      <label className="campo"><span>Nombre</span>
        <input value={nombre} onChange={e => setNombre(e.target.value)} /></label>
      <label className="campo"><span>Código (opcional)</span>
        <input value={codigo} onChange={e => setCodigo(e.target.value)} /></label>
      <label className="campo"><span>Cliente (opcional)</span>
        <input value={cliente} onChange={e => setCliente(e.target.value)} /></label>
      <button className="btn principal ancho" disabled={!nombre.trim()} onClick={() => void crear()}>
        Crear obra
      </button>
    </div>
  )
}

/* ---------------- Historial ---------------- */

const ETIQUETA: Record<string, string> = {
  ENTRADA: 'Entrada', SALIDA: 'Salida', DEVOLUCION: 'Devolución', AJUSTE: 'Ajuste',
  CONTEO: 'Conteo', DESACTIVACION: 'Desactivación', CREACION: 'Creación',
}

function Historial() {
  const [filas, setFilas] = useState<Awaited<ReturnType<typeof historial>>>([])
  const [error, setError] = useState<string | null>(null)
  useEffect(() => { historial(80).then(setFilas).catch(e => setError(mensajeDeError(e))) }, [])

  return (
    <div>
      <h1 style={{ marginBottom: 14 }}>Historial</h1>
      <Error_>{error}</Error_>
      {filas.length === 0
        ? <Vacio titulo="Sin movimientos todavía">Cada entrada, salida y devolución aparecerá aquí.</Vacio>
        : (
          <table className="tabla">
            <thead>
              <tr><th>Fecha</th><th>Tipo</th><th>Producto</th><th>Obra</th><th>Quién</th>
                  <th style={{ textAlign: 'right' }}>Cant.</th><th style={{ textAlign: 'right' }}>Stock</th></tr>
            </thead>
            <tbody>
              {filas.map(m => (
                <tr key={m.id}>
                  <td>{new Date(m.created_at).toLocaleString('es-PA')}</td>
                  <td>{ETIQUETA[m.tipo] ?? m.tipo}</td>
                  <td>{m.productos?.nombre ?? '—'}</td>
                  <td>{m.obras?.nombre ?? '—'}</td>
                  <td>{m.perfiles?.nombre ?? '—'}</td>
                  <td className="num">{m.delta > 0 ? '+' : ''}{m.delta}</td>
                  <td className="num">{m.stock_anterior} → {m.stock_posterior}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
    </div>
  )
}

/* ---------------- Alta rápida de producto ---------------- */

function NuevoProducto({ onListo }: { onListo: () => void }) {
  const { refrescar } = useSesion()
  const [cat, setCat] = useState<string[]>([])
  const [uni, setUni] = useState<{ codigo: string; nombre: string }[]>([])
  const [f, setF] = useState({
    nombre: '', categoria: '', unidad: 'UND', sku: '', codigo_barras: '',
    stock_minimo: '', descripcion: '',
  })
  const [escaneando, setEscaneando] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [ok, setOk] = useState<string | null>(null)

  useEffect(() => {
    listarCatalogos().then(c => {
      setCat(c.categorias); setUni(c.unidades)
      setF(v => ({ ...v, categoria: c.categorias[0] ?? '' }))
    }).catch(e => setError(mensajeDeError(e)))
  }, [])

  async function guardar() {
    setError(null)
    try {
      await crearProducto({
        nombre: f.nombre.trim(), categoria: f.categoria, unidad: f.unidad,
        sku: f.sku.trim(), codigo_barras: f.codigo_barras.trim(),
        stock_minimo: f.stock_minimo ? Number(f.stock_minimo) : 0,
        descripcion: f.descripcion.trim(),
      })
      setOk(`${f.nombre} creado con stock 0. Regístrale una entrada para cargar la cantidad.`)
      await refrescar()
      setTimeout(onListo, 1400)
    } catch (e) { setError(mensajeDeError(e)) }
  }

  if (escaneando) {
    return <div style={{ maxWidth: 480 }}>
      <h1 style={{ marginBottom: 14 }}>Código de barras</h1>
      <Escaner onCodigo={c => { setF(v => ({ ...v, codigo_barras: c })); setEscaneando(false) }}
               onCerrar={() => setEscaneando(false)} />
    </div>
  }

  return (
    <div style={{ maxWidth: 560 }}>
      <h1 style={{ marginBottom: 6 }}>Nuevo producto</h1>
      <p style={{ color: 'var(--texto-tenue)', marginTop: 0 }}>
        Solo el nombre es obligatorio. Lo demás se puede completar después.
      </p>
      <Exito>{ok}</Exito>
      <Error_>{error}</Error_>

      <label className="campo"><span>Nombre</span>
        <input autoFocus value={f.nombre} onChange={e => setF({ ...f, nombre: e.target.value })} /></label>

      <label className="campo"><span>Categoría</span>
        <select value={f.categoria} onChange={e => setF({ ...f, categoria: e.target.value })}>
          {cat.map(c => <option key={c} value={c}>{c}</option>)}
        </select></label>

      <label className="campo"><span>Unidad</span>
        <select value={f.unidad} onChange={e => setF({ ...f, unidad: e.target.value })}>
          {uni.map(u => <option key={u.codigo} value={u.codigo}>{u.nombre}</option>)}
        </select></label>

      <label className="campo"><span>Código de barras</span>
        <div style={{ display: 'flex', gap: 10 }}>
          <input value={f.codigo_barras} onChange={e => setF({ ...f, codigo_barras: e.target.value })} />
          <button className="btn" onClick={() => setEscaneando(true)}>Escanear</button>
        </div></label>

      <label className="campo"><span>SKU (opcional)</span>
        <input value={f.sku} onChange={e => setF({ ...f, sku: e.target.value })} /></label>

      <label className="campo"><span>Stock mínimo (opcional)</span>
        <input inputMode="numeric" value={f.stock_minimo}
               onChange={e => setF({ ...f, stock_minimo: e.target.value })} /></label>

      <label className="campo"><span>Descripción (opcional)</span>
        <textarea value={f.descripcion} onChange={e => setF({ ...f, descripcion: e.target.value })} /></label>

      <button className="btn principal ancho" disabled={!f.nombre.trim()} onClick={() => void guardar()}>
        Guardar producto
      </button>
    </div>
  )
}
