import { LayoutDashboard } from 'lucide-react'
import { useTranslation } from 'react-i18next'
import { NavLink, Outlet } from 'react-router'

import { LanguageSwitch } from '@/components/language-switch'
import { ThemeToggle } from '@/components/theme-toggle'
import { cn } from '@/lib/utils'

function Brand({ className }: { className?: string }) {
  const { t } = useTranslation()

  return (
    <div className={cn('flex items-center gap-2.5', className)}>
      <span
        aria-hidden
        className="grid size-7 place-items-center rounded-md bg-primary text-sm font-semibold text-primary-foreground uppercase"
      >
        {t('app.name').charAt(0)}
      </span>
      <span className="leading-tight">
        <span className="block text-sm font-semibold tracking-tight">{t('app.name')}</span>
        <span className="block text-xs text-muted-foreground">{t('app.tagline')}</span>
      </span>
    </div>
  )
}

export function AppShell() {
  const { t } = useTranslation()

  return (
    <div className="flex min-h-svh">
      <aside className="hidden w-60 shrink-0 flex-col border-r bg-card md:flex">
        <Brand className="h-14 border-b px-4" />
        <nav aria-label={t('shell.navigation')} className="flex flex-col gap-1 p-3">
          <NavLink
            to="/"
            end
            className={({ isActive }) =>
              cn(
                'flex items-center gap-2.5 rounded-md px-3 py-2 text-sm font-medium text-muted-foreground transition-colors outline-none hover:bg-accent hover:text-accent-foreground focus-visible:ring-[3px] focus-visible:ring-ring/50',
                isActive && 'bg-accent text-accent-foreground',
              )
            }
          >
            <LayoutDashboard aria-hidden className="size-4" />
            {t('shell.nav.overview')}
          </NavLink>
        </nav>
      </aside>

      <div className="flex min-w-0 flex-1 flex-col">
        <header className="flex h-14 shrink-0 items-center gap-1 border-b bg-card px-4 md:px-6">
          <Brand className="md:hidden" />
          <div className="ml-auto flex items-center gap-1">
            <LanguageSwitch />
            <ThemeToggle />
          </div>
        </header>
        <main className="flex-1 px-4 py-8 md:px-8">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
