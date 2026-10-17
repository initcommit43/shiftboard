import { Navigate, type RouteObject } from 'react-router'

import { redirectSignedIn, requireSession } from '@/features/auth/guards'
import { LoginPage } from '@/features/auth/login-page'
import { SessionLoading } from '@/features/auth/session-loading'
import { APP_ROUTE_ID } from '@/features/auth/use-session'
import { SettingsPage } from '@/features/settings/settings-page'
import { NewShiftPage } from '@/features/shifts/new-shift-page'
import { ShiftDetailPage } from '@/features/shifts/shift-detail-page'
import { ShiftsPage } from '@/features/shifts/shifts-page'
import { SignupsPage } from '@/features/signups/signups-page'

import { AppShell } from './app-shell'
import { ComingSoonPage } from './coming-soon-page'
import { NotFoundPage } from './not-found-page'

// All routes live here. Everything below the AppShell route needs a signed-in
// user: its loader restores the session or redirects to the login.
export const routes: RouteObject[] = [
  {
    hydrateFallbackElement: <SessionLoading />,
    children: [
      { path: 'login', loader: redirectSignedIn, element: <LoginPage /> },
      {
        id: APP_ROUTE_ID,
        loader: requireSession,
        element: <AppShell />,
        children: [
          { index: true, element: <Navigate to="/signups" replace /> },
          { path: 'shifts', element: <ShiftsPage /> },
          { path: 'shifts/new', element: <NewShiftPage /> },
          { path: 'shifts/:shiftId', element: <ShiftDetailPage /> },
          { path: 'signups', element: <SignupsPage /> },
          { path: 'messages', element: <ComingSoonPage area="messages" /> },
          { path: 'settings', element: <SettingsPage /> },
          { path: '*', element: <NotFoundPage /> },
        ],
      },
    ],
  },
]
