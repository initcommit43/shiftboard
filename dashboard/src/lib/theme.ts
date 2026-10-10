export type Theme = 'light' | 'dark'

const STORAGE_KEY = 'shiftboard.theme'

function apply(theme: Theme) {
  document.documentElement.classList.toggle('dark', theme === 'dark')
}

export function currentTheme(): Theme {
  return document.documentElement.classList.contains('dark') ? 'dark' : 'light'
}

/** Applies the stored choice, falling back to the system preference. */
export function initTheme() {
  const stored = localStorage.getItem(STORAGE_KEY)
  if (stored === 'light' || stored === 'dark') {
    apply(stored)
  } else {
    apply(window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light')
  }
}

export function toggleTheme(): Theme {
  const next = currentTheme() === 'dark' ? 'light' : 'dark'
  apply(next)
  localStorage.setItem(STORAGE_KEY, next)
  return next
}
