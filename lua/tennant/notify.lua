local M = {}
local translate = require('tennant.i18n').get

local history = {}
local session
local interceptor

local LEVEL_NAMES = {
  [vim.log.levels.TRACE] = 'trace',
  [vim.log.levels.DEBUG] = 'debug',
  [vim.log.levels.INFO] = 'information',
  [vim.log.levels.WARN] = 'warning',
  [vim.log.levels.ERROR] = 'error',
  [vim.log.levels.OFF] = 'off',
}

-- Must be called after notify plugins have replaced vim.notify.
M.intercept = function()
  if vim.notify == interceptor then
    return
  end
  local original = vim.notify
  interceptor = function(msg, level, opts)
    history[#history + 1] = { msg = tostring(msg), level = level or vim.log.levels.INFO }
    original(msg, level, opts)
  end
  vim.notify = interceptor
end

M.cancel = function()
  require('tennant.tts').stop()
  if session then
    local window = session.window
    session = nil
    if vim.api.nvim_win_is_valid(window) then
      vim.api.nvim_win_close(window, true)
    end
  end
end

local function read_current(first)
  local entry = session.entries[session.index]
  local level = translate(LEVEL_NAMES[entry.level] or 'information')
  local prompt = translate('Press n to continue or x to stop.')
  local text = level .. ': ' .. entry.msg
  if first then
    text = translate('Notifications: %d.'):format(#session.entries) .. ' ' .. text
  end
  if session.index == #session.entries then
    prompt = translate('No more notifications. Press x to close.')
  end
  vim.api.nvim_buf_set_lines(session.buffer, 0, -1, false,
    vim.split(text .. '\n\n' .. prompt, '\n', { plain = true }))
  require('tennant.tts').speak(text .. '. ' .. prompt)
end

M.read_last = function()
  M.cancel()
  if #history == 0 then
    require('tennant.tts').speak(translate('No recent notifications'))
    return
  end
  local buffer = vim.api.nvim_create_buf(false, true)
  local width = math.max(1, math.min(70, vim.o.columns - 4))
  local height = math.max(1, math.min(8, vim.o.lines - 4))
  local window = vim.api.nvim_open_win(buffer, true, {
    relative = 'editor', width = width, height = height,
    row = 1, col = 1, style = 'minimal', border = 'single',
  })
  vim.bo[buffer].bufhidden = 'wipe'
  session = { buffer = buffer, window = window, entries = vim.deepcopy(history), index = 1 }
  vim.keymap.set('n', 'n', function()
    if session.index == #session.entries then
      M.cancel()
      return
    end
    session.index = session.index + 1
    read_current(false)
  end, { buffer = buffer, silent = true })
  vim.keymap.set('n', 'x', M.cancel, { buffer = buffer, silent = true })
  vim.keymap.set('n', '<Esc>', M.cancel, { buffer = buffer, silent = true })
  vim.api.nvim_create_autocmd('BufLeave', { buffer = buffer, once = true, callback = M.cancel })
  read_current(true)
end

return M
