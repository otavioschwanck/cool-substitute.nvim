local M = {}

local substitute = require('cool-substitute.substitute')

function M.setup_keybindings(mappings)
  local bufopts = { silent = true }

  vim.keymap.set('n', mappings.start, substitute.start, bufopts)
  vim.keymap.set('n', mappings.start_and_edit, function() substitute.start({ edit_word = true }) end, bufopts)
  vim.keymap.set('n', mappings.start_and_edit_word, function() substitute.start({ complete_word = true, edit_word = true }) end, bufopts)
  vim.keymap.set('n', mappings.start_word, function() substitute.start({ complete_word = true }) end, bufopts)
  vim.keymap.set('n', mappings.apply_substitute_and_next, substitute.apply_and_next, bufopts)
  vim.keymap.set('n', mappings.apply_substitute_and_prev, substitute.apply_and_previous, bufopts)
  vim.keymap.set('n', mappings.apply_substitute_all, substitute.substitute_all, bufopts)
end

return M
