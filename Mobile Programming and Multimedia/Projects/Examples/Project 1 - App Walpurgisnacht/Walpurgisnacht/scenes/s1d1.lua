local composer = require( "composer" )
local loadsave = require( "loadsave" )

local scene = composer.newScene()

local physics = require( "physics" )

physics.start()
physics.setGravity( 0, 10 )

--physics.setDrawMode( "hybrid" )

-- groups

local t_groups = {
  backGroup, charactersGroup, bulletsGroup, choicesGroup, uiGroup, superGroup
}

-- graphics

local t_graphics = {
  blueGradient = {
    type = "gradient",
    color1 = { 0.19, 0.52, 0.96, 0.9 },
    color2 = { 0.42, 0.77, 0.93, 0.8 },
    direction = "down"
  },

  arrowSheetOptions, arrowSheet, arrow_actions
}

-- tutorial

local t_tutorial = {
  playerTutorial, textField, textFieldBox,
  tutorialCounter, nextTutorial,

  arrow = {}
}

-- audio

local t_audio = {
  soundtrack, soundtrackPlay,
  crit, props,
  apple, toast, ray, singlenote, doublenote, rat, wolfpaw,
  won, lost,
  confirm, confirmnot, tutorialnext
}

local t_optionTab = {
  opened, title,

  volumeButton, soundtrackButton, closeButton, exitButton
}

local t_buttontext = {
  volume, soundtrack, close, exit
}

-- goons types

local t_goons = {
  tikey, tikeyShape,
  skeley,

  goonsCounter, goonsCounterText, goonsToSpawn, goonsSpawned, goonsKilled
}

local function gotoScenarios()
  audio.play( t_audio.confirmnot )
  loadsave.saveTable( settings, "settings.json" )
  composer.gotoScene( "scenes.s1_menu" )
end

local function gotoDreaming()
  settings.currentScenario = 1
  loadsave.saveTable( settings, "settings.json" )
  composer.removeScene( "scenes.dreaming" )
  composer.gotoScene( "scenes.dreaming" )
end

local function gotoNextDream()
  audio.play( t_audio.confirm )
  settings.currentDream = 2
  gotoDreaming()
end

local function gotoSameDream()
  audio.play( t_audio.confirm )
  settings.currentDream = 1
  gotoDreaming()
end

local function openOptionTab()

  local function openedTimer()
    t_optionTab.opened = false
  end

  local function closeOptionTab()

    t_optionTab.optionScreen:removeSelf()
    t_optionTab.optionScreen = nil
    t_optionTab.title:removeSelf()
    t_optionTab.title = nil
    t_optionTab.volumeButton:removeSelf()
    t_optionTab.volumeButton = nil
    t_buttontext.volume:removeSelf()
    t_buttontext.volume = nil
    t_optionTab.soundtrackButton:removeSelf()
    t_optionTab.soundtrackButton = nil
    t_buttontext.soundtrack:removeSelf()
    t_buttontext.soundtrack = nil
    t_optionTab.closeButton:removeSelf()
    t_optionTab.closeButton = nil
    t_buttontext.close:removeSelf()
    t_buttontext.close = nil
    t_optionTab.exitButton:removeSelf()
    t_optionTab.exitButton = nil
    t_buttontext.exit:removeSelf()
    t_buttontext.exit = nil

    audio.play( t_audio.confirmnot )
    timer.performWithDelay( 100, openedTimer )

  end

  local function exitDream()

    closeOptionTab()
    if t_goons.goonsCounterText ~= nil then
      t_goons.goonsCounterText:removeSelf()
      t_goons.goonsCounterText = nil
    end

    physics.stop()

    audio.stop( { channel=1 } )
    audio.dispose( t_audio.soundtrack )
    t_audio.soundtrackPlay = nil
    t_audio.soundtrack = nil

    Runtime:removeEventListener( "tap", t_tutorial.nextTutorial )

    gotoScenarios()

  end

  if t_optionTab.opened == false then

    t_optionTab.opened = true

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
        t_audio.soundtrackPlay = audio.play( t_audio.soundtrack, { channel=1, loops=-1 } )
      end
    end

    local function createButton( text, xpos, ypos, xsize, ysize, fontsize )
      local button = display.newImageRect( t_groups.superGroup, "images/graphics/menu_button.png", xsize, ysize )
      button.x = xpos
      button.y = ypos
      local buttontext = display.newText( t_groups.superGroup, text, button.x, button.y, "GosmickSans.ttf", fontsize )
      buttontext:setFillColor( 0, 0, 0 )
      return button, buttontext
    end

    t_optionTab.optionScreen = display.newRect( t_groups.superGroup, 0, 0, 400, 250 )
    t_optionTab.optionScreen.x = display.contentWidth / 2
    t_optionTab.optionScreen.y = display.contentHeight / 2
    t_optionTab.optionScreen:setFillColor( 0.84, 0.33, 0.33 )
    t_optionTab.optionScreen:setStrokeColor( 0, 0, 0 )
    t_optionTab.optionScreen.strokeWidth = 3
    t_optionTab.optionScreen:toFront()

    t_optionTab.title = display.newText( t_groups.superGroup, "Aliza " .. settings.currentDream, display.contentCenterX, 70, "Mikodacs.otf", 36 )
    t_optionTab.title:setFillColor( 0, 0, 0 )

    local audioText

    if settings.volumeOn == true then
      audioText = "Volume: ON "
    else
      audioText = "Volume: OFF"
    end
    t_optionTab.volumeButton, t_buttontext.volume = createButton( audioText, display.contentCenterX, 135, 110, 40, 18 )
    t_optionTab.volumeButton:addEventListener( "tap", controlVolume )

    if settings.soundtrackOn == true then
      audioText = "Musica: ON "
    else
      audioText = "Musica: OFF"
    end
    t_optionTab.soundtrackButton, t_buttontext.soundtrack = createButton( audioText, display.contentCenterX, 185, 110, 40, 18 )
    t_optionTab.soundtrackButton:addEventListener( "tap", controlSoundtrack )

    t_optionTab.exitButton, t_buttontext.exit = createButton( "Abbandona", display.contentCenterX, 245, 110, 40, 18 )
    t_optionTab.exitButton:addEventListener( "tap", exitDream )

    t_optionTab.closeButton, t_buttontext.close = createButton( "Chiudi", display.contentCenterX + 150, 257, 80, 35, 18 )
    t_optionTab.closeButton:addEventListener( "tap", closeOptionTab )

    audio.play( t_audio.confirm )

  else
    closeOptionTab()
  end

end

-- collision filters

local t_cfilters = {
  cfGround, cfPlayer, cfEnemies, cfPlayerbullets, cfEnemybullets
}

-- screen zones

local t_screenzs = {
  background, groundShape, choicesGround,

  optionTabImage, optionTabFieldBox
}

-- phases

local t_phases = {
  playerTutorialPhase,

  techniquesPhase, playerAttackPhase, enemyAttackPhase, dreamCompleteCheckPhase
}

-- tables

local t_tables = {
  techniques_table, goons_table
}

-- combat player

local t_cbtplayer = {
  player_base_damage, player_base_ammo, player_base_defense, player_base_critperc,
  player_base_critdmg, player_isCrit, player_nextCrit,

  player_damage_bonus_plus, player_damage_bonus_multi, player_ammo_bonus_plus,
  player_defense_bonus_plus, player_critperc_bonus_plus,

  player_defense_bonus_multi, player_grit, player_critdmg_bonus_plus,
  player_rampage, player_culling, player_extrahit,

  player_final_damage, player_final_ammo, player_final_defense,
  player_final_critperc, player_final_critdmg,

  player_current_ammo,

  player_dead,

  vocal, mirror_prop, lunchbox_deployed, lunchbox_active, lunchbox_prop
}

