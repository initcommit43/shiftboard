import { CircleAlert, CircleCheck } from "lucide-react"
import { Toaster as Sonner, type ToasterProps } from "sonner"

// Unstyled, so that the toast takes every color from the design tokens.
function Toaster(props: ToasterProps) {
  return (
    <Sonner
      position="bottom-right"
      offset={24}
      icons={{
        success: <CircleCheck aria-hidden className="size-5 text-success" />,
        error: <CircleAlert aria-hidden className="size-5 text-destructive" />,
      }}
      toastOptions={{
        unstyled: true,
        classNames: {
          toast:
            "flex w-[380px] max-w-[calc(100vw-3rem)] items-start gap-3 rounded-lg border bg-popover p-4 text-sm text-popover-foreground shadow-lg",
          content: "flex flex-col gap-1",
          title: "font-medium",
          description: "text-muted-foreground",
        },
      }}
      {...props}
    />
  )
}

export { Toaster }
