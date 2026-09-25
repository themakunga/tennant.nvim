-- A real Neovim -> vim.system -> child Neovim boundary, with no audio device.
vim.opt.rtp:prepend('.')
local log = vim.fn.tempname()
local payload = 'café "quotes" $(touch NEVER) `code` ; & --help'
local tts = require('tennant.tts')
local native_backend = tts.backend
if native_backend then
  local command, options = native_backend(payload)
  assert(not vim.tbl_contains(command, payload) or vim.tbl_contains(command, '--'))
  if options then
    assert(options.stdin == payload, 'Text must be sent intact as data')
  end
end
local child = vim.fn.tempname() .. '.lua'
vim.fn.writefile({
  'local text = io.read("*a")',
  'vim.fn.writefile({text}, vim.env.TENNANT_TTS_LOG)',
  'vim.wait(10000, function() return false end)',
}, child)
tts.backend = function(text)
  return { vim.v.progpath, '--headless', '-u', 'NONE', '-i', 'NONE', '-l', child }, {
    stdin = text,
    env = { TENNANT_TTS_LOG = log },
  }
end
local language = vim.env.TENNANT_TEST_LANGUAGE or 'es'
require('tennant').setup({ language = language, prefix = ',t' })
vim.api.nvim_buf_set_lines(0, 0, -1, false, { payload, 'second line' })
vim.api.nvim_feedkeys(',tl', 'xt', false)
assert(vim.wait(5000, function()
  return vim.fn.filereadable(log) == 1
end))
assert(vim.fn.readfile(log)[1] == payload)
vim.cmd('TennantStop')
vim.fn.delete(log)
vim.api.nvim_feedkeys('ggVj,tl', 'xt', false)
assert(vim.wait(5000, function()
  return vim.fn.filereadable(log) == 1
end))
assert(vim.fn.readfile(log)[1] == payload .. ' second line')
vim.cmd('TennantStop')
vim.fn.delete(log)
vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'xt', false)
vim.notify('first notification')
vim.notify('second notification')
vim.cmd('TennantNotify')
assert(vim.wait(5000, function()
  return vim.fn.filereadable(log) == 1
end))
assert(vim.fn.readfile(log)[1]:find('2.', 1, true))
vim.fn.delete(log)
vim.api.nvim_feedkeys('n', 'xt', false)
assert(vim.wait(5000, function()
  return vim.fn.filereadable(log) == 1
end))
assert(vim.fn.readfile(log)[1]:find('second notification', 1, true))
vim.api.nvim_feedkeys('x', 'xt', false)
vim.fn.delete(log)
vim.fn.delete(child)
print('Process E2E checks passed')
