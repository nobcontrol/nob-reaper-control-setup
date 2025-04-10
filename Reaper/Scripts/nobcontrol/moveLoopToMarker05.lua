-- Move loop selection to marker 1, keeping the same length, and adjust playhead if necessary

local proj = 0

-- Get current loop points
local loop_start, loop_end = reaper.GetSet_LoopTimeRange2(proj, false, true, 0, 0, false)
local loop_length = loop_end - loop_start

-- Check if there is a valid loop selection
if loop_length <= 0 then
  return
end

-- Find marker 1
local marker_pos = nil
for i = 0, reaper.CountProjectMarkers(proj) - 1 do
  local retval, isrgn, pos, rgnend, name, markrgnindex = reaper.EnumProjectMarkers3(proj, i)
  if not isrgn and markrgnindex == 5 then
    marker_pos = pos
    break
  end
end

-- Check if marker 1 was found
if marker_pos == nil then
  return
end

-- Set new loop points
local new_loop_start = marker_pos
local new_loop_end = marker_pos + loop_length
reaper.GetSet_LoopTimeRange2(proj, true, true, new_loop_start, new_loop_end, false)

-- Handle playhead if playing and inside original loop
local play_state = reaper.GetPlayState()
if play_state & 1 == 1 then  -- Transport is playing
  local play_pos = reaper.GetPlayPosition()
  if play_pos >= loop_start and play_pos <= loop_end then
    local offset = play_pos - loop_start
    local new_play_pos = new_loop_start + offset
    reaper.SetEditCurPos(new_play_pos, false, true)
  else
    reaper.SetEditCurPos(new_loop_start, false, true)
  end
end

-- Move edit cursor to new loop start
reaper.SetEditCurPos(new_loop_start, true, false)
