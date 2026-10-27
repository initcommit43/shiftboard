import { type LoaderFunctionArgs, redirect } from 'react-router'

import { Role } from '@/api/generated'

import { loadSession } from './session'

const REDIRECT_PARAM = 'redirectTo'

/** Where the client portal lives. Client users see nothing else of the dashboard (ADR 0032). */
export const PORTAL_PATH = '/portal'

/** Sends a visitor to the login, with the way back to the requested page. */
function toLogin(request: Request) {
  const { pathname, search } = new URL(request.url)
  const requested = pathname + search
  return redirect(
    requested === '/'
      ? '/login'
      : `/login?${new URLSearchParams({ [REDIRECT_PARAM]: requested }).toString()}`,
  )
}

/** Loader of the agency's routes: returns the user or sends the visitor to the login. Client users go to their portal. */
export async function requireSession({ request }: LoaderFunctionArgs) {
  const user = await loadSession()
  if (!user) {
    return toLogin(request)
  }
  return user.role === Role.CLIENT ? redirect(PORTAL_PATH) : user
}

/** Loader of the portal routes: returns the client user. The agency's staff go to the dashboard. */
export async function requireClientSession({ request }: LoaderFunctionArgs) {
  const user = await loadSession()
  if (!user) {
    return toLogin(request)
  }
  return user.role === Role.CLIENT ? user : redirect('/')
}

/** Loader of the login route: a signed-in user goes straight into the app. */
export async function redirectSignedIn({ request }: LoaderFunctionArgs) {
  if (await loadSession()) {
    return redirect(redirectTarget(new URL(request.url).searchParams))
  }
  return null
}

/** The page requested before the login. Only paths inside the app are accepted. */
export function redirectTarget(searchParams: URLSearchParams) {
  const target = searchParams.get(REDIRECT_PARAM)
  return target?.startsWith('/') && !target.startsWith('//') ? target : '/'
}
