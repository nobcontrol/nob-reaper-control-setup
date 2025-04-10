function deleteInstance()
  -- Get the currently focused FX
  local retval, trackidx, itemidx, takeidx, fxidx, parm = reaper.GetTouchedOrFocusedFX(1)

  local track = reaper.GetTrack(0, trackidx) -- Convert to 0-based index

  reaper.TrackFX_Delete(track, fxidx)
end

-- Execute the function
deleteInstance()