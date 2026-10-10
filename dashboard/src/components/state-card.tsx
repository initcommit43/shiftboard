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
    <div className="flex min-h-[22.5rem] flex-col items-center justify-center gap-4 rounded-lg border bg-card px-6 py-12 text-center">
      <span
        aria-hidden
        className="grid size-14 place-items-center rounded-full bg-muted text-muted-foreground [&>svg]:size-6"
      >
        {icon}
      </span>
      <div className="space-y-1">
        <h2 className="text-lg leading-[1.625rem] font-semibold">{title}</h2>
        <p className="max-w-[27.5rem] text-sm text-muted-foreground">{description}</p>
      </div>
      {action}
    </div>
  )
}
