import * as React from "react"
import { cn } from "@/lib/utils"

function Input({ className, type, ...props }: React.ComponentProps<"input">) {
  return (
    <input
      type={type}
      data-slot="input"
      className={cn(
        "type-body-md h-14 w-full min-w-0 rounded-md border border-hairline bg-canvas px-4 text-ink transition-colors selection:bg-primary selection:text-on-primary placeholder:text-ink-placeholder disabled:pointer-events-none disabled:text-ink-disabled",
        "focus-visible:border-hairline-strong focus-visible:ring-1 focus-visible:ring-hairline-strong focus-visible:outline-none",
        className
      )}
      {...props}
    />
  )
}

export { Input }
