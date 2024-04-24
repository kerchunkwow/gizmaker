# Gizmaker
Gizmaker leverages the mapping UI and API built in to the Mudlet client to accomplish its two primary objectives
- provision of a visual interface to allow area maps to be viewed and modified during the creation process
- functions necessary to export the data related to these areas into external files formatted and exported for inclusion within Gizmo DikuMUD

## Project Epics
The Gizmaker project comprises three major epics, or areas of functionality:
- a UI to allow for the visual creation and manipulation of an Area and all of its component parts
- one or more scripts responsible for translating Area data into Area files formatted to comply with Gizmo DikuMUD's standards for area development
- a SQLite database for the capture and management of data related to areas and their content.

### Epic 1: Area Creation
#### Mudlet Mapper UI
To save time developing a custom UI for Gizmaker, the project will leverage the existing functionality built in to the Mudlet client for the storage and organization of the area data. Mudlet features are designed to be used by players to map existing MUDs while using the client, but Gizmaker will repurpose these to allow for offline creation and exploration of an Area in progress. The existence of the Mapper and Mudlet client provide Gizmaker a variety of "free" off-the-shelf features for use in Area creation:
- 2D and 3D visualization of Areas in progress including Rooms, Exits, and Doors
- Automated and manual (via mouse or keyboard) manipulation of Area layouts
- Lua 5.1 integration allowing Lua scripts to assist with creating & updating Area data
- Use of custom coloring, highlighting, and labeling to track & visualize key Area features such as Room flags or Mob locations
- "Virtual Exploration" of in progress areas to aid in smoke testing and validating Area layouts prior to export
- Bulk modification of Area data via interactive multi-select or Lua scripting
#### UserData
Built in to the Mudlet mapping API are a variety of mechanisms to create and manage data tables associated with various components of an Area. These allow for the creation of an arbitrary set of key-value pairs that can be defined and expanded as needed to support Area creation. Utilizing these data tables, Gizmaker can manage all of the data necesarry to create the final DikuMUD-formatted output files.

A simple example of how these functions will serve to capture the necessary data:
```lua
setRoomUserData( 8908, [[description]], [[You are in a small room, evidently meant for guards]] )
```

The fundamental attributes of an Area that can be created and managed using the Mudlet client are: Areas (sometimes called Zones), Rooms, Exits, and Doors. More detailed definitions exist elsewhere in this README but in short an Area is made up of Rooms; Rooms are linked to one another by Exits; some of those Exits may be doors. Mudlet will allow for the creation and visual organization of these elements which should ease the burden of creating areas in a more traditional, text-only setting.
Beyond support for these basic components, Mudlet allows each Room to be extended with an arbitrary set of "User Data" which we will utilize to add additional details needed to define the Rooms. These User Data fields will be critical to populating Rooms with sufficient detail so they can be exported and used in a live DikuMUD environment. The User Data for a room is implemented as a simple key-value table.

### Epic 2: Export Areas for DikuMUD
In order to be successfully deployed into a live DikuMUD environment, data related to each area must be formatted to comply with a predefined standard for DikuMUD; this is a legacy standard which uses the presence of special characters and careful placement of newlines to allow a DikuMUD to properly parse and laod an area. Done by hand, this is difficult and error-prone and part of why creating areas for MUDs remains challenging today. The goal of Gizmaker is to abstract this burden into Lua and Python scripts which operate on the data within Mudlet to export files which adhere to the Diku formatting standards.

### Epic 3: Manage Area Data in gizmaker.db
While Mudlet provides its own data file standard for storing maps, Gizmaker will populate and utilize a SQLite database to hold all of the data related to areas. gizmaker.db will aid in the creation of the Map within Mudlet and provide a more standardized method for organizing and accessing the data. This database will then act as a source of data fro the export process; the export script will query data from the gizmaker.db database and output it into the DikuMUD area format.

## Map Creation Functions
Below is a breakdown of the core functionality necessary to permit players to create Areas using the Mudlet mapper. These will be implemented primarily in Lua 5.1 compatible scripts within Mudlet using custom developed and built-in functions to add, arrange, and evaluate data related to areas and their associated elements.

### Add Room

## Data Structure
Following is a detailed definition for all of the data structures needed to create a complete area.
### Area
Areas (sometimes called Zones) organize MUDs into locations that can be visited by players looking to fight enemies, explore, and gather treasure. Each area generally follows a specific theme or idea such as "The Tower of Sorcery" or "The Cursed Graveyard." From a data perspective, areas are relatively simple:
- id: Unique identifier for this area; in Gizmaker these can be standard incrementing integers, but the export must be prepared to translate these values into ones that get assigned to a specific MUD (areas must be integrated starting with available ids)
- name: The name or title of the area, like "The Great Desert" or "The City of Thalos."
- resetTime: Duration in minutes between resets or "repops" where the zone returns to its default state and repopulates with new enemies, etc.
- resetType: Controls the conditions under which the area will reset; some areas are limited to resetting only when empty for instance.
### Room
Areas are made up of an arbitrary number of rooms; a very small area may contain fewer than 20, while a very large one may comprise several hundred. The attributes of a room include:
- id: Unique identifier for the room; can use a standard set of increment unique id's initially, but eventually these values will need to be updated to correspond to values assigned to the area for inclusion in a specific MUD (areas must be incorporated starting at the first available room id)
- name: A short string capturing a concise description of the room such as "A Dank Prison Cell" or "A Verdant Meadow."
- description: A paragraph-style narrative that describes the room to players in terms of geographical features, environment, sounds & scents, etc.; This is what the player sees when they enter a room or issue a "look" command within the room itself. It is the way players understand where they are and what is around them. It is how areas communicate themes, mood, aesthetic, etc.

## Mudlet Reference
### Wikis & Guides
- Wiki Manual for the [Mudlet Mapper](https://wiki.mudlet.org/w/Manual:Mapper)
- Wiki Reference for [Mapper API](https://wiki.mudlet.org/w/Manual:Mapper_Functions)

Below are definitions and descriptions of built-in Mudlet functions which will be leveraged by Gizmaker in the creation and management of area data. Mudlet uses Lua 5.1 with custom support for f-string interpolation.
- `setRoomUserData( roomID, keyString, valueString )`: Add to a key-value table of data associated with a specific room; both key and value must be passed as strings.
- `addRoom(roomID)`: Creates a new room with the given ID, returns true if the room was successfully created; essentially creates an empty disconnected "stub" room which must be populated with data and connected via exits to an adjacent room.


