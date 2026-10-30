import { useQueryClient } from '@tanstack/react-query'
import { useEffect } from 'react'
import { useNavigate, useRevalidator, useRouteLoaderData } from 'react-router'

import { onSessionExpired } from '@/api/client'
import type { CurrentUser } from '@/api/generated'

import type { requireClientSession, requireSession } from './guards'
import { logout } from './session'

/** Id of the agency's protected layout route, whose loader provides the signed-in user. */
export const APP_ROUTE_ID = 'app'

/** Id of the client portal's layout route, whose loader provides the signed-in client user. */
export const PORTAL_ROUTE_ID = 'portal'

/** The signed-in user, below either the agency's layout or the portal's. */
export function useCurrentUser(): CurrentUser {
  const staff = useRouteLoaderData<typeof requireSession>(APP_ROUTE_ID)
  const client = useRouteLoaderData<typeof requireClientSession>(PORTAL_ROUTE_ID)
  const user = staff ?? client
  if (!user) {
    throw new Error('useCurrentUser needs a protected layout route as an ancestor')
  }
  return user
}

export function useLogout() {
  const queryClient = useQueryClient()
  const navigate = useNavigate()

  return async () => {
    logout()
    await navigate('/login')
    queryClient.clear()
  }
}

/** When the session can no longer be refreshed: drop cached data and let the guard redirect to the login. */
export function useSessionExpiry() {
  const queryClient = useQueryClient()
  const { revalidate } = useRevalidator()

  useEffect(
    () =>
      onSessionExpired(() => {
        queryClient.clear()
        void revalidate()
      }),
    [queryClient, revalidate],
  )
}
