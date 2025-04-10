-- Move loop region to edit cursor

-- Begin an undo block to allow undoing this action
reaper.Undo_BeginBlock()

-- Get the current loop start and end times
local current_start, current_end = reaper.GetSet_LoopTimeRange2(0, false, true, 0, 0, false)

-- Calculate the current loop length
local loop_length = current_end - current_start

-- Get the current position of the edit cursor
local cursor_pos = reaper.GetCursorPosition()

-- Set the new loop start to the edit cursor position and the new end to cursor position plus the loop length
reaper.GetSet_LoopTimeRange2(0, true, true, cursor_pos, cursor_pos + loop_length, false)

-- End the undo block with a description of the action
reaper.Undo_EndBlock("Move loop to cursor", -1)
