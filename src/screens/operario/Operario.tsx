import { useEffect, useMemo, useState } from 'react'
import { useSesion } from '../../state/sesion'
import { Barra, BuscadorProductos, Error_, Escaner, Exito, FilaProducto, Numerico, Vacio } from '../../components/ui'
import { aplicarLocal, encolar, pendientes, sincronizar } from '../../lib/offline'
import { mensajeDeError, registrarConteo } from '../../lib/api'
import type { EstadoDevolucion, MovimientoPendiente, Producto } from '../../lib/tipos'

type Vista = 'inicio' | 'sacar' | 'devolver' | 'conteo' | 'buscar' | 'movimientos'

export function AppOperario() {
  const [vista, setVista] = useState<Vista>('inicio')
  const volver = () => setVista('inicio')

  return (
    <div className="pantalla">
      <Barra />
      {vista === 'inicio' && <Inicio ir={setVista} />}
      {vista === 'sacar' && <Flujo tipo="SALIDA" volver={volver} />}
      {vista === 'devolver' && <Flujo tipo="DEVOLUCION" volver={volver} />}
      {vista === 'conteo' && <Conteo volver={volver} />}
      {vista === 'buscar' && <Consultar volver={volver} />}
      {vista === 'movimientos' && <MisMovimientos volver={volver} />}
    </div>
  )
}

function Inicio({ ir }: { ir: (v: Vista) => void }) {
  const { perfil, salir, productos } = useSesion()
  const nombre = perfil?.nombre?.split(' ')[0] ?? ''
  return (
    <>
      <div className="cuerpo">
        <h1 style={{ marginBottom: 18 }}>Hola, {nombre}</h1>
        <button className="btn principal enorme ancho" style={{ marginBottom: 12 }} onClick={() => ir('sacar')}>
          Escanear y sacar
          <span className="sub">Llevar algo a una obra</span>
        </button>
        <div className="rejilla">
          <button className="btn enorme" onClick={() => ir('devolver')}>
            Devolver<span className="sub">Regresar a bodega</span>
          </button>
          <button className="btn enorme" onClick={() => ir('conteo')}>
            Contar<span className="sub">Conteo físico</span>
          </button>
          <button className="btn enorme" onClick={() => ir('buscar')}>
            Buscar<span className="sub">{productos.length} artículos</span>
          </button>
          <button className="btn enorme" onClick={() => ir('movimientos')}>
            Mis movimientos<span className="sub">Lo que registré</span>
          </button>
        </div>
      </div>
      <div className="pie">
        <button className="btn" onClick={() => void salir()}>Salir</button>
      </div>
    </>
  )
}

/* ============================================================
   Flujo de salida y devolución.
   Cuatro pasos como máximo: producto → cantidad → obra/estado → listo.
   ============================================================ */

type Paso = 'producto' | 'cantidad' | 'destino' | 'hecho'

