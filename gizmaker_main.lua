-- Constants for use throughout Gizmaker

-- Table to allow for quick lookups & conversions related to cardinal directions;
-- Alter the step values to quickly adjust the default room spacing.
-- [TODO] Once we have more constants, these can be moved to their own file
local stepX, stepY, stepZ = 2, 2, 1

DIR                       = {
  n     = {name = "north", reverse = "south", dx = 0, dy = stepY, dz = 0},
  s     = {name = "south", reverse = "north", dx = 0, dy = -stepY, dz = 0},
  e     = {name = "east", reverse = "west", dx = stepX, dy = 0, dz = 0},
  w     = {name = "west", reverse = "east", dx = -stepX, dy = 0, dz = 0},
  u     = {name = "up", reverse = "down", dx = 0, dy = 0, dz = stepZ},
  d     = {name = "down", reverse = "up", dx = 0, dy = 0, dz = -stepZ},
  north = {name = "north", reverse = "south", dx = 0, dy = stepY, dz = 0},
  south = {name = "south", reverse = "north", dx = 0, dy = -stepY, dz = 0},
  east  = {name = "east", reverse = "west", dx = stepX, dy = 0, dz = 0},
  west  = {name = "west", reverse = "east", dx = -stepX, dy = 0, dz = 0},
  up    = {name = "up", reverse = "down", dx = 0, dy = 0, dz = stepZ},
  down  = {name = "down", reverse = "up", dx = 0, dy = 0, dz = -stepZ}
}

-- Some default values to use when creating new Map elements; these values will need to be modified by the
-- Builder and eventually can be used to check and validate that all stub content has been properly populated.
-- [TODO] As the list of global definitions grows, move them to their own file.
DefaultAreaName           = "The Gizmaker Sandbox"
DefaultRoomName           = "A Featureless Cube"

-- Coordinates to track the Builder's location within their area, allowing new rooms to be positioned properly.
-- These coordinates do not have meaning in the final DikuMUD file output, but are used by the Mudlet Mapper to
-- create the visual layout of the area. 0, 0, 0 is the center of each area map.
Cx, Cy, Cz                = 0, 0, 0

-- A table defining the minimum RNumber for each area by name; this could be populated in advance with assigned
-- RNumbers to ensure synchronicity between Gizmaker's numbering system and the final DikuMUD files (but this
-- isn't strictly necessary).
MinimumRNumber            = {
  ["The Gizmaker Sandbox"] = 444
}

-- Gizmaker will use a variety of globals to track the Builder's current location within an Area in progress to
-- permit for efficient creation as well as virtual exploration of existing content.
CurrentAreaNumber         = nil -- RNumber of the Builder's current area
CurrentAreaName           = nil -- Name of the Builder's current area
CurrentRoomNumber         = nil -- RNumber of the Builder's current room
CurrentRoomName           = nil -- Name of the Builder's current room
CurrentRoomData           = {}  -- Table holding getAllRoomUserData() for the Builder's current room

-- Many functions will be made easier if we track the previous location of the Builder in addition to their current.
PreviousRoomNumber        = nil -- RNumber of the Builder's previous room
PreviousRoomName          = nil -- Name of the Builder's previous room
PreviousRoomData          = {}  -- Table holding getAllRoomUserData() for the Builder's previous room

-- Invoked via alias to call the addArea() function and start a new build.
function aliasAddArea()
  CurrentAreaName = DefaultAreaName or trim( matches[2] )
  addArea( CurrentAreaName )
end

-- Adds a new area to the Builder's map, creates the first room, and updates the Builder's location.
-- @param [areaName] string The name of the new area
function addArea( areaName )
  CurrentAreaNumber = addAreaName( areaName )
  -- Exit if we couldn't create the area; usually because an area by this name already exists.
  if not CurrentAreaNumber then
    cout( "Error in addNewArea() for: {STR}{areaName}{RES}" )
  else
    cout( "Added new area: {STR}{areaName}{RES} ({NUM}{CurrentAreaNumber}{RES})" )
    addNewRoom()
  end
end

