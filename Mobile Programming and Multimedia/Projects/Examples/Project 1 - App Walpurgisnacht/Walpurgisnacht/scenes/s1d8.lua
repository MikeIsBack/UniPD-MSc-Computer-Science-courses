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
  }
}

-- audio

local t_audio = {
  soundtrack, soundtrackPlay,
  crit, props,
  apple, toast, ray, singlenote, doublenote, rat, wolfpaw,
  won, lost,
  confirm, confirmnot
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
  goon_actions,

  tikey, tikeyShape,
  skeley,
  rosey, roseyShape,
  lampey,

  goonsCounter, goonsCounterText, goonsToSpawn, goonsSpawned, goonsKilled,
  tikeyInterval, skeleyInterval, roseyInterval
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
  settings.currentDream = 9
  gotoDreaming()
end

local function gotoSameDream()
  audio.play( t_audio.confirm )
  settings.currentDream = 8
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
    t_goons.goonsCounterText:removeSelf()
    t_goons.goonsCounterText = nil

    physics.stop()

    audio.stop( { channel=1 } )
    audio.dispose( t_audio.soundtrack )
    t_audio.soundtrackPlay = nil
    t_audio.soundtrack = nil
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
  spawnPhase, techniquesPhase, buffsPhase, battlePhase, playerAttackPhase, enemyAttackPhase, dreamCompleteCheckPhase
}

-- tables

