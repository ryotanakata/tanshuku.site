import path from "path";
import { defineConfig } from "vite";
import RubyPlugin from "vite-plugin-ruby";

export default defineConfig({
  plugins: [RubyPlugin()],
  server: {
    host: "0.0.0.0",
    port: 3036,
  },
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./app/frontend"),
    },
    extensions: [".js", ".ts", ".tsx", ".jsx"],
  },
  css: {
    modules: {
      localsConvention: "camelCase",
      generateScopedName: "style_[local]__[hash:base64:5]",
    },
  },
});
