-----------------------------------------------------------------------------------------
--
-- TERZO LIVELLO DEL GIOCO: SALTARE I NEMICI E RACCOGLIERE LA PLASTICA DAL CIELO
--
-----------------------------------------------------------------------------------------

-- dichiaro delle variabili che andrò a usare in varie scene del livello
local localLevel = 3 --VARIABILE CHE CONTIENE IL NUMERO DI LIVELLO A CUI APPARTIENE IL FILE LUA: IN QUESTO CASO SIAMO AL LIVELLO 1
local composer = require( "composer" ) --richiedo la libreria composer
local scene = composer.newScene() --nuova scena composer
local tutorial = 1 --ho completato il tutorial? se è 0 devo ancora farlo!
local bg --variabile che durante lo show conterrà le due immagini di sfondo che andranno una dopo l'altra
local punteggio --variabile che conterrà il mio punteggio del livello
local sprite --sprite del personaggio
local enemies = {} --sprite dei nemici
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
local timeToPlay = 70 --variabile che conterrà quanto l'utente dovrà sopravvivere all'interno del gioco
local scoreCount    --variabile conteggio punteggio iniziale
local gameFinished
local newTimerOut
local nextScene = "menu-levels"
local crunchSound = audio.loadSound("MUSIC/crunch.mp3")
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
  sceneGroup:insert( group_tutorial ) --inserisco il gruppo group_background dentro la scena
  sceneGroup:insert( group_background ) --inserisco il gruppo group_background dentro la scena
  sceneGroup:insert( group_castle ) --inserisco il gruppo castle sopra la scena e sotto i personaggi
  sceneGroup:insert( group_elements ) --inserisco il gruppo group_elements dentro la scena
end

