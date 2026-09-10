local M = {}

local _last = nil

local LEVEL_NAMES = {
  [vim.log.levels.TRACE] = 'trace',
  [vim.log.levels.DEBUG] = 'debug',
  [vim.log.levels.INFO] = 'información',
  [vim.log.levels.WARN] = 'advertencia',
  [vim.log.levels.ERROR] = 'error',
  [vim.log.levels.OFF] = 'off',
}

-- Must be called after notify plugins have replaced vim.notify
M.intercept = function()
  local original = vim.notify
  vim.notify = function(msg, level, opts)
    _last = { msg = tostring(msg), level = level or vim.log.levels.INFO }
    original(msg, level, opts)
  end
end

M.read_last = function()
  local speak = require('tennant.tts').speak
  if not _last then
    speak('Sin notificaciones recientes')
    return
  end
  local level_name = LEVEL_NAMES[_last.level] or 'información'
  speak(level_name .. ': ' .. _last.msg)
end

return M
