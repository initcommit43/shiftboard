import type { ReactNode } from 'react'

export function PageHeader({
  title,
  description,
  action,
}: {
  title: string
  description?: string
  action?: ReactNode
}) {
  return (
    <div className="flex flex-wrap items-end justify-between gap-4">
      <div className="space-y-2">
        <h1 className="type-heading-lg">{title}</h1>
        {description && <p className="text-ink-secondary">{description}</p>}
      </div>
      {action}
    </div>
  )
}
