import { createBrowserRouter } from 'react-router'

import { SystemStatusPage } from '@/features/system-status/system-status-page'

import { AppShell } from './app-shell'
import { NotFoundPage } from './not-found-page'

// All routes live here. Pages that need a signed-in user go under the AppShell
// layout route, which is where the auth guard will be attached.
export const router = createBrowserRouter([
  {
    element: <AppShell />,
    children: [
      { index: true, element: <SystemStatusPage /> },
      { path: '*', element: <NotFoundPage /> },
    ],
  },
])
