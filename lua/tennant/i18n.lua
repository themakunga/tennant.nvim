local M = { language = 'es' }

local spanish = {
  ['TTS process failed'] = 'El proceso TTS falló',
  ['Unable to start TTS process'] = 'No se pudo iniciar el proceso TTS',
  ['Notifications: %d.'] = 'Notificaciones: %d.',
  ['Press n to continue or x to stop.'] = 'Presiona n para continuar o x para detener la lectura.',
  ['No more notifications. Press x to close.'] = 'No hay más notificaciones. Presiona x para cerrar.',
  ['Read notifications'] = 'Leer notificaciones',
  ['Requires Neovim >= 0.12 (found %s)'] = 'Requiere Neovim >= 0.12 (tienes %s)',
  ['No TTS backend found.'] = 'No se encontró backend TTS.',
  ['Install one of: spd-say, espeak-ng, espeak, festival'] = 'Instala uno de: spd-say, espeak-ng, espeak, festival',
  ['Requires PowerShell with System.Speech (included in .NET Framework)'] = 'Requiere PowerShell con System.Speech (incluido en .NET Framework)',
  ['vim.treesitter.get_node unavailable; block reading will use the current line'] = 'vim.treesitter.get_node no disponible; lectura de bloques usará la línea actual',
  ['No TTS backend available'] = 'Sin backend TTS disponible',
  ['No recent notifications'] = 'Sin notificaciones recientes',
  ['No more nesting levels'] = 'No existen más niveles de anidación',
  ['Read word'] = 'Leer palabra',
  ['Read current line or line range'] = 'Leer línea actual o rango de líneas',
  ['Read block'] = 'Leer bloque',
  ['Read parent block'] = 'Leer bloque contenedor',
  ['Read last notification'] = 'Leer última notificación',
  ['Stop speaking'] = 'Detener lectura',
  ['Read selection'] = 'Leer selección',
  ['function'] = 'función',
  ['method'] = 'método',
  ['arrow function'] = 'función flecha',
  ['variable'] = 'variable',
  ['constant'] = 'constante',
  ['class'] = 'clase',
  ['if block'] = 'bloque if',
  ['for loop'] = 'bucle for',
  ['for in loop'] = 'bucle for in',
  ['while loop'] = 'bucle while',
  ['do while loop'] = 'bucle do while',
  ['try block'] = 'bloque try',
  ['return'] = 'retorno',
  ['import'] = 'importación',
  ['export'] = 'exportación',
  ['file'] = 'archivo',
  ['information'] = 'información',
  ['warning'] = 'advertencia',
  ['trace'] = 'trace',
  ['debug'] = 'debug',
  ['error'] = 'error',
  ['off'] = 'off',
}

M.setup = function(language)
  language = language or 'es'
  assert(language == 'es' or language == 'en', '[tennant] language must be es or en')
  M.language = language
end

M.get = function(text)
  return M.language == 'es' and (spanish[text] or text) or text
end

return M
