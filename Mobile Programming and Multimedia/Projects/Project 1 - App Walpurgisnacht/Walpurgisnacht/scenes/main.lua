local composer = require( "composer" )
local loadsave = require( "loadsave" )

-- Random seed
math.randomseed( os.time() )
math.random( 1, 3 )
math.random( 1, 3 )

-- Go to the menu screen
composer.gotoScene( "scenes.start_menu" )
