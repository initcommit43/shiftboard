import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'

import { workersApi } from '@/api/client'
import { errorMessage } from '@/api/errors'
import { type Worker, type WorkerPage, WorkerStatus } from '@/api/generated'

export const PAGE_SIZE = 20

export const signupKeys = {
  pending: ['signups', 'pending'] as const,
  pendingPage: (page: number) => [...signupKeys.pending, page] as const,
}

function pendingSignupsQuery(page: number) {
  return {
    queryKey: signupKeys.pendingPage(page),
    queryFn: ({ signal }: { signal: AbortSignal }) =>
      workersApi.listWorkers({ status: WorkerStatus.PENDING, page, size: PAGE_SIZE }, { signal }),
  }
}

export function usePendingSignups(page: number) {
  return useQuery({ ...pendingSignupsQuery(page), placeholderData: keepPreviousData })
}

/** Number of pending signups, read from the first page so that it shares the list's cache entry. */
export function usePendingSignupCount() {
  return useQuery({
    ...pendingSignupsQuery(0),
    select: (data: WorkerPage) => data.totalElements,
  }).data
}

export function fullName(worker: Worker) {
  return `${worker.firstName} ${worker.lastName}`
}

function useDecision(
  decide: (workerId: string) => Promise<Worker>,
  successKey: 'signups.approved' | 'signups.rejected',
) {
  const { t } = useTranslation()
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (worker: Worker) => decide(worker.id),
    onSuccess: (_data, worker) => {
      toast.success(t(`${successKey}.title`, { name: fullName(worker) }), {
        description: t(`${successKey}.description`),
      })
    },
    onError: (error) => {
      toast.error(errorMessage(t, error))
    },
    // Also after an error: someone else may have decided in the meantime. The
    // mutation stays pending until the list and the count are fresh.
    onSettled: () => queryClient.invalidateQueries({ queryKey: signupKeys.pending }),
  })
}

export function useApproveSignup() {
  return useDecision((workerId) => workersApi.approveWorker({ workerId }), 'signups.approved')
}

export function useRejectSignup() {
  return useDecision((workerId) => workersApi.rejectWorker({ workerId }), 'signups.rejected')
}
