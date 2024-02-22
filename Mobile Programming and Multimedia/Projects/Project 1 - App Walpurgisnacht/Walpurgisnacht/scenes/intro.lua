local composer = require( "composer" )
local loadsave = require( "loadsave" )

local scene = composer.newScene()

local sceneGroup

local t_audio = {
  soundtrack, soundtrackPlay, footstep
}

local function gotoIntroDreaming()
  if settings.firstTime == false then
    loadsave.saveTable( settings, "settings.json" )
    composer.removeScene( "scenes.dreaming" )
    composer.gotoScene( "scenes.start_menu" )
  else
    settings.currentScenario = 1
    settings.currentDream = 1
    loadsave.saveTable( settings, "settings.json" )
    composer.removeScene( "scenes.dreaming" )
    composer.gotoScene( "scenes.dreaming" )
  end
end

local intro = {
  "Ogni anno, durante la Walpurgisnacht, le streghe rinnovano il proprio patto con il Diavolo.",
  "Per questo motivo, vagano alla ricerca di sacrifici umani.",
  "...",
  "I famigli delle streghe, gli Incubi, invadono i sogni delle persone.",
  "Le indeboliscono con la paura per poi rapirle.",
  "...",
  "Solo tu puoi impedire che ciò accada.",
  "..."
}
local written = {}
local options = {}

local function writeParagraph( options )
  local textField_w = display.newText( options )
  textField_w.alpha = 0
  textField_w.anchorX = 0
  transition.fadeIn( textField_w, { time=500 } )

  local textField_r = display.newText( options )
  textField_r.alpha = 0
  textField_r.anchorX = 0
  textField_r:setTextColor( 0.84, 0.33, 0.33 )
  transition.fadeIn( textField_r, { time=1200, delay=2500 } )
  transition.fadeOut( textField_w, { time=1200, delay=2500 } )
  return textField_r
end

local function intro_end()
  audio.play( t_audio.footstep )
  Runtime:removeEventListener( "tap", intro_end )
  transition.fadeOut( written[7], { time=500 } )
  transition.fadeOut( written[8], { time=500 } )
  timer.performWithDelay( 1500, gotoIntroDreaming )
end

local function tap_p8()
  options = {
    text = intro[8],
    x = display.contentCenterX + 245,
    y = display.contentCenterY + 130,
    width = 100,
    height = 50,
    fontSize = 50,
    font = "GosmickSans.ttf",
    align = "left"
  }
  written[8] = display.newText( options )
  written[8].anchorX = 0
  written[8]:setTextColor( 0.84, 0.33, 0.33 )
  Runtime:addEventListener( "tap", intro_end )
end

local function intro_p7()
  audio.play( t_audio.footstep )
  Runtime:removeEventListener( "tap", intro_p7 )
  transition.fadeOut( written[4], { time=500 } )
  transition.fadeOut( written[5], { time=500 } )
  transition.fadeOut( written[6], { time=500 } )
  options = {
    text = intro[7],
    x = 0,
    y = display.contentCenterY - 50,
    width = 480,
    height = 100,
    fontSize = 24,
    font = "GosmickSans.ttf",
    align = "left"
  }
  written[7] = writeParagraph( options )
  timer.performWithDelay( 3200, tap_p8 )
end

local function tap_p6()
  options = {
    text = intro[6],
    x = display.contentCenterX + 245,
    y = display.contentCenterY + 130,
    width = 100,
    height = 50,
    fontSize = 50,
    font = "GosmickSans.ttf",
    align = "left"
  }
  written[6] = display.newText( options )
  written[6].anchorX = 0
  written[6]:setTextColor( 0.84, 0.33, 0.33 )
  Runtime:addEventListener( "tap", intro_p7 )
end

local function intro_p5()
  options = {
    text = intro[5],
    x = 0,
    y = display.contentCenterY + 90,
    width = 480,
    height = 200,
    fontSize = 24,
    font = "GosmickSans.ttf",
    align = "left"
  }
  written[5] = writeParagraph( options )
  timer.performWithDelay( 3600, tap_p6 )
end

local function intro_p4()
  audio.play( t_audio.footstep )
  Runtime:removeEventListener( "tap", intro_p4 )
  transition.fadeOut( written[1], { time=500 } )
  transition.fadeOut( written[2], { time=500 } )
  transition.fadeOut( written[3], { time=500 } )
  options = {
    text = intro[4],
    x = 0,
    y = display.contentCenterY - 50,
    width = 480,
    height = 100,
    fontSize = 24,
    font = "GosmickSans.ttf",
    align = "left"
  }
  written[4] = writeParagraph( options )
  timer.performWithDelay( 2500, intro_p5 )
end

local function tap_p3()
  options = {
    text = intro[3],
    x = display.contentCenterX + 245,
    y = display.contentCenterY + 130,
    width = 100,
    height = 50,
    fontSize = 50,
    font = "GosmickSans.ttf",
    align = "left"
  }
  written[3] = display.newText( options )
  written[3].anchorX = 0
  written[3]:setTextColor( 0.84, 0.33, 0.33 )
  Runtime:addEventListener( "tap", intro_p4 )
end

local function intro_p2()
  options = {
    text = intro[2],
    x = 0,
    y = display.contentCenterY + 40,
    width = 480,
    height = 100,
    fontSize = 24,
    font = "GosmickSans.ttf",
    align = "left"
  }
  written[2] = writeParagraph( options )
  timer.performWithDelay( 3400, tap_p3 )
end

local function intro_p1()
  t_audio.soundtrackPlay = audio.play( t_audio.soundtrack, { channel=1, loops=-1, fadein=5000 } )
  options = {
    text = intro[1],
    x = 0,
    y = display.contentCenterY - 50,
    width = 480,
    height = 100,
    fontSize = 24,
    font = "GosmickSans.ttf",
    align = "left"
  }
  written[1] = writeParagraph( options )
  timer.performWithDelay( 2500, intro_p2 )
end

-- create()
function scene:create( event )

  t_audio.soundtrack = audio.loadStream( "sounds/soundtracks/howling_wind.mp3" )

  t_audio.footstep = audio.loadSound( "sounds/effects/footstep.mp3" )

end

-- show()
function scene:show( event )

  sceneGroup = self.view
  local phase = event.phase

  if phase == "will" then

  elseif phase == "did" then
    sceneGroup.alpha = 0
    transition.fadeIn( sceneGroup, { time=500, onComplete=intro_p1 } )
  end

end

-- hide()
function scene:hide( event )

  sceneGroup = self.view
  local phase = event.phase

  if phase == "will" then
    audio.stop( t_audio.soundtrackPlay )
    audio.dispose( t_audio.soundtrack )
    t_audio.soundtrackPlay = nil
    t_audio.soundtrack = nil
    transition.fadeOut( sceneGroup, { time=500 } )
    settings.firstTime = false
  elseif phase == "did" then

  end

end

-- scene event listener
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )

return scene