function scene:show( event )
  local phase = event.phase

  if phase == "will" then
    -- Called when the scene is still off screen and is about to move on screen
    --richiedo la libreria necessaria per inserire la fisica all'interno del livello
    local physics = require("physics")
    physics.start()
    -- Overlays collision outlines on normal display objects
    physics.setGravity( 0,41 )
    physics.setDrawMode( "hybrid" )
    -- The default Corona renderer, with no collision outlines
    --physics.setDrawMode( "normal" )
    -- Shows collision engine outlines only
    --physics.setDrawMode( "debug" )

  elseif phase == "did" then
    if(tutorial == 0) then
      --[[ DA FARE


      --visualizzare il tutorial del gioco, all'interno del gruppo 'group_tutorial'
    

      ]]--
    elseif(tutorial == 1) then
      --VARIABILE CHE CONTIENE TUTTE LE INFORMAZIONI DEL LIVELLO
      local options = {
        effect = "fade",
        time = 1000,
        params = { level="level3"}
      }
      --ELIMINARE IL GRUPPO DEL TUTORIAL
      -- INIZIALIZZO LE VARIABILI CHE VERRANNO USATE NEL GIOCO
      local secondsPlayed = 0 --quanti secondi sono passati dall'inizio del gioco
      local castleAppared = 0 --variabile fuffa che mi servirà per controllare se il castello è già apparso sullo schermo una volta
      scoreCount = 0 --variabile conteggio punteggio iniziale
      -- VARIABILI PER LO SFONDO DI BACKGROUND {
      local _w = display.actualContentWidth  -- Width of screen
      local _h = display.actualContentHeight  -- Height of screen
      local _x = 0  -- Horizontal centre of screen
      local _y = 0  -- Vertical centre of screen

      bg={} -- 'vettore' che conterrà i due sfondi del gioco
      bg[1] = display.newImageRect("immagini/livello-3/background.png", _w, _h)
      bg[1].anchorY = 0
      bg[1].anchorX = 0
      bg[1].x = 0
      bg[1].y = _y
      group_background:insert(bg[1])
      bg[2] = display.newImageRect("immagini/livello-3/background.png", _w, _h)
      bg[2].anchorY = 0
      bg[2].anchorX = 0
      bg[2].x = _w
      bg[2].y = _y
      group_background:insert(bg[2])

      ------------------------------------------------------------
      -- VARIABILI MOLTO IMPORTANTI PER IL GIOCO: VELOCITA' DI GIOCO
      local enemySpeed_max = 8 -- massima velocità di spostamento del nemico
      local enemySpeed_min = 4-- minima velocità di spostamento del nemico
      local enemySpeed = enemySpeed_min --velocità di spostamento del nemico

      local frame_speed = 14 --questa sarà la velocità dello scorrimento del nostro sfondo, in base a questa velocità alzeremo anche quella del gioco

      local time_speed_min = 20 -- ogni quanti millisecondi verranno chiamate le funzioni di loop (esempio di sfondo group_background)
      local time_speed_max = 10 --massimo di velocità che time_speed può raggiungere

      local spriteFrameSpeed = 800 --velocità del movimento delle gambe dello sprite [250 - 800]
      local spriteFrameSpeed_max = 200 --velocità del movimento delle gambe dello sprite [250 - 800]

      local plasticToCatch = 7
      ------------------------------------------------------------
      --}
      --VARIABILI PER GLI ELEMENTI DELLO SCHERMO{
      local groundHeight = 100
      local ground = display.newRect( 0, 0,99999, groundHeight )
      ground:setFillColor(0,0,0,0)
      ground.name = "ground"
      group_elements:insert(ground)
      ground.x = display.contentCenterX
      ground.y = display.contentHeight- groundHeight/2
      physics.addBody(ground, "static",{bounce=0, friction=1 } )
      --

      --TESTO DELLO SCORE
      local scoreText = display.newText( scoreCount.."/"..plasticToCatch, display.contentCenterX, display.contentCenterY-300, native.systemFont, 28 )
      scoreText:setFillColor( 1, 1, 0 )
      group_elements:insert(scoreText)
      gameFinished = 0
      --}
      --VARIABILI PER GLI SPRITE {

      --PERSONAGGIO DEL GIOCO
      local spriteWalkingSheetData =
      {
        width=160,
        height=160,
        numFrames=8,
        sheetContentWidth=1280,
        sheetContentHeight=160
      }

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
        { name="walking", sheet=spriteWalkingSheet, start=1, count=8, time=spriteFrameSpeed, loopCount=0 },
        { name="jumping", sheet=spriteJumpingSheet, start=1, count=8, time=800, loopCount=0 }
      }
      --metto assieme tutti i dettagli dello sprite, elencati in precedenza
      sprite = display.newSprite( spriteWalkingSheet, spriteData )
      sprite.name = "sprite"
      group_elements:insert(sprite)
      sprite.x = (display.contentWidth/2)-390	
      sprite.y = ground.y - 100
      local frameIndex = 1
      local outlineSpriteWalking = graphics.newOutline(2, spriteWalkingSheet, frameIndex)   --outline personaggio
      local outlineSpriteJumping = graphics.newOutline(2, spriteJumpingSheet, 4)   --outline personaggio
      physics.addBody(sprite, { outline=outlineSpriteWalking, density=4, bounce=0, friction=1}) --sprite diventa corpo con fisica
      sprite.gravityScale = 3
      sprite.isFixedRotation = true --rotazione bloccata
      sprite.isJumping = false
      --sprite.mustChangeOutlineToWalk = false --variabile che mi servirà per  cambiare l'outline del personaggio da jumping a walking

      -- PRIMO NEMICO
      local enemyWalkingSheetData = { width=200, height=200, numFrames=6, sheetContentWidth=1200, sheetContentHeight=200 }
      local enemyWalkingSheet = graphics.newImageSheet( "immagini/livello-3/ratto.png", enemyWalkingSheetData )
      local enemyData = {
        { name="walking", sheet=enemyWalkingSheet, start=1, count=6, time=800, loopCount=0 }
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

      --CASTELLO DI SABBIA IN CUI ENTRERO' A FINE LIVELLO
      castle = display.newImageRect( "immagini/livello-2/last-destination.png", 700, 700 )
      castle.x = display.actualContentWidth + 800
      castle.y = ground.y - castle.height/2 - groundHeight/2
      group_castle:insert(castle)
      
      -- AGGIUNTO NEL LIVELLO 2 ---

      --PROIETTILE
      local bulletSheetData = { width=200, height=84, numFrames=3, sheetContentWidth=600, sheetContentHeight=84 }
      local bulletSheet = graphics.newImageSheet( "immagini/livello-2/ecoproiettile.png", bulletSheetData )
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
      local spineSheetData = { width=190, height=190, numFrames=9, sheetContentWidth=1710, sheetContentHeight=190 }
      local spineSheet = graphics.newImageSheet( "immagini/livello-3/spine2.png", spineSheetData )
      local spineData = {
        { name="spine", sheet=spineSheet, start=1, count=9, time=800, loopCount=0 }
      }
      local spineTimeSpawn = 5000

      -- PIATTAFORMA 
     -- platform = display.newImageRect( "immagini/livello-2/platform.png", 320, 225 )
     -- platform.x = display.actualContentWidth + 800
      --platform.y = display.contentHeight / 2
      --group_castle:insert(platform)
      local platformTimeSpawn = 10100
      --FUNZIONI {

      local function moveBackground(self)
        --questa funzione muove il group_background di sfondo
        if 	self.x<-(display.contentWidth-frame_speed*2) then
          self.x = display.contentWidth
        else
          self.x =self.x - frame_speed
        end
      end

      ------------------------------------------------
      -- FUNZIONI PER IL PRIMO NEMICO {
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
        if(type == "rat") then
          enemy = display.newSprite( enemyWalkingSheet, enemyData )
          enemy.x = display.actualContentWidth  + 200
          enemy.y = ground.y-150
          frameIndexNemico = 1;
          enemy.id = 0
          local outlineNemico = graphics.newOutline(6, enemyWalkingSheet, frameIndexNemico)
          physics.addBody(enemy, { outline=outlineNemico, density=5, bounce=0, friction=1})
          enemy.bodyType = "dynamic"
        elseif (type == "bat") then
          enemy = display.newSprite( batWalkingSheet, batData )
          enemy.id = 1
          enemy.x = display.actualContentWidth  + 50
          enemy.y = (display.contentHeight / 2) - 90
          frameIndexNemico = 1;
          local outlineNemico = graphics.newOutline(5, batWalkingSheet, frameIndexNemico)
          physics.addBody(enemy, { outline=outlineNemico, density=5, bounce=0, friction=1})
          enemy.bodyType = "dynamic"
        end
        enemy.name = "enemy"
        enemy:play()
        group_elements:insert(enemy)
        
        enemy.isFixedRotation = true
        enemy.gravityScale = 5
        table.insert(enemies, enemy)
        return enemy
      end
      ------------------------------------------------
      local function enemiesLoop()
        if(stopCreatingEnemies == 0) then
          enemy = createEnemies("rat")
          enemy.enterFrame = enemyScroll
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
      --}
      ------------------------------------------------
      local function enemiesBatLoop()
        if(stopCreatingEnemies == 0) then
          enemy = createEnemies("bat")
          enemy.enterFrame = enemyScroll
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
      --}
      ------------------------------------------------
      -- FUNZIONI PER IL SACCHETTO DI PLASTICA CHE VOLA{
      local function plasticbagScroll(self, event)
        --fa scorrere il sacchetto nello schermo
        if stop == 0 then
          self.x = self.x - (enemySpeed*2)
          local spostamentoaria = math.random(-5, 5)
          self.y = self.y + spostamentoaria
        end
      end
      ------------------------------------------------
      local function createPlasticbag()
        --crea un oggetto di un nuovo sprite del sacchetto e lo aggiunge alla tabella table_plasticbag[]
        --da implementare meglio, mi faccio passare che tipo di nemico devo inserire
        local plasticbag = display.newSprite( plasticbagSheet, plasticbagData )
        plasticbag.name = "plasticbag"
        plasticbag:play()
        group_elements:insert(plasticbag)
        plasticbag.x = display.actualContentWidth + 65
        plasticbag.y = 200
        local frameIndePlasticbag = 1;
        local outlinePlasticbag = graphics.newOutline(20, plasticbagSheet, frameIndePlasticbag)
        physics.addBody(plasticbag, { outline=outlinePlasticbag, density=1, bounce=0, friction=1})
        plasticbag.isBullet = true
        plasticbag.isSensor = true
        plasticbag.bodyType = "static"
        table.insert(table_plasticbag, plasticbag)
        return plasticbag
      end
      ------------------------------------------------
      local function plasticbagLoop()
        if(stopCreatingEnemies == 0) then
          plasticbag = createPlasticbag(plasticType) --creo un'istanza di un oggetto sprite plastic bag
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
      --}
      ------------------------------------------------
      function gameOver() 
        stop = 1 -- grazie a questo le animazioni personagggi non scrolleranno più
        stopCreatingEnemies = 1
        -- audio
        audio.pause(crunchSound)	
        audio.setMaxVolume(0.03)	
        local audiogameover = audio.loadSound("MUSIC/PERDENTE.mp3")	
        audio.play(audiogameover)
        --audio.play(audiogameover)
        resetScene("all")
        composer.gotoScene( "levels.gameover", options )
      end
      ------------------------------------------------
      --funzione che capisce se c'è collisione con un elemento
      function sprite.collision( self, event )
        if( event.phase == "began" ) then
          --tutte le informazioni dell'elemento che ho toccato le troviamo dentro event.other
          if(event.other.name ==  "plasticbag") then --mi sono scontrato con il sacchetto
            audio.setMaxVolume(0.03)	
            audio.play(crunchSound)
            scoreCount = scoreCount+1;
            scoreText.text = scoreCount.."/"..plasticToCatch
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

        -----------------------------------------------
      local function preCollisionEvent( self, event )
        local collideObject = event.other
        if ( collideObject.collType == "passthru" ) then
          --event.contact.isEnabled = false  --disable this specific collision
        end
      end
      sprite.preCollision = preCollisionEvent
      sprite:addEventListener( "preCollision" )
      ------------------------------------------------
      local function loop( event )
        --qui dentro metteremo tutte le cose che necessitano di un loop all'interno del gioco
        --richiamo le due funzioni per muovere lo sfondo
        moveBackground(bg[1])
        --print(bg[1].x)
        moveBackground(bg[2])
        sprite:play()
        local vx, vy = sprite:getLinearVelocity()
        --print(tostring(vy))  
        if(vy < -5) and (sprite.isJumping) then --se sto tornando a terra cambio l'outline e il mio corpo in walking
          --changeOutline("walk") --cambio l'outline del mio personaggio a quella della camminata -> più grossa e tozza
          --sprite.mustChangeOutlineToWalk = false
        end
        if(sprite.x < 0) then
          gameOver()
        end
      end
      ------------------------------------------------

      ------------------------------------------------
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
        local CastlePosition = castle.x - 80 --piglio la posizione del castello
        if(sprite.x <= CastlePosition) then --se la posizione dello sprite è dietro a quella del castello, vado ancora avanti
          sprite.x = sprite. x + 3 --lo sposto in avanti di 3
        else
          goToTheNewScene()
        end
      end
      function goToTheNewScene()
        composer.gotoScene( "menu-levels", "fade", 500 ) --vado alla nuova scena
      end
      ----------------------------------------------
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
            stop = 1	
            if (castleAppared == 0 ) then --se non ho già fatto apparire il castello, lo faccio apparire	
              print("dovrebbe apparire il castello")	
              castleAppared = 1 --non lo faccio più riapparire	
              sprite:removeEventListener("collision")	
              Runtime:addEventListener("enterFrame", castleScroll) --chiamo la funzione castleScroll per spostare il castello	
            end	
          end	
        end	
      end
      ----------------------------------------------------------
      --[[function changeOutline(phase)	
        if(tostring(phase) == "walk") then	
            sprite:setSequence("walking")	
            physics.removeBody(sprite)	
            physics.addBody(sprite, { outline=outlineSpriteWalking, density=4, bounce=0, friction=1})    --sprite diventa corpo con fisica	
            sprite.gravityScale = 3	
            sprite.isFixedRotation = true --rotazione bloccata	
        elseif (tostring(phase) == "jump") then	
            sprite:setSequence("jumping")	
            --physics.removeBody(sprite)	
            --physics.addBody(sprite, { outline=outlineSpriteJumping, density=4, bounce=0, friction=1})    --sprite diventa corpo con fisica	
            sprite.gravityScale = 3	
            --sprite.jumping = true
            sprite.isFixedRotation = true --rotazione bloccata	
            end	
         end]]--

      -- }
      --bottone per uscire dal livello e tornare al menu del livelli
      button_home = display.newImageRect( "immagini/menu/home.png", 100, 100 )
      button_home.anchorX =  0
      button_home.anchorY =  0
      button_home.x = display.actualContentWidth - 120
      button_home.y = 50
      group_elements:insert(button_home)

      function button_home:touch( event )
        if event.phase == "ended" then
          stop = 1
          timer.performWithDelay( 500, function() composer.gotoScene( "menu-levels", "fade", 500 ) end)  --ritorno al menu dei livelli
        end
      end
      button_home:addEventListener( "touch", touch )

      --------------------------------------------------
      --------- PARTI AGGIUNTE NEL LIVELLO 2 -----------
      --------------------------------------------------

      -- FUNZIONI PER IL PROIETTILE 'LATTINA DI PLASTICA'
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
        ------------------------------------------------
        -- Global collision handling
        function onBulletCollision( event )
          print(tostring(event.other.name))
          if(tostring(event.other.name) == "enemy") then --se il proiettile si è scontrato contro un nemico allora..
            enemyKilled = event.other --salvo dentro enemyKilled l'indirizzo che mi porta al nemico ucciso
            --Riproduco l'animazione dell'esplosione nelle stesse coordinate in cui si trova il nemico nel momento della collisione
            local explosion = display.newSprite( explosionSheet, explosionData ) --salvo dentro explosion l'animazione dell'esplosione
            explosion.name = "explosion"
            group_elements:insert(explosion)
            explosion.x = enemyKilled.x
            explosion.y = enemyKilled.y
            explosion:play()

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
          local outlineBullet = graphics.newOutline(6, bulletSheet, 2)
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

      function touchListener(event)
        if ( event.phase == "began" ) then --è finito il processo di touch dello sschermo
          if ((event.x >= 0 ) and (event.x <= display.actualContentWidth/2) and (not sprite.isJumping) )then
            print("dentrissimo")
            sprite:setLinearVelocity(0,- 1650)
            sprite.isJumping = true -- se ho toccato imposto la variabile isJumping del mio personaggio a true
            sprite:setSequence("jumping") --lo sprite si muove con animazione jumping
            sprite:play()
            --sprite.mustChangeOutlineToWalk = true
            print(sprite.x.."è la posizione del mio sprite")
          elseif (event.x > display.actualContentWidth / 2) and (event.x <= display.contentWidth) then
            --ho cliccato sulla parte destra dello shcermo, devo sparare
            if(scoreCount > 0) then
              bulletsLoop()
              scoreCount = scoreCount - 1
              scoreText.text = scoreCount.."/"..plasticToCatch
            end
          end
        end
      end
      Runtime:addEventListener( "touch", touchListener )

      -- FUNZIONI PER LE POZZE DI LIQUIDO ASSASSINO {
        local function spineScroll(self, event)
          --fa scorrere il nemico nello schermo
          if stop == 0 then
            self.x = self.x - (enemySpeed*2)
            self.y = ground.y - 150
          end
        end
        ------------------------------------------------
        local function createSpine()
          --crea un oggetto di un nuovo sprite nemico e lo aggiunge alla tabella enemies[]
          --da implementare meglio, mi faccio passare che tipo di nemico devo inserire
          local spine = display.newSprite( spineSheet, spineData )
          spine.name = "spine"
          spine:play()
          group_elements:insert(spine)
          spine.x = display.actualContentWidth + 150
          spine.y = ground.y - 150
          local outlineSpine = graphics.newOutline(1, spineSheet, 3)
          physics.addBody(spine, { outline=outlineSpine, density=1, bounce=0, friction=1})
          spine.isBullet = true
          spine.isSensor = true
          spine.bodyType = "dynamic"
          return spine
        end
        ------------------------------------------------
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
       --------------------------------------------------
      --------- PARTI AGGIUNTE NEL LIVELLO 3 -----------
      --------------------------------------------------

        -- FUNZIONI PER LE PIATTAFORME {
          local function platformScroll(self, event)
            --fa scorrere il nemico nello schermo
            if stop == 0 then
              self.x = self.x - (enemySpeed*2)
            end
          end
          ------------------------------------------------
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
          ------------------------------------------------
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
          
         --[[ local function preCollisionEvent( self, event )
 
            local collideObject = event.other
            if ( collideObject.collType == "passthru" ) then
               event.contact.isEnabled = false  --disable this specific collision
            end
          end
          
          sprite.preCollision = preCollisionEvent
          sprite:addEventListener( "preCollision" ) --]]

      --PARTE FINALE: richiamo le funzioni e aggiungo gli elementi allo schermo e ai gruppi
      timeplayed = timer.performWithDelay( 1000, increaseGameSpeed, 0 )
      gameLoop = timer.performWithDelay( time_speed_min, loop, 0 )

      callingEnemies = {}
      callingBats = {}
      callingPlasticbag = {}
      callingSpine = {}
      callingPlatform = {}

      --ratti 
      callingEnemies[1] = timer.performWithDelay( 7000, enemiesLoop, 1 )
      callingEnemies[2] = timer.performWithDelay( 32000, enemiesLoop, 0 )
      callingEnemies[3] = timer.performWithDelay( 3000, enemiesLoop, 1 )
      callingEnemies[4] = timer.performWithDelay( 18000, enemiesLoop, 1 )
      callingEnemies[5] = timer.performWithDelay( 28000, enemiesLoop, 1 )
      callingEnemies[6] = timer.performWithDelay( 42000, enemiesLoop, 1 )
      callingEnemies[7] = timer.performWithDelay( 57000, enemiesLoop, 1 )

      --pipistrelli
      callingBats[1] = timer.performWithDelay( 6500, enemiesBatLoop, 9 )
      callingBats[2] = timer.performWithDelay( 21700, enemiesBatLoop, 1 )
      callingBats[3] = timer.performWithDelay( 12000, enemiesBatLoop, 1 )
      callingBats[4] = timer.performWithDelay( 51000, enemiesBatLoop, 1 )

      --piattaforme 
      callingPlatform[1] = timer.performWithDelay( 1000, platformLoop, 1) 
      callingPlatform[2] = timer.performWithDelay( 25000, platformLoop, 1 )
      callingPlatform[3] = timer.performWithDelay( 17000, platformLoop, 0)
      callingPlatform[5] = timer.performWithDelay( 49000, platformLoop, 0)

      --spine
      callingSpine[1] = timer.performWithDelay( 5000, spineLoop, 0)
      callingSpine[2] = timer.performWithDelay( 38000, spineLoop, 1)
      callingSpine[3] = timer.performWithDelay( 11000, spineLoop, 0)
      callingSpine[4] = timer.performWithDelay( 23000, spineLoop, 1)
      callingSpine[5] = timer.performWithDelay( 34000, spineLoop, 1)
      callingSpine[6] = timer.performWithDelay( 53000, spineLoop, 1)
      callingSpine[7] = timer.performWithDelay( 44000, spineLoop, 1)



      --plastiche
      callingPlasticbag[1] = timer.performWithDelay( 1140, plasticbagLoop, 1)
      callingPlasticbag[2] = timer.performWithDelay( 17140, plasticbagLoop, 1)
      callingPlasticbag[3] = timer.performWithDelay( 47040, plasticbagLoop, 1)
      callingPlasticbag[4] = timer.performWithDelay( 49040, plasticbagLoop, 1)
      callingPlasticbag[25] = timer.performWithDelay( (timeToPlay/plasticToCatch)*1000, plasticbagLoop, plasticToCatch)
      -- aggiungere 29, 36, 43, 44
    end
  end
end
function scene:hide( event )
  local sceneGroup = self.view

  local phase = event.phase

  if event.phase == "will" then
    -- Called when the scene is on screen and is about to move off screen
    --
    -- INSERT code here to pause the scene
    -- e.g. stop timers, stop animation, unload sounds, etc.)
    --QUI BISOGNA SALVARE I DATI DEL GIOCATORE COME IL PUNTEGGIO
    print("game finished : " .. tostring(gameFinished))
    if(gameFinished == 1) then
      updateHighScore(scoreCount) --mando il punteggio appena raggiunto alla funzione che permetterà di aggiornarlo
      resetScene("gamefinished") --se entro qui devo cancellare anche un timeloop che è partito con l'avvicinamento del castello di sabbia
    else
      resetScene("gameOver")  --se entro qui sono uscito prima dal livello, devo eliminare meno timer all'interno del gioco
    end

  elseif phase == "did" then
    -- Called when the scene is now off screen
    --cancella tutto il contenuto all'interno di una scena senza salvare i contenuti
    local sceneToRemove = "levels.level"..localLevel
    composer.removeScene( sceneToRemove)
  end

end

function scene:destroy( event )

  -- Called prior to the removal of scene's "view" (sceneGroup)
  --
  -- INSERT code here to cleanup the scene
  -- e.g. remove display objects, remove touch listeners, save state, etc.
  local sceneGroup = self.view

end
----------------------------------------------
--FUNZIONE PER AGGIORNARE L'HIGHSCORE
function updateHighScore(scoreCount) --funzione che serve per aggiornare l'high score dell'utente
  local sqlite3 = require( "sqlite3" )
  local path = system.pathForFile( "data.db", system.DocumentsDirectory )
  local db = sqlite3.open( path )
  local levels = {} --creo una  tabella per memorizzare i dati che mi servrà per scegliere se il punteggio è un record o no
  for row in db:nrows( "SELECT level, scoreLevel3 FROM levels" ) do
    levels[#levels+1] =
    {
      --FirstName = row.FirstName,
      level = row.level,
      scoreLevel = row.scoreLevel3
    }
    local oldScore= levels[1].scoreLevel --salvo il punteggio che è già presente all'interno del database
    local levelReached = levels[1].level --mi scrivo il livello a cui è arrivato l'utente all'interno del gioco, se è l'1 allora aggiorneremo a 2 e gli permetteremo di fare un nuovo livello
    print("livello appena completato: ".. localLevel.." - vecchio punteggio:"..oldScore)
    if(tonumber(levelReached) == tonumber(localLevel)) then --se sono al livello 1, devo aumentare il livello
      if (tonumber(oldScore)<scoreCount) then --se il nuovo è punteggio è maggiore di quello già presente nel db entro nell'if
        print("devo aumentare di livello e inoltre aumento il punteggio")
        local query =("UPDATE levels SET level ='" .. (levelReached+1) .. "' ,scoreLevel3 = '" ..scoreCount .. "' WHERE ID = 1")
        print("query: ".. query)
        local pushQuery = db:exec (query)
        if(pushQuery == 0) then --se ritorna 0 allora ho modificato correttamente il db
          print(" Punteggio e livello correttamente modificati!")
        else
          print("ho provato a fare l'update della tabella ma non ci sono riuscito. codice errore: "..pushQuery) --errore
        end
      elseif (tonumber(oldScore) >= scoreCount) then
        --devo solamente aumentare solo il livello"
        local query =("UPDATE levels SET level ='" .. (levelReached+1) .. "' WHERE ID = 1")
        print("query: ".. query)
        local pushQuery = db:exec (query)
        if(pushQuery == 0) then --se ritorna 0 allora ho modificato correttamente il db
          print("livello correttamente modificati!")
        else
          print("ho provato a fare l'update della tabella ma non ci sono riuscito. codice errore: "..pushQuery) --errore
        end
      end
    else
      if((tonumber(oldScore) < scoreCount)) then
        local query =("UPDATE levels SET scoreLevel3 = '" ..scoreCount .. "' WHERE ID = 1")
        local pushQuery = db:exec (query)
        if(pushQuery == 0) then
          print(" Punteggio correttamente modificato!")
        else
          print("ho provato a fare l'update della tabella ma non ci sono riuscito. codice errore: "..pushQuery)
        end
      end
    end
  end
  if ( db and db:isopen() ) then --chiuso la connessione al database
    db:close()
  end
end
----------------------------------------------

function resetScene( tipo)
  if tipo == "gameOver" then
    --composer.isAudioPlayingMenu =0;	
    composer.isAudioPlaying=0;	
  	
    audio.dispose(crunchSound)
    timer.cancel( gameLoop )
    --timer.cancel( callingEnemies )
    --timer.cancel( callingPlasticbag )
    timer.cancel( timeplayed )
    --timer.cancel( callingSpine )
   -- timer.cancel( callingPlatform )
    --timer.cancel( callingBats )
    physics.pause()

    --ELIMINO I LISTENERS
    sprite:removeEventListener("collision")
    Runtime:removeEventListener("enterFrame",enemy)
    Runtime:removeEventListener("enterFrame",plasticbag)
    button_home:removeEventListener( "touch", touch )
    Runtime:removeEventListener( "touch", touchListener )
    Runtime:removeEventListener("enterFrame", bullet)

    --SVUOTO LE TABELLE
    for i=1, #callingEnemies do
      timer.cancel( callingEnemies[i] )
      callingEnemies[i] = nil        -- Nil Out Table Instance
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
    for i=1, #callingBats do
      timer.cancel( callingBats[i] )
      callingBats[i] = nil        -- Nil Out Table Instance
    end
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
  elseif tipo == "gamefinished" then
    audio.dispose(crunchSound)	
    --print("audio disposato nel livello 1")
    --ELIMINO I LISTENERS
    Runtime:removeEventListener( "collision", onBulletCollision )
    Runtime:removeEventListener( "touch", touchListener )
    Runtime:removeEventListener("enterFrame", spriteScrollToCastle)
    Runtime:removeEventListener("enterFrame", castleScroll)
    Runtime:removeEventListener("enterFrame",enemy)
    Runtime:removeEventListener("enterFrame",plasticbag)
    button_home:removeEventListener( "touch", touch )
    Runtime:removeEventListener("enterFrame", bullet)

    timer.cancel( gameLoop )
    --timer.cancel( callingEnemies )
    --timer.cancel( callingPlasticbag )
    timer.cancel( timeplayed )
    --timer.cancel( callingSpine )
    --timer.cancel( callingPlatform )
    --timer.cancel( callingBats )
    --timer.cancel( newTimerOut )
    physics.pause()

    --SVUOTO LE TABELLE
    for i=1, #callingEnemies do
      timer.cancel( callingEnemies[i] )
      callingEnemies[i] = nil        -- Nil Out Table Instance
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
    for i=1, #callingBats do
      timer.cancel( callingBats[i] )
      callingBats[i] = nil        -- Nil Out Table Instance
    end
    for i=1, #enemies do
      enemies[i]:removeSelf() -- Optional Display Object Removal
      enemies[i] = nil        -- Nil Out Table Instance
    end
    for i=1, #table_plasticbag do
      table_plasticbag[i]:removeSelf() -- Optional Display Object Removal
      table_plasticbag[i] = nil        -- Nil Out Table Instance
    end
    for i=1, #table_bullets do
      Runtime:addEventListener("enterFrame",  table_bullets[i])
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