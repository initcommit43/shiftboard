import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { CircleAlert, LinkIcon, LoaderCircle, PowerOff, TriangleAlert } from 'lucide-react'
import { type ReactNode, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Link, useNavigate, useParams } from 'react-router'

import { clientUsersApi } from '@/api/client'
import { ApiError, errorMessage } from '@/api/errors'
import type { ClientSetupInfo } from '@/api/generated'
import { Alert, AlertTitle } from '@/components/ui/alert'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Skeleton } from '@/components/ui/skeleton'

import { AuthLayout } from './auth-layout'
import { PORTAL_PATH } from './guards'
import { completeClientSetup } from './session'

const PASSWORD_MIN = 8
const PASSWORD_MAX = 128

/** Public page behind a client user's setup link: sets their password and logs them in (ADR 0032). */
export function ClientSetupPage() {
  const { setupCode = '' } = useParams()
  const { t } = useTranslation()
  const info = useQuery({
    queryKey: ['client-setup', setupCode],
    queryFn: ({ signal }) => clientUsersApi.getClientSetupInfo({ setupCode }, { signal }),
  })

  if (info.isPending) {
    return (
      <AuthLayout>
        <div role="status" aria-label={t('clientSetup.loading')} className="flex flex-col gap-4">
          <Skeleton className="h-9 w-64" />
          <Skeleton className="h-4 w-full" />
          <Skeleton className="h-14 rounded-md" />
          <Skeleton className="h-14 rounded-md" />
        </div>
      </AuthLayout>
    )
  }

  if (info.isError) {
    return <SetupError error={info.error} retrying={info.isFetching} onRetry={() => void info.refetch()} />
  }

  return <SetupForm setupCode={setupCode} info={info.data} />
}

function SetupError({
  error,
  retrying,
  onRetry,
}: {
  error: Error
  retrying: boolean
  onRetry: () => void
}) {
  const { t } = useTranslation()
  const code = error instanceof ApiError ? error.code : undefined

  if (code === 'setup_code_invalid') {
    return (
      <Message
        icon={<LinkIcon />}
        title={t('clientSetup.invalid.title')}
        description={t('clientSetup.invalid.description')}
        action={
          <Button asChild variant="outline">
            <Link to="/login">{t('clientSetup.toLogin')}</Link>
          </Button>
        }
      />
    )
  }
  if (code === 'client_portal_off') {
    return (
      <Message
        icon={<PowerOff />}
        title={t('clientSetup.portalOff.title')}
        description={t('clientSetup.portalOff.description')}
      />
    )
  }
  return (
    <Message
      icon={<TriangleAlert className="text-danger-text" />}
      title={t('clientSetup.error.title')}
      description={errorMessage(t, error)}
      action={
        <Button variant="outline" disabled={retrying} onClick={onRetry}>
          {t('clientSetup.error.retry')}
        </Button>
      }
    />
  )
}

function Message({
  icon,
  title,
  description,
  action,
}: {
  icon: ReactNode
  title: string
  description: string
  action?: ReactNode
}) {
  return (
    <AuthLayout>
      <span aria-hidden className="text-ink-tertiary [&>svg]:size-8">
        {icon}
      </span>
      <div className="space-y-2">
        <h1 className="type-heading-lg">{title}</h1>
        <p className="text-ink-secondary">{description}</p>
      </div>
      {action && <div>{action}</div>}
    </AuthLayout>
  )
}

type PasswordError = 'too_short' | 'required'

function SetupForm({ setupCode, info }: { setupCode: string; info: ClientSetupInfo }) {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const [password, setPassword] = useState('')
  const [confirmation, setConfirmation] = useState('')
  const [passwordError, setPasswordError] = useState<PasswordError | null>(null)
  const [mismatch, setMismatch] = useState(false)

  const submit = useMutation({
    mutationFn: (password: string) => completeClientSetup(setupCode, password),
    onSuccess: async () => {
      await navigate(PORTAL_PATH, { replace: true })
      // Whatever was cached belongs to whoever used this browser before.
      queryClient.clear()
    },
    onError: (error) => {
      const rejected =
        error instanceof ApiError ? error.fieldErrors.find((it) => it.field === 'password') : undefined
      if (rejected) {
        setPasswordError(rejected.code === 'required' ? 'required' : 'too_short')
        document.getElementById('setup-password')?.focus()
      }
    },
  })

  return (
    <AuthLayout>
      <div className="space-y-2">
        <h1 className="type-heading-lg">{t('clientSetup.title')}</h1>
        <p className="text-ink-secondary">
          {t('clientSetup.greeting', {
            firstName: info.firstName,
            agency: info.agencyName,
            client: info.clientName,
          })}
        </p>
      </div>

      {submit.isError && passwordError === null && (
        <Alert variant="destructive">
          <CircleAlert aria-hidden />
          <AlertTitle>{errorMessage(t, submit.error)}</AlertTitle>
        </Alert>
      )}

      <form
        noValidate
        className="flex flex-col gap-8"
        onSubmit={(event) => {
          event.preventDefault()
          if (password.length < PASSWORD_MIN) {
            setPasswordError(password ? 'too_short' : 'required')
            document.getElementById('setup-password')?.focus()
            return
          }
          if (password !== confirmation) {
            setMismatch(true)
            document.getElementById('setup-confirmation')?.focus()
            return
          }
          submit.mutate(password)
        }}
      >
        <div className="flex flex-col gap-4">
          <div className="flex flex-col gap-2">
            <Label htmlFor="setup-email">{t('clientSetup.email')}</Label>
            {/* Read-only, so that password managers save the new password with the right account. */}
            <Input id="setup-email" name="email" type="email" autoComplete="username" value={info.email} readOnly />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="setup-password">{t('clientSetup.password')}</Label>
            <Input
              id="setup-password"
              name="password"
              type="password"
              autoComplete="new-password"
              maxLength={PASSWORD_MAX}
              value={password}
              aria-invalid={passwordError !== null}
              aria-describedby={passwordError ? 'setup-password-error' : 'setup-password-hint'}
              onChange={(event) => {
                setPassword(event.target.value)
                setPasswordError(null)
              }}
              autoFocus
            />
            {passwordError ? (
              <p id="setup-password-error" className="type-body-sm text-danger-text">
                {t(`clientSetup.errors.${passwordError}`)}
              </p>
            ) : (
              <p id="setup-password-hint" className="type-body-sm text-ink-secondary">
                {t('clientSetup.passwordHint')}
              </p>
            )}
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="setup-confirmation">{t('clientSetup.confirmation')}</Label>
            <Input
              id="setup-confirmation"
              name="confirmation"
              type="password"
              autoComplete="new-password"
              maxLength={PASSWORD_MAX}
              value={confirmation}
              aria-invalid={mismatch}
              aria-describedby={mismatch ? 'setup-confirmation-error' : undefined}
              onChange={(event) => {
                setConfirmation(event.target.value)
                setMismatch(false)
              }}
            />
            {mismatch && (
              <p id="setup-confirmation-error" className="type-body-sm text-danger-text">
                {t('clientSetup.errors.mismatch')}
              </p>
            )}
          </div>
        </div>
        <Button type="submit" className="w-full" disabled={submit.isPending}>
          {submit.isPending && <LoaderCircle aria-hidden className="animate-spin" />}
          {t('clientSetup.submit')}
        </Button>
      </form>
    </AuthLayout>
  )
}