-- combat enemy

local t_cbtenemy = {
  goons, enemy_accuracy_bonus_minus
}

-- player

local t_player = {
  player,

  lastDamageDealt, lastDamageDealtBox
}

-- player HPBar

local t_playerHPB = {
  playerMaxHP, playerCurrentHP, playerHPBar
}

-- ending

local t_ending = {
  endingTurns, fortitudeLost, damageDone
}

-- techniques

local t_techniques = {
  technique_chosen, techniques_offered = {},
  technique_1, technique_2
}

-- techniques phase stuff

local function techniqueTap( event )

  print("techniqueTap()")
  if t_optionTab.opened == false then

    t_cbtplayer.player_damage_dealt_turn = 0

    if t_tutorial.tutorialCounter == 10
      and t_tutorial.arrow[5] ~= nil
      and t_tutorial.arrow[6] ~= nil
      and t_tutorial.textField ~= nil
      and t_tutorial.textFieldBox ~= nil then
        t_tutorial.arrow[5]:removeSelf()
        t_tutorial.arrow[5] = nil
        t_tutorial.arrow[6]:removeSelf()
        t_tutorial.arrow[6] = nil
        t_tutorial.textField:removeSelf()
        t_tutorial.textField = nil
        t_tutorial.textFieldBox:removeSelf()
        t_tutorial.textFieldBox = nil
    end

    if t_techniques.technique_chosen == 0 then
      audio.play( t_audio.choice )
      t_techniques.technique_chosen = event.target.sequence
      if t_techniques.technique_chosen == "apple" then
        t_cbtplayer.player_base_damage = 9
        t_cbtplayer.player_base_critperc = 60
        t_cbtplayer.player_base_ammo = 3
      elseif t_techniques.technique_chosen == "lunchbox" then
        t_cbtplayer.player_base_damage = 1
        t_cbtplayer.player_base_critperc = 0
        t_cbtplayer.player_base_ammo = 1
      elseif t_techniques.technique_chosen == "mirror" then
        t_cbtplayer.player_base_damage = 6
        t_cbtplayer.player_base_critperc = 0
        t_cbtplayer.player_base_ammo = 1
        transition.fadeIn( t_cbtplayer.mirror_prop, { time=350 } )
      elseif t_techniques.technique_chosen == "music" then
        t_cbtplayer.player_base_damage = 8
        t_cbtplayer.player_base_critperc = 40
        t_cbtplayer.player_base_ammo = 3
      elseif t_techniques.technique_chosen == "rat" then
        t_cbtplayer.player_base_damage = 4
        t_cbtplayer.player_base_critperc = 20
        t_cbtplayer.player_base_ammo = 6
      elseif t_techniques.technique_chosen == "wolfpaw" then
        t_cbtplayer.player_base_damage = 1
        t_cbtplayer.player_base_critperc = 0
        t_cbtplayer.player_base_ammo = 8
      end
    	print("technique chosen: " .. t_techniques.technique_chosen)
      transition.fadeOut( t_techniques.technique_1, { time=500 } )
    	transition.fadeOut( t_techniques.technique_2, { time=500 } )
      timer.performWithDelay( 500, t_phases.playerAttackPhase )
    end

  end

end

local function calculatePlayerTurnStats()

  print("calculatePlayerTurnStats()")

  print("player base damage: " .. t_cbtplayer.player_base_damage)
  t_cbtplayer.player_final_damage = t_cbtplayer.player_base_damage + t_cbtplayer.player_damage_bonus_plus
  print("player damage plus: " .. t_cbtplayer.player_final_damage)
  t_cbtplayer.player_final_damage = math.round( t_cbtplayer.player_final_damage + t_cbtplayer.player_final_damage * (t_cbtplayer.player_damage_bonus_multi / 10) )
  print("player final damage: " .. t_cbtplayer.player_final_damage)

  print("player base ammo: " .. t_cbtplayer.player_base_ammo)
  if t_techniques.technique_chosen == "wolfpaw" then
    t_cbtplayer.player_final_ammo = t_cbtplayer.player_base_ammo + t_cbtplayer.player_ammo_bonus_plus * 2
  else
    t_cbtplayer.player_final_ammo = t_cbtplayer.player_base_ammo + t_cbtplayer.player_ammo_bonus_plus
  end
  print("player final ammo: " .. t_cbtplayer.player_final_ammo)
  t_cbtplayer.player_current_ammo = t_cbtplayer.player_final_ammo

  print("player base defense: " .. t_cbtplayer.player_base_defense)
  t_cbtplayer.player_final_defense = t_cbtplayer.player_final_defense + t_cbtplayer.player_defense_bonus_plus
  print("player defense plus: " .. t_cbtplayer.player_final_defense)
  t_cbtplayer.player_final_defense = math.round( t_cbtplayer.player_final_defense * (t_cbtplayer.player_defense_bonus_multi / 10) )
  print("player final defense: " .. t_cbtplayer.player_final_defense)

  print("player base critperc: " .. t_cbtplayer.player_base_critperc)
  t_cbtplayer.player_final_critperc = t_cbtplayer.player_base_critperc + t_cbtplayer.player_critperc_bonus_plus
  print("player final critperc: " .. t_cbtplayer.player_final_critperc)

  t_cbtplayer.player_final_critdmg = t_cbtplayer.player_base_critdmg + t_cbtplayer.player_critdmg_bonus_plus

end

local function damagePlayer( damage )

	print("damagePlayer()")
  t_ending.fortitudeLost = t_ending.fortitudeLost + damage
	t_playerHPB.playerCurrentHP = t_playerHPB.playerCurrentHP - damage
	t_playerHPB.playerHPBar.width = t_playerHPB.playerCurrentHP
	if t_playerHPB.playerCurrentHP <= 0 then
		display.remove( t_playerHPB.playerHPBar )
    t_cbtplayer.player_dead = true
	elseif t_playerHPB.playerCurrentHP <= 10 then
		t_playerHPB.playerHPBar:setFillColor( 1, 0, 0 )
	elseif t_playerHPB.playerCurrentHP <= 50 then
		t_playerHPB.playerHPBar:setFillColor( 1, 1, 0 )
	end

end

local function specialDealt( damage, enemyObj, color )

  print("specialHit()")
  local damageText = display.newText( t_groups.uiGroup, damage, enemyObj.x + math.random( 26, 32 ), enemyObj.y - math.random( -8, 8 ), "GosmickSans.ttf", 10 )
  damageText:setFillColor( 0, 0, 0 )
  local vertices = { 0,-10, 3,-4, 10,-3, 5,3, 7,11, 0,8, -7,11, -5,3, -10,-3, -3,-4 }
  local damageBubble = display.newPolygon( t_groups.uiGroup, damageText.x, damageText.y, vertices )
  damageBubble:setFillColor( 1, 0, 0, 1 )
  damageBubble:scale( 1.1, 1.1 )
  damageText:toFront()
  transition.to( damageBubble, { time=1200, alpha=0, y=damageBubble.y-30, rotation=360, onComplete=function(damageBubble) damageBubble:removeSelf(); damageBubble=nil; end } )
  transition.to( damageText, { time=1200, alpha=0, y=damageText.y-30, onComplete=function(damageText) damageText:removeSelf(); damageText=nil; end } )

end

