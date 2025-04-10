-- Reaper Script: Select items just above the current selection's bounding box

-- Get the number of selected items
local selectedItemCount = reaper.CountSelectedMediaItems(0)
if selectedItemCount == 0 then return end -- Exit if no items are selected

-- Initialize bounding box variables
local topmostTrack = nil
local earliestPos = nil
local latestPos = nil

-- Determine the bounding box of the selected items
for i = 0, selectedItemCount - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    local itemStart = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local itemLength = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    local itemEnd = itemStart + itemLength
    local itemTrack = reaper.GetMediaItemTrack(item)
    local itemTrackNumber = reaper.GetMediaTrackInfo_Value(itemTrack, "IP_TRACKNUMBER")
    
    -- Update topmost track
    if not topmostTrack or itemTrackNumber < reaper.GetMediaTrackInfo_Value(topmostTrack, "IP_TRACKNUMBER") then
        topmostTrack = itemTrack
    end
    
    -- Update earliest and latest positions
    if not earliestPos or itemStart < earliestPos then
        earliestPos = itemStart
    end
    if not latestPos or itemEnd > latestPos then
        latestPos = itemEnd
    end
end

-- If we have no valid bounding box, exit
if not topmostTrack or not earliestPos or not latestPos then return end

-- Find items just above the bounding box
local closestItems = {}
local closestDistance = nil

local itemCount = reaper.CountMediaItems(0)
for i = 0, itemCount - 1 do
    local item = reaper.GetMediaItem(0, i)
    local itemStart = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local itemLength = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    local itemEnd = itemStart + itemLength
    local itemTrack = reaper.GetMediaItemTrack(item)
    local itemTrackNumber = reaper.GetMediaTrackInfo_Value(itemTrack, "IP_TRACKNUMBER")
    local topmostTrackNumber = reaper.GetMediaTrackInfo_Value(topmostTrack, "IP_TRACKNUMBER")

    -- Check if the item is above the bounding box
    if itemTrackNumber < topmostTrackNumber and
     ((itemStart >= earliestPos and itemStart <= latestPos and itemEnd >= earliestPos and itemEnd <= latestPos) or
      (itemStart > earliestPos and itemStart < latestPos) or
      (itemEnd > earliestPos and itemEnd < latestPos) or
      (itemStart < earliestPos and itemEnd >latestPos)) then
        local distance = topmostTrackNumber - itemTrackNumber
        if not closestDistance or distance < closestDistance then
            closestItems = {item}
            closestDistance = distance
        elseif distance == closestDistance then
            table.insert(closestItems, item)
        end
    end
end

-- Select the closest items above the bounding box
if #closestItems > 0 then
    for _, item in ipairs(closestItems) do
        reaper.SetMediaItemSelected(item, true)
    end
    reaper.UpdateArrange()
end
