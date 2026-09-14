import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import App from './App'
import { ProveedorSesion } from './state/sesion'
import './estilos.css'

if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js').catch(() => { /* sin PWA, la app sigue funcionando */ })
  })
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ProveedorSesion>
      <App />
    </ProveedorSesion>
  </StrictMode>,
)
