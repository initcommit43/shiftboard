import { CircleAlert, CircleCheck } from "lucide-react"
import { Toaster as Sonner, type ToasterProps } from "sonner"

// Unstyled, so that the toast takes every color from the design tokens. It is
// the inverse of the page, which sets it apart without a shadow.
function Toaster(props: ToasterProps) {
  return (
    <Sonner
      position="bottom-right"
      offset={24}
      icons={{
        success: <CircleCheck aria-hidden className="size-5" />,
        error: <CircleAlert aria-hidden className="size-5" />,
      }}
      toastOptions={{
        unstyled: true,
        classNames: {
          toast:
            "type-body-sm flex w-[380px] max-w-[calc(100vw-3rem)] items-start gap-3 rounded-md bg-action p-4 text-on-action",
          content: "flex flex-col gap-1",
          title: "font-semibold",
          description: "opacity-72",
        },
      }}
      {...props}
    />
  )
}

export { Toaster }
