# 2026-08-22 19:00 — Remove unused legacy module and inline guide

- Removed the unused direct `calcit-lang/memof` dependency and its entry module from the canonical `calcit.cirru` snapshot.
- Replaced the long project-local Respo/Calcit command manual with a short project guide that points to `calcit docs read upgrade` and `library-quality`.
- Verified dependency resolution, snapshot check-only, and JavaScript generation; the local Node runtime is too old for this checkout's Vite build, while CI uses Node 24.
