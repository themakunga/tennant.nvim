-- Run: nvim --headless -u NONE -i NONE -l tests/language.lua
vim.opt.rtp:prepend('.')
local spoken, notice
vim.notify = function(text) notice = text end
local tts = require('tennant.tts')
tts.backend = nil
require('tennant').setup({ language = 'en', prefix = ',t' })
assert(notice:find('No TTS backend found.', 1, true))
tts.speak('test')
assert(notice == '[tennant] No TTS backend available')
tts.speak = function(text) spoken = text end
assert(vim.api.nvim_get_commands({}).TennantParent.definition == 'Read parent block')
assert(vim.fn.maparg(',tl', 'x', false, true).desc == '[tennant] Read selection')
local notify = require('tennant.notify')
notify.read_last()
assert(spoken == 'No recent notifications')
notify.intercept()
vim.notify('Original message', vim.log.levels.WARN)
notify.read_last()
assert(spoken == 'warning: Original message')
tts.backend = true
require('tennant').setup({ language = 'es', prefix = ',t' })
notify.read_last()
assert(spoken == 'advertencia: Original message')
assert(vim.api.nvim_get_commands({}).TennantParent.definition == 'Leer bloque contenedor')
local i18n = require('tennant.i18n')
assert(not pcall(require('tennant').setup, { language = 'fr' }))
assert(i18n.language == 'es', 'Invalid language must not change the current language')
i18n.setup('en')
i18n.setup()
assert(i18n.get('file') == 'archivo', 'Spanish remains the default')
print('Language checks passed')
