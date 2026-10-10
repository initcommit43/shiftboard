import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import type { SystemApi } from '@/api/generated'
import { renderWithQueryClient } from '@/test/render'

import { SystemStatusPage } from './system-status-page'

const ping = vi.hoisted(() => vi.fn<SystemApi['ping']>())

vi.mock('@/api/client', () => ({
  systemApi: { ping },
}))

describe('SystemStatusPage', () => {
  beforeEach(() => {
    ping.mockReset()
  })

  it('shows a loading state while the API is being checked', () => {
    ping.mockReturnValue(new Promise(() => undefined))

    renderWithQueryClient(<SystemStatusPage />)

    expect(screen.getByRole('status', { name: 'Verbindung wird geprüft …' })).toBeInTheDocument()
  })

  it('shows the API version once the API answers', async () => {
    ping.mockResolvedValue({ status: 'ok', version: '0.1.0' })

    renderWithQueryClient(<SystemStatusPage />)

    expect(await screen.findByText('Verbunden')).toBeInTheDocument()
    expect(screen.getByText('API-Version')).toBeInTheDocument()
    expect(screen.getByText('0.1.0')).toBeInTheDocument()
    expect(screen.queryByRole('status')).not.toBeInTheDocument()
  })

  it('shows an error and recovers when retrying succeeds', async () => {
    ping.mockRejectedValueOnce(new Error('network down'))
    ping.mockResolvedValueOnce({ status: 'ok', version: '0.1.0' })
    const user = userEvent.setup()

    renderWithQueryClient(<SystemStatusPage />)

    expect(await screen.findByRole('alert')).toHaveTextContent('Die API ist nicht erreichbar')

    await user.click(screen.getByRole('button', { name: 'Erneut versuchen' }))

    expect(await screen.findByText('0.1.0')).toBeInTheDocument()
    expect(screen.queryByRole('alert')).not.toBeInTheDocument()
    expect(ping).toHaveBeenCalledTimes(2)
  })
})
