local M = {}
local config = require("popai.config")

M.buf = nil
M.win = nil
M.anchor_row = nil
M.anchor_col = nil

M.spinner_timer = nil
M.state = "idle" -- "idle", "waiting", "thinking", "generating"

function M.close()
	M.stop_spinner()
	if M.win and vim.api.nvim_win_is_valid(M.win) then
		vim.api.nvim_win_close(M.win, true)
	end
	M.win = nil
	M.buf = nil
	M.anchor_row = nil
	M.anchor_col = nil
	M.state = "idle"
end

local function update_window_size()
	if not M.win or not vim.api.nvim_win_is_valid(M.win) or not M.buf then
		return
	end

	local current_config = vim.api.nvim_win_get_config(M.win)
	local width = current_config.width
	local max_height = math.floor(vim.o.lines * config.options.ui.height_ratio)

	local lines = vim.api.nvim_buf_get_lines(M.buf, 0, -1, false)
	local wrapped_height = 0
	for _, line in ipairs(lines) do
		local line_width = vim.fn.strdisplaywidth(line)
		if line_width == 0 then
			wrapped_height = wrapped_height + 1
		else
			wrapped_height = wrapped_height + math.ceil(line_width / width)
		end
	end

	local new_height = math.min(math.max(1, wrapped_height), max_height)

	local new_row = M.anchor_row - new_height - 1
	if new_row < 0 then
		new_row = M.anchor_row + 1
	end

	vim.api.nvim_win_set_config(M.win, {
		relative = "editor",
		row = new_row,
		col = current_config.col,
		width = width,
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
	if row < 0 then
		row = M.anchor_row + 1
	end

	local col = M.anchor_col

	-- Smart positioning: center if too wide, or ensure it fits on screen
	if width > vim.o.columns * 0.8 then
		col = math.floor((vim.o.columns - width) / 2)
	elseif col + width > vim.o.columns then
		col = vim.o.columns - width - 2
	end

	-- Ensure col is non-negative
	if col < 0 then
		col = 1
	end

	local title = config.options.ui.title
	if title and title ~= "" then
		-- Add a little padding to the title if not already present
		if not title:match("^%s") then
			title = " " .. title
		end
		if not title:match("%s$") then
			title = title .. " "
		end
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
	vim.api.nvim_set_option_value(
		"winhl",
		"Normal:NormalFloat,FloatBorder:FloatBorder,FloatTitle:FloatTitle",
		{ win = M.win }
	)

	vim.keymap.set("n", "q", function()
		M.close()
	end, { buffer = M.buf, silent = true })
	vim.keymap.set("n", "<Esc>", function()
		M.close()
	end, { buffer = M.buf, silent = true })
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

function M.update_title(text)
	if M.win and vim.api.nvim_win_is_valid(M.win) then
		local base_title = config.options.ui.title or " PopAI "
		local new_title = base_title
		if text and text ~= "" then
			new_title = base_title .. text
		end
		-- Keep title centered
		vim.api.nvim_win_set_config(M.win, { title = new_title, title_pos = "center" })
	end
end

function M.stop_spinner()
	if M.spinner_timer then
		M.spinner_timer:stop()
		if not M.spinner_timer:is_closing() then
			M.spinner_timer:close()
		end
		M.spinner_timer = nil
	end
end

function M.start_spinner(label)
	M.stop_spinner()
	-- Neovim 0.10+ uses vim.uv, but fall back to vim.loop if needed
	local uv = vim.uv or vim.loop
	M.spinner_timer = uv.new_timer()
	local frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
	local i = 1

	M.spinner_timer:start(
		0,
		80,
		vim.schedule_wrap(function()
			if not M.win or not vim.api.nvim_win_is_valid(M.win) then
				M.stop_spinner()
				return
			end
			local frame = frames[i]
			i = (i % #frames) + 1
			M.update_title(string.format("(%s %s)", frame, label))
		end)
	)
end

function M.show_loading()
	M.clear()
	M.state = "waiting"
	M.start_spinner("Waiting...")
end

function M.set_thinking()
	if M.state ~= "thinking" then
		M.state = "thinking"
		M.start_spinner("Thinking...")
	end
end

function M.set_generating()
	if M.state ~= "generating" then
		M.state = "generating"
		M.stop_spinner()
		M.update_title("") -- Reset to default title
	end
end

function M.clear()
	if M.buf and vim.api.nvim_buf_is_valid(M.buf) then
		vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, { "" })
	end
end

return M
