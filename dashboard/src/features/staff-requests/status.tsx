import { useTranslation } from 'react-i18next'

import { known } from '@/api/enums'
import { StaffRequestStatus } from '@/api/generated'
import { Badge } from '@/components/ui/badge'

const STATUS_VARIANT = {
  [StaffRequestStatus.OPEN]: 'open',
  [StaffRequestStatus.ACCEPTED]: 'confirmed',
  [StaffRequestStatus.DECLINED]: 'cancelled',
  [StaffRequestStatus.WITHDRAWN]: 'tag',
} as const

/**
 * The status of a request for staff. Clients read an accepted request as planned
 * (`portal.requests.status`), the agency as turned into a shift (`staffRequests.status`).
 */
export function StaffRequestStatusBadge({
  status,
  audience,
}: {
  status: StaffRequestStatus
  audience: 'client' | 'agency'
}) {
  const { t } = useTranslation()
  const value = known(StaffRequestStatus, status)

  if (!value) {
    return <Badge>{t('unknownValue')}</Badge>
  }
  return (
    <Badge variant={STATUS_VARIANT[value]}>
      {t(audience === 'client' ? `portal.requests.status.${value}` : `staffRequests.status.${value}`)}
    </Badge>
  )
}
