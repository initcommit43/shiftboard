import { ChevronDown, LogOut } from 'lucide-react'
import { useTranslation } from 'react-i18next'

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
  const role = t(`roles.${user.role}`)

  return (
    <DropdownMenu>
      <DropdownMenuTrigger
        aria-label={t('shell.userMenu.open')}
        className="flex h-11 items-center gap-3 rounded-lg px-2 text-left transition-colors outline-none hover:bg-accent focus-visible:ring-[3px] focus-visible:ring-ring/50 data-[state=open]:bg-accent"
      >
        <span
          aria-hidden
          className="grid size-8 place-items-center rounded-full bg-secondary text-xs font-medium text-secondary-foreground"
        >
          {initials(user.email.split('@')[0] ?? '')}
        </span>
        <span className="hidden min-w-0 sm:block">
          <span className="block truncate text-sm leading-5 font-medium">{user.email}</span>
          <span className="block text-xs leading-4 text-muted-foreground">{role}</span>
        </span>
        <ChevronDown aria-hidden className="size-4" />
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-60">
        <DropdownMenuLabel>
          <span className="block truncate leading-5">{user.email}</span>
          <span className="block text-xs leading-4 font-normal text-muted-foreground">{role}</span>
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
