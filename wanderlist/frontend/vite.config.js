import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  // proxy rimosso: l'app usa ora IndexedDB locale (nessun backend necessario)
  server: {
    port: Number(process.env.PORT) || 5173,
  },
})
