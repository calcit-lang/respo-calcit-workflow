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
caps --ci
calcit calcit.cirru edit format
git diff --exit-code -- calcit.cirru
calcit calcit.cirru --check-only
calcit calcit.cirru js
yarn vite build --base=./
```

For upgrade or migration questions, query the maintained guide instead of copying a detailed language manual into this project:

```bash
calcit docs read upgrade --full
calcit docs read library-quality.md --full
```

Dependencies belong in `deps.cirru` and should use published version tags. Keep the Calcit version and CLI commands aligned with `setup-calcit` and the current upgrade guide.
