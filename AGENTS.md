# Repository Guidelines

## Project Structure & Module Organization

This repository is a Roblox Lua script hub.

- `loader.lua` is the public entry point loaded from GitHub raw content.
- `games.json` maps Roblox place IDs to supported game names.
- `games/` contains game-specific scripts named by place ID, for example `games/286090429.lua`.
- `scripts/Universal.lua` is the fallback script for unsupported games.
- `libraries/` contains shared helper libraries used by scripts.
- `version.txt` stores the current release version.

Keep place-specific behavior in `games/` and shared behavior in `libraries/`. Do not duplicate large helper blocks across game scripts.

## Build, Test, and Development Commands

There is no package manager or build step for this repo. Useful local checks:

```sh
git status --short
```

Shows changed files before committing.

```sh
lua -p loader.lua
```

Checks Lua syntax if a local Lua interpreter is installed. Repeat for changed `.lua` files.

```sh
git diff --check
```

Finds whitespace problems before commit.

Manual runtime validation should be done in the target Roblox environment using the loader URL from the README.

## Coding Style & Naming Conventions

Use Lua 5.1-compatible syntax. Prefer 4-space indentation, clear local variables, and small helper functions. Use `local` by default and avoid leaking globals except intentional loader guards such as `_G.LevisHubLoaded`.

Name game scripts by numeric place ID: `games/<placeId>.lua`. Use PascalCase for module-like library files, such as `UILibrary.lua`, and descriptive camelCase for local functions and variables.

## Testing Guidelines

No automated test suite currently exists. For each loader change, verify:

- supported place IDs load `games/<placeId>.lua`
- unsupported games load `scripts/Universal.lua`
- malformed or unavailable `games.json` falls back to the built-in registry
- script fetch or execution failure does not break the loader flow silently

For library changes, test at least one supported game and the universal script path.

## Commit & Pull Request Guidelines

Recent commits use short imperative messages, for example `Add README`, `Remove README`, and `Upload Levis Hub project`. Keep commit titles concise and describe the user-visible change.

Pull requests should include a short summary, changed files or areas, manual test notes, and screenshots or recordings for visible UI changes. Link related issues when available.

## Security & Configuration Tips

Do not commit secrets, private keys, executor tokens, or local machine paths. Keep `.DS_Store` and other OS-generated files out of git. Treat `loader.lua` changes carefully because users execute it directly from the `main` branch.
