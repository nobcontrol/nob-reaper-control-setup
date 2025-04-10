function openNext()
  -- Get the currently focused FX

  local retval, trackidx, itemidx, takeidx, fxidx, parm = reaper.GetTouchedOrFocusedFX(1)
  -- if retval ~= 1 then return end  -- No focused FX

  local track = reaper.GetTrack(0, trackidx) -- Convert to 0-based index

  -- Get the name of the focused FX
  local retval, fxName = reaper.TrackFX_GetFXName(track, fxidx)

  local fx_count = reaper.TrackFX_GetCount(track)
  local next_instance_index = fxidx + 1

 
  local retval, plugin_name = reaper.TrackFX_GetFXName(track, next_instance_index)

  if retval then
    reaper.TrackFX_Show(track, next_instance_index, 3)  -- 3 means "show floating window"
    local hwnd = reaper.TrackFX_GetFloatingWindow(track, next_instance_index);
    reaper.JS_Window_SetForeground(hwnd)
  end
end

-- Execute the function
openNext()