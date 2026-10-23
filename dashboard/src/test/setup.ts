import '@testing-library/jest-dom/vitest'
import '@/i18n'

import { cleanup } from '@testing-library/react'
import { toast } from 'sonner'
import { afterEach } from 'vitest'

import { logout } from '@/features/auth/session'

// jsdom does not lay out, so it has no scrolling.
Element.prototype.scrollIntoView = () => undefined

afterEach(() => {
  cleanup()
  // Toasts are module state too, and a new toaster shows the ones still active.
  toast.dismiss()
  // Session and tokens are module state: every test starts signed out.
  logout()
  localStorage.clear()
})
