local composer = require( "composer" )
local loadsave = require( "loadsave" )

local scene = composer.newScene()

local sceneGroup

local t_audio = {
  confirm, confirmnot
}

local function gotoScenarios2()
  audio.play( t_audio.confirm )
  composer.gotoScene( "scenes.scenarios2" )
end

local function swipeScenarios( event )
  if event.phase == "ended" then
    if event.xStart > event.x and (event.xStart - event.x) >= 100 then
      gotoScenarios2()
    end
  end
end

local function gotoScenario1()
  audio.play( t_audio.confirm )
  Runtime:removeEventListener( "touch", swipeScenarios )
  composer.removeScene( "scenes.intro" );
  if settings.firstTime == true then
    transition.fadeOut( sceneGroup, { time=500, onComplete=function() composer.gotoScene( "scenes.intro" ); end } )
  else
    composer.gotoScene( "scenes.s1_menu" )
  end
end

local function gotoScenario2()
  audio.play( t_audio.confirm )
  Runtime:removeEventListener( "touch", swipeScenarios )
  composer.gotoScene( "scenes.s2_menu" )
end

local function gotoScenario3()
  audio.play( t_audio.confirm )
  Runtime:removeEventListener( "touch", swipeScenarios )
  composer.gotoScene( "scenes.s3_menu" )
end

local function gotoMenu()
  audio.play( t_audio.confirmnot )
  composer.gotoScene( "scenes.start_menu" )
end

-- create()
function scene:create( event )

  t_audio.confirm = audio.loadSound( "sounds/effects/confirm.mp3" )
  t_audio.confirmnot = audio.loadSound( "sounds/effects/confirmnot.mp3" )

  sceneGroup = self.view

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

  local swipe_arrow_right = display.newImageRect( sceneGroup, "images/graphics/arrow_swipe.png", 36, 63 )
  swipe_arrow_right.x = display.contentCenterX + 250
  swipe_arrow_right.y = display.contentCenterY
  swipe_arrow_right:addEventListener( "tap", gotoScenarios2 )

  local function createScenarioButton( text, xpos, ypos, panoramic )
    local button = display.newImageRect( sceneGroup, "images/graphics/menu_button.png", 150, 50 )
    button.x = xpos
    button.y = ypos
    local buttontext = display.newText( sceneGroup, text, button.x, button.y, "GosmickSans.ttf", 30 )
    buttontext:setFillColor( 0, 0, 0 )
    return button, buttontext
  end

  local alizaButton, alizaText = createScenarioButton( "Aliza", display.contentCenterX, 130, "images/graphics/s1_panoramic.jpg" )
  alizaButton:addEventListener( "tap", gotoScenario1 )

  local bernardButton, bernardText = createScenarioButton( "Bernard", display.contentCenterX, 190, "images/graphics/s1_panoramic.jpg" )
  if settings.unlockedDream > 15 then
    bernardButton:addEventListener( "tap", gotoScenario2 )
  else
    bernardButton.alpha = 0.7
    bernardText.alpha = 0.7
  end

  local carlosButton, carlosText = createScenarioButton( "Carlos", display.contentCenterX, 250, "images/graphics/s1_panoramic.jpg" )
  if settings.unlockedDream > 30 then
    carlosButton:addEventListener( "tap", gotoScenario3 )
  else
    carlosButton.alpha = 0.7
    carlosText.alpha = 0.7
  end

  local function createButton( text, xpos, ypos, xsize, ysize, fontsize )
    local button = display.newImageRect( sceneGroup, "images/graphics/menu_button.png", xsize, ysize )
    button.x = xpos
    button.y = ypos
    local buttontext = display.newText( sceneGroup, text, button.x, button.y, "GosmickSans.ttf", fontsize )
    buttontext:setFillColor( 0, 0, 0 )
    return button
  end

  local closeButton = createButton( "Indietro", display.contentCenterX + 227, 296, 100, 35, 20 )
  closeButton:addEventListener( "tap", gotoMenu )

end

-- show()
function scene:show( event )

  sceneGroup = self.view
  local phase = event.phase

  if phase == "will" then

  elseif phase == "did" then
    Runtime:addEventListener( "touch", swipeScenarios )
  end

end

-- hide()
function scene:hide( event )

  sceneGroup = self.view
  local phase = event.phase

  if phase == "will" then
    Runtime:removeEventListener( "touch", swipeScenarios )
  elseif phase == "did" then

  end

end

-- scene event listener
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )

return scene
