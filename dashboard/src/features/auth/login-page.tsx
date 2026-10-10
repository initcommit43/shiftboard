import { useMutation } from '@tanstack/react-query'
import { CircleAlert, LoaderCircle } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useNavigate, useSearchParams } from 'react-router'

import { errorMessage } from '@/api/errors'
import { Brand } from '@/components/brand'
import { LanguageSwitch } from '@/components/language-switch'
import { ThemeToggle } from '@/components/theme-toggle'
import { Alert, AlertTitle } from '@/components/ui/alert'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

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
    onSuccess: () => navigate(redirectTarget(searchParams), { replace: true }),
  })

  return (
    <div className="relative flex min-h-svh flex-col items-center justify-center gap-8 px-4 py-12">
      <div className="absolute top-4 right-4 flex items-center gap-1">
        <LanguageSwitch />
        <ThemeToggle />
      </div>

      <Brand size="lg" />

      <Card className="w-full max-w-[25rem] p-8">
        <div className="space-y-2">
          <h1 className="text-xl leading-7 font-semibold tracking-[-0.0125rem]">
            {t('login.title')}
          </h1>
          <p className="text-sm text-muted-foreground">{t('login.description')}</p>
        </div>

        {submit.isError && (
          <Alert variant="destructive">
            <CircleAlert aria-hidden />
            <AlertTitle>{errorMessage(t, submit.error)}</AlertTitle>
          </Alert>
        )}

        <form
          className="flex flex-col gap-6"
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
      </Card>

      <p className="text-center text-sm text-muted-foreground">{t('login.workerHint')}</p>
    </div>
  )
}
