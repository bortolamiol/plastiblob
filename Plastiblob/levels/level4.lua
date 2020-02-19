-----------------------------------------------------------------------------------------
--
-- QUARTO LIVELLO DEL GIOCO: SALTARE I NEMICI E RACCOGLIERE LA PLASTICA DAL CIELO
--
-----------------------------------------------------------------------------------------

-- dichiaro delle variabili che andrò a usare in varie scene del livello
local localLevel = 4 --VARIABILE CHE CONTIENE IL NUMERO DI LIVELLO A CUI APPARTIENE IL FILE LUA: IN QUESTO CASO SIAMO AL LIVELLO 1
local composer = require( "composer" ) --richiedo la libreria composer
local scene = composer.newScene() --nuova scena composer
local bg --variabile che durante lo show conterrà le due immagini di sfondo che andranno una dopo l'altra
local punteggio --variabile che conterrà il mio punteggio del livello
local sprite --sprite del personaggio
local enemies = {} --sprite dei nemici
local table_enemies_bullets = {}
local table_enemies_timer = {}
local table_plasticbag = {} --tabella che conterrà al suo interno i sacchetti di plastica che sono sullo schermo
local table_bullets = {} --tabella che conterrà al suo interno i proiettili che sono sullo schermo
local table_spine = {} --tabella che conterrà al suo interno le pozze d'acqua che sono sullo schermo
local table_platform = {} --tabella che conterrà al suo interno le piattaforme che saranno sullo schermo
local button_home --bottone per uscire dal livello e tornare alla button_home dei livelli
local stop =  0 --variabile che servirà per capire se stoppare il gioco
local stopCreatingEnemies =  0 --variabile che servirà per capire se stoppare il gioco
local callingEnemies
local castle
local platform --variabile che conterrà al suo interno l'immagine della piattaforma che sarà visualizzata nel gioco
local callingPlasticbag
local callingSpine
local timeplayed  --varaiabile che misura da quanti secondi sono all'interno del gioco e farà cambiare la velocità
local timeToPlay = 60 --variabile che conterrà quanto l'utente dovrà sopravvivere all'interno del gioco
local scoreCount    --variabile conteggio punteggio iniziale
local gameFinished
local crunchSound = audio.loadSound("MUSIC/crunch.mp3")
local musicLevel4
local explosionSound4 = audio.loadSound("MUSIC/explosion.mp3") --carico suono esplosione
function scene:create( event )

  -- Called when the scene's view does not exist.
  --
  -- INSERT code here to initialize the scene
  -- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
  local sceneGroup = self.view
  musicLevel4 = audio.loadStream("MUSIC/level4.mp3") --carico la musica level4
  --creo due nuovi gruppi che inserirò all'interno del gruppo 'padre' sceneGroup
  group_tutorial = display.newGroup() --group_background conterrà la foto di sfondo che scrollerà
  group_background = display.newGroup() --group_background conterrà la foto di sfondo che scrollerà
  group_castle = display.newGroup() --group_elements conterrà tutti gli altri elementi dello schermo: sprite del personaggio, nemici e bottoni per uscire dal gioco
  group_elements = display.newGroup() --group_elements conterrà tutti gli altri elementi dello schermo: sprite del personaggio, nemici e bottoni per uscire dal gioco
  sceneGroup:insert( group_tutorial ) --inserisco il gruppo group_background dentro la scena
  sceneGroup:insert( group_background ) --inserisco il gruppo group_background dentro la scena
  sceneGroup:insert( group_castle ) --inserisco il gruppo castle sopra la scena e sotto i personaggi
  sceneGroup:insert( group_elements ) --inserisco il gruppo group_elements dentro la scena
end

