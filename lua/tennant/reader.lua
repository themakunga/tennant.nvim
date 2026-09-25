local M = {}
local translate = require('tennant.i18n').get

-- Block types to announce via treesitter
local BLOCK_LABELS = {
  function_definition = 'function',
  function_declaration = 'function',
  method_definition = 'method',
  method_declaration = 'method',
  arrow_function = 'arrow function',
  variable_declaration = 'variable',
  lexical_declaration = 'variable',
  const_declaration = 'constant',
  class_definition = 'class',
  class_declaration = 'class',
  if_statement = 'if block',
  for_statement = 'for loop',
  for_in_statement = 'for in loop',
  while_statement = 'while loop',
  do_statement = 'do while loop',
  try_statement = 'try block',
  return_statement = 'return',
  import_declaration = 'import',
  export_statement = 'export',
}

local function tts()
  return require('tennant.tts')
end

M.word = function()
  tts().speak(vim.fn.expand('<cword>'))
end

M.line = function(first, last)
  first = first or vim.fn.line('.')
  tts().speak(table.concat(vim.api.nvim_buf_get_lines(0, first - 1, last or first, false), '\n'))
end

M.selection = function()
  local lines = vim.fn.getregion(vim.fn.getpos('v'), vim.fn.getpos('.'), { type = vim.fn.mode() })
  tts().speak(table.concat(lines, '\n'))
end

local block_state

local function enclosing_block(node)
  while node and node:parent() and not BLOCK_LABELS[node:type()] do
    node = node:parent()
  end
  return node
end

M.block = function(parent)
  local buffer = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local tick = vim.api.nvim_buf_get_changedtick(buffer)
  local node
  if parent and block_state and block_state.buffer == buffer
      and block_state.tick == tick and vim.deep_equal(block_state.cursor, cursor) then
    node = block_state.node
  else
    block_state = nil
    local ok, current = pcall(vim.treesitter.get_node)
    if ok then
      node = enclosing_block(current)
    end
  end

  if parent then
    node = node and enclosing_block(node:parent())
    if not node then
      tts().speak(translate('No more nesting levels'))
      return
    end
  elseif not node then
    tts().speak(vim.api.nvim_get_current_line())
    return
  end

  block_state = { node = node, buffer = buffer, cursor = cursor, tick = tick }
  local label = BLOCK_LABELS[node:type()] or 'file'
  tts().speak(translate(label) .. ': ' .. vim.treesitter.get_node_text(node, buffer))
end

return M
