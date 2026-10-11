// Builds the design tokens into a Flutter theme source and CSS variables.
//
//   npm run build   write both outputs
//   npm run check   fail if the committed outputs differ from the tokens
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import StyleDictionary from "style-dictionary";

const here = dirname(fileURLToPath(import.meta.url));
const outputs = {
  css: resolve(here, "../dashboard/src/styles/tokens.css"),
  dart: resolve(here, "../mobile/lib/core/theme/tokens.dart"),
};

// Resolves references for one theme and returns its tokens as { "a.b.c": value }.
async function resolveTheme(theme) {
  const sd = new StyleDictionary({
    source: ["tokens/core.json", `tokens/${theme}.json`].map((file) => resolve(here, file).replaceAll("\\", "/")),
    usesDtcg: true,
    log: { verbosity: "silent" },
    platforms: { resolved: { transforms: ["name/kebab"] } },
  });
  const { allTokens } = await sd.getPlatformTokens("resolved");
  return Object.fromEntries(allTokens.map((token) => [token.path.join("."), token.$value]));
}

const group = (tokens, prefix) =>
  Object.entries(tokens)
    .filter(([path]) => path.startsWith(`${prefix}.`))
    .map(([path, value]) => [path.slice(prefix.length + 1), value]);

const px = (value) => Number.parseFloat(value);
const rem = (value) => `${px(value) / 16}rem`;
const camel = (name) => name.replace(/-(\w)/g, (_, char) => char.toUpperCase());
const dartName = (name) => (/^\d/.test(name) ? `s${name}` : camel(name));
// Colors are #RRGGBB or, with transparency, #RRGGBBAA. Dart wants the alpha first.
const dartColor = (hex) => `Color(0x${(hex.slice(7) || "FF").toUpperCase()}${hex.slice(1, 7).toUpperCase()})`;
const fontStack = (...families) => [...families.map((family) => `"${family}"`), "ui-sans-serif", "system-ui", "sans-serif"].join(", ");

const light = await resolveTheme("light");
const dark = await resolveTheme("dark");

const header = "Generated from design-tokens/tokens. Do not edit; run `npm run build` in design-tokens/.";

// CSS: colors, radius and fonts as variables, light on :root and dark on .dark,
// and one Tailwind utility per text style of the web scale (type-heading-lg, ...).
const cssColors = (tokens) => group(tokens, "color").map(([name, value]) => `  --${name}: ${value.toLowerCase()};`);
const cssTextStyle = ([name, style]) => [
  `@utility type-${name} {`,
  `  font-family: var(--font-family-${style.fontFamily === light["font.family.text"] ? "text" : "display"});`,
  `  font-size: ${rem(style.fontSize)};`,
  `  font-weight: ${style.fontWeight};`,
  `  line-height: ${style.lineHeight};`,
  `  letter-spacing: ${style.letterSpacing};`,
  "}",
  "",
];
const css = [
  `/* ${header} */`,
  ":root {",
  ...cssColors(light),
  ...group(light, "radius")
    .filter(([name]) => name !== "full")
    .map(([name, value]) => `  --radius-${name}: ${rem(value)};`),
  `  --font-family-text: ${fontStack(light["font.family.text"])};`,
  `  --font-family-display: ${fontStack(light["font.family.display-web"], light["font.family.text"])};`,
  "}",
  "",
  ".dark {",
  ...cssColors(dark),
  "}",
  "",
  ...group(light, "web.typography").flatMap(cssTextStyle),
].join("\n");

// Dart: the constants the Flutter theme is built from, with the mobile scale.
const colorNames = group(light, "color").map(([name]) => dartName(name));
const dartColors = (tokens) => group(tokens, "color").map(([name, value]) => `    ${dartName(name)}: ${dartColor(value)},`);
const dartNumbers = (...prefixes) =>
  prefixes.flatMap((prefix) =>
    group(light, prefix).map(([name, value]) => `  static const double ${dartName(name)} = ${px(value)};`),
  );
const dartTextStyle = ([name, style]) => [
  `  static const TextStyle ${dartName(name)} = TextStyle(`,
  `    fontFamily: '${style.fontFamily}',`,
  `    fontSize: ${px(style.fontSize)},`,
  `    fontWeight: FontWeight.w${style.fontWeight},`,
  `    height: ${px(style.lineHeight)} / ${px(style.fontSize)},`,
  `    letterSpacing: ${px(style.letterSpacing)},`,
  "  );",
];
const dart = [
  `// ${header}`,
  "import 'package:flutter/painting.dart';",
  "",
  "/// Semantic colors of one theme.",
  "class AppColors {",
  "  const AppColors({",
  ...colorNames.map((name) => `    required this.${name},`),
  "  });",
  "",
  ...colorNames.map((name) => `  final Color ${name};`),
  "",
  "  static const light = AppColors(",
  ...dartColors(light),
  "  );",
  "",
  "  static const dark = AppColors(",
  ...dartColors(dark),
  "  );",
  "}",
  "",
  "abstract final class AppSpacing {",
  ...dartNumbers("spacing", "mobile.layout"),
  "}",
  "",
  "abstract final class AppRadius {",
  ...dartNumbers("radius"),
  "}",
  "",
  "abstract final class AppSize {",
  ...dartNumbers("mobile.size"),
  "}",
  "",
  "abstract final class AppTypography {",
  ...group(light, "mobile.typography").flatMap(dartTextStyle),
  "}",
  "",
  "abstract final class AppBrand {",
  `  static const String name = '${light["brand.name"]}';`,
  `  static const String fontFamily = '${light["font.family.text"]}';`,
  `  static const String displayFontFamily = '${light["font.family.display-mobile"]}';`,
  "}",
  "",
].join("\n");

const results = { css, dart };
if (process.argv.includes("--check")) {
  const upToDate = (key) =>
    existsSync(outputs[key]) && readFileSync(outputs[key], "utf8").replaceAll("\r\n", "\n") === results[key];
  const stale = Object.keys(results).filter((key) => !upToDate(key));
  if (stale.length > 0) {
    console.error(`Token outputs are out of date:\n${stale.map((key) => `  ${outputs[key]}`).join("\n")}`);
    console.error('Run "npm run build" in design-tokens/ and commit the result.');
    process.exit(1);
  }
  console.log("Token outputs are up to date.");
} else {
  for (const [key, content] of Object.entries(results)) {
    mkdirSync(dirname(outputs[key]), { recursive: true });
    writeFileSync(outputs[key], content);
    console.log(`wrote ${outputs[key]}`);
  }
}
