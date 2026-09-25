local M = {}
local translate = require('tennant.i18n').get

M.setup = function(prefix)
  prefix = prefix or '<leader>tv'

  vim.keymap.set('x', prefix .. 'l', function() require('tennant.reader').selection() end,
    { desc = '[tennant] ' .. translate('Read selection'), silent = true })

  local maps = {
    { prefix .. 'w', function() require('tennant.reader').word() end,         'Read word' },
    { prefix .. 'l', function() require('tennant.reader').line() end,         'Read current line or line range' },
    { prefix .. 'b', function() require('tennant.reader').block() end,        'Read block' },
    { prefix .. 'p', function() require('tennant.reader').block(true) end,    'Read parent block' },
    { prefix .. 'n', function() require('tennant.notify').read_last() end,    'Read last notification' },
    { prefix .. 's', function() require('tennant.tts').stop() end,            'Stop speaking' },
  }

  for _, m in ipairs(maps) do
    vim.keymap.set('n', m[1], m[2], { desc = '[tennant] ' .. translate(m[3]), silent = true })
  end
end

return M
