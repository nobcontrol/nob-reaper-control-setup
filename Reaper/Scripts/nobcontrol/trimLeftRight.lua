-- Move the start of all selected media items to the left by 1/2000 of the arrange view.
-- The end of the clips remains in the same position.

-- Ensure the action is undoable
reaper.Undo_BeginBlock()

-- Get the arrange view start and end times
local arrange_start, arrange_end = reaper.GetSet_ArrangeView2(0, false, 0, 0)
local arrange_width = arrange_end - arrange_start

-- Calculate the adjustment amount (1/2000 of the arrange width)
local adjustment = arrange_width / 2000

-- Iterate through selected media items
local num_items = reaper.CountSelectedMediaItems(0)
for i = 0, num_items - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    if item then
        local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        local item_length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")

        -- Adjust the start position and length of the item
        local new_start = item_start + adjustment
        local new_length = item_length - adjustment

        -- Set the new start position and length
        reaper.SetMediaItemInfo_Value(item, "D_POSITION", new_start)
        reaper.SetMediaItemInfo_Value(item, "D_LENGTH", new_length)
    end
end

-- Update the arrangement view
reaper.UpdateArrange()

-- End undo block
reaper.Undo_EndBlock("Move start of selected items to the left", -1)
