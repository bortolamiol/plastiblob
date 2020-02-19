--------------------------------------------------------------------------------
--
-- PRIMO LIVELLO DEL GIOCO: SALTARE I NEMICI E RACCOGLIERE LA PLASTICA DAL CIELO
--
---------------------------------------------------------------------------------

-- dichiaro delle variabili che andrò a usare in varie scene del livello
local localLevel = 1 --VARIABILE CHE CONTIENE IL NUMERO DI LIVELLO A CUI APPARTIENE IL FILE LUA: IN QUESTO CASO SIAMO AL LIVELLO 1
local composer = require( "composer" ) --richiedo la libreria composer
local scene = composer.newScene() --nuova scena composer
local tutorial = 1 --ho completato il tutorial? se è 0 devo ancora farlo!
local bg --variabile che durante lo show conterrà le due immagini di sfondo che andranno una dopo l'altra
local punteggio --variabile che conterrà il mio punteggio del livello
local sprite --sprite del personaggio
local enemies = {} --sprite dei nemici
local table_plasticbag = {}
local button_home --bottone per uscire dal livello e tornare alla button_home dei livelli
local stop =  0 --variabile che servirà per capire se stoppare il gioco
local stopCreatingEnemies =  0 --variabile che servirà per capire se stoppare il gioco
local callingEnemies
local castle
local callingPlasticbag
local timeplayed  --varaiabile che misura da quanti secondi sono all'interno del gioco e farà cambiare la velocità
local timeToPlay = 60 --variabile che conterrà quanto l'utente dovrà sopravvivere all'interno del gioco
local scoreCount    --variabile conteggio punteggio iniziale
local gameFinished
local newTimerOut
local nextScene = "menu-levels"
local crunchSound = audio.loadSound("MUSIC/crunch.mp3") --carico suono "crunch"
local musicLevel1
function scene:create( event )

  -- Called when the scene's view does not exist.
  --
  -- INSERT code here to initialize the scene
  -- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
  local sceneGroup = self.view
  --creo due nuovi gruppi che inserirò all'interno del gruppo 'padre' sceneGroup
  group_tutorial = display.newGroup() --group_background conterrà la foto di sfondo che scrollerà
  group_background = display.newGroup() --group_background conterrà la foto di sfondo che scrollerà
  group_castle = display.newGroup() --group_elements conterrà tutti gli altri elementi dello schermo: sprite del personaggio, nemici e bottoni per uscire dal gioco
  group_elements = display.newGroup() --group_elements conterrà tutti gli altri elementi dello schermo: sprite del personaggio, nemici e bottoni per uscire dal gioco
  sceneGroup:insert( group_tutorial ) --inserisco il gruppo group_tutorial dentro la scena
  sceneGroup:insert( group_background ) --inserisco il gruppo group_background dentro la scena
  sceneGroup:insert( group_castle ) --inserisco il gruppo castle sopra la scena e sotto i personaggi
  sceneGroup:insert( group_elements ) --inserisco il gruppo group_elements dentro la scena

  musicLevel1 = audio.loadStream("MUSIC/level1.mp3")
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

  elseif phase == "did" then
    audio.play( musicLevel1, { channel=3, loops=-1 } ) --parte la musica del livello 1


    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    -------------------------   PARAMETRI DEL LIVELLO  -------------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    local options = {
      effect = "fade",
      time = 1000,
      params = { level="level1"} -- questa variabile verrà utilizzata dal gameover pper capire a che livello tornare
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
    bg[1] = display.newImageRect("immagini/livello-1/background.png", _w, _h)
    bg[1].anchorY = 0
    bg[1].anchorX = 0
    bg[1].x = 0
    bg[1].y = _y
    group_background:insert(bg[1])
    bg[2] = display.newImageRect("immagini/livello-1/background.png", _w, _h)
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
    local enemySpeed_max = 7.5 -- massima velocità di spostamento del nemico
    local enemySpeed_min = 4.5-- minima velocità di spostamento del nemico
    local enemySpeed = enemySpeed_min --velocità iniziale di spostamento del nemico, parte dal valore minimo

    local frame_speed = 20 --questa sarà la velocità dello scorrimento del nostro sfondo, si sposta di 20 pixel in 20

    local time_speed_min = 30 -- ogni quanti millisecondi verranno chiamate le funzioni di loop (esempio di sfondo group_background)
    local time_speed_max = 6 -- massimo di velocità che time_speed può raggiungere

    local plasticToCatch = 10 --numero di oggetti di plastica che l'utente dovrà raccogliere




    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    ---------------------   SPRITE E ANIMAZIONI DI GIOCO  ----------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------

    -- Terreno del gioco, un elemento statico e di colore trasparente
    local groundHeight = 100 --ha un'altezza di 100 px
    local ground = display.newRect( 0, 0,99999, groundHeight )
    ground:setFillColor(0,0,0,0) --colore trasparente
    ground.name = "ground" --il nome servirà in fase di collisione con il nostro sprite, per sapere che dovrà togliere l'animazione del salto e tornare su quella della camminata
    group_elements:insert(ground) --lo inserisco sopra il background
    ground.x = display.contentCenterX
    ground.y = display.contentHeight- groundHeight/2
    physics.addBody(ground, "static",{bounce=0, friction=1 } )


    --Testo dello score, che andrà a dire quanti oggetti di plastica abbiamo raccolto durante il gioco (su x/10)
    local scoreText = display.newText( scoreCount.."/"..plasticToCatch, display.contentCenterX, display.contentCenterY-300, native.systemFont, 28 )
    scoreText:setFillColor( 1, 1, 0 )
    group_elements:insert(scoreText)


    -- Sprite per il personaggio del gioco che cammina
    local spriteWalkingSheetData =
    {
      width=200,
      height=200,
      numFrames=8,
      sheetContentWidth=1600,
      sheetContentHeight=200
    }
    local spriteWalkingSheet = graphics.newImageSheet( "immagini/livello-1/spritewalking.png", spriteWalkingSheetData )


    --  Sprite per il personaggio del gioco che salta
    local spriteJumpingSheetData =
    {
      width=200,
      height=200,
      numFrames=8,
      sheetContentWidth=1600,
      sheetContentHeight=200
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
    sprite.mustChangeOutlineToWalk = false --variabile che mi servirà per  cambiare l'outline del personaggio da jumping a walking

    -- Sprite del primo nemico
    local enemyWalkingSheetData = { width=200, height=200, numFrames=8, sheetContentWidth=1600, sheetContentHeight=200 }
    local enemyWalkingSheet = graphics.newImageSheet( "immagini/livello-1/zombiewalking.png", enemyWalkingSheetData )
    local enemyData = {
      { name="walking", sheet=enemyWalkingSheet, start=1, count=8, time=800, loopCount=0 }
    }
    local enemyTimeSpawnMin = 5000
    local enemyTimeSpawnMax  = 5000

    -- Sprite del sacchetto in plastica che dobbiamo raccogliere
    local plasticbagSheetData = { width=130, height=130, numFrames=4, sheetContentWidth=520, sheetContentHeight=130 }
    local plasticbagSheet = graphics.newImageSheet( "immagini/livello-1/sacchetto.png", plasticbagSheetData )
    local plasticbagData = {
      { name="plastic", sheet=plasticbagSheet, start=1, count=4, time=500, loopCount=0 }
    }
    local plasticbagTimeSpawn = 5000


    --Sprite del castello di sabbia in cui entreremo a fine livello
    castle = display.newImageRect( "immagini/livello-1/last-destination.png", 700, 700 )
    castle.x = display.actualContentWidth + 800
    castle.y = ground.y - castle.height/2 - groundHeight/2
    group_castle:insert(castle)


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
    ------------------- FUNZIONI PER I NEMICI DEL GIOCO ------------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    local function enemyScroll(self, event)
      --fa scorrere il nemico nello schermo
      if stop == 0 then
        self.x = self.x - (enemySpeed*2) --enemySpeed cambia durante il gioco, più il tempo passa e più enemySpeed sarà maggiore
      end
    end
    ----------------------------------------------------------------------------
    local function createEnemies()
      --crea un oggetto di un nuovo sprite nemico e lo aggiunge alla tabella enemies[]
      --da implementare meglio, mi faccio passare che tipo di nemico devo inserire
      local enemy = display.newSprite( enemyWalkingSheet, enemyData )
      enemy.name = "enemy" -- chiama l'oggetto 'enemy' sarà utile in fase di collisione
      enemy:play() --fa partire l'animazione
      group_elements:insert(enemy) --lo inserisce nel gruppo sopra il bg

      --posiziona il nemico
      enemy.x = display.actualContentWidth + 50
      enemy.y = ground.y-150

      local outlineNemico = graphics.newOutline(5, enemyWalkingSheet, 1) --crea l'outline del nemico

      -- aggiunge l'elemento della fisica al nemico
      physics.addBody(enemy, { outline=outlineNemico, density=5, bounce=0, friction=1})
      enemy.bodyType = "static"
      enemy.isFixedRotation = true
      enemy.gravityScale = 5
      table.insert(enemies, enemy) --aggiunge l'elemento appena creato ad una tabella che andrà a contenere tutti gli oggetti dei nemici
      return enemy --ritorna l'oggetto creato
    end
    ----------------------------------------------------------------------------
    local function enemiesLoop()
      if(stopCreatingEnemies == 0) then --se il gioco non è finito, allora continuo a creare nemici
        enemy = createEnemies() --creo un nuovo oggetto nemico
        enemy.enterFrame = enemyScroll --lo faccio scrollare
        Runtime:addEventListener("enterFrame",enemy)
        for i,thisEnemy in ipairs(enemies) do
          if thisEnemy.x < -200 then --se il nemico ha oltrepassato la posizione -200 in x lo elimino completamente dallo schermo e dalla tabella dei nemici
            Runtime:removeEventListener("enterFrame",thisEnemy)
            display.remove(thisEnemy)
            table.remove(enemies,i)
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

    -- Funzione che va a capire con che elemento ho effettuato la collsione
    function sprite.collision( self, event )
      if( event.phase == "began" ) then
        --tutte le informazioni dell'elemento che ho toccato le troviamo dentro event.other
        if(event.other.name ==  "plasticbag") then --mi sono scontrato con il sacchetto
          --audio.setVolume(0.03)
          audio.play(crunchSound) --fai partire il suono "crunch"
          scoreCount = scoreCount+1; --aggiorno lo score
          scoreText.text = scoreCount.."/"..plasticToCatch --aggiorno il testo dei numeri di oggetti di plastica raccolti
          Runtime:removeEventListener("enterFrame", event.other) --rimuovo il listener dello scroll, così non si muove più
          local indexToRemove = table.indexOf(table_plasticbag, event.other ) --trovo l'indice che ha all'interno della tabella dei sacchetti di plastica
          table.remove(table_plasticbag, indexToRemove) --lo rimuovo dalla tabella, utilizzando l'indice 'indexToRemove'
          display:remove(event.other) --lo rimuovo dal display
          group_elements:remove(event.other) --lo rimuovo dal gruppo
        end
        if(event.other.name ==  "enemy") then --mi sono scontrato con il nemico
          stop = 1 --stoppo lo scorrimento di sfondo bg
          stopCreatingEnemies = 1 --stoppo la crezione di nuovi nemici
          audio.pause(crunchSound) --blocco l'audio crunch nel caso stesse suonando
          local audiogameover = audio.loadSound("MUSIC/PERDENTE.mp3") --carico suono "gameover"
          --audio.setVolume(0.03)
          audio.play(audiogameover) --faccio partire l'audio game over
          resetScene("all") --richiamo la funzione per resettare tutti gli elementi dello schermo
          composer.gotoScene( "levels.gameover", options ) --vado alla schermata di gameover, passandogli con il parametro options la variabile level = 1
        end
      end
    end
    sprite:addEventListener("collision") --ascoltatore

    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    ---------------- FUNZIONI PER IL SALTO E PRE-COLLISIONE  -------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    function sprite.touch( self,event)
      vx, vy = sprite:getLinearVelocity()
      if( event.phase == "began" and not self.isJumping ) then
        self:setLinearVelocity(0,-2550) --applico una forza lineare all'oggetto per farlo saltare
        self.isJumping = true -- se ho toccato imposto la variabile isJumping del mio personaggio a true
        self:setSequence("jumping") --lo sprite si muove con animazione jumping
        self:play()
        changeOutline("jump") --cambio l'outline del personaggio in modo da renderlo più 'corto'
        sprite.mustChangeOutlineToWalk = true
      end
    end
    Runtime:addEventListener( "touch", sprite )
    ----------------------------------------------------------------------------

    local function preCollisionEvent( self, event )
      local collideObject = event.other
      if ( collideObject.collType == "passthru" ) then
        event.contact.isEnabled = false  --disable this specific collision
      end
      if(event.other.name == "ground") then --se ho toccato il suolo dico allo sprite che non è più in salto, in modo da cambiare l'animazione
        self.isJumping = false
      end
    end
    sprite.preCollision = preCollisionEvent
    sprite:addEventListener( "preCollision" )


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

      --questa parte di codice serve per cambiare l'outline da 'jumping' a 'walking' quando si torna a terra
      local vx, vy = sprite:getLinearVelocity() -- riconosco se sto saltando
      if(vy > 1000) and (sprite.isJumping) then --se sto tornando a terra cambio l'outline e il mio corpo in walking
        if(sprite.mustChangeOutlineToWalk) then --ci entrà solo 1 volta per salto
          changeOutline("walk")
          print("changed")
          sprite.mustChangeOutlineToWalk = false
        end
      end
    end


    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    -------- FUNZIONI PER LO SCROL DEL CASTELLO FINALE DOVE ENTRERO'  ----------
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
    function spriteScrollToCastle() --avvicina lo sprite al castello
      local CastlePosition = castle.x - 20 --piglio la posizione del castello
      if(sprite.x <= CastlePosition) then --se la posizione dello sprite è dietro a quella del castello, vado ancora avanti
        sprite.x = sprite. x + 3 --lo sposto in avanti di 3
      else
        goToTheNewScene()
      end
    end
    function goToTheNewScene()
      composer.gotoScene( "menu-levels", "fade", 500 ) --vado alla nuova scena
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
            timer.cancel( callingEnemies ) --non chiamo più nemici
            timer.cancel( callingPlasticbag ) --non chiamo più sacchetti di plastica
            sprite:removeEventListener("collision") --rimuove l'ascoltatore delle collisioni con i nemici
            Runtime:addEventListener("enterFrame", castleScroll) --chiamo la funzione castleScroll per spostare il castello
          end
        end
      end
    end


    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    -------------- FUNZIONI PER CAMBIARE L'OUTLINE DELLO SPRITE ----------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    function changeOutline(phase) --dentro a phase passerò la fase a cui devo andare (se sto camminando o saltando)
      if(tostring(phase) == "walk") then --se devo camminare..
        sprite:setSequence("walking") --dico allo sprite di camminare
        physics.removeBody(sprite) --rimmuovo inizialmente il corpo fisico allo sprite..
        physics.addBody(sprite, { outline=outlineSpriteWalking, density=4, bounce=0, friction=1}) -- ... e glielo dirò subito dopo
        sprite.gravityScale = 3
        sprite.isFixedRotation = true --rotazione bloccata
      elseif (tostring(phase) == "jump") then --se devo saltare..
        sprite:setSequence("jumping") --dico allo sprite di saltare
        physics.removeBody(sprite) --rimuovo inizialmente il corpo fisico allo sprite..
        physics.addBody(sprite, { outline=outlineSpriteJumping, density=4, bounce=0, friction=1}) -- ... e glielo dirò subito dopo
        sprite.gravityScale = 3
        sprite.isFixedRotation = true --rotazione bloccata
      end
    end

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
        stopCreatingEnemies = 1
        timer.performWithDelay( 500, function() composer.gotoScene( "menu-levels", "fade", 500 ) end)  --ritorno al menu dei livelli
      end
    end
    button_home:addEventListener( "touch", touch )

    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    ---------------------------------- TIMER  ----------------------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    timeplayed = timer.performWithDelay( 1000, increaseGameSpeed, 0 ) --farà passare  i secondi del gioco per aumentare la velcoità di gioco
    gameLoop = timer.performWithDelay( time_speed_min, loop, 0 ) --loop del gioco in cui fa muovere gli sprite
    callingEnemies = timer.performWithDelay( math.random(enemyTimeSpawnMin, enemyTimeSpawnMax), enemiesLoop, 0 ) --chiama in nemici con un random tra un minimo e massimo
    callingPlasticbag = timer.performWithDelay( (timeToPlay/plasticToCatch)*1000, plasticbagLoop, plasticToCatch) --chiama gli oggetti di plastica ogni 10 secondi
  end
end
function scene:hide( event )
  local sceneGroup = self.view

  local phase = event.phase

  if event.phase == "will" then

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
    composer.removeScene( sceneToRemove)
  end

end

function scene:destroy( event )

  -- Called prior to the removal of scene's "view" (sceneGroup)
  --
  -- INSERT code here to cleanup the scene
  -- e.g. remove display objects, remove touch listeners, save state, etc.
  local sceneGroup = self.view
  audio.dispose( musicLevel1)
end


----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  -----------------     FUNZIONE PER AGGIORNARE IL DB      -------------------
  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
    
function updateHighScore(scoreCount) --funzione che serve per aggiornare l'high score dell'utente
  local sqlite3 = require( "sqlite3" )
  local path = system.pathForFile( "data.db", system.DocumentsDirectory )
  local db = sqlite3.open( path )
  local levels = {} --creo una  tabella per memorizzare i dati che mi servrà per scegliere se il punteggio è un record o no
  for row in db:nrows( "SELECT level, scoreLevel"..localLevel.." FROM levels" ) do
    levels[#levels+1] =
    {
      print(tostring(row)),
      --FirstName = row.FirstName,
      level = row.level,
      scoreLevel = row.scoreLevel1
    }
    local oldScore= levels[1].scoreLevel --salvo il punteggio che è già presente all'interno del database
    local levelReached = levels[1].level --mi scrivo il livello a cui è arrivato l'utente all'interno del gioco, se è l'1 allora aggiorneremo a 2 e gli permetteremo di fare un nuovo livello

    if(tonumber(levelReached) == tonumber(localLevel)) then --se sono al livello 1, devo aumentare il livello a cui può giocare l'utente (sbloccare quello dopo)
      if (tonumber(oldScore)<scoreCount) then --se il nuovo è punteggio è maggiore di quello già presente nel db entro nell'if
        local query =("UPDATE levels SET level ='" .. (levelReached+1) .. "' ,scoreLevel1 = '" ..scoreCount .. "' WHERE ID = 1")
        local pushQuery = db:exec (query) --se ritorna 0 allora ho modificato correttamente il db
      elseif (tonumber(oldScore) >= scoreCount) then
        --devo solamente aumentare solo il livello a cui può giocare l'utente
        local query =("UPDATE levels SET level ='" .. (levelReached+1) .. "' WHERE ID = 1")
        local pushQuery = db:exec (query) --se ritorna 0 allora ho modificato correttamente il db
      end
    else
      if((tonumber(oldScore) < scoreCount)) then --se ho già sbloccato il livello successivo controllo che il vecchio punteggio fosse maggiore o minore di quello attuale
        local query =("UPDATE levels SET scoreLevel1 = '" ..scoreCount .. "' WHERE ID = 1")
        local pushQuery = db:exec (query)
      end
    end
  end
end
----------------------------------------------------------------------------

function resetScene( tipo)

  --LA DIFFERENZA TRA I DUE TIPI E' CHE:
  -- IN (TIPO == "GAMEFINISHED") DEVO CANCELLARE PIU' ASCOLTATORI E TIMER COME QUELLO DELLA COMPARSA DEL CASTELLO

  --ELIMINO PRIMA LE COSE IN COMUNE
  --resetto le variabili per capire se sta suonando la musica di background nel menu o nel menu levels
  composer.isAudioPlayingMenu=0;
  composer.isAudioPlaying=0;

  --cancello i timer di gioco
  timer.cancel( gameLoop )
  timer.cancel( callingEnemies )
  timer.cancel( callingPlasticbag )
  timer.cancel( timeplayed )

  --svuoto le tabelle e i timer che ci sono dentro quelle tabelle o i loro ascoltatori
  for i=1, #enemies do
    enemies[i]:removeSelf() -- Optional Display Object Removal
    enemies[i] = nil        -- Nil Out Table Instance
  end
  for i=1, #table_plasticbag do
    table_plasticbag[i]:removeSelf() -- Optional Display Object Removal
    table_plasticbag[i] = nil        -- Nil Out Table Instance
  end

  physics.pause() --stoppo la fisica

  --elimino i listeners
  Runtime:removeEventListener("enterFrame",enemy)
  Runtime:removeEventListener("enterFrame",plasticbag)
  button_home:removeEventListener( "touch", touch )
  Runtime:removeEventListener( "touch", sprite )

  if tipo == "gameOver" then
    audio.dispose(crunchSound) --lo elimino dalla memoria
    sprite:removeEventListener("collision") --elimino il listener della collisione dello srpite
  elseif tipo == "gamefinished" then

    audio.pause(crunchSound) --blocco l'audio crunch nel caso stesse suonando
    audio.dispose(crunchSound) --lo elimino dalla memoria

    --ELIMINO I LISTENERS DEL CASTELLO
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