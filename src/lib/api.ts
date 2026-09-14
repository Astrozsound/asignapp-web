import { createClient } from '@supabase/supabase-js'
import type {
  Alerta, Dispositivo, Movimiento, MovimientoPendiente, Obra, Panel, Perfil, Producto,
} from './tipos'

const URL = import.meta.env.VITE_SUPABASE_URL as string | undefined
const CLAVE = import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined

export const configurado = Boolean(URL && CLAVE)

export const supabase = createClient(
  URL ?? 'http://localhost:54321',
  CLAVE ?? 'clave-no-configurada',
  { auth: { persistSession: true, autoRefreshToken: true } },
)

/** Traduce los errores de Postgres a algo que se entienda en la bodega. */
export function mensajeDeError(e: unknown): string {
  const bruto = (e as { message?: string })?.message ?? String(e)
  if (/Stock insuficiente/i.test(bruto)) return bruto
  if (/Invalid login credentials/i.test(bruto)) return 'Usuario o contraseña incorrectos.'
  if (/Failed to fetch|NetworkError/i.test(bruto)) return 'Sin conexión con el servidor.'
  if (/permite|Solo un|no está activa|Debe indicar/i.test(bruto)) return bruto
  return bruto
}

export async function miPerfil(): Promise<Perfil | null> {
  const { data: sesion } = await supabase.auth.getUser()
  if (!sesion.user) return null
  const { data, error } = await supabase
    .from('perfiles').select('id,nombre,rol,activo').eq('id', sesion.user.id).single()
  if (error) throw error
  return data as Perfil
}

export async function listarDispositivos(): Promise<Dispositivo[]> {
  const { data, error } = await supabase
    .from('dispositivos').select('id,codigo,nombre,tipo').eq('activo', true).order('codigo')
  if (error) throw error
  return data as Dispositivo[]
}

export async function listarProductos(): Promise<Producto[]> {
  const { data, error } = await supabase
    .from('vw_productos_stock').select('*').eq('activo', true).order('nombre')
  if (error) throw error
  return data as Producto[]
}

export async function listarObras(): Promise<Obra[]> {
  const { data, error } = await supabase
    .from('obras').select('id,nombre,codigo,cliente,estado').eq('estado', 'ACTIVA').order('nombre')
  if (error) throw error
  return data as Obra[]
}

export async function panel(): Promise<Panel> {
  const { data, error } = await supabase.from('vw_dashboard').select('*').single()
  if (error) throw error
  return data as Panel
}

export async function alertas(): Promise<Alerta[]> {
  const { data, error } = await supabase.from('vw_alertas').select('*')
  if (error) throw error
  return data as Alerta[]
}

export async function historial(limite = 60): Promise<(Movimiento & {
  productos: { nombre: string } | null
  obras: { nombre: string } | null
  perfiles: { nombre: string } | null
})[]> {
  const { data, error } = await supabase
    .from('movimientos')
    .select('id,tipo,cantidad,delta,stock_anterior,stock_posterior,nota,created_at,producto_id,' +
            'productos(nombre),obras(nombre),perfiles!movimientos_usuario_id_fkey(nombre)')
    .order('created_at', { ascending: false })
    .limit(limite)
  if (error) throw error
  return data as never
}

/** Envía un movimiento al servidor. El client_uuid lo hace idempotente. */
export async function enviarMovimiento(m: MovimientoPendiente) {
  const { error } = await supabase.rpc('registrar_movimiento', {
    p_tipo: m.tipo,
    p_producto_id: m.producto_id,
    p_cantidad: m.cantidad,
    p_client_uuid: m.client_uuid,
    p_obra_id: m.obra_id ?? null,
    p_dispositivo_id: m.dispositivo_id ?? null,
    p_estado_dev: m.estado_dev ?? null,
    p_nota: m.nota ?? null,
  })
  if (error) throw error
}

export async function crearProducto(p: {
  nombre: string; categoria: string; unidad: string; sku?: string
  codigo_barras?: string; stock_minimo?: number; descripcion?: string
}) {
  const [{ data: cat }, { data: uni }] = await Promise.all([
    supabase.from('categorias').select('id').eq('nombre', p.categoria).single(),
    supabase.from('unidades').select('id').eq('codigo', p.unidad).single(),
  ])
  const { data, error } = await supabase.from('productos').insert({
    nombre: p.nombre,
    categoria_id: cat?.id ?? null,
    unidad_id: uni?.id ?? null,
    sku: p.sku || null,
    codigo_barras: p.codigo_barras || null,
    stock_minimo: p.stock_minimo ?? 0,
    descripcion: p.descripcion || null,
  }).select('id').single()
  if (error) throw error
  return data.id as string
}

export async function desactivarProducto(id: string, motivo: string) {
  const { error } = await supabase.rpc('desactivar_producto', {
    p_producto_id: id, p_motivo: motivo,
  })
  if (error) throw error
}

export async function eliminarProducto(id: string) {
  const { error } = await supabase.rpc('eliminar_producto', { p_producto_id: id })
  if (error) throw error
}

export async function registrarConteo(
  items: { producto_id: string; cantidad_contada: number; motivo?: string }[],
  dispositivo_id: string | null,
) {
  const { error } = await supabase.rpc('registrar_conteo', {
    p_items: items,
    p_client_uuid: crypto.randomUUID(),
    p_dispositivo_id: dispositivo_id,
    p_nota: null,
  })
  if (error) throw error
}

export async function conteosPendientes() {
  const { data, error } = await supabase
    .from('conteos')
    .select('id,created_at,nota,conteo_items(producto_id,cantidad_sistema,cantidad_contada,diferencia,productos(nombre))')
    .eq('estado', 'PENDIENTE')
    .order('created_at', { ascending: false })
  if (error) throw error
  return data as never as {
    id: string; created_at: string; nota: string | null
    conteo_items: {
      producto_id: string; cantidad_sistema: number; cantidad_contada: number
      diferencia: number; productos: { nombre: string } | null
    }[]
  }[]
}

export async function aprobarConteo(id: string) {
  const { error } = await supabase.rpc('aprobar_conteo', { p_conteo_id: id })
  if (error) throw error
}

export async function listarCatalogos() {
  const [cats, unis] = await Promise.all([
    supabase.from('categorias').select('nombre').eq('activo', true).order('nombre'),
    supabase.from('unidades').select('codigo,nombre').eq('activo', true).order('codigo'),
  ])
  return {
    categorias: (cats.data ?? []).map(c => c.nombre as string),
    unidades: (unis.data ?? []) as { codigo: string; nombre: string }[],
  }
}
