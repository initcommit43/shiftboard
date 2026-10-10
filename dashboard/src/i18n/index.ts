import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'

import de from './locales/de.json'
import en from './locales/en.json'

export const languages = ['de', 'en'] as const
export type Language = (typeof languages)[number]

const STORAGE_KEY = 'shiftboard.language'

function isLanguage(value: unknown): value is Language {
  return languages.some((language) => language === value)
}

// German is the source language; every other locale must provide the same keys.
const resources = {
  de: { translation: de },
  en: { translation: en },
} satisfies Record<Language, { translation: typeof de }>

const stored = localStorage.getItem(STORAGE_KEY)

void i18n.use(initReactI18next).init({
  resources,
  lng: isLanguage(stored) ? stored : 'de',
  fallbackLng: 'de',
  interpolation: { escapeValue: false },
})

i18n.on('languageChanged', (language) => {
  document.documentElement.lang = language
  localStorage.setItem(STORAGE_KEY, language)
})

export function currentLanguage(): Language {
  return isLanguage(i18n.language) ? i18n.language : 'de'
}

export default i18n
