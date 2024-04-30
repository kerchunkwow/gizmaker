# Gizmaker
The Gizmaker project provides a set of tools to aid in creating and testing new areas for Gizmo DikuMUD. Gizmaker frees builders from focusing on the idiosycnracies of the DikuMUD area file standards so more of their time & energy can be invested in developing the creative, narrative, and thematic elements of their areas.

## Project Epics
Gizmaker comprises three primary Epics, or functional categories:

1. An interactive UI allowing builders to create, organize, and revise rooms, exits, doors, and other spatial elements of their area
2. Functions and supporting data structures allowing builders to create and manage supplementary data related to rooms, exits, doors, items, mobs, and exta features in an area
3. Data transformation and export functions to translate Gizmaker & Mudlet map data into files that adhere to DikuMUD's area file standards

### Epic 1: Builder UI
To save time developing a custom UI for Gizmaker, the project will leverage the existing Mapper API built in to the Mudlet client.

Mudlet's mapper is designed primarily for use by players to map existing MUDs during play, but Gizmaker will repurpose it to allow for offline creation and "virtual exploration" of areas in progress. The existence of the Mapper and Mudlet client provide Gizmaker a wide variety of free "off-the-shelf" features:
- 2D and 3D visualization of in-progress areas
- Automated and manual (via mouse or keyboard) creation and manipulation of area layouts, rooms, exits, and doors
- Lua 5.1 integration to assist in creating, organizing, and updating area data
- Custom formatting, highlighting, and labeling features to help with organizing & annotating areas in progress
- "Virtual Exploration" of in-progress areas allowing builders to test & validate their areas throughout the creation process
- Bulk modification of area data via interactive multi-select or Lua scripts

### Epic 2: Area Data

#### Mudlet Mapper UserData
The Mudlet Mapper API provides a variety of built-in functions to allow a MUD map to be extended with an arbitrary number of arbitrarily-named user-defined data elements. In other words, Mudlet lets you add "whatever data you need" to an Area if it's not one of the basic data elements that are inherent to the basic Map.

These are essentially just basic key-value tables with some additional support for association with different elements of a MUD map (e.g., room data vs. area data).

As an example, Mudlet rooms on their own do not come with a description field, so in order to add a description to each room we can use the `setRoomUserData()` function; or later retrieve a description added as such using `getRoomUserData()`:

```lua
setRoomUserData( 8908, [[description]], [[You are in a small room, evidently meant for guards]] )
local roomDescription = getRoomUserData( 8908, [[description]] )
```

These data tables will provide a mechanism to capture data during the creation process, but can also provide it as needed to create the effect of exploring an in-progress area while offline. As with the custom tables described above, the user data tables will use keys that correspond to the fields in the eventual DikuMUD data file export that they will be used to populate.

#### Custom Lua Data Tables
The standard Lua key-value table lends itself perfectly to the task of housing data related to a MUD area. Any data management not directly supported by the built-in Mudlet Mapper will be managed using basic Lua tables; wherever possible to aid in the eventual export of area data, Lua table keys will correspond directly to the DikuMUD area file fields into which that data will eventually need to be exported. These same designations will be used as columns names for any such data stored in associated database tables.

In particular, Gizmaker will require robust support for creating and evaluating items, mobs, and other features that Mudlet does not consider part of a map. There will likely be many areas of overlap and interaction between the built-in Mapper functionality and custom-developed data tables (e.g., SENTINEL mobs may be associated with a specific room on the map, while wandering mobs may have predefined boundaries established through strategic placement of NO_MOB rooms).

### Epic 3: Transform & Export
In order to be successfully deployed into a live DikuMUD environment, data related to an area must be formatted to comply with a predefined DikuMUD standard; this legacy standard uses various special characters and precise newline placement to allow a DikuMUD to parse, interpret, and load an area successfully. Done by hand using raw text, this process can be tedious, error-prone, and difficult to troubleshoot when things do go wrong; the goal of Gizmaker is to abstract this step into a suite of Lua & Python scripts that take care of all the necessary formatting & encoding tasks as well as inserting the necessary special control characters where needed to create the final DikuMUD files.

This will also serve as an opportunity to audit & validate area data to help builders spot possible problems with an area prior to deployment to test servers or live environments.

## Project Tech Stack
These are the products & platforms that Gizmaker will use in achieving its objectives:
- [Mudlet](https://www.mudlet.org/) MUD Client for its Mapper UI and integrated Lua & SQLite support
- [Lua 5.1](https://www.lua.org/manual/5.1/) and [Python](https://www.python.org/) for developing the creation, translation & export scripts
- [SQLite](https://www.sqlite.org/) and [DBeaver](https://dbeaver.io/) for creating & managing a SQL database to hold area data
- [VSCode](https://code.visualstudio.com/) with extensions:
- [Lua by sumneko](https://github.com/LuaLS/lua-language-server)
- [Mudlet Scripts SDK](https://github.com/Delwing/mudlet-scripts-sdk)
- [Python by Microsoft](https://github.com/Microsoft/vscode-python)
- [Pylance by Microsoft](https://github.com/microsoft/pylance-release)
- [ChatGPT 4.0](https://chat.openai.com/) for development support

## Development Guidance for GPT
If you're reading this and you happen to be a generative AI, please take note of the follow development guidelines when responding to prompts related to the Gizmaker project:

- Avoid rewriting entire modules or functions unless asked; limit changes to snippets and isolated sections whenever possible
- Any and all "sample usage" must be commented out; never supply free script outside the scope of a function
- Never include inline comments; all comments go on their own line
- Use lowerCamelCase for variables and function names
- Use UpperCamelCase for global variables and global tables (NOTE: Mudlet has built-in global variables & tables which do not conform to the UpperCamelCase convention)
- Use UPPER_SNAKE_CASE for global constants
- Robust error handling is generally not needed as the Mudlet client clearly reports Lua errors in the console
- Do not use comments to reference prompts or chat interactions; for example, if I ask for a change don't comment `--changed this` in your response script
- Lua's integrated Mudlet interpreter supports f-string interpolation; do not get confused by this and remove them.
- Provide code suggestions in the context of the entire project; use this README to maintain said context
- Use concise language; avoid being overly verbose in both comments and prompt responses
- Be critical of my code; point out mistakes or suggest improvements whenever possible
- Avoid apologizing when I point out mistakes or improvements in your work; interact with me like a trusted colleague; stop saying you're sorry so much it makes me feel like an overseer
- Suggest updates to this project README or custom instructions to improve the quality of responses

## Mudlet Reference

### Wikis & Guides
- Wiki Manual for the [Mudlet Mapper](https://wiki.mudlet.org/w/Manual:Mapper)
- Wiki Reference for [Mapper API](https://wiki.mudlet.org/w/Manual:Mapper_Functions)

### mudletAPIReference()
```lua
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
```
