-- Run: nvim --headless -u NONE -i NONE -l tests/selection.lua
vim.opt.rtp:prepend('.')
local spoken
package.loaded['tennant.tts'] = {
  backend = true,
  speak = function(text) spoken = text end,
}
require('tennant').setup({ prefix = ',t' })
vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'alpha', 'bravo', 'café' })
vim.fn.setreg('"', 'keep me')

local function keys(input)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(input, true, false, true), 'xt', false)
end

local function selection(input, expected)
  keys('<Esc>gg0' .. input .. ',tl')
  assert(spoken == expected, vim.inspect({ expected = expected, actual = spoken }))
  assert(vim.fn.getreg('"') == 'keep me', 'Selection must not overwrite registers')
end

selection('Vj', 'alpha\nbravo')
selection('jVk', 'alpha\nbravo')
selection('lvjl', 'lpha\nbra')
selection('<C-v>jl', 'al\nbr')
selection('jjllv$', 'fé')
vim.o.selection = 'exclusive'
selection('vl', 'a')
vim.o.selection = 'inclusive'
keys('<Esc>gg0,tl')
assert(spoken == 'alpha', 'Normal mapping must still read the current line')
vim.cmd('2,3TennantLine')
assert(spoken == 'bravo\ncafé', 'Command must read the supplied range')
vim.cmd('TennantLine')
assert(spoken == 'alpha', 'Command without a range must read the current line')
keys('ggVj:TennantLine<CR>')
assert(spoken == 'alpha\nbravo', 'Command must accept the Visual line range')
print('Selection and line range checks passed')