-- Adds a new room to the Builder's current area. If a direction is provided, coordinates for the
-- new room will be calculated based on the current location. This function also update the Builder's
-- location to the new room.
-- [TODO] A more robust implementation for adding new rooms would adapt to a wider range of parameters & options
-- and might not always update the Builder's location.
-- @param [roomName] string The name of the new room
-- @param [dir] string (optional) The direction we are traveling from our current location to create the new room
function addNewRoom( roomName, dir )
  -- Fetch the next available room ID; remember to define area minimums in the global table if
  -- you know them ahead of time.
  local roomID = nextRoomID()
  -- If no direction is supplied, assume we're creating the first/center room of a new area;
  -- otherwise, update coordinates based on the direction we traveled to get here.
  if not dir then
    Cx, Cy, Cz = 0, 0, 0
  else
    updateCoordinates( dir )
  end
  if not addRoom( roomID ) then
    cout( "Error adding room: {STR}{roomName}{RES} ({NUM}{nextRoomID}{RES})" )
  else
    -- Assign the room to the current area and update the Builder's location.
    setRoomArea( roomID, CurrentAreaNumber )
    setRoomName( roomID, roomName )
    setRoomCoordinates( roomID, Cx, Cy, Cz )
    setBuilderLocation( roomID )
  end
end

-- Invoked by directional commands in the Mudlet client, this function will either move the builder to an existing
-- room, or create a new room in the specified direction and link it to the current room; this default behavior
-- may need to be modified later to accommodate things like one-way exits, etc. but for now we assume two-way.
-- @param [dir] string The direction of travel (north, south, east, west, up, down)
function buildRoom( dir )
  local dest = getDest( dir )
  -- If an exit to an existing room is present, just go there, otherwise make a new room
  if dest then
    setBuilderLocation( dest )
    -- Update to the new room's coordinates; important here not to assume a perfect delta 'cause rooms can be
    -- manually relocated after being added to the map.
    Cx, Cy, Cz = getRoomCoordinates( CurrentRoomNumber )
  else
    -- Get the next available room ID & add a room with default name
    addNewRoom( DefaultRoomName, dir )

    -- Link the new current room with the previous room and vice-versa
    setExit( PreviousRoomNumber, CurrentRoomNumber, dir )
    setExit( CurrentRoomNumber, PreviousRoomNumber, reverse( dir ) )
  end
end

-- This function sets the Builder's current location and updates & redraws the map to reflect the change.
-- This function assumes the room and its containing area exist, so call this only once you've verified.
-- @param [roomID] number The ID of the room to set as the Builder's current location
function setBuilderLocation( roomID )
  PreviousRoomNumber = CurrentRoomNumber
  CurrentRoomNumber  = roomID
  PreviousRoomName   = CurrentRoomName
  CurrentRoomName    = getRoomName( CurrentRoomNumber )
  PreviousRoomData   = CurrentRoomData
  CurrentRoomData    = getAllRoomUserData( CurrentRoomNumber )
  CurrentAreaNumber  = getRoomArea( CurrentRoomNumber )
  CurrentAreaName    = getRoomAreaName( CurrentAreaNumber )
  centerview( CurrentRoomNumber )
  updateMap()
end

-- Updates the current coordinates based on the direction of travel
-- @param dir string The direction of movement (one of the keys in the DIR table)
function updateCoordinates( dir )
  -- Normalize the direction to lower case to ensure case insensitivity
  dir = dir:lower()

  -- Get data from the DIR table
  local dirData = DIR[dir]

  -- If the direction was valid, use the delta attributes from DIR to update coordinates
  if dirData then
    Cx = Cx + dirData.dx
    Cy = Cy + dirData.dy
    Cz = Cz + dirData.dz
  else
    cout( "updateCoordinates() received invalid direction: " .. dir )
  end
end

-- This function returns the next available room ID choosing a minimum value based on whether the current
-- area has a predefined minimum.
-- @return number The next available room ID
function nextRoomID()
  local min = MinimumRNumber[CurrentAreaName] or 1
  return createRoomID( min )
end

-- Given a direction, this function returns the room number of the destination room or nil if there is no exit/room.
-- @param dir string The direction of travel
function getDest( dir )
  local exits = getRoomExits( CurrentRoomNumber )
  if exits and exits[dir] then
    return exits[dir]
  else
    return nil
  end
end

-- Given a direction, return its reverse
-- @param dir string The direction to reverse
-- @return string The reverse direction
function reverse( dir )
  -- Normalize the direction to lower case to ensure case insensitivity
  dir = dir:lower()

  -- Get data from the DIR table
  local dirData = DIR[dir]

  -- If the direction was valid, return the reverse direction
  if dirData then
    return dirData.reverse
  else
    cout( "reverseDirection() received invalid direction: " .. dir )
  end
