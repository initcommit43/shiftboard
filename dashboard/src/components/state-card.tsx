import type { ReactNode } from 'react'

/** Centered message that fills the place of a page's content: empty, error or not built yet. */
export function StateCard({
  icon,
  title,
  description,
  action,
}: {
  icon: ReactNode
  title: string
  description: string
  action?: ReactNode
}) {
  return (
    <div className="flex min-h-[22.5rem] flex-col items-center justify-center gap-6 rounded-lg border bg-surface-card px-8 py-12 text-center">
      <span aria-hidden className="text-ink-tertiary [&>svg]:size-8">
        {icon}
      </span>
      <div className="space-y-2">
        <h2 className="type-heading-sm">{title}</h2>
        <p className="max-w-[27.5rem] text-ink-secondary">{description}</p>
      </div>
      {action}
    </div>
  )
}
