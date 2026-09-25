local M = {}
local translate = require('tennant.i18n').get

local function check_version()
  if vim.fn.has('nvim-0.12') == 0 then
    vim.notify(
      '[tennant] ' .. translate('Requires Neovim >= 0.12 (found %s)'):format(tostring(vim.version())),
      vim.log.levels.ERROR
    )
    return false
  end
  return true
end

local function check_tts(tts)
  if not tts.backend then
    local msg = '[tennant] ' .. translate('No TTS backend found.') .. '\n'
    local sysname = vim.loop.os_uname().sysname
    if sysname:match('Linux') then
      msg = msg .. translate('Install one of: spd-say, espeak-ng, espeak, festival')
    elseif sysname:match('Windows') then
      msg = msg .. translate('Requires PowerShell with System.Speech (included in .NET Framework)')
    end
    vim.notify(msg, vim.log.levels.WARN)
  end
end

local function check_treesitter()
  if not vim.treesitter.get_node then
    vim.notify(
      '[tennant] ' .. translate('vim.treesitter.get_node unavailable; block reading will use the current line'),
      vim.log.levels.INFO
    )
  end
end

---@param opts? { prefix?: string, language?: "es"|"en" }
M.setup = function(opts)
  opts = opts or {}
  require('tennant.i18n').setup(opts.language)
  if not check_version() then
    return
  end

  local tts = require('tennant.tts')
  check_tts(tts)
  check_treesitter()

  -- Intercept vim.notify after plugins have loaded
  vim.api.nvim_create_autocmd('VimEnter', {
    once = true,
    callback = function()
      require('tennant.notify').intercept()
    end,
  })

  require('tennant.keymaps').setup(opts.prefix)

  -- User commands
  vim.api.nvim_create_user_command('TennantWord',   function() require('tennant.reader').word() end,        { desc = translate('Read word') })
  vim.api.nvim_create_user_command('TennantLine', function(args)
    require('tennant.reader').line(args.line1, args.line2)
  end, { range = true, desc = translate('Read current line or line range') })
  vim.api.nvim_create_user_command('TennantBlock',  function() require('tennant.reader').block() end,       { desc = translate('Read block') })
  vim.api.nvim_create_user_command('TennantParent', function() require('tennant.reader').block(true) end,   { desc = translate('Read parent block') })
  vim.api.nvim_create_user_command('TennantNotify', function() require('tennant.notify').read_last() end,   { desc = translate('Read last notification') })
  vim.api.nvim_create_user_command('TennantStop',   function() require('tennant.tts').stop() end,           { desc = translate('Stop speaking') })
end

return M
