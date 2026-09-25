#!/usr/bin/env python3
"""Install checksum-pinned binaries into .tools (Python 3.12+)."""
import hashlib
import json
import os
from pathlib import Path
import platform
import sys
import tarfile
import urllib.request
import zipfile

lock = json.loads(Path('scripts/tools.json').read_text())
system = platform.system()
arm = platform.machine().lower() in ('arm64', 'aarch64')
for tool in sys.argv[1:] or lock:
    version = lock[tool]['version'].removeprefix('v')
    osname = {'Darwin': 'darwin', 'Linux': 'linux', 'Windows': 'windows'}[system]
    if tool == 'nvim':
        name = ('nvim-win-arm64.zip' if arm else 'nvim-win64.zip') if system == 'Windows' else (
            f'nvim-{"macos" if system == "Darwin" else "linux"}-{"arm64" if arm else "x86_64"}.tar.gz')
    elif tool == 'stylua':
        name = f'stylua-{"macos" if system == "Darwin" else osname}-{"aarch64" if arm else "x86_64"}.zip'
    else:
        arch = 'arm64' if arm else ('amd64' if tool == 'actionlint' else 'x64')
        name = f'{tool}_{version}_{osname}_{arch}.{"zip" if system == "Windows" else "tar.gz"}'
    asset = lock[tool]['assets'][name]
    dest = Path('.tools') / tool
    dest.mkdir(parents=True, exist_ok=True)
    archive = dest / name
    if not archive.exists() or hashlib.sha256(archive.read_bytes()).hexdigest() != asset['sha256']:
        urllib.request.urlretrieve(asset['url'], archive)
    if hashlib.sha256(archive.read_bytes()).hexdigest() != asset['sha256']:
        raise SystemExit(f'Checksum mismatch: {name}')
    if name.endswith('.zip'):
        with zipfile.ZipFile(archive) as source:
            source.extractall(dest)
    else:
        with tarfile.open(archive) as source:
            source.extractall(dest, filter='data')
    executable = next(p for p in dest.rglob(tool + ('.exe' if system == 'Windows' else '')) if p.is_file())
    executable.chmod(0o755)
    binpath = str(executable.parent.resolve())
    print(binpath)
    if os.environ.get('GITHUB_PATH'):
        with open(os.environ['GITHUB_PATH'], 'a') as output:
            output.write(binpath + '\n')
