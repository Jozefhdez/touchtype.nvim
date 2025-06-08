-- ~/touchtype.nvim/plugin/touchtype.lua
-- Description: Touch typing game for Neovim
-- This script sets up a user command to start a touch typing game in Neovim

vim.api.nvim_create_user_command("T", function()
	require("touchtype.game").start()
end, {})

