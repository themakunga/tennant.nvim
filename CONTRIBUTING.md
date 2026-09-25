# Contributing / Contribuir

## English

Use feature branches or forks and open pull requests against **develop**. Never push to
`main`. Only @themakunga reviews and merges contributions; only the automated
`develop → main` promotion PR targets `main`. No automatic merging is enabled.
Owner-authored PRs do not require self-approval. Other PRs require the owner's
approval of the current commit. After approving a PR, comment `/recheck` to refresh its policy status.
Before the first promotion is merged, rerun the successful develop CI run instead;
the default branch does not have the policy workflow yet. Updating a PR invalidates the prior approval.

Python 3.12+, Git, Neovim 0.12.4 and LuaRocks are required. Install the development tools:

```sh
python3 -m venv .venv
. .venv/bin/activate
pip install -r scripts/requirements-ci.txt
python3 scripts/install-tools.py nvim stylua actionlint gitleaks
luarocks install luacheck 1.2.0
```

Hooks automatically find tools in `.tools` and `.venv`. Add the LuaRocks bin
directory to PATH. For direct CLI use, add the directories printed by the installer. On Windows activate `.venv\Scripts\Activate.ps1` and use
`python` instead of `python3` if required. Then install both local hooks:

```sh
pre-commit install --hook-type pre-commit --hook-type pre-push
pre-commit run --all-files
python3 scripts/test.py
```

Run `stylua lua tests` to format Lua. Security fixtures intentionally contain unsafe
examples and are excluded from normal lint; Semgrep tests validate them separately.
CI repeats the hooks and runs both languages on Linux, macOS and Windows. E2E uses
real Neovim subprocesses without audio output; pronunciation is not tested.

All contributions are licensed under MIT. Explain the behavior change, include a
regression check, and update both README languages. Report vulnerabilities privately
as described in SECURITY.md. Do not put credentials or sensitive logs in PRs.

After validated pushes to develop, Actions maintains one promotion PR and one bot
report comment. VERSION sets the next stable base (initially 0.1.0). Daily tags use
`vX.Y.Z-pre-release.AAAAMMDD` in America/Santiago. The current day's tag, notes and
archives are replaced after each successful run; pin a commit for reproducibility.
Older daily releases remain. Failed or stale runs cannot publish. Stable tags are
created only by the owner from main. No days without changes are published.

## Español

Trabaja en ramas de funcionalidad o forks y abre PR hacia **develop**. Solo
@themakunga revisa y fusiona aportes. El bot mantiene un único PR `develop → main`;
no se permite fusionarlo automáticamente ni enviar cambios directamente a main.
Los PR del propietario no requieren autoaprobación. Los demás requieren su
aprobación del commit actual; tras aprobar un PR, comenta `/recheck` para actualizar el estado.
Antes de fusionar la primera promoción, vuelve a ejecutar CI de develop: el workflow
de política aún no existe en la rama predeterminada. Cada cambio invalida la aprobación anterior.

Instala las herramientas y ambos hooks con los comandos anteriores. Los controles
se repiten en CI porque los hooks locales pueden omitirse. Añade una prueba de
regresión y documentación en ambos idiomas. Las pruebas E2E usan procesos reales
sin sonido, no evalúan pronunciación. Los aportes se distribuyen bajo MIT.

Cada cambio validado actualiza la pre-release del día usando la fecha de Chile y
la base de VERSION. Su tag es mutable durante ese día: fija un commit si necesitas
reproducibilidad. Los días anteriores se conservan y los fallos bloquean publicación.
