import type { ReactNode } from 'react'
import { useTranslation } from 'react-i18next'

import { Brand } from '@/components/brand'
import { LanguageSwitch } from '@/components/language-switch'
import { ThemeToggle } from '@/components/theme-toggle'

/** The frame of the pages before the dashboard: the storytelling band next to a narrow column. */
export function AuthLayout({ children }: { children: ReactNode }) {
  const { t } = useTranslation()

  return (
    <div className="grid min-h-svh lg:grid-cols-2">
      {/* The storytelling band: dark in both themes, next to the form on the canvas. */}
      <div className="dark hidden flex-col justify-between border-r bg-canvas p-12 text-ink lg:flex">
        <Brand size="lg" />
        <p className="type-display-lg xl:type-display-xl max-w-[9em]">{t('login.tagline')}</p>
      </div>

      <div className="relative flex flex-col items-center justify-center gap-8 px-6 py-24">
        <div className="absolute top-4 right-4 flex items-center gap-1">
          <LanguageSwitch />
          <ThemeToggle />
        </div>

        <div className="flex w-full max-w-[25rem] flex-col gap-8">
          <div className="lg:hidden">
            <Brand size="lg" />
          </div>
          {children}
        </div>
      </div>
    </div>
  )
}
