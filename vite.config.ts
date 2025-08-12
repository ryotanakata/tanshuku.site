import { defineConfig } from "vite";
import RubyPlugin from "vite-plugin-ruby";

export default defineConfig({
  plugins: [
    RubyPlugin(),
  ],
  server: {
    host: '0.0.0.0',
    port: 3036,
  },
  resolve: {
    alias: {
      "@": "/app/frontend",
    },
    extensions: ['.js', '.ts', '.tsx', '.jsx'],
  },
  css: {
    modules: {
      localsConvention: "camelCase",
      generateScopedName: "[name]__[local]___[hash:base64:5]",
    },
    preprocessorOptions: {
      scss: {
        additionalData: `@use "app/frontend/styles/variables.scss" as *;`,
      },
    },
  },
});