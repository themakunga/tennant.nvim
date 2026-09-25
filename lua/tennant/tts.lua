local M = {}
local translate = require('tennant.i18n').get

local _job = nil

local function detect_backend()
  local sysname = vim.loop.os_uname().sysname

  if sysname == 'Darwin' then
    return function(text)
      return { 'say' }, { stdin = text }
    end
  end

  if sysname:match('Windows') then
    return function(text)
      return {
        'powershell',
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        '[Console]::InputEncoding = [System.Text.Encoding]::UTF8; '
          .. 'Add-Type -AssemblyName System.Speech; '
          .. '$speaker = New-Object System.Speech.Synthesis.SpeechSynthesizer; '
          .. '$speaker.Speak([Console]::In.ReadToEnd())',
      }, { stdin = text }
    end
  end

  -- Linux: first available
  -- ponytail: no native Linux TTS exists; check order by quality
  for _, bin in ipairs({ 'spd-say', 'espeak-ng', 'espeak', 'festival' }) do
    if vim.fn.executable(bin) == 1 then
      if bin == 'festival' then
        return function(text)
          return { 'festival', '--tts' }, { stdin = text }
        end
      end
      return function(text)
        if bin == 'spd-say' then
          return { bin, '--wait', '--', text }
        end
        return { bin, '--stdin' }, { stdin = text }
      end
    end
  end

  return nil
end

M.backend = detect_backend()

M.speak = function(text)
  if not M.backend then
    vim.notify('[tennant] ' .. translate('No TTS backend available'), vim.log.levels.WARN)
    return
  end
  text = vim.trim(text):gsub('%s+', ' ')
  if text == '' then
    return
  end
  M.stop()
  local job
  local ok, result = pcall(function()
    local command, options = M.backend(text)
    return vim.system(command, options or {}, function(exit)
      vim.schedule(function()
        if _job ~= job then
          return
        end
        _job = nil
        if exit.code ~= 0 then
          vim.notify('[tennant] ' .. translate('TTS process failed'), vim.log.levels.WARN)
        end
      end)
    end)
  end)
  if ok then
    job = result
    _job = job
  else
    vim.notify('[tennant] ' .. translate('Unable to start TTS process'), vim.log.levels.WARN)
  end
end

M.stop = function()
  if _job then
    _job:kill(9)
    _job = nil
  end
end

return M
