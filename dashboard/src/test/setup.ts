import '@testing-library/jest-dom/vitest'
import '@/i18n'

import { cleanup } from '@testing-library/react'
import { afterEach } from 'vitest'

import { logout } from '@/features/auth/session'

// jsdom does not lay out, so it has no scrolling.
Element.prototype.scrollIntoView = () => undefined

afterEach(() => {
  cleanup()
  // Session and tokens are module state: every test starts signed out.
  logout()
  localStorage.clear()
})
