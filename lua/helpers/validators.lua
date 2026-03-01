local M = {}

local notify = require('helpers').notify

M.validae_version = function()
  local last_version = '0.10.0'

  local ok, version = pcall(vim.version)

  if not ok or not version then
    notify.error("Neovim minimum version not admited, you must user > " .. last_version)
  end
end

return M
