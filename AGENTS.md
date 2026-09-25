# Repository workflow

- Integrate all work through develop. Contributors use feature branches/forks and PRs.
- Never merge develop into main: only @themakunga may perform that action.
- Reuse the existing open develop-to-main PR and the marked bot report comment.
- Keep code, commits and automation in English; maintain Spanish and English docs.
- Run pre-commit checks and `python3 scripts/test.py` before pushing.
- Never weaken security checks to make CI pass. Fix demonstrated failures minimally.
- Keep TTS content as data (argv with option boundaries or stdin), never shell code.
- Do not commit logs, credentials, tool downloads or test artifacts.
- Bump VERSION deliberately; only the current daily pre-release tag may move.
