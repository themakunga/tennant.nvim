local M = {}

---@param config tennant.Config
M.default = function(config)
  local command = vim.api.nvim_create_user_command
  local prefix = config.command_prefix or "Tennant"
  local notify = require("helpers").notify

  command(prefix .. 'ReadLine', function()
    require("tennant").read_line()
  end, {})


  command(prefix .. "Enable", function()
    config.enable = true
    notify.info(prefix .. " activated")
  end, {})

  command(prefix .. "Disable", function()
    config.enable = false
    notify.info(prefix .. "deactivated")
  end, {})

  command(prefix .. "Toggle", function()
    config.enable = not config.enable
    notify.info(prefix .. " " .. (config.enable and "activive" or "deactive"))
  end, {})
end

return M
