import { type LoaderFunctionArgs, redirect } from 'react-router'

import { loadSession } from './session'

const REDIRECT_PARAM = 'redirectTo'

/** Loader of the protected routes: returns the user or sends the visitor to the login. */
export async function requireSession({ request }: LoaderFunctionArgs) {
  const user = await loadSession()
  if (user) {
    return user
  }
  const { pathname, search } = new URL(request.url)
  const requested = pathname + search
  return redirect(
    requested === '/'
      ? '/login'
      : `/login?${new URLSearchParams({ [REDIRECT_PARAM]: requested }).toString()}`,
  )
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