local function extraHit( damage, enemyObj )

  print("extraHit()")
  local damageText = display.newText( t_groups.uiGroup, damage, enemyObj.x + math.random( 6, 14 ), enemyObj.y - math.random( -3, 13 ), "GosmickSans.ttf", 8 )
  damageText:setFillColor( 0, 0, 0 )
  local vertices = { 0,-10, 3,-4, 10,-3, 5,3, 7,11, 0,8, -7,11, -5,3, -10,-3, -3,-4 }
  local damageBubble = display.newPolygon( t_groups.uiGroup, damageText.x, damageText.y-1, vertices )
  damageBubble.fill = { type="image", filename="images/graphics/starfill_blue.png" }
  damageBubble:scale( 0.8, 0.8 )
  damageText:toFront()
  transition.to( damageBubble, { time=600, alpha=0, y=damageBubble.y-20, rotation=100, onComplete=function(damageBubble) damageBubble:removeSelf(); damageBubble=nil; end } )
  transition.to( damageText, { time=600, alpha=0, y=damageText.y-20, onComplete=function(damageText) damageText:removeSelf(); damageText=nil; end } )

  enemyObj.hp = enemyObj.hp - damage
  print("extradamaged goon for: " .. damage)
  print("goon hp: " .. enemyObj.hp)
  if enemyObj.hp <= 0 then
    transition.to( enemyObj, { time=50, alpha=0, onComplete=function(enemyObj) display.remove(enemyObj); enemyObj=nil; end } )
  end

end

local function hitDealt( damage, enemyObj )

  local damageText = display.newText( t_groups.uiGroup, damage, enemyObj.x + math.random( 12, 22 ), enemyObj.y - math.random( -6, 10 ), "GosmickSans.ttf", 9 )
  damageText:setFillColor( 0, 0, 0 )
  local vertices = { 0,-10, 3,-4, 10,-3, 5,3, 7,11, 0,8, -7,11, -5,3, -10,-3, -3,-4 }
  local damageBubble = display.newPolygon( t_groups.uiGroup, damageText.x, damageText.y, vertices )
  damageBubble.fill = { type="image", filename="images/graphics/starfill_yellow.png" }
  damageText:toFront()
  transition.to( damageBubble, { time=800, alpha=0, y=damageBubble.y-30, rotation=240, onComplete=function(damageBubble) damageBubble:removeSelf(); damageBubble=nil; end } )
  transition.to( damageText, { time=800, alpha=0, y=damageText.y-30, onComplete=function(damageText) damageText:removeSelf(); damageText=nil; end } )

end

local function critDealt( damage, enemyObj )

  local damageText = display.newText( t_groups.uiGroup, damage, enemyObj.x + math.random( 22, 32 ), enemyObj.y - math.random( -8, 8 ), "GosmickSans.ttf", 10 )
  damageText:setFillColor( 0, 0, 0 )
  local vertices = { 0,-10, 3,-4, 10,-3, 5,3, 7,11, 0,8, -7,11, -5,3, -10,-3, -3,-4 }
  local damageBubble = display.newPolygon( t_groups.uiGroup, damageText.x, damageText.y, vertices )
  damageBubble.fill = { type="image", filename="images/graphics/starfill_orange.png" }
  damageBubble:scale( 1.1, 1.1 )
  damageText:toFront()
  transition.to( damageBubble, { time=1200, alpha=0, y=damageBubble.y-30, rotation=360, onComplete=function(damageBubble) damageBubble:removeSelf(); damageBubble=nil; end } )
  transition.to( damageText, { time=1200, alpha=0, y=damageText.y-30, onComplete=function(damageText) damageText:removeSelf(); damageText=nil; end } )

end

local function damageEnemy( damage, enemyObj )

	print("damageEnemy()")
  if t_cbtplayer.player_nextCrit == true then
    t_cbtplayer.player_nextCrit = false
    t_cbtplayer.player_isCrit = true
    damage = damage * t_cbtplayer.player_final_critdmg
    specialDealt( damage, enemyObj )
  elseif math.random( 0, 100 ) < t_cbtplayer.player_final_critperc then
    t_cbtplayer.player_isCrit = true
    damage = damage * t_cbtplayer.player_final_critdmg
    critDealt( damage, enemyObj )
  else
    hitDealt( damage, enemyObj )
  end

  t_cbtplayer.player_damage_dealt_turn = t_cbtplayer.player_damage_dealt_turn + damage
  t_player.lastDamageDealt.text = "Ultimi danni: " .. t_cbtplayer.player_damage_dealt_turn
  t_ending.damageDealt = t_ending.damageDealt + damage
  enemyObj.hp = enemyObj.hp - damage
  print("damaged goon for: " .. damage)
  print("goon hp: " .. enemyObj.hp)
  if enemyObj.hp <= 0 then
    display.remove( enemyObj )
    enemyObj = nil
    t_goons.goonsTotalCount = t_goons.goonsTotalCount - 1
    if t_goons.goonsTotalCount == 3 then
      t_tutorial.tutorialCounter = t_tutorial.tutorialCounter + 1
    elseif t_goons.goonsTotalCount < 3 then
      t_goons.goonsCounterText.text = "x" .. tostring( t_goons.goonsTotalCount )
    end
  end

end

local function playerBulletCollision( self, event )

  if event.other.type == "boss" or event.other.type == "goons" then
    if self.type == "ray" then
      if t_cbtplayer.player_final_damage - self.refraction < 0 then
        damageEnemy( 0, event.other )
      else
        damageEnemy( t_cbtplayer.player_final_damage - self.refraction, event.other )
      end
    else
      damageEnemy( t_cbtplayer.player_final_damage + math.random( 0, 2 ), event.other )
    end
    if self.type == "apple" then -- apple
      audio.play( t_audio.apple )
      display.remove( self )
      self = nil
    elseif self.type == "toast" then -- lunchbox
      audio.play( t_audio.toast )
      display.remove( self )
      self = nil
    elseif self.type == "ray" then -- mirror
      self.refraction = self.refraction + 1
    elseif self.type == "singlenote" then -- music
      audio.play( t_audio.singlenote )
      display.remove( self )
      self = nil
    elseif self.type == "doublenote" then -- music
      audio.play( t_audio.doublenote )
      if self.strong == true then
        self.strong = false
      else
        display.remove( self )
        self = nil
      end
    elseif self.type == "rat" then -- rat
      audio.play( t_audio.rat )
      display.remove( self )
      self = nil
    elseif self.type == "wolfpaw" then -- wolfpaw
      audio.play( t_audio.wolfpaw )
    end
    t_cbtplayer.player_isCrit = false
  elseif event.other.type == "ground" then
    if self.type ~= "wolfpaw" then
      transition.to( self, { time=50, alpha=0, onComplete=function(self) display.remove(self); self=nil; end } )
    end
  end

end

