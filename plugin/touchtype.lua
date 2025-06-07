vim.api.nvim_create_user_command("T", function()
	require("touchtype.game").start()
end, {})
