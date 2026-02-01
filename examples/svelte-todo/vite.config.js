import { defineConfig } from "vite";
import { svelte } from "@sveltejs/vite-plugin-svelte";
import ViteRuby from "vite-plugin-ruby";

export default defineConfig({
  plugins: [svelte(), ...ViteRuby()],
});
