import * as React from "react"
import { ChevronDown } from "lucide-react"
import { cn } from "@/lib/utils"

function NativeSelect({ className, ...props }: React.ComponentProps<"select">) {
  return (
    <div data-slot="native-select-wrapper" className="relative">
      <select
        data-slot="native-select"
        className={cn(
          "type-body-md h-14 w-full min-w-0 appearance-none rounded-md border border-hairline bg-canvas pr-11 pl-4 text-ink transition-colors disabled:pointer-events-none disabled:text-ink-disabled",
          "focus-visible:border-hairline-strong focus-visible:ring-1 focus-visible:ring-hairline-strong focus-visible:outline-none",
          "aria-invalid:border-danger aria-invalid:ring-danger",
          className
        )}
        {...props}
      />
      <ChevronDown
        aria-hidden
        className="pointer-events-none absolute top-1/2 right-4 size-4 -translate-y-1/2 text-ink-tertiary"
      />
    </div>
  )
}

export { NativeSelect }
