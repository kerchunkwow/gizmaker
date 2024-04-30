-- Configure the "Custom Environments" used by Mudlet to determine the style of rooms in the Map
function defineCustomEnvColors()
  customColorsDefined = true
  setCustomEnvColor( COLOR_DEATH, 255, 99, 71, 255 )     -- <tomato>
  setCustomEnvColor( COLOR_CLUB, 70, 40, 115, 255 )      -- <medium_slate_blue>
  setCustomEnvColor( COLOR_INSIDE, 98, 62, 30, 255 )     -- custom rusty-brown
  setCustomEnvColor( COLOR_FOREST, 50, 65, 30, 255 )     -- custom dark green
  setCustomEnvColor( COLOR_MOUNTAINS, 120, 90, 90, 255 ) -- custom rosy-grey
  setCustomEnvColor( COLOR_CITY, 98, 88, 98, 255 )       -- dim purple/grey
  setCustomEnvColor( COLOR_WATER, 70, 130, 180, 255 )    -- <steel_blue>
  setCustomEnvColor( COLOR_FIELD, 107, 142, 35, 255 )    -- <olive_drab>
  setCustomEnvColor( COLOR_HILLS, 85, 105, 45, 255 )     -- custom green/brown
  setCustomEnvColor( COLOR_DEEPWATER, 25, 25, 110, 255 ) -- custom navy
  setCustomEnvColor( COLOR_PROC, 40, 100, 100, 255 )     -- custom dark cyan
  setCustomEnvColor( COLOR_OVERLAP, 250, 0, 250, 255 )   -- not used
  setCustomEnvColor( COLOR_SHOP, 50, 50, 20, 255 )
  roomColors = getCustomEnvColorTable()
  updateMap()
end

-- Set the color of the current Room on the map based on terrain type or attributes
function setRoomStyle( id )
  --local id = CurrentRoomNumber
  local roomFlags = getRoomUserData( id, "roomFlags" )
  local roomSpec = tonumber( getRoomUserData( id, "roomSpec" ) )
  local roomType = getRoomUserData( id, "roomType" )
  -- Check if 'DEATH' is present in roomFlags
  if (roomFlags and string.find( roomFlags, "DEATH" )) then
    unHighlightRoom( id )
    setRoomEnv( id, COLOR_DEATH )
    setRoomChar( id, "💀 " )
    lockRoom( id, true ) -- Lock this room so it won't ever be used for speedwalking
  elseif roomSpec > 0 then
    unHighlightRoom( id )
    setRoomEnv( id, COLOR_PROC )
    setRoomChar( id, "📁 " )
    if roomFlags and string.find( roomFlags, "CLUB" ) then
      cecho( f "\n\n<deep_pink>WARNING: {id} with PROC flag and CLUB flag<reset>\n\n" )
    end
  elseif roomFlags and string.find( roomFlags, "CLUB" ) then
    unHighlightRoom( id )
    setRoomEnv( id, COLOR_CLUB )
    setRoomChar( id, "💤" )
  else
    -- Check roomType and set color accordingly
    local roomTypeToColor = {
      ["Inside"]    = COLOR_INSIDE,
      ["Forest"]    = COLOR_FOREST,
      ["Mountains"] = COLOR_MOUNTAINS,
      ["City"]      = COLOR_CITY,
      ["Water"]     = COLOR_WATER,
      ["Field"]     = COLOR_FIELD,
      ["Hills"]     = COLOR_HILLS,
      ["Deepwater"] = COLOR_DEEPWATER
    }

    local color = roomTypeToColor[roomType]
    setRoomEnv( id, color )
  end
  updateMap()
end

-- Print a message w/ a tag denoting it as coming from our Mapper script
function mapInfo( message )
  cecho( f "\n  [<peru>M<reset>] {message}" )
end

-- Call setRoomStyle for all rooms in the MUD (kind of a global reset/refresh)
local function styleAllRooms()
  local allRooms = getRooms()
  for id, name in pairs( allRooms ) do
    setRoomStyle( id )
  end
end

