import TopPage from "@/pages/top/page";
import { createElement } from "react";
import { createRoot } from "react-dom/client";
import "@/styles/style.scss";

const root = createRoot(document.body);
root.render(createElement(TopPage));