local t_tables = {
  techniques_table, buffs_table, goons_table
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

    if t_techniques.technique_chosen == 0 then
      audio.play( t_audio.choice )
      t_techniques.technique_chosen = event.target.sequence
      if t_techniques.technique_chosen == "apple" then
        t_cbtplayer.player_base_damage = 9
        t_cbtplayer.player_base_critperc = 60
        t_cbtplayer.player_base_ammo = 3
        t_tables.buffs_table = {
          "coffin",
          "eyes",
          "fangs", "fangs", "fangs", "fangs",
          "mantis", "mantis", "mantis", "mantis",
          "gold", "gold",
        }
      elseif t_techniques.technique_chosen == "lunchbox" then
        t_cbtplayer.player_base_damage = 1
        t_cbtplayer.player_base_critperc = 0
        t_cbtplayer.player_base_ammo = 1
        t_tables.buffs_table = {
          "coffin", "coffin", "coffin", "coffin", "coffin", "coffin"
        }
      elseif t_techniques.technique_chosen == "mirror" then
        t_cbtplayer.player_base_damage = 6
        t_cbtplayer.player_base_critperc = 0
        t_cbtplayer.player_base_ammo = 1
        transition.fadeIn( t_cbtplayer.mirror_prop, { time=350 } )
        t_tables.buffs_table = {
          "coffin", "coffin",
          "eyes", "eyes",
          "mantis", "mantis",
          "gold", "gold", "gold", "gold",
          "tentacle", "tentacle", "tentacle", "tentacle"
        }
      elseif t_techniques.technique_chosen == "music" then
        t_cbtplayer.player_base_damage = 8
        t_cbtplayer.player_base_critperc = 40
        t_cbtplayer.player_base_ammo = 3
        t_tables.buffs_table = {
          "coffin",
          "eyes", "eyes",
          "fangs", "fangs", "fangs", "fangs",
          "mantis", "mantis", "mantis", "mantis",
          "gold", "gold", "gold", "gold",
          "tentacle", "tentacle", "tentacle"
        }
      elseif t_techniques.technique_chosen == "rat" then
        t_cbtplayer.player_base_damage = 4
        t_cbtplayer.player_base_critperc = 20
        t_cbtplayer.player_base_ammo = 6
        t_tables.buffs_table = {
          "coffin", "coffin", "coffin", "coffin",
          "eyes", "eyes", "eyes", "eyes",
          "fangs", "fangs",
          "mantis", "mantis", "mantis", "mantis",
          "gold", "gold",
          "tentacle", "tentacle",
        }
      elseif t_techniques.technique_chosen == "wolfpaw" then
        t_cbtplayer.player_base_damage = 1
        t_cbtplayer.player_base_critperc = 0
        t_cbtplayer.player_base_ammo = 8
        t_tables.buffs_table = {
          "coffin", "coffin",
          "eyes", "eyes", "eyes",
          "mantis",
          "gold", "gold", "gold", "gold",
          "tentacle", "tentacle", "tentacle", "tentacle"
        }
      end
    	print("technique chosen: " .. t_techniques.technique_chosen)
      transition.fadeOut( t_techniques.technique_1, { time=500 } )
    	transition.fadeOut( t_techniques.technique_2, { time=500 } )
      timer.performWithDelay( 500, t_phases.buffsPhase )
    end

  end

end

-- buffs

local t_buffs = {
  buffsSheetOptions, buffsSheet, buffs_types,

  buffs_X, buffs_Y,

  buffs_X1, buffs_X2, buffs_X3, buffs_Y1, buffs_Y2,

  buffs, buffs_offered, buffs_chosen, buffs_chosen_color,

  max_choices_number, current_choices_number,

  technique_chosen_reminder
}

-- buffs phase stuff

function shuffleBuffs()

	print("shuffleBuffs()")

  local num
  for i=0, 5 do
    num = math.random( 1, #t_tables.buffs_table)
    t_buffs.buffs_offered[i+1] = t_tables.buffs_table[num]
    table.remove( t_tables.buffs_table, num)
  end

end

local function buffsTap( event )

  print("buffsTap()")

  if event.target.chosen == 0 and t_buffs.current_choices_number <= t_buffs.max_choices_number then
    audio.play( t_audio.choice )
    t_buffs.buffs_chosen[t_buffs.current_choices_number] = event.target.sequence
    t_buffs.buffs_chosen_color[t_buffs.current_choices_number] = event.target.color
    event.target.chosen = t_buffs.current_choices_number
    event.target:setStrokeColor( 1, 1, 1 )
    event.target.strokeWidth = 4
    print("current choices number: " .. t_buffs.current_choices_number)
    t_buffs.current_choices_number = t_buffs.current_choices_number + 1
    if t_buffs.current_choices_number > t_buffs.max_choices_number then
      timer.performWithDelay( 200, t_phases.battlePhase )
      print("buffs chosen: " .. t_buffs.buffs_chosen[1] .. " " .. t_buffs.buffs_chosen[2] .. " " .. t_buffs.buffs_chosen[3] .. " " .. t_buffs.buffs_chosen[4])
      print("buffs chosen color: " .. t_buffs.buffs_chosen_color[1] .. " " .. t_buffs.buffs_chosen_color[2] .. " " .. t_buffs.buffs_chosen_color[3] .. " " .. t_buffs.buffs_chosen_color[4])
    end
  elseif event.target.chosen > 0 and t_buffs.current_choices_number <= t_buffs.max_choices_number then
    audio.play( t_audio.choice )
    event.target.chosen = 0
    event.target.strokeWidth = 2
    event.target:setStrokeColor( 0, 0, 0 )
    t_buffs.current_choices_number = t_buffs.current_choices_number - 1
    t_buffs.buffs_chosen[event.target.chosen] = t_buffs.buffs_chosen[t_buffs.current_choices_number]
    t_buffs.buffs_chosen[t_buffs.current_choices_number] = 0
    t_buffs.buffs_chosen_color[t_buffs.current_choices_number] = nil
  end

end

-- battle phase stuff

local function calculateBuffs()

  print("calculateBuffs()")

  for i=1, 4 do
    print("calculating buff " .. t_buffs.buffs_chosen[i] .. " with index: " .. i)
    if t_buffs.buffs_chosen[i] == "coffin" then
      t_cbtplayer.player_defense_bonus_plus = t_cbtplayer.player_defense_bonus_plus + 1
      print("-one more defense-")
    elseif t_buffs.buffs_chosen[i] == "eyes" then
      t_cbtenemy.enemy_accuracy_bonus_minus = t_cbtenemy.enemy_accuracy_bonus_minus + 1
      print("-enemies one less accuracy-")
    elseif t_buffs.buffs_chosen[i] == "fangs" then
      t_cbtplayer.player_damage_bonus_multi = t_cbtplayer.player_damage_bonus_multi + 1
      print("-10% more damage-")
    elseif t_buffs.buffs_chosen[i] == "mantis" then
      t_cbtplayer.player_critperc_bonus_plus = t_cbtplayer.player_critperc_bonus_plus + 20
      print("-20% more critperc-")
    elseif t_buffs.buffs_chosen[i] == "gold" then
      t_cbtplayer.player_ammo_bonus_plus = t_cbtplayer.player_ammo_bonus_plus + 1
      print("-more ammo-")
    elseif t_buffs.buffs_chosen[i] == "tentacle" then
      t_cbtplayer.player_damage_bonus_plus = t_cbtplayer.player_damage_bonus_plus + 1
      print("-one more damage-")
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
  print("player final defense: " .. t_cbtplayer.player_final_defense)

  print("player base critperc: " .. t_cbtplayer.player_base_critperc)
  t_cbtplayer.player_final_critperc = t_cbtplayer.player_base_critperc + t_cbtplayer.player_critperc_bonus_plus
  print("player final critperc: " .. t_cbtplayer.player_final_critperc)

  t_cbtplayer.player_final_critdmg = t_cbtplayer.player_base_critdmg + t_cbtplayer.player_critdmg_bonus_plus

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
    print("goon index: " .. enemyObj.index .. " is dead")
    table.remove( t_cbtenemy.goons, enemyObj.index )
    for i=enemyObj.index, #t_cbtenemy.goons do
      print("goon position: " .. i .. " had index " .. t_cbtenemy.goons[i].index)
      t_cbtenemy.goons[i].index = t_cbtenemy.goons[i].index - 1
      print("goon position: " .. i .. " has now index " .. t_cbtenemy.goons[i].index)
    end
    display.remove( enemyObj )
    enemyObj = nil
    t_goons.goonsKilled = t_goons.goonsKilled + 1
    t_goons.goonsCounterText.text = "x" .. tostring( t_goons.goonsToSpawn + t_goons.goonsSpawned - t_goons.goonsKilled )
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
      local dmg = t_cbtplayer.player_final_damage + math.random( 0, 2 ) - event.other.defense_plus
      if dmg < 0 then
        dmg = 0
      end
      damageEnemy( dmg, event.other )
    end
    if self.type == "apple" then -- apple
      event.other.accuracy_minus = event.other.accuracy_minus + 0.3 * t_cbtenemy.enemy_accuracy_bonus_minus
      audio.play( t_audio.apple )
      display.remove( self )
      self = nil
    elseif self.type == "toast" then -- lunchbox
      event.other.accuracy_minus = event.other.accuracy_minus + 0.2 * t_cbtenemy.enemy_accuracy_bonus_minus
      audio.play( t_audio.toast )
      display.remove( self )
      self = nil
    elseif self.type == "ray" then -- mirror
      event.other.accuracy_minus = event.other.accuracy_minus + 0.15 * t_cbtenemy.enemy_accuracy_bonus_minus
      self.refraction = self.refraction + 1
    elseif self.type == "singlenote" then -- music
      event.other.accuracy_minus = event.other.accuracy_minus + 0.2 * t_cbtenemy.enemy_accuracy_bonus_minus
      audio.play( t_audio.singlenote )
      display.remove( self )
      self = nil
    elseif self.type == "doublenote" then -- music
      event.other.accuracy_minus = event.other.accuracy_minus + 0.4 * t_cbtenemy.enemy_accuracy_bonus_minus
      audio.play( t_audio.doublenote )
      if self.strong == true then
        self.strong = false
      else
        display.remove( self )
        self = nil
      end
    elseif self.type == "rat" then -- rat
      event.other.accuracy_minus = event.other.accuracy_minus + t_cbtenemy.enemy_accuracy_bonus_minus
      audio.play( t_audio.rat )
      display.remove( self )
      self = nil
    elseif self.type == "wolfpaw" then -- wolfpaw
      event.other.accuracy_minus = event.other.accuracy_minus + 0.1 * t_cbtenemy.enemy_accuracy_bonus_minus
      audio.play( t_audio.wolfpaw )
    end
    print("goon accuracy reduced by " .. event.other.accuracy_minus)
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
      audio.play( t_audio.ray )
      transition.to( bullet, { width=300, x=600, time=400 } )
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
      transition.to( bullet, { x=600, y=math.random( t_player.player.y - 60, t_player.player.y ), time=2400, transition=easing.outQuad } )
      transition.to( bullet, { time=350, onComplete=playerAttack } )
    -- rat
    elseif t_techniques.technique_chosen == "rat" then
      bullet = display.newImageRect( t_groups.bulletsGroup, "images/objects/rat.png", 20, 10 )
      local ratShape = { 6,-6, 6,6, -6,6, -6,-6 }
      physics.addBody( bullet, "dynamic", { shape=ratShape, isSensor=true, isBullet=true, density=0.8, bounce=0.1, friction=0.3, filter=cfPlayerbullets } )
      bullet.x = math.random( 300, 400 )
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
    if t_techniques.technique_chosen == "apple"
      or t_techniques.technique_chosen == "music"
      or t_techniques.technique_chosen == "rat" then
        timer.performWithDelay( 1000, t_phases.enemyAttackPhase )
    else
      t_phases.enemyAttackPhase()
    end
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

  t_buffs.current_choices_number = 1

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

-- renew buffs

local function renewBuffs()

	print("renewBuffs()")

	shuffleBuffs()

  for i=1, 6 do
    t_buffs.buffs[i]:setSequence( t_buffs.buffs_offered[i] )
    if t_buffs.buffs[i].chosen > 0 then
      t_buffs.buffs[i].chosen = 0
      t_buffs.buffs[i].strokeWidth = 2
      t_buffs.buffs[i]:setStrokeColor( 0, 0, 0 )
    end
    t_buffs.buffs[i].background = display.newRect( t_groups.choicesGroup, t_buffs.buffs[i].x, t_buffs.buffs[i].y, 176, 60 )
    t_buffs.buffs[i].background.anchorX = 0
    t_buffs.buffs[i].background.anchorY = 0
    t_buffs.buffs[i].background.alpha = 0

    local color_num = math.random( 0, 2 )
    if color_num == 1 then
      t_buffs.buffs[i].color = "orange"
      t_buffs.buffs[i].background.fill = { type="image", filename="images/graphics/buffHammelinOrange.png" }
    elseif color_num == 2 then
      t_buffs.buffs[i].color = "red"
      t_buffs.buffs[i].background.fill = { type="image", filename="images/graphics/buffRidingRed.png" }
    else
      t_buffs.buffs[i].color = "white"
      t_buffs.buffs[i].background.fill = { type="image", filename="images/graphics/buffSnowWhite.png" }
    end
    t_buffs.buffs[i].background.fill = { type="image", filename="images/graphics/buffNeutral.png" } -- colori non introdotti
    t_buffs.buffs[i]:toFront()
    transition.fadeIn( t_buffs.buffs[i], { time=500 } )
    transition.fadeIn( t_buffs.buffs[i].background, { time=500 } )
  end

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

  local endingTitle = display.newText( t_groups.superGroup, "Aliza è stata rapita", display.contentCenterX, 40, "Mikodacs.otf", 40 )
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

  local retryButton = display.newImageRect( t_groups.superGroup, "images/graphics/button_retry.png", 94, 94 )
  retryButton.x = display.contentCenterX + 135
  retryButton.y = 235
  retryButton.alpha = 0
  retryButton:addEventListener( "tap", gotoSameDream )
  transition.fadeIn( retryButton, { time=1000 } )

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

local function damagePlayer( damage )

	print("damagePlayer()")
  print("player would lose " .. damage .. " fortitude")
  damage = damage - t_cbtplayer.player_final_defense
  if damage < 0 then
    damage = 0
  end
  print("player would lose " .. damage .. " fortitude with -defense")
  t_ending.fortitudeLost = t_ending.fortitudeLost + damage
	t_playerHPB.playerCurrentHP = t_playerHPB.playerCurrentHP - damage
	t_playerHPB.playerHPBar.width = t_playerHPB.playerCurrentHP / 3

  local damageText = display.newText( t_groups.uiGroup, damage, t_player.player.x - math.random( 12, 22 ), t_player.player.y - math.random( -6, 10 ), "GosmickSans.ttf", 9 )
  damageText:setFillColor( 0, 0, 0 )
  local vertices = { 0,-10, 3,-4, 10,-3, 5,3, 7,11, 0,8, -7,11, -5,3, -10,-3, -3,-4 }
  local damageBubble = display.newPolygon( t_groups.uiGroup, damageText.x, damageText.y, vertices )
  damageBubble.fill = { type="image", filename="images/graphics/starfill_yellow.png" }
  damageText:toFront()
  transition.to( damageBubble, { time=800, alpha=0, y=damageBubble.y-30, rotation=240, onComplete=function(damageBubble) damageBubble:removeSelf(); damageBubble=nil; end } )
  transition.to( damageText, { time=800, alpha=0, y=damageText.y-30, onComplete=function(damageText) damageText:removeSelf(); damageText=nil; end } )

	if t_playerHPB.playerCurrentHP <= 0 then
		display.remove( t_playerHPB.playerHPBar )
    t_cbtplayer.player_dead = true
	elseif t_playerHPB.playerCurrentHP <= 50 then
		t_playerHPB.playerHPBar:setFillColor( 1, 0, 0 )
	elseif t_playerHPB.playerCurrentHP <= 150 then
		t_playerHPB.playerHPBar:setFillColor( 1, 1, 0 )
	end

end

local function helpEnemy( enemyObj, color )

    print("helpEnemy()")
    local vertices = { -8,7, 0,-7, 8,7 }
    local helpBubble = display.newPolygon( t_groups.uiGroup, enemyObj.x, enemyObj.y - 10, vertices )
    helpBubble.fill = color
    helpBubble:setStrokeColor( 0, 0, 0 )
    helpBubble.strokeWidth = 1
    transition.to( helpBubble, { time=1500, alpha=0, y=helpBubble.y-40, onComplete=function(helpBubble) helpBubble:removeSelf(); helpBubble=nil; end } )

end

local function enemyBulletCollision( self, event )

  print("enemyBulletCollision")
  if event.other.type == "player" then
    if self.type == "bone" then -- skeley
      audio.play( t_audio.bone )
      damagePlayer( 4 + self.damage_plus + math.random( 0, 2 ) )
      display.remove( self )
      self = nil
    elseif self.type == "petal" then -- rosey
      audio.play( t_audio.petal )
      damagePlayer( self.damage_plus + math.random( 1, 5 ) )
      display.remove( self )
      self = nil
    end
  elseif ( event.other.type == "boss" or event.other.type == "goons" ) and event.other.race ~= "lampey" then
    if self.type == "charge_yellow" then -- lampey
      audio.play( t_audio.charge )
      helpEnemy( event.other, { 1, 1, 0 } )
      event.other.hp = event.other.maxhp
      display.remove( self )
      self = nil
    elseif self.type == "charge_orange" then -- lampey
      audio.play( t_audio.charge )
      helpEnemy( event.other, { 1, 0.65, 0 } )
      event.other.damage_plus = event.other.damage_plus + math.random( 1, 3 )
      display.remove( self )
      self = nil
    end
  elseif event.other.type == "ground" then
    transition.to( self, { time=50, alpha=0, onComplete=function(self) display.remove(self); self=nil; end } )
  end

end

local function enemyAttack()

  print("enemyAttack()")
  if #t_cbtenemy.goons <= 0 then
    print("no enemies alive attacking player")
    timer.performWithDelay( 500, t_phases.dreamCompleteCheckPhase )
  else
    for i=1, #t_cbtenemy.goons do
      print("goon index: " .. t_cbtenemy.goons[i].index .. " attacks with accuracy " .. t_cbtenemy.goons[i].accuracy_minus)
      if t_cbtenemy.goons[i].race == "skeley" then
        print("skeley attacks")
        local bullet = display.newImageRect( t_groups.bulletsGroup, "images/objects/bone.png", 12, 12 )
        physics.addBody( bullet, "dynamic", { radius=7, isSensor=true, isBullet=true, density=3.8, filter=t_cfilters.cfEnemybullets } )
        bullet.x = t_cbtenemy.goons[i].x - 5
        bullet.y = t_cbtenemy.goons[i].y - 5
        bullet.type = "bone"
        bullet.damage_plus = t_cbtenemy.goons[i].damage_plus
        bullet.collision = enemyBulletCollision
        bullet:addEventListener("collision")
        bullet:applyLinearImpulse( -( math.random( 56, 60 ) / ( 10 - t_cbtenemy.goons[i].accuracy_minus ) ), math.random( -32, -26 ) / ( 10 - t_cbtenemy.goons[i].accuracy_minus ), bullet.x, bullet.y )
        transition.to( bullet, { rotation=1080, time=3000 } )
      elseif t_cbtenemy.goons[i].race == "rosey" then
        for p=1, t_cbtenemy.goons[i].petals do
          local bullet = display.newImageRect( t_groups.bulletsGroup, "images/objects/petal.png", 22, 10 )
          physics.addBody( bullet, "dynamic", { radius=3, isSensor=true, isBullet=true, filter=t_cfilters.cfEnemybullets } )
          bullet.gravityScale = 0
          bullet.x = t_cbtenemy.goons[i].x - 5
          bullet.y = t_cbtenemy.goons[i].y + math.random( -8, 14 )
          bullet.type = "petal"
          bullet.damage_plus = t_cbtenemy.goons[i].damage_plus
          bullet.collision = enemyBulletCollision
          bullet:addEventListener("collision")
          if math.random( 0, 3 ) >= t_cbtenemy.goons[i].accuracy_minus then
            transition.to( bullet, { delay=math.random( 0, 300 ), x=-200, time=900 } )
          else
            bullet.rotation = 180
            transition.to( bullet, { delay=math.random( 0, 300 ), x=600, time=200 } )
          end
        end
        if t_cbtenemy.goons[i].petals == 5 then
          t_cbtenemy.goons[i].petals = 1
        else
          t_cbtenemy.goons[i].petals = t_cbtenemy.goons[i].petals + 1
        end
      elseif t_cbtenemy.goons[i].race == "lampey" then
        print("lampey attacks (helps)")
        local num = math.random( 0, 1 )
        print("random num:" .. num)
        if num == 0 then
          local bullet = display.newImageRect( t_groups.bulletsGroup, "images/objects/charge_yellow.png", 10, 13 )
          physics.addBody( bullet, "dynamic", { radius=5, isSensor=true, isBullet=true, density=3.0, filter=t_cfilters.cfPlayerbullets } )
          bullet.x = t_cbtenemy.goons[i].x
          bullet.y = t_cbtenemy.goons[i].y - 5
          bullet.type = "charge_yellow"
          bullet.collision = enemyBulletCollision
          bullet:addEventListener("collision")
          bullet:applyLinearImpulse( math.random( -10, -4 ) / 10, math.random( -14, -8 ) / 10, bullet.x, bullet.y )
          transition.to( bullet, { rotation=1080, time=2000 } )
        else
          local bullet = display.newImageRect( t_groups.bulletsGroup, "images/objects/charge_orange.png", 10, 13 )
          physics.addBody( bullet, "dynamic", { radius=5, isSensor=true, isBullet=true, density=3.0, filter=t_cfilters.cfPlayerbullets } )
          bullet.x = t_cbtenemy.goons[i].x
          bullet.y = t_cbtenemy.goons[i].y - 5
          bullet.type = "charge_orange"
          bullet.collision = enemyBulletCollision
          bullet:addEventListener("collision")
          bullet:applyLinearImpulse( math.random( -10, -4 ) / 10, math.random( -14, -8 ) / 10, bullet.x, bullet.y )
          transition.to( bullet, { rotation=1080, time=2000 } )
        end
      end
      t_cbtenemy.goons[i].accuracy_minus = 0
    end
    timer.performWithDelay( 1500, t_phases.dreamCompleteCheckPhase )
  end

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

  t_audio.bone = audio.loadSound( "sounds/effects/bone.mp3" )
  t_audio.petal = audio.loadSound( "sounds/effects/petal.mp3" )
  t_audio.charge = audio.loadSound( "sounds/effects/charge.mp3" )

  t_audio.soundtrackPlay = audio.play( t_audio.soundtrack, { channel=1, loops=-1 } )

  -- optionTab

  t_optionTab.opened = false

  -- collision filters

  t_cfilters.cfGround = { categoryBits=1, maskBits=30 }
  t_cfilters.cfPlayer = { categoryBits=2, maskBits=17 }
  t_cfilters.cfEnemies = { categoryBits=4, maskBits=13 }
  t_cfilters.cfPlayerbullets = { categoryBits=8, maskBits=29 } -- con player per buff, con enemies per blocco
  t_cfilters.cfEnemybullets = { categoryBits=16, maskBits=7 } -- con enemies per buff

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
  t_playerHPB.playerMaxHP = 300
  t_playerHPB.playerCurrentHP = 300

  t_playerHPB.playerHPBar = display.newRect( t_groups.uiGroup, playerIcon.x + 10, playerIcon.y - 4, t_playerHPB.playerMaxHP / 3, 15 )
  t_playerHPB.playerHPBar.anchorX = -1
  t_playerHPB.playerHPBar:setFillColor( 0, 1, 0 )
  t_playerHPB.playerHPBar.strokeWidth = 2
  t_playerHPB.playerHPBar:setStrokeColor( 0, 0, 0, 1 )
  playerIcon:toFront()

  -- goons shape

  t_goons.tikeyShape = { -18,-39, 18,-39, 18,39, -18,39 }
  t_goons.roseyShape = { -22,-14, 0,-30, 22,-14, 0,30 }

  -- goons counting

  t_goons.goonsToSpawn = 10
  t_goons.goonsSpawned = 0
  t_goons.goonsKilled = 0
  t_goons.tikeyInterval = -1
  t_goons.skeleyInterval = -1
  t_goons.roseyInterval = -1

  t_goons.goonsCounter = display.newImage( t_groups.uiGroup, "images/icons/goonsCounter.png", 19, 19 )
  t_goons.goonsCounter.x = 485
  t_goons.goonsCounter.y = 62
  t_goons.goonsCounterText = display.newText( "x" .. tostring( t_goons.goonsToSpawn ), 100, 200, "GosmickSans.ttf", 14 )
  t_goons.goonsCounterText.x = t_goons.goonsCounter.x + 22
  t_goons.goonsCounterText.y = t_goons.goonsCounter.y
  t_goons.goonsCounterText:setFillColor( 0, 0, 0 )

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

  -- buffs

  t_buffs.buffsSheetOptions =
  { frames =
    {
      -- 1) coffin
      { x = 0, y = 0, width = 176, height = 60 },
      -- 2) eyes
      { x = 176, y = 0, width = 176, height = 60 },
      -- 3) fangs
      { x = 352, y = 0, width = 176, height = 60 },
      -- 4) gold
      { x = 528, y = 0, width = 176, height = 60 },
      -- 5) mantis
      { x = 704, y = 0, width = 176, height = 60 },
      -- 6) tentacle
      { x = 880, y = 0, width = 176, height = 60 },
    }
  }

  t_buffs.buffsSheet = graphics.newImageSheet( "images/objects/sheets/buffsSheet.png", t_buffs.buffsSheetOptions )

  t_buffs.buffs_types = {
  	{ name = "coffin", start = 1, count = 1 },
  	{	name = "eyes", start = 2,	count = 1 },
  	{	name = "fangs", start = 3,	count = 1	},
    {	name = "gold", start = 4,	count = 1 },
    {	name = "mantis", start = 5,	count = 1 },
    {	name = "tentacle", start = 6,	count = 1 }
  }

  t_buffs.buffs_X = { -34, 152, 338 }
  t_buffs.buffs_Y = { 180, 250 }

  t_buffs.buffs_X1 = -34
  t_buffs.buffs_X2 = 152
  t_buffs.buffs_X3 = 338
  t_buffs.buffs_Y1 = 180
  t_buffs.buffs_Y2 = 250

  t_buffs.buffs = {}
  t_buffs.buffs_offered = {}
  t_buffs.buffs_chosen = {}
  t_buffs.buffs_chosen_color = {}

  t_buffs.max_choices_number = 4
  t_buffs.current_choices_number = 1

  for i=1, 6 do
    t_buffs.buffs[i] = display.newSprite( t_groups.choicesGroup, t_buffs.buffsSheet, t_buffs.buffs_types )
    t_buffs.buffs[i]:setSequence( t_buffs.buffs_offered[i] )
    t_buffs.buffs[i].anchorX = 0
    t_buffs.buffs[i].anchorY = 0
    t_buffs.buffs[i].chosen = 0
    t_buffs.buffs[i].alpha = 0
    t_buffs.buffs[i].strokeWidth = 2
    t_buffs.buffs[i]:setStrokeColor( 0, 0, 0 )
    local color = math.random( 0, 2 )
    if color == 1 then
      t_buffs.buffs[i].color = "orange"
    elseif color == 2 then
      t_buffs.buffs[i].color = "red"
    else
      t_buffs.buffs[i].color = "white"
    end
    t_buffs.buffs[i]:addEventListener( "tap", buffsTap )
    if i <= 2 then
      t_buffs.buffs[i].x = t_buffs.buffs_X[1]
    elseif i <= 4 then
      t_buffs.buffs[i].x = t_buffs.buffs_X[2]
    else
      t_buffs.buffs[i].x = t_buffs.buffs_X[3]
    end
    if (i+1)%2 == 0 then
      t_buffs.buffs[i].y = t_buffs.buffs_Y[1]
    else
      t_buffs.buffs[i].y = t_buffs.buffs_Y[2]
    end

  end

