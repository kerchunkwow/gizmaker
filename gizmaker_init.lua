---@diagnostic disable: need-check-nil

HOME_PATH = 'C:/dev/mud/gizmaker/'

luaSQL = require( "luasql.sqlite3" )

math.randomseed( os.time() * 1000 + math.floor( os.clock() * 1000 ) )

-- Function to load the other project scripts; this mainly exists so this file is eligible for auto-reload
function loadLua()
  runLuaFile( 'config/config_colors.lua' )
  runLuaFile( 'lib/lib_std.lua' )
  runLuaFile( 'room.lua' )
  runLuaFile( 'gizmaker_main.lua' )
end

loadLua()

-- Register an event to listen for file modifications and reload scripts
registerAnonymousEventHandler( 'sysPathChanged', fileModifiedEvent )

-- After all scripts are loaded, add a watcher to every Lua file that defines at least one function. Along with
-- the event registered above, this will make sure any changes in external scripts are loaded by Mudlet.
-- Just be careful with where and how you define and initialize globals as they may be reset at reload unless you
-- explicitly prevent this.
local function addFileWatchers()
  -- Table to hold all of the filenames that have defined functions in the current interpreter
  local mySources = {}
  -- Use a custom local 'contains' since we're pissing around in _G[]
  local function gotSource( src )
    for _, source in pairs( mySources ) do
      if source == src then
        return true
      end
    end
    return false
  end
  for k, v in pairs( _G ) do
    -- If the source of the definition includes the home directory, it's one of ours
    if type( v ) == "function" then
      local functionInfo = debug.getinfo( _G[k] )
      local functionSource = functionInfo.source
      functionSource = functionSource:sub( 2 )
      local isCustom = functionSource:match( HOME_PATH )
      if isCustom and not gotSource( functionSource ) then
        table.insert( mySources, functionSource )
        removeFileWatch( functionSource )
        addFileWatch( functionSource )
      end
    end
  end
end
addFileWatchers()

local function printLogo( colorIndex, offset )
  local logoColors = {
    {fg = "<yellow_green>",  bg = "<dark_olive_green>"}, -- green
    {fg = "<royal_blue>",    bg = "<medium_blue>"},      -- blue
    {fg = "<tomato>",        bg = "<firebrick>"},        -- red
    {fg = "<gold>",          bg = "<dark_goldenrod>"},   -- yellow
    {fg = "<medium_purple>", bg = "<dark_violet>"},      -- purple
    {fg = "<dark_orange>",   bg = "<saddle_brown>"},     -- orange
  }

  -- Custom Colors for Gizmaker Logo
  local FC = "<ansi_light_black>"
  local logoColor = nil
  if colorIndex then
    logoColor = logoColors[colorIndex]
  else
    logoColor = logoColors[math.random( #logoColors )]
  end
  local LC = logoColor.fg -- Foreground Logo Text
  local SC = logoColor.bg -- Logo Text Dropshadow
  local RC = "<reset>"

  local rightLogo = f [[
    ]]

  local gizmakerLogo = f [[
{FC} _____                                                                     _____
{FC}( ___ )                                                                   ( ___ )
{FC} |   |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|   |
{FC} |   |                                                                     |   |
{FC} |   |    {LC}██████{SC}╗ {LC}██{SC}╗{LC}███████{SC}╗{LC}███{SC}╗   {LC}███{SC}╗ {LC}█████{SC}╗ {LC}██{SC}╗  {LC}██{SC}╗{LC}███████{SC}╗{LC}██████{SC}╗    {FC}|   |
{FC} |   |   {LC}██{SC}╔════╝ {LC}██{SC}║╚══{LC}███{SC}╔╝{LC}████{SC}╗ {LC}████{SC}║{LC}██{SC}╔══{LC}██{SC}╗{LC}██{SC}║ {LC}██{SC}╔╝{LC}██{SC}╔════╝{LC}██{SC}╔══{LC}██{SC}╗   {FC}|   |
{FC} |   |   {LC}██{SC}║  {LC}███{SC}╗{LC}██{SC}║  {LC}███{SC}╔╝ {LC}██{SC}╔{LC}████{SC}╔{LC}██{SC}║{LC}███████{SC}║{LC}█████{SC}╔╝ {LC}█████{SC}╗  {LC}██████{SC}╔╝   {FC}|   |
{FC} |   |   {LC}██{SC}║   {LC}██{SC}║{LC}██{SC}║ {LC}███{SC}╔╝  {LC}██{SC}║╚{LC}██{SC}╔╝{LC}██{SC}║{LC}██{SC}╔══{LC}██{SC}║{LC}██{SC}╔═{LC}██{SC}╗ {LC}██{SC}╔══╝  {LC}██{SC}╔══{LC}██{SC}╗   {FC}|   |
{FC} |   |   {SC}╚{LC}██████{SC}╔╝{LC}██{SC}║{LC}███████{SC}╗{LC}██{SC}║ ╚═╝ {LC}██{SC}║{LC}██{SC}║  {LC}██{SC}║{LC}██{SC}║  {LC}██{SC}╗{LC}███████{SC}╗{LC}██{SC}║  {LC}██{SC}║   {FC}|   |
{FC} |   |    {SC}╚═════╝ ╚═╝╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝   {FC}|   |
{FC} |   |   Area Creation Assistant for Gizmo DikuMUD                  v0.1   |   |
{FC} |___|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|___|
{FC}(_____)                                                                   (_____){RC}]]

  cecho( "\n" .. gizmakerLogo .. "\n" )
end

local logos = 0.5
local off = 1
for i = 0, 40 do
  local currentLogoTime = logos
  local currentOffset = off
  local currentColor = (math.floor( i / 10 ) % 6) + 1
  tempTimer( currentLogoTime, function ()
    clearScreen()
    printLogo( currentColor, currentOffset )
  end )
  logos = logos + 0.025
  off = off + 1
end
