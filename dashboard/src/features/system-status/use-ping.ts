import { useQuery } from '@tanstack/react-query'

import { systemApi } from '@/api/client'

export function usePing() {
  return useQuery({
    queryKey: ['system', 'ping'],
    queryFn: ({ signal }) => systemApi.ping({ signal }),
  })
}
