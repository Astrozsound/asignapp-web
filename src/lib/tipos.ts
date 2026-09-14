export type Rol = 'ADMIN' | 'SUPERVISOR' | 'OPERARIO'

export type TipoMovimiento =
  | 'ENTRADA' | 'SALIDA' | 'DEVOLUCION' | 'AJUSTE' | 'CONTEO'
  | 'CAMBIO_ESTADO' | 'CREACION' | 'EDICION' | 'DESACTIVACION' | 'TRANSFERENCIA'

export type EstadoDevolucion = 'BUENO' | 'DANADO' | 'MANTENIMIENTO'

export interface Perfil {
  id: string
  nombre: string
  rol: Rol
  activo: boolean
}

export interface Dispositivo {
  id: string
  codigo: string
  nombre: string
  tipo: 'BODEGA' | 'OPERARIO'
}

export interface Producto {
  id: string
  sku: string | null
  nombre: string
  codigo_barras: string | null
  estado: string
  activo: boolean
  stock_minimo: number
  es_consumible: boolean
  es_retornable: boolean
  requiere_revision: boolean
  categoria: string | null
  unidad: string | null
  ubicacion: string | null
  bodega: string | null
  disponible: number
  en_obra: number
  total: number
}

export interface Obra {
  id: string
  nombre: string
  codigo: string | null
  cliente: string | null
  estado: 'ACTIVA' | 'FINALIZADA' | 'CANCELADA'
}

export interface Movimiento {
  id: string
  tipo: TipoMovimiento
  cantidad: number
  delta: number
  stock_anterior: number | null
  stock_posterior: number | null
  nota: string | null
  created_at: string
  producto_id: string | null
}

export interface Alerta {
  tipo: string
  severidad: string
  producto_id: string
  nombre: string
  detalle: string
}

export interface Panel {
  total_productos: number
  total_unidades: number
  stock_bajo: number
  agotados: number
  unidades_en_obra: number
  movimientos_hoy: number
  salidas_hoy: number
  devoluciones_hoy: number
  conteos_pendientes: number
}

/** Movimiento generado en la tablet, pendiente de llegar al servidor. */
export interface MovimientoPendiente {
  client_uuid: string
  tipo: Extract<TipoMovimiento, 'ENTRADA' | 'SALIDA' | 'DEVOLUCION'>
  producto_id: string
  producto_nombre: string
  cantidad: number
  obra_id?: string | null
  estado_dev?: EstadoDevolucion | null
  dispositivo_id?: string | null
  nota?: string | null
  creado_en: number
  intentos: number
  error?: string | null
}
