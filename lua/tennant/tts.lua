local M = {}

local _job = nil

local function detect_backend()
  local sysname = vim.loop.os_uname().sysname

  if sysname == 'Darwin' then
    return function(text)
      return { 'say', text }
    end
  end

  if sysname:match('Windows') then
    return function(text)
      local safe = text:gsub('"', ''):gsub("'", '')
      return {
        'powershell',
        '-NoProfile',
        '-Command',
        string.format(
          'Add-Type -AssemblyName System.Speech; (New-Object System.Speech.Synthesis.SpeechSynthesizer).Speak("%s")',
          safe
        ),
      }
    end
  end

  -- Linux: first available
  -- ponytail: no native Linux TTS exists; check order by quality
  for _, bin in ipairs({ 'spd-say', 'espeak-ng', 'espeak', 'festival' }) do
    if vim.fn.executable(bin) == 1 then
      if bin == 'festival' then
        return function(text)
          local safe = text:gsub("'", '')
          return { 'sh', '-c', string.format("printf '%%s' '%s' | festival --tts", safe) }
        end
      end
      return function(text)
        return { bin, text }
      end
    end
  end

  return nil
end

M.backend = detect_backend()

M.speak = function(text)
  if not M.backend then
    vim.notify('[tennant] Sin backend TTS disponible', vim.log.levels.WARN)
    return
  end
  text = vim.trim(text):gsub('%s+', ' ')
  if text == '' then
    return
  end
  M.stop()
  _job = vim.system(M.backend(text), {}, function()
    _job = nil
  end)
end

M.stop = function()
  if _job then
    _job:kill(9)
    _job = nil
  end
end

return M
