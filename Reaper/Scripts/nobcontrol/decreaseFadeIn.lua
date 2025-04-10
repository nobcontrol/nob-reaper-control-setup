-- Function to get time per pixel
local function GetTimePerPixel()
  local start_time, end_time = reaper.GetSet_ArrangeView2(0, false, 0, 0)
  local width = reaper.GetMainHwnd()
  --local _, _, arrange_width = reaper.JS_Window_GetClientSize(width)
  local arrange_width = 500;
  return (end_time - start_time) / arrange_width
end

-- Get time per pixel
local time_per_pixel = GetTimePerPixel()

-- Get the number of selected items
local num_selected_items = reaper.CountSelectedMediaItems(0)

-- Loop through all selected items
for i = 0, num_selected_items - 1 do
  -- Get the current item
  local item = reaper.GetSelectedMediaItem(0, i)
  
  -- Get the current fade-in time
  local current_fadein = reaper.GetMediaItemInfo_Value(item, "D_FADEINLEN")
  
  -- Calculate new fade-in time (exactly 1 pixel based on current view)
  local new_fadein = current_fadein - time_per_pixel
  
  -- Set the new fade-in time
  reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", new_fadein)
end

-- Update the arrange view
reaper.UpdateArrange()