-- Create a new room in the Mudlet; by default operates on the "current" room being the one you just arrived in;
-- passing dir and id will create a room offset from the current room (which no associated user data)
function createRoom( dir, id )
  if not customColorsDefined then defineCustomEnvColors() end
  local newRoomNumber = id or currentRoomNumber
  local nX, nY, nZ = mX, mY, mZ
  if dir == "east" then
    nX = nX + 1
  elseif dir == "west" then
    nX = nX - 1
  elseif dir == "north" then
    nY = nY + 1
  elseif dir == "south" then
    nY = nY - 1
  elseif dir == "up" then
    nZ = nZ + 1
  elseif dir == "down" then
    nZ = nZ - 1
  end
  -- Create a new room in the Mudlet mapper in the Area we're currently mapping
  addRoom( newRoomNumber )
  if currentAreaNumber == 115 or currentAreaNumber == 116 then
    currentAreaNumber = 115
    currentAreaName = 'Undead Realm'
  end
  setRoomArea( newRoomNumber, currentAreaName )
  setRoomCoordinates( currentRoomNumber, nX, nY, nZ )

  if not dir and not id then
    setRoomName( newRoomNumber, currentRoomData.roomName )
    setRoomUserData( newRoomNumber, "roomVNumber", currentRoomData.roomVNumber )
    setRoomUserData( newRoomNumber, "roomType", currentRoomData.roomType )
    setRoomUserData( newRoomNumber, "roomSpec", currentRoomData.roomSpec )
    setRoomUserData( newRoomNumber, "roomFlags", currentRoomData.roomFlags )
    setRoomUserData( newRoomNumber, "roomDescription", currentRoomData.roomDescription )
    setRoomUserData( newRoomNumber, "roomExtraKeyword", currentRoomData.roomExtraKeyword )
  else
    setRoomName( newRoomNumber, tostring( id ) )
  end
  setRoomStyle()
end

function clearCharacters()
  allRooms = getRooms()
  for id, name in pairs( allRooms ) do
    setRoomChar( id, "" )
  end
end

-- Display the properties of an exit for mapping and validation purposes; displayed when I issue a virtual "look <direction>" command
function inspectExit( direction )
  local fullDirection
  for dir, num in pairs( DIRECTIONS ) do
    if DIRECTIONS[direction] == num and #dir > 1 then
      fullDirection = dir
      break
    end
  end
  for _, exit in ipairs( currentRoomData.exits ) do
    if exit.exitDirection == fullDirection then
      local ec      = MAP_COLOR["exitDir"]
      local es      = MAP_COLOR["exitStr"]
      local esp     = MAP_COLOR["exitSpec"]
      local nc      = MAP_COLOR["number"]

      local exitStr = f "The {ec}{fullDirection}<reset> exit: "
      if exit.exitKeyword and #exit.exitKeyword > 0 then
        exitStr = exitStr .. f "\n  keywords: {es}{exit.exitKeyword}<reset>"
      end
      local isSpecial = false
      if (exit.exitFlags and exit.exitFlags ~= -1) or (exit.exitKey and exit.exitKey ~= -1) then
        isSpecial = true
        exitStr = exitStr ..
            (exit.exitFlags and exit.exitFlags ~= -1 and f "\n  flags: {esp}{exit.exitFlags}<reset>" or "") ..
            (exit.exitKey and exit.exitKey ~= -1 and f "\n  key: {nc}{exit.exitKey}<reset>" or "")
        if exit.exitKey and exit.exitKey > 0 then
          lastKey = exit.exitKey
        end
      end
      if exit.exitDescription and #exit.exitDescription > 0 then
        exitStr = exitStr .. f "\n  description: {es}{exit.exitDescription}<reset>"
      end
      cecho( f "\n{exitStr}" )
      return
    end
  end
  cecho( f "\n{MAP_COLOR['roomDesc']}You see no exit in that direction.<reset>" )
end

-- Get Exits from room with the given roomRNumber
function getExitData( roomRNumber )
  local roomData = getRoomData( roomRNumber )
  return roomData and roomData.exits
end

function getAreaByRoom( roomRNumber )
  local areaRNumber = roomToAreaMap[roomRNumber]
  return getAreaData( areaRNumber )
end

function getAllRoomsByArea( areaRNumber )
  local areaData = getAreaData( areaRNumber )
  return areaData and areaData.rooms or {}
end

-- Good neighbors are those that have a corresponding return/reverse exit back to our current room; reposition those rooms near us
-- Bad neighbors have no return/reverse exit; cull those exits (remove them from the map and store them in the culledExits table)
function findNearestNeighbors()
  local currentExits = getRoomExits( currentRoomNumber )
  local rc = MAP_COLOR["number"]

  for dir, roomNumber in pairs( currentExits ) do
    if roomExists( roomNumber ) and roomNumber ~= currentRoomNumber then
      local reverseDir = REVERSE[dir]
      local neighborExits = getRoomExits( roomNumber )

      if neighborExits and neighborExits[reverseDir] == currentRoomNumber then
        -- Good neighbor: reposition
        repositionRoom( roomNumber, dir )
        local path = createWintin( {dir} )
        --cecho( f( "\n<cyan>{path}<reset> to room {rc}{roomNumber}<reset>" ) )
      elseif neighborExits and (not neighborExits[reverseDir] or neighborExits[reverseDir] ~= currentRoomNumber) then
        cecho( f "\nRoom {rc}{roomNumber}<reset> is bad neighbor to our <cyan>{dir}<reset>, consider <firebrick>culling<reset> it" )
        --cullExit( dir )
      end
    end
  end
