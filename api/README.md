# API

`openapi.yaml` is the single source of truth for the shiftboard API. Every API change starts here, before any backend or client code.

Both clients are generated from it with [openapi-generator](https://openapi-generator.tech) and committed:

| Client | Generator | Output |
| --- | --- | --- |
| Worker app (Dart) | `dart-dio` | `mobile/packages/shiftboard_api/` |
| Dashboard (TypeScript) | `typescript-fetch` | `dashboard/src/api/generated/` |

Never edit the generated code or write API models by hand in the clients.

## Commands

Run in `api/`. Needs Node.js, Java and the Dart SDK (part of Flutter).

```
npm ci             install the tooling
npm run lint       lint the spec
npm run generate   regenerate both clients
npm run check      regenerate and fail if the committed clients differ (used in CI)
```

The generator version is pinned in `openapitools.json`.
