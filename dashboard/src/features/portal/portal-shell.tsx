import { useTranslation } from 'react-i18next'
import { Link, Outlet } from 'react-router'

import { Brand } from '@/components/brand'
import { LanguageSwitch } from '@/components/language-switch'
import { ThemeToggle } from '@/components/theme-toggle'
import { useCurrentUser, useSessionExpiry } from '@/features/auth/use-session'
import { UserMenu } from '@/features/auth/user-menu'
import { initials } from '@/lib/initials'

/**
 * The frame of the client portal. Unlike the agency's shell it has no
 * navigation and opens no live connections: clients see their shifts only.
 */
export function PortalShell() {
  const { t } = useTranslation()
  const { agency, client } = useCurrentUser()
  useSessionExpiry()
  const name = client?.name ?? agency.name

  return (
    <div className="flex min-h-svh flex-col">
      <header className="flex h-16 shrink-0 items-center justify-between gap-4 border-b px-4 sm:px-8">
        <div className="flex min-w-0 items-center gap-4">
          <Link to="/portal" aria-label={t('portal.home')} className="hidden sm:block">
            <Brand />
          </Link>
          <span aria-hidden className="hidden h-6 border-l sm:block" />
          <div className="flex min-w-0 items-center gap-3">
            <span
              aria-hidden
              className="type-caption grid size-9 shrink-0 place-items-center rounded-full bg-surface-soft font-semibold"
            >
              {initials(name)}
            </span>
            <div className="min-w-0">
              <span className="type-body-md-bold block truncate">{name}</span>
              <span className="type-caption block truncate text-ink-secondary">
                {t('portal.byAgency', { agency: agency.name })}
              </span>
            </div>
          </div>
        </div>
        <div className="flex items-center gap-1">
          <LanguageSwitch />
          <ThemeToggle />
          <UserMenu />
        </div>
      </header>
      <main className="flex-1 px-4 py-12 sm:px-8">
        <div className="mx-auto max-w-[75rem]">
          <Outlet />
        </div>
      </main>
    </div>
  )
}
