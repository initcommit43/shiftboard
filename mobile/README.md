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

With the backend's local profile and its seed data, these fictional accounts exist (password `shiftboard-demo`):

| Account | Status | Lands on |
| --- | --- | --- |
| `lena.hofer@example.com` | active | shifts |
| `emma.koller@example.com` | pending | waiting for approval |
| `simon.egger@example.com` | inactive | not active |

The signup code of the demo agency "Donau Personal" is `donau-demo`.

## Flows

The session decides which screen is shown; the router's `redirect` is the only place that navigates between these states.

| Session | Screen |
| --- | --- |
| being restored on start | start screen with a spinner; with a retry if the API cannot be reached |
| signed out | login, or the signup behind an invitation |
| signed in, worker `PENDING` | waiting for approval ("Status aktualisieren" asks again) |
| signed in, worker `INACTIVE` | not active |
| signed in, worker `ACTIVE` | home with the tabs; "Schichten" first |

- **Signup:** an invitation link opens the form for its code. Without the link, "Registrieren" on the login leads to a step where the worker pastes the link or the bare code. The form asks for name, date of birth, email, phone and password and loads the agency with `GET /signup/{code}`; an unknown code shows "invitation not valid". Signing up logs the worker in, who then waits for approval.
- **Login and logout:** email and password with client type `WORKER_APP`. Wrong credentials and a login on the wrong client show the same generic error. Logging out revokes the refresh token on the server (best effort) and always clears this device.
- **Shifts:** the API has no shift list yet, so the tab shows its empty state. "Aktualisieren" reloads the account, which moves a deactivated worker off the tab. The other tabs are placeholders.

### Invitation links

Until there is a web domain, invitations use a custom URL scheme: `shiftboard://join/<code>`. It is registered in `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist` and ends up on the route `/join/:signupCode`.

Open one on a running Android emulator or device:

```
adb shell am start -a android.intent.action.VIEW -d "shiftboard://join/donau-demo" app.shiftboard
```

On the iOS simulator:

```
xcrun simctl openurl booted "shiftboard://join/donau-demo"
```

### Tokens

- Access and refresh token are stored with `flutter_secure_storage` (Keychain on iOS, Keystore-backed storage on Android). Android auto backup is off, because a restored copy could not be decrypted on another device.
- `AuthInterceptor` adds the access token to the requests the API contract marks as protected. Login, refresh, logout and signup never carry one.
- On a 401 it exchanges the refresh token once and repeats the request. Refresh tokens are single use, so requests that fail at the same time wait for the same refresh.
- If the refresh token is rejected, the tokens are deleted and the app returns to the login. If the API cannot be reached, the session is kept.
- Tokens, passwords and personal data are never logged.

## Test and analyze

```
flutter analyze
flutter test
```

Widget tests swap the HTTP adapter of the API client for `FakeBackend` (`test/support/fake_backend.dart`) and the secure storage for a map, so they never touch the network and still run the generated client and the token handling.

## Structure

```
lib/
├── main.dart                  entry point, ProviderScope
├── app.dart                   MaterialApp.router: theme, locales, router
├── core/                      shared by all features
│   ├── api/                   apiProvider (the configured generated client), ApiError
│   ├── l10n/                  ARB files, context.l10n
│   ├── routing/               all routes and the redirect that follows the session
│   ├── theme/                 tokens.dart (generated), AppTheme
│   └── widgets/               button, text field, badge, alert, status message
└── features/
    ├── auth/                  session, token storage, auth interceptor, login, start screen
    ├── signup/                invitation code, signup form
    ├── approval/              waiting for approval, not active
    └── shifts/                home with the tabs, shift list (empty for now), account sheet
packages/
└── shiftboard_api/            generated API client
assets/fonts/inter/            Inter, bundled with its license
test/                          mirrors lib/; support/ holds the fake backend
```

A feature has `data/` (providers and repositories on the generated client) and `presentation/` (screens and widgets), and a `domain/` folder only once it has logic of its own.

## Conventions

- **State:** plain Riverpod providers, no code generation.
- **Routing:** paths live in `AppRoutes`, routes and the `redirect` in `core/routing/app_router.dart`. Screens do not navigate after login, logout or approval; they change the session and the redirect follows.
- **Errors:** `ApiError` turns a failed call into the API's error `code` and, in one place, into a localized message. Unknown codes get a generic one.
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
