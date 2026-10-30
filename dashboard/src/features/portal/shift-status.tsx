import { useTranslation } from 'react-i18next'

import { known } from '@/api/enums'
import { type ClientShift, ShiftStatus } from '@/api/generated'
import { Badge } from '@/components/ui/badge'
import { STATUS_VARIANT } from '@/features/shifts/format'

/** A shift's status in the client's words: a published shift is simply planned. */
export function PortalStatusBadge({ status }: { status: ShiftStatus }) {
  const { t } = useTranslation()
  const value = known(ShiftStatus, status)

  return value ? (
    <Badge variant={STATUS_VARIANT[value]}>{t(`portal.status.${value}`)}</Badge>
  ) : (
    <Badge>{t('unknownValue')}</Badge>
  )
}

/** How many of the spots are filled: "4 von 5", or "Voll". A cancelled shift has none to fill. */
export function FillStatus({ shift }: { shift: ClientShift }) {
  const { t } = useTranslation()

  if (shift.status === ShiftStatus.CANCELLED) {
    return (
      <span className="text-ink-secondary">
        <span aria-hidden>–</span>
        <span className="sr-only">{t('portal.fill.cancelled')}</span>
      </span>
    )
  }
  if (shift.confirmedCount >= shift.slots) {
    return <Badge variant="confirmed">{t('portal.fill.full')}</Badge>
  }
  return (
    <span className="tabular-nums">
      {t('portal.fill.count', { confirmed: shift.confirmedCount, total: shift.slots })}
    </span>
  )
}
