import { defineConfig } from "vite"
import react from "@vitejs/plugin-react"
import { resolve } from "path"

export default defineConfig({
  plugins: [react()],
  build: {
    manifest: true,
    rollupOptions: {
      input: resolve(__dirname, "frontend/application.jsx"),
    },
    outDir: "public/vite",
  },
  server: {
    origin: "http://localhost:5173",
  },
})
