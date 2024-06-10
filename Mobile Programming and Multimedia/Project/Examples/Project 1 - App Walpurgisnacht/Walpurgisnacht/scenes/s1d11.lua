-- componente necessaria alla gestione delle scene
local composer = require( "composer" )
-- componente necessaria alla gestione dei salvataggi permanenti dei dati
local loadsave = require( "loadsave" )

local scene = composer.newScene()

-- avvio della fisica
local physics = require( "physics" )

physics.start()
physics.setGravity( 0, 10 )

-- variabili inerenti ai gruppi

local t_groups = {
  backGroup, charactersGroup, bulletsGroup, choicesGroup, uiGroup, superGroup
}

-- variabili inerenti alla grafica di testo e box

local t_graphics = {
  blueGradient = {
    type = "gradient",
    color1 = { 0.19, 0.52, 0.96, 0.9 },
    color2 = { 0.42, 0.77, 0.93, 0.8 },
    direction = "down"
  }
}

-- variabili inerenti alla gestione del tutorial

local t_tutorial = {
  playerTutorial, textField, textFieldBox,
  tutorialCounter, nextTutorial
}

-- variabili inerenti alla gestione dell'audio

local t_audio = {
  soundtrack, soundtrackPlay,
  crit, props,
  apple, toast, ray, singlenote, doublenote, rat, wolfpaw,
  won, lost,
  confirm, confirmnot
}

-- variabili inerenti al menù delle opzioni

local t_optionTab = {
  opened, title,

  volumeButton, soundtrackButton, closeButton, exitButton
}

local t_buttontext = {
  volume, soundtrack, close, exit
}

-- -- variabili inerenti ai tipi di scagnozzi

local t_goons = {
  goon_actions,

  tikey, tikeyShape,
  skeley,
  rosey, roseyShape,
  lampey,

  goonsCounter, goonsCounterText, goonsToSpawn, goonsSpawned, goonsKilled,
  tikeyInterval, skeleyInterval, roseyInterval
}

-- funzione che salva i dati e va alla selezione scenario
local function gotoScenarios()
  audio.play( t_audio.confirmnot )
  loadsave.saveTable( settings, "settings.json" )
  composer.gotoScene( "scenes.s1_menu" )
end

-- funzione che salva i dati e va direttamente ad un sogno (il medesimo se ripetuto, oppure il prossimo)
local function gotoDreaming()
  settings.currentScenario = 1
  loadsave.saveTable( settings, "settings.json" )
  composer.removeScene( "scenes.dreaming" )
  composer.gotoScene( "scenes.dreaming" )
end

-- funzione che setta il valore del sogno di destinazione a quello successivo ed invoca gotoDreaming()
local function gotoNextDream()
  audio.play( t_audio.confirm )
  settings.currentDream = 12
  gotoDreaming()
end

-- funzione che setta il valore del sogno di destinazione a quello attuale ed invoca gotoDreaming()
local function gotoSameDream()
  audio.play( t_audio.confirm )
  settings.currentDream = 11
  gotoDreaming()
end

-- funzione per la visualizzazione del menù delle opzioni
local function openOptionTab()

  -- sequenza di funzioni interne ad openOptionTab()

  -- funzione per il delay della chiusura del menù delle opzioni
  -- senza un delay la chiusura del menù comporta la selezione di un attacco nella schermata sottostante
  local function openedTimer()
    t_optionTab.opened = false
  end

  -- funzione per la chiusura del menù delle opzioni
  -- cancellazione manuale obbligatoria di testo e box con la metodologia consiglia da Corona
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

  -- funzione per uscire dal livello corrente attraverso il menù delle opzioni
  -- rimuove grafica, fisica ed audio priam di uscire
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

  -- codice effettivo della funzione openOptionTab(), chiamata alla pressione dell'icona del meù
  if t_optionTab.opened == false then

    -- se il menù delle opzioni è attualmente chiuso, allora si apre
    t_optionTab.opened = true

    -- funzione per il controllo del volume globale
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

    -- funzione per il controllo del volume della musica di sottofondo
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

    -- funzione per la creazione di bottoni
    local function createButton( text, xpos, ypos, xsize, ysize, fontsize )
      local button = display.newImageRect( t_groups.superGroup, "images/graphics/menu_button.png", xsize, ysize )
      button.x = xpos
      button.y = ypos
      local buttontext = display.newText( t_groups.superGroup, text, button.x, button.y, "GosmickSans.ttf", fontsize )
      buttontext:setFillColor( 0, 0, 0 )
      return button, buttontext
    end

    -- creazione dello sfondo del menù delle opzioni
    t_optionTab.optionScreen = display.newRect( t_groups.superGroup, 0, 0, 400, 250 )
    t_optionTab.optionScreen.x = display.contentWidth / 2
    t_optionTab.optionScreen.y = display.contentHeight / 2
    t_optionTab.optionScreen:setFillColor( 0.84, 0.33, 0.33 )
    t_optionTab.optionScreen:setStrokeColor( 0, 0, 0 )
    t_optionTab.optionScreen.strokeWidth = 3
    t_optionTab.optionScreen:toFront()

    -- creazione del titolo del menù delle opzioni, in base al livello corrente
    t_optionTab.title = display.newText( t_groups.superGroup, "Aliza " .. settings.currentDream, display.contentCenterX, 70, "Mikodacs.otf", 36 )
    t_optionTab.title:setFillColor( 0, 0, 0 )

    local audioText

    -- creazione dei pulsanti riguardanti l'audio, il testo varia in base ai parametri all'apertura
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

    -- creazione del pulsante di uscita dal livello
    t_optionTab.exitButton, t_buttontext.exit = createButton( "Abbandona", display.contentCenterX, 245, 110, 40, 18 )
    t_optionTab.exitButton:addEventListener( "tap", exitDream )

    -- creazione del pulsante di chiusura del menù
    t_optionTab.closeButton, t_buttontext.close = createButton( "Chiudi", display.contentCenterX + 150, 257, 80, 35, 18 )
    t_optionTab.closeButton:addEventListener( "tap", closeOptionTab )

    audio.play( t_audio.confirm )

  else
    -- se il menù delle opzioni è attualmente aperto, allora si chiude
    closeOptionTab()
  end

end

-- variabili inerenti ai filtri di collisione

local t_cfilters = {
  cfGround, cfPlayer, cfEnemies, cfPlayerbullets, cfEnemybullets
}

-- variabili inerenti a zone importanti delle schermo

local t_screenzs = {
  background, groundShape, choicesGround,

  optionTabImage, optionTabFieldBox
}

-- variabili inerenti alle fasi di combattimento, compresa quella del tutorial

local t_phases = {
  playerTutorialPhase,

  spawnPhase, techniquesPhase, buffsPhase, battlePhase, playerAttackPhase, enemyAttackPhase, dreamCompleteCheckPhase
}

-- variabili inerenti alle tables

local t_tables = {
  techniques_table, buffs_table, goons_table
}

-- variabili inerenti al combattimento del giocatore

