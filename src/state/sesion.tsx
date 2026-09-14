import {
  createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode,
} from 'react'
import { listarObras, listarProductos, miPerfil, supabase } from '../lib/api'
import {
  arrancarSync, guardarCache, leerCache, observarSync, sincronizar, type EstadoSync,
} from '../lib/offline'
import type { Obra, Perfil, Producto } from '../lib/tipos'

interface Contexto {
  perfil: Perfil | null
  cargando: boolean
  productos: Producto[]
  obras: Obra[]
  dispositivoId: string | null
  dispositivoNombre: string | null
  estado: EstadoSync
  enCola: number
  refrescar: () => Promise<void>
  fijarDispositivo: (id: string, nombre: string) => void
  salir: () => Promise<void>
}

const Ctx = createContext<Contexto | null>(null)

const CLAVE_DISPOSITIVO = 'asignapp.dispositivo'

export function ProveedorSesion({ children }: { children: ReactNode }) {
  const [perfil, setPerfil] = useState<Perfil | null>(null)
  const [cargando, setCargando] = useState(true)
  const [productos, setProductos] = useState<Producto[]>([])
  const [obras, setObras] = useState<Obra[]>([])
  const [estado, setEstado] = useState<EstadoSync>('conectado')
  const [enCola, setEnCola] = useState(0)
  const [dispositivo, setDispositivo] = useState<{ id: string; nombre: string } | null>(() => {
    const crudo = localStorage.getItem(CLAVE_DISPOSITIVO)
    return crudo ? JSON.parse(crudo) : null
  })

  const refrescar = useCallback(async () => {
    try {
      const [p, o] = await Promise.all([listarProductos(), listarObras()])
      setProductos(p); setObras(o)
      await guardarCache(p, o)
    } catch {
      // Sin red: se trabaja con lo último que se descargó.
      const cache = await leerCache()
      setProductos(cache.productos); setObras(cache.obras)
    }
  }, [])

  useEffect(() => {
    let vivo = true
    supabase.auth.getSession().then(async ({ data }) => {
      if (!vivo) return
      if (data.session) {
        try { setPerfil(await miPerfil()) } catch { setPerfil(null) }
        await refrescar()
      }
      setCargando(false)
    })
    const { data: sub } = supabase.auth.onAuthStateChange(async (_evt, sesion) => {
      if (!sesion) { setPerfil(null); setProductos([]); return }
      try { setPerfil(await miPerfil()) } catch { setPerfil(null) }
      await refrescar()
    })
    arrancarSync()
    const dejar = observarSync((e, n) => {
      setEstado(e); setEnCola(n)
      if (e === 'conectado' && n === 0) void refrescar()
    })
    return () => { vivo = false; sub.subscription.unsubscribe(); dejar() }
  }, [refrescar])

  const fijarDispositivo = useCallback((id: string, nombre: string) => {
    localStorage.setItem(CLAVE_DISPOSITIVO, JSON.stringify({ id, nombre }))
    setDispositivo({ id, nombre })
  }, [])

  const salir = useCallback(async () => {
    await sincronizar()
    await supabase.auth.signOut()
    setPerfil(null)
  }, [])

  const valor = useMemo<Contexto>(() => ({
    perfil, cargando, productos, obras,
    dispositivoId: dispositivo?.id ?? null,
    dispositivoNombre: dispositivo?.nombre ?? null,
    estado, enCola, refrescar, fijarDispositivo, salir,
  }), [perfil, cargando, productos, obras, dispositivo, estado, enCola, refrescar, fijarDispositivo, salir])

  return <Ctx.Provider value={valor}>{children}</Ctx.Provider>
}

export function useSesion() {
  const c = useContext(Ctx)
  if (!c) throw new Error('useSesion fuera del proveedor')
  return c
}
