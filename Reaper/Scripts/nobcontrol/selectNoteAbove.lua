--[[
Script: Select First Note Above Current Selection (Prioritize Lower Pitch)
Author: Your Name
Description: Selects the first note(s) just above the current notes selection, which reside timely inside that selection.
If multiple notes are found, it prioritizes the note with the lower pitch.
If no suitable note is found, it selects any note above that is closer to the start of the selection.
If no selection is present, it selects the note that is closer to the current edit cursor position.
]]

local function get_note_info(take, note_idx)
  local retval, selected, muted, startppq, endppq, chan, pitch, vel = reaper.MIDI_GetNote(take, note_idx)
  return selected, startppq, endppq, pitch
end

local function select_note(take, note_idx, selected)
  reaper.MIDI_SetNote(take, note_idx, selected, nil, nil, nil, nil, nil, nil, true)
end

local function find_closest_note_above(take, startppq, endppq, pitch, note_count)
  local candidates = {}

  for i = 0, note_count - 1 do
      local _, note_startppq, _, note_pitch = get_note_info(take, i)
      if note_pitch > pitch and note_startppq >= startppq and note_startppq <= endppq then
          table.insert(candidates, {index = i, pitch = note_pitch})
      end
  end

  if #candidates > 0 then
      -- Sort candidates by pitch (ascending) to prioritize lower pitch
      table.sort(candidates, function(a, b) return a.pitch < b.pitch end)
      return candidates[1].index -- Return the note with the lowest pitch
  end

  return -1
end

local function find_any_note_above(take, startppq, pitch, note_count)
  local closest_note_idx = -1
  local closest_distance = math.huge

  for i = 0, note_count - 1 do
      local _, note_startppq, _, note_pitch = get_note_info(take, i)
      if note_pitch > pitch then
          local distance = math.abs(note_startppq - startppq)
          if distance < closest_distance then
              closest_distance = distance
              closest_note_idx = i
          end
      end
  end

  return closest_note_idx
end

local function main()
  local midi_editor = reaper.MIDIEditor_GetActive()
  if not midi_editor then return end

  local take = reaper.MIDIEditor_GetTake(midi_editor)
  if not take then return end

  local note_count, _, _ = reaper.MIDI_CountEvts(take)
  if note_count == 0 then return end

  local startppq, endppq = reaper.MIDI_GetPPQPosFromProjTime(take, reaper.GetCursorPosition()), reaper.MIDI_GetPPQPosFromProjTime(take, reaper.GetCursorPosition() + 1)
  local selected_notes = {}

  -- Find selected notes
  for i = 0, note_count - 1 do
      local selected, note_startppq, note_endppq, pitch = get_note_info(take, i)
      if selected then
          table.insert(selected_notes, {index = i, startppq = note_startppq, endppq = note_endppq, pitch = pitch})
      end
  end

  if #selected_notes > 0 then
      -- Find the first note above within the selection (prioritizing lower pitch)
      local closest_note_idx = -1
      for _, note in ipairs(selected_notes) do
          local note_idx = find_closest_note_above(take, note.startppq, note.endppq, note.pitch, note_count)
          if note_idx ~= -1 then
              closest_note_idx = note_idx
              break
          end
      end

      -- If no note found within the selection, find any note above closer to the start of the selection
      if closest_note_idx == -1 then
          for _, note in ipairs(selected_notes) do
              local note_idx = find_any_note_above(take, note.startppq, note.pitch, note_count)
              if note_idx ~= -1 then
                  closest_note_idx = note_idx
                  break
              end
          end
      end

      if closest_note_idx ~= -1 then
          -- Deselect all notes
          for i = 0, note_count - 1 do
              select_note(take, i, false)
          end

          -- Select the closest note above
          select_note(take, closest_note_idx, true)
      end
  else
      -- If no selection, find the note closest to the edit cursor
      local cursor_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, reaper.GetCursorPosition())
      local closest_note_idx = -1
      local closest_distance = math.huge

      for i = 0, note_count - 1 do
          local _, note_startppq, _, _ = get_note_info(take, i)
          local distance = math.abs(note_startppq - cursor_ppq)
          if distance < closest_distance then
              closest_distance = distance
              closest_note_idx = i
          end
      end

      if closest_note_idx ~= -1 then
          -- Deselect all notes
          for i = 0, note_count - 1 do
              select_note(take, i, false)
          end

          -- Select the closest note to the cursor
          select_note(take, closest_note_idx, true)
      end
  end

  reaper.UpdateArrange()
end

main()