local t_cbtplayer = {
  player_base_damage, -- danno di base
  player_base_ammo,  -- numero di colpi di base
  player_base_defense, -- difesa di base
  player_base_critperc, -- percentuale di colpo critico di base
  player_base_critdmg, -- moltiplicatore del danno quando avviene un critico
  player_isCrit, -- definisce se è il colpo attuale è un critico
  player_nextCrit, -- definisce se il prossimo colpo sarà un critico, solo nel caso 3+ colori arancio

  player_damage_bonus_plus, -- danno bonus additivo
  player_damage_bonus_multi, -- danno bonus percentuale
  player_ammo_bonus_plus, -- numero di colpi bonus additivo
  player_defense_bonus_plus, -- difesa bonus additiva
  player_critperc_bonus_plus, -- percentuale di colpo critico bonus additivo

  player_defense_bonus_multi, -- difesa bonus percentuale
  player_grit, -- definisce se il giocatore accumula uno scudo, solo nel caso di 2+ colori rossi
  player_critdmg_bonus_plus, -- danno di colpo critico bonus additivo, solo nel caso di 2+ colori arancio
  player_rampage, -- abilità di critico garantito dopo un critico, solo nel caso 3+ colori arancio
  player_culling, -- abilità di aumentare il danno effettuato di 1 ad ogni colpo extra, solo nel caso di 3+ colori bianco
  player_extrahit, -- abilità di effettuare colpi extra, solo nel caso di 2+ colori bianco

  player_final_damage, -- danno finale
  player_final_ammo, -- numero di colpi finali
  player_final_defense, -- difesa finale
  player_final_critperc, -- percentuale di colpo critico finale
  player_final_critdmg, -- danno critico finale

  orange_count, -- contatore colore arancio
  red_count, -- contatore colore rosso
  white_count, -- contatore colore bianco

  player_current_ammo, -- numero di colpi correnti

  player_dead, -- status di vita attuale

  vocal, -- definisce se la prossima nota dell'attacco musica sarà singola o doppia
  mirror_prop, -- l'oggetto fisico dello specchio
  lunchbox_deployed, lunchbox_active, -- definiscono lo status dell'attacco portapranzo
  lunchbox_prop -- l'oggetto fisico del portapranzo
}

-- variabili inerenti al combattimento coi nemici

local t_cbtenemy = {
  goons, enemy_accuracy_bonus_minus
}

-- variabili inerenti al giocatore

local t_player = {
  player,

  lastDamageDealt, lastDamageDealtBox, lastDamageReceived, lastDamageReceivedBox
}

-- variabili inerenti alla barra della vita del giocatore

local t_playerHPB = {
  playerMaxHP, playerCurrentHP, playerHPBar, playerCurrentGrit
}

-- variabili inerenti alla fine del livello

local t_ending = {
  endingTurns, fortitudeLost, damageDone
}

-- variabili inerenti agli attacchi (prima scelta tra due tecniche legate alle favole)

local t_techniques = {
  techniquesSheet, techniques_types,
  technique_chosen, techniques_offered = {},
  technique_1, technique_2
}

-- sezione per la fase delle tecniche

-- listener per il tap sulla scelta della tecnica
local function techniqueTap( event )

  print("techniqueTap()")
  -- controllo sull'apertura del menù delle opzioni
  if t_optionTab.opened == false then

    t_cbtplayer.player_damage_dealt_turn = 0
    t_cbtplayer.player_damage_received_turn = 0

    -- controllo sulla tecnica non ancora scelta
    if t_techniques.technique_chosen == 0 then
      audio.play( t_audio.choice )
      t_techniques.technique_chosen = event.target.sequence
      -- impostazione dei parametri per le fasi successive in base alla tecnica scelta
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
        t_cbtplayer.white_count = t_cbtplayer.white_count + 1
      elseif t_techniques.technique_chosen == "lunchbox" then
        t_cbtplayer.player_base_damage = 1
        t_cbtplayer.player_base_critperc = 0
        t_cbtplayer.player_base_ammo = 1
        t_tables.buffs_table = {
          "coffin", "coffin", "coffin", "coffin", "coffin", "coffin"
        }
        t_cbtplayer.red_count = t_cbtplayer.red_count + 1
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
        t_cbtplayer.white_count = t_cbtplayer.white_count + 1
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
        t_cbtplayer.orange_count = t_cbtplayer.orange_count + 1
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
        t_cbtplayer.orange_count = t_cbtplayer.orange_count + 1
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
        t_cbtplayer.red_count = t_cbtplayer.red_count + 1
      end
    	print("technique chosen: " .. t_techniques.technique_chosen)
      transition.fadeOut( t_techniques.technique_1, { time=500 } )
    	transition.fadeOut( t_techniques.technique_2, { time=500 } )
      -- passaggio alla fase dei potenziamenti
      timer.performWithDelay( 500, t_phases.buffsPhase )
    end

  end

end

-- variabili inerenti ai potenziamenti

local t_buffs = {
  buffsSheetOptions, buffsSheet, buffs_types,

  buffs_X, buffs_Y,

  buffs_X1, buffs_X2, buffs_X3, buffs_Y1, buffs_Y2,

  buffs, buffs_offered, buffs_chosen, buffs_chosen_color,

  max_choices_number, current_choices_number,

  technique_chosen_reminder
}

-- sezione per la fase dei potenziamenti

