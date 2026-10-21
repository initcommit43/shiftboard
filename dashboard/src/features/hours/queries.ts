import { useMutation, useQueryClient } from '@tanstack/react-query'
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'

import { hoursApi } from '@/api/client'
import type { HoursRequest, ShiftAssignment } from '@/api/generated'
import { shiftKeys, workerName } from '@/features/shifts/queries'

export const hoursKeys = {
  all: ['hours'] as const,
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
