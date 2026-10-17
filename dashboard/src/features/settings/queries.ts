import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'

import { settingsApi } from '@/api/client'
import type { AgencySettings } from '@/api/generated'

export const settingsKeys = {
  agency: ['agency-settings'] as const,
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
