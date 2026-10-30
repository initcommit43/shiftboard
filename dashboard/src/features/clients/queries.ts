import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'

import { clientsApi, clientUsersApi } from '@/api/client'
import { errorMessage } from '@/api/errors'
import type { ClientUser, ClientUserRequest } from '@/api/generated'
import { useAgencyFeatures } from '@/features/settings/queries'

export const PAGE_SIZE = 20

/** A client's page looks its client up among all of them; the API caps a page at 100. */
const ALL_CLIENTS_SIZE = 100

export const clientKeys = {
  list: (page: number) => ['clients', 'list', page] as const,
  all: ['clients', 'all'] as const,
  users: (clientId: string) => ['client-users', clientId] as const,
}

export function fullName({ firstName, lastName }: { firstName: string; lastName: string }) {
  return `${firstName} ${lastName}`
}

/** The link a client user sets their password with. */
export function setupLink(setupCode: string) {
  return `${window.location.origin}/client-setup/${encodeURIComponent(setupCode)}`
}

/** Whether the agency has the client portal switched on; false while that is not known. */
export function useClientPortalOn() {
  const features = useAgencyFeatures()
  return features.data?.clientPortal === true
}

export function useClients(page: number) {
  return useQuery({
    queryKey: clientKeys.list(page),
    queryFn: ({ signal }) => clientsApi.listClients({ page, size: PAGE_SIZE }, { signal }),
    placeholderData: keepPreviousData,
  })
}

/** One client, or null when the agency has none with this id. There is no endpoint for a single client. */
export function useClient(clientId: string) {
  return useQuery({
    queryKey: clientKeys.all,
    queryFn: ({ signal }) => clientsApi.listClients({ size: ALL_CLIENTS_SIZE }, { signal }),
    select: (page) => page.content.find((it) => it.id === clientId) ?? null,
  })
}

/** The portal users of a client, sorted by last and first name. */
export function useClientUsers(clientId: string) {
  return useQuery({
    queryKey: clientKeys.users(clientId),
    queryFn: ({ signal }) => clientUsersApi.listClientUsers({ clientId }, { signal }),
  })
}

export function useInviteClientUser(clientId: string) {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (clientUserRequest: ClientUserRequest) =>
      clientUsersApi.inviteClientUser({ clientId, clientUserRequest }),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: clientKeys.users(clientId) }),
  })
}

export function useRenewSetupLink(clientId: string) {
  const { t } = useTranslation()
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (user: ClientUser) =>
      clientUsersApi.renewClientUserSetupLink({ clientId, userId: user.id }),
    onError: (error) => {
      toast.error(errorMessage(t, error))
    },
    // Also after an error: the user may have set a password in the meantime.
    onSettled: () => queryClient.invalidateQueries({ queryKey: clientKeys.users(clientId) }),
  })
}

export function useDeactivateClientUser(clientId: string) {
  const { t } = useTranslation()
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (user: ClientUser) =>
      clientUsersApi.deactivateClientUser({ clientId, userId: user.id }),
    onSuccess: (user) => {
      toast.success(t('clients.users.deactivate.done', { name: fullName(user) }), {
        description: t('clients.users.deactivate.doneDescription'),
      })
    },
    onError: (error) => {
      toast.error(errorMessage(t, error))
    },
    onSettled: () => queryClient.invalidateQueries({ queryKey: clientKeys.users(clientId) }),
  })
}
