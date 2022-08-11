local M = {}

function M.status_with_icons()
  if vim.g.cool_substitute_is_active then
    return " Applying "
  elseif vim.g.cool_substitute_is_substituing then
    return " Writing "
  else
    return ""
  end
end

function M.status_no_icons()
  if vim.g.cool_substitute_is_active then
    return "Applying substitution"
  elseif vim.g.cool_substitute_is_substituing then
    return "Writing Substitution"
  else
    return ""
  end
end

function M.status_color()
  if vim.g.cool_substitute_is_active then
    return vim.g.cool_substitute_writing_substitution
  elseif vim.g.cool_substitute_is_substituing then
    return vim.g.cool_substitute_applying_substitution
  end
end

return M
