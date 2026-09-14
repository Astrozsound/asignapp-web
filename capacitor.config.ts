import type { CapacitorConfig } from '@capacitor/cli'

const config: CapacitorConfig = {
  appId: 'com.hyce.asignapp',
  appName: 'ASIGNAPP',
  webDir: 'dist',
  android: {
    // La app vive dentro del container: permite HTTP local si el servidor
    // Supabase se autoaloja en la red de la obra.
    allowMixedContent: true,
  },
  plugins: {
    SplashScreen: { launchShowDuration: 600, backgroundColor: '#111111' },
  },
}

export default config
