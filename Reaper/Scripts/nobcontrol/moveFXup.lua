-- Reaper Lua Script: Move Focused FX Up
-- Moves the currently focused FX one slot up in the FX chain of the selected track.

function MoveFocusedFXUp()
  local retval, track, item, fx_index = reaper.GetFocusedFX2()

  if not track then
    return
  end

  if fx_index == -1 then
    return
  end

  if fx_index == 0 then
    return
  end

  local tr = reaper.GetTrack(0, track - 1)
  if not tr then return end

  reaper.TrackFX_CopyToTrack(tr, fx_index, tr, fx_index-1, true)
end

-- Check if running in Reaper (otherwise, functions won't be available)
if reaper then
  MoveFocusedFXUp()
  reaper.defer(function() end) -- Prevents the script from running twice in some Reaper versions and contexts
else
  -- This part is for local testing outside Reaper, won't actually run in Reaper
  print("This script is intended to be run within Reaper.")
end