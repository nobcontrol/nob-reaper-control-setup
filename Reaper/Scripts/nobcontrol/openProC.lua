local PLUGIN_NAME = "FabFilter Pro-C 2"

-- Get the currently selected track
local track = reaper.GetSelectedTrack(0, 0)

if not track then
    return
end

-- Function to open the FX window for a specific FX index on a track
local function open_fx_window(track, fx_index)
    reaper.TrackFX_Show(track, fx_index, 3) -- Show the FX window
    local hwnd = reaper.TrackFX_GetFloatingWindow(track, fx_index);
    reaper.JS_Window_SetForeground(hwnd)
end

-- Search for the last instance of the specified plugin
local fx_count = reaper.TrackFX_GetCount(track)
local last_instance = -1

for i = 0, fx_count - 1 do
    local retval, fx_name = reaper.TrackFX_GetFXName(track, i, "")
    if retval and fx_name:find(PLUGIN_NAME, 1, true) then
        last_instance = i
    end
end

if last_instance >= 0 then
    -- Open the last instance of the plugin
    open_fx_window(track, last_instance)
else
    -- Add the plugin to the track's FX chain
    local new_fx_index = reaper.TrackFX_AddByName(track, PLUGIN_NAME, false, -1)
    if new_fx_index >= 0 then
        open_fx_window(track, new_fx_index)
    end
end
