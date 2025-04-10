-- Move the left loop point to the left by 1 grid subdivision

-- Get the current grid size (in quarter notes) and convert to seconds
local grid_division, division = reaper.GetSetProjectGrid(0, false) -- Grid size in quarter notes

-- Get the current start and end of the loop selection
local start_loop, end_loop = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)

-- Move the left loop point left by one grid size
local new_start_loop =  math.floor((start_loop + 2*division)/(2*division))*2*division
-- Ensure the new start loop point doesn't go below 0
if new_start_loop > end_loop then
    new_start_loop = end_loop
end

-- Set the new loop points
reaper.GetSet_LoopTimeRange(true, false, new_start_loop, end_loop, false)


