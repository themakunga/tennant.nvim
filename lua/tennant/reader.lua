local M = {}

-- Block types to announce via treesitter
local BLOCK_LABELS = {
  function_definition = 'función',
  function_declaration = 'función',
  method_definition = 'método',
  method_declaration = 'método',
  arrow_function = 'función flecha',
  variable_declaration = 'variable',
  lexical_declaration = 'variable',
  const_declaration = 'constante',
  class_definition = 'clase',
  class_declaration = 'clase',
  if_statement = 'bloque if',
  for_statement = 'bucle for',
  for_in_statement = 'bucle for in',
  while_statement = 'bucle while',
  do_statement = 'bucle do while',
  try_statement = 'bloque try',
  return_statement = 'retorno',
  import_declaration = 'importación',
  export_statement = 'exportación',
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
      tts().speak('No existen más niveles de anidación')
      return
    end
  elseif not node then
    tts().speak(vim.api.nvim_get_current_line())
    return
  end

  block_state = { node = node, buffer = buffer, cursor = cursor, tick = tick }
  local label = BLOCK_LABELS[node:type()] or 'archivo'
  tts().speak(label .. ': ' .. vim.treesitter.get_node_text(node, buffer))
end

return M