end

-- Move a room to a location relative to our current location (mX, mY, mZ)
function repositionRoom( id, relativeDirection )
  if not id or not relativeDirection then return end
  local rc = MAP_COLOR["number"]
  local mc = "<medium_orchid>"
  local rX, rY, rZ = mX, mY, mZ
  if relativeDirection == "north" then
    rY = rY + 1
  elseif relativeDirection == "south" then
    rY = rY - 1
  elseif relativeDirection == "east" then
    rX = rX + 1
  elseif relativeDirection == "west" then
    rX = rX - 1
  elseif relativeDirection == "up" then
    rZ = rZ + 1
  elseif relativeDirection == "down" then
    rZ = rZ - 1
  end
  cecho( f "\nRoom {rc}{id}<reset> is good neighbor to our <cyan>{relativeDirection}<reset>, moving to {mc}{rX}<reset>, {mc}{rY}<reset>, {mc}{rZ}<reset>" )
  setRoomCoordinates( id, rX, rY, rZ )
  updateMap()
end

-- The "main" display function to print the current room as if we just moved into it or looked at it
-- in the game; prints the room name, description, and exits.
function displayRoom( brief )
  brief = brief or true
  local rd = MAP_COLOR["roomDesc"]
  cecho( f "\n\n{getRoomString(currentRoomNumber, 2)}" )
  if not brief then
    cecho( f "\n{rd}{currentRoomData.roomDescription}<reset>" )
  end
  if currentRoomData.roomSpec > 0 then
    local renv = getRoomEnv( currentRoomNumber )
    if renv ~= COLOR_PROC then
      setRoomStyle()
    end
    cecho( f "\n\tThis room has a ~<ansi_light_yellow>special procedure<reset>~.\n" )
  end
  displayExits()
end

function setCurrentRoomxx( id )
  -- If this is the first Area or the id is outside the current Area, update Area before Room
  if currentAreaNumber < 0 or (not worldData[currentAreaNumber].rooms[id]) then
    setCurrentArea( roomToAreaMap[id] )
  end
  -- Save our lastRoomNumber for back-linking
  if currentRoomNumber > 0 then
    lastRoomNumber = currentRoomNumber
  end
  currentRoomData   = currentAreaData.rooms[id]
  currentRoomNumber = currentRoomData.roomRNumber
  currentRoomName   = currentRoomData.roomName
end

function setCurrentRoom( id )
  local roomNumber = tonumber( id )
  local roomArea = getRoomArea( roomNumber )
  roomArea = tonumber( roomArea )
  -- If this is the first Area or the id is outside the current Area, update Area before Room
  if currentAreaNumber ~= roomArea then
    setCurrentArea( roomArea )
  end
  --currentRoomData   = currentAreaData.rooms[id]
  currentRoomNumber = roomNumber                       -- currentRoomData.roomRNumber
  currentRoomName   = getRoomName( currentRoomNumber ) -- currentRoomData.roomName
  roomExits         = getRoomExits( currentRoomNumber )
end

function setCurrentAreax( id )
  currentAreaData   = worldData[id]
  currentAreaNumber = tonumber( currentAreaData.areaRNumber )
  currentAreaName   = tostring( currentAreaData.areaName )
end

function setCurrentArea( id )
  -- Store the room number of the "entrance" so we can easily reset to the start of an area when mapping
  -- firstAreaRoomNumber = id
  -- If we're leaving an Area, store information and report on the transition
  if currentAreaNumber > 0 then
    lastAreaNumber = currentAreaNumber
    lastAreaName   = currentAreaName
    mapInfo( f "Left: {areaTag()}" )
  end
  -- currentAreaData   = worldData[id]
  -- currentAreaNumber = tonumber( currentAreaData.areaRNumber )
  -- currentAreaName   = tostring( currentAreaData.areaName )
  currentAreaNumber = getRoomArea( id )
  currentAreaName   = getRoomAreaName( id )
  mapInfo( f "Entered {areaTag()}" )
  setMapZoom( 28 )
end

function setCurrentRoomNew( id )
  if currentAreaNumber < 0 or getRoomArea( id ) ~= currentAreaNumber then
    setCurrentArea( getRoomArea( id ) )
  end
end

