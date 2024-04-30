--[[ label.lua
The label module contains functions supporting the addition of custom labels to the Mudlet map.

Although labels do not have a function in the final DikuMUD area files, they can be used during the
build process to mark key rooms or other points of interest.
--]]

-- Add a label string to the area map with a content-specific format style
function addLabel()
  local labelDirection = matches[2]
  local labelType = matches[3]
  local dX = 0
  local dY = 0
  -- Adjust the label position based on initial direction parameter for less after-placement adjustment
  dX, dY = getLabelPosition( labelDirection )

  -- Hang on to the rest in globals so we can nudge with WASD; confirm with 'F' and cancel with 'C'
  if labelType == "room" then
    labelText = formatLabel( CurrentRoomName )
  elseif labelType == "key" and lastKey > 0 then
    labelText = tostring( lastKey )
    lastKey = -1
  elseif labelType == "proc" then
    labelText = currentRoomData.roomSpec
  else
    labelText = formatLabel( matches[4] )
    -- Replace '\\n' in our label strings with a "real" newline; probably a better way to do this
    -- labelText = labelText:gsub( "\\\\n", "\n" )
  end
  labelArea = getRoomArea( CurrentRoomNumber )
  labelX = mX + dX
  labelY = mY + dY
  labelR, labelG, labelB, labelSize = getLabelStyle( labelType )
  if not labelSize then return end -- Return if type invalid
  labelID = createMapLabel( labelArea, labelText, labelX, labelY, mZ, labelR, labelG, labelB, 0, 0, 0, 0, labelSize, true,
    true, "Bitstream Vera Sans Mono", 255, 0 )

  enableKey( "Labeling" )
end

-- Bind to keys in "Labeling" category to fine-tune label positions between addLabel() and finishLabel()
-- e.g., W for adjustLabel( 'left' ), CTRL-W for adjustLabel( 'left', 0.025 ) for finer-tune adjustments
function adjustLabel( direction, scale )
  -- Adjust the default scale as needed based on your Map's zoom level, font size, and auto scaling preference
  scale = scale or 0.05
  deleteMapLabel( labelArea, labelID )
  if direction == "left" then
    labelX = labelX - scale
  elseif direction == "right" then
    labelX = labelX + scale
  elseif direction == "up" then
    labelY = labelY + scale
  elseif direction == "down" then
    labelY = labelY - scale
  end
  -- Round coordinates to the nearest scale value
  labelX = round( labelX, scale )
  labelY = round( labelY, scale )
  -- Recreate the label at the new position
  labelID = createMapLabel( labelArea, labelText, labelX, labelY, mZ, labelR, labelG, labelB, 0, 0, 0, 0, labelSize, true,
    true, "Bitstream Vera Sans Mono", 255, 0 )
end

-- Once we're finished placing a label, clean up the globals we used to keep track of it
function finishLabel( keepLabel )
  if not keepLabel then deleteMapLabel( labelArea, labelID ) end
  labelText, labelArea, labelX, labelY = nil, nil, nil, nil
  labelR, labelG, labelB, labelSize = nil, nil, nil, nil
  labelID = nil
  disableKey( "Labeling" )
end

-- Customize label style based on type categories
function getLabelStyle( labelType )
  if labelType == "area" then
    return 199, 21, 133, 10
  elseif labelType == "room" then
    return 65, 105, 225, 8
  elseif labelType == "note" then
    return 189, 183, 107, 8
  elseif labelType == "dir" then
    return 64, 224, 208, 8
  elseif labelType == "key" then
    return 127, 255, 0, 8
  elseif labelType == "warn" then
    return 255, 99, 71, 10
  elseif labelType == "proc" then
    return 85, 25, 110, 8
  end
  return nil, nil, nil, nil
end

