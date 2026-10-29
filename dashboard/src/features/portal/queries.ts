import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'

import { clientPortalApi } from '@/api/client'
import { errorMessage } from '@/api/errors'
import type { ClientShiftPeriod, StaffRequest, StaffRequestRequest } from '@/api/generated'

export const PAGE_SIZE = 20

export const portalKeys = {
  list: (period: ClientShiftPeriod, page: number) => ['portal', 'shifts', period, page] as const,
  detail: (shiftId: string) => ['portal', 'shift', shiftId] as const,
  requests: ['portal', 'requests'] as const,
  requestPage: (page: number) => ['portal', 'requests', page] as const,
  locations: ['portal', 'locations'] as const,
}

/** The client's shifts; drafts are left out by the API. */
export function useClientShifts(period: ClientShiftPeriod, page: number) {
  return useQuery({
    queryKey: portalKeys.list(period, page),
    queryFn: ({ signal }) =>
      clientPortalApi.listClientShifts({ period, page, size: PAGE_SIZE }, { signal }),
    placeholderData: keepPreviousData,
  })
}

/** One of the client's shifts with the names of the confirmed workers. */
export function useClientShift(shiftId: string) {
  return useQuery({
    queryKey: portalKeys.detail(shiftId),
    queryFn: ({ signal }) => clientPortalApi.getClientShift({ shiftId }, { signal }),
  })
}

/** Everyone at the client's requests for staff, newest first, whatever their status. */
export function useClientStaffRequests(page: number) {
  return useQuery({
    queryKey: portalKeys.requestPage(page),
    queryFn: ({ signal }) =>
      clientPortalApi.listClientStaffRequests({ page, size: PAGE_SIZE }, { signal }),
    placeholderData: keepPreviousData,
  })
}

/** The client's locations, sorted by name. */
export function useClientLocations() {
  return useQuery({
    queryKey: portalKeys.locations,
    queryFn: ({ signal }) => clientPortalApi.listClientLocations({ signal }),
  })
}

export function useCreateClientStaffRequest() {
  const { t } = useTranslation()
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (staffRequestRequest: StaffRequestRequest) =>
      clientPortalApi.createClientStaffRequest({ staffRequestRequest }),
    onSuccess: (request) => {
      toast.success(t('portal.requests.sent.title', { role: request.role }), {
        description: t('portal.requests.sent.description'),
      })
      return queryClient.invalidateQueries({ queryKey: portalKeys.requests })
    },
  })
}

export function useWithdrawClientStaffRequest() {
  const { t } = useTranslation()
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (request: StaffRequest) =>
      clientPortalApi.withdrawClientStaffRequest({ requestId: request.id }),
    onSuccess: (request) => {
      toast.success(t('portal.requests.withdraw.done', { role: request.role }))
    },
    onError: (error) => {
      toast.error(errorMessage(t, error))
    },
    // Also after an error: the agency may have handled the request in the meantime.
    onSettled: () => queryClient.invalidateQueries({ queryKey: portalKeys.requests }),
  })
}
