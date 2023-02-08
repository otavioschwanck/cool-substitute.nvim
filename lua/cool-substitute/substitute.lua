local M = {}

local set = vim.api.nvim_set_option

local quick_key_to_substitute = 'SafeEditText123718cxzDUSAduasCGZXIUcgzIg'

local fix_cursor_position = function()
  local line_length = tonumber(#vim.fn.getline('.'))
  local line_expected_length = tonumber(vim.g.cool_substitute_matches_line_length[tostring(vim.g.cool_substitute_current_match)])

  if vim.g.cool_substitute_last_action == 'next' then
    if line_length > line_expected_length then
      vim.cmd("norm! " .. line_length - line_expected_length .. "l")
    elseif line_length < line_expected_length then
      vim.cmd("norm! " .. line_expected_length - line_length .. "h")
    end
  end
end

function M.cool_x()
  if (vim.fn.col('.') == #vim.fn.getline('.')) then
    vim.fn.setline('.', vim.fn.getline('.') .. " ")
  end
  vim.keymap.del("n", "x", {})
  vim.cmd("norm x")
  vim.keymap.set("n", "x", M.cool_x, {})
end

local go_to = function(pos)
  vim.fn.cursor(pos[1], pos[2])

  fix_cursor_position()
end

local get_pos = function()
  return vim.fn.searchpos(vim.g.cool_substitute_last_searched_word, 'n')
end

local save_search_pos = function()
  local current_position = get_pos()
  local positions = {}
  local line_lengths = {}

  local index = 1

  repeat
    table.insert(positions, get_pos())

    line_lengths[tostring(index)] = tostring(#vim.fn.getline('.'))

    vim.fn.search(vim.g.cool_substitute_last_searched_word)

    index = index + 1
  until get_pos()[1] == current_position[1] and get_pos()[2] == current_position[2]

  local start = positions[#positions]
  table.remove(positions, #positions)
  table.insert(positions, 1, start)

  vim.g.cool_substitute_matches = positions
  vim.g.cool_substitute_current_match = 1
  vim.g.cool_substitute_already_applieds = {}
  vim.g.cool_substitute_matches_line_length = line_lengths
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
  if vim.g.cool_substitute_is_applying then
    M.end_substitution()
  elseif vim.g.cool_substitute_is_active then
    if vim.fn.reg_recording() ~= '' then
      vim.cmd("norm! q")
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
  s = string.gsub(s, '%.', '[\\.]')

  return s
end

local find_current_map = function(map)
  local mappings = vim.api.nvim_get_keymap("n")

  local result

  for i = 1, #mappings, 1 do
    local mapping_buffer = mappings[i].buffer

    if string.lower(mappings[i].lhs) == string.lower(map) and (mapping_buffer == 0) then
      result = mappings[i]
    end
  end

  return result
end

local set_keymap = function()
  vim.g.cool_substitute_current_esc = find_current_map(vim.g.cool_substitute_terminate_substitute)
  vim.g.cool_substitute_current_cr = find_current_map(vim.g.cool_substitute_skip_substitute)
  vim.g.cool_substitute_current_cj = find_current_map(vim.g.cool_substitute_goto_next)
  vim.g.cool_substitute_current_ck = find_current_map(vim.g.cool_substitute_goto_previous)
  vim.g.cool_substitute_current_x = find_current_map("x")

  vim.keymap.set("n", vim.g.cool_substitute_terminate_substitute, cool_substitute_esc, {})
  vim.keymap.set("n", vim.g.cool_substitute_skip_substitute, M.skip, {})
  vim.keymap.set("n", vim.g.cool_substitute_goto_next, goto_next, {})
  vim.keymap.set("n", vim.g.cool_substitute_goto_previous, goto_previous, {})
  vim.keymap.set("n", "x", M.cool_x, {})
end

local restore_keymap = function()
  vim.keymap.del("n", vim.g.cool_substitute_terminate_substitute, {})
  vim.keymap.del("n", vim.g.cool_substitute_skip_substitute, {})
  vim.keymap.del("n", vim.g.cool_substitute_goto_next, {})
  vim.keymap.del("n", vim.g.cool_substitute_goto_previous, {})
  vim.keymap.del("n", "x", {})

  if((vim.g.cool_substitute_current_esc or {}).rhs) then
    vim.keymap.set("n", vim.g.cool_substitute_terminate_substitute, vim.g.cool_substitute_current_esc.rhs, { silent = vim.g.cool_substitute_current_esc.silent })
  end

  if((vim.g.cool_substitute_current_cr or {}).rhs) then
    vim.keymap.set("n", vim.g.cool_substitute_skip_substitute, vim.g.cool_substitute_current_cr.rhs, { silent = vim.g.cool_substitute_current_cr.silent })
  end

  if((vim.g.cool_substitute_current_cj or {}).rhs) then
    vim.keymap.set("n", vim.g.cool_substitute_goto_next, vim.g.cool_substitute_current_cj.rhs, { silent = vim.g.cool_substitute_current_cj.silent })
  end

  if((vim.g.cool_substitute_current_ck or {}).rhs) then
    vim.keymap.set("n", vim.g.cool_substitute_goto_previous, vim.g.cool_substitute_current_ck.rhs, { silent = vim.g.cool_substitute_current_ck.silent })
  end

  if((vim.g.cool_substitute_current_x or {}).rhs) then
    vim.keymap.set("n", "x", vim.g.cool_substitute_current_x.rhs, { silent = vim.g.cool_substitute_current_x.silent })
  end
end


local use_last_record = function(start_opts)
  local opts = start_opts or {}

  vim.fn.clearmatches()
  vim.g.cool_substitute_original_ignore_case = vim.api.nvim_get_option('ignorecase')

  set('ignorecase', false)
  set_keymap()

  local word

  if vim.fn.mode() == 'v' then
    vim.cmd("norm! \"" .. vim.g.cool_substitute_mark_char .. "y")

    word = vim.fn.getreg(vim.g.cool_substitute_mark_char)

    if word == vim.fn.expand("<cword>") then
      vim.g.cool_substitute_is_single_word = true
    end
  elseif vim.fn.mode() == 'v' then
    print("Visual Line not supported.")
  else
    word = vim.fn.expand("<cword>")
    vim.g.cool_substitute_is_single_word = true
  end

  vim.cmd("norm! m" .. vim.g.cool_substitute_mark_char)

  word = escape_string(word)

  if opts.complete_word then
    word = "\\<" .. word .. "\\>"
  end

  vim.g.cool_substitute_last_searched_word = word

  vim.fn.search(word, 'n')
  vim.fn.setreg('/', word)
  vim.cmd("norm! nN")

  save_search_pos()

  vim.g.cool_substitute_hl_id = os.time() + 223166
  vim.fn.matchadd("DiffText", word, 10, vim.g.cool_substitute_hl_id)

  vim.g.cool_substitute_is_applying = true
end


local start_recording = function(start_opts)
  local opts = start_opts or {}

  vim.fn.clearmatches()
  vim.g.cool_substitute_original_ignore_case = vim.api.nvim_get_option('ignorecase')

  set('ignorecase', false)
  set_keymap()

  local word

  if vim.fn.mode() == 'v' then
    vim.cmd("norm! \"" .. vim.g.cool_substitute_mark_char .. "y")

    word = vim.fn.getreg(vim.g.cool_substitute_mark_char)

    if word == vim.fn.expand("<cword>") then
      vim.g.cool_substitute_is_single_word = true
    end
  elseif vim.fn.mode() == 'v' then
    print("Visual Line not supported.")
  else
    word = vim.fn.expand("<cword>")
    vim.g.cool_substitute_is_single_word = true
  end

  vim.cmd("norm! m" .. vim.g.cool_substitute_mark_char)

  vim.g.cool_substitute_is_active = true

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

  vim.g.cool_substitute_hl_id = os.time() + 223166
  vim.fn.matchadd("DiffText", word, 10, vim.g.cool_substitute_hl_id)

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

  vim.cmd("norm! q")

  vim.g.cool_substitute_is_active = false
  vim.g.cool_substitute_is_applying = true

  local next_keymap = vim.g.cool_substitute_next_keymap or "M"

  local reg_char = vim.g.cool_substitute_reg_char
  vim.fn.setreg(reg_char, string.sub(vim.fn.getreg(reg_char), 1, -(1 + #next_keymap)))

  vim.g.cool_substitute_already_applieds = { 1 }

  if opts.backwards then
    if #vim.g.cool_substitute_matches > 1 then
      vim.g.cool_substitute_last_action = 'prev'
      vim.g.cool_substitute_current_match = #vim.g.cool_substitute_matches
      go_to(vim.g.cool_substitute_matches[#vim.g.cool_substitute_matches])
    else
      M.end_substitution()
    end
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
  vim.fn.clearmatches()

  restore_keymap()

  set('ignorecase', vim.g.cool_substitute_original_ignore_case)

  if vim.fn.reg_recording() ~= '' then
    vim.cmd("norm! q")
  end

  vim.g.cool_substitute_is_applying = false
  vim.g.cool_substitute_is_active = false
  vim.g.cool_substitute_last_action = nil

  vim.cmd("norm! `" .. vim.g.cool_substitute_mark_char)
  vim.cmd("noh")
end

local normalize_line = function()
  if verify_if_is_last_word() then
    local current_pos = { vim.fn.line('.'), vim.fn.col('.') }

    vim.cmd("norm! A                    " .. quick_key_to_substitute)
    vim.g.cool_substitute_normalized_line = true
    vim.cmd("norm! N")

    vim.fn.cursor(current_pos[1], current_pos[2])
  end
end

local remove_spaces = function()
  if vim.g.cool_substitute_normalized_line then
    vim.g.cool_substitute_normalized_line = false
    vim.cmd("s/\\ *" .. quick_key_to_substitute .. "//ge")

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
  elseif not (vim.g.cool_substitute_is_applying or vim.g.cool_substitute_is_active) then
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
      return true
    end

    goto_next()
  end
end

function M.apply_and_previous()
  local is_recording = vim.fn.reg_recording() ~= ''

  if is_recording then
    stop_recording({ backwards = true })
  elseif not (vim.g.cool_substitute_is_applying or vim.g.cool_substitute_is_active) then
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
  if not (vim.g.cool_substitute_is_applying or vim.g.cool_substitute_is_active) then
    print("Not in cool substitute.")
    return
  end

  if is_recording then
    stop_recording()
  end

  local result

  repeat
    result = M.apply_and_next()

    if result then
      return
    end
  until false
end

function M.start(start_opts)
  local is_recording = vim.fn.reg_recording() ~= ''

  if is_recording then
    print("Please exit macro before starting the substitute...")
  else
    start_recording(start_opts)
  end
end

function M.redo_last_record(start_opts)
  local is_recording = vim.fn.reg_recording() ~= ''

  if is_recording then
    print("Please exit macro before starting the substitute...")
  else
    use_last_record(start_opts)
  end
end

return M
