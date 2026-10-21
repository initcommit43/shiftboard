import {
  Calendar,
  type LucideIcon,
  MessageSquare,
  SlidersHorizontal,
  UserPlus,
} from 'lucide-react'
import type { ReactNode } from 'react'
import { useTranslation } from 'react-i18next'
import { NavLink, Outlet } from 'react-router'

import { Brand } from '@/components/brand'
import { LanguageSwitch } from '@/components/language-switch'
import { ThemeToggle } from '@/components/theme-toggle'
import { Badge } from '@/components/ui/badge'
import { useCurrentUser, useSessionExpiry } from '@/features/auth/use-session'
import { UserMenu } from '@/features/auth/user-menu'
import { useUnreadMessageCount } from '@/features/messages/queries'
import { usePendingSignupCount } from '@/features/signups/queries'
import { initials } from '@/lib/initials'
import { cn } from '@/lib/utils'

function NavItem({
  to,
  icon: Icon,
  label,
  children,
}: {
  to: string
  icon: LucideIcon
  label: string
  children?: ReactNode
}) {
  return (
    <NavLink
      to={to}
      className={({ isActive }) =>
        cn(
          'type-button-sm flex h-11 items-center gap-3 rounded-full px-4 text-ink-secondary transition-colors hover:bg-surface-soft hover:text-ink',
          isActive && 'bg-surface-soft text-ink',
        )
      }
    >
      <Icon aria-hidden className="size-[1.125rem] shrink-0" />
      <span className="flex-1">{label}</span>
      {children}
    </NavLink>
  )
}

function PendingSignupsBadge() {
  const { t } = useTranslation()
  const count = usePendingSignupCount()

  if (!count) {
    return null
  }
  return (
    <Badge variant="feature">
      <span aria-hidden>{count}</span>
      <span className="sr-only">{t('shell.nav.pendingSignups', { count })}</span>
    </Badge>
  )
}

function UnreadMessagesBadge() {
  const { t } = useTranslation()
  const count = useUnreadMessageCount()

  if (!count) {
    return null
  }
  return (
    <Badge variant="feature">
      <span aria-hidden>{count}</span>
      <span className="sr-only">{t('shell.nav.unreadMessages', { count })}</span>
    </Badge>
  )
}

export function AppShell() {
  const { t } = useTranslation()
  const { agency } = useCurrentUser()
  useSessionExpiry()

  return (
    <div className="flex min-h-svh">
      {/* The navigation is a dark band in both themes. */}
      <aside className="dark hidden w-64 shrink-0 flex-col gap-8 border-r bg-canvas px-4 pb-6 text-ink md:flex">
        <div className="flex h-16 items-center px-4">
          <Brand />
        </div>
        <nav aria-label={t('shell.navigation')} className="flex flex-col gap-1">
          <NavItem to="/shifts" icon={Calendar} label={t('shell.nav.shifts')} />
          <NavItem to="/signups" icon={UserPlus} label={t('shell.nav.signups')}>
            <PendingSignupsBadge />
          </NavItem>
          <NavItem to="/messages" icon={MessageSquare} label={t('shell.nav.messages')}>
            <UnreadMessagesBadge />
          </NavItem>
          <NavItem to="/settings" icon={SlidersHorizontal} label={t('shell.nav.settings')} />
        </nav>
      </aside>

      <div className="flex min-w-0 flex-1 flex-col">
        <header className="flex h-16 shrink-0 items-center justify-between gap-4 border-b px-8">
          <div className="flex min-w-0 items-center gap-3">
            <span
              aria-hidden
              className="type-caption grid size-9 shrink-0 place-items-center rounded-full bg-surface-soft font-semibold"
            >
              {initials(agency.name)}
            </span>
            <span className="type-body-md-bold truncate">{agency.name}</span>
          </div>
          <div className="flex items-center gap-1">
            <LanguageSwitch />
            <ThemeToggle />
            <UserMenu />
          </div>
        </header>
        <main className="flex-1 px-8 py-12">
          <div className="mx-auto max-w-[75rem]">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  )
}
