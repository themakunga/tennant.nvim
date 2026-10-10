#!/usr/bin/env python3
"""Idempotent daily pre-release from main; only invoked by trusted push jobs."""
from datetime import datetime
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
from zoneinfo import ZoneInfo

REPO = os.environ['GITHUB_REPOSITORY']
SHA = os.environ['GITHUB_SHA']
RUN = os.environ['GITHUB_RUN_ID']

def api(path, method='GET', data=None):
    command = ['gh', 'api', f'repos/{REPO}/{path}', '--method', method]
    if data is not None:
        command += ['--input', '-']
    value = subprocess.check_output(command, input=json.dumps(data).encode() if data is not None else None)
    return json.loads(value) if value.strip() else None

if api('git/ref/heads/main')['object']['sha'] != SHA:
    raise SystemExit('Newer main commit exists; skipping stale publication')

if os.environ['CI_RESULT'] != 'success':
    raise SystemExit('CI failed: release unchanged')

version = Path('VERSION').read_text().strip()
if not re.fullmatch(r'\d+\.\d+\.\d+', version):
    raise SystemExit('VERSION must contain X.Y.Z')

date = datetime.now(ZoneInfo('America/Santiago')).strftime('%Y%m%d')
tag = f'v{version}-pre-release.{date}'

# Validate head again immediately before publication.
if api('git/ref/heads/main')['object']['sha'] != SHA:
    raise SystemExit('Newer main commit exists; release unchanged')

refs = api(f'git/matching-refs/tags/{tag}')
if any(ref['ref'] == f'refs/tags/{tag}' for ref in refs):
    api(f'git/refs/tags/{tag}', 'PATCH', {'sha': SHA, 'force': True})
else:
    api('git/refs', 'POST', {'ref': f'refs/tags/{tag}', 'sha': SHA})

link = f'https://github.com/{REPO}/actions/runs/{RUN}'
notes = subprocess.check_output(['git', 'log', '--format=- %s (%h)', 'HEAD^..' + SHA], text=True)
notes = f'Daily snapshot for {date} (America/Santiago).\n\nCommit: `{SHA}`\n\n{notes}\n[Validation]({link})\n'

Path('reports').mkdir(exist_ok=True)
Path('reports/release.md').write_text(notes)

release_exists = subprocess.run(
    ['gh', 'release', 'view', tag],
    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
).returncode == 0
command = ['gh', 'release', 'edit' if release_exists else 'create', tag,
           '--title', tag, '--prerelease', '--notes-file', 'reports/release.md']
if not release_exists:
    command += ['--verify-tag']
subprocess.run(command, check=True)

assets = []
for extension, fmt in [('tar.gz', 'tar.gz'), ('zip', 'zip')]:
    path = Path(f'reports/tennant.nvim-{tag}.{extension}')
    subprocess.run(['git', 'archive', '--format=' + fmt, '--prefix=tennant.nvim/',
                    '--output=' + str(path), SHA], check=True)
    assets.append(path)

checksums = Path('reports/SHA256SUMS')
checksums.write_text(''.join(
    f'{hashlib.sha256(p.read_bytes()).hexdigest()}  {p.name}\n' for p in assets
))
subprocess.run(['gh', 'release', 'upload', tag, *map(str, assets), str(checksums), '--clobber'], check=True)

with open(os.environ['GITHUB_STEP_SUMMARY'], 'a') as f:
    f.write(f'Pre-release [{tag}](https://github.com/{REPO}/releases/tag/{tag}) updated.\n')
