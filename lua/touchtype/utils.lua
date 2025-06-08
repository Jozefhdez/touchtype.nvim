-- ~/touchtype.nvim/lua/touchtype/utils.lua
local M = {}

M.start_time = nil
M.end_time = nil

function M.start_timer()
    M.start_time = vim.loop.hrtime() -- This is nanoseconds btw
end

function M.end_timer()
    M.end_time = vim.loop.hrtime() -- This is nanoseconds btw
end

function M.get_elapsed_seconds()
    if M.start_time and M.end_time then
        return (M.end_time - M.start_time) / 1e9 -- Convert nanoseconds to seconds
    end
    return 0
end

function M.calculate_wpm(input, elapsed_seconds)
    local num_chars = #input
    local words = num_chars / 5
    local minutes = elapsed_seconds / 60
    if minutes == 0 then return 0 end
    return math.floor(words / minutes + 0.5)
end

return M
