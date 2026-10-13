import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'

import { clientsApi, shiftsApi } from '@/api/client'
import { errorMessage } from '@/api/errors'
import type { Shift, ShiftRequest } from '@/api/generated'

export const PAGE_SIZE = 20

/** The form offers every client and qualification at once; the API caps a page at 100. */
const OPTIONS_SIZE = 100

export const shiftKeys = {
  upcoming: ['shifts', 'upcoming'] as const,
  upcomingPage: (page: number) => [...shiftKeys.upcoming, page] as const,
  formOptions: ['shifts', 'form-options'] as const,
}

export function useUpcomingShifts(page: number) {
  return useQuery({
    queryKey: shiftKeys.upcomingPage(page),
    queryFn: ({ signal }) => shiftsApi.listShifts({ page, size: PAGE_SIZE }, { signal }),
    placeholderData: keepPreviousData,
  })
}

/** What the shift form offers to choose from: clients with their locations, and qualifications. */
export function useShiftFormOptions() {
  return useQuery({
    queryKey: shiftKeys.formOptions,
    queryFn: async ({ signal }) => {
      const [clients, qualifications] = await Promise.all([
        clientsApi.listClients({ size: OPTIONS_SIZE }, { signal }),
        clientsApi.listQualifications({ size: OPTIONS_SIZE }, { signal }),
      ])
      return { clients: clients.content, qualifications: qualifications.content }
    },
  })
}

export function useCreateShift() {
  const { t } = useTranslation()
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (shiftRequest: ShiftRequest) => shiftsApi.createShift({ shiftRequest }),
    onSuccess: (shift) => {
      toast.success(
        t(shift.status === 'PUBLISHED' ? 'shifts.created.published' : 'shifts.created.draft', {
          title: shift.title,
        }),
      )
      return queryClient.invalidateQueries({ queryKey: shiftKeys.upcoming })
    },
  })
}

export function usePublishShift() {
  const { t } = useTranslation()
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (shift: Shift) => shiftsApi.publishShift({ shiftId: shift.id }),
    onSuccess: (shift) => {
      toast.success(t('shifts.published.title', { title: shift.title }), {
        description: t('shifts.published.description'),
      })
    },
    onError: (error) => {
      toast.error(errorMessage(t, error))
    },
    // Also after an error: someone else may have published or removed the shift.
    onSettled: () => queryClient.invalidateQueries({ queryKey: shiftKeys.upcoming }),
  })
}
