-- Reaper script to delete the currently selected track

-- Check if Reaper API is available
if not reaper then
  reaper.ShowMessageBox("ReaScript API is not available.", "Error", 0)
  return
end

-- Get the currently selected track
local selected_track = reaper.GetSelectedTrack(0, 0)

if selected_track then
  local num_items = reaper.CountTrackMediaItems(selected_track)
  
  if num_items == 0 then
    reaper.DeleteTrack(selected_track)
  end
end
