local composer = require( "composer" )
local loadsave = require( "loadsave" )

local scene = composer.newScene()

local t_audio = {
  confirm, confirmnot
}

local function gotoDreaming( event )
  audio.play( t_audio.confirm )
  settings.currentScenario = 1
  settings.currentDream = event.target.dream
  loadsave.saveTable( settings, "settings.json" )
  composer.removeScene( "scenes.dreaming" )
  composer.removeScene( "scenes.s1d" .. event.target.dream )
  composer.gotoScene( "scenes.dreaming" )
end

local function gotoScenarios()
  audio.play( t_audio.confirmnot )
  composer.removeScene( "scenes.scenarios1" )
  composer.gotoScene( "scenes.scenarios1" )
end

-- create()
function scene:create( event )

  t_audio.confirm = audio.loadSound( "sounds/effects/confirm.mp3" )
  t_audio.confirmnot = audio.loadSound( "sounds/effects/confirmnot.mp3" )

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

  local function createDreamButton( text, xpos, ypos )
    local button = display.newImageRect( sceneGroup, "images/graphics/dream_button.png", 80, 80 )
    button.x = xpos
    button.y = ypos
    button:scale( 0.5, 0.5 )
    local buttontext = display.newText( sceneGroup, text, button.x, button.y, "GosmickSans.ttf", 26 )
    buttontext:setFillColor( 0, 0, 0 )
    return button, buttontext
  end

  local dreamButtons = {}
  local dreamButtonsText = {}

  local btnIndex = 0
  for i=1, 3 do
    for j=1, 5 do
      btnIndex = j + (i-1)*5
      dreamButtons[btnIndex], dreamButtonsText[btnIndex] = createDreamButton( tostring( btnIndex ), j*80, 60 + 60*i )
      dreamButtons[btnIndex].dream = btnIndex
      if settings.unlockedDream >= btnIndex then
        dreamButtons[btnIndex]:addEventListener( "tap", gotoDreaming )
      else
        dreamButtons[btnIndex].alpha = 0.7
        dreamButtonsText[btnIndex].alpha = 0.7
      end
    end
  end

  local function createButton( text, xpos, ypos, xsize, ysize, fontsize )
    local button = display.newImageRect( sceneGroup, "images/graphics/menu_button.png", xsize, ysize )
    button.x = xpos
    button.y = ypos
    local buttontext = display.newText( sceneGroup, text, button.x, button.y, "GosmickSans.ttf", fontsize )
    buttontext:setFillColor( 0, 0, 0 )
    return button
  end

  local backButton = createButton( "Indietro", display.contentCenterX + 227, 296, 100, 35, 20 )
  backButton:addEventListener( "tap", gotoScenarios )

end


-- scene event listener
scene:addEventListener( "create", scene )

return scene
