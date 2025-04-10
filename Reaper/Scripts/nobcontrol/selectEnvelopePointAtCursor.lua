-- Select envelope points immediately left and right of edit cursor within selected automation item

-- Get the currently selected envelope
local envelope = reaper.GetSelectedEnvelope(0)
if not envelope then
    return
end

-- Get the edit cursor position in seconds
local cursor_pos = reaper.GetCursorPosition()

-- Get the number of points in the envelope
local num_points = reaper.CountEnvelopePoints(envelope)
if num_points == 0 then
    return
end

-- Find a selected automation item that contains the cursor, if any
local selected_ai = nil
local selected_ai_idx = -1
local ai_count = reaper.CountAutomationItems(envelope)
for ai_idx = 0, ai_count - 1 do
    local start_time = reaper.GetSetAutomationItemInfo(envelope, ai_idx, "D_POSITION", 0, false)
    local length = reaper.GetSetAutomationItemInfo(envelope, ai_idx, "D_LENGTH", 0, false)
    local end_time = start_time + length
    if cursor_pos >= start_time and cursor_pos <= end_time then
        selected_ai = { start_time = start_time, end_time = end_time }
        num_points = reaper.CountEnvelopePointsEx(envelope, ai_idx)
        selected_ai_idx = ai_idx
        break -- Use the first selected AI containing the cursor
    end    
end

-- Define a small epsilon for floating-point time comparison
local epsilon = 1e-6

-- Variables to store point indices
local exact_indices = {}  -- Points exactly at the cursor
local left_idx = -1       -- Point immediately to the left
local left_time = -math.huge
local right_idx = -1      -- Point immediately to the right
local right_time = math.huge

-- Identify relevant points
for idx = 0, num_points - 1 do
    local retval, time = reaper.GetEnvelopePointEx(envelope, selected_ai_idx, idx)
    if not retval then goto continue end

    -- Filter points: only consider points inside the selected AI if it exists
    if selected_ai then
        if time < selected_ai.start_time or time > selected_ai.end_time then
            goto continue -- Skip points outside the automation item
        end
    end

    -- Check if the point is at, before, or after the cursor
    if math.abs(time - cursor_pos) < epsilon then
        table.insert(exact_indices, idx)
    elseif time < cursor_pos then
        if time > left_time then
            left_idx = idx
            left_time = time
        end
    elseif time > cursor_pos then
        if time < right_time then
            right_idx = idx
            right_time = time
        end
    end
    ::continue::
end

-- Determine which points to select
local points_to_select = {}
if #exact_indices > 0 then
    -- If there are points exactly at the cursor, select them
    points_to_select = exact_indices
else
    -- Otherwise, select the immediate neighbors
    if left_idx ~= -1 then table.insert(points_to_select, left_idx) end
    if right_idx ~= -1 then table.insert(points_to_select, right_idx) end
end

-- Create a set for efficient selection lookup
local select_set = {}
for _, idx in ipairs(points_to_select) do
    select_set[idx] = true
end

-- Update the selection status of all points
reaper.Main_OnCommand(40331, 0)

for idx = 0, num_points - 1 do
    local should_select = select_set[idx] or false
    reaper.SetEnvelopePointEx(envelope, selected_ai_idx, idx, nil, nil, nil, nil, should_select, false)
end

-- Refresh the UI
reaper.Envelope_SortPoints(envelope)
reaper.UpdateArrange()