-- ~/touchtype.nvim/lua/touchtype/ui.lua
local M = {}

local game_win_id = nil
local timer_win_id = nil
local timer_buf_id = nil
local timer = nil
local elapsed_seconds = 0

local function format_time(seconds)
	local mins = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d", mins, secs)
end

local function stop_timer()
	if timer then
		timer:stop()
		timer:close()
		timer = nil
	end
end

function M.open_window()
	-- TODO: Add menu to pick a maximum time add punctuations and numbers
	-- TODO: Add selection of game modes (time mode, amount of words needed to end current try)

	stop_timer()

	local buf = vim.api.nvim_create_buf(false, true)
	local input = require("touchtype.input")

	-- Fill the buffer with words
	local words_line = require("touchtype.words").get_game_words(50)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
		words_line,
		"00:00", -- Timer
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
	vim.api.nvim_win_set_cursor(win, { 1, 0 })
	input.reset_input()
	input.setup_keymaps(buf)

	vim.cmd("startinsert")

	elapsed_seconds = 0
	timer = vim.loop.new_timer()
	timer:start(
		0,
		1000,
		vim.schedule_wrap(function()
			elapsed_seconds = elapsed_seconds + 1

			if buf and vim.api.nvim_buf_is_valid(buf) then
				-- Updates third line
				vim.api.nvim_buf_set_lines(buf, 1, 2, false, { format_time(elapsed_seconds) })
			end
		end)
	)
end

function M.close_window()
	if game_win_id and vim.api.nvim_win_is_valid(game_win_id) then
		vim.api.nvim_win_close(game_win_id, true)
		game_win_id = nil
	end

	stop_timer()
end

function M.is_window_open()
	return game_win_id and vim.api.nvim_win_is_valid(game_win_id)
end

function M.results_window()
	-- TODO: Improve visuals
	-- TODO: Add acc in %
	-- TODO: Add graph of stats (similar to monkeytype)
	-- TODO: Make a play again keybind

	stop_timer()

	if game_win_id and vim.api.nvim_win_is_valid(game_win_id) then
		vim.api.nvim_win_close(game_win_id, true)
		game_win_id = nil
	end

	local buf = vim.api.nvim_create_buf(false, true)

	-- Calculate the eror count
	local input = require("touchtype.input")
	local errors = input.error_count

	-- Calculate the elapsed time and words per minute
	local utils = require("touchtype.utils")
	local wpm = utils.calculate_wpm(input.input_text, utils.get_elapsed_seconds())

	-- Fill the buffer with content
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
		"Results",
		"Mistakes:" .. errors,
		"Time elapsed: " .. utils.get_elapsed_seconds() .. " seconds",
		"Words per minute: " .. wpm,
		"Press :q to close",
	})

	-- Make buffer read-only
	vim.api.nvim_buf_set_option(buf, "readonly", true)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(buf, "swapfile", false)

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
	game_win_id = win
	vim.api.nvim_command("stopinsert")
end

return M
