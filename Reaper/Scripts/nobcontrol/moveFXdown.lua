-- Move the currently focused FX down in the FX chain

function move_focused_fx_down()
    local retval, track, item, fx_index = reaper.GetFocusedFX2()

    -- Only proceed if the focus is on a track FX (not input or monitoring FX)
    if track == 0 or fx_index < 0 then
        return
    end

    -- Get the actual track object
    local tr = reaper.GetTrack(0, track - 1)
    if not tr then return end

    local fx_count = reaper.TrackFX_GetCount(tr)
    local current_fx_index = fx_index

    -- Cannot move if already at the bottom
    if current_fx_index >= fx_count - 1 then return end

    reaper.Undo_BeginBlock()
    -- Swap with the one below
    reaper.TrackFX_CopyToTrack(tr, current_fx_index, tr, current_fx_index + 1, true)
    reaper.Undo_EndBlock("Move focused FX down", -1)
end

move_focused_fx_down()