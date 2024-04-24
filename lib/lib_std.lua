-- Run or "load" an Lua file; this is the first function defined in the Mudlet client
-- to enable us to develop scripts external to the client and import them into a
-- Mudlet session.
function runLuaFile( file )
  local filePath = f '{homeDirectory}{file}'
  if lfs.attributes( filePath, "mode" ) == "file" then
    dofile( filePath )
  else
    cecho( f "\n{filePath}<reset> not found." )
  end
end
