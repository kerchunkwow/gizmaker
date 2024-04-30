--[[ room.lua
This module implements data structures and functions necessary to create, manage, and export rooms
for the Gizmaker project.
--]]

-- This function is designed to make quickly adjusting room positions easier by "nudging" the current
-- room a single step in the specified direction.
-- @param dir string The direction to nudge the room
function nudgeRoom( dir )
  -- Normalize the direction to lower case to ensure case-insensitivity
  dir = dir:lower()

  -- Retrieve direction data from the DIR table
  local dirData = DIR[dir]

  -- Check for valid directions
  if dirData then
    -- Override the default magnitude of step -- it always nudges by 1
    Cx = Cx + (dirData.dx ~= 0 and dirData.dx / math.abs( dirData.dx ) or 0)
    Cy = Cy + (dirData.dy ~= 0 and dirData.dy / math.abs( dirData.dy ) or 0)
    Cz = Cz + (dirData.dz ~= 0 and dirData.dz / math.abs( dirData.dz ) or 0)
    -- Update the coordinates of the current room & redraw
    setRoomCoordinates( CurrentRoomNumber, Cx, Cy, Cz )
    updateMap()
  else
    cout( "Invalid direction provided to nudgeRoom: " .. dir )
  end
end

-- Basic "getters" and "setters" intended to be called primarily by aliases within the Mudlet client

function setRoomName( name )
  setRoomName( CurrentRoomNumber, name )
  updateMap()
end

function setRoomDescription( desc )
  setRoomUserData( CurrentRoomNumber, "description", desc )
  updateMap()
end
