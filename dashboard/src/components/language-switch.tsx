import { Languages } from 'lucide-react'
import { useTranslation } from 'react-i18next'

import { Button } from '@/components/ui/button'
import { currentLanguage, languages } from '@/i18n'

export function LanguageSwitch() {
  const { t, i18n } = useTranslation()
  const current = currentLanguage()
  const next = languages[(languages.indexOf(current) + 1) % languages.length] ?? current

  return (
    <Button
      variant="ghost"
      size="sm"
      aria-label={t('shell.language.switchTo', { language: t(`shell.language.${next}`) })}
      onClick={() => {
        void i18n.changeLanguage(next)
      }}
    >
      <Languages aria-hidden />
      <span className="uppercase">{current}</span>
    </Button>
  )
}
