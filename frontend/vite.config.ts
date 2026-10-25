import { existsSync } from "node:fs";
import { resolve } from "node:path";
import react from "@vitejs/plugin-react";
import { reactRouter } from "@react-router/dev/vite";
import { defineConfig } from "vite";

function prerenderedRoutes() {
  return {
    name: "prerendered-route-preview",
    configurePreviewServer(server: {
      middlewares: { use(handler: (req: { url?: string }, res: unknown, next: () => void) => void): void };
    }) {
      server.middlewares.use((req, _res, next) => {
        const [pathname] = (req.url ?? "/").split("?");

        if (!pathname.endsWith("/") && !pathname.includes(".")) {
          const routeIndex = resolve("build/client", `.${pathname}`, "index.html");
          if (existsSync(routeIndex)) {
            req.url = `${pathname}/index.html${req.url?.slice(pathname.length) ?? ""}`;
          }
        }

        next();
      });
    },
  };
}

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), reactRouter(), prerenderedRoutes()],
  environments: {
    client: {
      build: {
        rollupOptions: {
          output: {
            entryFileNames: (chunk) => `assets/${chunk.name.replace(/^_/, "")}-[hash].js`,
          },
        },
      },
    },
  },
});
