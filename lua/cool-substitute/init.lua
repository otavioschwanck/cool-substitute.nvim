local M = {}

local default_mappings = {
  start = 'gm',
  start_and_edit = 'gM',
  start_and_edit_word = 'g!M',
  start_word = 'g!m',
  apply_substitute_and_next = 'M',
  apply_substitute_and_prev = '<C-b>',
  apply_substitute_all = 'ga',
  force_terminate_substitute = 'g!!',
  redo_last_record = 'g!r',
  terminate_substitute = '<esc>',
  skip_substitute = '<cr>',
  goto_next = '<C-j>',
  goto_previous = '<C-k>',
}

function M.setup(setup_opts)
  local opts = setup_opts or {}

  if opts.setup_keybindings then
    local mappings = default_mappings

    for k,v in pairs(opts.mappings or {}) do mappings[k] = v end

    require('cool-substitute.map').setup_keybindings(mappings)
  end

  vim.g.cool_substitute_reg_char = opts.reg_char or 'o'
  vim.g.cool_substitute_mark_char = opts.mark_char or 't'
  vim.g.cool_substitute_writing_substitution = opts.writing_substitution_color or "#ECBE7B"
  vim.g.cool_substitute_applying_substitution = opts.applying_substitution_color or "#98be65"
  vim.g.substitute_with_next_key = opts.edit_word_when_starting_with_substitute_key or true
end

return M
