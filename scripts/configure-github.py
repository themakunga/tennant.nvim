#!/usr/bin/env python3
"""Apply reviewed repository settings. Run once as the repository owner after bootstrap."""
import json
from pathlib import Path
import subprocess

repo = 'themakunga/tennant.nvim'
def api(path, method='GET', data=None):
    command = ['gh', 'api', f'repos/{repo}/{path}', '--method', method]
    if data is not None:
        command += ['--input', '-']
    output = subprocess.check_output(command, input=json.dumps(data).encode() if data is not None else None)
    return json.loads(output) if output.strip() else None

api('actions/permissions/workflow', 'PUT', {'default_workflow_permissions':'read','can_approve_pull_request_reviews':True})
api('private-vulnerability-reporting', 'PUT')
existing = {rule['name']:rule['id'] for rule in api('rulesets')}
for path in sorted(Path('.github/rulesets').glob('*.json')):
    rule = json.loads(path.read_text())
    identifier = existing.get(rule['name'])
    result = api(f'rulesets/{identifier}' if identifier else 'rulesets', 'PUT' if identifier else 'POST', rule)
    print(f'{result["name"]}: active ({result["id"]})')