local function playerAttack()

  print("playerAttack()")
  if t_cbtplayer.lunchbox_deployed == true and t_cbtplayer.lunchbox_active == true then
    print("burst -" .. t_cbtplayer.lunchbox_prop.burst)
    if t_cbtplayer.lunchbox_prop.burst == 0 then
      for j=1, t_cbtplayer.player_current_ammo do
        local toast = display.newImageRect( t_groups.bulletsGroup, "images/objects/toast.png", 18, 17 )
        physics.addBody( toast, "dynamic", { radius=7, isSensor=true, isBullet=true, density=1, filter=t_cfilters.cfPlayerbullets } )
        toast.x = t_cbtplayer.lunchbox_prop.x + 5
        toast.y = t_cbtplayer.lunchbox_prop.y - 5
        toast:scale( 0.6, 0.6 )
        toast.type = "toast"
        toast.collision = playerBulletCollision
        toast:addEventListener("collision")
        toast:applyLinearImpulse( math.random( 12, 22 ) / 20, math.random( -25, -10 ) / 20, toast.x, toast.y )
        transition.to( toast, { rotation=720, time=3000 } )
      end
      t_cbtplayer.lunchbox_prop:removeSelf()
      t_cbtplayer.lunchbox_prop = nil
      t_cbtplayer.lunchbox_deployed = false
    else
      local toast = display.newImageRect( t_groups.bulletsGroup, "images/objects/toast.png", 18, 17 )
      physics.addBody( toast, "dynamic", { radius=7, isSensor=true, isBullet=true, density=1, filter=t_cfilters.cfPlayerbullets } )
      toast.x = t_cbtplayer.lunchbox_prop.x + 5
      toast.y = t_cbtplayer.lunchbox_prop.y - 5
      toast:scale( 0.6, 0.6 )
      toast.type = "toast"
      toast.collision = playerBulletCollision
      toast:addEventListener("collision")
      toast:applyLinearImpulse( math.random( 15, 25 ) / 20, math.random( -25, -10 ) / 20, toast.x, toast.y )
      transition.to( toast, { rotation=720, time=3000 } )
      t_cbtplayer.lunchbox_prop.burst = t_cbtplayer.lunchbox_prop.burst - 1
    end
    t_cbtplayer.lunchbox_active = false
  end
  if t_cbtplayer.player_current_ammo ~= 0 then
    -- apple
    if t_techniques.technique_chosen == "apple" then
      local bullet = display.newImageRect( t_groups.bulletsGroup, "images/objects/apple.png", 19, 22 )
      physics.addBody( bullet, "dynamic", { radius=7, isSensor=true, isBullet=true, density=3.8, filter=t_cfilters.cfPlayerbullets } )
      bullet.x = t_player.player.x + 15
      bullet.y = t_player.player.y - 5
      bullet:scale( 0.6, 0.6 )
      bullet.type = "apple"
      bullet.collision = playerBulletCollision
      bullet:addEventListener("collision")
      bullet:applyLinearImpulse( math.random( 58, 68 ) / 10, math.random( -38, -28 ) / 10, bullet.x, bullet.y )
      t_cbtplayer.player_current_ammo = t_cbtplayer.player_current_ammo - 1
      transition.to( bullet, { rotation=1080, time=3000 } )
      transition.to( bullet, { time=250, onComplete=playerAttack } )
    -- lunchbox
    elseif t_techniques.technique_chosen == "lunchbox" then
      t_cbtplayer.lunchbox_deployed = true
      t_cbtplayer.lunchbox_prop = display.newImageRect( t_groups.charactersGroup, "images/objects/lunchbox.png", 25, 28 )
      local lunchShape = { -8,-6, 8,-6, 8,8, -8,8 }
      physics.addBody( t_cbtplayer.lunchbox_prop, "dynamic", { shape=lunchShape, density=1, bounce=0, friction=1, filter=t_cfilters.cfEnemies } )
      t_cbtplayer.lunchbox_prop.x = t_player.player.x + 130
      t_cbtplayer.lunchbox_prop.y = t_player.player.y - 5
      t_cbtplayer.lunchbox_prop:scale( 0.7, 0.7 )
      t_cbtplayer.lunchbox_prop.type = "lunchbox"
      t_cbtplayer.lunchbox_prop.burst = 2
      t_cbtplayer.lunchbox_active = false
      t_cbtplayer.player_current_ammo = 0
      audio.play(t_audio.props )
      transition.to( t_cbtplayer.lunchbox_prop, { time=250, onComplete=playerAttack } )
    -- mirror
    elseif t_techniques.technique_chosen == "mirror" then
      bullet = display.newImageRect( t_groups.bulletsGroup, "images/objects/ray.png", 20, 3 )
      physics.addBody( bullet, "dynamic", { radius=2, isSensor=true, isBullet=true, filter=t_cfilters.cfPlayerbullets } )
      bullet.gravityScale = 0
      bullet.anchorX = 0
      bullet.refraction = 0
      bullet:toFront()
      bullet.x = t_cbtplayer.mirror_prop.x + 2
      bullet.y = t_cbtplayer.mirror_prop.y
      bullet.type = "ray"
      bullet.collision = playerBulletCollision
      bullet:addEventListener("collision")
      t_cbtplayer.player_current_ammo = t_cbtplayer.player_current_ammo - 1
      audio.play(t_audio.ray )
      transition.to( bullet, { width=300, x=600, time=450 } )
      transition.to( bullet, { time=500, onComplete=playerAttack } )
    -- music
    elseif t_techniques.technique_chosen == "music" then
      if t_cbtplayer.vocal == true then
        bullet = display.newImageRect( t_groups.bulletsGroup, "images/objects/doubleNote.png", 19, 18 )
        physics.addBody( bullet, "dynamic", { radius=5, isSensor=true, isBullet=true, filter=t_cfilters.cfPlayerbullets } )
        bullet.type = "doublenote"
        bullet.strong = true
        t_cbtplayer.vocal = false
      else
        bullet = display.newImageRect( t_groups.bulletsGroup, "images/objects/singleNote.png", 12, 16 )
        physics.addBody( bullet, "dynamic", { radius=3, isSensor=true, isBullet=true, filter=t_cfilters.cfPlayerbullets } )
        bullet.type = "singlenote"
        t_cbtplayer.vocal = true
      end
      bullet.gravityScale = 0
      bullet.x = t_player.player.x + 15
      bullet.y = t_player.player.y - 5
      bullet.collision = playerBulletCollision
      bullet:addEventListener("collision")
      t_cbtplayer.player_current_ammo = t_cbtplayer.player_current_ammo - 1
      transition.to( bullet, { x=600, y=math.random(t_player.player.y - 60, t_player.player.y), time=2400, transition=easing.outQuad } )
      transition.to( bullet, { time=250, onComplete=playerAttack } )
    -- rat
    elseif t_techniques.technique_chosen == "rat" then
      bullet = display.newImageRect( t_groups.bulletsGroup, "images/objects/rat.png", 20, 10 )
      local ratShape = { 6,-6, 6,6, -6,6, -6,-6 }
      physics.addBody( bullet, "dynamic", { shape=ratShape, isSensor=true, isBullet=true, density=0.8, bounce=0.1, friction=0.3, filter=cfPlayerbullets } )
      bullet.x = math.random( 350, 430 )
      bullet.y = -30
      bullet.type = "rat"
      bullet.rotation = math.random( 0, 359 )
      bullet.collision = playerBulletCollision
      bullet:addEventListener("collision")
      bullet:applyLinearImpulse( (math.random( 0, 40 ) - 20) / 80, 0, bullet.x, bullet.y )
      t_cbtplayer.player_current_ammo = t_cbtplayer.player_current_ammo - 1
      transition.to( bullet, { time=250, onComplete=playerAttack } )
    -- wolfpaw
    elseif t_techniques.technique_chosen == "wolfpaw" then
      bullet = display.newImageRect( t_groups.bulletsGroup, "images/objects/wolfpaw.png", 21, 54 )
      local pawShape = { 4,4, -6,4, -6,-20, 4,-20 }
      physics.addBody( bullet, "dynamic", { shape=pawShape, isSensor=true, isBullet=true, filter=t_cfilters.cfPlayerbullets } )
      bullet.gravityScale = 0
      bullet.x = math.random( display.contentCenterX + 60, display.contentCenterX + 170 )
      bullet.y = 166
      bullet:scale( 0.6, 0.6 )
      bullet.anchorY = 0.8
      bullet.type = "wolfpaw"
      bullet.rotation = -45
      bullet.collision = playerBulletCollision
      bullet:addEventListener("collision")
      t_cbtplayer.player_current_ammo = t_cbtplayer.player_current_ammo - 1
      transition.to( bullet, { alpha=0, time=500, transition=easing.inExpo, onComplete=function(bullet) display.remove(bullet); b=nil; end } )
      transition.to( bullet, { time=500, rotation=45 } )
      transition.to( bullet, { time=250, onComplete=playerAttack } )
    end
  else
    t_phases.enemyAttackPhase()
  end

