local M = {}

local levels = {
  ERROR = 1,
  WARN = 2,
  INFO = 3,
  DEBUG = 4,
  TRACE = 5,
}


local function notify(message, level, opts)
  opts = opts or {}

  local l = vim.log.levels
  if vim.notify then
    if not vim.log then
      vim.notify(message, level, opts)
    else
      local lvl


      if level == levels.ERROR then
        lvl = l.ERROR
      elseif level == levels.WARN then
        lvl = l.WARN
      elseif level == levels.INFO then
        lvl = l.INFO
      elseif level == levels.DEBUG then
        lvl = l.DEBUG
      else
        lvl = level
      end
      vim.notify(message, lvl, opts)
    end
  else
    local hl
    if level == l.ERROR then
      hl = "ErrorMsg"
    elseif level == l.WARN then
      hl = "WarnMsg"
    elseif level == l.INFO then
      hl = "InfoMsg"
    elseif level == l.DEBUG then
      hl = "DebugMsg"
    else
      hl = "None"
    end
    vim.api.nvim_echo({ { message, hl } }, true, {})
  end
end

M.error = function(message, opts)
  notify(message, levels.ERROR, opts)
end

M.warn = function(message, opts)
  notify(message, levels.WARN, opts)
end

M.info = function(message, opts)
  notify(message, levels.INFO, opts)
end

M.debug = function(message, opts)
  notify(message, levels.DEBUG, opts)
end

M.notify = function(message, level, opts)
  notify(message, level, opts)
end

return M
