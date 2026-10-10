# Design tokens

One token source for both frontends. Changing a value here changes the worker app and the agency dashboard, which is how an agency's branding is applied.

| File | Contains |
| --- | --- |
| `tokens/core.json` | Palette, spacing, radius, font, brand name |
| `tokens/light.json` | Semantic colors of the light theme, as references into the palette |
| `tokens/dark.json` | Semantic colors of the dark theme |

Tokens use the [Design Tokens (DTCG) format](https://www.designtokens.org/) and are resolved with [Style Dictionary](https://styledictionary.com).

## Outputs

| Output | Used by |
| --- | --- |
| `dashboard/src/styles/tokens.css` | CSS variables with the names shadcn/ui expects (`--background`, `--primary`, ...), light on `:root`, dark on `.dark` |
| `mobile/lib/core/theme/tokens.dart` | `AppColors.light` / `AppColors.dark`, `AppSpacing`, `AppRadius`, `AppFontSize`, `AppBrand` |

Both files are generated and committed. Never edit them, and never hardcode colors or other brand values in the apps.

## Commands

Run in `design-tokens/`.

```
npm ci           install the tooling
npm run build    regenerate both outputs
npm run check    fail if the committed outputs differ from the tokens (used in CI)
```
