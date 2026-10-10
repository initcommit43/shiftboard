import { Configuration, SystemApi } from './generated'

const configuration = new Configuration({
  basePath: import.meta.env.VITE_API_BASE_URL ?? '/api/v1',
})

export const systemApi = new SystemApi(configuration)
