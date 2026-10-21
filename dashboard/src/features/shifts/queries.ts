import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'

import { assignmentsApi, clientsApi, shiftsApi, shiftTemplatesApi } from '@/api/client'
import { errorMessage } from '@/api/errors'
import type {
  Shift,
  ShiftAssignment,
  ShiftChangeRequest,
  ShiftPeriod,
  ShiftRequest,
  ShiftTemplate,
  ShiftTemplateRequest,
} from '@/api/generated'

export const PAGE_SIZE = 20

/** The form offers every client and qualification at once; the API caps a page at 100. */
const OPTIONS_SIZE = 100

/** The claims of a shift are shown at once; the API caps a page at 100. */
const ASSIGNMENTS_SIZE = 100

// Everything about shifts lives under one key, so that a change refreshes lists, details and claims together.
export const shiftKeys = {
  all: ['shifts'] as const,
  list: (period: ShiftPeriod, page: number) => ['shifts', 'list', period, page] as const,
  detail: (shiftId: string) => ['shifts', 'detail', shiftId] as const,
  assignments: (shiftId: string) => ['shifts', 'assignments', shiftId] as const,
  formOptions: ['shift-form-options'] as const,
}

export function useShifts(period: ShiftPeriod, page: number) {
  return useQuery({
    queryKey: shiftKeys.list(period, page),
    queryFn: ({ signal }) => shiftsApi.listShifts({ period, page, size: PAGE_SIZE }, { signal }),
    placeholderData: keepPreviousData,
  })
}

export function useShift(shiftId: string) {
  return useQuery({
    queryKey: shiftKeys.detail(shiftId),
    queryFn: ({ signal }) => shiftsApi.getShift({ shiftId }, { signal }),
  })
}

/** All claims of a shift, oldest first. */
export function useShiftAssignments(shiftId: string) {
  return useQuery({
    queryKey: shiftKeys.assignments(shiftId),
    queryFn: ({ signal }) =>
      assignmentsApi.listShiftAssignments({ shiftId, size: ASSIGNMENTS_SIZE }, { signal }),
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

/** The picker offers every template at once; the API caps a page at 100. */
const TEMPLATES_SIZE = 100

export const templateKeys = {
  all: ['shift-templates'] as const,
}

/** The agency's templates, sorted by name. */
export function useShiftTemplates() {
  return useQuery({
    queryKey: templateKeys.all,
    queryFn: ({ signal }) =>
      shiftTemplatesApi.listShiftTemplates({ size: TEMPLATES_SIZE }, { signal }),
  })
}

export function useCreateShiftTemplate() {
  const { t } = useTranslation()
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (shiftTemplateRequest: ShiftTemplateRequest) =>
      shiftTemplatesApi.createShiftTemplate({ shiftTemplateRequest }),
    onSuccess: (template) => {
      toast.success(t('templates.saved.title', { name: template.name }), {
        description: t('templates.saved.description'),
      })
      return queryClient.invalidateQueries({ queryKey: templateKeys.all })
    },
  })
}

export function useUpdateShiftTemplate(templateId: string) {
  const { t } = useTranslation()
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (shiftTemplateRequest: ShiftTemplateRequest) =>
      shiftTemplatesApi.updateShiftTemplate({ templateId, shiftTemplateRequest }),
    onSuccess: (template) => {
      toast.success(t('templates.updated', { name: template.name }))
      return queryClient.invalidateQueries({ queryKey: templateKeys.all })
    },
  })
}

export function useDeleteShiftTemplate() {
  const { t } = useTranslation()
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (template: ShiftTemplate) =>
      shiftTemplatesApi.deleteShiftTemplate({ templateId: template.id }),
    onSuccess: (_data, template) => {
      toast.success(t('templates.deleted', { name: template.name }))
    },
    onError: (error) => {
      toast.error(errorMessage(t, error))
    },
    // Also after an error: a colleague may have deleted it already.
    onSettled: () => queryClient.invalidateQueries({ queryKey: templateKeys.all }),
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
      return queryClient.invalidateQueries({ queryKey: shiftKeys.all })
    },
  })
}

export function useUpdateShift(shiftId: string) {
  const { t } = useTranslation()
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (shiftChangeRequest: ShiftChangeRequest) =>
      shiftsApi.updateShift({ shiftId, shiftChangeRequest }),
    onSuccess: (shift) => {
      toast.success(t('shiftEdit.saved', { title: shift.title }))
      return queryClient.invalidateQueries({ queryKey: shiftKeys.all })
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
    onSettled: () => queryClient.invalidateQueries({ queryKey: shiftKeys.all }),
  })
}

export function useCancelShift() {
  const { t } = useTranslation()
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (shift: Shift) => shiftsApi.cancelShift({ shiftId: shift.id }),
    onSuccess: (shift) => {
      toast.success(t('shiftDetail.cancelled.title', { title: shift.title }), {
        description: t('shiftDetail.cancelled.description'),
      })
    },
    onError: (error) => {
      toast.error(errorMessage(t, error))
    },
    onSettled: () => queryClient.invalidateQueries({ queryKey: shiftKeys.all }),
  })
}

export function workerName(assignment: ShiftAssignment) {
  return `${assignment.worker.firstName} ${assignment.worker.lastName}`
}

type Decision = 'approve' | 'reject' | 'noShow'

const DECIDE: Record<Decision, (shiftId: string, assignmentId: string) => Promise<ShiftAssignment>> = {
  approve: (shiftId, assignmentId) => assignmentsApi.approveAssignment({ shiftId, assignmentId }),
  reject: (shiftId, assignmentId) => assignmentsApi.rejectAssignment({ shiftId, assignmentId }),
  noShow: (shiftId, assignmentId) => assignmentsApi.markNoShow({ shiftId, assignmentId }),
}

/** Approve, reject or mark a no-show. Lists and counts are fresh before the mutation settles. */
export function useAssignmentDecision(shiftId: string, decision: Decision) {
  const { t } = useTranslation()
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (assignment: ShiftAssignment) => DECIDE[decision](shiftId, assignment.id),
    onSuccess: (_data, assignment) => {
      toast.success(t(`shiftDetail.decided.${decision}`, { name: workerName(assignment) }))
    },
    onError: (error) => {
      toast.error(errorMessage(t, error))
    },
    // Also after an error: a colleague may have decided in the meantime.
    onSettled: () => queryClient.invalidateQueries({ queryKey: shiftKeys.all }),
  })
}

export function useRemoveAssignment(shiftId: string) {
  const { t } = useTranslation()
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: ({ assignment, reason }: { assignment: ShiftAssignment; reason: string }) =>
      assignmentsApi.removeAssignment({
        shiftId,
        assignmentId: assignment.id,
        removeAssignmentRequest: { reason },
      }),
    onSuccess: (_data, { assignment }) => {
      toast.success(t('shiftDetail.decided.remove', { name: workerName(assignment) }))
    },
    onSettled: () => queryClient.invalidateQueries({ queryKey: shiftKeys.all }),
  })
}