function Flujo({ tipo, volver }: { tipo: 'SALIDA' | 'DEVOLUCION'; volver: () => void }) {
  const { productos, obras, dispositivoId, refrescar } = useSesion()
  const [paso, setPaso] = useState<Paso>('producto')
  const [buscando, setBuscando] = useState(false)
  const [prod, setProd] = useState<Producto | null>(null)
  const [cantidad, setCantidad] = useState('1')
  const [obra, setObra] = useState<string>('')
  const [estadoDev, setEstadoDev] = useState<EstadoDevolucion>('BUENO')
  const [error, setError] = useState<string | null>(null)
  const [resultado, setResultado] = useState<string | null>(null)

  const esSalida = tipo === 'SALIDA'
  const titulo = esSalida ? 'Sacar producto' : 'Devolver producto'
  const tope = prod ? (esSalida ? prod.disponible : prod.en_obra || undefined) : undefined

  function porCodigo(codigo: string) {
    const hallado = productos.find(p => p.codigo_barras === codigo || p.sku === codigo)
    if (!hallado) {
      setError(`Código ${codigo}: no hay ningún producto con ese código. Avisa al encargado de bodega.`)
      setBuscando(false)
      return
    }
    elegir(hallado)
  }

  function elegir(p: Producto) {
    setError(null); setBuscando(false); setProd(p)
    setCantidad('1'); setPaso('cantidad')
  }

  async function confirmar() {
    if (!prod) return
    const n = Number(cantidad)
    if (!n || n <= 0) { setError('Indica una cantidad.'); return }
    if (esSalida && n > prod.disponible) {
      setError(`Solo hay ${prod.disponible} disponible(s) de ${prod.nombre}.`); return
    }
    if (esSalida && !obra) { setError('Elige la obra a la que se lo llevas.'); return }

    const m = await encolar({
      tipo, producto_id: prod.id, producto_nombre: prod.nombre, cantidad: n,
      obra_id: esSalida ? obra : null,
      estado_dev: esSalida ? null : estadoDev,
      dispositivo_id: dispositivoId, nota: null,
    })
    const local = aplicarLocal([prod], m as MovimientoPendiente)[0]
    setResultado(`${prod.nombre}: ${prod.disponible} → ${local.disponible}`)
    setPaso('hecho')
    void sincronizar().then(() => refrescar())
  }

  if (paso === 'hecho') {
    return (
      <>
        <div className="cuerpo centrado">
          <Exito>{esSalida ? 'Salida registrada' : 'Devolución registrada'}</Exito>
          <div className="tarjeta" style={{ fontSize: 20 }}>{resultado}</div>
        </div>
        <div className="pie">
          <button className="btn ancho" onClick={volver}>Terminar</button>
          <button className="btn principal ancho" onClick={() => { setProd(null); setPaso('producto'); setResultado(null) }}>
            Otro producto
          </button>
        </div>
      </>
    )
  }

  return (
    <>
      <div className="cuerpo">
        <h2 style={{ marginBottom: 14 }}>{titulo}</h2>
        <Error_>{error}</Error_>

        {paso === 'producto' && (
          buscando
            ? <Escaner onCodigo={porCodigo} onCerrar={() => setBuscando(false)} />
            : (
              <>
                <button className="btn principal ancho enorme" style={{ marginBottom: 14 }}
                        onClick={() => { setError(null); setBuscando(true) }}>
                  Escanear código
                </button>
                <BuscadorProductos
                  onElegir={elegir}
                  filtro={esSalida ? undefined : p => p.en_obra > 0}
                />
                {!esSalida && productos.every(p => p.en_obra === 0) && (
                  <Vacio titulo="No hay nada pendiente de devolver">
                    Todo lo que salió ya regresó a bodega.
                  </Vacio>
                )}
              </>
            )
        )}

        {paso === 'cantidad' && prod && (
          <>
            <FilaProducto p={prod} />
            <div style={{ height: 14 }} />
            <Numerico
              valor={cantidad} onCambio={setCantidad} maximo={tope}
              etiqueta={esSalida
                ? `disponible: ${prod.disponible} ${prod.unidad ?? 'UND'}`
                : `en obra: ${prod.en_obra} ${prod.unidad ?? 'UND'}`}
            />
          </>
        )}

        {paso === 'destino' && prod && (
          esSalida ? (
            <>
              <p style={{ color: 'var(--texto-tenue)', marginTop: 0 }}>¿A qué obra se lo llevas?</p>
              {obras.length === 0 && <Vacio titulo="No hay obras activas">Pídele al encargado que cree la obra.</Vacio>}
              {obras.map(o => (
                <button key={o.id}
                        className={`btn ancho ${obra === o.id ? 'principal' : ''}`}
                        style={{ marginBottom: 8, justifyContent: 'flex-start' }}
                        onClick={() => setObra(o.id)}>
                  {o.nombre}{o.codigo ? ` · ${o.codigo}` : ''}
                </button>
              ))}
            </>
          ) : (
            <>
              <p style={{ color: 'var(--texto-tenue)', marginTop: 0 }}>¿Cómo regresa?</p>
              {([['BUENO', 'Bueno', 'Vuelve a estar disponible'],
                 ['DANADO', 'Dañado', 'No vuelve al stock disponible'],
                 ['MANTENIMIENTO', 'Requiere mantenimiento', 'Queda fuera hasta repararse']] as const).map(
                ([v, t, sub]) => (
                  <button key={v}
                          className={`btn ancho ${estadoDev === v ? 'principal' : ''}`}
                          style={{ marginBottom: 8, flexDirection: 'column', minHeight: 84, gap: 2 }}
                          onClick={() => setEstadoDev(v)}>
                    {t}<span className="sub" style={{ fontSize: 14, fontWeight: 400, opacity: 0.75 }}>{sub}</span>
                  </button>
                ))}
            </>
          )
        )}
      </div>

      <div className="pie">
        <button className="btn" onClick={() => {
          if (paso === 'producto') return volver()
          if (paso === 'cantidad') return setPaso('producto')
          return setPaso('cantidad')
        }}>Atrás</button>
        {paso === 'cantidad' && (
          <button className="btn principal ancho" disabled={!Number(cantidad)} onClick={() => setPaso('destino')}>
            Continuar
          </button>
        )}
        {paso === 'destino' && (
          <button className="btn principal ancho" disabled={esSalida && !obra} onClick={() => void confirmar()}>
            {esSalida ? 'Confirmar salida' : 'Confirmar devolución'}
          </button>
        )}
      </div>
    </>
  )
}

/* ---------------- Conteo físico ---------------- */