-- funzione per il mescolamento casuale dei potenziamenti
function shuffleBuffs()

	print("shuffleBuffs()")

  local num
  for i=0, 5 do
    num = math.random( 1, #t_tables.buffs_table)
    t_buffs.buffs_offered[i+1] = t_tables.buffs_table[num]
    table.remove( t_tables.buffs_table, num)
  end

end

-- funzione per la scelta dei potenziamenti tramite tap
local function buffsTap( event )

  print("buffsTap()")

  -- se il potenziamento non era stato scelto e si possiedono ancora scelte (su 4 disponibili)
  if event.target.chosen == 0 and t_buffs.current_choices_number <= t_buffs.max_choices_number then
    audio.play( t_audio.choice )
    -- memorizzazione della scelta e del colore
    t_buffs.buffs_chosen[t_buffs.current_choices_number] = event.target.sequence
    t_buffs.buffs_chosen_color[t_buffs.current_choices_number] = event.target.color
    event.target.chosen = t_buffs.current_choices_number
    event.target:setStrokeColor( 1, 1, 1 )
    event.target.strokeWidth = 4
    print("current choices number: " .. t_buffs.current_choices_number)
    t_buffs.current_choices_number = t_buffs.current_choices_number + 1
    -- numero di scelte terminate
    if t_buffs.current_choices_number > t_buffs.max_choices_number then
      -- passaggio alla fase di combattimento
      timer.performWithDelay( 200, t_phases.battlePhase )
      print("buffs chosen: " .. t_buffs.buffs_chosen[1] .. " " .. t_buffs.buffs_chosen[2] .. " " .. t_buffs.buffs_chosen[3] .. " " .. t_buffs.buffs_chosen[4])
      print("buffs chosen color: " .. t_buffs.buffs_chosen_color[1] .. " " .. t_buffs.buffs_chosen_color[2] .. " " .. t_buffs.buffs_chosen_color[3] .. " " .. t_buffs.buffs_chosen_color[4])
    end
  -- se il potenziamento era già stato scelto e si possiedono ancora scelte
  elseif event.target.chosen > 0 and t_buffs.current_choices_number <= t_buffs.max_choices_number then
    -- il potenziamento e parametri allegati vengono de-selezionati ed azzerati
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

-- sezione per la fase del combattimento

-- funzione per il calcolo dei potenziamenti e delle abilità (i colori)
local function calculateBuffs()

  print("calculateBuffs()")

  -- ciclo per ciascuno dei 4 potenziamenti scelti
  -- l'efficacia dei potenziamenti varia poi in seguito in base all'attacco scelto precedentemente
  for i=1, 4 do
    print("calculating buff " .. t_buffs.buffs_chosen[i] .. " with index: " .. i)
    -- la bara conferisce +1 alla difesa (-1 ai danni nemici)
    if t_buffs.buffs_chosen[i] == "coffin" then
      t_cbtplayer.player_defense_bonus_plus = t_cbtplayer.player_defense_bonus_plus + 1
      print("-one more defense-")
    -- gli occhi conferiscono -1 alla precisione dei nemici (ad ogni contatto con l'attacco)
    elseif t_buffs.buffs_chosen[i] == "eyes" then
      t_cbtenemy.enemy_accuracy_bonus_minus = t_cbtenemy.enemy_accuracy_bonus_minus + 1
      print("-enemies one less accuracy-")
    -- le fauci conferiscono 10% danno extra
    elseif t_buffs.buffs_chosen[i] == "fangs" then
      t_cbtplayer.player_damage_bonus_multi = t_cbtplayer.player_damage_bonus_multi + 1
      print("-10% more damage-")
    -- le falci della mantide conferiscono 20% di percentuale di critico extra
    elseif t_buffs.buffs_chosen[i] == "mantis" then
      t_cbtplayer.player_critperc_bonus_plus = t_cbtplayer.player_critperc_bonus_plus + 20
      print("-20% more critperc-")
    -- l'oro conferisce 1 attacco extra
    elseif t_buffs.buffs_chosen[i] == "gold" then
      t_cbtplayer.player_ammo_bonus_plus = t_cbtplayer.player_ammo_bonus_plus + 1
      print("-more ammo-")
    -- i tentacoli conferiscono +1 al danno
    elseif t_buffs.buffs_chosen[i] == "tentacle" then
      t_cbtplayer.player_damage_bonus_plus = t_cbtplayer.player_damage_bonus_plus + 1
      print("-one more damage-")
    end

    -- calcolo dei colori scelti
    if t_buffs.buffs_chosen_color[i] == "orange" then
      t_cbtplayer.orange_count = t_cbtplayer.orange_count + 1
    elseif t_buffs.buffs_chosen_color[i] == "red" then
      t_cbtplayer.red_count = t_cbtplayer.red_count + 1
    elseif t_buffs.buffs_chosen_color[i] == "white" then
      t_cbtplayer.white_count = t_cbtplayer.white_count + 1
    end
  end

  print("calculating color perks")
  if t_cbtplayer.orange_count >= 3 then
    -- critico garantito dopo un critico
    t_cbtplayer.player_rampage = true
    print("-rampage active-")
    -- danno critico x3 al posto che x2
    t_cbtplayer.player_critdmg_bonus_plus = 1
    print("-crit damage x3-")
  elseif t_cbtplayer.orange_count == 2 then
    t_cbtplayer.player_critdmg_bonus_plus = 1
    print("-crit damage x3-")
  end
  if t_cbtplayer.red_count >= 3 then
    -- 20% meno danno subito
    t_cbtplayer.player_defense_bonus_multi = 20
    print("-20% more defense-")
    -- scudo in base al danno ricevuto (non contando difese) nel turno precedente
    t_cbtplayer.player_grit = 1
    print("-grit active-")
  elseif t_cbtplayer.red_count == 2 then
    t_cbtplayer.player_grit = 1
    print("-grit active-")
  end
  if t_cbtplayer.white_count >= 3 then
    -- danno che aumenta di 1 per ogni colpo extra effettuato
    t_cbtplayer.player_culling = 1
    print("-culling active-")
    -- possibilità di effettuare colpi extra
    t_cbtplayer.player_extrahit = 1
    print("-extrahit active-")
  elseif t_cbtplayer.white_count == 2 then
    t_cbtplayer.player_extrahit = 1
    print("-extrahit active-")
  end

end

-- funzione per il calcolo delle statistiche del turno corrente del giocatore
local function calculatePlayerTurnStats()

  print("calculatePlayerTurnStats()")

  -- l'efficacia di alcuni bonus varia in base all'attacco scelto, per bilanciarne la forza
  print("player base damage: " .. t_cbtplayer.player_base_damage)
  t_cbtplayer.player_final_damage = t_cbtplayer.player_base_damage + t_cbtplayer.player_damage_bonus_plus
  print("player damage plus: " .. t_cbtplayer.player_final_damage)
  t_cbtplayer.player_final_damage = math.round( t_cbtplayer.player_final_damage + t_cbtplayer.player_final_damage * ( t_cbtplayer.player_damage_bonus_multi / 10 ) )
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

-- funzione per mostrare il danno di un colpo speciale, con scelta del colore della stellina
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

-- funzione per mostrare il danno di un colpo extra, stellina bianca
local function extraHit( damage, enemyObj )

  print("extraHit()")
  local damageText = display.newText( t_groups.uiGroup, damage, enemyObj.x + math.random( 6, 14 ), enemyObj.y - math.random( -3, 13 ), "GosmickSans.ttf", 8 )
  damageText:setFillColor( 0, 0, 0 )
  local vertices = { 0,-10, 3,-4, 10,-3, 5,3, 7,11, 0,8, -7,11, -5,3, -10,-3, -3,-4 }
  local damageBubble = display.newPolygon( t_groups.uiGroup, damageText.x, damageText.y-1, vertices )
  damageBubble:setFillColor( 0.96, 0.96, 0.96 )
  damageBubble:scale( 0.8, 0.8 )
  damageText:toFront()
  transition.to( damageBubble, { time=600, alpha=0, y=damageBubble.y-20, rotation=100, onComplete=function(damageBubble) damageBubble:removeSelf(); damageBubble=nil; end } )
  transition.to( damageText, { time=600, alpha=0, y=damageText.y-20, onComplete=function(damageText) damageText:removeSelf(); damageText=nil; end } )

end

-- funzione per mostrare il danno di un colpo normale, stellina gialla sfumata
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

-- funzione per mostrare il danno di un colpo critico, stellina arancione sfumata
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

-- funzione per infliggere danno al nemico colpito
local function damageEnemy( damage, enemyObj )

	print("damageEnemy()")
  -- se un colpo critico garantito
  if t_cbtplayer.player_nextCrit == true then
    t_cbtplayer.player_nextCrit = false
    t_cbtplayer.player_isCrit = true
    damage = damage * t_cbtplayer.player_final_critdmg
    specialDealt( damage, enemyObj )
  -- se colpo critico random
  elseif math.random( 0, 100 ) < t_cbtplayer.player_final_critperc then
    t_cbtplayer.player_isCrit = true
    if t_cbtplayer.player_rampage == true then
      t_cbtplayer.player_nextCrit = true
    end
    damage = damage * t_cbtplayer.player_final_critdmg
    critDealt( damage, enemyObj )
  else
    -- se colpo normale
    hitDealt( damage, enemyObj )
  end

  -- aggiornamento statistiche fine livello
  t_cbtplayer.player_damage_dealt_turn = t_cbtplayer.player_damage_dealt_turn + damage
  t_player.lastDamageDealt.text = "Danni: " .. t_cbtplayer.player_damage_dealt_turn
  t_ending.damageDealt = t_ending.damageDealt + damage
  -- riduzione degli hp del nemico
  enemyObj.hp = enemyObj.hp - damage
  print("damaged goon for: " .. damage)
  print("goon hp: " .. enemyObj.hp)
  -- eliminazione del nemico
  if enemyObj.hp <= 0 then
    print("goon index: " .. enemyObj.index .. " is dead")
    table.remove( t_cbtenemy.goons, enemyObj.index )
    -- spostamento nella table dei nemici vivi con indici maggiori di quello eliminato
    -- funzionalità altrimenti non garantita da Lua
    for i=enemyObj.index, #t_cbtenemy.goons do
      print("goon position: " .. i .. " had index " .. t_cbtenemy.goons[i].index)
      t_cbtenemy.goons[i].index = t_cbtenemy.goons[i].index - 1
      print("goon position: " .. i .. " has now index " .. t_cbtenemy.goons[i].index)
    end
    display.remove( enemyObj )
    enemyObj = nil
    -- aggiornamento contatore nemici
    t_goons.goonsKilled = t_goons.goonsKilled + 1
    t_goons.goonsCounterText.text = "x" .. tostring( t_goons.goonsToSpawn + t_goons.goonsSpawned - t_goons.goonsKilled )
  end

  -- se abilità dei colpi extra, possibilità di infliggerne uno
  if t_cbtplayer.player_extrahit == 1 and math.random( 0, 3 ) == 3 and enemyObj ~= nil then
    if t_cbtplayer.player_culling > 0 then
      -- aumento del danno del giocatore di 1
      t_cbtplayer.player_culling = t_cbtplayer.player_culling + 1
    end
    local extradmg = math.random( 1, 2 )
    extraHit( extradmg, enemyObj )
    -- stessa procedura di sopra per statistiche ed eliminazione del nemico
    t_cbtplayer.player_damage_dealt_turn = t_cbtplayer.player_damage_dealt_turn + extradmg
    t_player.lastDamageDealt.text = "Danni: " .. t_cbtplayer.player_damage_dealt_turn
    t_ending.damageDealt = t_ending.damageDealt + extradmg
    enemyObj.hp = enemyObj.hp - extradmg
    print("extra damaged goon for: " .. extradmg)
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

end

-- funzione per la collisione dei proiettili del giocatore
local function playerBulletCollision( self, event )

  -- collisione con nemici
  if event.other.type == "boss" or event.other.type == "goons" then
    -- se raggio dell'attacco specchio, perde 1 di danno per ogni danno inflitto
    if self.type == "ray" then
      if t_cbtplayer.player_final_damage - self.refraction < 0 then
        damageEnemy( 0, event.other )
      else
        damageEnemy( t_cbtplayer.player_final_damage - self.refraction, event.other )
      end
    else
      -- danno aggiuntivo per l'abilità con 3 colori bianco
      print("enemy culled for " .. t_cbtplayer.player_culling)
      local dmg = t_cbtplayer.player_final_damage + math.random( 0, 2 ) + t_cbtplayer.player_culling - event.other.defense_plus
      if dmg < 0 then
        dmg = 0
      end
      damageEnemy( dmg, event.other )
    end
    -- suoni, modificatori di accuratezza nemica e altre caratteristiche dei vari attacchi
    if self.type == "apple" then -- mela
      event.other.accuracy_minus = event.other.accuracy_minus + 0.3 * t_cbtenemy.enemy_accuracy_bonus_minus
      audio.play( t_audio.apple )
      display.remove( self )
      self = nil
    elseif self.type == "toast" then -- portapranzo
      event.other.accuracy_minus = event.other.accuracy_minus + 0.2 * t_cbtenemy.enemy_accuracy_bonus_minus
      audio.play( t_audio.toast )
      display.remove( self )
      self = nil
    elseif self.type == "ray" then -- specchio
      event.other.accuracy_minus = event.other.accuracy_minus + 0.15 * t_cbtenemy.enemy_accuracy_bonus_minus
      self.refraction = self.refraction + 1
    elseif self.type == "singlenote" then -- musica nota singola
      event.other.accuracy_minus = event.other.accuracy_minus + 0.2 * t_cbtenemy.enemy_accuracy_bonus_minus
      audio.play( t_audio.singlenote )
      display.remove( self )
      self = nil
    elseif self.type == "doublenote" then -- musica nota doppia
      event.other.accuracy_minus = event.other.accuracy_minus + 0.4 * t_cbtenemy.enemy_accuracy_bonus_minus
      audio.play( t_audio.doublenote )
      if self.strong == true then
        self.strong = false
      else
        display.remove( self )
        self = nil
      end
    elseif self.type == "rat" then -- ratti
      event.other.accuracy_minus = event.other.accuracy_minus + t_cbtenemy.enemy_accuracy_bonus_minus
      audio.play( t_audio.rat )
      display.remove( self )
      self = nil
    elseif self.type == "wolfpaw" then -- zampa di lupo
      event.other.accuracy_minus = event.other.accuracy_minus + 0.1 * t_cbtenemy.enemy_accuracy_bonus_minus
      audio.play( t_audio.wolfpaw )
    end
    print("goon accuracy reduced by " .. event.other.accuracy_minus)
    t_cbtplayer.player_isCrit = false
  -- collisione con il terreno
  elseif event.other.type == "ground" then
    -- solo ia zampa di lupo non scompare quando collide col terreno
    if self.type ~= "wolfpaw" then
      transition.to( self, { time=50, alpha=0, onComplete=function(self) display.remove(self); self=nil; end } )
    end
  end

end

-- funzione per l'attacco del giocatore
local function playerAttack()

  print("playerAttack()")
  -- attacco del portapranzo se attivo
  if t_cbtplayer.lunchbox_deployed == true and t_cbtplayer.lunchbox_active == true then
    print("lunchbox burst -" .. t_cbtplayer.lunchbox_prop.burst)
    -- scoppio dei toast del portapranzo
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
      -- tiro di un singolo toast
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
  -- se l'attacco non ha finito munizioni
  if t_cbtplayer.player_current_ammo ~= 0 then
    -- mela
    -- traiettoria ad arco seguente la fisica
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
    -- portapranzo
    -- generazione dell'oggetto portapranzo
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
    -- specchio
    -- generazione dell'oggetto specchio e dei proiettili come veloci raggi lineari
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
    -- musica
    elseif t_techniques.technique_chosen == "music" then
      -- la nota pari è sempre doppia ed infligge due volte il danno
      if t_cbtplayer.vocal == true then
        bullet = display.newImageRect( t_groups.bulletsGroup, "images/objects/doubleNote.png", 19, 18 )
        physics.addBody( bullet, "dynamic", { radius=5, isSensor=true, isBullet=true, filter=t_cfilters.cfPlayerbullets } )
        bullet.type = "doublenote"
        bullet.strong = true
        t_cbtplayer.vocal = false
      else
        -- la nota dispari è sempre singola
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
    -- ratti
    -- cadono dal cielo secondo fisica con traiettorie random
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
    -- zampe di lupo
    -- emergono random dal suolo e danneggiano ruotando su un perno
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
    -- delay necessario per la lunghezza dell'attacco
    if t_techniques.technique_chosen == "apple"
      or t_techniques.technique_chosen == "lunchbox"
      or t_techniques.technique_chosen == "music"
      or t_techniques.technique_chosen == "rat" then
        -- passaggio alla fase di attacco nemico
        timer.performWithDelay( 1000, t_phases.enemyAttackPhase )
    else
      -- passaggio alla fase di attacco nemico
      t_phases.enemyAttackPhase()
    end
  end

end

-- funzione per il reset della statistiche del turno

local function resetTurnStats()

  print("resetTurnStats()")
  -- se il portapranzo è attivo, non viene offerto
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

  t_cbtplayer.orange_count = 0
  t_cbtplayer.red_count = 0
  t_cbtplayer.white_count = 0

  t_cbtplayer.vocal = false

  t_techniques.technique_chosen = 0

  t_buffs.current_choices_number = 1

  t_cbtenemy.enemy_accuracy_bonus_minus = 0

end

-- funzione per il rinnovo della scelta delle tecniche

local function renewTechniques()

  -- funzione per rimescolare le tecniche
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
  -- comparsa delle 2 tecniche sorteggiate random
	t_techniques.technique_1:setSequence( t_techniques.techniques_offered[1] )
	t_techniques.technique_2:setSequence( t_techniques.techniques_offered[2] )
  transition.to( t_techniques.technique_1, { time=500, alpha=0.9 } )
	transition.to( t_techniques.technique_2, { time=500, alpha=0.9 } )

end

-- funzione per il rinnovo della scelta dei potenziamenti

local function renewBuffs()

	print("renewBuffs()")

	shuffleBuffs()

  for i=1, 6 do
    t_buffs.buffs[i]:setSequence( t_buffs.buffs_offered[i] )
    -- reset dei parametri nel caso il potenziamento fosse stato scelto il turno precedente
    if t_buffs.buffs[i].chosen > 0 then
      t_buffs.buffs[i].chosen = 0
      t_buffs.buffs[i].strokeWidth = 2
      t_buffs.buffs[i]:setStrokeColor( 0, 0, 0 )
    end
    t_buffs.buffs[i].background = display.newRect( t_groups.choicesGroup, t_buffs.buffs[i].x, t_buffs.buffs[i].y, 176, 60 )
    t_buffs.buffs[i].background.anchorX = 0
    t_buffs.buffs[i].background.anchorY = 0
    t_buffs.buffs[i].background.alpha = 0

    -- attribuzione random del colore del potenziamento
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
    t_buffs.buffs[i]:toFront()
    transition.fadeIn( t_buffs.buffs[i], { time=500 } )
    transition.fadeIn( t_buffs.buffs[i].background, { time=500 } )
  end

end

-- funzione per l'esito negativo del livello
local function nightmareDream()

  print("nightmareDream()")
  physics.stop()

  t_audio.lost = audio.loadSound( "sounds/effects/lost.mp3" )
  audio.play( t_audio.lost )

  audio.stop( { channel=1 } )
  audio.dispose( t_audio.soundtrack )
  t_audio.soundtrackPlay = nil
  t_audio.soundtrack = nil

  -- rimozioni necessariamente manuali
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
  t_player.lastDamageReceived:removeSelf()
  t_player.lastDamageReceived = nil
  t_player.lastDamageReceivedBox:removeSelf()
  t_player.lastDamageReceivedBox = nil

  -- settaggio di sfondo, scritte e pulsanti

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

-- funzione per l'esito positivo del livello
-- quasi identica a quella per l'esito negativo
local function goodDream()

  print("goodDream()")
  physics.stop()


  t_audio.won = audio.loadSound( "sounds/effects/won.mp3" )
  audio.play( t_audio.won )

  audio.stop( { channel=1 } )
  audio.dispose( t_audio.soundtrack )
  t_audio.soundtrackPlay = nil
  t_audio.soundtrack = nil

  -- potenziale aggiornamento dei livelli sbloccati
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
  t_player.lastDamageReceived:removeSelf()
  t_player.lastDamageReceived = nil
  t_player.lastDamageReceivedBox:removeSelf()
  t_player.lastDamageReceivedBox = nil

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

-- funzione per il danneggiamento del giocatore
local function damagePlayer( damage )

	print("damagePlayer()")
  -- calcolo dello scudo nel caso di 2+ colori rossi
  if t_cbtplayer.player_grit > 0 then
    t_cbtplayer.player_grit = t_cbtplayer.player_grit + math.round( damage * 0.3 )
    print("increased grit by " .. math.round( damage * 0.3 ) )
  end
  -- calcolo dei bonus di difesa
  print("player would lose " .. damage .. " fortitude")
  damage = math.round( ( damage * ( 100 - t_cbtplayer.player_defense_bonus_multi ) ) / 100 )
  print("player would lose " .. damage .. " fortitude with %defense")
  damage = damage - t_cbtplayer.player_final_defense
  if damage < 0 then
    damage = 0
  end
  print("player would lose " .. damage .. " fortitude with %defense and -defense")

  -- calcolo dell'assorbimento dello scudo
  if t_playerHPB.playerCurrentGrit > 0 then
    t_playerHPB.playerCurrentGrit = t_playerHPB.playerCurrentGrit - damage
    print("grit absorbed " .. damage)
    if t_playerHPB.playerCurrentGrit < 0 then
      damage = -t_playerHPB.playerCurrentGrit
      print("grit couldn't absorb last " .. damage)
    end
  end

  -- aggiornamento statistiche di fine livello e barra della vita del giocatore
  t_cbtplayer.player_damage_received_turn = t_cbtplayer.player_damage_received_turn + damage
  t_player.lastDamageReceived.text = "Coraggio: -" .. t_cbtplayer.player_damage_received_turn
  t_ending.fortitudeLost = t_ending.fortitudeLost + damage
  t_playerHPB.playerCurrentHP = t_playerHPB.playerCurrentHP - damage
  t_playerHPB.playerHPBar.width = t_playerHPB.playerCurrentHP / 3

  -- visualizzazione danno al giocatore
  local damageText = display.newText( t_groups.uiGroup, damage, t_player.player.x - math.random( 12, 22 ), t_player.player.y - math.random( -6, 10 ), "GosmickSans.ttf", 9 )
  damageText:setFillColor( 0, 0, 0 )
  local vertices = { 0,-10, 3,-4, 10,-3, 5,3, 7,11, 0,8, -7,11, -5,3, -10,-3, -3,-4 }
  local damageBubble = display.newPolygon( t_groups.uiGroup, damageText.x, damageText.y, vertices )
  if damage > 0 then
    damageBubble.fill = { type="image", filename="images/graphics/starfill_yellow.png" }
  else
    damageBubble.fill = { type="image", filename="images/graphics/starfill_blue.png" }
  end
  damageText:toFront()
  transition.to( damageBubble, { time=800, alpha=0, y=damageBubble.y-30, rotation=240, onComplete=function(damageBubble) damageBubble:removeSelf(); damageBubble=nil; end } )
  transition.to( damageText, { time=800, alpha=0, y=damageText.y-30, onComplete=function(damageText) damageText:removeSelf(); damageText=nil; end } )

  -- colore della barra della vita del giocatore
  if t_playerHPB.playerCurrentGrit <= 0 then
    if t_playerHPB.playerCurrentHP <= 0 then
      t_cbtplayer.player_dead = true
    elseif t_playerHPB.playerCurrentHP <= 50 then
    	t_playerHPB.playerHPBar:setFillColor( 1, 0, 0 )
    elseif t_playerHPB.playerCurrentHP <= 150 then
    	t_playerHPB.playerHPBar:setFillColor( 1, 1, 0 )
    else
      t_playerHPB.playerHPBar:setFillColor( 0, 1, 0 )
    end
  end

end

-- funzione per il triangolo  creato dai proiettili-lampadina del nemico lampe
local function helpEnemy( enemyObj, color )

    print("helpEnemy()")
    local vertices = { -8,7, 0,-7, 8,7 }
    local helpBubble = display.newPolygon( t_groups.uiGroup, enemyObj.x, enemyObj.y - 10, vertices )
    helpBubble.fill = color
    helpBubble:setStrokeColor( 0, 0, 0 )
    helpBubble.strokeWidth = 1
    transition.to( helpBubble, { time=1500, alpha=0, y=helpBubble.y-40, onComplete=function(helpBubble) helpBubble:removeSelf(); helpBubble=nil; end } )

end

-- funzione per la collisione dei proiettili dei nemici
local function enemyBulletCollision( self, event )

  print("enemyBulletCollision")
  -- collisione con il giocatore
  if event.other.type == "player" then
    -- attacco di skeley
    if self.type == "bone" then
      audio.play( t_audio.bone )
      damagePlayer( 4 + self.damage_plus + math.random( 0, 2 ) )
      display.remove( self )
      self = nil
    -- attacco di rosey
    elseif self.type == "petal" then
      audio.play( t_audio.petal )
      damagePlayer( self.damage_plus + math.random( 1, 5 ) )
      display.remove( self )
      self = nil
    end
  -- collisione con altri nemici
  elseif ( event.other.type == "boss" or event.other.type == "goons" ) and event.other.race ~= "lampey" then
    -- lampadina gialla di lampey, cura il nemico colpito
    if self.type == "charge_yellow" then
      audio.play( t_audio.charge )
      helpEnemy( event.other, { 1, 1, 0 } )
      event.other.hp = event.other.maxhp
      display.remove( self )
      self = nil
    -- lampadina gialla di lampey, aumenta permanentemente i danni del nemico colpito
    elseif self.type == "charge_orange" then
      audio.play( t_audio.charge )
      helpEnemy( event.other, { 1, 0.65, 0 } )
      event.other.damage_plus = event.other.damage_plus + math.random( 1, 3 )
      display.remove( self )
      self = nil
    end
  -- collisione con il terreno con conseguente scomparsa dal proiettile
  elseif event.other.type == "ground" then
    transition.to( self, { time=50, alpha=0, onComplete=function(self) display.remove(self); self=nil; end } )
  end

end

-- funzione per l'attacco dei nemici
local function enemyAttack()

  print("enemyAttack()")
  -- nessun nemico
  if #t_cbtenemy.goons <= 0 then
    print("no enemies alive attacking player")
    -- passaggio alla fase di controllo fine livello
    timer.performWithDelay( 500, t_phases.dreamCompleteCheckPhase )
  else
    -- ciclo per ogni nemico vivo
    for i=1, #t_cbtenemy.goons do
      print("goon index: " .. t_cbtenemy.goons[i].index .. " attacks with accuracy " .. t_cbtenemy.goons[i].accuracy_minus)
      -- se skeley, tira un osso con traiettoria ad arco seguente fisica
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
      -- se rosey, crea da 1 a 5 petali con traiettoria lineare senza gravità
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
        -- a 5 petali si azzerano ad 1
        if t_cbtenemy.goons[i].petals == 5 then
          t_cbtenemy.goons[i].petals = 1
        -- a <5 petali se ne crea un altro
        else
          t_cbtenemy.goons[i].petals = t_cbtenemy.goons[i].petals + 1
        end
      -- se lmapey, tira una lampadina o gialla o arancione
      elseif t_cbtenemy.goons[i].race == "lampey" then
        print("lampey attacks (helps)")
        local num = math.random( 0, 1 )
        print("random num:" .. num)
        -- lampadina gialla
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
          -- lampadina arancione
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
      -- reset dell'accuratezza
      t_cbtenemy.goons[i].accuracy_minus = 0
    end
    -- passaggio alla fase di controllo fine livello
    timer.performWithDelay( 1500, t_phases.dreamCompleteCheckPhase )
  end

end

-- funzione per il russare della tenda del giocatore
local function snoring()

  local snoreText = display.newText( t_groups.uiGroup, "Z", 90, 135, "GosmickSans.ttf", 7 )
  snoreText:setFillColor( 0, 0, 0 )
  transition.to( snoreText, { time=3000, alpha=0, y=110, onComplete=snoring } )

end

-- create()
function scene:create( event )

  local sceneGroup = self.view

  physics.pause()

  -- istanziazione gruppi

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

  -- istanziazione audio

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

  -- istanziazione optionTab

  t_optionTab.opened = false

  -- istanziazione tutorial

  t_tutorial.playerTutorial = {
    "Aliza non ha intenzione di cedere alle insidie delle streghe", --1
    "Adesso i potenziamenti possiedono un colore casuale",
    "Se scegli 2 volte lo stesso colore, avrai un beneficio aggiuntivo", --3
    "Se scegli 3 volte lo stesso colore, avrai un ulteriore beneficio aggiuntivo",
    "L'arancio ti aiuta nei danni a bersaglio singolo e nei danni critici", --5
    "Il rosso ti aiuta nella difesa e nel mantenere il coraggio",
    "Il bianco ti aiuta nei danni ad area", --7
    "Anche il colore della fantasia scelta contribuisce ai benefici!",
    "D'ora in poi valuta fantasie e potenziamenti anche dal loro colore" --9
  }
  t_tutorial.tutorialCounter = 1


  -- istanziazione filtri di collisione

  t_cfilters.cfGround = { categoryBits=1, maskBits=30 }
  t_cfilters.cfPlayer = { categoryBits=2, maskBits=17 }
  t_cfilters.cfEnemies = { categoryBits=4, maskBits=13 }
  t_cfilters.cfPlayerbullets = { categoryBits=8, maskBits=29 }
  t_cfilters.cfEnemybullets = { categoryBits=16, maskBits=7 }

  -- istanziazione zone dello schermo

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

  -- istanziazione tables

  t_tables.techniques_table = { "apple", "lunchbox", "mirror", "music", "rat", "wolfpaw" }
  t_tables.goons_table = {}

  -- istanziazione combattimento del giocatore

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

  t_cbtplayer.orange_count = 0
  t_cbtplayer.red_count = 0
  t_cbtplayer.white_count = 0

  t_cbtplayer.vocal = false

  t_cbtplayer.player_damage_dealt_turn = 0
  t_cbtplayer.player_damage_received_turn = 0

  t_cbtplayer.player_dead = false

  -- istanziazione combattimento del nemico

  t_cbtenemy.goons = {}

  t_cbtenemy.enemy_accuracy_bonus_minus = 0

  -- istanziazione giocatore

  t_player.player = display.newImageRect( t_groups.charactersGroup, "images/characters/aliza_tent.png", 61, 41 )
  t_player.player.x = display.contentCenterX - 150
  t_player.player.y = display.contentCenterY - 20
  t_player.player.type = "player"
  local playerShape = { -17,-20, 17,-20, 30,20, -30,20 }
  physics.addBody( t_player.player, "static", { shape=playerShape, bounce=0, friction=1, density=1, filter=t_cfilters.cfPlayer } )
  snoring()

  -- istanziazione oggetti specchio e portapranzo

  t_cbtplayer.mirror_prop = display.newImage( t_groups.charactersGroup, "images/objects/magicMirror.png", 24, 41 )
  t_cbtplayer.mirror_prop.x = t_player.player.x + 45
  t_cbtplayer.mirror_prop.y = t_player.player.y - 12
  t_cbtplayer.mirror_prop.alpha = 0

  t_cbtplayer.lunchbox_deployed = false
  t_cbtplayer.lunchbox_active = false

  -- istanziazione indicatore danni ultimo turno

  t_player.lastDamageDealt = display.newText( t_groups.uiGroup, "Danni: " .. t_cbtplayer.player_damage_dealt_turn, display.contentCenterX - 240, display.contentCenterY - 50, "GosmickSans.ttf", 10 )
  t_player.lastDamageDealt:setFillColor( 0, 0, 0 )

  t_player.lastDamageDealtBox = display.newRect( t_groups.uiGroup, t_player.lastDamageDealt.x, t_player.lastDamageDealt.y, 80, 20 )
  t_player.lastDamageDealtBox.fill = t_graphics.blueGradient
  t_player.lastDamageDealtBox.strokeWidth = 2
  t_player.lastDamageDealtBox:setStrokeColor( 0, 0, 0 )

  t_player.lastDamageDealt:toFront()

  t_player.lastDamageReceived = display.newText( t_groups.uiGroup, "Coraggio: -" .. t_cbtplayer.player_damage_received_turn, display.contentCenterX - 240, display.contentCenterY - 20, "GosmickSans.ttf", 10 )
  t_player.lastDamageReceived:setFillColor( 0, 0, 0 )

  t_player.lastDamageReceivedBox = display.newRect( t_groups.uiGroup, t_player.lastDamageReceived.x, t_player.lastDamageReceived.y, 80, 20 )
  t_player.lastDamageReceivedBox.fill = t_graphics.blueGradient
  t_player.lastDamageReceivedBox.strokeWidth = 2
  t_player.lastDamageReceivedBox:setStrokeColor( 0, 0, 0 )

  t_player.lastDamageReceived:toFront()

  -- istanziazione barra della vita del giocatore

  local playerIcon = display.newImage( t_groups.uiGroup, "images/characters/alizaPortrait.png", -24, 20 )
  t_playerHPB.playerMaxHP = 300
  t_playerHPB.playerCurrentHP = 300
  t_playerHPB.playerCurrentGrit = 0

  t_playerHPB.playerHPBar = display.newRect( t_groups.uiGroup, playerIcon.x + 10, playerIcon.y - 4, t_playerHPB.playerMaxHP / 3, 15 )
  t_playerHPB.playerHPBar.anchorX = -1
  t_playerHPB.playerHPBar:setFillColor( 0, 1, 0 )
  t_playerHPB.playerHPBar.strokeWidth = 2
  t_playerHPB.playerHPBar:setStrokeColor( 0, 0, 0, 1 )
  playerIcon:toFront()

  -- istanziazione shape dei nemici

  t_goons.tikeyShape = { -18,-39, 18,-39, 18,39, -18,39 }
  t_goons.roseyShape = { -22,-14, 0,-30, 22,-14, 0,30 }

  -- istanziazione contatori dei nemici

  t_goons.goonsToSpawn = 15
  t_goons.goonsSpawned = 0
  t_goons.goonsKilled = 0
  t_goons.tikeyInterval = 5
  t_goons.skeleyInterval = 2
  t_goons.roseyInterval = 3

  t_goons.goonsCounter = display.newImage( t_groups.uiGroup, "images/icons/goonsCounter.png", 19, 19 )
  t_goons.goonsCounter.x = 485
  t_goons.goonsCounter.y = 62
  t_goons.goonsCounterText = display.newText( "x" .. tostring( t_goons.goonsToSpawn ), 100, 200, "GosmickSans.ttf", 14 )
  t_goons.goonsCounterText.x = t_goons.goonsCounter.x + 22
  t_goons.goonsCounterText.y = t_goons.goonsCounter.y
  t_goons.goonsCounterText:setFillColor( 0, 0, 0 )

  -- istanziazione statistiche finali

  t_ending.endingTurns = 0
  t_ending.fortitudeLost = 0
  t_ending.damageDealt = 0

  -- istanziazione tecniche

  local techniquesSheetOptions =
  { frames =
    {
      -- 1) mela
      { x = 0, y = 0, width = 265, height = 130 },
      -- 2) portapranzo
      { x = 265, y = 0, width = 265, height = 130 },
      -- 3) specchio
      { x = 530, y = 0, width = 265, height = 130 },
      -- 3) musica
      { x = 795, y = 0, width = 265, height = 130 },
      -- 3) ratti
      { x = 1060, y = 0, width = 265, height = 130 },
      -- 3) zampe di lupo
      { x = 1325, y = 0, width = 265, height = 130 },

    }
  }

  t_techniques.techniquesSheet = graphics.newImageSheet( "images/objects/sheets/fablesSheet.png", techniquesSheetOptions )

  t_techniques.techniques_types = {
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

  t_techniques.technique_1 = display.newSprite( t_groups.choicesGroup, t_techniques.techniquesSheet, t_techniques.techniques_types )
  t_techniques.technique_1.x = techniques_X1
  t_techniques.technique_1.y = techniques_Y1
  t_techniques.technique_1.anchorX = 0
  t_techniques.technique_1.anchorY = 0
  t_techniques.technique_1:setSequence( t_techniques.techniques_offered[1] )
  t_techniques.technique_1.alpha = 0
  t_techniques.technique_1.strokeWidth = 2
  t_techniques.technique_1:setStrokeColor( 0, 0, 0 )

  t_techniques.technique_2 = display.newSprite( t_groups.choicesGroup, t_techniques.techniquesSheet, t_techniques.techniques_types )
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

  -- istanziazione potenziamenti

  t_buffs.technique_chosen_reminder = display.newSprite( t_groups.uiGroup, t_techniques.techniquesSheet, t_techniques.techniques_types )
  t_buffs.technique_chosen_reminder.x = display.contentCenterX - 240
  t_buffs.technique_chosen_reminder.y = display.contentCenterY - 90
  t_buffs.technique_chosen_reminder.alpha = 0
  t_buffs.technique_chosen_reminder.strokeWidth = 5
  t_buffs.technique_chosen_reminder:setStrokeColor( 0, 0, 0 )
  t_buffs.technique_chosen_reminder:scale( 0.3, 0.3 )

  t_buffs.buffsSheetOptions =
  { frames =
    {
      -- 1) bara
      { x = 0, y = 0, width = 176, height = 60 },
      -- 2) occhi
      { x = 176, y = 0, width = 176, height = 60 },
      -- 3) fauci
      { x = 352, y = 0, width = 176, height = 60 },
      -- 4) oro
      { x = 528, y = 0, width = 176, height = 60 },
      -- 5) falci mantide
      { x = 704, y = 0, width = 176, height = 60 },
      -- 6) tentacolo
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
    -- inizio livello che parte dalla fase di tutorial
    t_phases.playerTutorialPhase()
  end

