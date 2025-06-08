-- ~/touchtype.nvim/lua/touchtype/ui.lua
local M = {}

local game_win_id = nil

function M.open_window()
	local buf = vim.api.nvim_create_buf(false, true)
	local input = require("touchtype.input")

	-- Fill the buffer with content
	local words_line = require("touchtype.words").get_game_words(10)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
		words_line,
		"", -- User input
	})

	-- Get current editor size
	local ui = vim.api.nvim_list_uis()[1]
	local width = ui.width
	local height = ui.height

	-- Configure floating window to take full screen
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = 2,
		col = 2,
		style = "minimal",
		border = "rounded",
	})
	game_win_id = win

	-- Set cursor on line 2
	vim.api.nvim_win_set_cursor(win, { 2, 0 })

	-- Set cursor on the second line
	vim.cmd(string.format(
		[[
		augroup TouchTypeInput
			autocmd!
			autocmd TextChangedI <buffer=%d> lua require('touchtype.input').on_input_changed(%d)
		augroup END
	]],
		buf,
		buf
	))
end

function M.results_window()
	if game_win_id and vim.api.nvim_win_is_valid(game_win_id) then
		vim.api.nvim_win_close(game_win_id, true)
		game_win_id = nil
	end

	local buf = vim.api.nvim_create_buf(false, true)
	local input = require("touchtype.input")

	-- Fill the buffer with content
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
		"Results",
		"",
	})

	vim.api.nvim_buf_set_option(buf, "modifiable", false)

	local ui = vim.api.nvim_list_uis()[1]
	local width = ui.width - 10
	local height = ui.height - 10

	-- Configure floating window to take full screen
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = 2,
		col = 2,
		style = "minimal",
		border = "rounded",
	})
end

return M
