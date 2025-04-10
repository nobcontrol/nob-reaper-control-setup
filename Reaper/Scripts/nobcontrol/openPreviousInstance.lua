function openPreviousInstance()
  -- Get the currently focused FX

  local retval, trackidx, itemidx, takeidx, fxidx, parm = reaper.GetTouchedOrFocusedFX(1)
  -- if retval ~= 1 then return end  -- No focused FX

  local track = reaper.GetTrack(0, trackidx) -- Convert to 0-based index

  -- Get the name of the focused FX
  local retval, fxName = reaper.TrackFX_GetFXName(track, fxidx)

  local fx_count = reaper.TrackFX_GetCount(track)
  local previous_instance_index = -1

  for i = fxidx - 1, 0, -1 do
    local retval, plugin_name = reaper.TrackFX_GetFXName(track, i, "")
    if retval and plugin_name == fxName then
      previous_instance_index = i
      break
    end
  end

  if previous_instance_index ~= -1 then
    reaper.TrackFX_Show(track, previous_instance_index, 3)  -- 3 means "show floating window"
    local hwnd = reaper.TrackFX_GetFloatingWindow(track, previous_instance_index);
    reaper.JS_Window_SetForeground(hwnd)
--    local result = reaper.TrackFX_SetNamedConfigParm(track,  previous_instance_index, "fx_focused", "1")
  end
end

-- Execute the function
openPreviousInstance()