function Conteo({ volver }: { volver: () => void }) {
  const { productos, dispositivoId } = useSesion()
  const [prod, setProd] = useState<Producto | null>(null)
  const [contado, setContado] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [listo, setListo] = useState<string | null>(null)

  const diferencia = useMemo(() => {
    if (!prod || contado === '') return null
    return Number(contado) - prod.disponible
  }, [prod, contado])

  async function enviar() {
    if (!prod) return
    try {
      await registrarConteo(
        [{ producto_id: prod.id, cantidad_contada: Number(contado), motivo: 'Conteo desde tablet' }],
        dispositivoId,
      )
      setListo(diferencia === 0
        ? 'Conteo registrado. Coincide con el sistema.'
        : `Conteo registrado. Diferencia de ${diferencia! > 0 ? '+' : ''}${diferencia}. El encargado debe aprobarla.`)
    } catch (e) {
      setError(mensajeDeError(e))
    }
  }

  if (listo) {
    return (
      <>
        <div className="cuerpo centrado"><Exito>{listo}</Exito></div>
        <div className="pie"><button className="btn principal ancho" onClick={volver}>Terminar</button></div>
      </>
    )
  }

  return (
    <>
      <div className="cuerpo">
        <h2 style={{ marginBottom: 14 }}>Conteo físico</h2>
        <Error_>{error}</Error_>
        {!prod
          ? <BuscadorProductos onElegir={p => { setProd(p); setContado('') }} />
          : (
            <>
              <FilaProducto p={prod} />
              <p style={{ color: 'var(--texto-tenue)' }}>
                El sistema dice {prod.disponible}. Cuenta lo que hay de verdad.
              </p>
              <Numerico valor={contado} onCambio={setContado} etiqueta="unidades contadas" />
              {diferencia !== null && diferencia !== 0 && (
                <div className="tarjeta" style={{ marginTop: 14, borderColor: 'var(--aviso)' }}>
                  Diferencia de {diferencia > 0 ? '+' : ''}{diferencia}. El inventario no cambia hasta
                  que el encargado apruebe el ajuste.
                </div>
              )}
            </>
          )}
        <div style={{ height: 8 }} />
        {productos.length === 0 && <Vacio titulo="No hay productos descargados">Conéctate una vez para descargar el inventario.</Vacio>}
      </div>
      <div className="pie">
        <button className="btn" onClick={() => (prod ? setProd(null) : volver())}>Atrás</button>
        {prod && (
          <button className="btn principal ancho" disabled={contado === ''} onClick={() => void enviar()}>
            Registrar conteo
          </button>
        )}
      </div>
    </>
  )
}

/* ---------------- Consulta ---------------- */

function Consultar({ volver }: { volver: () => void }) {
  const [prod, setProd] = useState<Producto | null>(null)
  const [escaneando, setEscaneando] = useState(false)
  const { productos } = useSesion()

  return (
    <>
      <div className="cuerpo">
        <h2 style={{ marginBottom: 14 }}>Buscar</h2>
        {prod ? (
          <div className="tarjeta">
            <h2>{prod.nombre}</h2>
            <p style={{ color: 'var(--texto-tenue)' }}>
              {prod.categoria ?? 'Sin categoría'}{prod.sku ? ` · ${prod.sku}` : ''}
            </p>
            <table className="tabla">
              <tbody>
                <tr><td>Disponible en bodega</td><td className="num"><b>{prod.disponible}</b> {prod.unidad}</td></tr>
                <tr><td>En obra</td><td className="num">{prod.en_obra}</td></tr>
                <tr><td>Total</td><td className="num">{prod.total}</td></tr>
                <tr><td>Ubicación</td><td className="num">{prod.ubicacion ?? '—'}</td></tr>
                <tr><td>Estado</td><td className="num">{prod.estado}</td></tr>
              </tbody>
            </table>
          </div>
        ) : escaneando
          ? <Escaner
              onCodigo={c => {
                const h = productos.find(p => p.codigo_barras === c || p.sku === c)
                setEscaneando(false)
                if (h) setProd(h)
              }}
              onCerrar={() => setEscaneando(false)} />
          : (
            <>
              <button className="btn ancho" style={{ marginBottom: 14 }} onClick={() => setEscaneando(true)}>
                Escanear código
              </button>
              <BuscadorProductos onElegir={setProd} />
            </>
          )}
      </div>
      <div className="pie">
        <button className="btn ancho" onClick={() => (prod ? setProd(null) : volver())}>Atrás</button>
      </div>
    </>
  )
}

/* ---------------- Movimientos recientes de esta tablet ---------------- */

function MisMovimientos({ volver }: { volver: () => void }) {
  const [cola, setCola] = useState<MovimientoPendiente[]>([])
  useEffect(() => { void pendientes().then(setCola) }, [])

  return (
    <>
      <div className="cuerpo">
        <h2 style={{ marginBottom: 14 }}>Mis movimientos</h2>
        {cola.length === 0
          ? <Vacio titulo="Nada en espera">Todo lo que registraste ya está en el servidor.</Vacio>
          : cola.map(m => (
            <div key={m.client_uuid} className="tarjeta">
              <b>{m.tipo === 'SALIDA' ? 'Salida' : m.tipo === 'DEVOLUCION' ? 'Devolución' : 'Entrada'} · {m.cantidad}</b>
              <div>{m.producto_nombre}</div>
              <div className="meta" style={{ color: 'var(--texto-tenue)', fontSize: 14 }}>
                {new Date(m.creado_en).toLocaleString('es-PA')}
                {m.error ? ` · rechazado: ${m.error}` : ' · esperando red'}
              </div>
            </div>
          ))}
      </div>
      <div className="pie"><button className="btn ancho" onClick={volver}>Atrás</button></div>
    </>
  )
}
