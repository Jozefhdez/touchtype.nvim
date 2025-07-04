local M = {}

function M.setup()
	-- Create custom highlight groups for better visual experience
	vim.api.nvim_set_hl(0, "TouchTypeCorrect", { fg = "#a6e3a1", bg = "#313244", bold = true })
	vim.api.nvim_set_hl(0, "TouchTypeIncorrect", { fg = "#f38ba8", bg = "#313244", bold = true })
	vim.api.nvim_set_hl(0, "TouchTypeTitle", { fg = "#cba6f7", bold = true })
	vim.api.nvim_set_hl(0, "TouchTypeStats", { fg = "#89b4fa", italic = true })
	
	vim.api.nvim_create_user_command("TouchType", function()
		require("touchtype.game").start()
	end, {})
end

return M
