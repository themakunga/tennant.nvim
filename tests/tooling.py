"""Prove the configured tools reject deliberately broken, disposable inputs."""
from pathlib import Path
import secrets
import string
import subprocess
import sys
import tempfile

with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    lua = root / 'bad.lua'
    lua.write_text('local unused={ a=1}\nmissing_global()\n')
    secret = root / 'secret.txt'
    # Synthetic token, assembled to avoid putting a credential-shaped string in Git.
    secret.write_text('token = "' + 'ghp_' + ''.join(secrets.choice(string.ascii_letters + string.digits) for _ in range(36)) + '"\n')
    workflow = root / 'unsafe.yml'
    workflow.write_text('name: bad\non: push\njobs:\n  check:\n    runs-on: ubuntu-latest\n    steps:\n      - uses: actions/checkout@main\n')
    invalid = root / 'invalid.yml'
    invalid.write_text('name: bad\non: push\njobs:\n  check:\n    steps:\n      - run: echo missing runner\n')
    commands = [
        ['stylua', '--check', str(lua)],
        ['luacheck', str(lua)],
        ['gitleaks', 'dir', '--redact', '--no-banner', str(root)],
        ['actionlint', str(invalid)],
        ['zizmor', '--offline', '--min-severity', 'low', str(workflow)],
    ]
    for command in commands:
        result = subprocess.run([sys.executable, 'scripts/hook.py', *command],
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        assert result.returncode != 0, f'{command[0]} failed to reject the fixture'
        assert 'Traceback' not in result.stdout and 'not found' not in result.stdout.lower(), result.stdout
        print(f'{command[0]} rejected the deliberately unsafe fixture')
