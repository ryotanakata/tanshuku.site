import '../controllers'
import React from 'react'
import { createRoot } from 'react-dom/client'
import App from '../react/App'

document.addEventListener('DOMContentLoaded', () => {
  const reactApp = document.getElementById('react-app')
  if (reactApp) {
    const root = createRoot(reactApp)
    root.render(React.createElement(App))
  }
})