luaSQL = require( "luasql.sqlite3" )

-- Seed Lua's RNG
math.randomseed( os.time() )

function reloadGizmaker()
  -- Load our standard library
  runLuaFile( 'lib/lib_std.lua' )
end