end

-- reset turn stats

local function resetTurnStats()

  print("resetTurnStats()")
  if t_cbtplayer.lunchbox_deployed == true then
    t_cbtplayer.lunchbox_active = true
    t_tables.techniques_table = { "apple", "mirror", "music", "rat", "wolfpaw" }
  else
    t_tables.techniques_table = { "apple", "lunchbox", "mirror", "music", "rat", "wolfpaw" }
  end

  t_cbtplayer.player_damage_bonus_plus = 0
  t_cbtplayer.player_damage_bonus_multi = 0
  t_cbtplayer.player_ammo_bonus_plus= 0
  t_cbtplayer.player_defense_bonus_plus = 0
  t_cbtplayer.player_critperc_bonus_plus = 0
  t_cbtplayer.player_isCrit = false
  t_cbtplayer.player_nextCrit = false

  t_cbtplayer.player_defense_bonus_multi = 0
  t_cbtplayer.player_grit = 0
  t_cbtplayer.player_critdmg_bonus_plus = 0
  t_cbtplayer.player_rampage = false
  t_cbtplayer.player_culling = 0
  t_cbtplayer.player_extrahit = 0

  t_cbtplayer.player_final_damage = t_cbtplayer.player_base_damage
  t_cbtplayer.player_final_ammo = t_cbtplayer.player_base_ammo
  t_cbtplayer.player_final_defense = t_cbtplayer.player_base_defense
  t_cbtplayer.player_final_critperc = t_cbtplayer.player_base_critperc
  t_cbtplayer.player_final_critdmg = t_cbtplayer.player_base_critdmg

  t_cbtplayer.vocal = false

  t_techniques.technique_chosen = 0

  t_cbtenemy.enemy_accuracy_bonus_minus = 0

end

-- renew techniques

