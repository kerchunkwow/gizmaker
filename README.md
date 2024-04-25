# Gizmaker
The Gizmaker project seeks to provide a set of tools and features to aid in the process of creating new areas for Gizmo DikuMUD. Ideally, Gizmaker should free builders to focus less on the idiosycnracies of DikuMUD area file standards and more on the creative & narrative aspects of area design and construction.

## Project Epics
Gizmaker comprises three primary Epics, or areas of intended functionality:

1. An interactive UI allowing buildings to create, organize, and maintain Area layouts throughout the build process
2. Features allowing builders to create and maintain data describing their areas' mobs, items, and extra features
3. Functions to transform area data and export it into files conforming to the predefined standards for inclusion in Gizmo DikuMUD

### Epic 1: Builder UI
To save time developing a custom UI for Gizmaker, the project will leverage the existing Mapper features built in to the Mudlet client for the storage and organization of area data.

Mudlet's mapper is primarily designed for use by players to map existing MUDs during play, but Gizmaker will repurpose it to allow for offline creation and exploration. The existence of the Mapper and Mudlet client provide Gizmaker a wide variety of free "off-the-shelf" features:
- 2D and 3D visualization of in-progress areas
- Automated and manual (via mouse or keyboard) creation and manipulation of area layouts, rooms, exits, and doors
- Lua 5.1 integration to assist in creating, organizing, and updating area data
- Custom formatting, highlighting, and labeling features to allow for thorough annotation of area features
- "Virtual Exploration" of in-progress areas allowing builders to test & validate their areas throughout the creation process
- Bulk modification of area data via interactive multi-select or Lua scrips

### Epic 2: Area Data

#### Lua Data
The standard Lua key-value table lends itself perfectly to the task of housing data related to a MUD area. Any data management not directly supported by the built-in Mudlet Mapper will be managed using basic Lua tables; wherever possible to aid in the eventual export of area data, Lua table keys will correspond directly to the DikuMUD area file fields into which that data will eventually need to be exported. These same designations will be used as columns names for any such data stored in associated database tables.

#### Mapper UserData
The Mudlet Mapper API provides a variety of built-in functions to allow a MUD map to be extended with an arbitrary number of arbitrarily-named user-defined data elements. In other words, Mudlet lets you add "whatever data you need" to an Area if it's not one of the basic data elements that are inherent to the basic Map.

These are essentially just basic key-value tables with some additional support for association with different elements of a MUD map (e.g., room data vs. area data).

As an example, Mudlet rooms on their own do not come with a description field, so in order to add a description to each room we can use the `setRoomUserData()` function; or later retrieve a description added as such using `getRoomUserData()`:

```lua
setRoomUserData( 8908, [[description]], [[You are in a small room, evidently meant for guards]] )
local roomDescription = getRoomUserData( 8908, [[description]] )
```

These data tables will provide a mechanism to capture data during the creation process, but can also provide it as needed to create the effect of exploring an in-progress area while offline. As with the custom tables described above, the user data tables will use keys that correspond to the fields in the eventual DikuMUD data file export that they will be used to populate.

### Epic 3: Transform & Export
In order to be successfully deployed into a live DikuMUD environment, data related to an area must be formatted to comply with a predefined standard for DikuMUD; this legacy standard uses various special characters and careful newline placement to allow a DikuMUD to parse, interpret, and load an area. Done by hand using raw text editors, this process can be tedious, error-prone, and difficult to troubleshoot when things do go wrong; the goal of Gizmaker is to abstract this step "behind the scenes" into a suite of Lua & Python scripts that take care of the necessary formatting & encoding tasks as well as inserting the necessary special control characters where needed to create the final DikuMUD files.

## Project Tech
These are the technology products & platforms that will be used to develop & support the Gizmaker project:
- [Mudlet](https://www.mudlet.org/) MUD Client for its Mapper UI and integrated Lua & SQLite support
- [Lua 5.1](https://www.lua.org/manual/5.1/) and [Python](https://www.python.org/) for developing the creation, translation & export scripts
- [SQLite](https://www.sqlite.org/) and [DBeaver](https://dbeaver.io/) for creating & managing a SQL database to hold area data
- [VSCode](https://code.visualstudio.com/) with extensions:
- [Lua by sumneko](https://github.com/LuaLS/lua-language-server)
- [Mudlet Scripts SDK](https://github.com/Delwing/mudlet-scripts-sdk)
- [Python by Microsoft](https://github.com/Microsoft/vscode-python)
- [Pylance by Microsoft](https://github.com/microsoft/pylance-release)
- [ChatGPT 4.0](https://chat.openai.com/) for development assistance

## Development Guidance for GPT
If you're a generative AI model reviewing this README, the following is for you. Please follow these guidelines when writing script and responding to prompts:

- Avoid rewriting entire modules or functions unless asked; limit changes to snippets whenever possible
- Provide all "example usage" as commented script; never provide script including "free script" outside the scope of a function
- Do not include inline comments; all comments go on their own line
- Use lowerCamelCase for variables and function names
- Use UpperCamelCase for global variables and global tables (NOTE: Mudlet has built-in global variables & tables which do not conform to the UpperCamelCase convention)
- Use UPPER_SNAKE_CASE for global constants
- Error handling is generally not needed as the Mudlet client clearly reports Lua errors in the console
- Do not use comments to refer to our chat interactions; for example, if I ask for a change don't comment `--changed this`
- Lua's integrated Mudlet interpreter supports f-string interpolation; do not get confused by this and remove them.

## Mudlet Reference
### Wikis & Guides
- Wiki Manual for the [Mudlet Mapper](https://wiki.mudlet.org/w/Manual:Mapper)
- Wiki Reference for [Mapper API](https://wiki.mudlet.org/w/Manual:Mapper_Functions)

