-- ~/touchtype.nvim/lua/touchtype/ui.lua

local popup = require("plenary.popup")

local M = {}

local game_win_id = nil
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

-- Function to wrap text without cutting words
local function wrap_text(text, max_width)
	local lines = {}
	local words = {}
	
	-- Split text into words
	for word in text:gmatch("%S+") do
		table.insert(words, word)
	end
	
	local current_line = ""
	local prefix = "  " -- Account for the prefix spacing
	local available_width = max_width - #prefix
	
	for _, word in ipairs(words) do
		-- Check if adding this word would exceed the line width
		local test_line = current_line == "" and word or current_line .. " " .. word
		
		if #test_line <= available_width then
			current_line = test_line
		else
			-- Current line is full, start a new line
			if current_line ~= "" then
				table.insert(lines, prefix .. current_line)
			end
			current_line = word
		end
	end
	
	-- Add the last line if it's not empty
	if current_line ~= "" then
		table.insert(lines, prefix .. current_line)
	end
	
	return lines
end

function M.open_window()
	-- TODO: Add menu to pick a maximum time add punctuations and numbers
	-- TODO: Add selection of game modes (time mode, amount of words needed to end current try)

	stop_timer()

	local buf = vim.api.nvim_create_buf(false, true)
	local input = require("touchtype.input")

	-- Fill the buffer with words
	local words_text = require("touchtype.words").get_game_words(50)
	local ui = vim.api.nvim_list_uis()[1]
	local width = math.min(80, ui.width - 10)
	
	-- Wrap the words to fit the window width
	local wrapped_lines = wrap_text(words_text, width - 4) -- Account for borders and padding
	
	-- Create the buffer content with wrapped words
	local buffer_content = {
		"",
		"  " .. string.rep("─", math.min(47, width - 6)),
		"  📝 TouchType.nvim - Practice Your Typing Skills",
		"  " .. string.rep("─", math.min(47, width - 6)),
		"",
	}
	
	-- Add wrapped word lines
	for _, line in ipairs(wrapped_lines) do
		table.insert(buffer_content, line)
	end
	
	-- Add remaining UI elements
	table.insert(buffer_content, "")
	table.insert(buffer_content, "  ⏱️  Time: 00:00    📊 WPM: --    ❌ Errors: 0")
	table.insert(buffer_content, "")
	table.insert(buffer_content, "  💡 Tip: Type the words above. Green = correct, Red = incorrect")
	table.insert(buffer_content, "")
	
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, buffer_content)

	-- Get current editor size
	local height = math.min(8 + #wrapped_lines, ui.height - 20) -- Dynamic height based on wrapped lines
	local row = math.floor((ui.height - height) / 2)
	local col = math.floor((ui.width - width) / 2)

	-- Configure floating window centered
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = " TouchType.nvim ",
		title_pos = "center",
	})

	game_win_id = win
	
	-- Position cursor on the first words line (dynamic position)
	local words_start_line = 6 -- First word line (1-indexed)
	vim.api.nvim_win_set_cursor(win, { words_start_line, 2 })
	
	input.reset_input()
	input.setup_keymaps(buf, wrapped_lines) -- Pass wrapped lines to input handler

	-- Add some nice highlighting (dynamic positions)
	vim.api.nvim_buf_add_highlight(buf, -1, "TouchTypeTitle", 2, 0, -1)
	local stats_line_pos = 6 + #wrapped_lines + 1 -- Position after wrapped lines
	vim.api.nvim_buf_add_highlight(buf, -1, "TouchTypeStats", stats_line_pos - 1, 0, -1)
	vim.api.nvim_buf_add_highlight(buf, -1, "Comment", stats_line_pos + 1, 0, -1)

	vim.cmd("startinsert")

	elapsed_seconds = 0
	timer = vim.loop.new_timer()
	timer:start(
		0,
		1000,
		vim.schedule_wrap(function()
			elapsed_seconds = elapsed_seconds + 1

			if buf and vim.api.nvim_buf_is_valid(buf) then
				-- Update stats line with better formatting (dynamic position)
				local stats_line_pos = 6 + #wrapped_lines + 1 -- Position after wrapped lines
				local wpm = elapsed_seconds > 0 and math.floor((#input.input_text / 5) / (elapsed_seconds / 60)) or 0
				local stats = string.format("  ⏱️  Time: %s    📊 WPM: %d    ❌ Errors: %d", 
					format_time(elapsed_seconds), wpm, input.error_count or 0)
				vim.api.nvim_buf_set_lines(buf, stats_line_pos - 1, stats_line_pos, false, { stats })
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
	-- TODO: Add acc in %
	-- TODO: Add graph of stats (similar to monkeytype)
	-- TODO: Make a play again keybind

	stop_timer()

	if game_win_id and vim.api.nvim_win_is_valid(game_win_id) then
		vim.api.nvim_win_close(game_win_id, true)
		game_win_id = nil
	end

	local buf = vim.api.nvim_create_buf(false, true)

	-- Calculate the error count
	local input = require("touchtype.input")
	local errors = input.error_count

	-- Calculate the elapsed time and words per minute
	local utils = require("touchtype.utils")
	local wpm = utils.calculate_wpm(input.input_text, utils.get_elapsed_seconds())
	local accuracy = #input.input_text > 0 and math.floor(((#input.input_text - errors) / #input.input_text) * 100) or 0

	-- Create a nice results display
	local results_content = {
		"",
		"  " .. string.rep("═", 50),
		"  🎯 TYPING RESULTS",
		"  " .. string.rep("═", 50),
		"",
		"  📊 STATISTICS:",
		"  ─────────────────────",
		string.format("  ⚡ Words per minute: %d WPM", wpm),
		string.format("  🎯 Accuracy: %d%%", accuracy),
		string.format("  ❌ Mistakes: %d", errors),
		string.format("  ⏱️  Time: %d seconds", math.floor(utils.get_elapsed_seconds())),
		string.format("  📝 Characters typed: %d", #input.input_text),
		"",
		"  " .. string.rep("─", 50),
		"",
		"  🔄 Press :R to play again",
		"  🚪 Press :q to quit",
		"",
	}

	-- Fill the buffer with content
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, results_content)

	-- Make buffer read-only
	vim.bo[buf].readonly = true
	vim.bo[buf].modifiable = false
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false

	local width = 60
	local height = 20
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	-- Configure floating window centered with better styling
	game_win_id = popup.create(buf, {
		title = " 🏆 Results ",
		highlight = "NormalFloat",
		line = row,
		col = col,
		minwidth = width,
		minheight = height,
		borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
	})

	-- Add syntax highlighting for better visuals
	vim.api.nvim_buf_add_highlight(buf, -1, "TouchTypeTitle", 2, 0, -1)
	vim.api.nvim_buf_add_highlight(buf, -1, "Keyword", 5, 0, -1)
	for i = 7, 11 do
		vim.api.nvim_buf_add_highlight(buf, -1, "TouchTypeStats", i, 0, -1)
	end
	vim.api.nvim_buf_add_highlight(buf, -1, "Comment", 15, 0, -1)
	vim.api.nvim_buf_add_highlight(buf, -1, "Comment", 16, 0, -1)

	vim.api.nvim_command("stopinsert")
end

return M
