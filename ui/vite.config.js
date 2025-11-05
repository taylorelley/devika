import { sveltekit } from "@sveltejs/kit/vite";
import { defineConfig } from "vite";
import wasm from "vite-plugin-wasm";

const allowedHosts = ["localhost", "127.0.0.1"];
if (process.env.VITE_ALLOWED_HOST) {
  allowedHosts.push(process.env.VITE_ALLOWED_HOST);
}

export default defineConfig({
  plugins: [sveltekit(), wasm()],
  server: {
    port: 3000,
    allowedHosts,
  },
  preview: {
    port: 3001,
  },
  build: {
    target: "esnext",
  },
});
