import { BookmarkPlus, CircleAlert, LoaderCircle } from 'lucide-react'
import { useId, useState } from 'react'
import { useTranslation } from 'react-i18next'

import { ApiError, errorMessage } from '@/api/errors'
import type { FieldError, ShiftTemplateRequest } from '@/api/generated'
import { Alert, AlertTitle } from '@/components/ui/alert'
import {
  AlertDialog,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

import { useCreateShiftTemplate } from './queries'

const NAME_MAX = 80

type NameError = 'required' | 'taken'

/**
 * Saves a shift as a named template for the whole agency. `prepare` returns the template
 * without its name, or null when the shift is not complete yet; the dialog then stays shut.
 */
export function SaveAsTemplate({
  prepare,
  defaultName,
  onFieldErrors,
}: {
  prepare: () => Omit<ShiftTemplateRequest, 'name'> | null
  defaultName: string
  /** Field errors that belong on a form rather than in the dialog. */
  onFieldErrors?: (errors: FieldError[]) => void
}) {
  const { t } = useTranslation()
  const save = useCreateShiftTemplate()
  const id = useId()
  const [request, setRequest] = useState<Omit<ShiftTemplateRequest, 'name'> | null>(null)
  const [name, setName] = useState('')
  const [nameError, setNameError] = useState<NameError | null>(null)

  function close() {
    setRequest(null)
    setNameError(null)
    save.reset()
  }

  return (
    <>
      <Button
        type="button"
        variant="outline"
        onClick={() => {
          const prepared = prepare()
          if (prepared) {
            setName(defaultName.slice(0, NAME_MAX))
            setRequest(prepared)
          }
        }}
      >
        <BookmarkPlus aria-hidden />
        {t('templates.save.action')}
      </Button>
      <AlertDialog
        open={request !== null}
        onOpenChange={(open) => {
          if (!open && !save.isPending) {
            close()
          }
        }}
      >
        <AlertDialogContent>
          <form
            noValidate
            className="contents"
            onSubmit={(event) => {
              event.preventDefault()
              const trimmed = name.trim()
              if (!request) {
                return
              }
              if (!trimmed) {
                setNameError('required')
                document.getElementById(id)?.focus()
                return
              }
              save.mutate(
                { ...request, name: trimmed },
                {
                  onSuccess: close,
                  onError: (error) => {
                    if (error instanceof ApiError && error.code === 'template_name_taken') {
                      setNameError('taken')
                      document.getElementById(id)?.focus()
                    } else if (
                      error instanceof ApiError &&
                      error.fieldErrors.length > 0 &&
                      onFieldErrors
                    ) {
                      onFieldErrors(error.fieldErrors)
                      close()
                    }
                  },
                },
              )
            }}
          >
            <AlertDialogHeader>
              <AlertDialogTitle>{t('templates.save.title')}</AlertDialogTitle>
              <AlertDialogDescription>{t('templates.save.description')}</AlertDialogDescription>
            </AlertDialogHeader>
            {save.isError && nameError === null && (
              <Alert variant="destructive">
                <CircleAlert aria-hidden />
                <AlertTitle>{errorMessage(t, save.error)}</AlertTitle>
              </Alert>
            )}
            <div className="flex flex-col gap-2">
              <Label htmlFor={id}>{t('templates.save.name')}</Label>
              <Input
                id={id}
                maxLength={NAME_MAX}
                value={name}
                aria-invalid={nameError !== null}
                aria-describedby={nameError ? `${id}-error` : `${id}-hint`}
                onChange={(event) => {
                  setName(event.target.value)
                  setNameError(null)
                }}
              />
              {nameError ? (
                <p id={`${id}-error`} className="type-body-sm text-danger-text">
                  {t(`templates.save.errors.${nameError}`)}
                </p>
              ) : (
                <p id={`${id}-hint`} className="type-body-sm text-ink-secondary">
                  {t('templates.save.nameHint')}
                </p>
              )}
            </div>
            <AlertDialogFooter>
              <AlertDialogCancel asChild>
                <Button type="button" variant="outline" disabled={save.isPending}>
                  {t('templates.save.cancel')}
                </Button>
              </AlertDialogCancel>
              <Button type="submit" disabled={save.isPending}>
                {save.isPending && <LoaderCircle aria-hidden className="animate-spin" />}
                {t('templates.save.confirm')}
              </Button>
            </AlertDialogFooter>
          </form>
        </AlertDialogContent>
      </AlertDialog>
    </>
  )
}
