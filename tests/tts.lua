vim.opt.rtp:prepend('.')
local original_system, original_uname, original_executable = vim.system, vim.uv.os_uname, vim.fn.executable
local calls, jobs, warnings = {}, {}, {}
vim.notify = function(message)
  warnings[#warnings + 1] = message
end
vim.system = function(command, options, callback)
  local job = { killed = false }
  job.kill = function()
    job.killed = true
  end
  jobs[#jobs + 1] = job
  calls[#calls + 1] = { command = command, options = options, callback = callback }
  return job
end
local payload = '"; $(echo unsafe) `code` & --help café'
for _, backend in ipairs({ 'Darwin', 'Windows_NT', 'spd-say', 'espeak-ng', 'espeak', 'festival' }) do
  vim.uv.os_uname = function()
    return { sysname = backend:match('Darwin') or backend:match('Windows_NT') or 'Linux' }
  end
  vim.fn.executable = function(bin)
    return bin == backend and 1 or 0
  end
  package.loaded['tennant.tts'] = nil
  local tts = require('tennant.tts')
  tts.speak(payload)
  local call = calls[#calls]
  if backend == 'spd-say' then
    assert(call.command[#call.command - 1] == '--' and call.command[#call.command] == payload)
  else
    assert(call.options.stdin == payload)
    assert(not vim.tbl_contains(call.command, payload))
  end
  local old = calls[#calls]
  tts.speak('replacement')
  assert(jobs[#jobs - 1].killed)
  old.callback({ code = 0 })
  vim.wait(20)
  tts.stop()
  assert(jobs[#jobs].killed, 'Old completion must not lose the replacement process')
end
local tts = require('tennant.tts')
tts.speak('failure')
calls[#calls].callback({ code = 1 })
vim.wait(20)
assert(#warnings == 1, 'Report process failure')
vim.system = function()
  error('spawn failed')
end
tts.speak('failure')
assert(#warnings == 2, 'Report spawn failure')
vim.system, vim.uv.os_uname, vim.fn.executable = original_system, original_uname, original_executable
print('TTS security and lifecycle checks passed')
