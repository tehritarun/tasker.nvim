M = {}

M.width = 40

local replaceLine = function(f)
	local buf = vim.api.nvim_get_current_buf()
	local line = vim.api.nvim_get_current_line()
	local win = vim.api.nvim_get_current_win()
	local r, _ = unpack(vim.api.nvim_win_get_cursor(win))
	local newLine = f(line)
	vim.api.nvim_buf_set_lines(buf, r - 1, r, false, newLine)
end

local updateMultipleLines = function(f)
	local buf = vim.api.nvim_get_current_buf()
	local startRow = vim.fn.line("v")
	local endRow = vim.fn.line(".")
	-- print(startRow, endRow)
	if startRow == 0 or endRow == 0 then
		vim.notify("Tasker: No visual selection found. Please select lines in visual mode first.", vim.log.levels.WARN)
		return
	end

	-- Ensure row range is valid (start <= end)
	if startRow > endRow then
		startRow, endRow = endRow, startRow
	end

	local lines = vim.api.nvim_buf_get_lines(buf, startRow - 1, endRow, false)
	for i, line in ipairs(lines) do
		lines[i] = f(line)[1]
	end
	vim.api.nvim_buf_set_lines(buf, startRow - 1, endRow, false, lines)
end

local strMakeTitle = function(line)
	local strText = string.rep("-", M.width, "")
	local spcCount = math.modf((M.width - 4 - string.len(line)) / 2)
	local spc = string.rep(" ", spcCount, "")
	line = spc .. line:upper() .. spc
	if string.len(line) < M.width - 4 then
		line = line .. " "
	end
	line = "|-" .. line .. "-|"
	if string.len(line) > M.width then
		local diff = string.len(line) - M.width
		strText = strText .. string.rep("-", diff, "")
	end
	return { strText, line, strText }
end

local strMakeItem = function(line)
	local line_trim = line:gsub("^%s*(.-)", "%1")
	if line_trim:sub(1, 1) == "-" or line_trim == "" then
		return { line }
	end
	local spc = #line - #line_trim
	return {
		line:sub(1, spc) .. "- [ ] " .. string.upper(line:sub(spc + 1, spc + 1)) .. line:sub(spc + 2, spc + #line_trim),
	}
end

local trim_spaces_and_hyphens = function(s)
	-- Remove leading spaces and hyphens
	s = s:gsub("^- [%s%-]+", "")
	-- Remove trailing spaces and hyphens
	s = s:gsub("- [%s%-]+$", "")
	return s
end

local strMakeSubTitle = function(s)
	s = trim_spaces_and_hyphens(s)
	local spcCount = math.modf((M.width - #s) / 2)
	local spc = string.rep("-", spcCount, "")
	s = spc .. s:upper() .. spc
	if #s ~= M.width then
		s = s .. "-"
	end
	return { s }
end

local strMarkItem = function(s)
	local output = s:gsub("%[.?%]", "[X]", 1)
	return { output }
end

local strUnmarkItem = function(s)
	local output = s:gsub("%[.?%]", "[ ]", 1)
	return { output }
end

M.makeTitle = function()
	replaceLine(strMakeTitle)
end

M.makeSubTitle = function()
	replaceLine(strMakeSubTitle)
end

M.makeItem = function()
	local mode = vim.fn.mode()
	-- print("mode", mode)
	if mode == "n" then
		replaceLine(strMakeItem)
	elseif mode == "v" then
		updateMultipleLines(strMakeItem)
	end
end

M.markItem = function()
	local mode = vim.fn.mode()
	if mode == "n" then
		replaceLine(strMarkItem)
	elseif mode == "v" then
		updateMultipleLines(strMarkItem)
	end
end

M.unmarkItem = function()
	local mode = vim.fn.mode()
	if mode == "n" then
		replaceLine(strUnmarkItem)
	elseif mode == "v" then
		updateMultipleLines(strUnmarkItem)
	end
end

local expand_path = function(path)
	if path:sub(1, 1) == "~" then
		return os.getenv("HOME") .. path:sub(2)
	end
	return path
end

local center_in = function(outer, inner)
	return (outer - inner) / 2
end

local win_config = function()
	local width = math.min(math.floor(vim.o.columns * 0.8), 64)
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

local open_floating_file = function(target_file)
	local expanded_path = expand_path(target_file)
	if vim.fn.filereadable(expanded_path) == 0 then
		vim.notify("Todo file doesn't exist at directory: " .. expanded_path, vim.log.levels.ERROR)
	end

	local buf = vim.fn.bufnr(expanded_path, true)

	if buf == -1 then
		buf = vim.api.nvim_create_buf(false, false)
		vim.api.nvim_buf_set_name(buf, expanded_path)
	end

	vim.bo[buf].swapfile = false

	local win = vim.api.nvim_open_win(buf, true, win_config())

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

local setup_user_commands = function(opts)
	local target_file = opts.target_file or "todo.md"
	vim.api.nvim_create_user_command("Td", function()
		open_floating_file(target_file)
	end, {})
end

M.setup = function(opts)
	opts = opts or {}
	M.width = opts.width or 50
	setup_user_commands(opts)
end

return M
