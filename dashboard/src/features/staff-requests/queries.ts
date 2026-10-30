import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'

import { staffRequestsApi } from '@/api/client'
import { type StaffRequest, type StaffRequestPage, StaffRequestStatus } from '@/api/generated'
import { useClientPortalOn } from '@/features/clients/queries'

export const PAGE_SIZE = 20

// Everything about requests lives under one key, so that a decision refreshes the lists and the count together.
export const staffRequestKeys = {
  all: ['staff-requests'] as const,
  list: (status: StaffRequestStatus, page: number) => ['staff-requests', 'list', status, page] as const,
  detail: (requestId: string) => ['staff-requests', 'detail', requestId] as const,
}

function staffRequestsQuery(status: StaffRequestStatus, page: number) {
  return {
    queryKey: staffRequestKeys.list(status, page),
    queryFn: ({ signal }: { signal: AbortSignal }) =>
      staffRequestsApi.listStaffRequests({ status, page, size: PAGE_SIZE }, { signal }),
  }
}

/** Open requests earliest start first; handled ones latest first. */
export function useStaffRequests(status: StaffRequestStatus, page: number) {
  return useQuery({ ...staffRequestsQuery(status, page), placeholderData: keepPreviousData })
}

/**
 * Number of open requests, read from the first page so that it shares the list's cache entry.
 * Only asked for while the client portal is switched on.
 */
export function useOpenStaffRequestCount() {
  const on = useClientPortalOn()
  return useQuery({
    ...staffRequestsQuery(StaffRequestStatus.OPEN, 0),
    enabled: on,
    select: (data: StaffRequestPage) => data.totalElements,
  }).data
}

export function useStaffRequest(requestId: string) {
  return useQuery({
    queryKey: staffRequestKeys.detail(requestId),
    queryFn: ({ signal }) => staffRequestsApi.getStaffRequest({ requestId }, { signal }),
  })
}

export function useDeclineStaffRequest() {
  const { t } = useTranslation()
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: ({ request, reason }: { request: StaffRequest; reason: string }) =>
      staffRequestsApi.declineStaffRequest({
        requestId: request.id,
        staffRequestDecline: { reason },
      }),
    onSuccess: (declined) => {
      toast.success(t('staffRequests.decline.done', { client: declined.client.name }), {
        description: t('staffRequests.decline.doneDescription'),
      })
    },
    // Also after an error: the client may have withdrawn it, or a colleague handled it.
    onSettled: () => queryClient.invalidateQueries({ queryKey: staffRequestKeys.all }),
  })
}
