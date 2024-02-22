local composer = require( "composer" )
local loadsave = require( "loadsave" )

local scene = composer.newScene()

local sceneGroup

local t_audio = {
  confirm, confirmnot
}

local function gotoScenarios1()
  audio.play( t_audio.confirm )
  composer.gotoScene( "scenes.scenarios1" )
end

local function gotoScenarios3()
  --audio.play( t_audio.confirm )
  print("No scenarios3") -- update futuro
  --composer.gotoScene( "scenes.scenarios3" )
end

local function swipeScenarios( event )
  if event.phase == "ended" then
    if event.xStart < event.x and (event.x - event.xStart) >= 100 then
      gotoScenarios1()
    end
    elseif event.xStart > event.x and (event.xStart - event.x) >= 100 then
      gotoScenarios3()
  end
end

local function gotoScenario4()
  audio.play( t_audio.confirm )
  Runtime:removeEventListener( "touch", swipeScenarios )
  composer.gotoScene( "scenes.s4_menu" )
end

local function gotoScenario5()
  audio.play( t_audio.confirm )
  Runtime:removeEventListener( "touch", swipeScenarios )
  composer.gotoScene( "scenes.s5_menu" )
end

local function gotoScenario6()
  audio.play( t_audio.confirm )
  Runtime:removeEventListener( "touch", swipeScenarios )
  composer.gotoScene( "scenes.s6_menu" )
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

  local swipe_arrow_left = display.newImageRect( sceneGroup, "images/graphics/arrow_swipe.png", 36, 63 )
  swipe_arrow_left.rotation = 180
  swipe_arrow_left.x = display.contentCenterX - 250
  swipe_arrow_left.y = display.contentCenterY
  swipe_arrow_left:addEventListener( "tap", gotoScenarios1 )

  local swipe_arrow_right = display.newImageRect( sceneGroup, "images/graphics/arrow_swipe.png", 36, 63 )
  swipe_arrow_right.x = display.contentCenterX + 250
  swipe_arrow_right.y = display.contentCenterY
  swipe_arrow_right:addEventListener( "tap", gotoScenarios3 )

  local function createScenarioButton( text, xpos, ypos, panoramic )
    local button = display.newImageRect( sceneGroup, "images/graphics/menu_button.png", 150, 50 )
    button.x = xpos
    button.y = ypos
    local buttontext = display.newText( sceneGroup, text, button.x, button.y, "GosmickSans.ttf", 30 )
    buttontext:setFillColor( 0, 0, 0 )
    return button, buttontext
  end

  local daliaButton, daliaText = createScenarioButton( "Dalia", display.contentCenterX, 130, "images/graphics/s1_panoramic.jpg" )
  if settings.unlockedDream > 45 then
    daliaButton:addEventListener( "tap", gotoScenario4 )
  else
    daliaButton.alpha = 0.7
    daliaText.alpha = 0.7
  end

  local eliaButton, eliaText = createScenarioButton( "Elia", display.contentCenterX, 190, "images/graphics/s1_panoramic.jpg" )
  if settings.unlockedDream > 60 then
    eliaButton:addEventListener( "tap", gotoScenario5 )
  else
    eliaButton.alpha = 0.7
    eliaText.alpha = 0.7
  end

  local fabianButton, fabianText = createScenarioButton( "Fabian", display.contentCenterX, 250, "images/graphics/s1_panoramic.jpg" )
  if settings.unlockedDream > 75 then
    fabianButton:addEventListener( "tap", gotoScenario6 )
  else
    fabianButton.alpha = 0.7
    fabianText.alpha = 0.7
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
