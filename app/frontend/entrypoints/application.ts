import React from "react";
import { createRoot } from "react-dom/client";
import App from "../react/App";
import "../styles/application.scss";

document.addEventListener("DOMContentLoaded", (): void => {
  const reactApp: HTMLElement | null = document.getElementById("react-app");
  
  if (reactApp) {
    const root = createRoot(reactApp);
    root.render(React.createElement(App));
  }
});
