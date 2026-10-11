export function PageHeader({ title, description }: { title: string; description?: string }) {
  return (
    <div className="space-y-2">
      <h1 className="type-heading-lg">{title}</h1>
      {description && <p className="text-ink-secondary">{description}</p>}
    </div>
  )
}
