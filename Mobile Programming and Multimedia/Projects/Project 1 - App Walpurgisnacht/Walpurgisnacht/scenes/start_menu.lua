local composer = require( "composer" )
local loadsave = require( "loadsave" )

local scene = composer.newScene()

local t_audio = {
  confirm
}

local t_buttontext = {
  volume, soundtrack
}

local function gotoScenarios()
  audio.play( t_audio.confirm )
  composer.removeScene( "scenes.scenarios1" )
  composer.gotoScene( "scenes.scenarios1" )
end

local function gotoIntro()
  audio.play( t_audio.confirm )
  composer.removeScene( "scenes.intro" )
  composer.gotoScene( "scenes.intro" )
end

local function gotoFacebookPage()
  audio.play( t_audio.confirm )
  system.openURL( "http://www.coronalabs.com" )
end

local function gotoCredits()
  audio.play( t_audio.confirm )
  composer.gotoScene( "scenes.credits" )
end

local function controlVolume()
  if audio.getVolume() > 0 then
    settings.volumeOn = false
    t_buttontext.volume.text = "Volume: OFF"
    audio.setVolume( 0.0 )
  else
    audio.play( t_audio.confirm )
    settings.volumeOn = true
    t_buttontext.volume.text = "Volume: ON "
    audio.setVolume( 0.5 )
  end
end

local function controlSoundtrack()
  if audio.getVolume( { channel=1 } ) > 0 then
    audio.play( t_audio.confirm )
    settings.soundtrackOn = false
    t_buttontext.soundtrack.text = "Musica: OFF"
    audio.setVolume( 0.0, { channel=1 } )
  else
    audio.play( t_audio.confirm )
    settings.soundtrackOn = true
    t_buttontext.soundtrack.text = "Musica: ON "
    audio.setVolume( 0.5, { channel=1 } )
  end
end

local function exit()
  loadsave.saveTable( settings, "settings.json" )
  os.exit()
end

settings = loadsave.loadTable( "settings.json" )
if settings == nil then
  print("first time")
  settings = {}
  settings.firstTime = true
  settings.currentScenario = 1
  settings.currentDream = 0
  settings.unlockedDream = 1
  settings.volumeOn = true
  settings.soundtrackOn = true
  loadsave.saveTable( settings, "settings.json" )
  settings = loadsave.loadTable( "settings.json" )
end

-- customer own music
if audio.supportsSessionProperty then
  audio.setSessionProperty( audio.MixMode, audio.AmbientMixMode )
end

-- android options
display.setStatusBar( display.HiddenStatusBar )
native.setProperty( "androidSystemUiVisibility", "immersiveSticky" )

-- create()
function scene:create( event )

  audio.reserveChannels( 1 )
  t_audio.confirm = audio.loadSound( "sounds/effects/confirm.mp3" )

  local sceneGroup = self.view

  local background = display.newImageRect( sceneGroup, "images/graphics/starting_menu.jpg", 570, 350 )
  background.x = display.contentCenterX
  background.y = display.contentCenterY

  local titleText = display.newText( sceneGroup, "Walpurgisnacht", display.contentCenterX + 75, 42, "Mikodacs.otf", 54 )
  titleText:setFillColor( 0, 0, 0 )

  redGradient = {
    type = "gradient",
    color1 = { 0.85, 0.16, 0.16, 0.9 },
    color2 = { 0.90, 0.43, 0.43, 0.8 },
    direction = "down"
  }

  local titleBox = display.newRect( sceneGroup, titleText.x, titleText.y, titleText.width + 14, titleText.height + 6 )
  titleBox.fill = redGradient
  titleBox:setStrokeColor( 0, 0, 0 )
  titleBox.strokeWidth = 3

  titleText:toFront()

  local function createButton( text, xpos, ypos, xsize, ysize, fontsize )
    local button = display.newImageRect( sceneGroup, "images/graphics/menu_button.png", xsize, ysize )
    button.x = xpos
    button.y = ypos
    local buttontext = display.newText( sceneGroup, text, button.x, button.y, "GosmickSans.ttf", fontsize )
    buttontext:setFillColor( 0, 0, 0 )
    return button, buttontext
  end

  local playButton = createButton( "Gioca", display.contentCenterX, 140, 150, 50, 30 )
  playButton:addEventListener( "tap", gotoScenarios )

  if settings.firstTime == false then
    local introButton = createButton( "Intro", display.contentCenterX - 200, 160, 110, 40, 18 )
    introButton:addEventListener( "tap", gotoIntro )
  end

  local facebookButton = createButton( "Facebook", display.contentCenterX - 200, 220, 110, 40, 18 )
  facebookButton:addEventListener( "tap", gotoFacebookPage )

  local creditsButton = createButton( "Crediti", display.contentCenterX - 200, 280, 110, 40, 18 )
  creditsButton:addEventListener( "tap", gotoCredits )

  local volumeButton

  volumeButton, t_buttontext.volume = createButton( "Volume: ON ", display.contentCenterX + 200, 165, 110, 40, 18 )
  volumeButton:addEventListener( "tap", controlVolume )

  local soundtrackButton

  soundtrackButton, t_buttontext.soundtrack = createButton( "Musica: ON ", display.contentCenterX + 200, 215, 110, 40, 18 )
  soundtrackButton:addEventListener( "tap", controlSoundtrack )

  local exitButton = createButton( "Esci", display.contentCenterX + 200, 280, 110, 40, 18 )
  exitButton:addEventListener( "tap", exit )

  if settings.volumeOn == true then
    t_buttontext.volume.text = "Volume: ON "
    audio.setVolume( 0.5 )
  else
    t_buttontext.volume.text = "Volume: OFF"
    audio.setVolume( 0.0 )
  end
  if settings.soundtrackOn == true then
    t_buttontext.soundtrack.text = "Musica: ON "
    audio.setVolume( 0.5, { channel=1 } )
  else
    t_buttontext.soundtrack.text = "Musica: OFF"
    audio.setVolume( 0.0, { channel=1 } )
  end

end

-- show()
function scene:show( event )

  sceneGroup = self.view
  local phase = event.phase

  if phase == "will" then
    if settings.volumeOn == true then
      t_buttontext.volume.text = "Volume: ON "
      audio.setVolume( 0.5 )
    else
      t_buttontext.volume.text = "Volume: OFF"
      audio.setVolume( 0.0 )
    end
    if settings.soundtrackOn == true then
      t_buttontext.soundtrack.text = "Musica: ON "
      audio.setVolume( 0.5, { channel=1 } )
    else
      t_buttontext.soundtrack.text = "Musica: OFF"
      audio.setVolume( 0.0, { channel=1 } )
    end
  elseif phase == "did" then

  end

end

-- scene event listener
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )

return scene
