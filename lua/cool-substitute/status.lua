local M = {}

function M.status_with_icons()
  if vim.g.cool_substitute_is_applying then
    return " Applying " .. vim.g.cool_substitute_current_match .. "/" .. #(vim.g.cool_substitute_matches or {})
  elseif vim.g.cool_substitute_is_active then
    return " Writing " .. vim.g.cool_substitute_current_match .. "/" .. #(vim.g.cool_substitute_matches or {})
  else
    return ""
  end
end

function M.status_no_icons()
  if vim.g.cool_substitute_is_applying then
    return "Applying substitution " .. vim.g.cool_substitute_current_match .. "/" .. #(vim.g.cool_substitute_matches or {})
  elseif vim.g.cool_substitute_is_active then
    return "Writing Substitution " .. vim.g.cool_substitute_current_match .. "/" .. #(vim.g.cool_substitute_matches or {})
  else
    return ""
  end
end

function M.status_color()
  if vim.g.cool_substitute_is_applying then
    return vim.g.cool_substitute_applying_substitution
  elseif vim.g.cool_substitute_is_active then
    return vim.g.cool_substitute_writing_substitution
  end
end

return M
