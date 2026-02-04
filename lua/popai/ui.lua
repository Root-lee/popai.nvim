local M = {}
local config = require("popai.config")

M.buf = nil
M.win = nil
M.anchor_row = nil
M.anchor_col = nil

function M.close()
  if M.win and vim.api.nvim_win_is_valid(M.win) then
    vim.api.nvim_win_close(M.win, true)
  end
  M.win = nil
  M.buf = nil
  M.anchor_row = nil
  M.anchor_col = nil
end

local function update_window_size()
  if not M.win or not vim.api.nvim_win_is_valid(M.win) or not M.buf then return end

  local line_count = vim.api.nvim_buf_line_count(M.buf)
  local max_height = math.floor(vim.o.lines * config.options.ui.height_ratio)
  local new_height = math.min(math.max(1, line_count), max_height)
  
  local current_config = vim.api.nvim_win_get_config(M.win)
  local new_row = M.anchor_row - new_height - 1
  if new_row < 0 then new_row = M.anchor_row + 1 end
  
  vim.api.nvim_win_set_config(M.win, {
    relative = "editor",
    row = new_row,
    col = current_config.col,
    width = current_config.width,
    height = new_height,
  })
end

function M.create_window()
  M.close()

  M.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("filetype", "markdown", { buf = M.buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = M.buf })

  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local win_pos = vim.api.nvim_win_get_position(0)
  M.anchor_row = win_pos[1] + cursor_pos[1] - vim.fn.line("w0") + 1
  M.anchor_col = win_pos[2] + cursor_pos[2]

  local width = math.floor(vim.o.columns * config.options.ui.width_ratio)
  local height = 1

  local row = M.anchor_row - height - 1
  if row < 0 then row = M.anchor_row + 1 end
  
  local col = M.anchor_col
  
  -- Smart positioning: center if too wide, or ensure it fits on screen
  if width > vim.o.columns * 0.8 then
      col = math.floor((vim.o.columns - width) / 2)
  elseif col + width > vim.o.columns then
    col = vim.o.columns - width - 2
  end
  
  -- Ensure col is non-negative
  if col < 0 then col = 1 end

  local title = config.options.ui.title
  if title and title ~= "" then
      -- Add a little padding to the title if not already present
      if not title:match("^%s") then title = " " .. title end
      if not title:match("%s$") then title = title .. " " end
  end

  local opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = config.options.ui.border or "rounded",
    title = title,
    title_pos = "center",
    -- Add padding to the window content
    -- Note: 'noautocmd' is often used but not strictly necessary here
  }

  -- 1. Create the window
  M.win = vim.api.nvim_open_win(M.buf, true, opts)
  
  -- 2. Set window options for better UX
  vim.api.nvim_set_option_value("wrap", true, { win = M.win })
  vim.api.nvim_set_option_value("linebreak", true, { win = M.win })
  vim.api.nvim_set_option_value("cursorline", false, { win = M.win }) -- No cursorline needed for output
  vim.api.nvim_set_option_value("number", false, { win = M.win })
  vim.api.nvim_set_option_value("relativenumber", false, { win = M.win })
  vim.api.nvim_set_option_value("foldenable", false, { win = M.win })
  vim.api.nvim_set_option_value("signcolumn", "no", { win = M.win })

  -- 3. Set highlights for "modern" look
  -- Link to Telescope/Lazy generic highlights if available, or define defaults
  vim.api.nvim_set_option_value("winhl", "Normal:NormalFloat,FloatBorder:FloatBorder,FloatTitle:FloatTitle", { win = M.win })
  
  vim.keymap.set("n", "q", function() M.close() end, { buffer = M.buf, silent = true })
  vim.keymap.set("n", "<Esc>", function() M.close() end, { buffer = M.buf, silent = true })
end

function M.write(text)
  if not M.buf or not vim.api.nvim_buf_is_valid(M.buf) then
    return
  end

  local lines = vim.split(text, "\n")
  local current_lines = vim.api.nvim_buf_get_lines(M.buf, 0, -1, false)
  
  if #current_lines == 0 or (#current_lines == 1 and current_lines[1] == "") then
    vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, lines)
  else
    local last_line_idx = #current_lines
    local last_line = current_lines[last_line_idx]
    
    local first_chunk = lines[1]
    local rest_chunks = {}
    if #lines > 1 then
      for i = 2, #lines do
        table.insert(rest_chunks, lines[i])
      end
    end
    
    vim.api.nvim_buf_set_lines(M.buf, last_line_idx - 1, last_line_idx, false, { last_line .. first_chunk })
    
    if #rest_chunks > 0 then
      vim.api.nvim_buf_set_lines(M.buf, last_line_idx, last_line_idx, false, rest_chunks)
    end
  end

  if M.win and vim.api.nvim_win_is_valid(M.win) then
    local new_line_count = vim.api.nvim_buf_line_count(M.buf)
    vim.api.nvim_win_set_cursor(M.win, { new_line_count, 0 })
    update_window_size()
  end
end

function M.show_loading()
  M.clear()
  -- Use a spinner if possible, or just text
  local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
  M.write(" " .. spinner[1] .. " Thinking...")
  
  -- Simple animation loop could be added here with vim.loop.new_timer
  -- For now, static text with an icon is better than just "Loading..."
end

function M.clear()
  if M.buf and vim.api.nvim_buf_is_valid(M.buf) then
    vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, {""})
  end
end

return M
