local M = {}

---@param min string minimun admited version
---@return boolean
M.nvim_min_version = function(min)
  local current = vim.version()

  local parts = vim.split(min, '.', { plain = true })

  local min_major = tonumber(parts[1])
  local min_minor = tonumber(parts[2] or 0)
  local min_patch = tonumber(parts[3] or 0)

  if not min_major then
    return false
  end

  if current.major > min_major then
    return true
  elseif current.major < min_major then
    return false
  else
    if current.minor > min_minor then
      return true
    elseif current.minor < min_minor then
      return false
    else
      if current.patch >= min_patch then
        return true
      else
        return false
      end
    end
  end
end

return M