end

-- show()
function scene:show( event )

  local sceneGroup = self.view
  local phase = event.phase

  if phase == "will" then

  elseif phase == "did" then
    physics.start()
    t_phases.spawnPhase()
  end

end

----------------------
-- GAME FLOW BEGINS --
----------------------

t_phases.spawnPhase = function()

  local function spawnGoons( race )
    local newgoon
    if race == "tikey" then
      newgoon = display.newImageRect( t_groups.charactersGroup, "images/characters/tikey.png", 41, 82 )
      table.insert( t_cbtenemy.goons, newgoon )
      t_goons.goonsToSpawn = t_goons.goonsToSpawn - 1
      t_goons.goonsSpawned = t_goons.goonsSpawned + 1
      print("new tikey added to index " .. #t_cbtenemy.goons)
      newgoon.x = math.random( display.contentCenterX + 20, display.contentCenterX + 60 )
      newgoon.y = math.random( display.contentCenterY - 55, display.contentCenterY - 40 )
      physics.addBody( newgoon, "static", { shape=t_goons.tikeyShape, filter=t_cfilters.cfEnemies } )
      newgoon.type = "goons"
      newgoon.race = "tikey"
      newgoon.maxhp = 90
      newgoon.hp = newgoon.maxhp
      newgoon.defense_plus = 2
      newgoon.damage_plus = 0
      newgoon.accuracy_minus = 0
      newgoon.index = #t_cbtenemy.goons
      newgoon.alpha = 0
      newgoon.fill.effect = "filter.pixelate"
      newgoon.fill.effect.numPixels = 14
      transition.fadeIn( newgoon, { time=1500 } )
      transition.to( newgoon.fill.effect, { time=1500, numPixels=1 } )
    elseif race == "skeley" then
      newgoon = display.newImageRect( t_groups.charactersGroup, "images/characters/skeley.png", 41, 41 )
      table.insert( t_cbtenemy.goons, newgoon )
      t_goons.goonsToSpawn = t_goons.goonsToSpawn - 1
      t_goons.goonsSpawned = t_goons.goonsSpawned + 1
      print("new skeley added to index " .. #t_cbtenemy.goons)
      newgoon.x = math.random( display.contentCenterX + 60, display.contentCenterX + 100 )
      newgoon.y = math.random( display.contentCenterY - 34, display.contentCenterY - 26 )
      physics.addBody( newgoon, "static", { radius=20, filter=t_cfilters.cfEnemies } )
      newgoon.type = "goons"
      newgoon.race = "skeley"
      newgoon.maxhp = 40
      newgoon.hp = newgoon.maxhp
      newgoon.defense_plus = 0
      newgoon.damage_plus = 0
      newgoon.accuracy_minus = 0
      newgoon.index = #t_cbtenemy.goons
      newgoon.alpha = 0
      newgoon.fill.effect = "filter.pixelate"
      newgoon.fill.effect.numPixels = 14
      transition.fadeIn( newgoon, { time=1500 } )
      transition.to( newgoon.fill.effect, { time=1500, numPixels=1 } )
    elseif race == "rosey" then
      newgoon = display.newImageRect( t_groups.charactersGroup, "images/characters/rosey.png", 44, 66 )
      table.insert( t_cbtenemy.goons, newgoon )
      t_goons.goonsToSpawn = t_goons.goonsToSpawn - 1
      t_goons.goonsSpawned = t_goons.goonsSpawned + 1
      print("new rosey added to index " .. #t_cbtenemy.goons)
      newgoon.x = math.random( display.contentCenterX + 140, display.contentCenterX + 180 )
      newgoon.y = display.contentCenterY - 30
      physics.addBody( newgoon, "static", { shape=t_goons.roseyShape, filter=t_cfilters.cfEnemies } )
      newgoon.type = "goons"
      newgoon.race = "rosey"
      newgoon.maxhp = 30
      newgoon.hp = newgoon.maxhp
      newgoon.defense_plus = 0
      newgoon.damage_plus = 0
      newgoon.accuracy_minus = 0
      newgoon.index = #t_cbtenemy.goons
      newgoon.alpha = 0
      newgoon.petals = 2
      newgoon.fill.effect = "filter.pixelate"
      newgoon.fill.effect.numPixels = 14
      transition.fadeIn( newgoon, { time=1500 } )
      transition.to( newgoon.fill.effect, { time=1500, numPixels=1 } )
    elseif race == "lampey" then
      newgoon = display.newImageRect( t_groups.charactersGroup, "images/characters/lampey.png", 41, 36 )
      table.insert( t_cbtenemy.goons, newgoon )
      t_goons.goonsToSpawn = t_goons.goonsToSpawn - 1
      t_goons.goonsSpawned = t_goons.goonsSpawned + 1
      print("new rosey added to index " .. #t_cbtenemy.goons)
      newgoon.x = math.random( display.contentCenterX + 100, display.contentCenterX + 160 )
      newgoon.y = display.contentCenterY - 40
      physics.addBody( newgoon, "static", { radius=20, filter=t_cfilters.cfEnemies } )
      newgoon.type = "goons"
      newgoon.race = "lampey"
      newgoon.maxhp = 60
      newgoon.hp = newgoon.maxhp
      newgoon.defense_plus = 0
      newgoon.damage_plus = 0
      newgoon.accuracy_minus = 0
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

  print("spawnPhase()")
  if t_goons.goonsToSpawn > 0 then
    spawnGoons( "skeley" )
    spawnGoons( "skeley" )
    spawnGoons( "skeley" )
    spawnGoons( "skeley" )
    spawnGoons( "skeley" )
    spawnGoons( "skeley" )
    spawnGoons( "rosey" )
    spawnGoons( "rosey" )
    spawnGoons( "rosey" )
    spawnGoons( "rosey" )
  end

  timer.performWithDelay( 250, t_phases.techniquesPhase )

end

-- techniques phase

t_phases.techniquesPhase = function()

  print("techniquesPhase()")
  transition.fadeIn( t_screenzs.optionTabFieldBox, { time=300 } )
  transition.fadeIn( t_screenzs.optionTabImage, { time=300 } )
  t_ending.endingTurns = t_ending.endingTurns + 1
  resetTurnStats()
  renewTechniques()
  if #t_cbtenemy.goons ~= nil then
    print("goons alive: " .. #t_cbtenemy.goons)
    for i=1, #t_cbtenemy.goons do
      print("goon race " .. t_cbtenemy.goons[i].race .. " with index " .. t_cbtenemy.goons[i].index .. " is still alive")
    end
  else
    print("goons alive: nil")
  end

end

-- buffs phase

t_phases.buffsPhase = function()

  print("buffsPhase()")
  renewBuffs()

end

-- battle phase

t_phases.battlePhase = function()

	print("battlePhase()")
  t_screenzs.optionTabFieldBox.alpha = 0
  t_screenzs.optionTabImage.alpha = 0
  for i=1, 6 do
    transition.fadeOut( t_buffs.buffs[i], { time=500 } )
    transition.fadeOut( t_buffs.buffs[i].background, { time=500 } )
  end
  timer.performWithDelay( 500, t_phases.playerAttackPhase )

end

-- player attack phase

t_phases.playerAttackPhase = function()

  print("playerAttackPhase()")
  calculateBuffs()
  calculatePlayerTurnStats()
  playerAttack()

end

-- enemy attack phase

t_phases.enemyAttackPhase = function()

  print("enemyAttackPhase()")
  if t_cbtplayer.mirror_prop.alpha > 0 then
    transition.fadeOut( t_cbtplayer.mirror_prop, { time=350 } )
  end
  timer.performWithDelay( 500, enemyAttack )

end

t_phases.dreamCompleteCheckPhase = function()

  print("dreamCompleteCheckPhase()")
  if t_cbtplayer.player_dead == true then
    nightmareDream()
  elseif t_goons.goonsKilled >= ( t_goons.goonsToSpawn + t_goons.goonsSpawned ) then
    goodDream()
  else
    t_phases.spawnPhase()
  end

end

-- scene event listener
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )

return scene
