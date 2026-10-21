import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'

import { hoursApi } from '@/api/client'
import type { HoursRequest, ShiftAssignment } from '@/api/generated'
import { shiftKeys, workerName } from '@/features/shifts/queries'

/** The hours page shows a whole period at once; the API caps a page at 100. */
const HOURS_SIZE = 100

export const hoursKeys = {
  all: ['hours'] as const,
  period: (from: Date, to: Date) => ['hours', 'period', from.toISOString(), to.toISOString()] as const,
}

/** Every entry of shifts starting in `[from, to)`, by shift start; all pages at once. */
export function useHoursOfPeriod(range: { from: Date; to: Date } | null) {
  return useQuery({
    queryKey: range ? hoursKeys.period(range.from, range.to) : hoursKeys.all,
    queryFn: async ({ signal }) => {
      if (!range) {
        return []
      }
      const request = (page: number) =>
        hoursApi.listHours({ ...range, page, size: HOURS_SIZE }, { signal })
      const first = await request(0)
      const rest = await Promise.all(
        Array.from({ length: Math.max(0, first.totalPages - 1) }, (_, index) => request(index + 1)),
      )
      return [first, ...rest].flatMap((page) => page.content)
    },
    enabled: range !== null,
  })
}

/** Saves and so approves the hours of one worker. Saving again replaces them. */
export function useApproveHours(shiftId: string) {
  const { t } = useTranslation()
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: ({ assignment, request }: { assignment: ShiftAssignment; request: HoursRequest }) =>
      hoursApi.approveHours({ shiftId, assignmentId: assignment.id, hoursRequest: request }),
    onSuccess: (_data, { assignment }) => {
      toast.success(t('hours.approved', { name: workerName(assignment) }))
    },
    // Also after an error: the worker may have been removed or the hours changed meanwhile.
    onSettled: () =>
      Promise.all([
        queryClient.invalidateQueries({ queryKey: shiftKeys.all }),
        queryClient.invalidateQueries({ queryKey: hoursKeys.all }),
      ]),
  })
}
