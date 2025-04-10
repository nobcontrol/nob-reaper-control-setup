-- Lua script for REAPER to select next item to the left based on bounding box of selected items

-- Function to get the track number from a media item
function GetTrackNumber(item)
  local track = reaper.GetMediaItem_Track(item)
  local trackIndex = 0
  while trackIndex < reaper.CountTracks(0) do
      if reaper.GetTrack(0, trackIndex) == track then return trackIndex end
      trackIndex = trackIndex + 1
  end
  return -1  -- Return -1 if track not found
end

-- Main function
function Main()
  
  local sel_items = {}
  local min_start = math.huge
  local max_start = -math.huge
  local track_set = {}

  -- Collect selected items and their positions
  for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
      local item = reaper.GetSelectedMediaItem(0, i)
      table.insert(sel_items, item)
      local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      min_start = math.min(min_start, item_start)
      max_start = math.max(max_start, item_start)
      local track_num = GetTrackNumber(item)
      if track_num >= 0 then track_set[track_num] = true end
  end

  -- If no items were selected initially, exit
  if #sel_items == 0 then return end

  -- Find and select the next item to the left
  local bestItemPosition = -math.huge;

  -- Find the best item position
  for track_num = 0, reaper.CountTracks(0) - 1 do
      if track_set[track_num] then
          local track = reaper.GetTrack(0, track_num)
          for i = 0, reaper.CountTrackMediaItems(track) - 1 do
              local item = reaper.GetTrackMediaItem(track, i)
              local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
              if (item_start < min_start and item_start > bestItemPosition) then
                  bestItemPosition = item_start
              end
          end
      end
  end

  -- Select all items starting at the best item position
  for track_num = 0, reaper.CountTracks(0) - 1 do
    if track_set[track_num] then
        local track = reaper.GetTrack(0, track_num)
        for i = 0, reaper.CountTrackMediaItems(track) - 1 do
            local item = reaper.GetTrackMediaItem(track, i)
            local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
            if (item_start == bestItemPosition) then
              reaper.SetMediaItemSelected(item, true)
            end
        end
    end
  end

  -- Update arrange view to show new selection
  reaper.UpdateArrange()
end

-- Execute the main function
Main()

-- Undo point
reaper.Undo_OnStateChange2(0, "Select Next Item to Left within Bounding Box of Selected Items", -1)
