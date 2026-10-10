import * as React from "react"
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils"

const badgeVariants = cva(
  "inline-flex w-fit shrink-0 items-center justify-center px-2 py-1 text-xs leading-4 font-medium whitespace-nowrap",
  {
    variants: {
      variant: {
        secondary: "rounded-sm bg-secondary text-secondary-foreground",
        count:
          "min-w-6 rounded-full bg-primary text-primary-foreground tabular-nums",
      },
    },
    defaultVariants: {
      variant: "secondary",
    },
  }
)

function Badge({
  className,
  variant = "secondary",
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
