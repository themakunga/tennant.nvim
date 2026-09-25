#!/usr/bin/env python3
"""Collect every check, including failures, into the Actions summary."""
import os
from pathlib import Path
import subprocess

commands = {
    'tool-regressions': ['python3', 'tests/tooling.py'],
    'hooks': ['pre-commit', 'run', '--all-files', '--hook-stage', 'pre-commit'],
    'secrets-history': ['gitleaks', 'git', '--redact', '--no-banner', '--report-format', 'json',
                        '--report-path', 'reports/secrets.json'],
    'security-rule-tests': ['semgrep', 'scan', '--test', '--config', '.github/security/lua.yml',
                            'tests/fixtures/security.lua'],
}
Path('reports').mkdir(exist_ok=True)
rows = ['# Quality and security', '', '| Check | Result |', '|---|---|']
failed = False
for name, command in commands.items():
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    Path(f'reports/{name}.log').write_text(result.stdout)
    print(result.stdout)
    failed |= result.returncode != 0
    rows.append(f'| {name} | {"PASS" if result.returncode == 0 else "FAIL"} |')
summary = '\n'.join(rows) + '\n'
Path('reports/summary.md').write_text(summary)
if os.environ.get('GITHUB_STEP_SUMMARY'):
    with open(os.environ['GITHUB_STEP_SUMMARY'], 'a') as output:
        output.write(summary)
raise SystemExit(int(failed))
