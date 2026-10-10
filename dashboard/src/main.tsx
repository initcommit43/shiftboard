import '@/styles/index.css'
import '@/i18n'

import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'

import { App } from '@/app/app'
import { initTheme } from '@/lib/theme'

initTheme()

const root = document.getElementById('root')
if (!root) {
  throw new Error('Root element #root is missing in index.html')
}

createRoot(root).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
