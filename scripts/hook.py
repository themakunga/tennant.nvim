#!/usr/bin/env python3
"""Expose repository-local development tools to Git hooks."""
import os
from pathlib import Path
import subprocess
import sys

root = Path(__file__).resolve().parent.parent
paths = [root / '.venv/bin', root / '.venv/Scripts', root / '.tools/luacheck/bin']
for tool in ('stylua', 'actionlint', 'gitleaks', 'nvim'):
    for candidate in (root / '.tools' / tool).rglob(tool + ('.exe' if os.name == 'nt' else '')):
        if candidate.is_file():
            paths.append(candidate.parent)
env = dict(os.environ, PATH=os.pathsep.join(map(str, paths)) + os.pathsep + os.environ['PATH'])
# Local scans do not need credentials, and zizmor rejects empty token variables.
for name in ('GH_TOKEN', 'GITHUB_TOKEN'):
    env.pop(name, None)
env['SEMGREP_SEND_METRICS'] = 'off'
raise SystemExit(subprocess.run(sys.argv[1:], env=env).returncode)
