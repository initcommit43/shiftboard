import '@/styles/index.css'
import '@/i18n'

import { QueryClient } from '@tanstack/react-query'
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { createBrowserRouter } from 'react-router'

import { ApiError } from '@/api/errors'
import { App } from '@/app/app'
import { routes } from '@/app/router'
import { initTheme } from '@/lib/theme'

initTheme()

const root = document.getElementById('root')
if (!root) {
  throw new Error('Root element #root is missing in index.html')
}

const router = createBrowserRouter(routes)
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      // An answer from the API is final; only failed connections are retried.
      retry: (failureCount, error) => failureCount < 1 && !(error instanceof ApiError),
    },
  },
})

createRoot(root).render(
  <StrictMode>
    <App router={router} queryClient={queryClient} />
  </StrictMode>,
)
