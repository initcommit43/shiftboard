import { useMutation } from '@tanstack/react-query'
import { CircleAlert, LoaderCircle } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useNavigate, useSearchParams } from 'react-router'

import { ApiError, errorMessage } from '@/api/errors'
import { Alert, AlertTitle } from '@/components/ui/alert'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

import { AuthLayout } from './auth-layout'
import { redirectTarget } from './guards'
import { login } from './session'

export function LoginPage() {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const [searchParams] = useSearchParams()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')

  const submit = useMutation({
    mutationFn: ({ email, password }: { email: string; password: string }) =>
      login(email, password),
    // Client users land on '/' and are taken on to their portal from there.
    onSuccess: () => navigate(redirectTarget(searchParams), { replace: true }),
  })

  return (
    <AuthLayout>
      <div className="space-y-2">
        <h1 className="type-heading-lg">{t('login.title')}</h1>
        <p className="text-ink-secondary">{t('login.description')}</p>
      </div>

      {submit.isError && (
        <Alert variant="destructive">
          <CircleAlert aria-hidden />
          <AlertTitle>
            {/* A client user can't do anything about the switch; the generic text speaks to the agency. */}
            {submit.error instanceof ApiError && submit.error.code === 'client_portal_off'
              ? t('login.clientPortalOff')
              : errorMessage(t, submit.error)}
          </AlertTitle>
        </Alert>
      )}

      <form
        className="flex flex-col gap-8"
        onSubmit={(event) => {
          event.preventDefault()
          submit.mutate({ email, password })
        }}
      >
        <div className="flex flex-col gap-4">
          <div className="flex flex-col gap-2">
            <Label htmlFor="email">{t('login.email')}</Label>
            <Input
              id="email"
              name="email"
              type="email"
              autoComplete="username"
              placeholder={t('login.emailPlaceholder')}
              value={email}
              onChange={(event) => {
                setEmail(event.target.value)
              }}
              required
              autoFocus
            />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="password">{t('login.password')}</Label>
            <Input
              id="password"
              name="password"
              type="password"
              autoComplete="current-password"
              placeholder={t('login.passwordPlaceholder')}
              value={password}
              onChange={(event) => {
                setPassword(event.target.value)
              }}
              required
            />
          </div>
        </div>
        <Button type="submit" className="w-full" disabled={submit.isPending}>
          {submit.isPending && <LoaderCircle aria-hidden className="animate-spin" />}
          {t('login.submit')}
        </Button>
      </form>

      <p className="type-body-sm text-ink-secondary">{t('login.workerHint')}</p>
    </AuthLayout>
  )
}
