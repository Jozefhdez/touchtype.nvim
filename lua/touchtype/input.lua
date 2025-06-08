-- ~/touchtype.nvim/lua/touchtype/input.lua
local M = {}

local ns = vim.api.nvim_create_namespace("TouchTypeHL")
M.input_text = ""

function M.on_input_changed(buf)
	local input = vim.api.nvim_buf_get_lines(buf, 1, 2, false)[1]
    M.input_text = input
	vim.api.nvim_buf_set_lines(buf, 1, 2, false, { input })

	-- Capture the target line from the first line of the buffer
	local target = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]
	M.error_count = 0

	-- Each character in the input line is compared to the target line
	for i = 1, #input do
		local char = input:sub(i, i)
		local target_char = target:sub(i, i)
		local hl_group = (char == target_char) and "DiffAdd" or "DiffDelete" -- Highlight group
		vim.api.nvim_buf_add_highlight(buf, ns, hl_group, 1, i - 1, i) -- Highlight the character in the second line
		if char ~= target_char then
			M.error_count = M.error_count + 1
		end
	end
	M.check_result(#input, #target)
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