local function renewTechniques()

  local function shuffleTechniques()

  	print("shuffleTechniques()")
    local num
    for i=0, 1 do
      num = math.random( 1, #t_tables.techniques_table)
      t_techniques.techniques_offered[i+1] = t_tables.techniques_table[num]
      table.remove( t_tables.techniques_table, num)
    end

  end

	print("renewTechniques()")
  shuffleTechniques()
	t_techniques.technique_1:setSequence( t_techniques.techniques_offered[1] )
	t_techniques.technique_2:setSequence( t_techniques.techniques_offered[2] )
  transition.to( t_techniques.technique_1, { time=500, alpha=0.9 } )
	transition.to( t_techniques.technique_2, { time=500, alpha=0.9 } )

end

-- endings

local function nightmareDream()

  print("nightmareDream()")
  physics.stop()

  t_audio.lost = audio.loadSound( "sounds/effects/lost.mp3" )
  audio.play( t_audio.lost )

  audio.stop( { channel=1 } )
  audio.dispose( t_audio.soundtrack )
  t_audio.soundtrackPlay = nil
  t_audio.soundtrack = nil

  local menuButton = display.newImageRect( t_groups.superGroup, "images/graphics/button_menu.png", 94, 94 )
  menuButton.x = display.contentCenterX - 135
  menuButton.y = 235
  menuButton:addEventListener( "tap", gotoScenarios )

  local retryButton = display.newImageRect( t_groups.superGroup, "images/graphics/button_retry.png", 94, 94 )
  retryButton.x = display.contentCenterX + 135
  retryButton.y = 235
  retryButton:addEventListener( "tap", gotoSameDream )

end

local function goodDream()

  print("goodDream()")
  physics.stop()


  t_audio.won = audio.loadSound( "sounds/effects/won.mp3" )
  audio.play( t_audio.won )

  audio.stop( { channel=1 } )
  audio.dispose( t_audio.soundtrack )
  t_audio.soundtrackPlay = nil
  t_audio.soundtrack = nil

  if settings.currentDream == settings.unlockedDream then
    settings.unlockedDream = settings.unlockedDream + 1
    loadsave.saveTable( settings, "settings.json" )
    composer.removeScene( "scenes.scenarios" )
    composer.removeScene( "scenes.s1_menu" )
  end

  t_screenzs.optionTabFieldBox:removeSelf()
  t_screenzs.optionTabFieldBox = nil
  t_screenzs.optionTabImage:removeSelf()
  t_screenzs.optionTabImage = nil
  t_goons.goonsCounterText:removeSelf()
  t_goons.goonsCounterText = nil
  t_player.lastDamageDealt:removeSelf()
  t_player.lastDamageDealt = nil
  t_player.lastDamageDealtBox:removeSelf()
  t_player.lastDamageDealtBox = nil

  local blackScreen = display.newRect( t_groups.superGroup, 0, 0, 570, 350 )
  blackScreen.x = display.contentWidth / 2
  blackScreen.y = display.contentHeight / 2
  blackScreen:setFillColor( 0, 0, 0 )
  blackScreen.alpha = 0
  transition.fadeIn( blackScreen, { time=1000 } )

  local endingTitle = display.newText( t_groups.superGroup, "Il sogno ha fine", display.contentCenterX, 40, "Mikodacs.otf", 40 )
  endingTitle.alpha = 0
  endingTitle:setTextColor( 1, 1, 1 )

  local endingTurns =  display.newText( t_groups.superGroup, "Durata del sonno: ".. tostring( t_ending.endingTurns ) .. " turni", display.contentCenterX, 100, "GosmickSans.ttf", 20 )
  local fortitudeLost =  display.newText( t_groups.superGroup, "Coraggio perduto: ".. tostring( t_ending.fortitudeLost ), display.contentCenterX, 130, "GosmickSans.ttf", 20 )
  local damageDone =  display.newText( t_groups.superGroup, "Danni inflitti: " .. tostring( t_ending.damageDealt ), display.contentCenterX, 170, "GosmickSans.ttf", 20 )
  endingTurns:setTextColor( 1, 1, 1 )
  fortitudeLost:setTextColor( 1, 1, 1 )
  damageDone:setTextColor( 1, 1, 1 )
  endingTurns.alpha = 0
  fortitudeLost.alpha = 0
  damageDone.alpha = 0

  transition.fadeIn( endingTitle, { time=1000 } )
  transition.fadeIn( endingTurns, { time=1000 } )
  transition.fadeIn( fortitudeLost, { time=1000 } )
  transition.fadeIn( damageDone, { time=1000 } )

  local menuButton = display.newImageRect( t_groups.superGroup, "images/graphics/button_menu.png", 94, 94 )
  menuButton.x = display.contentCenterX - 155
  menuButton.y = 235
  menuButton.alpha = 0
  menuButton:addEventListener( "tap", gotoScenarios )
  transition.fadeIn( menuButton, { time=1000 } )

  local nextButton = display.newImageRect( t_groups.superGroup, "images/graphics/button_next.png", 94, 94 )
  nextButton.x = display.contentCenterX + 155
  nextButton.y = 235
  nextButton.alpha = 0
  nextButton:addEventListener( "tap", gotoNextDream )
  transition.fadeIn( nextButton, { time=1000 } )

end

local function snoring()
  local snoreText = display.newText( t_groups.uiGroup, "Z", 90, 135, "GosmickSans.ttf", 7 )
  snoreText:setFillColor( 0, 0, 0 )
  transition.to( snoreText, { time=3000, alpha=0, y=110, onComplete=snoring } )
end

-- create()
function scene:create( event )

  local sceneGroup = self.view

  physics.pause()

  -- groups

  t_groups.backGroup = display.newGroup()
  sceneGroup:insert( t_groups.backGroup )
  t_groups.charactersGroup = display.newGroup()
  sceneGroup:insert( t_groups.charactersGroup )
  t_groups.bulletsGroup = display.newGroup()
  sceneGroup:insert( t_groups.bulletsGroup )
  t_groups.choicesGroup = display.newGroup()
  sceneGroup:insert( t_groups.choicesGroup )
  t_groups.uiGroup = display.newGroup()
  sceneGroup:insert( t_groups.uiGroup )
  t_groups.superGroup = display.newGroup()
  sceneGroup:insert( t_groups.superGroup )

  -- audio

  t_audio.soundtrack = audio.loadStream( "sounds/soundtracks/aliza_quartet" .. math.random( 1, 6 ) .. ".mp3" )

  t_audio.confirm = audio.loadSound( "sounds/effects/confirm.mp3" )
  t_audio.confirmnot = audio.loadSound( "sounds/effects/confirmnot.mp3" )
  t_audio.tutorialnext = audio.loadSound( "sounds/effects/tutorialnext.mp3" )
  t_audio.choice = audio.loadSound( "sounds/effects/choice.mp3" )

  t_audio.crit = audio.loadSound( "sounds/effects/crit.wav" )
  t_audio.props = audio.loadSound( "sounds/effects/props.mp3" )

  t_audio.apple = audio.loadSound( "sounds/effects/apple.mp3" )
  t_audio.toast = audio.loadSound( "sounds/effects/toast.mp3" )
  t_audio.ray = audio.loadSound( "sounds/effects/ray.mp3" )
  t_audio.singlenote = audio.loadSound( "sounds/effects/singlenote.mp3" )
  t_audio.doublenote = audio.loadSound( "sounds/effects/doublenote.mp3" )
  t_audio.rat = audio.loadSound( "sounds/effects/rat.mp3" )
  t_audio.wolfpaw = audio.loadSound( "sounds/effects/wolfpaw.mp3" )

  t_audio.soundtrackPlay = audio.play( t_audio.soundtrack, { channel=1, loops=-1 } )

  -- optionTab

  t_optionTab.opened = false

  -- graphics

  t_graphics.arrowSheetOptions =
  { frames =
    {
      -- 1) arrow1
      { x = 0, y = 0, width = 53, height = 30 },
      -- 2) arrow2
      { x = 53, y = 0, width = 53, height = 30 },
      -- 3) arrow3
      { x = 106, y = 0, width = 53, height = 30 },
      -- 4) arrow4
      { x = 159, y = 0, width = 53, height = 30 },
      -- 5) arrow5
      { x = 212, y = 0, width = 53, height = 30 },
      -- 6) arrow6
      { x = 265, y = 0, width = 53, height = 30 }
    }
  }

  t_graphics.arrowSheet = graphics.newImageSheet( "images/graphics/arrow_tutorialSheet.png", t_graphics.arrowSheetOptions )
  t_graphics.arrow_actions = {
    { name = "idle", start = 1,	count = 6, time = 1000, loopCount = 0, loopDirection = "forward" }
  }

  -- tutorial

  t_tutorial.playerTutorial = {
    "Ti trovi nel sogno di Aliza", --1
    "Permettimi una breve introduzione",
    "Questa è lei che dorme", --3
    "Questa è la sua barra del coraggio",
    "Quando finisce il coraggio, Aliza non potrà più opporsi alle streghe", --5
    "Verrà rapita e dovrai ripetere il sogno di nuovo",
    "Questo è il pulsante del menù", --7
    "Attenzione, sta arrivando un Incubo!",
    "Scaccialo via con un attacco!", --9
    "Scegli tra le fantasie casuali comparse",
    "L'Incubo ha subito troppi danni ed è svanito, ben fatto!", --11
    "Aliza adora fiabe e favole: ciascuna ha un effetto diverso",
    "I tre simboli rappresentano danno, critico e munizioni", --13
    "Ricordati di sperimentare le varie fantasie!",
    "Stanno arrivando altri Incubi!", --15
    "Qui puoi trovare il contatore dei nemici rimanenti",
    "Scacciali dal sogno! Buona fortuna!" --17
  }
  t_tutorial.tutorialCounter = 1

  -- collision filters

  t_cfilters.cfGround = { categoryBits=1, maskBits=30 }
  t_cfilters.cfPlayer = { categoryBits=2, maskBits=17 }
  t_cfilters.cfEnemies = { categoryBits=4, maskBits=13 }
  t_cfilters.cfPlayerbullets = { categoryBits=8, maskBits=21 }
  t_cfilters.cfEnemybullets = { categoryBits=16, maskBits=3 }

  -- screen zones

  t_screenzs.background = display.newImageRect( t_groups.backGroup, "images/graphics/forest.png", 570, 170 )
  t_screenzs.background.x = display.contentCenterX
  t_screenzs.background.y = 165
  t_screenzs.background.anchorY = 1
  t_screenzs.background.type = "ground"
  t_screenzs.groundShape = { -285,80, -285,83, 285,80, 285,83 }
  physics.addBody( t_screenzs.background, "static", { bounce=0, friction=1, shape=t_screenzs.groundShape, filter=t_cfilters.cfGround } )

  t_screenzs.choicesGround = display.newImageRect( t_groups.choicesGroup, "images/graphics/choicesGround.png", 570, 155 )
  t_screenzs.choicesGround.x = display.contentCenterX
  t_screenzs.choicesGround.y = 320
  t_screenzs.choicesGround.anchorY = 1

  t_screenzs.optionTabImage = display.newImageRect( t_groups.uiGroup, "images/icons/optionTab.png", 25, 22 )
  t_screenzs.optionTabImage.x = 495
  t_screenzs.optionTabImage.y = 22

  t_screenzs.optionTabFieldBox = display.newRect( t_groups.uiGroup, t_screenzs.optionTabImage.x, t_screenzs.optionTabImage.y,
    t_screenzs.optionTabImage.width + 20, t_screenzs.optionTabImage.height + 10 )
  t_screenzs.optionTabFieldBox.strokeWidth = 2
  t_screenzs.optionTabFieldBox.fill = t_graphics.blueGradient
  t_screenzs.optionTabFieldBox:setStrokeColor( 0, 0, 0 )
  t_screenzs.optionTabFieldBox:addEventListener( "tap", openOptionTab )

  t_screenzs.optionTabImage:toFront()

  -- tables

  t_tables.techniques_table = { "apple", "lunchbox", "mirror", "music", "rat", "wolfpaw" }
  t_tables.goons_table = {}

  -- combat player

  t_cbtplayer.player_base_damage = 0
  t_cbtplayer.player_base_ammo = 0
  t_cbtplayer.player_base_defense = 0
  t_cbtplayer.player_base_critperc = 0
  t_cbtplayer.player_base_critdmg = 2
  t_cbtplayer.player_isCrit = false
  t_cbtplayer.player_nextCrit = false

  t_cbtplayer.player_damage_bonus_plus = 0
  t_cbtplayer.player_damage_bonus_multi = 0
  t_cbtplayer.player_ammo_bonus_plus = 0
  t_cbtplayer.player_defense_bonus_plus = 0
  t_cbtplayer.player_critperc_bonus_plus = 0

  t_cbtplayer.player_defense_bonus_multi = 0
  t_cbtplayer.player_grit = 0
  t_cbtplayer.player_critdmg_bonus_plus = 0
  t_cbtplayer.player_rampage = false
  t_cbtplayer.player_culling = 0
  t_cbtplayer.player_extrahit = 0

  t_cbtplayer.player_final_damage = t_cbtplayer.player_base_damage
  t_cbtplayer.player_final_ammo = t_cbtplayer.player_base_ammo
  t_cbtplayer.player_final_defense = t_cbtplayer.player_base_defense
  t_cbtplayer.player_final_critperc = t_cbtplayer.player_base_critperc
  t_cbtplayer.player_final_critdmg = t_cbtplayer.player_base_critdmg

  t_cbtplayer.vocal = false

  t_cbtplayer.player_damage_dealt_turn = 0

  t_cbtplayer.player_dead = false

  -- combat enemy

  t_cbtenemy.goons = {}

  t_cbtenemy.enemy_accuracy_bonus_minus = 0

  -- player

  t_player.player = display.newImageRect( t_groups.charactersGroup, "images/characters/aliza_tent.png", 61, 41 )
  t_player.player.x = display.contentCenterX - 150
  t_player.player.y = display.contentCenterY - 20
  t_player.player.type = "player"
  local playerShape = { -17,-20, 17,-20, 30,20, -30,20 }
  physics.addBody( t_player.player, "static", { shape=playerShape, bounce=0, friction=1, density=1, filter=t_cfilters.cfPlayer } )
  snoring()

  -- props

  t_cbtplayer.mirror_prop = display.newImage( t_groups.charactersGroup, "images/objects/magicMirror.png", 24, 41 )
  t_cbtplayer.mirror_prop.x = t_player.player.x + 45
  t_cbtplayer.mirror_prop.y = t_player.player.y - 12
  t_cbtplayer.mirror_prop.alpha = 0

  t_cbtplayer.lunchbox_deployed = false
  t_cbtplayer.lunchbox_active = false

  -- last turn indicator

  t_player.lastDamageDealt = display.newText( t_groups.uiGroup, "Ultimi danni: " .. t_cbtplayer.player_damage_dealt_turn, display.contentCenterX - 240, display.contentCenterY - 50, "GosmickSans.ttf", 10 )
  t_player.lastDamageDealt:setFillColor( 0, 0, 0 )

  t_player.lastDamageDealtBox = display.newRect( t_groups.uiGroup, t_player.lastDamageDealt.x, t_player.lastDamageDealt.y, 80, 20 )
  t_player.lastDamageDealtBox.fill = t_graphics.blueGradient
  t_player.lastDamageDealtBox.strokeWidth = 2
  t_player.lastDamageDealtBox:setStrokeColor( 0, 0, 0 )

  t_player.lastDamageDealt:toFront()

  -- player HPBar

  local playerIcon = display.newImage( t_groups.uiGroup, "images/characters/alizaPortrait.png", -24, 20 )
  t_playerHPB.playerMaxHP = 1000
  t_playerHPB.playerCurrentHP = 1000

  t_playerHPB.playerHPBar = display.newRect( t_groups.uiGroup, playerIcon.x + 10, playerIcon.y - 4, t_playerHPB.playerMaxHP / 10, 15 )
  t_playerHPB.playerHPBar.anchorX = -1
  t_playerHPB.playerHPBar:setFillColor( 0, 1, 0 )
  t_playerHPB.playerHPBar.strokeWidth = 2
  t_playerHPB.playerHPBar:setStrokeColor( 0, 0, 0, 1 )
  playerIcon:toFront()

  -- goons

  t_goons.goonsTotalCount = 4

  -- goons shape

  t_goons.tikeyShape = { -18,-39, 18,-39, 18,39, -18,39 }

  -- endings

  t_ending.endingTurns = 0
  t_ending.fortitudeLost = 0
  t_ending.damageDealt = 0

  -- techniques

  local techniquesSheetOptions =
  { frames =
    {
      -- 1) apple
      { x = 0, y = 0, width = 265, height = 130 },
      -- 2) lunchbox
      { x = 265, y = 0, width = 265, height = 130 },
      -- 3) mirror
      { x = 530, y = 0, width = 265, height = 130 },
      -- 3) music
      { x = 795, y = 0, width = 265, height = 130 },
      -- 3) rat
      { x = 1060, y = 0, width = 265, height = 130 },
      -- 3) wolfpaw
      { x = 1325, y = 0, width = 265, height = 130 },

    }
  }

  local techniquesSheet = graphics.newImageSheet( "images/objects/sheets/fablesSheet.png", techniquesSheetOptions )

  local techniques_types = {
    {	name = "apple", start = 1,	count = 1 },
  	{	name = "lunchbox", start = 2,	count = 1 },
  	{	name = "mirror",	start = 3, count = 1 },
    {	name = "music", start = 4,	count = 1 },
    {	name = "rat", start = 5,	count = 1 },
    {	name = "wolfpaw", start = 6,	count = 1 }
  }

  local techniques_Y1 = 180
  local techniques_X1 = -35
  local techniques_X2 = 250

  t_techniques.techniques_offered = {}

  t_techniques.technique_chosen = 0

  t_techniques.technique_1 = display.newSprite( t_groups.choicesGroup, techniquesSheet, techniques_types )
  t_techniques.technique_1.x = techniques_X1
  t_techniques.technique_1.y = techniques_Y1
  t_techniques.technique_1.anchorX = 0
  t_techniques.technique_1.anchorY = 0
  t_techniques.technique_1:setSequence( t_techniques.techniques_offered[1] )
  t_techniques.technique_1.alpha = 0
  t_techniques.technique_1.strokeWidth = 2
  t_techniques.technique_1:setStrokeColor( 0, 0, 0 )

  t_techniques.technique_2 = display.newSprite( t_groups.choicesGroup, techniquesSheet, techniques_types )
  t_techniques.technique_2.x = techniques_X2
  t_techniques.technique_2.y = techniques_Y1
  t_techniques.technique_2.anchorX = 0
  t_techniques.technique_2.anchorY = 0
  t_techniques.technique_2:setSequence( t_techniques.techniques_offered[2] )
  t_techniques.technique_2.alpha = 0
  t_techniques.technique_2.strokeWidth = 2
  t_techniques.technique_2:setStrokeColor( 0, 0, 0 )

  t_techniques.technique_1:addEventListener( "tap", techniqueTap )
  t_techniques.technique_2:addEventListener( "tap", techniqueTap )