function setCurrentAreaNew( id )
  -- If we're leaving an Area, store information and report on the transition
  if currentAreaNumber > 0 then
    lastAreaNumber = currentAreaNumber
    lastAreaName   = currentAreaName
    mapInfo( f "Left: {areaTag()}" )
  end
  currentAreaNumber = getRoomArea( id )
  currentAreaName   = getRoomAreaName( id )
  mapInfo( f "Entered {areaTag()}" )
  setMapZoom( 28 )
end

function setCurrentRoomxx( id )
  -- If this is the first Area or the id is outside the current Area, update Area before Room
  if currentAreaNumber < 0 or (not worldData[currentAreaNumber].rooms[id]) then
    setCurrentArea( roomToAreaMap[id] )
  end
  -- Save our lastRoomNumber for back-linking
  if currentRoomNumber > 0 then
    lastRoomNumber = currentRoomNumber
  end
  currentRoomData   = currentAreaData.rooms[id]
  currentRoomNumber = currentRoomData.roomRNumber
  currentRoomName   = currentRoomData.roomName
end

-- Display all exits of the current room as they might appear in the MUD
function displayExits( id )
  local exitData = currentRoomData.exits
  local exitString = ""
  local isFirstExit = true

  local minRNumber = currentAreaData.areaMinRoomRNumber
  local maxRNumber = currentAreaData.areaMaxRoomRNumber

  for _, exit in pairs( exitData ) do
    local dir = exit.exitDirection
    local to = exit.exitDest
    local ec = MAP_COLOR["exitDir"]
    local nc

    -- Determine the color based on exit properties
    if to == currentRoomNumber or (culledExits[currentRoomNumber] and culledExits[currentRoomNumber][dir]) then
      -- "Dim" the exit if it leads to the same room or has been culled (because several exits lead to the same destination)
      nc = "<dim_grey>"
    elseif not isInArea( to, currentAreaNumber ) then --to < minRNumber or to > maxRNumber then
      -- The room leads to a different area
      nc = MAP_COLOR["area"]
    else
      local destRoom = currentAreaData.rooms[to]
      if destRoom and destRoom.roomFlags:find( "DEATH" ) then
        nc = MAP_COLOR["death"]
      elseif (exit.exitFlags and exit.exitFlags ~= -1) or (exit.exitKey and exit.exitKey ~= -1) then
        nc = MAP_COLOR["exitSpec"]
      else
        nc = MAP_COLOR["number"]
      end
    end
    --local nextExit = f "{ec}{dir}<reset> ({nc}{to}<reset>)"
    local nextExit = f "{nc}{dir}<reset>)"
    if isFirstExit then
      exitString = f "{MAP_COLOR['exitStr']}Exits:  [" .. nextExit .. f "{MAP_COLOR['exitStr']}]<reset>"
      isFirstExit = false
    else
      exitString = exitString .. f " {MAP_COLOR['exitStr']}[<reset>" .. nextExit .. f "{MAP_COLOR['exitStr']}]<reset>"
    end
  end
  cecho( f "\n   {exitString}" )
end

-- Get new coordinates based on the existing global coordinates and the recent direction of travel
function getNextCoordinates( direction )
  local nextX, nextY, nextZ = mX, mY, mZ
  -- Increment by 2 to provide a buffer on the Map for moving rooms around (don't buffer in the Z dimension)
  if direction == "north" then
    nextY = nextY + 2
  elseif direction == "south" then
    nextY = nextY - 2
  elseif direction == "east" then
    nextX = nextX + 2
  elseif direction == "west" then
    nextX = nextX - 2
  elseif direction == "up" then
    nextZ = nextZ + 1
  elseif direction == "down" then
    nextZ = nextZ - 1
  end
  return nextX, nextY, nextZ
end

function setRoomStyleAlias()
  local roomStyle = matches[2]
  if roomStyle == "mana" then
    unHighlightRoom( currentRoomNumber )
    setRoomEnv( currentRoomNumber, COLOR_CLUB )
    setRoomChar( currentRoomNumber, "💤" )
  elseif roomStyle == "shop" then
    unHighlightRoom( currentRoomNumber )
    setRoomEnv( currentRoomNumber, COLOR_SHOP )
    setRoomChar( currentRoomNumber, "💰" )
    --setRoomCharColor( currentRoomNumber, 140, 130, 15, 255 )
  elseif roomStyle == "death" then
    unHighlightRoom( currentRoomNumber )
    setRoomEnv( currentRoomNumber, COLOR_DEATH )
    setRoomChar( currentRoomNumber, "💀 " )
    lockRoom( currentRoomNumber, true )
  elseif roomStyle == "proc" then
    unHighlightRoom( id )
    setRoomEnv( id, COLOR_PROC )
    setRoomChar( id, "📁 " )
  end
end
