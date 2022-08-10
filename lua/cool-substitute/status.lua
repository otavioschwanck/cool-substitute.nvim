local M = {}

function M.status_with_icons()
  if vim.g.cool_substitute_is_active then
    return " Writng Substitution"
  elseif vim.g.cool_substitute_is_substituing then
    return " Applying substitution for " .. vim.g.cool_substitute_last_searched_word
  else
    return ""
  end
end

function M.status_no_icons()
  if vim.g.cool_substitute_is_active then
    return "Writng Substitution"
  elseif vim.g.cool_substitute_is_substituing then
    return "Applying substitution for " .. vim.g.cool_substitute_last_searched_word
  else
    return ""
  end
end

function M.status_color()
  if vim.g.cool_substitute_is_active then
    return "#98be65"
  elseif vim.g.cool_substitute_is_substituing then
    return "#ECBE7B"
  else
    return "#fff"
  end
end

return M
