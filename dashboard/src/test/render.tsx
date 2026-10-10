import { QueryClient } from '@tanstack/react-query'
import { render } from '@testing-library/react'
import { createMemoryRouter } from 'react-router'

import { App } from '@/app/app'
import { routes } from '@/app/router'

/** Renders the whole app at the given path, with a fresh query cache and retries off. */
export function renderApp(path: string) {
  const router = createMemoryRouter(routes, { initialEntries: [path] })
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
    },
  })

  render(<App router={router} queryClient={queryClient} />)
  return { router }
}
