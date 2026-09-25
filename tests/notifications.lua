-- Run: nvim --headless -u NONE -i NONE -l tests/notifications.lua
vim.opt.rtp:prepend('.')
local spoken, stopped = '', 0
package.loaded['tennant.tts'] = {
  speak = function(text)
    spoken = text
  end,
  stop = function()
    stopped = stopped + 1
  end,
}
vim.notify = function() end
local notify = require('tennant.notify')
notify.intercept()
notify.intercept()
notify.read_last()
assert(spoken == 'Sin notificaciones recientes')
vim.notify('first', vim.log.levels.INFO)
vim.notify('second', vim.log.levels.WARN)
local original = vim.api.nvim_get_current_buf()
vim.keymap.set('n', 'n', '<Nop>', { buffer = original, desc = 'original n' })
local function key(k)
  vim.api.nvim_feedkeys(k, 'xt', false)
end
notify.read_last()
assert(spoken:find('Notificaciones: 2. información: first', 1, true))
assert(spoken:find('Presiona n', 1, true))
vim.notify('third')
key('n')
assert(spoken:find('advertencia: second', 1, true))
assert(spoken:find('No hay más notificaciones', 1, true))
local before = stopped
key('x')
assert(stopped > before)
assert(vim.api.nvim_get_current_buf() == original)
assert(vim.fn.maparg('n', 'n', false, true).desc == 'original n')
require('tennant.i18n').setup('en')
notify.read_last()
assert(spoken:find('Notifications: 3. information: first', 1, true))
key('n')
key('n')
assert(spoken:find('information: third', 1, true))
key('n')
assert(vim.api.nvim_get_current_buf() == original)
notify.read_last()
notify.cancel()
assert(vim.api.nvim_get_current_buf() == original)
print('Notification checks passed')
