--[[
 * ReaScript Name: Select Previous Note with Same or Closest Pitch
 * Author: Your Name
 * Version: 1.1
 * Description: Selects the note immediately to the left of the current selection with the same pitch as any selected note. If none is found, selects the closest pitch. If no selection is present, selects the note closest to the edit cursor.
--]]

function main()
  local editor = reaper.MIDIEditor_GetActive()
  if not editor then return end

  local take = reaper.MIDIEditor_GetTake(editor)
  if not take then return end

  local _, noteCount = reaper.MIDI_CountEvts(take)
  if noteCount == 0 then return end

  local selectedNotes = {}
  local firstSelectedPPQ = math.huge
  local lastSelectedPPQ = -math.huge

  -- Gather selected notes and determine the time range of the selection
  for i = 0, noteCount - 1 do
      local _, selected, _, startppqpos, _, _, pitch, _ = reaper.MIDI_GetNote(take, i)
      if selected then
          selectedNotes[#selectedNotes + 1] = {index = i, pitch = pitch, startppqpos = startppqpos}
          if startppqpos < firstSelectedPPQ then firstSelectedPPQ = startppqpos end
          if startppqpos > lastSelectedPPQ then lastSelectedPPQ = startppqpos end
      end
  end

  local targetNoteIndex = nil
  local minTimeDiff = math.huge
  local minPitchDiff = math.huge

  if #selectedNotes > 0 then
      -- Search for the note immediately to the right with the same pitch
      for i = 0, noteCount - 1 do
          local _, _, _, startppqpos, _, _, pitch, _ = reaper.MIDI_GetNote(take, i)
          if startppqpos > lastSelectedPPQ then
              for _, selNote in ipairs(selectedNotes) do
                  if pitch == selNote.pitch and (startppqpos - lastSelectedPPQ) < minTimeDiff then
                      minTimeDiff = startppqpos - lastSelectedPPQ
                      targetNoteIndex = i
                  end
              end
          end
      end

      -- If no exact pitch match is found, search for the closest pitch
      if not targetNoteIndex then
          for i = 0, noteCount - 1 do
              local _, _, _, startppqpos, _, _, pitch, _ = reaper.MIDI_GetNote(take, i)
              if startppqpos > lastSelectedPPQ then
                  for _, selNote in ipairs(selectedNotes) do
                      local pitchDiff = math.abs(pitch - selNote.pitch)
                      if (startppqpos - lastSelectedPPQ) < minTimeDiff or ((startppqpos - lastSelectedPPQ) == minTimeDiff and pitchDiff < minPitchDiff) then
                          minTimeDiff = startppqpos - lastSelectedPPQ
                          minPitchDiff = pitchDiff
                          targetNoteIndex = i
                      end
                  end
              end
          end
      end
  else
      -- No notes are selected; find the note closest to the edit cursor
      local cursorPos = reaper.MIDI_GetPPQPosFromProjTime(take, reaper.GetCursorPosition())
      for i = 0, noteCount - 1 do
          local _, _, _, startppqpos, _, _, _, _ = reaper.MIDI_GetNote(take, i)
          local timeDiff = math.abs(startppqpos - cursorPos)
          if timeDiff < minTimeDiff then
              minTimeDiff = timeDiff
              targetNoteIndex = i
          end
      end
  end

  -- Select the target note if found
  if targetNoteIndex then
      reaper.MIDI_SelectAll(take, false)
      reaper.MIDI_SetNote(take, targetNoteIndex, true, nil, nil, nil, nil, nil, nil)
  end

  reaper.MIDI_Sort(take)
end

reaper.Undo_BeginBlock()
main()
reaper.Undo_EndBlock("Select Previous Note with Same or Closest Pitch", -1)