end

-- show()
function scene:show( event )

  local sceneGroup = self.view
  local phase = event.phase

  if phase == "will" then

  elseif phase == "did" then
    physics.start()
    t_phases.playerTutorialPhase()
  end

end

---------------------
-- TUTORIAL BEGINS --
---------------------

-- player tutorial phase
t_phases.playerTutorialPhase = function()

  local function spawnGoons( i, type )
    local newgoon
    if type == "shieldy" then
      newgoon = display.newImageRect( t_groups.charactersGroup, "images/characters/tikey.png", 41, 82 )
      table.insert( t_cbtenemy.goons, newgoon )
      newgoon.x = math.random( display.contentCenterX + 130, display.contentCenterX + 160 )
      newgoon.y = math.random( display.contentCenterY - 55, display.contentCenterY - 40 )
      physics.addBody( newgoon, "static", { shape=t_goons.tikeyShape, filter=t_cfilters.cfEnemies } )
      newgoon.type = "goons"
      newgoon.race = "tikey"
      newgoon.hp = 60
      newgoon.index = #t_cbtenemy.goons
      newgoon.alpha = 0
      newgoon.fill.effect = "filter.pixelate"
      newgoon.fill.effect.numPixels = 14
      transition.fadeIn( newgoon, { time=1500 } )
      transition.to( newgoon.fill.effect, { time=1500, numPixels=1 } )
    else
      print("goon not available")
    end
  end

  local function spawnArrow( i, xpos, ypos, rotate )
    t_tutorial.arrow[i] = display.newSprite( t_groups.uiGroup, t_graphics.arrowSheet, t_graphics.arrow_actions )
    t_tutorial.arrow[i].x = xpos
    t_tutorial.arrow[i].y = ypos
    t_tutorial.arrow[i].rotation = rotate
    t_tutorial.arrow[i]:setSequence( "idle" )
    t_tutorial.arrow[i]:play()
  end

  local function deleteArrow( i )
    t_tutorial.arrow[i]:removeSelf()
    t_tutorial.arrow[i] = nil
  end

  local function narrateTutorial()
    local options = {
      parent = t_groups.uiGroup,
      text = t_tutorial.playerTutorial[t_tutorial.tutorialCounter],
      x = display.contentCenterX,
      y = display.contentCenterY - 90,
      fontSize = 15,
      font = "GosmickSans.ttf",
      align = "left"
    }

    t_tutorial.textField = display.newText( options )
    t_tutorial.textField:setTextColor(  0, 0, 0 )

    t_tutorial.textFieldBox = display.newRect( t_groups.uiGroup, t_tutorial.textField.x, t_tutorial.textField.y,
      t_tutorial.textField.width + 12, t_tutorial.textField.height + 10 )
    t_tutorial.textFieldBox.strokeWidth = 2
    t_tutorial.textFieldBox.fill = t_graphics.blueGradient
    t_tutorial.textFieldBox:setStrokeColor( 0, 0, 0 )

    t_tutorial.textField:toFront()

    if t_tutorial.tutorialCounter == 3 then
      spawnArrow( 1, t_player.player.x, t_player.player.y - 38, 90 )
    elseif t_tutorial.tutorialCounter == 4 then
      deleteArrow( 1 )
      spawnArrow( 2, t_playerHPB.playerHPBar.x + 40, t_playerHPB.playerHPBar.y + 35, -90 )
    elseif t_tutorial.tutorialCounter == 5 then
      deleteArrow( 2 )
    elseif t_tutorial.tutorialCounter == 7 then
      spawnArrow( 3, t_screenzs.optionTabImage.x - 50, t_screenzs.optionTabImage.y, 00 )
    elseif t_tutorial.tutorialCounter == 8 then
      deleteArrow( 3 )
      spawnGoons( 1, "shieldy" )
      spawnArrow( 4, t_cbtenemy.goons[1].x, t_cbtenemy.goons[1].y - 45, 90 )
    elseif t_tutorial.tutorialCounter == 9 then
      deleteArrow( 4 )
    elseif t_tutorial.tutorialCounter == 10 then
      resetTurnStats()
      renewTechniques()
      spawnArrow( 5, t_techniques.technique_1.x + 130, t_techniques.technique_1.y + 15, 90 )
      spawnArrow( 6, t_techniques.technique_2.x + 130, t_techniques.technique_2.y + 15, 90 )
    elseif t_tutorial.tutorialCounter == 15 then
      spawnGoons( 2, "shieldy" )
      spawnGoons( 3, "shieldy" )
      spawnGoons( 4, "shieldy" )
    elseif t_tutorial.tutorialCounter == 16 then
      t_goons.goonsCounter = display.newImage( t_groups.uiGroup, "images/icons/goonsCounter.png", 19, 19 )
      t_goons.goonsCounter.x = 485
      t_goons.goonsCounter.y = 62
      t_goons.goonsCounterText = display.newText( "x" .. tostring(t_goons.goonsTotalCount), 100, 200, "GosmickSans.ttf", 14 )
      t_goons.goonsCounterText.x = t_goons.goonsCounter.x + 22
      t_goons.goonsCounterText.y = t_goons.goonsCounter.y
      t_goons.goonsCounterText:setFillColor( 0, 0, 0 )
      spawnArrow( 7, t_goons.goonsCounter.x - 35, t_goons.goonsCounter.y, 0 )
    elseif t_tutorial.tutorialCounter == 17 then
      t_tutorial.textField:removeSelf()
      t_tutorial.textField = nil
      t_tutorial.textFieldBox:removeSelf()
      t_tutorial.textFieldBox = nil
      deleteArrow( 7 )
      t_phases.techniquesPhase()
    end
  end

  function t_tutorial.nextTutorial( event )
    if t_optionTab.opened == false then
      if t_tutorial.tutorialCounter ~= 10 then
        if t_tutorial.tutorialCounter == 17 then
          Runtime:removeEventListener( "tap", t_tutorial.nextTutorial )
        elseif event.x < t_screenzs.optionTabFieldBox.contentBounds.xMin or
          event.x > t_screenzs.optionTabFieldBox.contentBounds.xMax or
          event.y < t_screenzs.optionTabFieldBox.contentBounds.yMin or
          event.y > t_screenzs.optionTabFieldBox.contentBounds.yMax then
            t_tutorial.tutorialCounter = t_tutorial.tutorialCounter + 1
            if t_tutorial.textField ~= nil and t_tutorial.textFieldBox ~= nil then
              audio.play( t_audio.tutorialnext )
              t_tutorial.textField:removeSelf()
              t_tutorial.textField = nil
              t_tutorial.textFieldBox:removeSelf()
              t_tutorial.textFieldBox = nil
            end
            narrateTutorial()
        end
      end
    end
  end

  if t_tutorial.tutorialCounter ~= 11 then
    Runtime:addEventListener( "tap", t_tutorial.nextTutorial )
  end
  narrateTutorial()

