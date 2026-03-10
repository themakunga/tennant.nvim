---@class tennant.Config
---@field enable boolean
---@field voice string|nil
---@field rate number|nil
---@field delimiter string
---@field announce_line_movement boolean
---@field announce_new_line boolean
---@field command_prefix string|nil

---@class tennant.SpeakConfig
---@field voice string|nil
---@field rate number|nil

local S = {}

---@type tennant.Config
S.config = {
  enable = true,
  voice = nil,
  rate = nil,
  delimiter = "[%s%p]",
  announce_line_movement = true,
  announce_new_line = true,
  command_prefix = "Tennant"
}

return S
