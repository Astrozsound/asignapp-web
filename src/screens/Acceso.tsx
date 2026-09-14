import { useEffect, useState } from 'react'
import { configurado, listarDispositivos, mensajeDeError, supabase } from '../lib/api'
import { useSesion } from '../state/sesion'
import { Error_ } from '../components/ui'
import type { Dispositivo } from '../lib/tipos'

export function Entrar() {
  const [correo, setCorreo] = useState('')
  const [clave, setClave] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [ocupado, setOcupado] = useState(false)

  async function enviar() {
    setOcupado(true); setError(null)
    const { error } = await supabase.auth.signInWithPassword({ email: correo.trim(), password: clave })
    if (error) setError(mensajeDeError(error))
    setOcupado(false)
  }

  return (
    <div className="pantalla">
      <div className="cuerpo centrado">
        <div style={{ marginBottom: 28 }}>
          <div style={{ fontSize: 40, fontWeight: 800, letterSpacing: '0.01em' }}>
            ASIGN<span style={{ color: 'var(--amarillo)' }}>APP</span>
          </div>
          <div style={{ color: 'var(--texto-tenue)' }}>Inventario · Constructora HYCE</div>
        </div>

        {!configurado && (
          <div className="mensaje error">
            Falta configurar el servidor. Define VITE_SUPABASE_URL y VITE_SUPABASE_ANON_KEY
            antes de compilar la app.
          </div>
        )}

        <Error_>{error}</Error_>

        <label className="campo">
          <span>Correo</span>
          <input type="email" inputMode="email" autoComplete="username"
                 value={correo} onChange={e => setCorreo(e.target.value)} />
        </label>
        <label className="campo">
          <span>Contraseña</span>
          <input type="password" autoComplete="current-password"
                 value={clave} onChange={e => setClave(e.target.value)}
                 onKeyDown={e => { if (e.key === 'Enter') void enviar() }} />
        </label>
        <button className="btn principal ancho" disabled={ocupado || !correo || !clave} onClick={() => void enviar()}>
          {ocupado ? 'Entrando…' : 'Entrar'}
        </button>
      </div>
    </div>
  )
}

export function ElegirDispositivo() {
  const { fijarDispositivo } = useSesion()
  const [lista, setLista] = useState<Dispositivo[]>([])
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    listarDispositivos().then(setLista).catch(e => setError(mensajeDeError(e)))
  }, [])

  return (
    <div className="pantalla">
      <div className="cuerpo centrado">
        <h1 style={{ marginBottom: 6 }}>¿Cuál tablet es esta?</h1>
        <p style={{ color: 'var(--texto-tenue)', marginTop: 0, marginBottom: 22 }}>
          Se elige una sola vez. Cada movimiento queda registrado con la tablet desde la que se hizo.
        </p>
        <Error_>{error}</Error_>
        {lista.map(d => (
          <button key={d.id} className="btn ancho" style={{ marginBottom: 10, justifyContent: 'flex-start' }}
                  onClick={() => fijarDispositivo(d.id, d.nombre)}>
            <b>{d.codigo}</b>
            <span style={{ color: 'var(--texto-tenue)', fontWeight: 400 }}>{d.nombre}</span>
          </button>
        ))}
      </div>
    </div>
  )
}
