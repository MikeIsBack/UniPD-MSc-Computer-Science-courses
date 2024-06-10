-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )

-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )

-- Random seed
math.randomseed( os.time() )
math.random( 1, 3 )
math.random( 1, 3 )

-- Go to the menu screen
composer.gotoScene( "scenes.start_menu" )