end

---------------------
-- INIZIO TUTORIAL --
---------------------

-- funzione della fase di tutorial
t_phases.playerTutorialPhase = function()

  -- funzione per la narrazione del testo del tutorial
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

    -- fine del tutorial
    if t_tutorial.tutorialCounter == 9 then
      t_tutorial.textField:removeSelf()
      t_tutorial.textField = nil
      t_tutorial.textFieldBox:removeSelf()
      t_tutorial.textFieldBox = nil
      Runtime:removeEventListener( "tap", t_tutorial.nextTutorial )
      -- passaggio alla fase di generazione dei nemici
      t_phases.spawnPhase()
    end
  end

  -- listener per l'avanzamento al prossimo passo del tutorial
  -- avviato da un tap in qualsiasi zona dello schermo
  function t_tutorial.nextTutorial( event )
    print("next " .. t_tutorial.tutorialCounter)
    if t_optionTab.opened == false then
      -- tap non avvenuto sull'icona del menù delle opzioni
      if event.x < t_screenzs.optionTabFieldBox.contentBounds.xMin or
        event.x > t_screenzs.optionTabFieldBox.contentBounds.xMax or
        event.y < t_screenzs.optionTabFieldBox.contentBounds.yMin or
        event.y > t_screenzs.optionTabFieldBox.contentBounds.yMax then
          t_tutorial.tutorialCounter = t_tutorial.tutorialCounter + 1
          -- rimozione del testo del passo tutorial precedente
          if t_tutorial.textField ~= nil and t_tutorial.textFieldBox ~= nil then
            audio.play( t_audio.tutorialnext )
            t_tutorial.textField:removeSelf()
            t_tutorial.textField = nil
            t_tutorial.textFieldBox:removeSelf()
            t_tutorial.textFieldBox = nil
          end
          -- proseguimento con il tutorial
          narrateTutorial()
      end
    end
  end

  -- listener globale per il tap
  Runtime:addEventListener( "tap", t_tutorial.nextTutorial )
  -- inizio narrazione tutorial
  narrateTutorial()

