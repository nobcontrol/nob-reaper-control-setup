-- Move the left loop point to the left by 1 grid subdivision

-- Get the current grid size (in quarter notes) and convert to seconds
local grid_division, division = reaper.GetSetProjectGrid(0, false) -- Grid size in quarter notes

-- Get the current start and end of the loop selection
local start_loop, end_loop = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)

local endLoopInQN = reaper.TimeMap2_timeToQN(0, end_loop)

local newEndLoopInQN = math.floor((endLoopInQN + 4*division)/(4*division))*4*division
local new_end_loop = reaper.TimeMap2_QNToTime(0, newEndLoopInQN);

-- Set the new loop points
reaper.GetSet_LoopTimeRange(true, false, start_loop, new_end_loop, false)