function scene:show( event )
  local phase = event.phase

  if phase == "will" then
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    -------------------   RICHIEDO LA FISICA ALLA LIBRERIA  --------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    local physics = require("physics")
    physics.start()
    -- Overlays collision outlines on normal display objects
    physics.setGravity( 0,41 )
    --physics.setDrawMode( "hybrid" )

  elseif phase == "did" then
    audio.play( musicLevel4, { channel=3, loops=-1 } ) --parte la musica del livello 3


    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    -------------------------   PARAMETRI DEL LIVELLO  -------------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    local options = {
      effect = "fade",
      time = 1000,
      params = { level="level4"} -- questa variabile verrà utilizzata dal gameover pper capire a che livello tornare
    }

    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    -------------------   VARIE VARIABILI DI FUNZIONAMENTO  --------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    local secondsPlayed = 0 --quanti secondi sono passati dall'inizio del gioco
    local castleAppared = 0 --variabile fuffa che mi servirà per controllare se il castello è già apparso sullo schermo una volta
    scoreCount = 0 --variabile conteggio punteggio iniziale
    gameFinished = 0 --variabile che mi servirà per fare un controllo aggiuntivo e fermare le animazioni e la creazione dei personaggi fino a quando non si cancellano i timer e animazioni

    -- VARIABILI PER LO SFONDO DI BACKGROUND
    local _w = display.actualContentWidth  -- Width of screen
    local _h = display.actualContentHeight  -- Height of screen
    local _x = 0  -- Horizontal centre of screen
    local _y = 0  -- Vertical centre of screen

    bg={} -- 'vettore' che conterrà i due sfondi del gioco
    bg[1] = display.newImageRect("immagini/livello-4/background.png", _w, _h)
    bg[1].anchorY = 0
    bg[1].anchorX = 0
    bg[1].x = 0
    bg[1].y = _y
    group_background:insert(bg[1])
    bg[2] = display.newImageRect("immagini/livello-4/background.png", _w, _h)
    bg[2].anchorY = 0
    bg[2].anchorX = 0
    bg[2].x = _w
    bg[2].y = _y
    group_background:insert(bg[2])

    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    -------------------   VARIABILI PER VELOCITA' DI GIOCO  --------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    local enemySpeed_max = 8-- massima velocità di spostamento del nemico
    local enemySpeed_min = 4.5 -- minima velocità di spostamento del nemico
    local enemySpeed = enemySpeed_min --velocità iniziale di spostamento del nemico, parte dal valore minimo

    local frame_speed = 16 --questa sarà la velocità dello scorrimento del nostro sfondo, si sposta di 20 pixel in 20

    local time_speed_min = 20 -- ogni quanti millisecondi verranno chiamate le funzioni di loop (esempio di sfondo group_background)
    local time_speed_max = 10 -- massimo di velocità che time_speed può raggiungere

    local plasticToCatch = 7 --numero di oggetti di plastica che l'utente dovrà raccogliere

    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    ---------------------   SPRITE E ANIMAZIONI DI GIOCO  ----------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------


    -- Terreno del gioco, un elemento statico e di colore trasparente
    local groundHeight = 90 --ha un'altezza di 100 px
    local ground = display.newRect( 0, 0,99999, groundHeight )
    ground:setFillColor(0,0,0,0) --colore trasparente
    ground.name = "ground" --il nome servirà in fase di collisione con il nostro sprite, per sapere che dovrà togliere l'animazione del salto e tornare su quella della camminata
    group_elements:insert(ground) --lo inserisco sopra il background
    ground.x = display.contentCenterX
    ground.y = display.contentHeight- groundHeight/2
    physics.addBody(ground, "static",{bounce=0, friction=1 } )

    --Testo dello score, che andrà a dire quanti oggetti di plastica abbiamo raccolto durante il gioco (su x/10)
    local scoreText = display.newText( scoreCount.."/10", display.contentCenterX, display.contentCenterY-300, native.systemFont, 28 )
    scoreText:setFillColor( 1, 1, 0 )
    group_elements:insert(scoreText)
    local spriteWalkingSheetData =
    {
      width=160,
      height=160,
      numFrames=8,
      sheetContentWidth=1280,
      sheetContentHeight=160
    }

    --sprite del personaggio
    local spriteWalkingSheet = graphics.newImageSheet( "immagini/livello-1/spritewalking.png", spriteWalkingSheetData )
    -- primo sprite per il personaggio che salta
    local spriteJumpingSheetData =
    {
      width=160,
      height=160,
      numFrames=8,
      sheetContentWidth=1280,
      sheetContentHeight=160
    }

    local spriteJumpingSheet = graphics.newImageSheet( "immagini/livello-1/spritejump.png", spriteJumpingSheetData )
    -- In your sequences, add the parameter 'sheet=', referencing which image sheet the sequence should use
    local spriteData = {
      { name="walking", sheet=spriteWalkingSheet, start=1, count=8, time=800, loopCount=0 },
      { name="jumping", sheet=spriteJumpingSheet, start=1, count=8, time=900, loopCount=0 }
    }
    --metto assieme tutti i dettagli dello sprite, elencati in precedenza
    sprite = display.newSprite( spriteWalkingSheet, spriteData ) --assegnno allo sprite lo sheet del walking
    sprite.name = "sprite" --gli assegno il nome sprite, mi servirà in fase di collsione
    group_elements:insert(sprite)

    --posiziono lo sprite
    sprite.x = (display.contentWidth/2)-350
    sprite.y = ground.y - 100

    --preparo gli outline del personaggio. in questo livello ne ho 2 = uno per la fase di camminamento e uno per il salto che andrò ad intercambiare
    local outlineSpriteWalking = graphics.newOutline(2, spriteWalkingSheet, 1)   --outline personaggio
    local outlineSpriteJumping = graphics.newOutline(2, spriteJumpingSheet, 4)   --outline personaggio

    --applico la fisica al nostro personaggio
    physics.addBody(sprite, { outline=outlineSpriteWalking, density=4, bounce=0, friction=1}) --sprite diventa corpo con fisica
    sprite.gravityScale = 3
    sprite.isFixedRotation = true --rotazione bloccata
    sprite.isJumping = false
    --sprite.mustChangeOutlineToWalk = false --variabile che mi servirà per  cambiare l'outline del personaggio da jumping a walking

    -- PRIMO NEMICO
    local enemyWalkingSheetData = { width=250, height=250, numFrames=10, sheetContentWidth=2500, sheetContentHeight=250 }
    local enemyWalkingSheet = graphics.newImageSheet( "immagini/livello-4/scienziato.png", enemyWalkingSheetData )
    local enemyData = {
      { name="walking", sheet=enemyWalkingSheet, start=1, count=10, time=800, loopCount=0 }
    }
    local enemyTimeSpawnMin = 13000
    local enemyTimeSpawnMax  = 13500

    -- NEMICO PIPISTRELLO
    local batWalkingSheetData = { width=200, height=200, numFrames=8, sheetContentWidth=1600, sheetContentHeight=200 }
    local batWalkingSheet = graphics.newImageSheet( "immagini/livello-3/bat.png", batWalkingSheetData )
    local batData = {
      { name="walking", sheet=batWalkingSheet, start=1, count=8, time=600, loopCount=0 }
    }
    local batTimeSpawnMin = 1500
    local batTimeSpawnMax  = 15000

    -- SACCHETTO IN PLASTICA
    local plasticbagSheetData = { width=130, height=130, numFrames=4, sheetContentWidth=520, sheetContentHeight=130 }
    local plasticbagSheet = graphics.newImageSheet( "immagini/livello-1/sacchetto.png", plasticbagSheetData )
    local plasticbagData = {
      { name="plastic", sheet=plasticbagSheet, start=1, count=4, time=460, loopCount=0 }
    }
    local plasticbagTimeSpawn = 9000

<<<<<<< HEAD
<<<<<<< HEAD
    --porta  in cui entrerò a fine livello, in questo livello è la porta che porta ai laboratori
    castle = display.newImageRect( "immagini/livello-2/last-destination.png", 700, 700 )
=======
    --porta  in cui entrerò a fine livello, in questo livello sono l'entrata delle fogne
    castle = display.newImageRect( "immagini/livello-4/last-destination.png", 500, 500 )