end

----------------------
-- FLUSSO DI GIOCO  --
----------------------

-- funzione della fase di generazione dei nemici
t_phases.spawnPhase = function()

  -- funzione per la generazione dei nemici data la razza (il nome del tipo)
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
  -- logica per la generazione dei nemici, variabile in base al livello
  if t_goons.goonsToSpawn == 8 then
    spawnGoons( "tikey" )
    spawnGoons( "tikey" )
    spawnGoons( "skeley" )
    spawnGoons( "skeley" )
    spawnGoons( "rosey" )
    spawnGoons( "rosey" )
  end
  -- generazione in base agli intervalli, se mancano nemici da generare
  if t_goons.goonsToSpawn > 0 and t_goons.skeleyInterval == 0 then
    spawnGoons( "skeley" )
    t_goons.skeleyInterval = 3
  else
    t_goons.skeleyInterval = t_goons.skeleyInterval - 1
  end
  if t_goons.goonsToSpawn > 0 and t_goons.roseyInterval == 0 then
    spawnGoons( "rosey" )
    t_goons.roseyInterval = 3
  end
  if t_goons.goonsToSpawn > 0 and t_goons.tikeyInterval == 0 then
    spawnGoons( "tikey" )
    t_goons.tikeyInterval = 5
  else
    t_goons.tikeyInterval = t_goons.tikeyInterval - 1
  end
  -- generazione istantanea se non ci sono nemici sullo schermo ma mancano da generare
  if t_goons.goonsToSpawn ~= 0 and t_goons.goonsSpawned == t_goons.goonsKilled then
    print("killed goons too fast, skipping 1 turn")
    for i=0, t_goons.goonsToSpawn / 2 do
      spawnGoons( "skeley" )
      print("goonsSpawned: " .. t_goons.goonsSpawned)
      print("goonsToSpawn: " .. t_goons.goonsToSpawn)
    end
    t_phases.spawnPhase()
  else
    print("goonsSpawned: " .. t_goons.goonsSpawned)
    print("goonsToSpawn: " .. t_goons.goonsToSpawn)
    print("still " .. t_goons.goonsToSpawn .. " to spawn")
    print("rosey spawning in " .. t_goons.roseyInterval .. " turns")
    print("tikey spawning in " .. t_goons.tikeyInterval .. " turns")
    print("skeley spawning in " .. t_goons.skeleyInterval .. " turns")
    -- passaggio alla fase di scelta della tecnica
    timer.performWithDelay( 250, t_phases.techniquesPhase )
  end

