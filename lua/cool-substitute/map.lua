local M = {}

local substitute = require('cool-substitute.substitute')

function M.setup_keybindings(mappings)
  local bufopts = function(description)
    return { silent = true, desc = description }
  end

  if mappings.start ~= '' then
    vim.keymap.set({'n', 'v'}, mappings.start, substitute.start, bufopts('Mark word/region for substitute'))
  end
  if mappings.redo_last_record ~= '' then
    vim.keymap.set({'n', 'v'}, mappings.redo_last_record, substitute.redo_last_record, bufopts('Redo last record of cool substitute'))
  end
  if mappings.start_and_edit ~= '' then
    vim.keymap.set({'n', 'v'}, mappings.start_and_edit, function() substitute.start({ edit_word = true }) end, bufopts('Mark and edit word/region for substitute'))
  end
  if mappings.start_and_edit_word ~= '' then
    vim.keymap.set({'n', 'v'}, mappings.start_and_edit_word, function() substitute.start({ complete_word = true, edit_word = true }) end, bufopts('Mark and edit(only full) word/region for substitute'))
  end
  if mappings.start_word ~= '' then
    vim.keymap.set({'n', 'v'}, mappings.start_word, function() substitute.start({ complete_word = true }) end, bufopts('Mark full word/region for substitute'))
  end
  if mappings.apply_substitute_and_next ~= '' then
    vim.keymap.set({'n', 'v'}, mappings.apply_substitute_and_next, substitute.apply_and_next, bufopts('Start substitution and go to next substitution.'))
  end
  if mappings.apply_substitute_and_prev ~= '' then
    vim.keymap.set('n', mappings.apply_substitute_and_prev, substitute.apply_and_previous, bufopts('Start substitution and go to previous substitution'))
  end
  if mappings.apply_substitute_all ~= '' then
    vim.keymap.set('n', mappings.apply_substitute_all, substitute.substitute_all, bufopts('Substitute all'))
  end
  if mappings.force_terminate_substitute ~= '' then
    vim.keymap.set('n', mappings.force_terminate_substitute, substitute.end_substitution, bufopts('Force Terminate Macro'))
  end

  vim.g.cool_substitute_terminate_substitute = mappings.terminate_substitute
  vim.g.cool_substitute_skip_substitute = mappings.skip_substitute
  vim.g.cool_substitute_goto_next = mappings.goto_next
  vim.g.cool_substitute_goto_previous = mappings.goto_previous
end

return M
