-- ~/touchtype.nvim/lua/touchtype/input.lua

local M = {}

local ns = vim.api.nvim_create_namespace("TouchTypeHL")
M.input_text = ""
M.error_count = 0

function M.reset_input()
	M.input_text = ""
	M.error_count = 0
end

function M.setup_keymaps(buf)
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
	local target = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]
	M.error_count = 0
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, 1)
	for i = 1, #M.input_text do
		local char = M.input_text:sub(i, i)
		local target_char = target:sub(i, i)
		local hl_group = (char == target_char) and "DiffAdd" or "DiffDelete"
		vim.api.nvim_buf_add_highlight(buf, ns, hl_group, 0, i - 1, i)
		if char ~= target_char then
			M.error_count = M.error_count + 1
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
