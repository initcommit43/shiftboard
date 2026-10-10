# Worker app

Flutter app for iOS and Android in which workers find and claim shifts. State with Riverpod, routing with go_router, API access through the generated client.

Needs Flutter 3.47 or newer (Dart 3.13).

## Run

Run all commands in `mobile/`.

```
flutter pub get
flutter run
```

The app talks to the backend at `API_BASE_URL`. Without it, it expects a local backend on port 8080:

| Target | Default |
| --- | --- |
| Android emulator | `http://10.0.2.2:8080/api/v1` (the emulator's address of the host machine) |
| iOS simulator | `http://localhost:8080/api/v1` |

Anything else, such as a physical device in the same network, is set at build time:

```
flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8080/api/v1
```

Cleartext HTTP is enabled for Android debug builds only (`android/app/src/debug/AndroidManifest.xml`); release builds are meant to use HTTPS.

## Test and analyze

```
flutter analyze
flutter test
```

Widget tests override `apiProvider` with a client whose HTTP adapter is faked, so they never touch the network.

## Structure

```
lib/
├── main.dart                  entry point, ProviderScope
├── app.dart                   MaterialApp.router: theme, locales, router
├── core/                      shared by all features
│   ├── api/                   apiProvider: the configured generated client
│   ├── l10n/                  ARB files, context.l10n
│   ├── routing/               all routes and the redirect hook
│   └── theme/                 tokens.dart (generated), AppTheme
└── features/
    └── <feature>/
        ├── data/              providers and repositories on the generated client
        └── presentation/      screens and widgets
packages/
└── shiftboard_api/            generated API client
assets/fonts/inter/            Inter, bundled with its license
test/                          mirrors lib/
```

A feature gets a `domain/` folder only once it has logic of its own. `system_status` is the one feature so far: the start screen pings the API and shows the result.

## Conventions

- **State:** plain Riverpod providers, no code generation.
- **Routing:** paths live in `AppRoutes`, routes and the `redirect` hook in `core/routing/app_router.dart`.
- **API:** models and calls come from `shiftboard_api`. Never write API models by hand.
- **Theme:** colors, spacing, radii and font sizes come from `core/theme/tokens.dart`. Use `Theme.of(context)`, `context.semanticColors` (success, warning) and `AppSpacing`; never hardcode a color or brand value.
- **Strings:** every user-facing string goes through `context.l10n`. German is the template language, English a translation.

## Generated code

| What | Source | Regenerate | Committed |
| --- | --- | --- | --- |
| `packages/shiftboard_api/` | `api/openapi.yaml` | `npm run generate` in [`api/`](../api) | yes |
| `lib/core/theme/tokens.dart` | `design-tokens/tokens/` | `npm run build` in [`design-tokens/`](../design-tokens) | yes |
| `lib/core/l10n/generated/` | `lib/core/l10n/app_*.arb` | `flutter pub get`, any build, or `flutter gen-l10n` | no |

None of these are edited by hand.

To add a string, add it with a description to `app_de.arb`, add the translation to `app_en.arb` and run `flutter gen-l10n`. Settings are in `l10n.yaml`.

## Font

Inter 4.1 from the [Inter project](https://github.com/rsms/inter/releases/tag/v4.1) is bundled in `assets/fonts/inter/` in the weights 400, 500, 600 and 700, together with its SIL Open Font License. Nothing is fetched at runtime.
