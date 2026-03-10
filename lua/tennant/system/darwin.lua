local M = {}

---@param text string
---@param config tennant.SpeakConfig
---@return nil
M.default = function(text, config)
  if not text or text == "" then
    return
  end

  local cmd = { "say" }

  if config.voice then
    table.insert(cmd, '-v')
    table.insert(cmd, config.voice)
  end

  if config.rate then
    table.insert(cmd, '-r')
    table.insert(cmd, config.rate)
  end
  table.insert(cmd, text)

  vim.fn.jobstart(cmd, { detach = true })
end

return M
