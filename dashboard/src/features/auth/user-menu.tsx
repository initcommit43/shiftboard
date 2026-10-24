import { ChevronDown, LogOut } from 'lucide-react'
import { useTranslation } from 'react-i18next'

import { known } from '@/api/enums'
import { Role } from '@/api/generated'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { initials } from '@/lib/initials'

import { useCurrentUser, useLogout } from './use-session'

export function UserMenu() {
  const { t } = useTranslation()
  const user = useCurrentUser()
  const logout = useLogout()
  const knownRole = known(Role, user.role)
  const role = knownRole ? t(`roles.${knownRole}`) : t('unknownValue')

  return (
    <DropdownMenu>
      <DropdownMenuTrigger
        aria-label={t('shell.userMenu.open')}
        className="flex h-12 items-center gap-3 rounded-full pr-4 pl-1.5 text-left transition-colors hover:bg-surface-soft data-[state=open]:bg-surface-soft"
      >
        <span
          aria-hidden
          className="type-caption grid size-9 place-items-center rounded-full bg-action font-semibold text-on-action"
        >
          {initials(user.email.split('@')[0] ?? '')}
        </span>
        <span className="hidden min-w-0 sm:block">
          <span className="type-button-sm block truncate">{user.email}</span>
          <span className="type-caption block text-ink-secondary">{role}</span>
        </span>
        <ChevronDown aria-hidden className="size-4" />
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-64">
        <DropdownMenuLabel>
          <span className="block truncate">{user.email}</span>
          <span className="type-caption block text-ink-secondary">{role}</span>
        </DropdownMenuLabel>
        <DropdownMenuSeparator />
        <DropdownMenuItem
          onSelect={() => {
            void logout()
          }}
        >
          <LogOut aria-hidden />
          {t('shell.userMenu.logout')}
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
