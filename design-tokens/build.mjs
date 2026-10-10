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
const dartColor = (hex) => `Color(0xFF${hex.slice(1).toUpperCase()})`;

const light = await resolveTheme("light");
const dark = await resolveTheme("dark");

const header = "Generated from design-tokens/tokens. Do not edit; run `npm run build` in design-tokens/.";

// CSS: the variable names shadcn/ui expects, light on :root and dark on .dark.
const cssColors = (tokens) => group(tokens, "color").map(([name, value]) => `  --${name}: ${value.toLowerCase()};`);
const css = [
  `/* ${header} */`,
  ":root {",
  ...cssColors(light),
  `  --radius: ${rem(light["radius.md"])};`,
  `  --font-sans: "${light["font.family.sans"]}", ui-sans-serif, system-ui, sans-serif;`,
  "}",
  "",
  ".dark {",
  ...cssColors(dark),
  "}",
  "",
].join("\n");

// Dart: the constants the Flutter theme is built from.
const colorNames = group(light, "color").map(([name]) => dartName(name));
const dartColors = (tokens) => group(tokens, "color").map(([name, value]) => `    ${dartName(name)}: ${dartColor(value)},`);
const dartNumbers = (prefix) =>
  group(light, prefix).map(([name, value]) => `  static const double ${dartName(name)} = ${px(value)};`);
const dart = [
  `// ${header}`,
  "import 'dart:ui';",
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
  ...dartNumbers("spacing"),
  "}",
  "",
  "abstract final class AppRadius {",
  ...dartNumbers("radius"),
  "}",
  "",
  "abstract final class AppFontSize {",
  ...dartNumbers("font.size"),
  "}",
  "",
  "abstract final class AppBrand {",
  `  static const String name = '${light["brand.name"]}';`,
  `  static const String fontFamily = '${light["font.family.sans"]}';`,
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
