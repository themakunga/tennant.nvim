-- # ruleid: lua-shell-execution
os.execute(text)
-- # ruleid: lua-shell-execution
io.popen(text)
-- # ruleid: lua-dynamic-code
loadstring(text)
-- # ruleid: lua-shell-argv
local unsafe = { 'sh', '-c', text }
-- # ok: lua-shell-execution
vim.system({ 'festival', '--tts' }, { stdin = text })
-- # ok: lua-dynamic-code
local value = tostring(text)
