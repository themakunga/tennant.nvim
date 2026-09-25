local M = {}

local function check_version()
  if vim.fn.has('nvim-0.12') == 0 then
    vim.notify(
      '[tennant] Requiere Neovim >= 0.12 (tienes ' .. tostring(vim.version()) .. ')',
      vim.log.levels.ERROR
    )
    return false
  end
  return true
end

local function check_tts(tts)
  if not tts.backend then
    local msg = '[tennant] No se encontró backend TTS.\n'
    local sysname = vim.loop.os_uname().sysname
    if sysname:match('Linux') then
      msg = msg .. 'Instala uno de: spd-say, espeak-ng, espeak, festival'
    elseif sysname:match('Windows') then
      msg = msg .. 'Requiere PowerShell con System.Speech (incluido en .NET Framework)'
    end
    vim.notify(msg, vim.log.levels.WARN)
  end
end

local function check_treesitter()
  if not vim.treesitter.get_node then
    vim.notify(
      '[tennant] vim.treesitter.get_node no disponible; lectura de bloques usará la línea actual',
      vim.log.levels.INFO
    )
  end
end

---@param opts? { prefix?: string }
M.setup = function(opts)
  if not check_version() then
    return
  end

  opts = opts or {}

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
  vim.api.nvim_create_user_command('TennantWord',   function() require('tennant.reader').word() end,        { desc = 'Leer palabra bajo el cursor' })
  vim.api.nvim_create_user_command('TennantLine', function(args)
    require('tennant.reader').line(args.line1, args.line2)
  end, { range = true, desc = 'Read current line or line range' })
  vim.api.nvim_create_user_command('TennantBlock',  function() require('tennant.reader').block() end,       { desc = 'Leer bloque actual' })
  vim.api.nvim_create_user_command('TennantParent', function() require('tennant.reader').block(true) end,   { desc = 'Read parent block' })
  vim.api.nvim_create_user_command('TennantNotify', function() require('tennant.notify').read_last() end,   { desc = 'Leer última notificación' })
  vim.api.nvim_create_user_command('TennantStop',   function() require('tennant.tts').stop() end,           { desc = 'Detener lectura' })
end

return M
