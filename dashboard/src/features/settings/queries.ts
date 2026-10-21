import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'

import { settingsApi } from '@/api/client'
import type { AgencyFeatures, AgencySettings } from '@/api/generated'

export const settingsKeys = {
  agency: ['agency-settings'] as const,
  features: ['agency-features'] as const,
}

export function useAgencyFeatures() {
  return useQuery({
    queryKey: settingsKeys.features,
    queryFn: ({ signal }) => settingsApi.getAgencyFeatures({ signal }),
  })
}

export function useSaveAgencyFeatures() {
  const { t } = useTranslation()
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (agencyFeatures: AgencyFeatures) =>
      settingsApi.updateAgencyFeatures({ agencyFeatures }),
    onSuccess: (saved) => {
      queryClient.setQueryData(settingsKeys.features, saved)
      toast.success(t('settings.features.saved'))
    },
  })
}

export function useAgencySettings() {
  return useQuery({
    queryKey: settingsKeys.agency,
    queryFn: ({ signal }) => settingsApi.getAgencySettings({ signal }),
  })
}

export function useSaveAgencySettings() {
  const { t } = useTranslation()
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (agencySettings: AgencySettings) =>
      settingsApi.updateAgencySettings({ agencySettings }),
    onSuccess: (saved) => {
      queryClient.setQueryData(settingsKeys.agency, saved)
      toast.success(t('settings.saved'))
    },
  })
}
