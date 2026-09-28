local M = {}
local translate = require('tennant.i18n').get

local _job = nil
local settings = {}

local supported = {
  Darwin = { voice = true, rate = { 1 } },
  Windows = { voice = true, rate = { -10, 10 }, volume = { 0, 100 } },
  ['spd-say'] = { voice = true, rate = { -100, 100 }, pitch = { -100, 100 }, volume = { -100, 100 } },
  ['espeak-ng'] = { voice = true, rate = { 1 }, pitch = { 0, 99 }, volume = { 0, 200 } },
  espeak = { voice = true, rate = { 1 }, pitch = { 0, 99 }, volume = { 0, 200 } },
  festival = {},
}

local function append(command, flag, value)
  if value ~= nil then
    command[#command + 1] = flag
    command[#command + 1] = tostring(value)
  end
end

local function detect_backend(preferred)
  local sysname = vim.loop.os_uname().sysname

  if sysname == 'Darwin' and (not preferred or preferred == 'say') then
    return function(text)
      local command = { 'say' }
      append(command, '-v', settings.voice)
      append(command, '-r', settings.rate)
      return command, { stdin = text }
    end,
      'Darwin'
  end

  if sysname:match('Windows') and (not preferred or preferred == 'powershell') then
    return function(text)
      return {
        'powershell',
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        '[Console]::InputEncoding = [System.Text.Encoding]::UTF8; '
          .. 'Add-Type -AssemblyName System.Speech; '
          .. '$speaker = New-Object System.Speech.Synthesis.SpeechSynthesizer; '
          .. 'if ($env:TENNANT_TTS_VOICE) { $speaker.SelectVoice($env:TENNANT_TTS_VOICE) }; '
          .. 'if ($env:TENNANT_TTS_RATE) { $speaker.Rate = [int]$env:TENNANT_TTS_RATE }; '
          .. 'if ($env:TENNANT_TTS_VOLUME) { $speaker.Volume = [int]$env:TENNANT_TTS_VOLUME }; '
          .. '$speaker.Speak([Console]::In.ReadToEnd())',
      }, {
        stdin = text,
        env = {
          TENNANT_TTS_VOICE = settings.voice or '',
          TENNANT_TTS_RATE = settings.rate and tostring(settings.rate) or '',
          TENNANT_TTS_VOLUME = settings.volume and tostring(settings.volume) or '',
        },
      }
    end,
      'Windows'
  end

  -- Linux: first available
  -- ponytail: no native Linux TTS exists; check order by quality
  for _, bin in ipairs(preferred and { preferred } or { 'spd-say', 'espeak-ng', 'espeak', 'festival' }) do
    if supported[bin] and vim.fn.executable(bin) == 1 then
      if bin == 'festival' then
        return function(text)
          return { 'festival', '--tts' }, { stdin = text }
        end, bin
      end
      return function(text)
        if bin == 'spd-say' then
          local command = { bin, '--wait' }
          append(command, '-y', settings.voice)
          append(command, '-r', settings.rate)
          append(command, '-p', settings.pitch)
          append(command, '-i', settings.volume)
          command[#command + 1] = '--'
          command[#command + 1] = text
          return command
        end
        local command = { bin, '--stdin' }
        append(command, '-v', settings.voice)
        append(command, '-s', settings.rate)
        append(command, '-p', settings.pitch)
        append(command, '-a', settings.volume)
        return command, { stdin = text }
      end,
        bin
    end
  end

  return nil
end

M.backend, M.backend_name = detect_backend()

M.setup = function(opts)
  opts = opts or {}
  local backend, name = M.backend, M.backend_name
  if opts.backend ~= nil then
    assert(type(opts.backend) == 'string', '[tennant] tts.backend must be a backend name')
    backend, name = detect_backend(opts.backend)
    assert(backend, '[tennant] TTS backend unavailable: ' .. opts.backend)
  end
  for key, value in pairs(opts) do
    if key ~= 'backend' then
      local range = (supported[name] or {})[key]
      assert(range, '[tennant] tts.' .. key .. ' is unsupported by this TTS backend')
      if key == 'voice' then
        assert(
          type(value) == 'string' and value ~= '' and not value:match('^%-') and not value:find('\0'),
          '[tennant] tts.voice must be a nonempty voice name'
        )
      else
        assert(
          type(value) == 'number' and value % 1 == 0 and value >= range[1] and (not range[2] or value <= range[2]),
          '[tennant] tts.' .. key .. ' is out of range'
        )
      end
    end
  end
  M.backend, M.backend_name = backend, name
  settings = { voice = opts.voice, rate = opts.rate, pitch = opts.pitch, volume = opts.volume }
end

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