end

----------------------
-- GAME FLOW BEGINS --
----------------------

-- techniques phase

t_phases.techniquesPhase = function()

  print("techniquesPhase()")
  transition.fadeIn( t_screenzs.optionTabFieldBox, { time=300 } )
  transition.fadeIn( t_screenzs.optionTabImage, { time=300 } )
  t_ending.endingTurns = t_ending.endingTurns + 1
  resetTurnStats()
  renewTechniques()

end

-- player attack phase

t_phases.playerAttackPhase = function()

  print("playerAttackPhase()")
  t_screenzs.optionTabFieldBox.alpha = 0
  t_screenzs.optionTabImage.alpha = 0
  calculatePlayerTurnStats()
  playerAttack()

end

-- enemy attack phase

t_phases.enemyAttackPhase = function()

  print("enemyAttackPhase()")
  if t_cbtplayer.mirror_prop.alpha > 0 then
    transition.fadeOut( t_cbtplayer.mirror_prop, { time=350 } )
  end
  timer.performWithDelay( 1200, t_phases.dreamCompleteCheckPhase )

end

t_phases.dreamCompleteCheckPhase = function()

  print("dreamCompleteCheckPhase()")
  if t_cbtplayer.player_dead == true then
    nightmareDream()
  elseif t_goons.goonsTotalCount == 0 then
    goodDream()
  elseif t_tutorial.tutorialCounter == 11 then
    t_phases.playerTutorialPhase()
  else
    t_phases.techniquesPhase()
  end

end

-- scene event listener
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )

return scene
