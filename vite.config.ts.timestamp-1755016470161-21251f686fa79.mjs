// vite.config.ts
import { defineConfig } from "file:///Users/ryotanakata/Documents/TECH/Code/GitHub/tanshuku.site/node_modules/vite/dist/node/index.js";
import RubyPlugin from "file:///Users/ryotanakata/Documents/TECH/Code/GitHub/tanshuku.site/node_modules/vite-plugin-ruby/dist/index.js";
import react from "file:///Users/ryotanakata/Documents/TECH/Code/GitHub/tanshuku.site/node_modules/@vitejs/plugin-react/dist/index.js";
var vite_config_default = defineConfig({
  plugins: [
    RubyPlugin(),
    react()
  ],
  server: {
    host: "0.0.0.0",
    port: 3036
  },
  resolve: {
    alias: {
      "@": "/app/frontend"
    },
    extensions: [".ts", ".tsx", ".js", ".jsx"]
  },
  css: {
    modules: {
      localsConvention: "camelCase",
      generateScopedName: "[name]__[local]___[hash:base64:5]"
    },
    preprocessorOptions: {
      scss: {
        additionalData: `@import "app/frontend/styles/variables.scss";`
      }
    }
  }
});
export {
  vite_config_default as default
};
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsidml0ZS5jb25maWcudHMiXSwKICAic291cmNlc0NvbnRlbnQiOiBbImNvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9kaXJuYW1lID0gXCIvVXNlcnMvcnlvdGFuYWthdGEvRG9jdW1lbnRzL1RFQ0gvQ29kZS9HaXRIdWIvdGFuc2h1a3Uuc2l0ZVwiO2NvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9maWxlbmFtZSA9IFwiL1VzZXJzL3J5b3RhbmFrYXRhL0RvY3VtZW50cy9URUNIL0NvZGUvR2l0SHViL3RhbnNodWt1LnNpdGUvdml0ZS5jb25maWcudHNcIjtjb25zdCBfX3ZpdGVfaW5qZWN0ZWRfb3JpZ2luYWxfaW1wb3J0X21ldGFfdXJsID0gXCJmaWxlOi8vL1VzZXJzL3J5b3RhbmFrYXRhL0RvY3VtZW50cy9URUNIL0NvZGUvR2l0SHViL3RhbnNodWt1LnNpdGUvdml0ZS5jb25maWcudHNcIjtpbXBvcnQgeyBkZWZpbmVDb25maWcgfSBmcm9tIFwidml0ZVwiO1xuaW1wb3J0IFJ1YnlQbHVnaW4gZnJvbSBcInZpdGUtcGx1Z2luLXJ1YnlcIjtcbmltcG9ydCByZWFjdCBmcm9tIFwiQHZpdGVqcy9wbHVnaW4tcmVhY3RcIjtcblxuZXhwb3J0IGRlZmF1bHQgZGVmaW5lQ29uZmlnKHtcbiAgcGx1Z2luczogW1xuICAgIFJ1YnlQbHVnaW4oKSxcbiAgICByZWFjdCgpLFxuICBdLFxuICBzZXJ2ZXI6IHtcbiAgICBob3N0OiAnMC4wLjAuMCcsXG4gICAgcG9ydDogMzAzNixcbiAgfSxcbiAgcmVzb2x2ZToge1xuICAgIGFsaWFzOiB7XG4gICAgICBcIkBcIjogXCIvYXBwL2Zyb250ZW5kXCIsXG4gICAgfSxcbiAgICBleHRlbnNpb25zOiBbJy50cycsICcudHN4JywgJy5qcycsICcuanN4J10sXG4gIH0sXG4gIGNzczoge1xuICAgIG1vZHVsZXM6IHtcbiAgICAgIGxvY2Fsc0NvbnZlbnRpb246IFwiY2FtZWxDYXNlXCIsXG4gICAgICBnZW5lcmF0ZVNjb3BlZE5hbWU6IFwiW25hbWVdX19bbG9jYWxdX19fW2hhc2g6YmFzZTY0OjVdXCIsXG4gICAgfSxcbiAgICBwcmVwcm9jZXNzb3JPcHRpb25zOiB7XG4gICAgICBzY3NzOiB7XG4gICAgICAgIGFkZGl0aW9uYWxEYXRhOiBgQGltcG9ydCBcImFwcC9mcm9udGVuZC9zdHlsZXMvdmFyaWFibGVzLnNjc3NcIjtgLFxuICAgICAgfSxcbiAgICB9LFxuICB9LFxufSk7Il0sCiAgIm1hcHBpbmdzIjogIjtBQUFtVyxTQUFTLG9CQUFvQjtBQUNoWSxPQUFPLGdCQUFnQjtBQUN2QixPQUFPLFdBQVc7QUFFbEIsSUFBTyxzQkFBUSxhQUFhO0FBQUEsRUFDMUIsU0FBUztBQUFBLElBQ1AsV0FBVztBQUFBLElBQ1gsTUFBTTtBQUFBLEVBQ1I7QUFBQSxFQUNBLFFBQVE7QUFBQSxJQUNOLE1BQU07QUFBQSxJQUNOLE1BQU07QUFBQSxFQUNSO0FBQUEsRUFDQSxTQUFTO0FBQUEsSUFDUCxPQUFPO0FBQUEsTUFDTCxLQUFLO0FBQUEsSUFDUDtBQUFBLElBQ0EsWUFBWSxDQUFDLE9BQU8sUUFBUSxPQUFPLE1BQU07QUFBQSxFQUMzQztBQUFBLEVBQ0EsS0FBSztBQUFBLElBQ0gsU0FBUztBQUFBLE1BQ1Asa0JBQWtCO0FBQUEsTUFDbEIsb0JBQW9CO0FBQUEsSUFDdEI7QUFBQSxJQUNBLHFCQUFxQjtBQUFBLE1BQ25CLE1BQU07QUFBQSxRQUNKLGdCQUFnQjtBQUFBLE1BQ2xCO0FBQUEsSUFDRjtBQUFBLEVBQ0Y7QUFDRixDQUFDOyIsCiAgIm5hbWVzIjogW10KfQo=
