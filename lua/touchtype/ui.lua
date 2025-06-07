local M = {}

function M.open_window()
	local buf = vim.api.nvim_create_buf(false, true)

	-- Fill the buffer with content
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
		"Welcome to TouchType",
	})

	-- Get current editor size
	local ui = vim.api.nvim_list_uis()[1]
	local width = ui.width
	local height = ui.height

	-- Configure floating window to take almost full screen
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
