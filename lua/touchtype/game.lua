-- ~/touchtype.nvim/lua/touchtype/game.lua
local M = {}

-- Function to start the game
function M.start()
	local ui = require("touchtype.ui")
	ui.open_window()
end

return M
