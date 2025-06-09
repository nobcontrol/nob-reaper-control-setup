-- Move the left loop point to the left by 1 grid subdivision

-- Get the current grid size (in quarter notes) and convert to seconds
local grid_division, division = reaper.GetSetProjectGrid(0, false) -- Grid size in quarter notes

-- Get the current start and end of the loop selection
local start_loop, end_loop = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)

local startLoopInQN = reaper.TimeMap2_timeToQN(0, start_loop)

local newStartLoopInQN = math.floor((startLoopInQN + 4*division)/(4*division))*4*division;
local new_start_loop = reaper.TimeMap2_QNToTime(0, newStartLoopInQN);

if new_start_loop > end_loop then
    new_start_loop = end_loop
end

-- Set the new loop points
reaper.GetSet_LoopTimeRange(true, false, new_start_loop, end_loop, false)


