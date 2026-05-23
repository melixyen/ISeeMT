import { computed, isRef } from 'vue'
import en from '../locales/en.json'
import zh from '../locales/zh.json'

const locales = { en, zh }

export function useI18n(langRef) {
  return computed(() => {
    const lang = isRef(langRef) ? langRef.value : langRef
    return locales[lang] ?? locales.en
  })
}
