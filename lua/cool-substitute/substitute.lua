local M = {}

local set = vim.api.nvim_set_option

local quick_key_to_substitute = '                                        SafeEditText123718cxzDUSAduasCGZXIUcgzIg'

local go_to = function(pos)
  vim.fn.cursor(pos[1], pos[2])
end

local get_pos = function()
  return vim.fn.searchpos(vim.g.cool_substitute_last_searched_word, 'n')
end

local save_search_pos = function()
  local current_position = get_pos()
  local positions = {}

  repeat
    table.insert(positions, get_pos())
    vim.fn.search(vim.g.cool_substitute_last_searched_word)
  until get_pos()[1] == current_position[1] and get_pos()[2] == current_position[2]

  local start = positions[#positions]
  table.remove(positions, #positions)
  table.insert(positions, 1, start)

  vim.g.cool_substitute_matches = positions
  vim.g.cool_substitute_current_match = 1
  vim.g.cool_substitute_already_applieds = {}
end

local current_match_already_applied = function()
  local applied = false

  for i = 1, #vim.g.cool_substitute_already_applieds, 1 do
    if vim.g.cool_substitute_current_match == vim.g.cool_substitute_already_applieds[i] then
      applied = true
    end
  end

  return applied
end

local goto_previous = function()
  if vim.g.cool_substitute_applying_substitution then
    if (vim.g.cool_substitute_current_match == 1) then
      vim.g.cool_substitute_current_match = #vim.g.cool_substitute_matches
    end

    repeat
      vim.g.cool_substitute_current_match = vim.g.cool_substitute_current_match - 1

      if (vim.g.cool_substitute_current_match <= 1) then
        vim.g.cool_substitute_current_match = #vim.g.cool_substitute_matches
      end
    until not current_match_already_applied()

    go_to(vim.g.cool_substitute_matches[vim.g.cool_substitute_current_match])
  end
end

local goto_next = function()
  if vim.g.cool_substitute_applying_substitution then
    if (vim.g.cool_substitute_current_match == #vim.g.cool_substitute_matches) then
      vim.g.cool_substitute_current_match = 0
    end

    repeat
      vim.g.cool_substitute_current_match = vim.g.cool_substitute_current_match + 1

      if (vim.g.cool_substitute_current_match > #vim.g.cool_substitute_matches) then
        vim.g.cool_substitute_current_match = 1
      end
    until not current_match_already_applied()

    go_to(vim.g.cool_substitute_matches[vim.g.cool_substitute_current_match])
  end
end

local save_to_applied = function()
  local applieds = vim.g.cool_substitute_already_applieds

  table.insert(applieds, vim.g.cool_substitute_current_match)

  vim.g.cool_substitute_already_applieds = applieds
end

local verify_if_ended = function()
  local applieds = vim.g.cool_substitute_already_applieds

  if #applieds == #vim.g.cool_substitute_matches then
    M.end_substitution()

    return true
  end

  return false
end

local cool_substitute_esc = function()
  if vim.g.cool_substitute_is_active then
    M.end_substitution()
  elseif vim.g.cool_substitute_is_substituing then
    if vim.fn.reg_recording() ~= '' then
      vim.cmd("norm q")
    end

    M.end_substitution()
  end
end

local escape_string = function(text)
  local s = text

  s = string.gsub(s, '\\', '\\\\')
  s = string.gsub(s, '%[', '\\[')
  s = string.gsub(s, '%]', '\\]')
  s = string.gsub(s, '%!', '\\!')
  s = string.gsub(s, '%$', '\\$')
  s = string.gsub(s, '%#', '\\#')
  s = string.gsub(s, '%*', '\\*')
  s = string.gsub(s, '%?', '[\\?]')
  s = string.gsub(s, '%^', '\\^')
  s = string.gsub(s, '%%', '[\\%%]')
  s = string.gsub(s, '%-', '[\\-]')
  s = string.gsub(s, '%+', '[\\+]')

  return s
end

local find_current_map = function(map)
  local mappings = vim.api.nvim_get_keymap("N")

  local result

  for i = 1, #mappings, 1 do
    local mapping_buffer = mappings[i].buffer

    if string.lower(mappings[i].lhs) == map and (mapping_buffer == 0) then
      result = mappings[i].rhs
    end
  end

  return result
end

local set_keymap = function()
  vim.g.cool_substitute_current_esc = find_current_map("<esc>")
  vim.g.cool_substitute_current_cr = find_current_map("<cr>")
  vim.g.cool_substitute_current_cj = find_current_map("<c-j>")
  vim.g.cool_substitute_current_ck = find_current_map("<c-k>")

  if vim.g.cool_substitute_current_esc then
    vim.keymap.del("n", "<esc>", {})
  end

  if vim.g.cool_substitute_current_cr then
    vim.keymap.del("n", "<cr>", {})
  end

  if vim.g.cool_substitute_current_cj then
    vim.keymap.del("n", "<cj>", {})
  end

  if vim.g.cool_substitute_current_ck then
    vim.keymap.del("n", "<ck>", {})
  end

  vim.keymap.set("n", "<esc>", cool_substitute_esc, {})
  vim.keymap.set("n", "<cr>", M.skip, {})
  vim.keymap.set("n", "<C-j>", goto_next, {})
  vim.keymap.set("n", "<C-k>", goto_previous, {})
end

local restore_keymap = function()
  if(vim.g.cool_substitute_current_esc) then
    vim.keymap.del("n", "<esc>", {})

    vim.keymap.set("n", "<esc>", vim.g.cool_substitute_current_esc, {})
  end

  if(vim.g.cool_substitute_current_cr) then
    vim.keymap.del("n", "<cr>", {})

    vim.keymap.set("n", "<cr>", vim.g.cool_substitute_current_cr, {})
  end

  if(vim.g.cool_substitute_current_cj) then
    vim.keymap.del("n", "<C-j>", {})

    vim.keymap.set("n", "<C-j>", vim.g.cool_substitute_current_cr, {})
  end

  if(vim.g.cool_substitute_current_ck) then
    vim.keymap.del("n", "<C-k>", {})

    vim.keymap.set("n", "<C-k>", vim.g.cool_substitute_current_cr, {})
  end
end


local start_recording = function(start_opts)
  local opts = start_opts or {}

  vim.g.cool_substitute_original_ignore_case = vim.api.nvim_get_option('ignorecase')

  set('ignorecase', false)
  set_keymap()

  local word

  if vim.fn.mode() == 'v' then
    vim.cmd("norm \"" .. vim.g.cool_substitute_mark_char .. "y")

    word = vim.fn.getreg(vim.g.cool_substitute_mark_char)
  elseif vim.fn.mode() == 'v' then
    print("Visual Line not supported.")
  else
    word = vim.fn.expand("<cword>")
  end

  vim.cmd("norm m" .. vim.g.cool_substitute_mark_char)

  vim.g.cool_substitute_is_substituing = true

  vim.g.cool_substitute_word_for_status = word

  word = escape_string(word)

  if opts.complete_word then
    word = "\\<" .. word .. "\\>"
  end

  vim.g.cool_substitute_last_searched_word = word

  vim.fn.search(word, 'n')
  vim.fn.setreg('/', word)
  vim.cmd("norm! nN")

  save_search_pos()

  vim.cmd("norm! q" .. vim.g.cool_substitute_reg_char)

  if opts.edit_word then
    vim.fn.feedkeys("cgn", "t")
  end
end

local verify_if_is_last_word = function()
  local word = vim.g.cool_substitute_last_searched_word
  local current_line = vim.fn.getline('.')

  return string.sub(current_line, -(#word), -1) == word
end

local stop_recording = function(stop_opts)
  local opts = stop_opts or {}

  vim.cmd("norm q")

  vim.g.cool_substitute_is_substituing = false
  vim.g.cool_substitute_is_active = true

  local next_keymap = vim.g.cool_substitute_next_keymap or "M"

  local reg_char = vim.g.cool_substitute_reg_char
  vim.fn.setreg(reg_char, string.sub(vim.fn.getreg(reg_char), 1, -(1 + #next_keymap)))

  vim.g.cool_substitute_already_applieds = { 1 }

  if opts.backwards then
    vim.g.cool_substitute_last_action = 'prev'
    vim.g.cool_substitute_current_match = #vim.g.cool_substitute_matches
    go_to(vim.g.cool_substitute_matches[#vim.g.cool_substitute_matches])
  else
    if #vim.g.cool_substitute_matches > 1 then
      vim.g.cool_substitute_last_action = 'next'
      vim.g.cool_substitute_current_match = 2
      go_to(vim.g.cool_substitute_matches[2])
    else
      M.end_substitution()
    end
  end
end

function M.end_substitution()
  restore_keymap()

  set('ignorecase', vim.g.cool_substitute_original_ignore_case)

  vim.g.cool_substitute_is_active = false
  vim.g.cool_substitute_is_substituing = false
  vim.g.cool_substitute_last_action = nil

  vim.cmd("norm `" .. vim.g.cool_substitute_mark_char)
  vim.cmd("noh")
end

local normalize_line = function()
  if verify_if_is_last_word() then
    vim.cmd("norm A" .. quick_key_to_substitute)
    vim.g.cool_substitute_normalized_line = true
    vim.cmd("norm N")
  end
end

local remove_spaces = function()
  if vim.g.cool_substitute_normalized_line then
    vim.g.cool_substitute_normalized_line = false
    vim.cmd("s/" .. quick_key_to_substitute .. "//ge")

  end
end

function M.skip()
  if vim.g.cool_substitute_applying_substitution then
    save_to_applied()

    if verify_if_ended() then
      return
    end

    if vim.g.cool_substitute_last_action == 'prev' then
      goto_previous()
    else
      goto_next()
    end
  end
end

function M.apply_and_next()
  local is_recording = vim.fn.reg_recording() ~= ''

  if is_recording then
    stop_recording()
  elseif not (vim.g.cool_substitute_is_active or vim.g.cool_substitute_is_substituing) then
    if vim.g.substitute_with_next_key then
      M.start({ edit_word = true })
    else
      M.start({})
    end
  else
    vim.g.cool_substitute_last_action = 'next'

    local word = vim.g.cool_substitute_last_searched_word

    normalize_line()

    vim.cmd("norm! @" .. vim.g.cool_substitute_reg_char)

    remove_spaces()

    vim.g.cool_substitute_last_searched_word = word
    vim.fn.setreg('/', word)

    save_to_applied()

    if verify_if_ended() then
      return
    end

    goto_next()
  end
end

function M.apply_and_previous()
  local is_recording = vim.fn.reg_recording() ~= ''

  if is_recording then
    stop_recording({ backwards = true })
  elseif not (vim.g.cool_substitute_is_active or vim.g.cool_substitute_is_substituing) then
    print("Not in cool substitute.")
  else
    vim.g.cool_substitute_last_action = 'prev'

    local word = vim.g.cool_substitute_last_searched_word

    normalize_line()

    vim.cmd("norm! @" .. vim.g.cool_substitute_reg_char)

    remove_spaces()

    vim.g.cool_substitute_last_searched_word = word
    vim.fn.setreg('/', word)

    save_to_applied()

    if verify_if_ended() then
      return
    end

    goto_previous()
  end
end

function M.substitute_all()
  if not (vim.g.cool_substitute_is_active or vim.g.cool_substitute_is_substituing) then
    print("Not in cool substitute.")
    return
  end

  if is_recording then
    stop_recording()
  end

  repeat
    M.apply_and_next()
  until verify_if_ended()
end

function M.start(start_opts)
  local is_recording = vim.fn.reg_recording() ~= ''

  if is_recording then
    print("Please exit macro before starting the substitute...")
  else
    start_recording(start_opts)
  end
end

return M
