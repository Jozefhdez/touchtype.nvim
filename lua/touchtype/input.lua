-- ~/touchtype.nvim/lua/touchtype/input.lua

local M = {}

local ns = vim.api.nvim_create_namespace("TouchTypeHL")
M.input_text = ""
M.error_count = 0
M.wrapped_lines = {} -- Store wrapped lines for proper highlighting

function M.reset_input()
	M.input_text = ""
	M.error_count = 0
	M.wrapped_lines = {}
end

function M.setup_keymaps(buf, wrapped_lines)
	M.wrapped_lines = wrapped_lines or {}
	vim.api.nvim_buf_set_keymap(
		buf,
		"i",
		"<BS>",
		'<Cmd>lua require("touchtype.input").backspace()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(buf, "i", "<CR>", "<Nop>", { noremap = true, silent = true })

	for i = 32, 126 do
		local char = string.char(i)
		vim.api.nvim_buf_set_keymap(
			buf,
			"i",
			char,
			string.format('<Cmd>lua require("touchtype.input").type_char("%s")<CR>', char),
			{ noremap = true, silent = true }
		)
	end
end

function M.type_char(char)
	M.input_text = M.input_text .. char
	M.update_highlight()
end

function M.backspace()
	M.input_text = M.input_text:sub(1, -2)
	M.update_highlight()
end

function M.update_highlight()
	local buf = vim.api.nvim_get_current_buf()
	
	-- Reconstruct the full target text from wrapped lines
	local target_parts = {}
	for _, line in ipairs(M.wrapped_lines) do
		-- Remove the leading spaces from each line
		local clean_line = line:gsub("^%s*", "")
		if clean_line ~= "" then
			table.insert(target_parts, clean_line)
		end
	end
	local target = table.concat(target_parts, " ")
	
	if not target or target == "" then return end
	
	M.error_count = 0
	
	-- Clear highlights on all wrapped lines
	local words_start_line = 5 -- 0-indexed line where words start
	for i = 0, #M.wrapped_lines - 1 do
		vim.api.nvim_buf_clear_namespace(buf, ns, words_start_line + i, words_start_line + i + 1)
	end
	
	-- Apply highlighting across multiple lines
	local char_pos = 0
	local target_pos = 1
	
	for line_idx, line in ipairs(M.wrapped_lines) do
		local clean_line = line:gsub("^%s*", "")
		local prefix_len = #line - #clean_line
		
		for char_idx = 1, #clean_line do
			if target_pos <= #M.input_text then
				local input_char = M.input_text:sub(target_pos, target_pos)
				local target_char = target:sub(target_pos, target_pos)
				local hl_group
				
				if input_char == target_char then
					hl_group = "TouchTypeCorrect"
				else
					hl_group = "TouchTypeIncorrect"
					M.error_count = M.error_count + 1
				end
				
				-- Apply highlight with proper line and column positions
				local line_num = 5 + line_idx - 1 -- 0-indexed buffer line
				local col_start = prefix_len + char_idx - 1
				local col_end = prefix_len + char_idx
				
				vim.api.nvim_buf_add_highlight(buf, ns, hl_group, line_num, col_start, col_end)
				target_pos = target_pos + 1
			end
		end
		
		-- Account for space between words (except for the last line)
		if line_idx < #M.wrapped_lines and target_pos <= #M.input_text then
			target_pos = target_pos + 1 -- Skip the space character
		end
	end
	
	M.check_result(#M.input_text, #target)
end

function M.check_result(length_input, length_target)
	if length_input == length_target then
		local ui = require("touchtype.ui")
		local utils = require("touchtype.utils")
		utils.end_timer()
		ui.results_window()
	end
end

return M
