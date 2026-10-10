# shiftboard dashboard

The agency dashboard: dispatchers publish shifts and manage the worker pool here. React and TypeScript, built with Vite, styled with Tailwind CSS and shadcn/ui.

So far it contains the app shell and one page that checks the connection to the backend.

## Run

Developed and tested with Node 24.

```sh
npm ci
npm run dev
```

The app runs on http://localhost:5173. API requests go to `/api/v1`, and the dev server proxies `/api` to the backend on `http://localhost:8080`, so development needs no CORS setup. Without a running backend the start page shows its error state.

To point the app at another API, copy `.env.example` to `.env.local` and set `VITE_API_BASE_URL`.

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
├── main.tsx           entry: styles, i18n, theme, render
├── app/               providers, routes (router.tsx), app shell
├── features/          one folder per feature
│   └── system-status/ start page that pings the API
├── components/        shared components
│   └── ui/            shadcn/ui components
├── api/
│   ├── client.ts      configured API instances
│   └── generated/     generated API client (do not edit)
├── i18n/              i18next setup and locales (de, en)
├── lib/               shared helpers
├── styles/
│   ├── index.css      Tailwind setup, maps the theme to the tokens
│   └── tokens.css     generated design tokens (do not edit)
└── test/              test setup and render helper
```

A feature keeps its pages, components, hooks and tests together in `src/features/<feature>/`. Code moves to `components/` or `lib/` once a second feature needs it.

## Conventions

- **Routes** are defined in `src/app/router.tsx` and nowhere else.
- **Server state** goes through TanStack Query; features wrap their calls in hooks such as `usePing`.
- **Strings** never live in components. German (`src/i18n/locales/de.json`) is the source language, `en.json` must have the same keys, and translation keys are type-checked.
- **Colors, radius and font** come from the design tokens through Tailwind utilities (`bg-primary`, `text-muted-foreground`, `bg-success`). No hardcoded color values, also not in shadcn/ui components.
- **shadcn/ui** components are added with `npx shadcn@latest add <component>` and live in `src/components/ui/`. Check a new component for literal colors such as `text-white` and replace them with token utilities.

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
