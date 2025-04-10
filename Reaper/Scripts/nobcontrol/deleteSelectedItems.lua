-- Reaper script to delete all selected items
local item_count = reaper.CountMediaItems(0)

reaper.Undo_BeginBlock()

if item_count > 0 then
  for i = 0, item_count do
    local item = reaper.GetMediaItem(0, item_count-i)
    if item then
      if reaper.IsMediaItemSelected(item) then
        reaper.DeleteTrackMediaItem(reaper.GetMediaItemTrack(item), item)
      end
    end  
  end  
end

reaper.Undo_EndBlock("Delete selected items", -1)

reaper.UpdateArrange()

