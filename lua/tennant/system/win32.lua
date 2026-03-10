local M = {}

---@param text string
---@param config tennant.SpeakConfig
M.default = function(text, config)
  if not text or text == "" then
    return
  end

  -- a powershell command builder
  local cmd = string.format([[
    Add-Type -AssemblyName System.Speech;
        $synth = New-Object System.Speech.Synthesis.SpeechSynthesizer;
        %s
        $synth.Speak('%s');
  ]], config.voice and "$system.SelecVoice('" .. config.voice .. "');" or "",
    text:gsub("'", "''"))

  vim.fn.jobstart({ "powershell", "-Command", cmd }, { deatach = true })
end

return M
