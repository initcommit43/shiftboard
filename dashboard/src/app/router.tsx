import { Navigate, type RouteObject } from 'react-router'

import { ClientSetupPage } from '@/features/auth/client-setup-page'
import { redirectSignedIn, requireClientSession, requireSession } from '@/features/auth/guards'
import { LoginPage } from '@/features/auth/login-page'
import { SessionLoading } from '@/features/auth/session-loading'
import { APP_ROUTE_ID, PORTAL_ROUTE_ID } from '@/features/auth/use-session'
import { ClientPage } from '@/features/clients/client-page'
import { ClientsPage } from '@/features/clients/clients-page'
import { HoursPage } from '@/features/hours/hours-page'
import { MessagesPage } from '@/features/messages/messages-page'
import { PortalRequestFormPage } from '@/features/portal/portal-request-form-page'
import { PortalRequestsPage } from '@/features/portal/portal-requests-page'
import { PortalShell } from '@/features/portal/portal-shell'
import { PortalShiftDetailPage } from '@/features/portal/portal-shift-detail-page'
import { PortalShiftsPage } from '@/features/portal/portal-shifts-page'
import { SettingsPage } from '@/features/settings/settings-page'
import { EditShiftPage } from '@/features/shifts/edit-shift-page'
import { NewShiftPage } from '@/features/shifts/new-shift-page'
import { ShiftDetailPage } from '@/features/shifts/shift-detail-page'
import { ShiftsPage } from '@/features/shifts/shifts-page'
import { SignupsPage } from '@/features/signups/signups-page'
import { EditTemplatePage } from '@/features/templates/edit-template-page'
import { TemplatesPage } from '@/features/templates/templates-page'

import { AppShell } from './app-shell'
import { NotFoundPage } from './not-found-page'

// All routes live here. Everything below the AppShell route needs a signed-in
// member of the agency, everything below the PortalShell route a signed-in
// client user: their loaders restore the session or redirect to the login, and
// send each kind of user to their own side (ADR 0032).
export const routes: RouteObject[] = [
  {
    hydrateFallbackElement: <SessionLoading />,
    children: [
      { path: 'login', loader: redirectSignedIn, element: <LoginPage /> },
      { path: 'client-setup/:setupCode', element: <ClientSetupPage /> },
      {
        id: PORTAL_ROUTE_ID,
        path: 'portal',
        loader: requireClientSession,
        element: <PortalShell />,
        children: [
          { index: true, element: <PortalShiftsPage /> },
          { path: 'shifts/:shiftId', element: <PortalShiftDetailPage /> },
          { path: 'requests', element: <PortalRequestsPage /> },
          { path: 'requests/new', element: <PortalRequestFormPage /> },
          { path: '*', element: <NotFoundPage /> },
        ],
      },
      {
        id: APP_ROUTE_ID,
        loader: requireSession,
        element: <AppShell />,
        children: [
          { index: true, element: <Navigate to="/signups" replace /> },
          { path: 'shifts', element: <ShiftsPage /> },
          { path: 'shifts/new', element: <NewShiftPage /> },
          { path: 'shifts/:shiftId', element: <ShiftDetailPage /> },
          { path: 'shifts/:shiftId/edit', element: <EditShiftPage /> },
          { path: 'templates', element: <TemplatesPage /> },
          { path: 'templates/:templateId', element: <EditTemplatePage /> },
          { path: 'hours', element: <HoursPage /> },
          { path: 'signups', element: <SignupsPage /> },
          { path: 'messages', element: <MessagesPage /> },
          { path: 'messages/:conversationId', element: <MessagesPage /> },
          { path: 'clients', element: <ClientsPage /> },
          { path: 'clients/:clientId', element: <ClientPage /> },
          { path: 'settings', element: <SettingsPage /> },
          { path: '*', element: <NotFoundPage /> },
        ],
      },
    ],
  },
]
