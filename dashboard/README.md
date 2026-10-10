# shiftboard dashboard

The agency dashboard: dispatchers publish shifts and manage the worker pool here. React and TypeScript, built with Vite, styled with Tailwind CSS and shadcn/ui.

So far dispatchers and admins can log in and out, and approve or reject pending worker signups. The other areas of the navigation are placeholders.

## Run

Developed and tested with Node 24.

```sh
npm ci
npm run dev
```

The app runs on http://localhost:5173. API requests go to `/api/v1`, and the dev server proxies `/api` to the backend on `http://localhost:8080`, so development needs no CORS setup. Without a running backend the login page renders, and logging in reports that the server cannot be reached.

To point the app at another API, copy `.env.example` to `.env.local` and set `VITE_API_BASE_URL`. The backend has no CORS configuration, so in development the proxy is the way to reach it.

The backend's local profile seeds demo accounts, all with the password `shiftboard-demo`:

| Agency         | Accounts                                                                            |
| -------------- | ----------------------------------------------------------------------------------- |
| Donau Personal | `admin.donau@example.com`, `dispatcher1.donau@example.com`, `dispatcher2.donau@example.com` |
| Alpen Events   | `dispatcher.alpen@example.com`                                                      |

Donau Personal starts with four pending signups. The login is limited to 5 attempts per 15 minutes.

## Scripts

| Command              | What it does                                   |
| -------------------- | ---------------------------------------------- |
| `npm run dev`        | Dev server with hot reload                     |
| `npm run build`      | Type-check, then build to `dist/`              |
| `npm run preview`    | Serve the production build locally             |
| `npm run typecheck`  | Type-check app, tooling and generated client   |
| `npm run lint`       | ESLint                                         |
| `npm test`           | Component tests, single run                    |
| `npm run test:watch` | Component tests in watch mode                  |

## Structure

```
src/
├── main.tsx           entry: styles, i18n, theme, router, query client
├── app/               app composition, routes (router.tsx), app shell, placeholder pages
├── features/          one folder per feature
│   ├── auth/          session, route guards, login page, user menu
│   └── signups/       pending signups: list, approve, reject
├── components/        shared components (brand, page header, state card)
│   └── ui/            shadcn/ui components
├── api/
│   ├── client.ts      configured API instances, token refresh
│   ├── tokens.ts      token storage
│   ├── errors.ts      ApiError and the mapping from error codes to messages
│   └── generated/     generated API client (do not edit)
├── i18n/              i18next setup and locales (de, en)
├── lib/               shared helpers
├── styles/
│   ├── index.css      Tailwind setup, maps the theme to the tokens
│   └── tokens.css     generated design tokens (do not edit)
└── test/              test setup, render helper, in-memory fake of the API
```

A feature keeps its pages, components, hooks and tests together in `src/features/<feature>/`. Code moves to `components/` or `lib/` once a second feature needs it.

## Routes

| Path                                 | Page                                             |
| ------------------------------------ | ------------------------------------------------ |
| `/login`                             | Login. Public; a signed-in user is sent on       |
| `/`                                  | Redirects to `/signups`                          |
| `/signups`                           | Pending signups                                  |
| `/shifts`, `/messages`, `/settings`  | Placeholders until their slices are built        |

Everything except `/login` sits below the app shell route. Its loader (`requireSession`) returns the signed-in user or redirects to `/login?redirectTo=<requested path>`; after the login the user lands on the requested page. Components read the user with `useCurrentUser()`.

## Authentication and session

The login sends the client type `DASHBOARD`, so the backend only lets dispatchers and admins in. Wrong credentials and a worker account (`wrong_client`) produce the same generic message.

- **Tokens** (`src/api/tokens.ts`): the access token is held in memory only. The refresh token is stored in `localStorage`, so that a reload or a new tab does not end the session. The trade-off: script injected through an XSS hole could read it. An `httpOnly` cookie would close that gap but needs a change of the API contract, which returns the tokens in the response body. Until then the exposure is limited by refresh tokens being single use and revoked on logout.
- **Refresh** (`src/api/client.ts`): the generated client is configured once with the access token and two middlewares. On a 401 the first one exchanges the refresh token, then repeats the request with the new access token. Refresh tokens rotate, so all concurrent requests share one refresh. The login, refresh and logout endpoints never trigger it. If the refresh fails, the tokens are cleared, cached data is dropped and the route guard leads back to the login.
- **Restore** (`src/features/auth/session.ts`): after a page load the guard first exchanges the stored refresh token and loads `/me`. Protected pages render only after that; a loading indicator shows in the meantime.
- **Logout**: clears the tokens and the query cache on this device right away and revokes the refresh token on the server (`POST /auth/logout`, best effort).

## Conventions

- **Routes** are defined in `src/app/router.tsx` and nowhere else.
- **Server state** goes through TanStack Query. Each feature keeps its query keys, queries and mutations in one file (`queries.ts`); mutations invalidate what they change.
- **Errors**: the API client turns every error response into an `ApiError` with the problem `code`. `errorMessage()` in `src/api/errors.ts` maps it to the translation `errors.<code>`; unknown codes get a generic message. A new code only needs a translation.
- **Strings** never live in components. German (`src/i18n/locales/de.json`) is the source language, `en.json` must have the same keys, and translation keys are type-checked. Dates are formatted with `Intl` in the active language.
- **Colors, radius and font** come from the design tokens through Tailwind utilities (`bg-primary`, `text-muted-foreground`, `bg-success`). No hardcoded color values, also not in shadcn/ui components.
- **Radius**: the theme follows the shadcn/ui scale, in which the token `--radius` is `rounded-lg`. The radii of the design therefore map to `rounded-sm` (sm: badges), `rounded-lg` (md: buttons, inputs, cards, tables, nav items) and `rounded-xl` (lg: dialogs, login card).
- **shadcn/ui** components are added with `npx shadcn@latest add <component>` and live in `src/components/ui/`. After adding one: change the `cn` import to `@/lib/utils`, replace literal colors such as `text-white` with token utilities, and remove the parts that are not used.

## Tests

Component tests run with Vitest and Testing Library. They render the whole app (`renderApp()` in `src/test/render.tsx`) against an in-memory fake of the API (`src/test/fake-api.ts`) that replaces `fetch`, so the real client, token refresh, guards and pages are exercised without a network. The fake follows the contract: rotating refresh tokens, bearer checks and problem responses with codes.

## Generated code

Two locations are build output of other folders in the monorepo. They are committed, never edited by hand, and excluded from linting.

**API client** (`src/api/generated/`), generated from `api/openapi.yaml`. API models are never written by hand. After a spec change:

```sh
cd ../api
npm ci
npm run generate   # needs Java and the Dart SDK
```

The generated code does not pass every strict compiler flag the app uses, so it is type-checked as its own project (`tsconfig.generated.json`) with those flags switched off. The app code keeps the strict settings from `tsconfig.base.json`.

**Design tokens** (`src/styles/tokens.css`), generated from `design-tokens/tokens/`. After a token change:

```sh
cd ../design-tokens
npm ci
npm run build
```
