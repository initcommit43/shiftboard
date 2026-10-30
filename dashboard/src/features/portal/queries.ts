import { keepPreviousData, useQuery } from '@tanstack/react-query'

import { clientPortalApi } from '@/api/client'
import type { ClientShiftPeriod } from '@/api/generated'

export const PAGE_SIZE = 20

export const portalKeys = {
  list: (period: ClientShiftPeriod, page: number) => ['portal', 'shifts', period, page] as const,
  detail: (shiftId: string) => ['portal', 'shift', shiftId] as const,
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
