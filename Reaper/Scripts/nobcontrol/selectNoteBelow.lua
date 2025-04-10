--[[
ReaScript Name: Select Note Below (Time & Pitch Aware) Without Fallback
Description: In the MIDI editor, if one or more notes are selected, this script uses the earliest note (by start time)
             as a reference and looks for an unselected note that has a lower pitch than that reference note and that 
             starts at or before the reference time. If such a note exists, it becomes the new selection.
             If no candidate is found, the current selection remains unchanged.
             When no note is selected, it uses the edit cursor’s time and a default pitch (Middle C, 60) as reference.
Author: ChatGPT
Version: 1.0
--]]

local function main()
  -- Get active MIDI editor and its take.
  local editor = reaper.MIDIEditor_GetActive()
  if not editor then return end
  local take = reaper.MIDIEditor_GetTake(editor)
  if not take then return end

  local _, noteCount, _, _ = reaper.MIDI_CountEvts(take)

  local ref_time, ref_pitch
  local selectionExists = false

  -- Check if any note is selected.
  for i = 0, noteCount-1 do
    local retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
    if selected then
      selectionExists = true
      break
    end
  end

  if selectionExists then
    -- Use the earliest (leftmost) selected note as the reference.
    local earliest_time = math.huge
    for i = 0, noteCount-1 do
      local retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
      if selected and startppqpos < earliest_time then
        earliest_time = startppqpos
        ref_time = startppqpos
        ref_pitch = pitch
      end
    end
  else
    -- No note is selected: use the edit cursor's time and a default pitch (Middle C, 60) as reference.
    local cursorTime = reaper.GetCursorPosition()
    ref_time = reaper.MIDI_GetPPQPosFromProjTime(take, cursorTime)
    ref_pitch = 60
  end

  -- Look for an unselected note that has a lower pitch than ref_pitch and starts at or before ref_time.
  local candidateIndex = nil
  local minTimeDiff = math.huge

  for i = 0, noteCount-1 do
    local retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
    if (not selected) and (pitch < ref_pitch) and (startppqpos <= ref_time) then
      local timeDiff = ref_time - startppqpos
      if timeDiff < minTimeDiff then
        minTimeDiff = timeDiff
        candidateIndex = i
      end
    end
  end

  -- Only change the selection if a proper candidate was found.
  if candidateIndex then
    -- Clear current selection.
    for i = 0, noteCount-1 do
      local retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
      if selected then
        reaper.MIDI_SetNote(take, i, false, muted, startppqpos, endppqpos, chan, pitch, vel, false)
      end
    end
    -- Select the candidate note.
    local retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, candidateIndex)
    reaper.MIDI_SetNote(take, candidateIndex, true, muted, startppqpos, endppqpos, chan, pitch, vel, false)
    reaper.MIDI_Sort(take)
  end

  reaper.UpdateArrange()
end

reaper.Undo_BeginBlock()
main()
reaper.Undo_EndBlock("Select Note Below (Time & Pitch Aware) Without Fallback", -1)
