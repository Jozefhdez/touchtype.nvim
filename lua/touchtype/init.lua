local M = {}

function M.setup()
	vim.api.nvim_create_user_command("TouchType", function()
		require("touchtype.game").start()
	end, {})
end

return M
