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

  if backend ~= 'festival' then
    local configured = backend == 'Darwin' and { voice = 'Samantha', rate = 210 }
      or backend == 'Windows_NT' and { voice = 'Microsoft Zira Desktop', rate = -2, volume = 80 }
      or backend == 'spd-say' and { voice = 'en_US', rate = -20, pitch = 10, volume = 30 }
      or { voice = 'en+f3', rate = 190, pitch = 60, volume = 120 }
    tts.setup(configured)
    tts.speak(payload)
    call = calls[#calls]
    if backend == 'Windows_NT' then
      assert(call.options.env.TENNANT_TTS_VOICE == configured.voice)
      assert(call.options.env.TENNANT_TTS_RATE == '-2')
      assert(call.options.env.TENNANT_TTS_VOLUME == '80')
      assert(not table.concat(call.command, ' '):find(configured.voice, 1, true))
    else
      assert(vim.tbl_contains(call.command, configured.voice))
      assert(vim.tbl_contains(call.command, tostring(configured.rate)))
      if configured.pitch then
        assert(vim.tbl_contains(call.command, tostring(configured.pitch)))
        assert(vim.tbl_contains(call.command, tostring(configured.volume)))
      end
      if backend == 'spd-say' then
        assert(call.command[#call.command - 1] == '--' and call.command[#call.command] == payload)
      else
        assert(call.options.stdin == payload)
      end
    end
    assert(not pcall(tts.setup, { voice = '-malformed' }))
    assert(not pcall(tts.setup, { rate = -99999 }))
    tts.stop()
  else
    assert(not pcall(tts.setup, { voice = 'anything' }))
  end
end
vim.uv.os_uname = function()
  return { sysname = 'Linux' }
end
vim.fn.executable = function(bin)
  return (bin == 'spd-say' or bin == 'espeak-ng') and 1 or 0
end
package.loaded['tennant.tts'] = nil
local chosen = require('tennant.tts')
chosen.setup({ backend = 'espeak-ng', voice = 'en' })
assert(not pcall(chosen.setup, { backend = 'festival' }))
chosen.speak('selected')
assert(calls[#calls].command[1] == 'espeak-ng', 'Keep the selected backend after invalid configuration')
chosen.stop()
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
