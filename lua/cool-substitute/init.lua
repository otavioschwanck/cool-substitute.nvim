local M = {}

local default_mappings = {
  start = 'gm',
  start_and_edit = 'gM',
  start_and_edit_word = 'g!M',
  start_word = 'g!m',
  apply_substitute_and_next = 'M',
  apply_substitute_and_prev = '<C-b>',
  apply_substitute_all = 'ga',
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
end

return M
