#!/usr/bin/env python3
"""Run every Neovim check without writing logs to the checkout."""
import os
from pathlib import Path
import subprocess
import tempfile

failed = []
with tempfile.TemporaryDirectory() as directory:
    env = dict(os.environ, NVIM_LOG_FILE=str(Path(directory) / 'nvim.log'))
    for language in ('es', 'en'):
        for test in sorted(Path('tests').glob('*.lua')):
            print(f'\n== {test} ({language}) ==', flush=True)
            result = subprocess.run(['nvim', '--headless', '-u', 'NONE', '-i', 'NONE', '-l', str(test)],
                                    env=dict(env, TENNANT_TEST_LANGUAGE=language), timeout=90)
            if result.returncode:
                failed.append(f'{test} ({language})')
if failed:
    raise SystemExit('Failed: ' + ', '.join(failed))
print('All Neovim checks passed')
