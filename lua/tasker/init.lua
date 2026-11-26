local M = {}

M.width = 40

local function replace_line(transform_fn)
	local buf = vim.api.nvim_get_current_buf()
	local line = vim.api.nvim_get_current_line()
	local win = vim.api.nvim_get_current_win()
	local row = vim.api.nvim_win_get_cursor(win)[1]
	local new_line = transform_fn(line)
	vim.api.nvim_buf_set_lines(buf, row - 1, row, false, new_line)
end

local function update_multiple_lines(transform_fn)
	local buf = vim.api.nvim_get_current_buf()
	local start_row = vim.fn.line("v")
	local end_row = vim.fn.line(".")

	if start_row == 0 or end_row == 0 then
		vim.notify("Tasker: No visual selection found. Please select lines in visual mode first.", vim.log.levels.WARN)
		return
	end

	-- Ensure row range is valid (start <= end)
	if start_row > end_row then
		start_row, end_row = end_row, start_row
	end

	local lines = vim.api.nvim_buf_get_lines(buf, start_row - 1, end_row, false)
	for i, line in ipairs(lines) do
		lines[i] = transform_fn(line)[1]
	end
	vim.api.nvim_buf_set_lines(buf, start_row - 1, end_row, false, lines)
end

local function str_make_title(line)
	local border = string.rep("-", M.width)
	local space_count = math.floor((M.width - 4 - #line) / 2)
	local padding = string.rep(" ", space_count)

	line = padding .. line:upper() .. padding
	if #line < M.width - 4 then
		line = line .. " "
	end

	line = "|-" .. line .. "-|"
	if #line > M.width then
		local diff = #line - M.width
		border = border .. string.rep("-", diff)
	end

	return { border, line, border }
end

local function str_make_item(line)
	local trimmed = line:gsub("^%s*(.-)", "%1")
	if trimmed:sub(1, 1) == "-" or trimmed == "" then
		return { line }
	end

	local indent = #line - #trimmed
	local first_char = line:sub(indent + 1, indent + 1):upper()
	local rest = line:sub(indent + 2, indent + #trimmed)

	return { line:sub(1, indent) .. "- [ ] " .. first_char .. rest }
end

local function trim_spaces_and_hyphens(s)
	s = s:gsub("^- [%s%-]+", "")
	s = s:gsub("- [%s%-]+$", "")
	return s
end

local function str_make_subtitle(s)
	s = trim_spaces_and_hyphens(s)
	local space_count = math.floor((M.width - #s) / 2)
	local padding = string.rep("-", space_count)

	s = padding .. s:upper() .. padding
	if #s ~= M.width then
		s = s .. "-"
	end

	return { s }
end

local function str_mark_item(s)
	return { (s:gsub("%[.?%]", "[X]", 1)) }
end

local function str_unmark_item(s)
	return { (s:gsub("%[.?%]", "[ ]", 1)) }
end

M.makeTitle = function()
	replace_line(str_make_title)
end

M.makeSubTitle = function()
	replace_line(str_make_subtitle)
end

M.makeItem = function()
	local mode = vim.fn.mode()
	if mode == "n" then
		replace_line(str_make_item)
	elseif mode == "v" then
		update_multiple_lines(str_make_item)
	end
end

M.markItem = function()
	local mode = vim.fn.mode()
	if mode == "n" then
		replace_line(str_mark_item)
	elseif mode == "v" then
		update_multiple_lines(str_mark_item)
	end
end

M.unmarkItem = function()
	local mode = vim.fn.mode()
	if mode == "n" then
		replace_line(str_unmark_item)
	elseif mode == "v" then
		update_multiple_lines(str_unmark_item)
	end
end

local function make_md_table_row(line, separator)
	local newline, count = string.gsub(line, separator, " | ")
	newline = "| " .. newline .. " |"
	return newline, count
end

M.CreateMarkdownTable = function()
	local buf = vim.api.nvim_get_current_buf()
	local start_row = vim.fn.line("v")
	local end_row = vim.fn.line(".")

	if start_row == 0 or end_row == 0 then
		vim.notify("Tasker: No visual selection found. Please select lines in visual mode first.", vim.log.levels.WARN)
		return
	end

	-- Ensure row range is valid (start <= end)
	if start_row > end_row then
		start_row, end_row = end_row, start_row
	end

	local lines = vim.api.nvim_buf_get_lines(buf, start_row - 1, end_row, false)
	local count = 0
	for i, line in ipairs(lines) do
		lines[i], count = make_md_table_row(line, ",")
	end

	local divider = string.rep("| --- ", count + 1) .. "|"
	table.insert(lines, 2, divider)

	vim.api.nvim_buf_set_lines(buf, start_row - 1, end_row, false, lines)
end

local function expand_path(path)
	if path:sub(1, 1) == "~" then
		return os.getenv("HOME") .. path:sub(2)
	end
	return path
end

local function center_in(outer, inner)
	return (outer - inner) / 2
end

local function get_window_config()
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)

	return {
		relative = "editor",
		width = width,
		height = height,
		col = center_in(vim.o.columns, width),
		row = center_in(vim.o.lines, height),
		border = "rounded",
	}
end

local function open_floating_file(target_file)
	local expanded_path = expand_path(target_file)
	if vim.fn.filereadable(expanded_path) == 0 then
		vim.notify("Todo file doesn't exist at directory: " .. expanded_path, vim.log.levels.ERROR)
		return
	end

	local buf = vim.fn.bufnr(expanded_path, true)

	if buf == -1 then
		buf = vim.api.nvim_create_buf(false, false)
		vim.api.nvim_buf_set_name(buf, expanded_path)
	end

	vim.bo[buf].swapfile = false

	vim.api.nvim_open_win(buf, true, get_window_config())

	vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
		silent = true,
		noremap = true,
		callback = function()
			if vim.api.nvim_get_option_value("modified", { buf = buf }) then
				vim.notify("Save your changes please", vim.log.levels.WARN)
			else
				vim.api.nvim_win_close(0, true)
			end
		end,
	})
end

local state = {
	floating = {
		buf = -1,
		win = -1,
	},
}

local function create_floating_terminal(opts)
	local buf
	if vim.api.nvim_buf_is_valid(opts.buf) then
		buf = opts.buf
	else
		buf = vim.api.nvim_create_buf(false, true)
	end

	local win = vim.api.nvim_open_win(buf, true, get_window_config())

	return { buf = buf, win = win }
end

local function toggle_terminal()
	if not vim.api.nvim_win_is_valid(state.floating.win) then
		state.floating = create_floating_terminal({ buf = state.floating.buf })
		if vim.bo[state.floating.buf].buftype ~= "terminal" then
			vim.cmd.terminal()
			state.floating.buf = vim.api.nvim_get_current_buf()
		end
	else
		vim.api.nvim_win_hide(state.floating.win)
	end
end

local function setup_user_commands(opts)
	local target_file = opts.target_file or "todo.md"

	vim.api.nvim_create_user_command("Td", function()
		open_floating_file(target_file)
	end, {})

	vim.api.nvim_create_user_command("Tt", function()
		toggle_terminal()
	end, {})
end

M.setup = function(opts)
	opts = opts or {}
	M.width = opts.width or 50
	setup_user_commands(opts)
end

return M
