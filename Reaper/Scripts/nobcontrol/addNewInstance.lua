-- Function to add a new instance of the currently focused plugin to its own chain
function addPluginToSelfChain()
  -- Get the currently focused FX

  local retval, trackidx, itemidx, takeidx, fxidx, parm = reaper.GetTouchedOrFocusedFX(1)
  -- if retval ~= 1 then return end  -- No focused FX

  local track = reaper.GetTrack(0, trackidx) -- Convert to 0-based index

  -- Get the name of the focused FX
  local retval, fxName = reaper.TrackFX_GetFXName(track, fxidx)

  if fxName then
      -- Add the same FX again but inside itself
      reaper.TrackFX_AddByName(track, fxName, false, -1)
  end
end

-- Execute the function
addPluginToSelfChain()