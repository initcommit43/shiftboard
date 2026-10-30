import { CircleAlert, LoaderCircle, UserPlus } from 'lucide-react'
import { useId, useState } from 'react'
import { useTranslation } from 'react-i18next'

import { ApiError, errorMessage } from '@/api/errors'
import type { ClientUserInvitation, ClientUserRequest, FieldError } from '@/api/generated'
import { Alert, AlertTitle } from '@/components/ui/alert'
import {
  AlertDialog,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from '@/components/ui/alert-dialog'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

import { useInviteClientUser } from './queries'
import { SetupLinkContent } from './setup-link'

const NAME_MAX = 100
const EMAIL_MAX = 254

type Field = keyof ClientUserRequest
const FIELDS: Field[] = ['firstName', 'lastName', 'email']

type FieldErrorCode = 'required' | 'invalid_length' | 'invalid_format' | 'taken' | 'unknown'
// A field without an error is undefined: typing clears its error.
type Errors = Partial<Record<Field, FieldErrorCode | undefined>>

const KNOWN_CODES = new Set<string>(['required', 'invalid_length', 'invalid_format'])

function isField(field: string): field is Field {
  return (FIELDS as string[]).includes(field)
}

/** The field errors of a `validation_failed` response, placed on the fields of the form. */
function serverErrors(fieldErrors: FieldError[]): Errors {
  const errors: Errors = {}
  for (const { field, code } of fieldErrors) {
    if (isField(field)) {
      errors[field] = KNOWN_CODES.has(code) ? (code as FieldErrorCode) : 'unknown'
    }
  }
  return errors
}

const EMPTY: ClientUserRequest = { firstName: '', lastName: '', email: '' }

/** Gives someone at the client access to the portal, then shows the setup link to pass on. */
export function InviteClientUser({ clientId, clientName }: { clientId: string; clientName: string }) {
  const { t } = useTranslation()
  const invite = useInviteClientUser(clientId)
  const id = useId()
  const [open, setOpen] = useState(false)
  const [values, setValues] = useState<ClientUserRequest>(EMPTY)
  const [errors, setErrors] = useState<Errors>({})
  const [invitation, setInvitation] = useState<ClientUserInvitation | null>(null)

  function fieldId(field: Field) {
    return `${id}-${field}`
  }

  function focusFirst(found: Errors) {
    const first = FIELDS.find((field) => found[field])
    if (first) {
      document.getElementById(fieldId(first))?.focus()
    }
  }

  return (
    <AlertDialog
      open={open}
      onOpenChange={(next) => {
        if (invite.isPending) {
          return
        }
        setOpen(next)
        if (next) {
          setValues(EMPTY)
          setErrors({})
          setInvitation(null)
          invite.reset()
        }
      }}
    >
      <AlertDialogTrigger asChild>
        <Button>
          <UserPlus aria-hidden />
          {t('clients.users.invite.action')}
        </Button>
      </AlertDialogTrigger>
      <AlertDialogContent>
        {invitation ? (
          <SetupLinkContent invitation={invitation} />
        ) : (
          <form
            noValidate
            className="contents"
            onSubmit={(event) => {
              event.preventDefault()
              const request = {
                firstName: values.firstName.trim(),
                lastName: values.lastName.trim(),
                email: values.email.trim(),
              }
              const missing: Errors = {}
              for (const field of FIELDS) {
                if (!request[field]) {
                  missing[field] = 'required'
                }
              }
              if (FIELDS.some((field) => missing[field])) {
                setErrors(missing)
                focusFirst(missing)
                return
              }
              invite.mutate(request, {
                onSuccess: setInvitation,
                onError: (error) => {
                  if (!(error instanceof ApiError)) {
                    return
                  }
                  const rejected: Errors =
                    error.code === 'email_already_registered'
                      ? { email: 'taken' }
                      : serverErrors(error.fieldErrors)
                  setErrors(rejected)
                  focusFirst(rejected)
                },
              })
            }}
          >
            <AlertDialogHeader>
              <AlertDialogTitle>{t('clients.users.invite.title')}</AlertDialogTitle>
              <AlertDialogDescription>
                {t('clients.users.invite.description', { client: clientName })}
              </AlertDialogDescription>
            </AlertDialogHeader>
            {invite.isError && !FIELDS.some((field) => errors[field]) && (
              <Alert variant="destructive">
                <CircleAlert aria-hidden />
                <AlertTitle>{errorMessage(t, invite.error)}</AlertTitle>
              </Alert>
            )}
            <div className="flex flex-col gap-4">
              <div className="grid gap-4 sm:grid-cols-2">
                <TextField
                  id={fieldId('firstName')}
                  label={t('clients.users.invite.firstName')}
                  autoComplete="off"
                  maxLength={NAME_MAX}
                  value={values.firstName}
                  error={errors.firstName}
                  onChange={(firstName) => {
                    setValues({ ...values, firstName })
                    setErrors({ ...errors, firstName: undefined })
                  }}
                />
                <TextField
                  id={fieldId('lastName')}
                  label={t('clients.users.invite.lastName')}
                  autoComplete="off"
                  maxLength={NAME_MAX}
                  value={values.lastName}
                  error={errors.lastName}
                  onChange={(lastName) => {
                    setValues({ ...values, lastName })
                    setErrors({ ...errors, lastName: undefined })
                  }}
                />
              </div>
              <TextField
                id={fieldId('email')}
                label={t('clients.users.invite.email')}
                type="email"
                autoComplete="off"
                maxLength={EMAIL_MAX}
                value={values.email}
                error={errors.email}
                onChange={(email) => {
                  setValues({ ...values, email })
                  setErrors({ ...errors, email: undefined })
                }}
              />
            </div>
            <AlertDialogFooter>
              <AlertDialogCancel asChild>
                <Button type="button" variant="outline" disabled={invite.isPending}>
                  {t('clients.users.invite.cancel')}
                </Button>
              </AlertDialogCancel>
              <Button type="submit" disabled={invite.isPending}>
                {invite.isPending && <LoaderCircle aria-hidden className="animate-spin" />}
                {t('clients.users.invite.confirm')}
              </Button>
            </AlertDialogFooter>
          </form>
        )}
      </AlertDialogContent>
    </AlertDialog>
  )
}

function TextField({
  id,
  label,
  type = 'text',
  autoComplete,
  maxLength,
  value,
  error,
  onChange,
}: {
  id: string
  label: string
  type?: string
  autoComplete: string
  maxLength: number
  value: string
  error: FieldErrorCode | undefined
  onChange: (value: string) => void
}) {
  const { t } = useTranslation()

  return (
    <div className="flex flex-col gap-2">
      <Label htmlFor={id}>{label}</Label>
      <Input
        id={id}
        type={type}
        autoComplete={autoComplete}
        maxLength={maxLength}
        value={value}
        aria-invalid={error !== undefined}
        aria-describedby={error ? `${id}-error` : undefined}
        onChange={(event) => {
          onChange(event.target.value)
        }}
      />
      {error && (
        <p id={`${id}-error`} className="type-body-sm text-danger-text">
          {t(`clients.users.invite.errors.${error}`)}
        </p>
      )}
    </div>
  )
}
