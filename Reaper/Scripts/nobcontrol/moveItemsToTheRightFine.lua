-- Move selected clips to the left by 1/1000 of the arrange view width
-- Save this file as a .lua script and load it into Reaper's Action List

-- Get the current arrange view dimensions
function get_arrange_view_dimensions()
    local start_time, end_time = reaper.GetSet_ArrangeView2(0, false, 0, 0)
    return start_time, end_time
end

-- Main script function
function move_selected_items_left()
    -- Get arrange view dimensions
    local start_time, end_time = get_arrange_view_dimensions()
    local arrange_width = end_time - start_time

    -- Calculate the movement offset (1/1000th of the arrange view width)
    local offset = arrange_width / 2000

    -- Get the number of selected media items
    local num_items = reaper.CountSelectedMediaItems(0)

    -- Move each selected media item
    for i = 0, num_items - 1 do
        local item = reaper.GetSelectedMediaItem(0, i)
        if item then
            local item_position = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
            local new_position = item_position + offset

            -- Set the new position
            reaper.SetMediaItemInfo_Value(item, "D_POSITION", new_position)
        end
    end

    -- Update the arrange view
    reaper.UpdateArrange()
end

-- Run the script
reaper.Undo_BeginBlock()
move_selected_items_left()
reaper.Undo_EndBlock("Move selected clips left by 1/1000th of arrange view", -1)
