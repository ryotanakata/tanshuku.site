import { defineConfig } from "vite";
import RubyPlugin from "vite-plugin-ruby";

export default defineConfig({
  plugins: [
    RubyPlugin(),
    react({
      tsDecorators: true, // TypeScript デコレータサポート
    }),
  ],
  resolve: {
    alias: {
      "@": "/app/javascript",
    },
  },
});
