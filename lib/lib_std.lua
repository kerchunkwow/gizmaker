---@diagnostic disable: cast-local-type, need-check-nil

-- Run or "load" an Lua file; this is the first function defined in the Mudlet client
-- to enable us to develop scripts external to the client and import them into a
-- Mudlet session.
function runLuaFile( file )
  local filePath = f '{HOME_PATH}{file}'
  if lfs.attributes( filePath, "mode" ) == "file" then
    dofile( filePath )
  else
    cecho( f "\n{filePath}<reset> not found." )
  end
end

-- Compile and execute a lua function directly from the command-line; used
-- throughout other scripts and in aliases as 'lua <command> <args>'
function runLuaLine()
  local args = matches[2]
  -- Try to compile an expression.
  local func, err = loadstring( "return " .. args )

  -- If that fails, try a statement.
  if not func then
    func, err = assert( loadstring( args ) )
  end
  -- If that fails, raise an error.
  if not func then
    error( err )
  end
  -- Create the function
  local runFunc =

      function ( ... )
        if not table.is_empty( {...} ) then
          display( ... )
        end
      end

  -- Call it
  runFunc( func() )
end

-- Called when sysPathChanged events fire on files which were registered by addFileWatchers()
function fileModifiedEvent( _, path )
  -- Throttle this event 'cause VS-Code extensions fire extra modifications with each save
  local fileModifiedDelay = 5 -- seconds between auto-reloads
  if not fileModifiedEventDelayed then
    fileModifiedEventDelayed = true
    tempTimer( fileModifiedDelay, [[fileModifiedEventDelayed = nil]] )
    -- If it's the Mudlet module that was changed, refresh the XML file
    -- nil all existing functions that reference this file as their source
    local function unloadFile( path )
      for k, v in pairs( _G ) do
        -- Don't 💀 ourselves
        if type( v ) == "function" and k ~= "fileModifiedEvent" then
          local functionInfo = debug.getinfo( v )
          local functionSource = functionInfo.source
          functionSource = functionSource:sub( 2 )
          if functionSource:match( path ) then
            _G[k] = nil
          end
        end
      end
    end
    unloadFile( path )
    -- Just reload the file; we know it's there since it had stuff in _G[]
    dofile( path )
  end
end

-- Print a formatted string to the main console
function cout( s )
  cecho( "\n" .. f( s ) )
end

-- Print a formatted string to the "Info" console
function iout( s )
  cecho( "info", "\n" .. f( s ) )
end

-- Trim leading/trailing whitespace from a string
function trim( s )
  if not s then return end
  return s:match( "^%s*(.-)%s*$" )
end

-- Output number char(s) in a color; useful e.g., to add padding to formatted output by printing
-- a series of <black> characters.
function fill( number, char, color )
  if not color then color = "<black>" end
  if not char then char = "." end
  return f "{color}" .. string.rep( char, number ) .. "<reset>"
end

-- Get a list of substrings by splitting a string at delimeter
function split( s, delim )
  local substrings = {}
  local from = 1
  local delimFrom, delimTo = string.find( s, delim, from )

  while delimFrom do
    table.insert( substrings, string.sub( s, from, delimFrom - 1 ) )
    from = delimTo + 1
    delimFrom, delimTo = string.find( s, delim, from )
  end
  table.insert( substrings, string.sub( s, from ) )

  return substrings
end

-- Feed the contents of a file line-by-line as if it came from the MUD
function feedFile( feedPath )
  local feedRate = 0.01
  local file = io.open( feedPath, "r" )

  local lines = file:lines()

  local function feedLine()
    local nextLine = lines()
    if nextLine then
      cfeedTriggers( nextLine )
      tempTimer( feedRate, feedLine )
    else
      file:close()
    end
  end

  feedLine()
end

-- Round n to the nearest s
function round( n, s )
  s = s or 0.05
  return math.floor( n / s + 0.5 ) * s
end

-- Ensure a value remains within a fixed range
function clamp( value, min, max )
  return math.max( min, math.min( max, value ) )
end

-- Clear all user windows
function clearScreen()
  -- Clear the main user/console window
  clearUserWindow()

  -- For each sub/child window, clear it and then print a newline to "flush" the buffer
  local userWindows = Geyser.windows
  for _, window in ipairs( userWindows ) do
    -- The Geyser.windows list appends 'Container' to window names but still seems to be the shortest/simplest way to get a list of all windows
    local trimmedName = window:gsub( "Container", "" )
    clearUserWindow( trimmedName )
    cecho( trimmedName, "\n" )
  end
end
