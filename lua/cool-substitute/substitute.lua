local M = {}

local set = vim.api.nvim_set_option

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

local find_current_esc = function()
  local mappings = vim.api.nvim_get_keymap("N")

  local result

  for i = 1, #mappings, 1 do
    local mapping_buffer = mappings[i].buffer

    if string.lower(mappings[i].lhs) == "<esc>" and (mapping_buffer == 0) then
      result = mappings[i].rhs
    end
  end

  return result
end

local set_keymap = function()
  vim.g.cool_substitute_current_esc = find_current_esc()

  if vim.g.cool_substitute_current_esc then
    vim.keymap.del("n", "<esc>", {})
    vim.keymap.set("n", "<esc>", cool_substitute_esc, {})
  end
end

local restore_keymap = function()
  if(vim.g.cool_substitute_current_esc) then
    vim.keymap.del("n", "<esc>", {})

    vim.keymap.set("n", "<esc>", vim.g.cool_substitute_current_esc, {})
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

  if opts.complete_word then
    word = "\\<" .. word .. "\\>"
  end

  vim.g.cool_substitute_last_searched_word = word

  vim.fn.search(word, 'n')
  vim.fn.setreg('/', word)
  vim.cmd("norm! lN")

  vim.cmd("norm! q" .. vim.g.cool_substitute_reg_char)

  if opts.edit_word then
    vim.fn.feedkeys("cgn", "t")
  end
end

local stop_recording = function(stop_opts)
  local opts = stop_opts or {}

  vim.cmd("norm q")

  vim.g.cool_substitute_is_substituing = false
  vim.g.cool_substitute_is_active = true

  local next_keymap = vim.g.cool_substitute_next_keymap or "M"

  local reg_char = vim.g.cool_substitute_reg_char
  vim.fn.setreg(reg_char, string.sub(vim.fn.getreg(reg_char), 1, -(1 + #next_keymap)))

  local word = vim.g.cool_substitute_last_searched_word

  if opts.backwards then
    vim.fn.search(word, 'b')
  else
    vim.fn.search(word)
  end
end

function M.end_substitution()
  restore_keymap()

  set('ignorecase', vim.g.cool_substitute_original_ignore_case)

  vim.g.cool_substitute_is_active = false
  vim.g.cool_substitute_is_substituing = false

  vim.cmd("norm `" .. vim.g.cool_substitute_mark_char)
  vim.cmd("noh")
end

function M.apply_and_next()
  local is_recording = vim.fn.reg_recording() ~= ''

  if is_recording then
    stop_recording()
  elseif not (vim.g.cool_substitute_is_active or vim.g.cool_substitute_is_substituing) then
    print("Not in cool substitute.")
  else
    local word = vim.g.cool_substitute_last_searched_word

    vim.cmd("norm! @" .. vim.g.cool_substitute_reg_char)

    local result = vim.fn.search(word)

    if result == 0 then
      M.end_substitution()
    end
  end
end

function M.apply_and_previous()
  local is_recording = vim.fn.reg_recording() ~= ''

  if is_recording then
    stop_recording({ backwards = true })
  elseif not (vim.g.cool_substitute_is_active or vim.g.cool_substitute_is_substituing) then
    print("Not in cool substitute.")
  else
    local word = vim.g.cool_substitute_last_searched_word

    vim.cmd("norm! @" .. vim.g.cool_substitute_reg_char)

    local result = vim.fn.search(word, "b")

    if result == 0 then
      M.end_substitution()
    end
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

  local word = vim.g.cool_substitute_last_searched_word

  while vim.fn.search(word, 'nc') ~= 0 do
    M.apply_and_next()
  end

  M.end_substitution()
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
