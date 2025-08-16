import TopPage from "@/pages/top/page";
import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import "@/styles/style.scss";

const container = document.getElementById("root");

if (container) {
  const root = createRoot(container);
  root.render(
    <StrictMode>
      <TopPage />
    </StrictMode>
  );
} else {
  console.error("root not found");
}
