# Agent notes

This repository is a small Respo/Calcit workflow example. Keep project-specific notes short; use the current Calcit documentation for language and tool details.

## Before editing

```bash
calcit docs agents --full
calcit docs read upgrade --full
calcit query config
calcit query ns
calcit query modules
```

The source snapshot is `calcit.cirru`. Do not add or restore `compact.cirru`; use `calcit edit` and `calcit tree` for snapshot changes, then run `calcit calcit.cirru edit format`.

## Validation

```bash
caps --strict --ci
yarn install --immutable
caps verify --toolchain
calcit calcit.cirru edit format
git diff --exit-code -- calcit.cirru
calcit calcit.cirru --check-only
calcit calcit.cirru analyze dynamic-methods --max 0
calcit calcit.cirru analyze quality --baseline config/calcit-quality.json
calcit calcit.cirru js
yarn vite build --base=./
```

For upgrade or migration questions, query the maintained guide instead of copying a detailed language manual into this project:

```bash
calcit docs read upgrade --full
calcit docs read library-quality.md --full
```

Dependencies belong in `deps.cirru` and should use published version tags. Keep `deps.cirru` and `@calcit/procs` on the same exact Calcit version; enforce that relationship with `caps verify --toolchain`.
