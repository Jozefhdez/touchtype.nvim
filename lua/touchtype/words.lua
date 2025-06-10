-- ~/touchtype.nvim/lua/touchtype/words.lua

local M = {}

local words = require("touchtype.wordsFile")

-- Function to get random words
function M.get_game_words(amount)
	local result = {}
	for _ = 1, amount do
		table.insert(result, words[math.random(#words)])
	end
	return table.concat(result, " ")
end

return M