>>>>>>> f68bb041eaa5a58ad71430ae61b41d4168f0f7e2
=======
    --porta  in cui entrerò a fine livello, in questo livello sono l'entrata delle fogne
    castle = display.newImageRect( "immagini/livello-4/last-destination.png", 500, 500 )
>>>>>>> f68bb041eaa5a58ad71430ae61b41d4168f0f7e2
    castle.x = display.actualContentWidth + 800
    castle.y = ground.y - castle.height/2 - groundHeight/2
    group_castle:insert(castle)

    -- AGGIUNTO NEL LIVELLO 2 ---

    --Sprite del proiettile
    --IL NOSTRO PROIETTILE
    local bulletSheetData = { width=150, height=150, numFrames=3, sheetContentWidth=450, sheetContentHeight=150 }
    local bulletSheet = graphics.newImageSheet( "immagini/finale/ecoproiettile.png", bulletSheetData )
    local bulletData = {
      { name="ecoproiettile", sheet=bulletSheet, start=1, count=3, time=400, loopCount=0 }
    }
    --ESPLOSIONE QUANDO SI COLPISCE IL NEMICO CON IL PROIETTILE
    local explosionSheetData = { width=200, height=200, numFrames=12, sheetContentWidth=2400, sheetContentHeight=200 }
    local explosionSheet = graphics.newImageSheet( "immagini/livello-1/explosion.png", explosionSheetData )
    local explosionData = {
      { name="explosion", sheet=explosionSheet, start=1, count=12, time=800, loopCount=1}
    }
    -- AGGIUNTO NEL LIVELLO 3 --

    -- POZZA D'ACQUA ASSASSINA --
    local spineSheetData = { width=200, height=200, numFrames=9, sheetContentWidth=1800, sheetContentHeight=200 }
    local spineSheet = graphics.newImageSheet( "immagini/livello-3/spine2.png", spineSheetData )
    local spineData = {
      { name="spine", sheet=spineSheet, start=1, count=9, time=800, loopCount=0 }
    }


    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    -------------------- FUNZIONI LO SFONDO DEL GIOCO  -------------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------

    local function moveBackground(self) --funzione dello scroll del gioco
      --questa funzione muove il group_background di sfondo
      if 	self.x<-(display.contentWidth-frame_speed*2) then
        self.x = display.contentWidth
      else
        self.x =self.x - frame_speed --si muove di 20 in 20
      end
    end

    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    ---------------- FUNZIONI PER IL PRIMO NEMICO DEL GIOCO --------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------

    local function enemyScroll(self, event)
      --fa scorrere il nemico nello schermo
      if stop == 0 then
        self.x = self.x - (enemySpeed*2)

        if(self.id == 1) then --se sono il pipistrello allora mantengo l'altezza in y
          self.y = (display.contentHeight / 2) - 90
        end
      end
    end

    ------------------------------------------------
    local function createEnemies(type)
      --crea un oggetto di un nuovo sprite nemico e lo aggiunge alla tabella enemies[]
      --da implementare meglio, mi faccio passare che tipo di nemico devo inserire
      local enemy
      if(type == "doc") then
        enemy = display.newSprite( enemyWalkingSheet, enemyData )

        --posiziona il nemico
        enemy.x = display.actualContentWidth  + 200
        enemy.y = ground.y-150
        frameIndexNemico = 1;
        enemy.id = 0
        local outlineNemico = graphics.newOutline(6, enemyWalkingSheet, frameIndexNemico)

        -- aggiunge l'elemento della fisica al nemico
        physics.addBody(enemy, { outline=outlineNemico, density=5, bounce=0, friction=1})
        enemy.bodyType = "dynamic"
      elseif (type == "bat") then
        enemy = display.newSprite( batWalkingSheet, batData )
        enemy.id = 1

        --posiziona il nemico
        enemy.x = display.actualContentWidth  + 50
        enemy.y = (display.contentHeight / 2) - 90
        frameIndexNemico = 1;
        local outlineNemico = graphics.newOutline(5, batWalkingSheet, frameIndexNemico)

        -- aggiunge l'elemento della fisica al nemico
        physics.addBody(enemy, { outline=outlineNemico, density=5, bounce=0, friction=1})
        enemy.bodyType = "dynamic"
      end
      enemy.name = "enemy"-- chiama l'oggetto 'enemy' sarà utile in fase di collisione
      enemy:play() --fa partire l'animazione
      group_elements:insert(enemy) --lo inserisce nel gruppo sopra il bg

      enemy.isFixedRotation = true
      enemy.gravityScale = 5
      table.insert(enemies, enemy)
      return enemy
    end
    -----------------------------------------------------------
    local function enemiesLoop()
      if(stopCreatingEnemies == 0) then--se il gioco non è finito, allora continuo a creare nemici
        enemy = createEnemies("doc")  --creo un nuovo oggetto nemico
        enemy.enterFrame = enemyScroll --lo faccio scrollare
        Runtime:addEventListener("enterFrame",enemy)
        for i,thisEnemy in ipairs(enemies) do
          if thisEnemy.x < -200 then
            Runtime:removeEventListener("enterFrame",thisEnemy)
            display.remove(thisEnemy)
            table.remove(enemies,i)
          end
        end
      end
    end
    ------------------------------------------------

    local function enemiesBatLoop() --crea un nuovo nemico ratto
      if(stopCreatingEnemies == 0) then--se il gioco non è finito, allora continuo a creare nemici
        enemy = createEnemies("bat") --creo un nuovo nemico dicendogli che devo creare un ratto
        enemy.enterFrame = enemyScroll --scrollo
        Runtime:addEventListener("enterFrame",enemy)
        for i,thisEnemy in ipairs(enemies) do
          if thisEnemy.x < -200 then--se il nemico ha oltrepassato la posizione -200 in x lo elimino completamente dallo schermo e dalla tabella dei nemici
            Runtime:removeEventListener("enterFrame",thisEnemy)
            display.remove(thisEnemy)
            table.remove(enemies,i)
          end
        end
      end
    end


    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    ----------------- FUNZIONI I NEMICI A FORMA DI SPINA -----------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    local function spineScroll(self, event)
      --fa scorrere il nemico nello schermo
      if stop == 0 then
        self.x = self.x - (enemySpeed*2)
        self.y = ground.y - 145
      end
    end
    ----------------------------------------------------------------------------

    local function createSpine()
      --crea un oggetto di un nuovo sprite nemico e lo aggiunge alla tabella enemies[]
      --da implementare meglio, mi faccio passare che tipo di nemico devo inserire
      local spine = display.newSprite( spineSheet, spineData )
      spine.name = "spine"
      spine:play()
      group_elements:insert(spine)
      spine.x = display.actualContentWidth + 150
      spine.y = ground.y - 125
      local outlineSpine = graphics.newOutline(4, spineSheet, 1)
      physics.addBody(spine, { outline=outlineSpine, density=1, bounce=0, friction=1})
      spine.isBullet = true
      spine.isSensor = true
      spine.bodyType = "dynamic"
      return spine
    end
    ----------------------------------------------------------------------------

    local function spineLoop()
      if(stopCreatingEnemies == 0 ) then
        spine = createSpine()
        spine.enterFrame = spineScroll
        table.insert(table_spine, spine)
        Runtime:addEventListener("enterFrame",spine)
        for i,thisSpine in ipairs(table_spine) do
          if thisSpine.x < -200 then
            Runtime:removeEventListener("enterFrame",thisSpine)
            display.remove(thisSpine)
            table.remove(table_spine,i)
          end
        end
      end
    end


    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    ---------------- FUNZIONI PER GLI OGGETTI DI PLASTICA ----------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    local function plasticbagScroll(self, event)  --fa scrollare l'oggetto di plastica
      --fa scorrere il sacchetto nello schermo
      if stop == 0 then
        self.x = self.x - (enemySpeed*2)
        local spostamentoaria = math.random(-5, 5) --aggiunge uno spostamento dato dall'aria per rendere più credibile lo scroll
        self.y = self.y + spostamentoaria --cambia la sua posizione in y aggiungendo o diminuendola in basea allo spostamento dell'aria
      end
    end
    ----------------------------------------------------------------------------
    local function createPlasticbag()
      --crea un oggetto di un nuovo sprite del sacchetto e lo aggiunge alla tabella table_plasticbag[]
      --da implementare meglio, mi faccio passare che tipo di nemico devo inserire
      local plasticbag = display.newSprite( plasticbagSheet, plasticbagData )
      plasticbag.name = "plasticbag" -- chiama l'oggetto 'plsticbag' sarà utile in fase di collisione
      plasticbag:play() --parte l'animazione
      group_elements:insert(plasticbag)

      --posiziono l'elemento di plastica inizialmente ffuori dallo schermo
      plasticbag.x = display.actualContentWidth + 65
      plasticbag.y = 200

      local outlinePlasticbag = graphics.newOutline(20, plasticbagSheet, 1) --outline del sacchetto di plastica a partire dal frame index = 1

      --aggiungendo la fisica all'elemento
      physics.addBody(plasticbag, { outline=outlinePlasticbag, density=1, bounce=0, friction=1})
      plasticbag.isBullet = true
      plasticbag.isSensor = true
      plasticbag.bodyType = "static"
      table.insert(table_plasticbag, plasticbag) --aggiunge l'elemento appena creato ad una tabella che andrà a contenere tutti gli oggetti di plastica
      return plasticbag
    end
    ------------------------------------------------
    local function plasticbagLoop()
      if(stopCreatingEnemies == 0) then
        plasticbag = createPlasticbag() --creo un'istanza di un oggetto sprite plastic bag
        plasticbag.enterFrame = plasticbagScroll --lo faccio scrollare, grazie alla funzione plasticbagScroll
        Runtime:addEventListener("enterFrame", plasticbag) --assegno all'evento enterframe lo scroll
        for i,thisPlasticbag in ipairs(table_plasticbag) do  --ipairs ritorna: an iteration Function, a Table, and 0. (?? trovata online)
          if thisPlasticbag.x < -200 then --se c'è un sacchetto di plastica che ha superato il limite di -200, lo togliamo!
            Runtime:removeEventListener("enterFrame",thisPlasticbag) --rimuovo l'ascoltatore che lo fa scrollare
            display.remove(thisPlasticbag) --rimuove QUEL sacchetto di plastica dal display display
            table.remove(table_plasticbag,i) --lo rimuove anche dalla tabella dei sacchetti di plastica
          end
        end
      end
    end


    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    -------------- FUNZIONI PER LE COLLISIONI CON ALTRI SPRITE -----------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    function gameOver()
      stop = 1 -- grazie a questo le animazioni personagggi non scrolleranno più
      -- audio
      stopCreatingEnemies = 1 --stoppa di creare nuovi nemici
      audio.pause(crunchSound)
      --audio.setMaxVolume(0.03)
      local audiogameover = audio.loadSound("MUSIC/PERDENTE.mp3")
      audio.play(audiogameover)
      --audio.play(audiogameover)
      resetScene("all")
      composer.gotoScene( "levels.gameover", options )
    end
    ----------------------------------------------------------------------------

    --funzione che capisce se c'è collisione con un elemento
    function sprite.collision( self, event )
      if( event.phase == "began" ) then
        --tutte le informazioni dell'elemento che ho toccato le troviamo dentro event.other
        if(event.other.name ==  "plasticbag") then --mi sono scontrato con il sacchetto
          -- audio.setMaxVolume(0.03)
          audio.play(crunchSound)
          scoreCount = scoreCount+1;
          scoreText.text = scoreCount.."/10"
          Runtime:removeEventListener("enterFrame", event.other) --rimuovo il listener dello scroll, così non si muove più
          local indexToRemove = table.indexOf(table_plasticbag, event.other ) --trovo l'indice che ha all'interno della tabella dei sacchetti di plastica
          table.remove(table_plasticbag, indexToRemove) --lo rimuovo dalla tabella, utilizzando l'indice 'indexToRemove'
          display:remove(event.other) --lo rimuovo dal display
          group_elements:remove(event.other) --lo rimuovo dal gruppo (????? serve??? NON LO SO, VEDIAMO SE DARA' PROBLEMI)
        end
        if(event.other.name ==  "enemy") or (event.other.name ==  "spine") then
          gameOver()
        end
        if(event.other.name == "ground") or (event.other.name == "platform") then
          sprite.isJumping = false
          sprite:setSequence("walking")
        end
      end
    end
    sprite:addEventListener("collision")

    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    --------------------- FUNZIONI PER IL LOOP DEL GIOCO  ----------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------

    local function loop( event )
      --qui dentro metteremo tutte le cose che necessitano di un loop all'interno del gioco
      --richiamo le due funzioni per muovere lo sfondo
      moveBackground(bg[1])
      moveBackground(bg[2])
      sprite:play()
      if(sprite.x < 0) then
        gameOver()
      end
    end

    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    ------- FUNZIONI PER LO SCROLL DEL CASTELLO FINALE DOVE ENTRERO'  ----------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    function castleScroll() --funzione per far apparire nello schermo un castello in cui il blob entrerà
      --in modo molto ignorante sposta il castello verso il nostro personaggio e ci vado incontro
      if(castle.x > (display.actualContentWidth- (display.actualContentWidth / 4))) then --mando avanti il castello di sabbia fino ad un certo punto
        castle.x = castle.x - 20 --sposto il castello di 20 pixel
      else
        Runtime:removeEventListener("enterFrame", castleScroll) -- rimuovo l'evento event scroll
        gameFinished = 1 --imposto la variabile a 1, grazie a questo eliminerò anche le funzioni che ho creato qui  sopra
        timer.cancel( gameLoop ) --non mando più avanti lo sfondo di background
        Runtime:addEventListener("enterFrame", spriteScrollToCastle) --faccio parire la funzione che manderà avanti di un po' lo scroll
      end
    end
    ----------------------------------------------------------------------------

    function spriteScrollToCastle() --avvicina lo sprite al castello
      local CastlePosition = castle.x - 20 --piglio la posizione del castello
      if(sprite.x <= CastlePosition) then --se la posizione dello sprite è dietro a quella del castello, vado ancora avanti
        sprite.x = sprite. x + 3 --lo sposto in avanti di 3
      else
        goToTheNewScene()
      end
    end
    ----------------------------------------------------------------------------

    function goToTheNewScene()
      local options = {
        effect = "fade", --animazione
        time = 500, --tempo che durerà l'animazione
        params = { level= 5, imagetoshow = 2 } --parametri che gli passo: il numero del livello a cui andare dopo la storia e il numero di immagini da mostrare
        }
      composer.gotoScene( "levels.storylevel", options) --vado alla nuova scena
    end



    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    --------------- FUNZIONI PER L'INCREMENDO DELLA VELOCITA' ------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    local function increaseGameSpeed(event)
      secondsPlayed = secondsPlayed + 1 --ogni secondo che passa aumento questa variabile che tiene conto di quanto tempo è passato
      print("seconds played: " ..secondsPlayed)
      if(gameLoop._delay >= time_speed_max) then --minimo di millisecondi a cui può spingersi la funzione loop
        --time speed con cui viene richiamata la funzione loop
        local x_time_speed = ((time_speed_max * secondsPlayed) / timeToPlay) --ottiene un numero da 1 a 6
        gameLoop._delay = time_speed_min - ((time_speed_min * x_time_speed)/time_speed_max ) --il time delay è frutto di un'altra proporzione da 6 a 30
        --cambio della velocità del nostro nemico [da 2 a 12] --> secondi passati : secondi totali = x : 12 (ritornerà un numero da 1 a 12)
        local x_enemySpeed = ((enemySpeed_max * secondsPlayed)/timeToPlay)
        enemySpeed = enemySpeed_min + x_enemySpeed --la velocità è data dalla velocità minima (2) + il risultato della proporzione
      end
      if(secondsPlayed >= timeToPlay ) then --se è ora di far finire il gioco, vado al passo successivo
        stopCreatingEnemies = 1 --non creo più nemici perchè il tempo è finito
        if(secondsPlayed >= timeToPlay + 5) then --faccio apparire dopo 5 secondi il castello di sabbia
          stop = 1 --blocco l'animazione dello scorrimento di sfondo
          if (castleAppared == 0 ) then --se non ho già fatto apparire il castello, lo faccio apparire
            castleAppared = 1 --non lo faccio più riapparire
            sprite:removeEventListener("collision") --rimuove l'ascoltatore delle collisioni con i nemici
            Runtime:addEventListener("enterFrame", castleScroll) --chiamo la funzione castleScroll per spostare il castello
          end
        end
      end
    end

    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    ------------- FUNZIONI PER IL PROIETTILE E LATTINA DI PLASTICA --------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------

    local function bulletScroll(self, event)
      --fa scorrere il sacchetto nello schermo
      if stop == 0 then
        self.x = self.x + 10 --fa andare  avanti il proiettile in x senza spostarsi in y
        if self.x > display.actualContentWidth + 30 then --se c'è un sacchetto di plastica che ha superato il limite di -200, lo togliamo!
          self:removeEventListener( "collision", onBulletCollision ) --rimuovo l'ascoltatore per la collisione di quel sprite
          Runtime:removeEventListener("enterFrame",self) --rimuovo l'ascoltatore che lo fa scrollare
          group_elements:remove(self)
          display.remove(self) --rimuove QUEL sacchetto di plastica dal display display
          local res = table.remove(table_bullets, table.indexOf( table_bullets, self )) --lo rimuove anche dalla tabella dei proeittili
        end
      end
    end

    ----------------------------------------------------------------------------
    function onBulletCollision( event ) --controlla se ci state collisioni del proiettile con il nemico
      print(event.other.name)
      if(tostring(event.other.name) == "enemy") then --se il proiettile si è scontrato contro un nemico allora..
        enemyKilled = event.other --salvo dentro enemyKilled l'indirizzo che mi porta al nemico ucciso
        --Riproduco l'animazione dell'esplosione nelle stesse coordinate in cui si trova il nemico nel momento della collisione
        local explosion = display.newSprite( explosionSheet, explosionData ) --salvo dentro explosion l'animazione dell'esplosione
        explosion.name = "explosion"
        group_elements:insert(explosion)
        explosion.x = enemyKilled.x - 75
        explosion.y = enemyKilled.y
        explosion:play()
        audio.play( explosionSound3 ) --faccio partire audio esplosione

        --rimuovo il nemico dallo schermo
        Runtime:removeEventListener("enterFrame", enemyKilled) --non faccio più muovere il nemico
        display.remove(enemyKilled) --rimuovo dal display il nemico
        local position = table.indexOf(enemies, enemyKilled) --carico dentro la variabile position la posizione del nemico colpito dentro la tabella dei nemici
        table.remove(enemies,position) --rimuovo dalla tabella enemies il nemico colpito

        --rimuovo la bottiglia appena lanciata
        group_elements:remove(event.target)
        event.target:removeEventListener( "collision", onBulletCollision ) --rimuovo l'ascoltatore per la collisione di quel sprite
        Runtime:removeEventListener("enterFrame",event.target) --rimuovo l'ascoltatore che lo fa scrollare
        display.remove(event.target) --rimuove QUELLA bottiglia di plastica dal display
        local res = table.remove(table_bullets, table.indexOf( table_bullets, event.target )) --lo rimuove anche dalla tabella dei proeittili
      end
    end

    ---------------------------------------------------
    local function createBullet()
      --crea un oggetto di un nuovo sprite del sacchetto e lo aggiunge alla tabella table_plasticbag[]
      --da implementare meglio, mi faccio passare che tipo di nemico devo inserire
      local bullet = display.newSprite( bulletSheet, bulletData )
      bullet.name = "bullet"
      bullet:play()
      group_elements:insert(bullet)
      bullet.x = sprite.x + 80
      bullet.y = sprite.y
      local outlineBullet = graphics.newOutline(1, bulletSheet, 2)
      physics.addBody(bullet, { outline=outlineBullet, density=1, bounce=0, friction=1})
      bullet.isBullet = true
      bullet.isSensor = true
      bullet.bodyType = "static"
      return bullet
    end


    ------------------------------------------------
    local function bulletsLoop()
      bullet = createBullet() --creo un'istanza di un oggetto sprite plastic bag
      table.insert(table_bullets, bullet)
      bullet:addEventListener( "collision", onBulletCollision )
      bullet.enterFrame = bulletScroll --lo faccio scrollare, grazie alla funzione plasticbagScroll
      Runtime:addEventListener("enterFrame", bullet) --assegno all'evento enterframe lo scroll
    end

    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    ---------------------- FUNZIONI PER LE PIATTAFORME--------------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    local function platformScroll(self, event)
      --fa scorrere il nemico nello schermo
      if stop == 0 then
        self.x = self.x - (enemySpeed*2)
      end
    end

    ----------------------------------------------------------------------------

    local function createPlatform()
      --crea un oggetto di un nuovo sprite nemico e lo aggiunge alla tabella enemies[]
      --da implementare meglio, mi faccio passare che tipo di nemico devo inserire
      local platform = display.newImageRect( "immagini/livello-3/platform.png", 320, 125 )
      platform.name = "platform"
      group_elements:insert(platform)
      platform.x = display.actualContentWidth + 200
      platform.y = (display.contentHeight / 2) + 40
      local outlinePlatform = graphics.newOutline(2, "immagini/livello-3/platform.png")
      physics.addBody(platform, "static", { outline=outlinePlatform, bounce=0, friction=1 } )
      platform.collType = "passthru"
      --print("creata una piattaforma")
      return platform
    end

    ----------------------------------------------------------------------------

    local function platformLoop()
      if(stopCreatingEnemies == 0 ) then
        platform = createPlatform()
        platform.enterFrame = platformScroll
        table.insert(table_platform, platform)
        Runtime:addEventListener("enterFrame",platform)
        for i,thisPlatform in ipairs(table_platform) do
          if thisPlatform.x < -300 then
            Runtime:removeEventListener("enterFrame",thisPlatform)
            display.remove(thisPlatform)
            table.remove(table_platform,i)
          end
        end
      end
    end

    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    ----------- ASCOLTATORE CHE CAPISCE SE DEVO SPARARE O SALTARE --------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------

    function touchListener(event)
      if ( event.phase == "began" ) then --è finito il processo di touch dello sschermo
        if ((event.x >= 0 ) and (event.x <= display.actualContentWidth/2) and (not sprite.isJumping) )then
          sprite:setLinearVelocity(0,- 1750)
          sprite.isJumping = true -- se ho toccato imposto la variabile isJumping del mio personaggio a true
          sprite:setSequence("jumping") --lo sprite si muove con animazione jumping
          sprite:play()
        elseif (event.x > display.actualContentWidth / 2) and (event.x <= display.contentWidth) then
          --ho cliccato sulla parte destra dello shcermo, devo sparare
          if(scoreCount > 0) then
            bulletsLoop()
            scoreCount = scoreCount - 1
            scoreText.text = scoreCount.."/10"
          end
        end
      end
    end
    Runtime:addEventListener( "touch", touchListener )

    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    -------------------- BOTTONI E ALTRI ELEMENTI VISIVI -----------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    button_home = display.newImageRect( "immagini/menu/home.png", 100, 100 ) --immagine per tornare alla home
    button_home.anchorX =  0
    button_home.anchorY =  0
    button_home.x = display.actualContentWidth - 120
    button_home.y = 50
    group_elements:insert(button_home)

    function button_home:touch( event ) --ascoltatore di touch del bottone di home
      if event.phase == "ended" then
        stop = 1 --blocco le animazioni di scorrimento sfondo
        stopCreatingEnemies =1
        timer.performWithDelay( 500, function() composer.gotoScene( "menu-levels", "fade", 500 ) end)  --ritorno al menu dei livelli
      end
    end
    button_home:addEventListener( "touch", touch )




    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    ---------------------------------- TIMER  ----------------------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    timeplayed = timer.performWithDelay( 1000, increaseGameSpeed, 0 )
    gameLoop = timer.performWithDelay( time_speed_min, loop, 0 )


    --rendo queste cinque variabili delle tabelle di oggetti che conterranno vari timer che andranno a richiamare i sacchetti di plastica e i nemici
    callingEnemies = {}
    callingBats = {}
    callingPlasticbag = {}
    callingSpine = {}
    callingPlatform = {}

    --mutanti
    callingEnemies[1] = timer.performWithDelay( 3000, enemiesLoop, 0 )
    callingEnemies[2] = timer.performWithDelay( 25900, enemiesLoop, 1 )
    callingEnemies[3] = timer.performWithDelay( 55000, enemiesLoop, 1 )

    --pipistrelli
    callingBats[1] = timer.performWithDelay( 4000, enemiesBatLoop, 1 )
    callingBats[2] = timer.performWithDelay( 7000, enemiesBatLoop, 1 )
    callingBats[3] = timer.performWithDelay( 11000, enemiesBatLoop, 1 )
    callingBats[4] = timer.performWithDelay( 14500, enemiesBatLoop, 1 )
    callingBats[5] = timer.performWithDelay( 20500, enemiesBatLoop, 1 )
    callingBats[6] = timer.performWithDelay( 32500, enemiesBatLoop, 1 )
    callingBats[7] = timer.performWithDelay( 34500, enemiesBatLoop, 1 )
    callingBats[8] = timer.performWithDelay( 38500, enemiesBatLoop, 1 )
    callingBats[9] = timer.performWithDelay( 42600, enemiesBatLoop, 1 )
    callingBats[10] = timer.performWithDelay( 51000, enemiesBatLoop, 1 )
    --callingBats[11] = timer.performWithDelay( 55500, enemiesBatLoop, 1 )
    callingBats[11] = timer.performWithDelay( 57500, enemiesBatLoop, 1 )

    --piattaforme
    callingPlatform[1] = timer.performWithDelay( 8000, platformLoop, 1)
    callingPlatform[2] = timer.performWithDelay( 20000, platformLoop, 1 )
    callingPlatform[3] = timer.performWithDelay( 28000, platformLoop, 1)
    callingPlatform[4] = timer.performWithDelay( 31500, platformLoop, 1)
    callingPlatform[5] = timer.performWithDelay( 36500, platformLoop, 1)
    callingPlatform[6] = timer.performWithDelay( 53500, platformLoop, 1)

    --spine
    callingSpine[1] = timer.performWithDelay( 1000, spineLoop, 1)
    callingSpine[2] = timer.performWithDelay( 5000, spineLoop, 1)
    callingSpine[3] = timer.performWithDelay( 10000, spineLoop, 1)
    callingSpine[4] = timer.performWithDelay( 13500, spineLoop, 1)
    callingSpine[5] = timer.performWithDelay( 17000, spineLoop, 1)
    callingSpine[6] = timer.performWithDelay( 22500, spineLoop, 1)
    callingSpine[7] = timer.performWithDelay( 25000, spineLoop, 1)
    callingSpine[8] = timer.performWithDelay( 35000, spineLoop, 1)
    callingSpine[9] = timer.performWithDelay( 37000, spineLoop, 1)
    callingSpine[10] = timer.performWithDelay( 46000, spineLoop, 1)
    callingSpine[11] = timer.performWithDelay( 49000, spineLoop, 1)
    callingSpine[12] = timer.performWithDelay( 53000, spineLoop, 1)
    callingSpine[13] = timer.performWithDelay( 58000, spineLoop, 1)
    callingSpine[14] = timer.performWithDelay( 16000, spineLoop, 1)
    callingSpine[15] = timer.performWithDelay( 30900, spineLoop, 1)


    --plastiche
    callingPlasticbag[1] = timer.performWithDelay( 3000, plasticbagLoop, 1)
    callingPlasticbag[2] = timer.performWithDelay( 12000, plasticbagLoop, 1)
    callingPlasticbag[3] = timer.performWithDelay( 20000, plasticbagLoop, 1)
    callingPlasticbag[4] = timer.performWithDelay( 25000, plasticbagLoop, 1)
    callingPlasticbag[5] = timer.performWithDelay( 31500, plasticbagLoop, 1)
    callingPlasticbag[6] = timer.performWithDelay( 36000, plasticbagLoop, 1)
    callingPlasticbag[7] = timer.performWithDelay( 42000, plasticbagLoop, 1)
    callingPlasticbag[8] = timer.performWithDelay( 48000, plasticbagLoop, 1)
    callingPlasticbag[9] = timer.performWithDelay( 53500, plasticbagLoop, 1)
    callingPlasticbag[10] = timer.performWithDelay( 60000, plasticbagLoop, 1)
  end
end


function scene:hide( event )
  local sceneGroup = self.view

  local phase = event.phase

  if event.phase == "will" then
    -- Called when the scene is on screen and is about to move off screen
    if(gameFinished == 1) then --se gameFinished è 1 vuol dire che ho correttamente completato il livello,, sennò vol dire che sono morto
      updateHighScore(scoreCount) --mando il punteggio appena raggiunto alla funzione che permetterà di aggiornarlo
      resetScene("gamefinished") --se entro qui devo cancellare anche un timeloop che è partito con l'avvicinamento del castello di sabbia
    else
      resetScene("gameOver")  --se entro qui sono uscito prima dal livello, devo eliminare meno timer all'interno del gioco
    end

  elseif phase == "did" then
    --cancella tutto il contenuto all'interno di una scena senza salvare i contenuti
    audio.stop( 3 ) --la musica del livello 1 si ferma
    local sceneToRemove = "levels.level"..localLevel --questo codice prende in modo dinamico la scena su cui siamo ed elimina gli elementi all'interno
    local r = composer.removeScene( sceneToRemove)
    print(tostring(r))
  end

end

function scene:destroy( event )

  -- Called prior to the removal of scene's "view" (sceneGroup)
  --
  -- INSERT code here to cleanup the scene
  -- e.g. remove display objects, remove touch listeners, save state, etc.
  audio.dispose( musicLevel3) --elimino la musica del livello
  local sceneGroup = self.view
end


----------------------------------------------
--FUNZIONE PER AGGIORNARE L'HIGHSCORE
function updateHighScore(scoreCount) --funzione che serve per aggiornare l'high score dell'utente
  local sqlite3 = require( "sqlite3" )
  local path = system.pathForFile( "data.db", system.DocumentsDirectory )
  local db = sqlite3.open( path )
  local levels = {} --creo una  tabella per memorizzare i dati che mi servrà per scegliere se il punteggio è un record o no
  for row in db:nrows( "SELECT level, scoreLevel4 FROM levels" ) do
    levels[#levels+1] =
    {
      level = row.level,
      scoreLevel = row.scoreLevel4
    }
    local oldScore= levels[1].scoreLevel --salvo il punteggio che è già presente all'interno del database
    local levelReached = levels[1].level --mi scrivo il livello a cui è arrivato l'utente all'interno del gioco, se è l'1 allora aggiorneremo a 2 e gli permetteremo di fare un nuovo livello
    if(tonumber(levelReached) == tonumber(localLevel)) then --se sono al livello 1, devo aumentare il livello
      if (tonumber(oldScore)<scoreCount) then --se il nuovo è punteggio è maggiore di quello già presente nel db entro nell'if
        local query =("UPDATE levels SET level ='" .. (levelReached+1) .. "' ,scoreLevel4 = '" ..scoreCount .. "' WHERE ID = 1")
        local pushQuery = db:exec (query)
      elseif (tonumber(oldScore) >= scoreCount) then --devo solamente aumentare solo il livello"
        local query =("UPDATE levels SET level ='" .. (levelReached+1) .. "' WHERE ID = 1")
        local pushQuery = db:exec (query)
      end
    else
      if((tonumber(oldScore) < scoreCount)) then
        local query =("UPDATE levels SET scoreLevel4 = '" ..scoreCount .. "' WHERE ID = 1")
        local pushQuery = db:exec (query)
      end
    end
  end
  if ( db and db:isopen() ) then --chiuso la connessione al database
    db:close()
  end
end
----------------------------------------------

function resetScene( tipo)

  --LA DIFFERENZA TRA I DUE TIPI E' CHE:
  -- IN (TIPO == "GAMEFINISHED") DEVO CANCELLARE PIU' ASCOLTATORI E TIMER COME QUELLO DELLA COMPARSA DEL CASTELLO

  --ELIMINO PRIMA LE COSE IN COMUNE
  --resetto le variabili per capire se sta suonando la musica di background nel menu o nel menu levels
    timer.cancel( timeplayed ) --non faccio più andare il  conteggio dei secondi
    composer.isAudioPlaying=0
    physics.pause()

    --elimino i listeners
    Runtime:removeEventListener("enterFrame",enemy)
    Runtime:removeEventListener("enterFrame",plasticbag)
    Runtime:removeEventListener( "touch", touchListener )
    button_home:removeEventListener( "touch", touch )
    button_home:removeEventListener( "touch", touch )

    --Svuoto le tabelle
    --prima svuoto le tabelle che ho usato per richiamare i vari timer di comparsa dei nemici e degli oggetti di plastica
    for i=1, #callingEnemies do
      timer.cancel( callingEnemies[i] )
      callingEnemies[i] = nil
    end
    for i=1, #callingBats do
      timer.cancel( callingBats[i] )
      callingBats[i] = nil        -- Nil Out Table Instance
    end
    for i=1, #callingPlasticbag do
      timer.cancel( callingPlasticbag[i] )
      callingPlasticbag[i] = nil        -- Nil Out Table Instance
    end
    for i=1, #callingSpine do
      timer.cancel( callingSpine[i] )
      callingSpine[i] = nil        -- Nil Out Table Instance
    end
    for i=1, #callingPlatform do
      timer.cancel( callingPlatform[i] )
      callingPlatform[i] = nil        -- Nil Out Table Instance
    end

    --Ora cancello i dati dalle tabelle che ho usato per memorizzre tutti gli oggetti tra cui i nemici, piattaforme ecc.
    for i=1, #enemies do
      enemies[i]:removeSelf() -- Optional Display Object Removal
      enemies[i] = nil        -- Nil Out Table Instance
    end
    for i=1, #table_plasticbag do
      table_plasticbag[i]:removeSelf() -- Optional Display Object Removal
      table_plasticbag[i] = nil        -- Nil Out Table Instance
    end
    for i=1, #table_bullets do
      Runtime:removeEventListener("enterFrame",  table_bullets[i])
      table_bullets[i]:removeEventListener( "collision", onBulletCollision )
      table_bullets[i]:removeSelf() -- Optional Display Object Removal
      table_bullets[i] = nil        -- Nil Out Table Instance
    end
    for i=1, #table_spine do
      Runtime:removeEventListener("enterFrame",  table_spine[i])
      table_spine[i]:removeSelf() -- Optional Display Object Removal
      table_spine[i] = nil        -- Nil Out Table Instance
    end
    for i=1, #table_platform do
      Runtime:removeEventListener("enterFrame",  table_platform[i])
      table_platform[i]:removeSelf() -- Optional Display Object Removal
      table_platform[i] = nil        -- Nil Out Table Instance
    end

  if tipo == "gameOver" then
    --cancelllo il timer del gameLoop e i listeners rimasti
    timer.cancel( gameLoop )
    sprite:removeEventListener("collision")
    
  elseif tipo == "gamefinished" then
    --elimino i listeners che ho richiamato nel momento in cui devo far arrivare l'entrata finale
    Runtime:removeEventListener("enterFrame", spriteScrollToCastle)
    Runtime:removeEventListener("enterFrame", castleScroll)
  end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene