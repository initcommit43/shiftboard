import { useQueryClient } from '@tanstack/react-query'
import { useEffect } from 'react'
import { useNavigate, useRevalidator, useRouteLoaderData } from 'react-router'

import { onSessionExpired } from '@/api/client'
import type { CurrentUser } from '@/api/generated'

import type { requireSession } from './guards'
import { logout } from './session'

/** Id of the protected layout route, whose loader provides the signed-in user. */
export const APP_ROUTE_ID = 'app'

export function useCurrentUser(): CurrentUser {
  const user = useRouteLoaderData<typeof requireSession>(APP_ROUTE_ID)
  if (!user) {
    throw new Error('useCurrentUser needs the protected app route as an ancestor')
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
