-- Convert 0.01 dB to a gain factor
local dB_increase = 0.1
local gain_factor = 10 ^ (dB_increase / 20)

-- Get the count of selected media items
local item_count = reaper.CountSelectedMediaItems(0)

if item_count > 0 then
    -- Loop through all selected media items
    for i = 0, item_count - 1 do
        -- Get the selected media item
        local item = reaper.GetSelectedMediaItem(0, i)
        
        -- Get the current volume of the item
        local current_vol = reaper.GetMediaItemInfo_Value(item, "D_VOL")
        
        -- Apply the volume increase
        local new_vol = current_vol * gain_factor
        reaper.SetMediaItemInfo_Value(item, "D_VOL", new_vol)
    end
    
    reaper.UpdateArrange()
end
   