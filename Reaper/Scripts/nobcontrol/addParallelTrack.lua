--[[
Description: Adds a new track below the currently selected track.
             Creates a send from the original track to the new track using 
             pre-fader (after FX) routing, renames the new track to the original track's name plus " - Parallel", and selects it.
Author: ChatGPT
Version: 1.0
--]]

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)

-- Get the first selected track
local orig_tr = reaper.GetSelectedTrack(0, 0)
if not orig_tr then
  return
end

-- Get the 0-based index of the original track (IP_TRACKNUMBER is 1-based)
local orig_index = reaper.GetMediaTrackInfo_Value(orig_tr, "IP_TRACKNUMBER") - 1

-- Insert a new track right below the original track
reaper.InsertTrackAtIndex(orig_index + 1, true)
reaper.TrackList_AdjustWindows(false)
local new_tr = reaper.GetTrack(0, orig_index + 1)

-- Create a send from the original track to the new track
local send_idx = reaper.CreateTrackSend(orig_tr, new_tr)
-- Set send mode to pre-fader (after FX) 
-- (in Reaper this routes the processed signal independent of the track fader)
reaper.SetTrackSendInfo_Value(orig_tr, 0, send_idx, "I_SENDMODE", 3)

-- Get the original track's name and set the new track's name to "OriginalName - Parallel"
local ok, orig_name = reaper.GetSetMediaTrackInfo_String(orig_tr, "P_NAME", "", false)
if not ok then orig_name = "" end
local new_name = orig_name .. " - Parallel"
reaper.GetSetMediaTrackInfo_String(new_tr, "P_NAME", new_name, true)

-- Select only the new track
reaper.Main_OnCommand(40297, 0) -- Unselect all tracks
reaper.SetTrackSelected(new_tr, true)

reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
reaper.Undo_EndBlock("Add Parallel Track with Pre-Fader Send", -1)

