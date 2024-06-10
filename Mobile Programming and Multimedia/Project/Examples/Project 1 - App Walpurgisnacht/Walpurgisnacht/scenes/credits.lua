local composer = require( "composer" )

local scene = composer.newScene()

local t_audio = {
  confirm, confirmnot
}

local function gotoMenu()
  audio.play( t_audio.confirmnot )
  composer.gotoScene( "scenes.start_menu" )
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

  local author = display.newText( sceneGroup, "Gioco sviluppato da Casagrande Marco", display.contentCenterX, 140, "GosmickSans.ttf", 26 )
  author:setFillColor( 1, 1, 1 )

  --local artist = display.newText( sceneGroup, "Margagliotta Miryam", display.contentCenterX, 240, "GosmickSans.ttf", 30 )
  --artist:setFillColor( 1, 1, 1 )

  local sbb = display.newText( sceneGroup, "Musiche di Aliza: Steve's Bedroom Band", display.contentCenterX, 190, "GosmickSans.ttf", 18 )
  sbb:setFillColor( 1, 1, 1 )

  local forest = display.newText( sceneGroup, "Sfondo di Aliza: Edermunizz.itch.io", display.contentCenterX, 210, "GosmickSans.ttf", 18 )
  forest:setFillColor( 1, 1, 1 )

  local zapsplat = display.newText( sceneGroup, "Audio ed effetti: Zapsplat.com", display.contentCenterX, 230, "GosmickSans.ttf", 18 )
  zapsplat:setFillColor( 1, 1, 1 )

  local fma = display.newText( sceneGroup, "Audio: FreeMusicArchive.com", display.contentCenterX, 250, "GosmickSans.ttf", 18 )
  fma:setFillColor( 1, 1, 1 )

  local soundimage = display.newText( sceneGroup, "Effetti: SoundImage.com", display.contentCenterX, 270, "GosmickSans.ttf", 18 )
  soundimage:setFillColor( 1, 1, 1 )

  local function createButton( text, xpos, ypos, xsize, ysize, fontsize )
    local button = display.newImageRect( sceneGroup, "images/graphics/menu_button.png", xsize, ysize )
    button.x = xpos
    button.y = ypos
    local buttontext = display.newText( sceneGroup, text, button.x, button.y, "GosmickSans.ttf", fontsize )
    buttontext:setFillColor( 0, 0, 0 )
    return button
  end

  local backButton = createButton( "Indietro", display.contentCenterX + 232, 298, 90, 30, 18 )
  backButton:addEventListener( "tap", gotoMenu )
end

-- scene event listener
scene:addEventListener( "create", scene )

return scene
