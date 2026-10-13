import * as React from "react"
import { cn } from "@/lib/utils"

function Textarea({ className, ...props }: React.ComponentProps<"textarea">) {
  return (
    <textarea
      data-slot="textarea"
      className={cn(
        "type-body-md min-h-28 w-full min-w-0 rounded-md border border-hairline bg-canvas px-4 py-3.5 text-ink transition-colors selection:bg-primary selection:text-on-primary placeholder:text-ink-placeholder disabled:pointer-events-none disabled:text-ink-disabled",
        "focus-visible:border-hairline-strong focus-visible:ring-1 focus-visible:ring-hairline-strong focus-visible:outline-none",
        "aria-invalid:border-danger aria-invalid:ring-danger",
        className
      )}
      {...props}
    />
  )
}

export { Textarea }
