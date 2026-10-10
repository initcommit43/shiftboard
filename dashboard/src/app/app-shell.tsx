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
          'flex h-9 items-center gap-3 rounded-lg px-3 text-sm font-medium text-muted-foreground transition-colors outline-none hover:bg-accent hover:text-accent-foreground focus-visible:ring-[3px] focus-visible:ring-ring/50',
          isActive && 'bg-accent text-accent-foreground',
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
    <Badge variant="count">
      <span aria-hidden>{count}</span>
      <span className="sr-only">{t('shell.nav.pendingSignups', { count })}</span>
    </Badge>
  )
}

export function AppShell() {
  const { t } = useTranslation()
  const { agency } = useCurrentUser()
  useSessionExpiry()

  return (
    <div className="flex min-h-svh">
      <aside className="hidden w-60 shrink-0 flex-col gap-6 border-r bg-card px-3 py-4 md:flex">
        <div className="flex h-8 items-center px-2">
          <Brand />
        </div>
        <nav aria-label={t('shell.navigation')} className="flex flex-col gap-1">
          <NavItem to="/shifts" icon={Calendar} label={t('shell.nav.shifts')} />
          <NavItem to="/signups" icon={UserPlus} label={t('shell.nav.signups')}>
            <PendingSignupsBadge />
          </NavItem>
          <NavItem to="/messages" icon={MessageSquare} label={t('shell.nav.messages')} />
          <NavItem to="/settings" icon={SlidersHorizontal} label={t('shell.nav.settings')} />
        </nav>
      </aside>

      <div className="flex min-w-0 flex-1 flex-col">
        <header className="flex h-16 shrink-0 items-center justify-between gap-4 border-b bg-card px-6">
          <div className="flex min-w-0 items-center gap-3">
            <span
              aria-hidden
              className="grid size-8 shrink-0 place-items-center rounded-lg bg-accent text-xs font-medium text-accent-foreground"
            >
              {initials(agency.name)}
            </span>
            <span className="truncate text-sm font-semibold">{agency.name}</span>
          </div>
          <div className="flex items-center gap-1">
            <LanguageSwitch />
            <ThemeToggle />
            <UserMenu />
          </div>
        </header>
        <main className="flex-1 px-6 py-8">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
