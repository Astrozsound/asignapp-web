import { useSesion } from './state/sesion'
import { ElegirDispositivo, Entrar } from './screens/Acceso'
import { AppAdmin } from './screens/admin/Admin'
import { AppOperario } from './screens/operario/Operario'

export default function App() {
  const { perfil, cargando, dispositivoId } = useSesion()

  if (cargando) {
    return (
      <div className="pantalla">
        <div className="cuerpo centrado" style={{ textAlign: 'center', color: 'var(--texto-tenue)' }}>
          Abriendo ASIGNAPP…
        </div>
      </div>
    )
  }

  if (!perfil) return <Entrar />
  if (!dispositivoId) return <ElegirDispositivo />

  // El rol decide la interfaz. La Tablet 1 la usa un ADMIN o SUPERVISOR;
  // las tablets 2 y 3, un OPERARIO. El backend valida igualmente.
  return perfil.rol === 'OPERARIO' ? <AppOperario /> : <AppAdmin />
}
