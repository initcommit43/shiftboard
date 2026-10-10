import { Moon, Sun } from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'

import { Button } from '@/components/ui/button'
import { currentTheme, toggleTheme } from '@/lib/theme'

export function ThemeToggle() {
  const { t } = useTranslation()
  const [theme, setTheme] = useState(currentTheme)
  const isDark = theme === 'dark'

  return (
    <Button
      variant="ghost"
      size="icon-sm"
      aria-label={isDark ? t('shell.theme.toLight') : t('shell.theme.toDark')}
      onClick={() => {
        setTheme(toggleTheme())
      }}
    >
      {isDark ? <Sun aria-hidden /> : <Moon aria-hidden />}
    </Button>
  )
}
