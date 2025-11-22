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
	local startRow, _ = unpack(vim.api.nvim_buf_get_mark(buf, "<"))
	local endRow, _ = unpack(vim.api.nvim_buf_get_mark(buf, ">"))
	local lines = vim.api.nvim_buf_get_lines(buf, startRow - 1, endRow, false)
	for i = 1, #lines, 1 do
		lines[i] = f(lines[i])[1]
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
	if line_trim:sub(1, 1) == "[" or line_trim == "" then
		return { line }
	end
	local spc = #line - #line_trim
	return {
		line:sub(1, spc) .. "[ ] " .. string.upper(line:sub(spc + 1, spc + 1)) .. line:sub(spc + 2, spc + #line_trim),
	}
end

local trim_spaces_and_hyphens = function(s)
	-- Remove leading spaces and hyphens
	s = s:gsub("^[%s%-]+", "")
	-- Remove trailing spaces and hyphens
	s = s:gsub("[%s%-]+$", "")
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

M.makeItem = function(mode)
	if mode == "n" then
		replaceLine(strMakeItem)
	elseif mode == "v" then
		updateMultipleLines(strMakeItem)
	end
end

M.markItem = function(mode)
	if mode == "n" then
		replaceLine(strMarkItem)
	elseif mode == "v" then
		updateMultipleLines(strMarkItem)
	end
end

M.unmarkItem = function(mode)
	if mode == "n" then
		replaceLine(strUnmarkItem)
	elseif mode == "v" then
		updateMultipleLines(strUnmarkItem)
	end
end

M.setup = function(opts)
	M.width = opts.width or 50
end

return M
