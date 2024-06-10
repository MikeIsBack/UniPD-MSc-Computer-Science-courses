local composer = require( "composer" )
local loadsave = require( "loadsave" )

local scene = composer.newScene()

local t_audio = {
  dreaming
}

local function gotoScenarioDream()
  composer.removeScene( "scenes.s" .. settings.currentScenario .. "d" .. settings.currentDream )
  composer.gotoScene( "scenes.s" .. settings.currentScenario .. "d" .. settings.currentDream )
end

-- create()
function scene:create( event )

  local sceneGroup = self.view

  local dream_start = display.newImageRect( sceneGroup, "images/graphics/dream_start.png", 570, 320 )
  dream_start.x = display.contentCenterX
  dream_start.y = display.contentCenterY
  dream_start.fill.effect = "filter.swirl"
  dream_start.fill.effect.intensity = 0

  t_audio.dreaming = audio.loadSound( "sounds/effects/dreaming.mp3" )
  audio.play( t_audio.dreaming )

  transition.to( dream_start.fill.effect, { time=1600, delay=400, intensity=1, transition=easing.inSine } )
  transition.to( dream_start, { time=1000, delay=1000, alpha=0, onComplete=gotoScenarioDream } )

end

-- scene event listener
scene:addEventListener( "create", scene )

return scene
