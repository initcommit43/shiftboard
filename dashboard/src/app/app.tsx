import { type QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { useTranslation } from 'react-i18next'
import type { createBrowserRouter } from 'react-router'
import { RouterProvider } from 'react-router/dom'

import { Toaster } from '@/components/ui/sonner'

export function App({
  router,
  queryClient,
}: {
  router: ReturnType<typeof createBrowserRouter>
  queryClient: QueryClient
}) {
  const { t } = useTranslation()

  return (
    <QueryClientProvider client={queryClient}>
      <RouterProvider router={router} />
      <Toaster containerAriaLabel={t('shell.notifications')} />
    </QueryClientProvider>
  )
}
