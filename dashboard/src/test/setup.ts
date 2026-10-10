import '@testing-library/jest-dom/vitest'
import '@/i18n'

import { cleanup } from '@testing-library/react'
import { afterEach } from 'vitest'

import { logout } from '@/features/auth/session'

afterEach(() => {
  cleanup()
  // Session and tokens are module state: every test starts signed out.
  logout()
  localStorage.clear()
})
