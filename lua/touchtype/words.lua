-- ~/touchtype.nvim/lua/touchtype/words.lua

-- TODO: Change the way words are selected, instead of getting them from an array do it from bigger pool (csv)
local M = {}

-- Predefined set of words
local words = {
	"hello",
	"world",
	"neovim",
	"touch",
	"type",
	"game",
	"lua",
	"vim",
	"editor",
	"buffer",
	"window",
	"command",
	"function",
	"start",
	"open",
	"close",
	"line",
	"text",
	"file",
	"plugin",
	"config",
	"setup",
}

-- Function to get random word
function M.get_words(amount_words)
	local string_words = ""

	for _ = 1, amount_words do
		if _ < amount_words then
			string_words = string_words .. words[math.random(1, #words)] .. " "
		else
			string_words = string_words .. words[math.random(1, #words)] -- Last word without trailing space
		end
	end

	return string_words
end

-- Function to get a list of words for the game
function M.get_game_words(amount_words)
	local game_words = M.get_words(amount_words)
	return game_words
end

return M
