import * as React from "react"
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils"

const badgeVariants = cva(
  "type-caption inline-flex w-fit shrink-0 items-center justify-center rounded-full px-3 py-1 whitespace-nowrap",
  {
    variants: {
      variant: {
        tag: "border bg-surface-soft text-ink",
        feature: "min-w-7 bg-primary text-on-primary tabular-nums",
        open: "bg-status-open-bg text-status-open-fg",
        confirmed: "bg-status-confirmed-bg text-status-confirmed-fg",
        cancelled: "bg-status-cancelled-bg text-status-cancelled-fg",
      },
    },
    defaultVariants: {
      variant: "tag",
    },
  }
)

function Badge({
  className,
  variant = "tag",
  ...props
}: React.ComponentProps<"span"> & VariantProps<typeof badgeVariants>) {
  return (
    <span
      data-slot="badge"
      data-variant={variant}
      className={cn(badgeVariants({ variant }), className)}
      {...props}
    />
  )
}

export { Badge, badgeVariants }
