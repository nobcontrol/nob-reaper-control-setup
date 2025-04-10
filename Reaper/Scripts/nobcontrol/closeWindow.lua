-- Close the currently focused plugin or mixer floating window in Reaper

-- Check if the current window has focus
local hwnd = reaper.JS_Window_GetFocus()

if hwnd then
  -- Traverse up the window hierarchy until a relevant title is found
  local title = ""
  while hwnd do
    title = reaper.JS_Window_GetTitle(hwnd)
    if title:match("^FX:") or title:match("^BYPASSED") or title:match("^VST:") or title:match("^VST3:") or title:match("^MIDI take:") or title:lower():match("mixer") then
      break
    end
    hwnd = reaper.JS_Window_GetParent(hwnd)
  end

  -- Close the window if a matching title is found
  if hwnd and (title:match("^FX:") or title:match("^BYPASSED") or title:match("^VST:") or title:match("^VST3:") or title:match("^MIDI take:") or title:lower():match("mixer")) then
    reaper.JS_Window_Destroy(hwnd)
  end

  local mixer_hwnd = reaper.JS_Window_Find("Mixer", true)

  if mixer_hwnd then
    -- Bring the mixer window to the foreground
    reaper.JS_Window_SetForeground(mixer_hwnd)
  end
end
