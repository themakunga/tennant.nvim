local M = {}

local notify = require("helpers").notify

---@param text string
---@param config tennant.SpeakConfig
M.default = function(text, config)
  if not text or text == "" then
    return
  end

  local cmd = {}

  if vim.fn.execute("espeak") == 1 then
    table.insert(cmd, "espeak")
  elseif vim.fn.execute("espeak-ng") == 1 then
    table.insert(cmd, "espeak-ng")
  else
    notify.error("There is no voice over package installed on this system (eSpeak or eSpeak-ng)")
    return
  end

  if config.voice then
    table.insert(cmd, '-v')
    table.insert(cmd, tostring(config.voice))
  end

  if config.rate then
    table.insert(cmd, '-s')
    table.insert(cmd, tostring(config.rate))
  end

  table.insert(cmd, text)

  vim.fn.jobstart(cmd, { detach = true })
end

return M