end

-- funzione della fase di scelta della tecnica
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
  -- si passa alla fase successiva col tap su una tecnica, se ne occupa dunque il listener

end

-- buffs phase

t_phases.buffsPhase = function()

  print("buffsPhase()")
  t_buffs.technique_chosen_reminder:setSequence( t_techniques.technique_chosen )
  transition.fadeIn( t_buffs.technique_chosen_reminder, { time=500 } )
  renewBuffs()
  -- si passa alla fase successiva col tap su una tecnica, se ne occupa dunque il listener

end

-- funzione per la fase di combattimento
t_phases.battlePhase = function()

	print("battlePhase()")
  t_screenzs.optionTabFieldBox.alpha = 0
  t_screenzs.optionTabImage.alpha = 0
  for i=1, 6 do
    transition.fadeOut( t_buffs.buffs[i], { time=500 } )
    transition.fadeOut( t_buffs.buffs[i].background, { time=500 } )
    transition.fadeOut( t_buffs.technique_chosen_reminder, { time=500 } )
  end
  -- passaggio alla fase di attacco del giocatore
  timer.performWithDelay( 500, t_phases.playerAttackPhase )

end

-- funzione per la fase di attacco del giocatore
t_phases.playerAttackPhase = function()

  print("playerAttackPhase()")
  calculateBuffs()
  print("orange count: " .. t_cbtplayer.orange_count)
  print("red count: " .. t_cbtplayer.red_count)
  print("white count: " .. t_cbtplayer.white_count)
  calculatePlayerTurnStats()
  playerAttack()
  -- si passa alla fase successiva automaticamente al termine delle munizioni del giocatore

