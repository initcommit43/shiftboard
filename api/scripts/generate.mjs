// Regenerates the Dart and TypeScript API clients from openapi.yaml.
//
//   npm run generate   regenerate both clients
//   npm run check      regenerate, then fail if the committed clients differ
//
// Needs Java (openapi-generator) and the Dart SDK (build_runner) on the PATH.
import { execSync } from "node:child_process";
import { rmSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const apiDir = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const repoDir = resolve(apiDir, "..");
const dartDir = resolve(repoDir, "mobile/packages/shiftboard_api");
const tsDir = resolve(repoDir, "dashboard/src/api/generated");

const run = (command, cwd) => {
  console.log(`\n> ${command}`);
  execSync(command, { cwd, stdio: "inherit" });
};

// Remove previous output so deleted schemas and operations do not linger.
rmSync(resolve(dartDir, "lib"), { recursive: true, force: true });
rmSync(tsDir, { recursive: true, force: true });

run("npx openapi-generator-cli generate", apiDir);

// The Dart client uses built_value, which needs its own code generation step.
run("dart pub get", dartDir);
run("dart run build_runner build", dartDir);
run("dart format .", dartDir);

if (process.argv.includes("--check")) {
  const paths = "mobile/packages/shiftboard_api dashboard/src/api/generated";
  // Compare the working tree with the index, so staged files count as committed.
  const git = (args) => execSync(`git ${args} -- ${paths}`, { cwd: repoDir, encoding: "utf8" });
  const changes = git("diff --name-only") + git("ls-files --others --exclude-standard");
  if (changes.trim() !== "") {
    console.error(`\nGenerated clients are out of date. Run "npm run generate" in api/ and commit the result.\n${changes}`);
    process.exit(1);
  }
  console.log("\nGenerated clients are up to date.");
}
