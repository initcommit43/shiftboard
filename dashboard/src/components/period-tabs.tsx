import { Link } from 'react-router'

import { cn } from '@/lib/utils'

/** Pill links that switch a list between periods, such as upcoming and past. */
export function PeriodTabs<P extends string>({
  label,
  tabs,
  current,
}: {
  label: string
  tabs: { period: P; to: string; label: string }[]
  current: P
}) {
  return (
    <nav aria-label={label} className="flex gap-2">
      {tabs.map((tab) => {
        const active = tab.period === current
        return (
          <Link
            key={tab.period}
            to={tab.to}
            aria-current={active ? 'page' : undefined}
            className={cn(
              'type-button-sm inline-flex h-9 items-center rounded-full px-4 transition-colors',
              active ? 'bg-action text-on-action' : 'bg-surface-soft text-ink hover:bg-surface-soft/70',
            )}
          >
            {tab.label}
          </Link>
        )
      })}
    </nav>
  )
}
