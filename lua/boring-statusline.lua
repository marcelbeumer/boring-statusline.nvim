local M = {}

local diagnostics_status_cached = ""

local diagnostics_status = function()
  if diagnostics_status_cached ~= "" then
    return diagnostics_status_cached
  end

  local diagnostics = vim.diagnostic.get(0, {})
  local severity = vim.diagnostic.severity
  local diag_icon = {
    [severity.ERROR] = "",
    [severity.WARN] = "",
    [severity.HINT] = "󰌶",
    [severity.INFO] = "",
  }
  local totals = {
    [severity.ERROR] = 0,
    [severity.WARN] = 0,
    [severity.HINT] = 0,
    [severity.INFO] = 0,
  }
  for _, d in ipairs(diagnostics) do
    totals[d.severity] = totals[d.severity] + 1
  end

  local status = ""
  for level, total in pairs(totals) do
    if total > 0 then
      status = status .. string.format("%s %d ", diag_icon[level], total)
    end
  end

  diagnostics_status_cached = status
  return status
end

local function debounce(callback, delay)
  local timer = nil
  return function()
    if timer then
      return
    end
    timer = vim.defer_fn(function()
      timer = nil
      callback()
    end, delay)
  end
end

M.statusline = function()
  local file_path = "%f"
  local line_col = "%8(%l,%c%)"
  local position = "%5P"

  return string.format("%s %%=%s %s %s", file_path, diagnostics_status(), line_col, position)
end

M.setup = function()
  vim.api.nvim_create_autocmd("DiagnosticChanged", {
    callback = debounce(function()
      diagnostics_status_cached = ""
      vim.cmd.redrawstatus()
    end, 200),
    group = vim.api.nvim_create_augroup("UpdateStatusline", { clear = true }),
  })
  vim.o.statusline = "%!v:lua.require('boring-statusline').statusline()"
end

return M
