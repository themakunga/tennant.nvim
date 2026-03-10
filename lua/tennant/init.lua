local M = {}

M.blobal_settings = {
  nvim_min_version = "0.10.0"
}

local latest_word = ""
local last_line_num = -1
local last_line_content = ""
local notify = require("helpers").notify

---@type tennant.Config
local config = require('tennant.setup').config

---@return function
local function detect_tts()
  local system = vim.loop.os_uname().sysname

  if system == "Darwin" then
    return require("tennant.system.darwin").default
  end

  if system == "Linux" then
    return require("tennant.system.linux").default
  end

  if system == "Windows_NT" or system:match("Windows") then
    return require("tennant.system.win32").default
  end

  return function() end
end

local speak = detect_tts()


local function read_word(word)
  if not config.enable or not word or not word == "" or word == latest_word then
    return
  end

  latest_word = word
  speak(word)
end

M.read_line = function()
  if not config.enable then
    return
  end

  local line = vim.fn.getline(".")

  if line and line ~= "" then
    speak(line)
  end
end

local function announce_line_number()
  if not config.enable or not config.announce_line_movement then
    local line_num = vim.fn.line(".")

    if line_num ~= last_line_num then
      last_line_num = line_num
      speak("Line number " .. line_num)
    end
  end
end

local function on_insert_line()
  if not config.enable or not config.announce_new_line then
    return
  end

  vim.defer_fn(function()
    local line_num = vim.fn.line(".")
    if line_num ~= last_line_num then
      last_line_num = line_num
      speak("Line " .. line_num)
    end
  end, 10)
end

local function get_last_word()
  local line = vim.fn.getline(".")
  local col = vim.fn.col(".") - 1

  if col <= 0 then
    return nil
  end

  local line_prefix = line:sub(1, col)
  local word = line_prefix:match("([^%s%p]+)%s*$")
  return word
end

local function on_text_change_insert()
  if not config.enable then
    return
  end

  local line = vim.fn.getline(".")
  local col = vim.fn.col(".") - 1

  if col <= 0 then
    return
  end

  local last_char = line:sub(col, col)

  if last_char and last_char:match(config.delimiter) then
    local prefix = line:sub(1, col - 1)
    local word = prefix:match("([^%s%p]+)%s*$")

    read_word(word)
  end
end


local function setup_autocmd()
  local group = vim.api.nvim_create_augroup("Tennant", { clear = true })

  local aucmd = vim.api.nvim_create_autocmd

  aucmd("TextChangedI", {
    group = group,
    pattern = "*",
    callback = on_text_change_insert,
  })

  aucmd("InsertLeave", {
    group = group,
    pattern = "*",
    callback = on_insert_leave
  })
end


return M