end

-- funzione per la fase di attacco dei nemici
t_phases.enemyAttackPhase = function()

  print("enemyAttackPhase()")
  -- scomparsa dell'oggetto specchio
  if t_cbtplayer.mirror_prop.alpha > 0 then
    transition.fadeOut( t_cbtplayer.mirror_prop, { time=350 } )
  end
  timer.performWithDelay( 500, enemyAttack )
  -- si passa alla fase successiva automaticamente al termine degli attacchi dei nemici

end

-- funzione per la fase di controllo di fine livello
t_phases.dreamCompleteCheckPhase = function()

  print("dreamCompleteCheckPhase()")
  -- giocatore senza vita, esito negativo
  if t_cbtplayer.player_dead == true then
    nightmareDream()
  -- tutti i nemici eliminati, esito positivo
  elseif t_goons.goonsKilled >= ( t_goons.goonsToSpawn + t_goons.goonsSpawned ) then
    goodDream()
  else
    -- cambio colore della barra della vita del giocatore se abilità scudo con 2+ colori rosso
    if t_cbtplayer.player_grit > 0 then
      print("total grit accumulated " .. t_cbtplayer.player_grit)
      t_playerHPB.playerCurrentGrit = t_cbtplayer.player_grit
      t_playerHPB.playerHPBar:setFillColor( 0, 0.80, 0.82 )
    else
      if t_playerHPB.playerCurrentHP <= 50 then
    		t_playerHPB.playerHPBar:setFillColor( 1, 0, 0 )
    	elseif t_playerHPB.playerCurrentHP <= 150 then
    		t_playerHPB.playerHPBar:setFillColor( 1, 1, 0 )
      else
        t_playerHPB.playerHPBar:setFillColor( 0, 1, 0 )
    	end
    end
    -- passaggio / ritorno alla fase di generazione dei nemici
    t_phases.spawnPhase()
  end

end

-- scene event listener
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )

return scene
