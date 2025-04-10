--[[
 * ReaScript Name: Hide Empty Tracks in TCP
 * Author: Your Name/AI Assistant
 * Licence: GPL v3
 * REAPER: 6.0+
 * Version: 1.0
 * Provides: [main=main] .
--]]

--[[
 * Changelog:
 * v1.0 (YYYY-MM-DD)
   - Initial release: Hides tracks in TCP with no items and no active envelopes.
--]]

---------------------------------------------------------------------
-- Function to check if a track has any active envelopes
---------------------------------------------------------------------
function TrackHasActiveEnvelopes(track)
  if not track then return false end

  local env_count = reaper.CountTrackEnvelopes(track)
  if env_count == 0 then return false end

  for i = 0, env_count - 1 do
    local envelope = reaper.GetTrackEnvelope(track, i)
    if envelope then
      -- Check if the envelope is active (enabled)
      -- B_ACTIVE returns 1.0 if active, 0.0 if not
      -- if reaper.GetEnvelopeInfo_Value(envelope, "B_ACTIVE") > 0 then
        return true -- Found at least one active envelope
      -- end
    end
  end

  return false -- No active envelopes found
end

---------------------------------------------------------------------
-- Main function
---------------------------------------------------------------------
function Main()
  reaper.Undo_BeginBlock() -- Start undo block
  reaper.PreventUIRefresh(1) -- Prevent UI flickering/slowdown

  local tracks_hidden = 0
  local total_tracks = reaper.CountTracks(0) -- Get total tracks in current project
  local master_track = reaper.GetMasterTrack(0) -- Get the master track

  for i = 0, total_tracks - 1 do
    local track = reaper.GetTrack(0, i)

    if track and track ~= master_track then -- Process only valid tracks that are not the master track
      local item_count = reaper.CountTrackMediaItems(track)
      local has_active_envs = TrackHasActiveEnvelopes(track)

      -- Check if track is empty (no items AND no active envelopes)
      if item_count == 0 and not has_active_envs then
        -- Check if it's already hidden to avoid unnecessary calls
        local is_visible = reaper.GetMediaTrackInfo_Value(track, "B_SHOWINTCP") > 0
        if is_visible then
          reaper.SetMediaTrackInfo_Value(track, "B_SHOWINTCP", 0) -- Hide track in TCP
          tracks_hidden = tracks_hidden + 1
        end
      end
    end
  end

  reaper.PreventUIRefresh(-1) -- Re-enable UI updates
  reaper.UpdateArrange() -- Force Arrangement View (TCP) update

  reaper.Undo_EndBlock("Hide empty tracks in TCP (" .. tracks_hidden .. " hidden)", -1) -- End undo block
end

---------------------------------------------------------------------
-- Run the main function
---------------------------------------------------------------------
-- Check if running from Reaper (otherwise could be required by another script)
local _, script_path = reaper.get_action_context()
if script_path then
  Main()
else
  -- If required by another script, just make the functions available
  -- reaper.defer(Main) -- Optional: use defer if running directly from editor/console
end

-- Optional: uncomment the line below if you want the script to run immediately
-- when loaded into the ReaScript editor without needing to press Ctrl+S or Run.
-- Be careful with this if you have complex setup/teardown logic.
-- Main()