end

-- Function to fully delete all mapped content and restart the build process; not much practical application in
-- the final product, but will be useful during the development process to test new features & quickly correct
-- for mistakes.
function reset()
  cout( "Resetting map..." )
  local areas = getAreaTable()
  local rooms = getRooms()
  if areas then
    for name, id in pairs( areas ) do
      cout( "  Deleted Area: " .. name )
      deleteArea( id )
    end
  end
  if rooms then
    for id, room in pairs( rooms ) do
      cout( "  Deleted Room: " .. id )
      deleteRoom( id )
    end
  end
  updateMap()
end

-- This function is not intended for use, but demonstrates core functions of the Mudlet Mapper API which
-- will serve Gizmaker's goal of providing builders with a more efficient, intuitive interface for the
-- creation, maintenance, and eventual export of MUD area files.
function mudletAPIReference()
  -- addAreaName() adds a new area to the Mudlet Map and returns a unique ID; this ID may or may not match
  -- the official assigned ID of the area, because that must be determined by the MUD administrators
  -- based on availability. If a placeholder ID is used during the build process, it can be translated at
  -- export.
  local areaID = addAreaName( "The Library of Gizmaker" )

  -- createRoomID() fetches the next available room ID after the given minimum value; this is useful if you
  -- know ahead of time which room IDs you have been assigned by the MUD so your rooms will always be greater
  -- than this value as they are added. However, if you do NOT know this ahead of time you can use arbitrary
  -- IDs during the build process and they can be translated to the official IDs at export.
  local nextRoomID = createRoomID( 1000 )

  -- addRoom() creates a new "stub" with the given ID; returns true if successful; stub rooms have no assigned
  -- area and are not connected to any other rooms by default, so they will need to be given a home and
  -- connected to the map to avoid being "orphaned" in limbo.
  if not addRoom( nextRoomID ) then
    cout( "Error adding room #{nextRoomID}." )
  end
  -- setRoomArea() assigns a room with the given ID to an area with the given ID; this is the first step in "placing"
  -- a new room; unless it's the origin room of a completely new area, then it will need to be assigned coordinates and
  -- connected to an existing room in order to be useful.
  setRoomArea( nextRoomID, areaID )

  -- Gets the area ID of the area to which a room has been assigned; in this case, roomAreaID will be equal to areaID,
  -- or the ID of "The Library of Gizmaker."
  local roomAreaID = getRoomArea( nextRoomID )

  -- Despite its name, getRoomAreaName() cannot return the name of an area to which a room belongs given only the room ID,
  -- it must take an area ID. The Mudlet API acknowledges this naming discrepancy but maintains this legacy naming to avoid
  -- breaking existing scripts.
  local roomAreaName = getRoomAreaName( roomAreaID )

  -- Associate a key-value user data pair with a room; Gizmaker will use this to define
  -- a wide variety of properties for later export into the DikuMUD area files.
  setRoomUserData( nextRoomID, "sample_string_key", "sample_string_value" )
  setRoomUserData( nextRoomID, "sample_number_key", "sample_number_value" )

  -- User data is retrieved by room ID and key
  local thisString = getRoomUserData( nextRoomID, "sample_string_key" )

  -- Mudlet user data is stored in string format, so numbers must be converted where necessary
  local thisNumber = tonumber( getRoomUserData( nextRoomID, "sample_number_key" ) )

  -- getRoomExits() returns a table describing the exits from the room with the given ID; this is a key-value table mapping
  -- directions to the integer ID of the room to which they lead; a room with no exits will return an empty table.
  local exits = getRoomExits( nextRoomID )

  -- Example getRoomExits() return value:
  -- exits = {
  --   'west': 80
  --   'east': 78
  -- }

  -- roomExists() can test for the existence of a room prior to acting upon it
  if roomExists( 1001 ) then
    cout( "Room 1001 exists in the Mudlet map." )
  end
  -- updateMap() must be called before any changes to the map made from script are actually rendered, it should be included at
  -- the conclusion of any script sequence that modifies the map.
  updateMap()

  -- Similar to updateMap(), centerview() updates the Mapper UI itself to center on the room with the given ID, often used in
  -- conjunction with a "current" location to keep the builder's view centered on the room or area they're working on, but can
  -- also be used as a means to jump to other areas for specific reference purposes.
  centerview( nextRoomID )
end
