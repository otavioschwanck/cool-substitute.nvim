local M = {}

local substitute = require('cool-substitute.substitute')

function M.setup_keybindings(mappings)
  local bufopts = function(description)
    return { silent = true, desc = description }
  end

  vim.keymap.set({'n', 'v'}, mappings.start, substitute.start, bufopts('Mark word/region for substitute'))
  vim.keymap.set({'n', 'v'}, mappings.start_and_edit, function() substitute.start({ edit_word = true }) end, bufopts('Mark and edit word/region for substitute'))
  vim.keymap.set({'n', 'v'}, mappings.start_and_edit_word, function() substitute.start({ complete_word = true, edit_word = true }) end, bufopts('Mark and edit(only full) word/region for substitute'))
  vim.keymap.set({'n', 'v'}, mappings.start_word, function() substitute.start({ complete_word = true }) end, bufopts('Mark full word/region for substitute'))
  vim.keymap.set('n', mappings.apply_substitute_and_next, substitute.apply_and_next, bufopts('Start substitution and go to next substitution.'))
  vim.keymap.set('n', mappings.apply_substitute_and_prev, substitute.apply_and_previous, bufopts('Start substitution and go to previous substitution'))
  vim.keymap.set('n', mappings.apply_substitute_all, substitute.substitute_all, bufopts('Substitute all'))
  vim.keymap.set('n', mappings.force_terminate_substitute, substitute.end_substitution, bufopts('Force Terminate Macro'))
end

return M
