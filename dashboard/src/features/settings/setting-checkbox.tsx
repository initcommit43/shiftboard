import { Label } from '@/components/ui/label'

/** One setting that is on or off, with a hint below its label. */
export function SettingCheckbox({
  id,
  label,
  hint,
  checked,
  disabled,
  onChange,
}: {
  id: string
  label: string
  hint: string
  checked: boolean
  disabled: boolean
  onChange: (checked: boolean) => void
}) {
  return (
    <div className="flex items-start gap-4">
      <input
        id={id}
        type="checkbox"
        className="mt-1 size-5 shrink-0 accent-action"
        checked={checked}
        disabled={disabled}
        aria-describedby={`${id}-hint`}
        onChange={(event) => {
          onChange(event.target.checked)
        }}
      />
      <div className="space-y-1">
        <Label htmlFor={id} className="type-body-md-bold text-ink">
          {label}
        </Label>
        <p id={`${id}-hint`} className="type-body-sm text-ink-secondary">
          {hint}
        </p>
      </div>
    </div>
  )
}
