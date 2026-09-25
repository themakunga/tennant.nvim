-- Run: nvim --headless -u NONE -i NONE -l tests/blocks.lua
vim.opt.rtp:prepend('.')
local spoken
package.loaded['tennant.tts'] = {
  backend = true,
  speak = function(text) spoken = text end,
}
require('tennant').setup({ prefix = ',t' })
local lines = {
  'function outer()',
  '  function inner()',
  '    print("inside")',
  '  end',
  '  print("outside")',
  'end',
  'print("file")',
}
vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
vim.bo.filetype = 'lua'
vim.treesitter.get_parser(0, 'lua'):parse()
vim.api.nvim_win_set_cursor(0, { 3, 6 })

local function keys(input)
  vim.api.nvim_feedkeys(input, 'xt', false)
end

local inner = 'función: ' .. table.concat({ 'function inner()', lines[3], lines[4] }, '\n')
local outer = 'función: ' .. table.concat(lines, '\n', 1, 6)
local file = 'archivo: ' .. table.concat(lines, '\n')
keys(',tb')
assert(spoken == inner, 'Read the entire inner function')
keys(',tp')
assert(spoken == outer, 'Read the entire enclosing function')
vim.cmd('TennantParent')
assert(vim.trim(spoken) == file, 'Read the file at the root')
for _ = 1, 2 do
  keys(',tp')
  assert(spoken == 'No existen más niveles de anidación', 'Announce exhaustion')
end
vim.cmd('TennantBlock')
assert(spoken == inner, 'Block command restarts at the cursor')
vim.api.nvim_win_set_cursor(0, { 5, 4 })
keys(',tp')
assert(vim.trim(spoken) == file, 'Cursor movement resets traversal')
vim.api.nvim_win_set_cursor(0, { 3, 6 })
keys(',tb')
vim.api.nvim_buf_set_lines(0, 2, 3, false, { '    print("edited")' })
keys(',tp')
assert(spoken == outer:gsub('inside', 'edited'), 'Edits invalidate the stored node')
vim.cmd('enew')
vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'plain text' })
keys(',tb')
assert(spoken == 'plain text', 'Missing parser falls back to current line')
keys(',tp')
assert(spoken == 'No existen más niveles de anidación', 'Never reuse another buffer node')
print('Nested block checks passed')