-- For longer labels, insert newlines & attempt to center-justify
-- [TODO] Update this to support an arbitrary number of lines
function formatLabel( lbl )
  -- Adjust threshhold where labels will be broken with newline
  if #lbl <= 18 then
    return lbl
  end
  local midpoint = math.floor( #lbl / 2 )
  local spaceBefore = lbl:sub( 1, midpoint ):match( ".*%s()" )
  local spaceAfter = lbl:sub( midpoint + 1 ):match( "%s()" )

  -- Ignore labels with no spaces
  if not spaceBefore and not spaceAfter then
    return lbl
  end
  local newlinePos
  if spaceBefore then
    newlinePos = spaceBefore
  else
    newlinePos = midpoint + spaceAfter
  end
  -- Calculate padding to center-justify; indenting whichever line is shorter
  local firstLine = lbl:sub( 1, newlinePos - 1 )
  local secondLine = lbl:sub( newlinePos )
  local lineLengthDiff = #firstLine - #secondLine
  if lineLengthDiff < 0 then
    firstLine = string.rep( " ", math.floor( math.abs( lineLengthDiff ) / 2 ) ) .. firstLine
  else
    secondLine = string.rep( " ", math.floor( lineLengthDiff / 2 ) ) .. secondLine
  end
  return firstLine .. "\n" .. secondLine
end

-- Start new labels at a relative offset to minimize post-labeling adjustments
function getLabelPosition( direction )
  if direction == 'n' then
    return -0.5, 0.5
  elseif direction == 's' then
    return -0.5, -0.5
  elseif direction == 'e' then
    return 0.5, 0.5
  elseif direction == 'w' then
    return -2.5, 0.5 -- Labels are justified, so move them further left to compensate
  end
end

function alignLabels( id )
  local nc = MAP_COLOR["number"]
  local areaLabels = getMapLabels( id )
  local labelCount = #areaLabels
  local modCount = 0
  -- Ignore missing areas and ones w/ no labels
  if areaLabels and labelCount > 0 then
    -- getMapLabels is zero-based
    for lbl = 0, labelCount do
      local labelData = getMapLabel( id, lbl )
      if labelData then
        lT = labelData.Text
        lX = labelData.X
        lY = labelData.Y
        cecho( f "\n<royal_blue>{lT}<reset>: {nc}{lX}<reset>, {nc}{lY}<reset>" )
      end
    end
  end
end

-- For a given area, update labels from an old color to a new color and size
function updateLabelStyle( id, oR, oG, oB, nR, nG, nB, nS )
  local areaLabels = getMapLabels( id )
  local labelCount = #areaLabels
  local modCount = 0
  -- Ignore missing areas and ones w/ no labels
  if areaLabels and labelCount > 0 then
    -- getMapLabels is zero-based
    for lbl = 0, labelCount do
      local labelData = getMapLabel( id, lbl )
      if labelData then
        local lR = labelData.FgColor.r
        local lG = labelData.FgColor.g
        local lB = labelData.FgColor.b
        -- Check for labels w/ old color
        if lR == oR and lG == oG and lB == oB then
          local lT = labelData.Text
          -- Round the coordinates to the nearest 0.025
          local lX = round( labelData.X )
          local lY = round( labelData.Y )
          local lZ = round( labelData.Z )
          -- Delete existing label and create a new one in its place using the new color & size
          deleteMapLabel( id, lbl )
          createMapLabel( id, lT, lX, lY, lZ, nR, nG, nB, 0, 0, 0, 0, nS, true, true, "Bitstream Vera Sans Mono", 255, 0 )
          modCount = modCount + 1
        end
      end
    end
    updateMap()
  end
  return modCount
end

-- Globally update area labels from deep_pink to medium_violet_red
function updateAllAreaLabels()
  local areaID = 1
  local modCount = 0
  while worldData[areaID] do
    modCount = modCount + updateLabelStyle( areaID, 255, 69, 0, 255, 99, 71, 10 )
    areaID = areaID + 1
    -- Skip area 107; it's missing from our database
    if areaID == 107 then areaID = areaID + 1 end
  end
  cecho( f "\n<dark_orange>{modCount}<reset> room labels updated." )
end

-- Globally update room labels from orange-ish to royal_blue
function updateAllRoomLabels()
  local areaID = 1
  local modCount = 0
  while worldData[areaID] do
    modCount = modCount + updateLabelStyle( areaID, 255, 140, 0, 65, 105, 225, 8 )
    areaID = areaID + 1
    -- Skip area 107; it's missing from our database
    if areaID == 107 then areaID = areaID + 1 end
  end
  cecho( f "\n<dark_orange>{modCount}<reset> room labels updated." )
end

function viewLabelData()
  local areaLabels = getMapLabels( currentAreaNumber )
  for lbl = 0, #areaLabels do
    local labelData = getMapLabel( currentAreaNumber, lbl )
    if labelData then
      local lT = labelData.Text
      local lR = labelData.FgColor.r
      local lG = labelData.FgColor.g
      local lB = labelData.FgColor.b
      cecho( f "\n<royal_blue>{lT}<reset>: ({lR}, {lG}, {lB})" )
    end
  end
end
