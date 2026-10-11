# Design tokens

One token source for both frontends. Changing a value here changes the worker app and the agency dashboard, which is how an agency's branding is applied.

| File | Contains |
| --- | --- |
| `tokens/core.json` | Palette, spacing, radius, font families, brand name, and per platform the text styles (`web.typography`, `mobile.typography`) and the mobile layout and control sizes |
| `tokens/light.json` | Semantic colors of the light theme, as references into the palette |
| `tokens/dark.json` | Semantic colors of the dark theme |

Both themes have the same semantic colors, named after their role: `canvas`, `surface-card`, `ink`, `ink-secondary`, `hairline`, `action` (the primary call to action: black in light, white in dark), `primary` (the cobalt brand color, used sparingly), `danger` and the `status-*` pairs. Transparent colors are written as `#RRGGBBAA`.

Tokens use the [Design Tokens (DTCG) format](https://www.designtokens.org/) and are resolved with [Style Dictionary](https://styledictionary.com).

## Outputs

| Output | Used by |
| --- | --- |
| `dashboard/src/styles/tokens.css` | CSS variables for colors (`--canvas`, `--ink`, ...), radius and font families, light on `:root`, dark on `.dark`, and one Tailwind utility per web text style (`type-heading-lg`, `type-body-md`, ...) |
| `mobile/lib/core/theme/tokens.dart` | `AppColors.light` / `AppColors.dark`, `AppSpacing`, `AppRadius`, `AppSize`, `AppTypography`, `AppBrand` |

Both files are generated and committed. Never edit them, and never hardcode colors or other brand values in the apps.

## Commands

Run in `design-tokens/`.

```
npm ci           install the tooling
npm run build    regenerate both outputs
npm run check    fail if the committed outputs differ from the tokens (used in CI)
```
