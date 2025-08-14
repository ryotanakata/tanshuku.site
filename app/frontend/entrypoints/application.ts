import { createElement } from "react";
import { createRoot } from "react-dom/client";
import TopPage from "@/pages/top/page";
import "@/styles/style.scss";

const initializeApp = () => {
  const body: HTMLElement | null = document.body;

  if (!body) return;

  const root = createRoot(body);
  root.render(createElement(TopPage));
}

document.addEventListener("DOMContentLoaded", initializeApp);
