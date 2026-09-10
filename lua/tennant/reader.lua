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

M.line = function()
  tts().speak(vim.api.nvim_get_current_line())
end

M.block = function()
  local ok, node = pcall(vim.treesitter.get_node)
  if not ok or not node then
    tts().speak(vim.api.nvim_get_current_line())
    return
  end

  local current = node
  while current do
    local label = BLOCK_LABELS[current:type()]
    if label then
      local sr, _, er, _ = current:range()
      -- read first line with the label prefix
      local first = vim.api.nvim_buf_get_lines(0, sr, sr + 1, false)[1] or ''
      tts().speak(label .. ': ' .. vim.trim(first))
      return
    end
    current = current:parent()
  end

  -- fallback: just read the line
  tts().speak(vim.api.nvim_get_current_line())
end

return M
