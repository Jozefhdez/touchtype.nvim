-- ~/touchtype.nvim/lua/touchtype/game.lua
local M = {}

-- Function to start the game
function M.start()
	local ui = require("touchtype.ui")
	local utils = require("touchtype.utils")

	-- Start the timer
	utils.start_timer()

	-- Open the game window
	ui.open_window()
end

return M
