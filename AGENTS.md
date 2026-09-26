# Repository workflow

- `main` is the single source of truth. All feature branches are cut from `main` and merged back via PR.
- Only @themakunga may merge to `main`.
- Release branches (`release/vX.Y.Z`) are cut from `main`, contain the version bump, and are handled by the release pipeline.
- Keep code, commits and automation in English; maintain Spanish and English docs.
- Run pre-commit checks and `python3 scripts/test.py` before pushing.
- Never weaken security checks to make CI pass. Fix demonstrated failures minimally.
- Keep TTS content as data (argv with option boundaries or stdin), never shell code.
- Do not commit logs, credentials, tool downloads or test artifacts.
- Bump VERSION deliberately; only the current daily pre-release tag may move.
