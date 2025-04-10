 -- Get arrange view dimensions
 local start_time, end_time = reaper.GetSet_ArrangeView2(0, false, 0, 0)
 local arrange_width = end_time - start_time

 local offset = arrange_width / 2000

-- Get the current start and end of the loop selection
local start_loop, end_loop = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)

-- Move the left loop point left by one grid size
local new_end_loop = end_loop + offset

-- Set the new loop points
reaper.GetSet_LoopTimeRange(true, false, start_loop, new_end_loop, false)

