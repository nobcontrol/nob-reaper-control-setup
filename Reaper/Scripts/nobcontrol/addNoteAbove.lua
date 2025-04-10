--[[
  Script: Select note immediately above selection (or closest to edit/pitch cursor)
  Description: For the active MIDI editor take, if any notes are selected it computes the bounding box of the selection,
    then tries to add to the selection the note(s) immediately above – first checking for those overlapping horizontally.
    If none are found, it adds the note above the box whose start position (in grid units) and pitch is closest to the
    midpoint of the top edge. If no note is already selected, it selects the note closest to the intersection of
    the edit cursor (time) and the pitch cursor.
  
  Assumptions:
    - Horizontal units: 1 grid subdivision = 1 unit. (The script uses reaper.MIDI_GetGrid to determine grid size in PPQ.)
    - Vertical units: 1 semitone = 1 unit.
  
  Save this as a .lua file and run it from Reaper’s MIDI editor.
--]]

reaper.Undo_BeginBlock()

-- Get the active MIDI editor and its take
local editor = reaper.MIDIEditor_GetActive()
if not editor then return end
local take = reaper.MIDIEditor_GetTake(editor)
if not take then return end

-- Get the grid subdivision size (in PPQ); if invalid, use a fallback value (e.g. 480)
local grid_ppq = reaper.MIDI_GetGrid(take)
if grid_ppq <= 0 then grid_ppq = 480 end

local note_count = reaper.MIDI_CountEvts(take)
local selected_count = 0

-- Variables to hold the bounding box of the selected notes
local min_x, max_x = math.huge, -math.huge  -- horizontal: note start and end (converted to grid units)
local min_pitch, max_pitch = math.huge, -math.huge

-- We'll store all note properties in a table (indexed by note index)
local notes = {}

for i = 0, note_count-1 do
    local retval, selected, muted, startppq, endppq, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
    notes[i] = {selected = selected, muted = muted, startppq = startppq, endppq = endppq, chan = chan, pitch = pitch, vel = vel}
    if selected then
        selected_count = selected_count + 1
        local x_start = startppq / grid_ppq
        local x_end   = endppq   / grid_ppq
        if x_start < min_x then min_x = x_start end
        if x_end   > max_x then max_x   = x_end   end
        if pitch   < min_pitch then min_pitch = pitch end
        if pitch   > max_pitch then max_pitch = pitch end
    end
end

-- Disable sorting for performance while modifying note selection
reaper.MIDI_DisableSort(take)

if selected_count > 0 then
  -- CASE 1: There is an existing selection.
  -- First, find unselected notes that are above the current bounding box AND whose horizontal range overlaps the box.
  local candidates = {}
  for i = 0, note_count-1 do
      local note = notes[i]
      if not note.selected and note.pitch > min_pitch then
          local x_start = note.startppq / grid_ppq
          local x_end   = note.endppq   / grid_ppq
          -- Check horizontal overlap: if the note’s horizontal span touches the selection
          if (x_end > min_x and x_start < max_x) then
              local diff = note.pitch - min_pitch
              table.insert(candidates, {index = i, diff = diff})
          end
      end
  end

  if #candidates > 0 then
      -- Found candidate(s): select all notes having the smallest pitch difference.
      local min_diff = math.huge
      for _, cand in ipairs(candidates) do
          if cand.diff < min_diff then
              min_diff = cand.diff
          end
      end
      for _, cand in ipairs(candidates) do
          if cand.diff == min_diff then
              local note = notes[cand.index]
              reaper.MIDI_SetNote(take, cand.index, true, note.muted, note.startppq, note.endppq, note.chan, note.pitch, note.vel)
          end
      end
  else
      -- Fallback: no candidate overlapping horizontally.
      -- Look among all unselected notes above the box and pick the one closest (Euclidean distance)
      -- to the midpoint of the top edge of the selection (whose coordinates are: x = (min_x+max_x)/2, y = max_pitch)
      local fallback_candidates = {}
      for i = 0, note_count-1 do
          local note = notes[i]
          if not note.selected and note.pitch > max_pitch then
              local x = note.startppq / grid_ppq
              local mid_x = (min_x + max_x) / 2
              local dx = x - mid_x
              local dy = note.pitch - max_pitch
              local dist = math.sqrt(dx*dx + dy*dy)
              table.insert(fallback_candidates, {index = i, dist = dist})
          end
      end
      if #fallback_candidates > 0 then
          local best = fallback_candidates[1]
          for _, cand in ipairs(fallback_candidates) do
              if cand.dist < best.dist then best = cand end
          end
          local note = notes[best.index]
          reaper.MIDI_SetNote(take, best.index, true, note.muted, note.startppq, note.endppq, note.chan, note.pitch, note.vel)
      end
  end

else
  -- No selection - find closest note to cursors
  reaper.MIDI_SelectAll(take, false)
    
  local cursor_pos = reaper.GetCursorPosition()
  local cursor_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, cursor_pos)
  local pitch_cursor = reaper.MIDIEditor_GetSetting_int(editor, "active_note_row")
  local grid_division = reaper.MIDI_GetGrid(take)
  local grid_ppq = grid_division * 960  -- Assuming 960 PPQ per quarter note

  local closest_dist = math.huge
  local closest_index = -1

  for i = 0, note_count - 1 do
      local ret, _, muted, startppq, endppq, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
      local h_dist = math.abs((startppq - cursor_ppq) / grid_ppq)
      local v_dist = math.abs(pitch - pitch_cursor)
      local total_dist = h_dist + v_dist

      if total_dist < closest_dist or (total_dist == closest_dist and v_dist < closest_v_dist) then
          closest_dist = total_dist
          closest_v_dist = v_dist
          closest_index = i
      end
  end

  if closest_index >= 0 then
      reaper.MIDI_SetNote(take, closest_index, true)
  end
end

-- Re-enable sorting and finish up.
reaper.MIDI_Sort(take)
reaper.Undo_EndBlock("Select note above bounding box", -1)
reaper.UpdateArrange()
